package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class SetupTests extends TModelSuite {

  test("Setup creates citizens") { ws =>
    // this basically just a dummy test...
    ws.cmd("setup")
    ws.rpt("any? citizens") shouldBe true
  }

}
