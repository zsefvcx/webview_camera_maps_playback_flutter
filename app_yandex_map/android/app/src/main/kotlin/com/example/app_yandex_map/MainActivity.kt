package com.example.app_yandex_map

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.yandex.mapkit.MapKitFactory;

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        //MapKitFactory.setLocale("RU_ru") // Your preferred language. Not required, defaults to system language
        MapKitFactory.setApiKey("47b9b9d4-ef54-40a4-913c-9c3edcf9b11a") // Your generated API key
        super.configureFlutterEngine(flutterEngine)
    }
}
