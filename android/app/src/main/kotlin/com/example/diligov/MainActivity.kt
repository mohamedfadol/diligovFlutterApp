package com.diligov.doc
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    override fun onDestroy() {
        super.onDestroy()
        // Notify Flutter code that the app is being terminated
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "app_lifecycle").invokeMethod("onTerminate", null)
    }
}
