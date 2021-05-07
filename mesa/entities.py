import typing
import scenario as scen
from mesa import Agent
if typing.TYPE_CHECKING:
    from model import ProtonT


class Location:

    def __init__(self, size=0, shape='null'):
        self.shape: [] = shape
        self.size: int = size


class Topic:

    def __init__(self,  name="Topic", risk=0.5, protective=0.5, value=0.5):
        self.topic_name: str = name
        self.risk_weight: float = risk
        self.protective_weight: float = protective
        self.value: float = value

    def __repr__(self):
        return "Topic: " + self.topic_name


class Citizen(Agent):

    def __init__(self, model, unique_id):
        super().__init__(unique_id, model)
        self.model: ProtonT = model
        self.unique_id = unique_id
        self.x = 0
        self.y = 0
        self.area: int = 0
        self.residence: Location = Location()
        self.topics: list = []
        self.setup_topics()
        self.countdown: int = 0
        self.current_task: str = "none"
        self.current_activity: str = "none"
        self.recruited: bool = False
        self.hours_to_recruit: int = 0
        self.recruit_target: str = "none"
        self.my_links_cap: int = 0

    def __repr__(self):
        return("Hi, I am agent " + str(self.unique_id) + ".")

    def setup_topics(self):
        for a_topic in scen.topic_definition_list():
            new_topic = Topic(a_topic[0], a_topic[1], a_topic[2])
            self.topics.append(new_topic)
