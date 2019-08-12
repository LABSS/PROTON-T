package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TPreachingTests extends TModelSuite {

 def setup(ws: HeadlessWorkspace): Unit = {
    ws.cmd("""
      set total-citizens 1000
      set alpha 1
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
    for (fid <- 1 to 17 * 3 + 10) {
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
    for (fid <- 1 to 17 * 3 + 10) {
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
}