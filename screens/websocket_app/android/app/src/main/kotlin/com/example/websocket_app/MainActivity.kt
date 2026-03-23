package com.example.websocket_app

import android.graphics.Rect
import android.os.Build
import android.view.View
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onPostResume() {
		super.onPostResume()
		applySystemGestureExclusion()
	}

	override fun onWindowFocusChanged(hasFocus: Boolean) {
		super.onWindowFocusChanged(hasFocus)
		if (hasFocus) {
			applySystemGestureExclusion()
		}
	}

	private fun applySystemGestureExclusion() {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return

		val density = resources.displayMetrics.density
		val excludeWidthPx = (260f * density).toInt()

		val targetView: View = findViewById(android.R.id.content) ?: window.decorView

		targetView.post {
			val height = targetView.height
			if (height <= 0) return@post
			val rect = Rect(0, 0, excludeWidthPx, height)
			targetView.systemGestureExclusionRects = listOf(rect)
		}
	}
}
