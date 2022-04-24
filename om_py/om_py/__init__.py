# python setup.py sdist bdist_wheel

import os

from om_py.functions import f2mc
from om_py.random import Random 
from om_py.python_to_om import to_om, lispify, om_print
#from om_py.musicxml2om import musicxml2om
from om_py.score import add_dots, names2ratio, notes_divisions, fix_min_pulses, fix_nested_tuplets, check_the_var, remove_the_var, list_depth, ckn_notes, om_pulse, om_group, om_measure, om_voice, om_part 


