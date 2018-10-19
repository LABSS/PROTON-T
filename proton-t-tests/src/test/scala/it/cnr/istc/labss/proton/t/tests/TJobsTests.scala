package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TJobsTests extends TModelSuite {

 def setup4x100(ws: HeadlessWorkspace): Unit = {
    ws.cmd("""
      set num-communities 4
      set citizens-per-community 100
      setup
    """)
  }

  test("All mosques and community centers staffed") { ws =>
    setup4x100(ws)
    ws.rpt("""
      all? activities with [ 
        [ is-job? and (location-type = "community center"  or location-type = "mosque") ]  of my-activity-type 
      ] [ 
        any? activity-link-neighbors 
      ] 
      """) shouldBe true
  }
}
