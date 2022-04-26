# ======================= Add OM Variables BELOW this Line ========================

sound = r'C:\Users\Neimog\Documents\OM#\temp-files\om-ckn\44705.aif'

# ======================= Add OM Variables ABOVE this Line ========================

import librosa
import numpy as np
import librosa.display
import matplotlib.pyplot as plt
from om_py import to_om

y, sr = librosa.load(sound)

f0 = librosa.yin(y, fmin=80, fmax=5000)

times = librosa.times_like(f0)

to_om(list(times))
to_om(list(f0))

