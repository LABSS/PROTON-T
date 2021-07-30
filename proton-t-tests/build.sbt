lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "it.cnr.istc.labss",
      scalaVersion := "2.12.4"
    )),
    name := "proton-t-tests"
  )

// https://github.com/NetLogo/NetLogo/issues/1915
resolvers +=
  "NetLogoJVM" at "https://dl.bintray.com/netlogo/NetLogo-JVM/"

libraryDependencies ++= Seq(
  "org.scalatest" %% "scalatest" % "3.0.5" % Test,
  "org.nlogo" % "netlogo" % "6.1.1" % Test
)

lazy val downloadFromZip = taskKey[Unit]("Download zipped extensions and extract them to ./extensions")

downloadFromZip := {
  val baseURL = "https://github.com/NetLogo/NetLogo-Libraries/raw/6.1/extensions/"
  val extensions = List(
    "csv" -> "csv-1.1.1.zip",
    "profiler" -> "profiler-1.1.1.zip",
    "rnd" -> "rnd-3.0.1.zip",
    "table" -> "table-1.3.1.zip",    
    "vid" -> "vid-1.0.1.zip"    
  )
  for {
    (extension, file) <- extensions
    path = new File("extensions/" + extension)
    if java.nio.file.Files.notExists(path.toPath)
    url = new URL(baseURL + file)
  } {
    println("Downloading " + url)
    IO.unzipURL(url, path)
  }
}

Test / compile := (Test /compile dependsOn downloadFromZip).value

Test / fork  := true

test / javaOptions += "-Xms512M -Xmx3000M -Xss1M -XX:+UseConcMarkSweepGC -XX:NewRatio=8"
