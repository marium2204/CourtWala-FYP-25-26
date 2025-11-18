plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ fixed from Groovy to Kotlin DSL
}

android {
    namespace = "com.example.temp_flutter_project"
    compileSdk = 36 // or flutter.compileSdkVersion if using FlutterPlugin convention

    defaultConfig {
        applicationId = "com.example.temp_flutter_project"
        minSdk = flutter.minSdkVersion // or flutter.minSdkVersion
        targetSdk = 34 // or flutter.targetSdkVersion
        versionCode = 1 // or flutter.versionCode
        versionName = "1.0" // or flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.." // keep Flutter source directory
}
