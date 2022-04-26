# ======================= Add OM Variables BELOW this Line ========================

audio_files =  None

# ======================= Add OM Variables ABOVE this Line ========================

import matplotlib.pyplot as plt
import numpy as np
import librosa
from om_py import to_om

def amplitude_envelope(signal, frame_size, hop_length):
    
    amplitude_envelope = []
    for i in range(0, len(signal), hop_length): 
        amplitude_envelope_current_frame = max(signal[i:i+frame_size]) 
        amplitude_envelope.append(amplitude_envelope_current_frame)
    return np.array(amplitude_envelope)   

def fancy_amplitude_envelope(signal, frame_size, hop_length):
    return np.array([max(signal[i:i+frame_size]) for i in range(0, len(signal), hop_length)])

def max_amplitude_envelope (audio_file):
    
    FRAME_SIZE = 256
    HOP_LENGTH = 128
    audio, sr = librosa.load(audio_file)
    sample_duration = 1 / sr
    tot_samples = len(audio)
    duration = 1 / sr * tot_samples
    ae_audio = amplitude_envelope(audio, FRAME_SIZE, HOP_LENGTH)
    frames = range(len(ae_audio))
    t = librosa.frames_to_time(frames, hop_length=HOP_LENGTH)
    ae_audio = max(ae_audio)
    return ae_audio
    
amplitudes = []

for audio_file in audio_files:
    amp_max = max_amplitude_envelope(audio_file)
    amplitudes.append(amp_max)

to_om(amplitudes)


    

