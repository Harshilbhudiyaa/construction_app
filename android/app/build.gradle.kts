plugins {
    id("com.android.application")
<<<<<<< Updated upstream
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
=======

    // Firebase (Google Services)
    id("com.google.gms.google-services")

    // Kotlin (recommended id for Kotlin DSL projects)
    id("org.jetbrains.kotlin.android")

    // Flutter Gradle Plugin must be last
>>>>>>> Stashed changes
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.construction_app"
    compileSdk = flutter.compileSdkVersion.toInt()
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.construction_app"
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
