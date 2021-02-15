from __future__ import annotations
from typing import Dict, Union, Any
import time
from mesa import Model
from mesa.time import BaseScheduler
from numpy.random import default_rng
from entities import Citizen
from scenario import *


class ProtonT(Model):

    def __init__(self, number_of_citizens=150, seed=int(time.time() % 60)):
        super().__init__(seed=seed)
        self.seed: int = seed
        self.tick: int = 0
        self.space_width: int = 40
        self.space_height: int = 40
        self.rng: default_rng = default_rng(self.seed)
        self.schedule: BaseScheduler = BaseScheduler(self)
        self.total_citizens: int = number_of_citizens

        self.number_of_citizens: int = number_of_citizens
        self.local: Dict = {}  # table with values for setup
        self.population: Dict = {}
        self.areas = []  # list index of areas, [1,2 ...4]
        self.area_names: Dict = {}  # names of areas, {1:A, ...}
        self.area_population: Dict = {}  # population into the areas, {1:9999, ...}

        # todo: add sliders definitions
        # todo: add all global definitions
        # self.population_details
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

    def __repr__(self):
        return "ProtonT Model"

    def setup_communities_citizens(self):
        for citizen in range(self.number_of_citizens):
            new_citizen = Citizen(self, citizen)
            self.schedule.add(new_citizen)


if __name__ == "__main__":
    model = ProtonT()

    load_totals(model)
    model.setup_communities_citizens()

    for agent in model.schedule.agents:
        print(agent)
