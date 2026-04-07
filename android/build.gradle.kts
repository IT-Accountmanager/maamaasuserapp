buildscript {

//    ext.kotlin_version = '2.2.0'   // ✅ ADD THIS LINE

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.9.1")
        classpath("com.google.gms:google-services:4.4.4")
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.9")

        // ✅ ADD THIS LINE
//        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}


//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
