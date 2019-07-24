import xml.etree.ElementTree as ET

#pretty print method
def indent(elem, level=0):
    i = "\n" + level*"  "
    j = "\n" + (level-1)*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for subelem in elem:
            indent(subelem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = j
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = j
    return elem
	
tree = ET.parse('base_rp0.6.xml')
root = tree.getroot()

# first, sentitivity analysis.

al = tree.find('.//enumeratedValueSet[@variable="activity-radius"]')
al.insert(1, ET.Element("value", value="5"))

al = tree.find('.//enumeratedValueSet[@variable="alpha"]')
al.insert(1, ET.Element("value", value="0.0"))

al = tree.find('.//enumeratedValueSet[@variable="recruit-hours-threshold"]')
al.insert(1, ET.Element("value", value="50"))

al = tree.find('.//enumeratedValueSet[@variable="population-employed-%"]')
al.insert(1, ET.Element("value", value="5"))
al.insert(1, ET.Element("value", value="20"))
al.insert(1, ET.Element("value", value="40"))

al = tree.find('.//enumeratedValueSet[@variable="work-socialization-probability"]')
al.insert(1, ET.Element("value", value="0.3"))

al = tree.find('.//enumeratedValueSet[@variable="male-ratio"]')
al.insert(1, ET.Element("value", value="45"))
al.insert(1, ET.Element("value", value="55"))

#write to file
tree = ET.ElementTree(indent(root))
tree.write('sensitivity_rp0.6.xml', encoding='utf-8')

# then we restart and prepare the high risk

tree = ET.parse('base_rp0.6.xml')
root = tree.getroot()

al = tree.find('.//enumeratedValueSet[@variable="high-risk-employed"]')
for x in al.getchildren():
  al.remove(x)
al.insert(1, ET.Element("value", value="50"))
al.insert(1, ET.Element("value", value="100"))

al = tree.find('.//enumeratedValueSet[@variable="population-employed-%"]')
al.insert(1, ET.Element("value", value="5"))
al.insert(1, ET.Element("value", value="20"))
al.insert(1, ET.Element("value", value="40"))

al = tree.find('.//enumeratedValueSet[@variable="male-ratio"]')
al.insert(1, ET.Element("value", value="45"))
al.insert(1, ET.Element("value", value="55"))

#write to file
tree = ET.ElementTree(indent(root))
tree.write('high-risk_rp0.6.xml',  encoding='utf-8')

# then we restart and prepare the CPOS

tree = ET.parse('base_rp0.6.xml')
root = tree.getroot()

al = tree.find('.//enumeratedValueSet[@variable="cpo-%"]')
for x in al.getchildren():
  al.remove(x)
al.insert(1, ET.Element("value", value="25"))
al.insert(1, ET.Element("value", value="50"))

al = tree.find('.//enumeratedValueSet[@variable="population-employed-%"]')
al.insert(1, ET.Element("value", value="5"))
al.insert(1, ET.Element("value", value="20"))
al.insert(1, ET.Element("value", value="40"))

al = tree.find('.//enumeratedValueSet[@variable="male-ratio"]')
al.insert(1, ET.Element("value", value="45"))
al.insert(1, ET.Element("value", value="55"))

#write to file
tree = ET.ElementTree(indent(root))
tree.write('cpos_rp0.6.xml', encoding='utf-8')

# finally, the community workers 

tree = ET.parse('base_rp0.6.xml')
root = tree.getroot()

al = tree.find('.//enumeratedValueSet[@variable="number-workers-per-community-center"]')
for x in al.getchildren():
  al.remove(x)
al.insert(1, ET.Element("value", value="3"))
al.insert(1, ET.Element("value", value="5"))

al = tree.find('.//enumeratedValueSet[@variable="population-employed-%"]')
al.insert(1, ET.Element("value", value="5"))
al.insert(1, ET.Element("value", value="20"))
al.insert(1, ET.Element("value", value="40"))

al = tree.find('.//enumeratedValueSet[@variable="male-ratio"]')
al.insert(1, ET.Element("value", value="45"))
al.insert(1, ET.Element("value", value="55"))

#write to file
tree = ET.ElementTree(indent(root))
tree.write('communityworkers_rp0.6.xml', encoding='utf-8')

