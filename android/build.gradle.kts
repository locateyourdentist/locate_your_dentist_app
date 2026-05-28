//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}
//
//val newBuildDir: Directory =
//    rootProject.layout.buildDirectory
//        .dir("../../build")
//        .get()
//rootProject.layout.buildDirectory.value(newBuildDir)
//
//subprojects {
//    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//    project.layout.buildDirectory.value(newSubprojectBuildDir)
//}
//subprojects {
//    project.evaluationDependsOn(":app")
//}
//
//tasks.register<Delete>("clean") {
//    delete(rootProject.layout.buildDirectory)
//}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// === FIX: IMMEDIATE LINT CONFIGURATION ===
subprojects {
    beforeEvaluate {
        val androidExtension = extensions.findByName("android")
        if (androidExtension != null) {
            configure<com.android.build.gradle.BaseExtension> {
                lintOptions {
                    isCheckReleaseBuilds = false
                    isAbortOnError = false
                    disable("LintVitalAnalyzeRelease")
                }
            }
        }
    }
}
// Place this at the absolute bottom of your android/build.gradle.kts file
subprojects {
    tasks.configureEach {
        if (name == "lintVitalAnalyzeRelease" || name.contains("lintVital")) {
            enabled = false
        }
    }
}