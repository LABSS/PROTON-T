from __future__ import annotations
from typing import Dict, Union, Any
import time
from mesa import Model
from mesa.time import BaseScheduler
from numpy.random import default_rng
from entities import Citizen
import pandas as pd
import scenario as scen
import os


class ProtonT(Model):

    def __init__(self, number_of_citizens=150, seed=os.urandom(8)[0]):
        super().__init__(seed=seed)
        self.seed: int = seed
        self.tick: int = 0
        self.space_width: int = 40
        self.space_height: int = 40
        self.rng: default_rng = default_rng(self.seed)
        self.schedule: BaseScheduler = BaseScheduler(self)
        self.total_citizens: int = number_of_citizens

        self.number_of_citizens: int = number_of_citizens
        self.local: Dict = dict()  # table with values for setup
        self.population: Dict = dict()
        self.areas = []  # list index of areas, [1,2 ...4]
        self.area_names: Dict = dict()  # names of areas, {1:A, ...}
        self.area_population: Dict = dict()  # population into the areas, {1:9999, ...}
        self.population_details_db = []
        self.population_details: Dict = dict()  #

        # todo: add sliders definitions
        self.male_ratio: list = ["from scenario", 45, 50, 55]
        self.male_ratio_index: int = 1
        # todo: add all global definitions

        # self.migrant_muslims_ratio
        # self.soc_counter
        # self.soc_online_counter
        # self.rec_counter
        # self.printed
        # self.fail_activity_counter
        # self.radicalization_threshold
        # self.police_actions_counter
        # self.police_action_probability
        # self.r_t_100
        # self.r_t_56

        """
        Directory structure:
            ├───inputs (@self.input_directory)
            │   ├───neukolln (@self.eindhoven)
            │   │   ├───data
            │   │   └───raw
            
        """
        self.mesa_dir: str = os.getcwd()
        self.cwd: str = os.path.dirname(self.mesa_dir)
        self.input_directory: str = os.path.join(self.cwd, "inputs")
        self.neukolln: str = os.path.join(self.input_directory, "neukolln")
        self.data_folder: str = os.path.join(self.neukolln, "data")

    def __repr__(self):
        return "ProtonT Model"

    def setup_communities_citizens(self):
        for citizen in range(self.number_of_citizens):
            new_citizen = Citizen(self, citizen)
            self.schedule.add(new_citizen)

    def read_csv_city(self, filename: str):
        """
        Based on the ProtonOc.data_folder attribute, which represents the directory of the city
        of interest, this function returns a pd.DataFrame named filename in the directory. Warning,
        the file must be a .csv file, it is not necessary to pass also the extension

        :param filename: str, the filename
        :return: pd.DataFrame, a pandas dataframe
        """
        return pd.read_csv(os.path.join(self.data_folder, filename + ".csv"))

    def change_global_gender_ratio(self, target_ratio):
        ratio_m = []
        males_pop = 0
        females_pop = 0
        for i in self.areas:
            details_list = self.population_details[i][i]
            for detail in details_list:
                if detail[2]:  # male
                    males_pop = males_pop + detail[5]
                else:
                    females_pop = females_pop + detail[5]
            ratio_m.append(males_pop / (males_pop + females_pop))
        new_list = []
        for i in self.areas:
            details_list = self.population_details[i][i]
            for detail in details_list:
                if detail[2]:
                    detail[5] = detail[5] * target_ratio / ratio_m[i-1]
                else:
                    detail[5] = detail[5] * (1 - target_ratio) / ratio_m[i - 1]
                new_list.append(detail)
            self.population_details[i] = {i: new_list}

    def load_totals(self):
        local_db = self.read_csv_city("neighborhoods")
        model.local = scen.from_db_to_dict("local", local_db)
        population_db = self.read_csv_city("neukolln-totals")
        model.population = scen.from_db_to_dict("population", population_db)
        model.areas = list(model.population.keys())
        names = population_db["area_name"].values.tolist()
        population = population_db["sum(value)"].values.tolist()
        population_sum = sum(population)
        for i in range(len(model.areas)):
            key = model.areas[i]
            self.area_population[key] = population[i] / population_sum * self.total_citizens
            self.area_names[key] = names[i]
        self.population_details_db = self.read_csv_city("neukolln-by-citizenship-migrantbackground-gender-religion-age")
        for a in self.areas:
            details = []
            for index, row in self.population_details_db.iterrows():
                if row['area_code'] == a:
                    details.append(row.values)
            self.population_details[a] = {a: details}


if __name__ == "__main__":
    model = ProtonT()

    model.load_totals()
    if model.male_ratio[model.male_ratio_index] != "from scenario":
        model.change_global_gender_ratio(model.male_ratio[model.male_ratio_index] / 100)
    model.setup_communities_citizens()
    # todo: time loop
    for agent in model.schedule.agents:
            print(agent)
        # todo: agent activation