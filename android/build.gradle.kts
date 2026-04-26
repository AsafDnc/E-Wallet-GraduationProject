import com.android.build.gradle.LibraryExtension

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

// AGP 8+: plugins must declare `namespace`. Legacy packages (e.g. isar_flutter_libs)
// omit it; derive from Gradle `group` (matches their AndroidManifest package).
subprojects {
    afterEvaluate {
        if (!project.plugins.hasPlugin("com.android.library")) {
            return@afterEvaluate
        }
        project.extensions.findByType(LibraryExtension::class.java)?.apply {
            val current = namespace
            if (current.isNullOrEmpty()) {
                val fromGroup = project.group?.toString().orEmpty()
                namespace =
                    fromGroup.ifEmpty { "com.flutter.${project.name.replace('-', '_')}" }
            }
        }
    }
}

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
