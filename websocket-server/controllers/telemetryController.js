const dgram = require('dgram');
const { PORT } = require('../config');
const telemetry = require('../services/telemetryService');

const MAV_STX_V2 = 0xFD;
let mavSeq = 0;
const clients = new Map();

function clamp(n, min, max) {
  return Math.min(max, Math.max(min, n));
}

function randInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function jitter(n, delta, min, max) {
  return clamp(n + randInt(-delta, delta), min, max);
}

let powerState = {
  soc: 100,
  soh: 100,
  capacityAh: 200,
  hvVoltage: 50,
  hvCurrent: 0,
  hvTemp: 30,
  hvMainContactor: 1,
  motorCurrent: -10,
  dcDcPercent: 90,
  auxPercent: 100,
  dcBusVoltage: 50,
  hvFaultFlags: 0,
  maxCell: 3.65,
  minCell: 3.65,
  lvVoltage: 48,
  lvCurrent: 0,
  lvInputVoltage: 48,
  lvInputCurrent: 5,
  lvOutputCurrent: 0,
  lvChannelMask: 0x3F,
  lvChannelCurrents: [1,1,1,1,1,1],
  lvTemperature: 30,
  lvCanStatus: 1,
  lvLastReset: Date.now(),
  lastTime: Date.now(),
};

