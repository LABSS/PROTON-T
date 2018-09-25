lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "it.cnr.istc.labss",
      scalaVersion := "2.12.4"
    )),
    name := "proton-t-tests"
  )

resolvers += Resolver.bintrayRepo("netlogo", "NetLogo-JVM")

libraryDependencies ++= Seq(
  "org.scalatest" %% "scalatest" % "3.0.5" % Test,
  "org.nlogo" % "netlogo" % "6.0.4" % Test
)

lazy val downloadFromZip = taskKey[Unit]("Download zipped extensions and extract them to ./extensions")

downloadFromZip := {
  // This will download extensions only if the `extensions` directory
  // does not exist. If you need to add a new extension, remove
  // the `extensions` directory to cause sbt to re-download everything
  if (java.nio.file.Files.notExists(new File("extensions").toPath())) {
    println("Downloading extensions...")
    val baseURL = "https://raw.githubusercontent.com/NetLogo/NetLogo-Libraries/6.0/extensions/"
    val extensions = List(
      "table" -> "table-1.3.0.zip",
      "profiler" -> "profiler-1.1.0.zip",
      "rnd" -> "rnd-3.0.0.zip"
    )
    for ((extension, file) <- extensions) {
      println("Downloading " + baseURL + file)
      IO.unzipURL(new URL(baseURL + file), new File("extensions/" + extension))
    }
  }
}

compile in Test := (compile in Test).dependsOn(downloadFromZip).value

fork in Test := true

javaOptions in test += "-Xms512M -Xmx3000M -Xss1M -XX:+UseConcMarkSweepGC -XX:NewRatio=8"
