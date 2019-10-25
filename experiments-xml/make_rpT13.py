import xml.etree.ElementTree as ET
import pretty_print

version="rpT13"
base = '_rpT13'
repetitions=10

# the base one

experiment = version + '_base'
tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', experiment)
al.set('repetitions', str(repetitions))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write(experiment + '.xml',  encoding='utf-8')


# high risk
experiment = version + '_high-risk'
tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', experiment)
al.set('repetitions', str(repetitions))
al = tree.find('.//enumeratedValueSet[@variable="high-risk-employed"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="25"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write(experiment + '.xml',  encoding='utf-8')

# community workers
experiment = version + '_cworkers5'
tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', experiment)
al.set('repetitions', str(repetitions))
al = tree.find('.//enumeratedValueSet[@variable="number-workers-per-community-center"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="5"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write(experiment + '.xml',  encoding='utf-8')

experiment = version + '_cworkers10'
tree = ET.parse(base + '.xml')
root = tree.getroot()
al = tree.find('.//experiment')
al.set('name', experiment)
al.set('repetitions', str(repetitions))
al = tree.find('.//enumeratedValueSet[@variable="number-workers-per-community-center"]')
for x in al.getchildren(): al.remove(x)
al.insert(1, ET.Element("value", value="10"))
tree = ET.ElementTree(pretty_print.indent(root))
tree.write(experiment + '.xml',  encoding='utf-8')

