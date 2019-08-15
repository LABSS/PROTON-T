package it.cnr.istc.labss.proton.t.tests

import org.nlogo.headless.HeadlessWorkspace
import org.nlogo.core.LogoList
import org.nlogo.api.ScalaConversions.RichSeq

class TRiskAndPropensityTests extends TModelSuite {

 def setup4x300(ws: HeadlessWorkspace): Unit = {
    ws.cmd("""
      set total-citizens 3000
      setup
      ask one-of citizens with [ age < 25 and not employed? ] [
        table:put attributes "male?" true 
        table:put attributes "criminal-history?" true 
        table:put attributes "immigrant?" true
        table:put attributes "authoritarian?" true
      ]
      calculate-propensity      
    """)
  }

  test("Computation of risk and propensity as expected") { ws =>
    setup4x300(ws)
    val citizenkane:String = ws.rpt("""
      [ who ] of one-of citizens with [
        get "male?" and 
        not employed? and  
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
        set value 0.23 * 2
        ] 
      ]
      ask ck [ ask one-of my-out-topic-links with [
        [topic-name] of other-end = "Institutional distrust" ] [
        set value -0.87 * 2
        ]
      ]
      ask ck [ ask one-of my-out-topic-links with [
        [topic-name] of other-end = "Collective relative deprivation" ] [
        set value 0.99 * 2
        ]
      ] 
    """)
    println(ws.rpt("""
      [ risk ] of citizen """.concat(citizenkane))) 
    ws.rpt("""
      [ risk = 2.12994 ] of citizen """.concat(citizenkane)) shouldBe true  
  }
}

