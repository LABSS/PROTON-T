package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TOpinionDynamicsTest extends TModelSuite {

 def setup(ws: HeadlessWorkspace): Unit = {
    ws.cmd("""
      set total-citizens 2000
      setup
    """)
  }

  test("Effects of talk-to as expected") { ws =>
    setup(ws)
    val talker:String =   ws.rpt("[ who ] of one-of citizens").toString
    val listener:String = ws.rpt("[ who ] of one-of citizens with [ who != " + talker + " ]").toString  
     val v2:Double = ws.rpt("""
       [ opinion-on-topic "Institutional distrust" ] of citizen """ + listener ).toString.toDouble
    println(v2)
     val diff:Double = ws.rpt("""
       [ opinion-on-topic "Institutional distrust" ] of citizen """ + talker + """ -
       [ opinion-on-topic "Institutional distrust" ] of citizen """ + listener  ).toString.toDouble
    val alpha:Double = ws.rpt("alpha").toString.toDouble
    ws.cmd("ask citizen " + talker + " [ show talk-to-tuned turtle-set citizen " + listener + """ topic-by-name "Institutional distrust" 1 ] """)  
    (ws.rpt("""
      [ opinion-on-topic "Institutional distrust" ] of citizen """ + listener ).toString.toDouble == 
    (if (Math.abs(diff) < 2 - alpha * Math.abs(v2)) v2 + (2 - alpha * Math.abs(v2)) * diff / 2 else  v2 )) shouldBe true
  }
}

