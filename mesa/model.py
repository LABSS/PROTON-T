from __future__ import annotations
from typing import Dict, Union, Any
import time
from mesa import Model
from mesa.time import RandomActivation
from numpy.random import default_rng
from entities import Citizen


class ProtonT(Model):

    def __init__(self, number_of_citizens=150, seed=int(time.time() % 60)):
        super().__init__(seed=seed)
        self.seed: int = seed
        self.tick: int = 0
        self.space_width: int = 40
        self.space_height: int = 40
        self.rng: default_rng = default_rng(self.seed)
        self.schedule: RandomActivation = RandomActivation(self)
        # Global definitions
        # ------------------
        # Areas: TO DO
        self.number_of_citizens: int = number_of_citizens
        self.areas: Dict = {}  # areas hashtable. {key:population}

    def __repr__(self):
        return "ProtonT Model"

    def load_totals(self):
        print('Load Totals')
        # load demographic data

    def setup_world(self):
        print('Load Totals')
        # load demographic data

    def setup_topics(self):
        print('Load Totals')
        # load demographic data

    def load_opinions(self):
        from scenario import Opinions
        print('Load Totals')
        # load demographic data



    def setup_communities_citiziens(self):
        for citizen in range(self.number_of_citizens):
            new_citizen = Citizen(self, citizen)
            self.schedule.add(new_citizen)


model = ProtonT()

model.load_totals()
model.setup_world()
model.setup_topics()

model.setup_communities_citiziens()

model.load_opinions()

for agent in model.schedule.agents:
    print(agent)
