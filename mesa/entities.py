import typing
from mesa import Agent
if typing.TYPE_CHECKING:
    from model import ProtonT


class Location:

    def __init__(self, size=0, shape='null'):
        self.shape: [] = shape
        self.size: int = size


class Citizen(Agent):

    def __init__(self, model, unique_id):
        super().__init__(unique_id, model)
        self.model: ProtonT = model
        self.unique_id = unique_id
        self.x = 0
        self.y = 0
        self.area: int = 0
        self.residence: Location = Location()

    def __repr__(self):
        return "Agent: " + str(self.unique_id)


