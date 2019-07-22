#/bin/bash
runplan="rp0.6"
echo $runplan
population=3000
echo $population
# high risk
awk '/<enumeratedValueSet variable=\"high-risk-employed\">/,/ <\/enumeratedValueSet>/ {sub(/<value value=\"&quot;no intervention&quot;\"\/>/,"<value value=\"50\"\/>\n        <value value=\"100\"\/>")}1' base_$runplan.xml > $runplan-high_risks.xml
awk '/<enumeratedValueSet variable=\"population-emp">/,/ <\/enumeratedValueSet>/ {sub(/<value value=\"10\"\/>/,"<value value=\"5\"\/>\n        <value value=\"10\"\/>\n        <value value=\"20\"\/>\n        <value value=\"40\"\/>")}1' $runplan-high_risks.xml > $runplan_high_risks.xml


#awk '/<enumeratedValueSet variable=\"total-citizens\">/,/ <\/enumeratedValueSet>/ {sub(/<value value=\"5000\"\/>/,"<value value=\"$population\"\/>")}1' base_$runplan.xml > $runplan-sensitivity.xml
awk '/<enumeratedValueSet variable=\"alpha\">/,/ <\/enumeratedValueSet>/ {sub(/<value value=\"1\"\/>/,"<value value=\"0\"\/>\n        <value value=\"1\"\/>")}1' $runplan-sensitivity.xml > $runplan-sensitivity.xml
awk '/<enumeratedValueSet variable=\"population-employed-%\">/,/ <\/enumeratedValueSet>/ {sub(/<value value=\"1\"\/>/,"<value value=\"5\"\/>\n        <value value=\"10\"\/>\n        <value value=\"20\"\/>\n        <value value=\"40\"\/>")}1' $runplan-sensitivity.xml > $runplan-sensitivity.xml
awk '/<enumeratedValueSet variable=\"activity-radius\">/,/ <\/enumeratedValueSet>/ {sub(/<value value=\"10\"\/>/,"<value value=\"5\"\/>\n        <value value=\"10\"\/>")}1' $runplan-sensitivity.xml > $runplan-sensitivity.xml


#awk '/<enumeratedValueSet variable=\"education-rate\">/,/ <\/enumeratedValueSet>/ {sub(/value=\"1\"/,"value=\"1\.5\"")}1' exp-OC-highEduEco2.xml > exp-OC-highEduEco.xml
#rm exp-OC-highEduEco2.xml
#awk '/<enumeratedValueSet variable=\"employment-rate\">/,/ <\/enumeratedValueSet>/ {sub(/value=\"1\"/,"value=\"0\.5\"")}1' exp-OC-baseEduEco.xml > exp-OC-lowEduEco2.xml
#awk '/<enumeratedValueSet variable=\"education-rate\">/,/ <\/enumeratedValueSet>/ {sub(/value=\"1\"/,"value=\"0\.5\"")}1' exp-OC-lowEduEco2.xml > exp-OC-lowEduEco.xml
#rm exp-OC-lowEduEco2.xml


#gender: 45 - 50 - 55
#employment: 5 - *10.30* - 20 - 40

#        <value value="50"/>
#        <value value="100"/>