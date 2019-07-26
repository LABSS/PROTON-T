package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TJobsTest extends TModelSuite {

 def setup(ws: HeadlessWorkspace): Unit = {
    ws.cmd("""
      set total-citizens 2000
      set alpha 0.1
      setup
    """)
  }

  test("no homeless") { ws =>
    setup(ws)
    ws.cmd("go")
    ws.rpt("""
        any? citizens with [ not member? "residence" [ [ location-type ] of my-activity-type ] of activity-link-neighbors  ]
     """) shouldBe false
  }

 test("citizens in workplace are working") { ws =>
    setup(ws)
    for (fid <- 1 to 600) {
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

}