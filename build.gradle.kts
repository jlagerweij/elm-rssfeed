import com.moowork.gradle.node.NodeExtension
import com.moowork.gradle.node.npm.NpmTask
import com.moowork.gradle.node.task.NodeTask

plugins {
  id("com.moowork.node").version("1.3.1")
}

configure<NodeExtension> {
  version = "12.10.0"
  download = true
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
    from("build/web/static") {
      into("static")
    }
    from("src/static/convert-rss-to-json.php") {
      into("/")
    }
    from("build/web/index.html")
    into("build/dist")
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

