package com.luis.signo_peru_app

import android.os.Bundle
import androidx.core.animation.doOnEnd
import android.view.View
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    // 1) Instala la SplashScreen del sistema
    val splashScreen = installSplashScreen()
    
    WindowCompat.setDecorFitsSystemWindows(window, false)

    // 2) Configura el decorView para layout FULLSCREEN / STABLE
    window.decorView.systemUiVisibility = (
        View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
    )
    // 2) Anima la vista de splash para que haga un fade‐out al terminar el dibujo
    splashScreen.setOnExitAnimationListener { splashScreenView ->
      // splashScreenView.view es el View que contiene tu fondo + logo
      val view = splashScreenView.view
      // asegúrate de que empiece opaco
      view.alpha = 1f

      view.animate()
        .alpha(0f)               // 1f → 0f en opacidad
        .setDuration(600L)       // duración 600 ms
        .withEndAction {
          // cuando termine, quitar la splash
          splashScreenView.remove()
        }
        .start()
    }

    super.onCreate(savedInstanceState)
  }
}