function updatePowerState() {
  const now = Date.now();
  const dt = (now - powerState.lastTime) / 1000;
  powerState.lastTime = now;
  const dtHours = dt / 3600;
  if (typeof powerState.targetCurrent === "undefined") {
    powerState.targetCurrent = -30;
  }
  if (Math.random() < 0.02) {
    if (powerState.soc <= 20) {
      powerState.targetCurrent = 10 + Math.random() * 30;
    } else {
      if (Math.random() < 0.85) {
        powerState.targetCurrent = -(15 + Math.random() * 85);
      } else {
        powerState.targetCurrent = -(30 + Math.random() * 170);
      }
    }
  }
  const rampRate = 10 * dt;
  if (powerState.hvCurrent < powerState.targetCurrent) {
    powerState.hvCurrent += rampRate;
    if (powerState.hvCurrent > powerState.targetCurrent) powerState.hvCurrent = powerState.targetCurrent;
  } else if (powerState.hvCurrent > powerState.targetCurrent) {
    powerState.hvCurrent -= rampRate;
    if (powerState.hvCurrent < powerState.targetCurrent) powerState.hvCurrent = powerState.targetCurrent;
  }
  const socChange = (powerState.hvCurrent * dtHours) / powerState.capacityAh * 100;
  powerState.soc += socChange;
  if (powerState.soc < 15) powerState.soc = 15;
  if (powerState.soc > 100) powerState.soc = 100;
  if (powerState.soc <= 18 && powerState.hvCurrent < 0) {
    powerState.targetCurrent = 15 + Math.random() * 20;
  }

  const minV = 40;
  const maxV = 58.4;

  const socVoltage = minV + (powerState.soc / 100) * (maxV - minV);

  const loadSag = powerState.hvCurrent * 0.02;

  powerState.hvVoltage = socVoltage - loadSag + (Math.random() - 0.5) * 0.2;

  if (powerState.hvVoltage < minV) powerState.hvVoltage = minV;

  const ambientTemp = 25;
  const heat = (powerState.hvCurrent * powerState.hvCurrent) * 0.00003;
  const cooling = 0.02 * (powerState.hvTemp - ambientTemp);
  powerState.hvTemp += heat - cooling + (Math.random() - 0.5) * 0.1;
  if (powerState.hvCurrent > 0) {
    if (powerState.hvTemp > 60) powerState.hvTemp = 60;
  } else {
    if (powerState.hvTemp > 65) powerState.hvTemp = 65;
  }
  if (powerState.hvTemp < -30) powerState.hvTemp = -30;
  const avgCell = powerState.hvVoltage / 16;
  let maxCell = avgCell + (Math.random() - 0.5) * 0.03;
  let minCell = avgCell + (Math.random() - 0.5) * 0.03;
  if (minCell > maxCell) [maxCell, minCell] = [minCell, maxCell];
  maxCell = Math.min(4.6, maxCell);
  minCell = Math.max(2.8, minCell);
  const SOH_DEGRADATION_RATE = 0.005;
  powerState.soh -= SOH_DEGRADATION_RATE * dt;
  if (powerState.hvTemp > 50) {
    powerState.soh -= (powerState.hvTemp - 50) * 0.00002;
  }
  if (powerState.soh > 100) powerState.soh = 100;
  if (powerState.soh < 10) powerState.soh = 100;
  powerState.maxCell = maxCell;
  powerState.minCell = minCell;
  let faults = 0;
  if (powerState.hvVoltage > 70) {
    faults |= 1 << 0;
  } else if (powerState.hvVoltage < 30) {
    faults |= 1 << 1;
  }
  if (powerState.hvTemp > 75) faults |= 1 << 2;
  if ((maxCell - minCell) > 0.05) faults |= 1 << 3;
  powerState.hvFaultFlags = faults;
  powerState.hvMainContactor = Math.random() < 0.98 ? 1 : 0;
  powerState.motorCurrent = -10 + Math.sin(now / 2000) * 5 + (Math.random() - 0.5) * 2;
  powerState.dcDcPercent -= 1;
  if (powerState.dcDcPercent < 70) powerState.dcDcPercent = 90;
  powerState.auxPercent -= 1;
  if (powerState.auxPercent < 70) powerState.auxPercent = 100;
  powerState.dcBusVoltage = 400 + Math.sin(now / 3000) * 5 + (Math.random() - 0.5) * 2;
  const totalLoad = powerState.lvChannelCurrents.reduce((a,b)=>a+b,0);
  powerState.lvCurrent = totalLoad;
  powerState.lvVoltage = 48 - totalLoad * 0.05;
  if (now - powerState.lvLastReset > 60000) {
    powerState.lvInputVoltage = 48;
    powerState.lvInputCurrent = 5;
    powerState.lvTemperature = 30;
    powerState.lvLastReset = now;
  }
  powerState.lvInputVoltage = 48 + Math.sin(now / 4000) * 2 + (Math.random() - 0.5) * 0.5;
  powerState.lvInputCurrent = 5 + Math.sin(now / 3000) * 1.5 + (Math.random() - 0.5) * 0.3;
  for (let i = 0; i < 6; i++) {
    if (Math.random() < 0.01) {
      powerState.lvChannelMask ^= (1 << i);
    }
    powerState.lvChannelCurrents[i] = (powerState.lvChannelMask & (1 << i)) ? 1 + Math.random() * 3 : 0;
  }
  powerState.lvOutputCurrent = powerState.lvChannelCurrents.reduce((a,b)=>a+b,0);
  powerState.lvInputPower = powerState.lvInputVoltage * powerState.lvInputCurrent;
  powerState.lvLoadPower = powerState.lvInputVoltage * powerState.lvOutputCurrent;
  powerState.lvTemperature = 30 + (powerState.lvLoadPower * 0.01) + (Math.random() - 0.5) * 1;
  if (powerState.lvTemperature > 80) powerState.lvTemperature = 80;
  if (powerState.lvTemperature < 20) powerState.lvTemperature = 20;
  if (powerState.lvCanStatus == 1 && Math.random() < 0.01) {
    powerState.lvCanStatus ^= 1;
  }
}

function crcAccumulate(crc, value) {
  let tmp = (value ^ (crc & 0xff)) & 0xff;
  tmp ^= (tmp << 4) & 0xff;
  return (((crc >> 8) ^ (tmp << 8) ^ (tmp << 3) ^ (tmp >> 4)) & 0xffff);
}

