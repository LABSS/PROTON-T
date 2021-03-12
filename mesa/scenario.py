def from_db_to_dict(variable_name, db):
    table = dict()
    if variable_name == "local":
        for i in range(len(db)):
            key = db.iloc[i, 0]
            if key in table:
                table[key][db.iloc[i, 1]] = db.iloc[i, 2]
            else:
                table[key] = {db.iloc[i, 1]: db.iloc[i, 2]}
    if variable_name == "population":
        for i in range(len(db)):
            table[db.iloc[i, 0]] = [db.iloc[i, 1], db.iloc[i, 2]]
    return table

def topic_definition_list():
    # type, risk-weight, protective-weight
    return  [
                ["Non integration", 0.188, 0.178],
                ["Institutional distrust", 0.277, 0.153],
                ["Collective relative deprivation", 0.116, 0],
            ]


