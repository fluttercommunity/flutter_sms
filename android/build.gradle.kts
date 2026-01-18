plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android") version "2.1.0"
}

group = "com.example.flutter_sms"
version = "1.0-SNAPSHOT"

android {
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    defaultConfig {
        minSdk = flutter.minSdkVersion
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")

    lint {
        disable.add("InvalidPackage")
    }
}

repositories {
    google()
    mavenCentral() // jcenter is deprecated; use mavenCentral
}

dependencies {
    implementation("androidx.core:core-ktx:1.16.0")
   }
