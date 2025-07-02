plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.demo_conut"
    // 设置编译SDK版本为35，以满足您项目中其他插件的要求
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    // Java版本配置，保持1.8
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.example.demo_conut"
        minSdk = 21
        targetSdk = 35 // 与 compileSdk 保持一致
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 在您真正需要打包发布时，再来配置签名
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    /*implementation("com.amap.api:location:5.2.0")
    implementation("com.amap.api:3dmap:8.1.0")
    implementation("com.amap.api:search:5.0.0")*/

    // ✅ 核心修正：
    // 将之前找不到的 $kotlin_version 变量，
    // 直接替换为与 Flutter 3.10.6 兼容的 Kotlin 版本号 "1.8.22"
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.22")
}
