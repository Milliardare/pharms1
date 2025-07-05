import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ Charger les propriétés depuis key.properties
val keyProperties = Properties()
val keyPropertiesFile: File = rootProject.projectDir.parentFile.resolve("key.properties")
println("🔍 DEBUG - keyPropertiesFile path: ${keyPropertiesFile.absolutePath}")
println("🔍 DEBUG - keyPropertiesFile exists? ${keyPropertiesFile.exists()}")


// val keyPropertiesFile = rootProject.parentFile.file("key.properties")

// val keyPropertiesFile = rootProject.file("android/key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
    println("✅ key.properties chargé")
} else {
    println("❌ key.properties NON trouvé")
}

android {
    namespace = "com.example.pharmacietest1"
    compileSdk = 35

    ndkVersion = "29.0.13599879"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.pharmacietest1"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keyProperties.getProperty("storeFile")
            println("🛠️ storeFile path: $storeFilePath")
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            } else {
                throw GradleException("storeFile is missing in key.properties")
            }

            keyAlias = keyProperties.getProperty("keyAlias") ?: ""
            keyPassword = keyProperties.getProperty("keyPassword") ?: ""
            storePassword = keyProperties.getProperty("storePassword") ?: ""
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.2"))
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
}

flutter {
    source = "../.."
}



// import java.util.Properties
// import java.io.FileInputStream

// plugins {
//     id("com.android.application")
//     id("kotlin-android")
//     id("com.google.gms.google-services")
//     id("dev.flutter.flutter-gradle-plugin")
// }

// val keyProperties = Properties().apply {
//     val keyPropertiesFile = rootProject.file("android/key.properties")
//     if (keyPropertiesFile.exists()) {
//         load(FileInputStream(keyPropertiesFile))
//     }
// }

// android {
//     namespace = "com.example.pharmacietest1"
//     compileSdk = 35  // Remplace par la version que tu souhaites

//     ndkVersion = "29.0.13599879"

//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_11
//         targetCompatibility = JavaVersion.VERSION_11
//     }

//     kotlinOptions {
//         jvmTarget = "11"
//     }

//     defaultConfig {
//         applicationId = "com.example.pharmacietest1"
//         minSdk = 21
//         targetSdk = 35
//         versionCode = 1
//         versionName = "1.0"
//     }

//     signingConfigs {
//         create("release") {
//             val storeFilePath = keyProperties.getProperty("storeFile")
//             println("🛠️ storeFile path: $storeFilePath")
//             if (storeFilePath != null) {
//                 storeFile = file(storeFilePath)
//             } else {
//                 throw GradleException("storeFile is missing in key.properties")
//             }
//             keyAlias = keyProperties.getProperty("keyAlias") ?: ""
//             keyPassword = keyProperties.getProperty("keyPassword") ?: ""
//             storePassword = keyProperties.getProperty("storePassword") ?: ""
//         }
//     }

//     buildTypes {
//         getByName("release") {
//             signingConfig = signingConfigs.getByName("release")
//             isMinifyEnabled = false
//             isShrinkResources = false
//         }
//     }
// }

// dependencies {
//     implementation(platform("com.google.firebase:firebase-bom:32.7.2"))
//     implementation("com.google.firebase:firebase-auth-ktx")
//     implementation("com.google.firebase:firebase-firestore-ktx")
// }

// flutter {
//     source = "../.."
// }



// import java.util.Properties
// import java.io.FileInputStream

// plugins {
//     id("com.android.application")
//     id("kotlin-android")
//     id("com.google.gms.google-services")
//     id("dev.flutter.flutter-gradle-plugin")
// }

// val keyProperties = Properties()
// val keyPropertiesFile = rootProject.file("android/key.properties")
// if (keyPropertiesFile.exists()) {
//     keyProperties.load(FileInputStream(keyPropertiesFile))
// }

// android {
//     namespace = "com.example.pharmacietest1"
//     compileSdk = 35  // Remplace par la version que tu souhaites

//     ndkVersion = "29.0.13599879"

//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_11
//         targetCompatibility = JavaVersion.VERSION_11
//     }

//     kotlinOptions {
//         jvmTarget = "11"
//     }

//     defaultConfig {
//         applicationId = "com.example.pharmacietest1"
//         minSdk = 21
//         targetSdk = 35
//         versionCode = 1
//         versionName = "1.0"
//     }

