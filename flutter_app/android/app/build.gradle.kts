import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "in.ponsrischool.nmms"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "in.ponsrischool.nmms"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val envPath = System.getenv("KEYSTORE_PATH")
            val possibleFiles = listOfNotNull(
                envPath?.let { File(it) },
                File(rootDir, "../../android-keystore/release.jks"),
                File(rootDir, "../android-keystore/release.jks"),
                File(rootDir, "android-keystore/release.jks"),
                File("/Users/sandipkumarpatel/Documents/Quiz/android-keystore/release.jks")
            )
            val keystoreFile = possibleFiles.firstOrNull { it.exists() }
            if (keystoreFile != null) {
                storeFile = keystoreFile
                storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "Ponsri@2026Secure"
                keyAlias = System.getenv("KEY_ALIAS") ?: "ponsri-release"
                keyPassword = System.getenv("KEY_PASSWORD") ?: "Ponsri@2026Secure"
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            signingConfig = if (releaseConfig.storeFile?.exists() == true) {
                releaseConfig
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
