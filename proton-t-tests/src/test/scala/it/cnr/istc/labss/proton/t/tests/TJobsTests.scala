package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TJobsTests extends TModelSuite {

 def setup(ws: HeadlessWorkspace): Unit = {
    ws.cmd("""
      set total-citizens 1000
      set alpha 0.1
      setup
    """)
  }

  test("All propaganda and community centers staffed") { ws =>
    setup(ws)
    ws.rpt("""
      all? activities with [ 
        [ is-job? and (location-type = "community center"  or location-type = "propaganda place") ]  of my-activity-type 
      ] [ 
        any? activity-link-neighbors 
      ] 
      """) shouldBe true
  }

  test("Community workers preach to an effect") { ws =>
    setup(ws)
    for (fid <- 1 to 24 * 3 + 18) {
      ws.cmd(" go ")
      if (fid % 10 == 0) println(fid)    
    }
    ws.cmd("""
      ask n-of (count citizens / 20 * 
        count locations with [ shape = "community center" ]) 
        citizens with [
          [ shape ] of locations-here != [ "community center" ] 
        ] [
          move-to one-of locations with [ shape = "community center" ] 
        ]
    """)
    val meanInstDist = """
      mean [ value ] of link-set [
        out-topic-link-to ( one-of topics with [ topic-name = "Institutional distrust" ]) 
      ] of (citizens-on locations with [ shape = "community center"]) with [
        [ not (is-job? and location-type = "community center") ] of [ my-activity-type ] of current-activity 
      ]
    """
    val before = ws.rpt(meanInstDist).asInstanceOf[Number].floatValue    
    ws.cmd("""
      repeat 100 [ 
        ask citizens with [ 
          [ is-job? and location-type = "community center" ] of [ my-activity-type ] of current-activity 
        ] [ preach ]
        ]
      """)
    val after = ws.rpt(meanInstDist).asInstanceOf[Number].floatValue
    after - before < 0 shouldBe true
  }

  test("Radicalizers preach to an effect") { ws =>
    setup(ws) 
    for (fid <- 1 to 24 * 3 + 18) {
      ws.cmd(" go ")
      if (fid % 10 == 0) println(fid)    
    }
    ws.cmd("""
      ask n-of (count citizens / 5 / 
        count locations with [ shape = "propaganda place" ])
        citizens with [
          [ shape ] of locations-here != [ "propaganda place" ] 
        ] [
          move-to one-of locations with [ shape = "propaganda place" ] 
        ]    
    """)
    val meanInstDist = """
      mean [ value ] of link-set [
        out-topic-link-to ( one-of topics with [ topic-name = "Institutional distrust" ]) 
      ] of (citizens-on locations with [ shape = "propaganda place" ]) with [
        [ not (is-job? and location-type = "propaganda place") ] of [ my-activity-type ] of current-activity 
      ]
    """
    val before = ws.rpt(meanInstDist).asInstanceOf[Number].floatValue
    ws.cmd("""
      repeat 100 [ 
        ask citizens with [ 
          [ is-job? and location-type = "propaganda place" ] of [ my-activity-type ] of current-activity 
        ] [ preach ]
        ]
      """)
      val after = ws.rpt(meanInstDist).asInstanceOf[Number].floatValue
      after - before > 0 shouldBe true
  }

  test("citizens in workplace are working") { ws =>
    setup(ws)
    for (fid <- 1 to 400) {
      ws.cmd("go")
      ws.rpt("""
        count citizens with [ any? out-activity-link-neighbors with [ 
          [ is-mandatory? ] of my-activity-type and 
          [ current-activity] of myself = self] 
        ] -
        count citizens with  [ [ [is-mandatory? ] of my-activity-type ] of current-activity ]
      """) shouldBe 0 
      ws.rpt("""
        all? citizens with [ any? locations-here with [ shape = "workplace" ] ] [ 
          [ [ location-type ] of my-activity-type ] of current-activity = "workplace" ]
        """) shouldBe true  
      ws.rpt("""
        max [length [ shape ] of locations-here  ] of activities = 1
        """) shouldBe true    
      if (fid % 10 == 0) println(fid)    
    }
  }

  test("no homeless") { ws =>
    setup(ws)
    ws.cmd("go")
    ws.rpt("""
        any? citizens with [ not member? "residence" [ [ location-type ] of my-activity-type ] of activity-link-neighbors  ]
     """) shouldBe false
  }
}