package id.go.pdam.salims.apps

import android.content.Context
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.salims_apps/mock_location"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isMockLocation") {
                val isMock = isMockLocationEnabled()
                result.success(isMock)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isMockLocationEnabled(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Android 6.0 (API 23) and above
            // Note: ALLOW_MOCK_LOCATION was deprecated in API 23
            // For API 23+, we check if app is in mock location mode
            try {
                Settings.Secure.getInt(
                    applicationContext.contentResolver,
                    Settings.Secure.ALLOW_MOCK_LOCATION,
                    0
                ) != 0
            } catch (e: Exception) {
                // If we can't check, assume false (no mock location)
                false
            }
        } else {
            // Below Android 6.0
            try {
                Settings.Secure.getString(
                    applicationContext.contentResolver,
                    Settings.Secure.ALLOW_MOCK_LOCATION
                ) != "0"
            } catch (e: Exception) {
                false
            }
        }
    }
}