function buildMavlinkV2Frame(payload, msgId, crcExtra) {
  const len = payload.length;
  const incompatFlags = 0;
  const compatFlags = 0;
  const seq = mavSeq & 0xff;
  mavSeq = (mavSeq + 1) & 0xff;
  const sysId = 1;
  const compId = 1;

  const msgIdLow = msgId & 0xff;
  const msgIdMid = (msgId >> 8) & 0xff;
  const msgIdHigh = (msgId >> 16) & 0xff;

  const frameLen = 1 + 1 + 1 + 1 + 1 + 1 + 1 + 3 + len + 2;
  const frame = Buffer.alloc(frameLen);
  let o = 0;

  frame.writeUInt8(MAV_STX_V2, o++);
  frame.writeUInt8(len, o++);
  frame.writeUInt8(incompatFlags, o++);
  frame.writeUInt8(compatFlags, o++);
  frame.writeUInt8(seq, o++);
  frame.writeUInt8(sysId, o++);
  frame.writeUInt8(compId, o++);
  frame.writeUInt8(msgIdLow, o++);
  frame.writeUInt8(msgIdMid, o++);
  frame.writeUInt8(msgIdHigh, o++);

  payload.copy(frame, o);
  o += len;

  let crc = 0xffff;
  const headerBytes = [len, incompatFlags, compatFlags, seq, sysId, compId, msgIdLow, msgIdMid, msgIdHigh];
  for (const b of headerBytes) {
    crc = crcAccumulate(crc, b & 0xff);
  }
  for (let i = 0; i < len; i++) {
    crc = crcAccumulate(crc, payload[i] & 0xff);
  }
  crc = crcAccumulate(crc, crcExtra & 0xff);

  frame.writeUInt8(crc & 0xff, o++);
  frame.writeUInt8((crc >> 8) & 0xff, o++);

  return frame;
}

function buildComputeFrame() {
  const payloadObj = telemetry.createPayload();
  const cpuVal = Number(payloadObj.cpuUsage);
  const memVal = Number(payloadObj.memoryUsage);
  const internalTemp = String(payloadObj.temperature || '0C');
  const softwareVersion = String(payloadObj.softwareVersion || 'v1.0.0');

  const buf = Buffer.alloc(44, 0);
  let offset = 0;
  buf.writeUInt16LE(Math.max(0, Math.min(cpuVal, 100)), offset); offset += 2;
  buf.writeUInt16LE(Math.max(0, Math.min(memVal, 100)), offset); offset += 2;
  Buffer.from(internalTemp, 'ascii').copy(buf, offset, 0, 16); offset += 16;
  Buffer.from(softwareVersion, 'ascii').copy(buf, offset, 0, 24); offset += 24;

  return buildMavlinkV2Frame(buf, 1, 138);
}

function buildHvBmsFrame() {
  // Use the generated dialect's layout: all floats (4 bytes) then uint8s
  const buf = Buffer.alloc(29, 0);
  let offset = 0;
  buf.writeFloatLE(powerState.capacityAh * powerState.soc / 100, offset); offset += 4; // capacityRemaining
  buf.writeFloatLE(powerState.hvVoltage, offset); offset += 4; // packVoltage
  buf.writeFloatLE(powerState.hvCurrent, offset); offset += 4; // packCurrent
  buf.writeFloatLE(powerState.maxCell, offset); offset += 4; // maxCellVoltage
  buf.writeFloatLE(powerState.minCell, offset); offset += 4; // minCellVoltage
  buf.writeFloatLE(powerState.hvTemp, offset); offset += 4; // maxCellTemperature
  buf.writeUInt8(Math.round(powerState.soh), offset); offset += 1;
  buf.writeUInt8((powerState.hvFaultFlags & 1) ? 1 : 0, offset); offset += 1; // faultOverVoltage
  buf.writeUInt8((powerState.hvFaultFlags & 2) ? 1 : 0, offset); offset += 1; // faultUnderVoltage
  buf.writeUInt8((powerState.hvFaultFlags & 4) ? 1 : 0, offset); offset += 1; // faultOverTemperature
  buf.writeUInt8((powerState.hvFaultFlags & 8) ? 1 : 0, offset); offset += 1; // faultCellImbalance
  return buildMavlinkV2Frame(buf, 2, 187);
}

