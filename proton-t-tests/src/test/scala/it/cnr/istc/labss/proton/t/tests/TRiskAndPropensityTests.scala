package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TRiskAndPropensityTests extends TModelSuite {

 def setup4x300(ws: HeadlessWorkspace): Unit = {
    ws.cmd("""
      set num-communities 4
      set citizens-per-community 300
      setup
    """)
  }

  test("Computation of risk and propensity as expected") { ws =>
    setup4x300(ws)
    val citizenkane:String = ws.rpt("""
      [ who ] of one-of citizens with [
        get "male?" and 
        employed? and  
        get "criminal-history?" and 
        get "immigrant?" and
        get "authoritarian?" and
        age <= 25
      ]
    """).toString
    println(ws.rpt("""
      [ propensity ] of citizen """.concat(citizenkane))) 
    ws.rpt("""
      [ propensity =  2.08 ] of citizen """.concat(citizenkane)) shouldBe true
    ws.cmd("""
      let ck citizen """ + citizenkane + """
      ask ck [ ask one-of my-out-topic-links with [
        [topic-name] of other-end = "Non integration" ] [
        set value 0.23
        ] 
      ]
      ask ck [ ask one-of my-out-topic-links with [
        [topic-name] of other-end = "Institutional distrust" ] [
        set value -0.87
        ]
      ]
      ask ck [ ask one-of my-out-topic-links with [
        [topic-name] of other-end = "Collective relative deprivation" ] [
        set value 0.99
        ]
      ] 
    """)
    println(ws.rpt("""
      [ risk ] of citizen """.concat(citizenkane))) 
    ws.rpt("""
      [ risk = 2.12994 ] of citizen """.concat(citizenkane)) shouldBe true  
  }
}
