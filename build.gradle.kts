import com.moowork.gradle.node.npm.NpmTask
import com.moowork.gradle.node.task.NodeTask
import com.moowork.gradle.node.NodeExtension

plugins {
  id("com.moowork.node").version("1.3.1")
}

configure<NodeExtension> {
  version = "10.16.3"
  download = true
}

tasks {
  create<NpmTask>("webpack") {
    dependsOn("npmInstall")
    setArgs(listOf("run", "prod"))
  }
  create<NodeTask>("webpackDevServer") {
    dependsOn("npmInstall")
    setScript(file("node_modules/webpack-dev-server/bin/webpack-dev-server"))
    setArgs(listOf("--hot"))
  }
  create<Copy>("dist") {
    dependsOn("webpack")
    from("build/web/static") {
      into("static")
    }
    from("src/static/convert-rss-to-json.php") {
      into("/")
    }
    from("build/web/index.html")
    into("build/dist")
  }
  create("clean") {
    doLast {
      delete("node_modules")
      delete("elm-stuff")
      delete("build")
    }
  }
  create("build") {
    dependsOn("webpack")
  }
  create<Exec>("deployStatic") {
    dependsOn("dist")
    commandLine = "scp -r build/dist/static ernie:/volume1/web/j/rss/elm/".split(" ")
  }
  create<Exec>("deployHtml") {
    dependsOn("dist")
    commandLine = "scp -r build/dist/index.html ernie:/volume1/web/j/rss/elm/".split(" ")
  }
  create<Exec>("deployConvertScript") {
    dependsOn("dist")
    commandLine = "scp -r build/dist/convert-rss-to-json.php ernie:/volume1/web/j/rss/elm/".split(" ")
  }
  create("deploy") {
    dependsOn(listOf("deployStatic", "deployHtml", "deployConvertScript"))
  }
}

