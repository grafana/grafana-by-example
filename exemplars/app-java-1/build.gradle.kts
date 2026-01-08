plugins {
    id("java")
    id("org.springframework.boot") version "2.7.0"
    id("io.spring.dependency-management") version "1.1.7"
}

group = "org.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    testImplementation("org.junit.jupiter:junit-jupiter-api:5.8.2")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine:5.8.2")

    implementation("io.prometheus:prometheus-metrics-bom:1.3.5")
    implementation("io.prometheus:simpleclient")
    implementation("io.prometheus:simpleclient_httpserver")
    implementation("io.prometheus:prometheus-metrics-model:1.3.5")

    implementation("io.opentelemetry:opentelemetry-api:1.46.0")
    implementation("io.opentelemetry:opentelemetry-sdk:1.46.0")
}

tasks.getByName<Test>("test") {
    useJUnitPlatform()
}
