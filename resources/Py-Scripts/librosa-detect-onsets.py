# ======================= Add OM Variables BELOW this Line ========================
sound =  "None"

# ======================= Add OM Variables ABOVE this Line ========================

import librosa
from om_py import to_om

y, sr = librosa.load(sound)
onset_frames = librosa.onset.onset_detect(y=y, sr=sr, units='time')

to_om(onset_frames)



