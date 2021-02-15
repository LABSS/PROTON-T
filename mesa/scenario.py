import pandas as pd


def from_db_to_dict(variable_name, db):
    table = {}
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


def load_totals(model):
    data_path = "../inputs/neukolln/data/"
    local_db = pd.read_csv(data_path+"neighborhoods.csv")
    model.local = from_db_to_dict("local", local_db)
    population_db = pd.read_csv(data_path + "neukolln-totals.csv")
    model.population = from_db_to_dict("population", population_db)
    model.areas = list(model.population.keys())
    names = population_db["area_name"].values.tolist()
    population = population_db["sum(value)"].values.tolist()
    population_sum = sum(population)
    for i in range(len(model.areas)):
        key = model.areas[i]
        model.area_population[key] = population[i] / population_sum * model.total_citizens
        model.area_names[key] = names[i]
