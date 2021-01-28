# -*- coding: utf-8 -*-
"""
Created on Wed Jan 27 12:43:13 2021

@author: cecconi.federico
"""
import typing
from mesa import Agent
if typing.TYPE_CHECKING:
    from model import ProtonT

class Citizen(Agent):

    def __init__(self, model, unique_id):
        super().__init__(unique_id, model)
        self.model: ProtonT = model
        self.unique_id = unique_id
        self.x = 0
        self.y = 0
        self.area = 0

    def __repr__(self):
        return "Node: " + str(self.unique_id)


