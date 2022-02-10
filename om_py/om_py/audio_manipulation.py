from pyo import *


def ckn_binaural_pyo(infile, outfile, soundduration, azimuth, elevation, azispan):
    s = Server(nchnls=2, audio='offline').boot()
    s.recordOptions(dur=soundduration, filename=outfile, fileformat=0, sampletype=0)
    sf = SfPlayer(infile, mul=0.3)
    bin = Binaural(sf, azimuth=azimuth, elevation=elevation, azispan=azispan) 
    bin.out()
    s.start()

def ckn_convolution_pyo(infile, outfile, convolve_file, soundduration):
    s = Server(nchnls=2, audio='offline').boot()
    s.recordOptions(dur=soundduration, filename=outfile, fileformat=0, sampletype=0)
    sf = SfPlayer(infile, mul=[1,1])
    bin = Convolve(sf, SndTable(convolve_file), size=1024, mul=.15).out()
    bin.out()
    s.start()