//     signingConfigs {
//         create("release") {
//         val storeFilePath = keyProperties.getProperty("storeFile")
//         println("🛠️ storeFile path: $storeFilePath")
//         if (storeFilePath != null) {
//             storeFile = file(storeFilePath)
//         } else {
//             throw GradleException("storeFile is missing in key.properties")
//         }
//         keyAlias = keyProperties.getProperty("keyAlias") ?: ""
//         keyPassword = keyProperties.getProperty("keyPassword") ?: ""
//         storePassword = keyProperties.getProperty("storePassword") ?: ""
//     }
// }
//         //  create("release") {
//         // keyAlias = keyProperties.getProperty("keyAlias") ?: ""
//         // keyPassword = keyProperties.getProperty("keyPassword") ?: ""
//         // val storeFilePath = keyProperties.getProperty("storeFile")
//         // if (storeFilePath != null) {
//         //     storeFile = file(storeFilePath)
//         // }
//         // storePassword = keyProperties.getProperty("storePassword") ?: ""
//         // }
//         // create("release") {
//         //     keyAlias = keyProperties["keyAlias"] as String?
//         //     keyPassword = keyProperties["keyPassword"] as String?
//         //     storeFile = file(keyProperties["storeFile"] as String)
//         //     storePassword = keyProperties["storePassword"] as String?
//         // }
//     }

//     buildTypes {
//         getByName("release") {
//             signingConfig = signingConfigs.getByName("release")
//             isMinifyEnabled = false
//             isShrinkResources = false
//         }
//     }
// }

// dependencies {
//     implementation(platform("com.google.firebase:firebase-bom:32.7.2"))
//     implementation("com.google.firebase:firebase-auth-ktx")
//     implementation("com.google.firebase:firebase-firestore-ktx")
// }

// flutter {
//     source = "../.."
// }



// import java.util.Properties
// import java.io.FileInputStream

// plugins {
//     id("com.android.application")
//     id("kotlin-android")
//     id("com.google.gms.google-services")
//     // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
//     id("dev.flutter.flutter-gradle-plugin")
    

// }


// val keyProperties = Properties()
// val keyPropertiesFile = rootProject.file("android/key.properties")
// if (keyPropertiesFile.exists()) {
//     keyProperties.load(FileInputStream(keyPropertiesFile))
// }

// android {
//     namespace = "com.example.pharmacietest1"
//     compileSdk = flutter.compileSdkVersion
//     ndkVersion = "29.0.13599879"

//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_11
//         targetCompatibility = JavaVersion.VERSION_11
//     }

//     kotlinOptions {
//         jvmTarget = JavaVersion.VERSION_11.toString()
//     }

//     defaultConfig {
//         // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//         applicationId = "com.example.pharmacietest1"
//         // You can update the following values to match your application needs.
//         // For more information, see: https://flutter.dev/to/review-gradle-config.
//         minSdk = flutter.minSdkVersion
//         targetSdk = flutter.targetSdkVersion
//         versionCode = flutter.versionCode
//         versionName = flutter.versionName
//     }
//     signingConfigs {
//     create("release") {
//         keyAlias = keyProperties["keyAlias"] as String?
//         keyPassword = keyProperties["keyPassword"] as String?
//         storeFile = file(keyProperties["storeFile"] as String)
//         storePassword = keyProperties["storePassword"] as String?
//     }
// }
  

//     buildTypes {
//             getByName("release") {
//         signingConfig = signingConfigs.getByName("release")
//         isMinifyEnabled = false
//         isShrinkResources = false
//     }

//     }
//         // release {
//         //     // TODO: Add your own signing config for the release build.
//         //     // Signing with the debug keys for now, so `flutter run --release` works.
//         //     signingConfig = signingConfigs.getByName("debug")
//         // }
//     }
// }
// dependencies {
//     implementation(platform("com.google.firebase:firebase-bom:32.7.2"))

//     // Ajoute ici d'autres dépendances Firebase si tu veux, par exemple :
//     implementation("com.google.firebase:firebase-auth-ktx")
//     implementation("com.google.firebase:firebase-firestore-ktx")
// }


// flutter {
//     source = "../.."
// }
// apply(plugin = "com.google.gms.google-services")

