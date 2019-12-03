import com.palantir.gradle.graal.NativeImageTask
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.jetbrains.kotlin.javac.resolve.classId
import org.springframework.boot.gradle.tasks.bundling.BootJar

plugins {
  id("org.springframework.boot") version "2.2.1.RELEASE"
  id("io.spring.dependency-management") version "1.0.8.RELEASE"
  id("com.palantir.graal") version "0.6.0-33-gb052835"
  kotlin("jvm") version "1.3.61"
  kotlin("plugin.spring") version "1.3.61"
  kotlin("kapt") version "1.3.61"
}

group = "net.lagerwey.rssfeed"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

val developmentOnly by configurations.creating
configurations {
  runtimeClasspath {
    extendsFrom(developmentOnly)
  }
}

repositories {
  mavenCentral()
}

dependencies {
  implementation("org.springframework.boot:spring-boot-starter")
  implementation("org.springframework:spring-web")
  implementation("org.jetbrains.kotlin:kotlin-reflect")
  implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
  implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
  developmentOnly(files("lib"))
  developmentOnly("org.springframework.boot:spring-boot-devtools")
  testImplementation("org.springframework.boot:spring-boot-starter-test") {
    exclude(group = "org.junit.vintage", module = "junit-vintage-engine")
  }

  kapt("org.springframework.boot:spring-boot-configuration-processor")
}

tasks.withType<Test> {
  useJUnitPlatform()
}

tasks.withType<KotlinCompile> {
  kotlinOptions {
    freeCompilerArgs = listOf("-Xjsr305=strict")
    jvmTarget = "1.8"
  }
}

tasks.withType<Jar> {
  enabled = true
}
tasks.withType<BootJar> {
  classifier = "all"
  mainClassName = "net.lagerwey.rssfeed.rsstojsonconverter.RssToJsonConverterApplicationKt"
}

graal {
  mainClass("net.lagerwey.rssfeed.rsstojsonconverter.RssToJsonConverterApplicationKt")
  outputName("rss-to-json-converter")
//  graalVersion("19.2.1")
  option("-H:+TraceClassInitialization")
  option("-H:+ReportExceptionStackTraces")
  option("--report-unsupported-elements-at-runtime")
  option("--enable-http")
  option("--static")
}

tasks.withType<NativeImageTask> {
  dependsOn("build")
}