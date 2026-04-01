allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Apuntamos a la carpeta build dentro del proyecto Flutter
rootProject.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir("../build").get())

subprojects {
    project.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir(project.name).get())
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
