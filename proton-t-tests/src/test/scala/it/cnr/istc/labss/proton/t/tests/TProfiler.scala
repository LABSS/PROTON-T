package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TProfiler extends TModelSuite {

  test("Running the GO profiler") { ws =>
    ws.cmd("""
      profile-go
      """
    )
	}
	test("Running the SETUP profiler") { ws =>
    ws.cmd("""
      profile-setup
      """
    )
  }
}
