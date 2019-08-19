import xml.etree.ElementTree as ET

version="rp0.8"

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


tree = ET.parse('base_' + version + '.xml')
root = tree.getroot()

al = tree.find('.//enumeratedValueSet[@variable="high-risk-employed"]')
for x in al.getchildren():
  al.remove(x)
al.insert(1, ET.Element("value", value="75"))

#write to file
tree = ET.ElementTree(indent(root))
tree.write('high-risk_' + version + '.xml',  encoding='utf-8')

# then we restart and prepare the CPOS

tree = ET.parse('base_' + version + '.xml')
root = tree.getroot()

al = tree.find('.//enumeratedValueSet[@variable="cpo-%"]')
for x in al.getchildren():
  al.remove(x)
al.insert(1, ET.Element("value", value="50"))

#write to file
tree = ET.ElementTree(indent(root))
tree.write('cpos_' + version + '.xml', encoding='utf-8')

# finally, the community workers 

tree = ET.parse('base_' + version + '.xml')
root = tree.getroot()

al = tree.find('.//enumeratedValueSet[@variable="number-workers-per-community-center"]')
for x in al.getchildren():
  al.remove(x)
al.insert(1, ET.Element("value", value="5"))

#write to file
tree = ET.ElementTree(indent(root))
tree.write('communityworkers_' + version + '.xml', encoding='utf-8')