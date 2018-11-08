package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TJobsTests extends TModelSuite {

 def setup4x300(ws: HeadlessWorkspace): Unit = {
    ws.cmd("""
      set num-communities 4
      set citizens-per-community 300
      setup
    """)
  }

  test("All mosques and community centers staffed") { ws =>
    setup4x300(ws)
    ws.rpt("""
      all? activities with [ 
        [ is-job? and (location-type = "community center"  or location-type = "mosque") ]  of my-activity-type 
      ] [ 
        any? activity-link-neighbors 
      ] 
      """) shouldBe true
  }

  test("Community workers preach to an effect") { ws =>
    setup4x300(ws)
    ws.cmd("""
      repeat 24 * 10 + 10 [ go ] ; 10AM on the tenth day
    """)
    val meanFundamentalism = """
      mean [ value ] of link-set [
        out-topic-link-to ( one-of topics with [ topic-name = "Fundamentalism" ]) 
      ] of (citizens-on locations with [ shape = "community center"]) with [
        [ not (is-job? and location-type = "community center") ] of [ my-activity-type ] of current-activity 
      ]
    """
    val before = ws.rpt(meanFundamentalism).asInstanceOf[Number].floatValue    
    ws.cmd("""
      repeat 100 [ 
        ask citizens with [ 
          [ is-job? and location-type = "community center" ] of [ my-activity-type ] of current-activity 
        ] [ preach ]]
      """)
    val after = ws.rpt(meanFundamentalism).asInstanceOf[Number].floatValue
    after - before < 0 shouldBe true
  }

  test("The activity system should be coherent") { ws =>
    setup4x300(ws)
    1 to 500 foreach { _ => 
      ws.cmd("go")
      ws.rpt("""
        count activities with [  
            [is-mandatory?] of my-activity-type and any? citizens with [ current-activity = myself ]
          ] - count citizens with  [ [ [is-mandatory? ] of my-activity-type ] of current-activity ]
      """) shouldBe 0 
    }
  }
}

// 

//show count activities with [[is-mandatory?] of my-activity-type and count citizens with [ current-activity = myself ] > 1]
/*
Why there are 20 people using the same sleep activity?

observer> show count citizens with  [ [ [is-mandatory?] of my-activity-type ] of current-activity ]
observer: 400
observer> show count activities with [[is-mandatory?] of my-activity-type and any? citizens with [ current-activity = myself ]]
observer: 380
observer> show count activities with [[is-mandatory?] of my-activity-type and count citizens with [ current-activity = myself ] > 1]
observer: 20

*/