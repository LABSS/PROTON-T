import xml.etree.ElementTree as ET
import pretty_print

version="_rpT13"
base = 'base-rpT13'

# the base ones
# varying alpha and the radicalization percentage. 
# two 20 blocks and one 10x4 one.

tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(20))
al = tree.find('.//enumeratedValueSet[@variable="radicalization-percentage"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write('base_r10' + version + '.xml',  encoding='utf-8')

tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(20))
al = tree.find('.//enumeratedValueSet[@variable="talk-effect-size"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="0.01"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write('base_t001' + version + '.xml',  encoding='utf-8')

tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(10))
al = tree.find('.//enumeratedValueSet[@variable="total-citizens"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10000"))
al = tree.find('.//enumeratedValueSet[@variable="talk-effect-size"]')
al.insert(1, ET.Element("value", value="0.01"))
al = tree.find('.//enumeratedValueSet[@variable="radicalization-percentage"]')
al.insert(1, ET.Element("value", value="10"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write('base_10K' + version + '.xml',  encoding='utf-8')


# high risk
# one40 x 40K, 
# two 20 blocks and one 10x4 one.

tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(40))
al = tree.find('.//enumeratedValueSet[@variable="high-risk-employed"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="25"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write('high-risk_25' + version + '.xml',  encoding='utf-8')

tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(10))
al = tree.find('.//enumeratedValueSet[@variable="total-citizens"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10000"))
al = tree.find('.//enumeratedValueSet[@variable="high-risk-employed"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10"))
al.insert(1, ET.Element("value", value="25"))
al.insert(1, ET.Element("value", value="50"))
al.insert(1, ET.Element("value", value="75"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write('high-risk_10K' + version + '.xml',  encoding='utf-8')

# community workers

tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(40))
al = tree.find('.//enumeratedValueSet[@variable="number-workers-per-community-center"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="25"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write('cworkers' + version + '.xml',  encoding='utf-8')

tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', version)
al.set('repetitions', str(10))
al = tree.find('.//enumeratedValueSet[@variable="total-citizens"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10000"))
al = tree.find('.//enumeratedValueSet[@variable="number-workers-per-community-center"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="5"))
al.insert(1, ET.Element("value", value="10"))
al.insert(1, ET.Element("value", value="20"))
al.insert(1, ET.Element("value", value="40"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write('cworkers_10K' + version + '.xml',  encoding='utf-8')

