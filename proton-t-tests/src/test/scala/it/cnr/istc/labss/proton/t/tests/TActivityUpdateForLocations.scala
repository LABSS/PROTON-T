package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TActivityUpdateForLocations extends TModelSuite {

 def setup4x300(ws: HeadlessWorkspace): Unit = {
    ws.cmd("""
      set num-communities 4
      set citizens-per-community 300
      setup
    """)
  }

  test("good experiences improve the value of activities, and bad ones go the other way around") { ws =>
    setup4x300(ws)
    ws.cmd("""
      repeat 24 * 3 + 10 [ go ] ; 10AM on the third day
    """)
    var before = ws.rpt("sum [ value ] of activity-links").asInstanceOf[Number].floatValue    
    ws.cmd("""ask citizens with [ current-activity != nobody ] [ update-activity-value true self ]""")
    var after = ws.rpt("sum [ value ] of activity-links").asInstanceOf[Number].floatValue
    after - before > 0 shouldBe true
    ws.cmd("""
      repeat 24 * 3 [ go ] ; three more days
    """)
    before = ws.rpt("sum [ value ] of activity-links").asInstanceOf[Number].floatValue 
    ws.cmd("""ask citizens with [ current-activity != nobody ] [ update-activity-value false self ]""")
    after = ws.rpt("sum [ value ] of activity-links").asInstanceOf[Number].floatValue
    after - before < 0 shouldBe true
  }
}
