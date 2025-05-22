plugins {
    id("com.android.application")
    id("kotlin-android")
    // Plugin Flutter harus di-apply paling bawah
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dicoding_story"
    compileSdk = flutter.compileSdkVersion

    // Tetapkan versi NDK di sini
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.dicoding_story"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        // Gunakan Java 1.8 atau lebih tinggi
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

flutter {
    source = "../.."
}

// dependencies tetap didefinisikan di luar block android
dependencies {
    implementation("com.google.android.gms:play-services-maps:18.1.0")
    implementation("com.google.android.gms:play-services-location:21.0.1")
    // ... plugin lain
}
