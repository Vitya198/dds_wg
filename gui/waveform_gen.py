# Direct Digital Synthesis 
# Képlet => f = fs*(M/N), 
# N: az eltárolt adatok száma
# M: a lépésköz, max az adatok számának 8
# fs: pedig a mintavételi frekvencia
import numpy as np             
import scipy as sc
import scipy.fftpack  as ft
import scipy.signal as sg
import struct

class DDS:
    def __init__(self):
        #alap értékek beállítása
        self.fs = 96e3 
        self.dt = 1/self.fs
        self.N = 1024
        self.nt = np.arange(self.N)     #elemekből vektor készítése
        self.xt = self.nt*self.dt       #mintavételezés
        

    def sinus_wave(self):
        #alapértelmezett érték, ahol a frekvencilépés=1
        self.f = 93.75

        #függvény értékeinek meghatározása
        self.sin_wave_int = np.cos(2*np.pi*self.f*self.xt)  

        # 8 bites egész számokként ábrázolása (-128..127 tartományban)
        self.sin_wave = (self.sin_wave_int * 127).astype(np.int8)

        return self.sin_wave  
    

    def set_frequency(self, freq):

        #frekvencia beállítása
        self.f = freq
        '''
        #Frekvencia érték megváltoztatás írása az FPGA-ra
        self.freq_step = (self.f *self.N)/self.fs   #frekvencia lépés

        # Az adat bájtokra bontása
        data_bytes = struct.pack('>H', self.freq_step)
        
        # Az adat két darab 8 bites változóra bontása
        self.freq_step_l = data_bytes[0]
        self.freq_step_h = data_bytes[1]
        '''
        #függvény értékeinek meghatározása
        self.sin_wave_gui = np.cos(2*np.pi*self.f*self.xt)            







