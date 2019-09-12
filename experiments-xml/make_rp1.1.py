import xml.etree.ElementTree as ET
import pretty_print


base = 'donotrun_rp1.1'


version="rp1.1-10K-56"
tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(10))
al = tree.find('.//enumeratedValueSet[@variable="radicalization-percentage"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="5.6"))
al = tree.find('.//enumeratedValueSet[@variable="total-citizens"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10000"))
al = tree.find('.//enumeratedValueSet[@variable="running-plan"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value='"' + version + '"'))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write(version + '.xml',  encoding='utf-8')



version="rp1.1-10K-10"
tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(10))
al = tree.find('.//enumeratedValueSet[@variable="radicalization-percentage"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10"))
al = tree.find('.//enumeratedValueSet[@variable="total-citizens"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10000"))
al = tree.find('.//enumeratedValueSet[@variable="running-plan"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value='"' + version + '"'))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write(version + '.xml',  encoding='utf-8')

version="rp1.1-40K-10"
tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(10))
al = tree.find('.//enumeratedValueSet[@variable="radicalization-percentage"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10"))
al = tree.find('.//enumeratedValueSet[@variable="total-citizens"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="40000"))
al = tree.find('.//enumeratedValueSet[@variable="running-plan"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value='"' + version + '"'))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write(version + '.xml',  encoding='utf-8')

version="rp1.1-40K-56"
tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(10))
al = tree.find('.//enumeratedValueSet[@variable="radicalization-percentage"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="5.6"))
al = tree.find('.//enumeratedValueSet[@variable="total-citizens"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="40000"))
al = tree.find('.//enumeratedValueSet[@variable="running-plan"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value='"' + version + '"'))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write(version + '.xml',  encoding='utf-8')

