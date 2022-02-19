# python setup.py sdist bdist_wheel

import os

from om_py.functions import f2mc
from om_py.random import Random 
from om_py.python_to_om import to_om
from om_py.python_to_om import lispify
from om_py.musicxml2om import musicxml2om

if os.name == 'nt':
    from om_py.audio_manipulation import ckn_binaural_pyo
    from om_py.audio_manipulation import ckn_convolution_pyo

else:
    None

