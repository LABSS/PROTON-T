import xml.etree.ElementTree as ET

version="rp0.9"
source_name='source_' + version + '.donotlaunch.xml'

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
	
# the base

tree = ET.parse(source_name)
root = tree.getroot()

for criminalhistory in [ ["2","5"],["10", "20"]]:

    al = tree.find('.//enumeratedValueSet[@variable="male-ratio"]')
    al.insert(1, ET.Element("value", value="45"))
    al.insert(1, ET.Element("value", value="55"))

    al = tree.find('.//enumeratedValueSet[@variable="population-employed-%"]')
    al.insert(1, ET.Element("value", value="20"))
    al.insert(1, ET.Element("value", value="30"))
    al.insert(1, ET.Element("value", value="40"))
    al.insert(1, ET.Element("value", value="50"))

    al = tree.find('.//enumeratedValueSet[@variable="criminal-history-percent"]')
    for x in al.getchildren():
        al.remove(x)
    for x in criminalhistory:
        al.insert(1, ET.Element("value", value=x))

    #write to file
    tree = ET.ElementTree(indent(root))
    tree.write('base_' + version + "-ch" + "".join(criminalhistory) + '.xml',  encoding='utf-8')

for gender in ["50","45","55"]:

    #  the high risk

    tree = ET.parse(source_name)
    root = tree.getroot()

    al = tree.find('.//enumeratedValueSet[@variable="high-risk-employed"]')
    for x in al.getchildren():
      al.remove(x)
    al.insert(1, ET.Element("value", value="75"))
    al.insert(1, ET.Element("value", value="50"))

    al = tree.find('.//enumeratedValueSet[@variable="male-ratio"]')
    for x in al.getchildren():
      al.remove(x)
    al.insert(1, ET.Element("value", value=gender))

    al = tree.find('.//enumeratedValueSet[@variable="population-employed-%"]')
    al.insert(1, ET.Element("value", value="20"))
    al.insert(1, ET.Element("value", value="30"))
    al.insert(1, ET.Element("value", value="40"))
    al.insert(1, ET.Element("value", value="50"))

    al = tree.find('.//enumeratedValueSet[@variable="criminal-history-percent"]')
    al.insert(1, ET.Element("value", value="2"))
    al.insert(1, ET.Element("value", value="5"))
    al.insert(1, ET.Element("value", value="10"))

    #write to file
    tree = ET.ElementTree(indent(root))
    tree.write('high-risk_' + version + "_g" + gender + '.xml',  encoding='utf-8')

    # then we restart and prepare the CPOS

    tree = ET.parse(source_name)
    root = tree.getroot()

    al = tree.find('.//enumeratedValueSet[@variable="cpo-%"]')
    for x in al.getchildren():
      al.remove(x)
    al.insert(1, ET.Element("value", value="50"))
    al.insert(1, ET.Element("value", value="25"))

    al = tree.find('.//enumeratedValueSet[@variable="male-ratio"]')
    for x in al.getchildren():
      al.remove(x)
    al.insert(1, ET.Element("value", value=gender))

    al = tree.find('.//enumeratedValueSet[@variable="population-employed-%"]')
    al.insert(1, ET.Element("value", value="20"))
    al.insert(1, ET.Element("value", value="30"))
    al.insert(1, ET.Element("value", value="40"))
    al.insert(1, ET.Element("value", value="50"))

    al = tree.find('.//enumeratedValueSet[@variable="criminal-history-percent"]')
    al.insert(1, ET.Element("value", value="2"))
    al.insert(1, ET.Element("value", value="5"))
    al.insert(1, ET.Element("value", value="10"))

    #write to file
    tree = ET.ElementTree(indent(root))
    tree.write('cpos_' + version + "_g" + gender + '.xml',  encoding='utf-8')

    # finally, the community workers 

    tree = ET.parse(source_name)
    root = tree.getroot()

    al = tree.find('.//enumeratedValueSet[@variable="number-workers-per-community-center"]')
    for x in al.getchildren():
      al.remove(x)
    al.insert(1, ET.Element("value", value="3"))
    al.insert(1, ET.Element("value", value="5"))

    al = tree.find('.//enumeratedValueSet[@variable="male-ratio"]')
    for x in al.getchildren():
      al.remove(x)
    al.insert(1, ET.Element("value", value=gender))

    al = tree.find('.//enumeratedValueSet[@variable="population-employed-%"]')
    al.insert(1, ET.Element("value", value="20"))
    al.insert(1, ET.Element("value", value="30"))
    al.insert(1, ET.Element("value", value="40"))
    al.insert(1, ET.Element("value", value="50"))

    al = tree.find('.//enumeratedValueSet[@variable="criminal-history-percent"]')
    al.insert(1, ET.Element("value", value="2"))
    al.insert(1, ET.Element("value", value="5"))
    al.insert(1, ET.Element("value", value="10"))

    #write to file
    tree = ET.ElementTree(indent(root))
    tree.write('communityworkers_' + version + "_g" + gender + '.xml',  encoding='utf-8')