function buildHvPduFrame() {
  // Use the generated dialect's layout: all floats (4 bytes) then uint8s
  const buf = Buffer.alloc(11, 0);
  let offset = 0;
  buf.writeFloatLE(powerState.motorCurrent, offset); offset += 4;
  buf.writeFloatLE(powerState.dcBusVoltage, offset); offset += 4;
  buf.writeUInt8(powerState.hvMainContactor, offset); offset += 1;
  buf.writeUInt8(powerState.dcDcPercent, offset); offset += 1;
  buf.writeUInt8(powerState.auxPercent, offset); offset += 1;
  return buildMavlinkV2Frame(buf, 3, 19);
}

function buildLvBatteryFrame() {
  // Use the generated dialect's layout: all floats (4 bytes)
  const buf = Buffer.alloc(8, 0);
  let offset = 0;
  buf.writeFloatLE(powerState.lvVoltage, offset); offset += 4;
  buf.writeFloatLE(powerState.lvCurrent, offset); offset += 4;
  return buildMavlinkV2Frame(buf, 4, 121);
}

function buildLvPduFrame() {
  // Use the generated dialect's layout: all floats (4 bytes), then uint8, then float, then uint8
  const buf = Buffer.alloc(49, 0);
  let offset = 0;
  buf.writeFloatLE(powerState.lvInputVoltage, offset); offset += 4;
  buf.writeFloatLE(powerState.lvInputCurrent, offset); offset += 4;
  buf.writeFloatLE(powerState.lvInputPower, offset); offset += 4;
  buf.writeFloatLE(powerState.lvOutputCurrent, offset); offset += 4;
  buf.writeFloatLE(powerState.lvLoadPower, offset); offset += 4;
  buf.writeFloatLE(powerState.lvTemperature, 20); // temperature at offset 20
  offset = 24;
  for (let i = 0; i < 6; i++) {
    buf.writeFloatLE(powerState.lvChannelCurrents[i], offset); offset += 4;
  }
  buf.writeUInt8(powerState.lvCanStatus, 48); // canStatus at offset 48
  return buildMavlinkV2Frame(buf, 5, 218);
}

function start() {
  const server = dgram.createSocket('udp4');

  server.on('error', (err) => {
    console.error(`UDP server error:\n${err.stack}`);
    server.close();
    process.exit(1);
  });

  server.on('message', (msg, rinfo) => {
    if (msg && msg.length > 0) {
      const msgType = msg.readUInt8(0);
      if (msgType === 0) {
        const key = `${rinfo.address}:${rinfo.port}`;
        clients.set(key, { address: rinfo.address, port: rinfo.port, lastSeen: Date.now() });
      }
    }
  });

  server.on('listening', () => {
    const address = server.address();
    console.log(`UDP server is listening on ${address.address || '0.0.0.0'}:${address.port}`);
  });

  server.bind(PORT, '0.0.0.0');

  let lastSummaryLog = 0;
  const pushInterval = setInterval(() => {
    const now = Date.now();
    // Drop clients that haven't pinged OR been sent to recently.
    for (const [key, client] of clients.entries()) {
      const lastActivity = Math.max(client?.lastSeen || 0, client?.lastSent || 0);
      if (!lastActivity || (now - lastActivity) > 120000) {
        clients.delete(key);
      }
    }

    updatePowerState();
    const frames = [
      buildComputeFrame(),
      buildHvBmsFrame(),
      buildHvPduFrame(),
      buildLvBatteryFrame(),
      buildLvPduFrame()
    ];

    const packet = Buffer.concat(frames);

    if (clients.size === 0) return;

    if (now - lastSummaryLog > 5000) {
      lastSummaryLog = now;
      console.log(`Telemetry: pushing to ${clients.size} client(s)`);
    }

    for (const client of clients.values()) {
      server.send(packet, client.port, client.address, (err) => {
        if (!err) client.lastSent = now;
      });
    }
  }, 1000);

  process.on('SIGINT', () => {
    clearInterval(pushInterval);
    server.close();
    process.exit(0);
  });
}

module.exports = {
  start,
};