import com.avast.gradle.dockercompose.ComposeExtension
import com.bmuschko.gradle.docker.tasks.image.DockerBuildImage
import com.moowork.gradle.node.NodeExtension
import com.moowork.gradle.node.npm.NpmTask
import com.moowork.gradle.node.task.NodeTask

plugins {
  id("com.moowork.node").version("1.3.1")
  id("com.bmuschko.docker-remote-api").version("5.2.0")
  id("com.avast.gradle.docker-compose").version("0.9.5")
}

configure<NodeExtension> {
  version = "12.13.0"
  download = true
}

configure<ComposeExtension> {
  projectName = "elm-rssfeed"
  useComposeFiles = listOf("docker/docker-compose.yaml")
}

tasks {
  register<NodeTask>("localDev") {
    dependsOn("npmInstall")
    group = "development"
    description = "Start local development server on port 8080."
    setScript(file("node_modules/webpack-dev-server/bin/webpack-dev-server"))
    setArgs(listOf("--hot"))
  }

  register<Copy>("assemble") {
    dependsOn("webpack")
    description = "Assembles the outputs of this project."
    group = "build"
    from("build/webpack") {
      into("web")
    }
    from("src/static/api/feeds.json") {
      into("web/api/")
    }
    from("docker/elm-rssfeed")
    into("${buildDir}/dist")
  }

  register<Copy>("assembleConvertRssToJson") {
    from("docker/convert-rss-to-json") {
      into("/")
    }
    from("src/php/convert-rss-to-json.php") {
      into("/")
    }
    into("${buildDir}/convert-rss-to-json")
  }

  register<DockerBuildImage>("buildConvertRssToJson") {
    dependsOn("assembleConvertRssToJson")
    inputDir.set(file("${buildDir}/convert-rss-to-json"))
    tags.add("elm-rssfeed-convert-rss-to-json:latest")
  }

  register<DockerBuildImage>("buildElmRssFeed") {
    dependsOn("assemble")
    inputDir.set(file("${buildDir}/dist"))
    tags.add("elm-rssfeed:latest")
  }

  register("build") {
    group = "build"
    dependsOn("buildConvertRssToJson", "buildElmRssFeed")
  }

  register("clean") {
    group = "build"
    description = "Deletes the build, node_modules and elm-stuff directories."
    doLast {
      delete("node_modules")
      delete("elm-stuff")
      delete("build")
    }
  }

  register<NpmTask>("webpack") {
    dependsOn("npmInstall")
    description = "Assembles this project."
    group = "build"
    inputs.dir("src")
    inputs.file("elm.json")
    inputs.file("webpack.config.js")
    outputs.dir("${buildDir}/webpack")
    setNpmCommand("run-script", "prod")
  }

  register("publish") {
    dependsOn("assemble")
    description = "Publish output of this project to a server."
    group = "build"
    doLast {
      exec {
        println("Publish static")
        description = "Publish static"
        commandLine = "scp -r build/dist/static ernie:/volume1/web/j/rss/elm/".split(" ")
      }
      exec {
        println("Publish HTML")
        description = "Publish HTML"
        commandLine = "scp -r build/dist/index.html ernie:/volume1/web/j/rss/elm/".split(" ")
      }
      exec {
        println("Publish Convert script")
        description = "Publish Convert script"
        commandLine = "scp -r build/dist/convert-rss-to-json.php ernie:/volume1/web/j/rss/elm/".split(" ")
      }
    }
  }
}

