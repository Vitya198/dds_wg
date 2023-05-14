import tkinter as tk
from waveform_gen import DDS
from serial_com import serial_com
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from PIL import ImageTk

class GUI(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.canvas = tk.Canvas(master)
        self.master.title('Hullámfomra generátor')
        self.pack()
        
        #lekérjük az alkalmazás képernyőjének méreteit
        self.screen_width  = self.winfo_screenwidth()
        self.screen_height = self.winfo_screenheight()

        # Az alapértelmezett hullámforma a későbbiekben alkalmazandó*
        self.selected_waveform = "sinus"
 
        self.input_frame = tk.Frame(self.master)
        self.input_frame.pack(side='left')
        
        self.graph_frame = tk.Frame(self.master)
        self.graph_frame.pack(side='right')

        #DDS objektum létrehozása
        self.dds = DDS()

        #soros kommunikációs objektum létrehozása
        self.ser_com = serial_com()

        #Kommunikációs regiszterek címei
        self.NCO_START_REG   = 0x00
        self.FREQ_SET_REG_L  = 0x01
        self.FREQ_SET_REG_H  = 0x02
        self.DAC_SCALE_REG   = 0x03

        #Létrehozzuk a kreten belüli "alkalmazásokat"
        self.create_widgets()


#--------------------------------------------------------------------------------------------------------#
#                                               Függvények                                               #
#--------------------------------------------------------------------------------------------------------#
    #Ha a megadott érték nem szám és nem a megfelelő intervallumba eseik, akkor False-al térünk vissza
    def check_value(self):
        value = self.input_frame.frequency_entry.get()
        if value.isdigit() and 16 <= int(value) <= 20000:
            self.send_freq_number()
            self.update_plot()
        else:
           # Ablak mérete
            self.width = 300
            self.height = 50
            # Képernyő közepére igazítás
            self.error_window = tk.Toplevel(self)
            self.error_window.title('Error')
            self.screen_width = self.error_window.winfo_screenwidth()
            self.screen_height = self.error_window.winfo_screenheight()
            self.x_cordinate = int((self.screen_width/2) - (self.width/2))
            self.y_cordinate = int((self.screen_height/2) - (self.height/2))
            self.error_window.geometry("{}x{}+{}+{}".format(self.width, self.height, self.x_cordinate, self.y_cordinate))
            # Ablak fix mérete
            self.error_window.resizable(False, False)
            #error icon
            #self.error_icon = tk.PhotoImage(file = "/Users/vikto/error.png")
            #self.error_window.iconphoto(False,self.error_icon)
            #Label + button
            self.error_label = tk.Label(self.error_window, text="A frekvencia nem a megfelelő intervallumba esik")
            self.ok_button = tk.Button(self.error_window, text = "OK", command=self.error_window.destroy)

            self.error_label.pack()
            self.ok_button.pack()
    
    #A függvény a dac gomb ON/OFF állapotba történő váltására szolgál
    def update_label(self):
        #Új érték lekérése a csúszkáról
        scale_value = self.input_frame.dac_scale_slider.get()

        #A csúszka áthelyezése az újértékre
        if scale_value == 0:
            self.input_frame.dac_scale_slider.set(1)
        elif scale_value == 1:
            self.input_frame.dac_scale_slider.set(2)
        else:
            self.input_frame.dac_scale_slider.set(0)

    #Frekvencia beállítása és elküldése 
    def send_freq_number(self):
        self.freq = int(self.input_frame.frequency_entry.get())  # lekérjük a beviteli mezőben megadott számot
        self.dds.set_frequency(self.freq)  # átadjuk a számot a waveform_gen objektumnak"""

        #Engedélyezés
        self.ser_com.send_command(self.ser_com.WRITE_COMMAND, self.NCO_START_REG, "0x01")

        #Frekvencia feltöltése 
        self.ser_com.send_command(self.ser_com.WRITE_COMMAND, self.FREQ_SET_REG_L, self.dds.freq_step_l)
        self.ser_com.send_command(self.ser_com.WRITE_COMMAND, self.FREQ_SET_REG_H, self.dds.freq_step_h)

    #Digital-Analog Átalakító skálázásának beállítása
    def send_dac_scale(self, value):

        scale_value = int(self.input_frame.dac_scale_slider.get())

        #Scale adat feltöltése
        self.ser_com.send_command(self.ser_com.WRITE_COMMAND, self.DAC_SCALE_REG, scale_value)

    #Hullámforma ábrájának frissítése
    def update_plot(self):

        xt = self.dds.xt
        yt_t = self.dds.sin_wave_int
    
        #canvas1.delete("all") #előző ábra törlése
        canvas1 = tk.Canvas(self.graph_frame.canvas_1, width='400',height='300')
        canvas1.grid(row=0, column=0, padx=5,pady=5, sticky="NSEW")
        
        self.fig = plt.figure(0,figsize=(10, 5), dpi=100)
        plt.clf()
        plt.title('DDS jelgenerálás: f = {} Hz'.format(str(self.dds.f)))
        plt.ylabel('Amplitúdó')
        plt.xlabel('Idő')
        plt.plot(xt, yt_t)
        plt.tight_layout()
        #self.fig = plt.gcf()
        canvas1.delete("all") #előző ábra törlése
        #canvas1.delete("all") #előző ábra törlése
        canvas1 = FigureCanvasTkAgg(self.fig, master=canvas1)
        canvas1.draw()
        canvas1.get_tk_widget().grid(row=0, column=0, padx=5,pady=5, sticky="NSEW")



#--------------------------------------------------------------------------------------------------------#
#                                       Az alkalmazás ablaka                                             #                
#--------------------------------------------------------------------------------------------------------#
    def create_widgets(self):

        # Draw the line on the canvas
        self.canvas.create_line(0, 0, 0, 400, width=2)

        # Pack the frames and canvas widget
        self.input_frame.pack(side='left', fill='both', expand=True)
        self.canvas.pack(side='right', fill='y')
        self.graph_frame.pack(side='right', fill='both', expand=True)
    

    #-------------------------------------------------------#
    # Input Frame (bal oldai keret, ahol az inputok vannak) #
    #-------------------------------------------------------#
        #frequency set    
        self.input_frame.frequency_label = tk.Label(self.input_frame, text='Frequency (20Hz-20kHz)',font=("Helvetica", 16, "bold"))
        self.input_frame.frequency_entry = tk.Entry(self.input_frame, validate="key")

        #Létrehozunk egy gombot, amely ellenőrzi a szám helyességét
        self.input_frame.submit_button = tk.Button(self.input_frame, text="Ellenőrzés",  command = self.check_value) 

        #Elhelyezzük a gombokat és feliratokat
        self.input_frame.frequency_label.grid(row=0, column=0, sticky="NSEW")
        self.input_frame.frequency_entry.grid(row=1, column=0, padx=5, pady=5, sticky="NSEW")
        self.input_frame.submit_button.grid(row=1, column=1, padx=5, pady=5, sticky="NSEW")

        #DAC scale megváltoztatása
        self.input_frame.dac_scale_label = tk.Label(self.input_frame, text="DAC scale factor", font=("Helvetica", 16, "bold"))
        self.input_frame.dac_scale_label.grid(row=3, column=1, sticky="NSEW")

        self.input_frame.dac_scale_slider = tk.Scale(self.input_frame, from_=0, to=2, orient=tk.HORIZONTAL, command = self.update_label) 
        self.input_frame.dac_scale_slider.grid(row=4, column=1, padx=5, pady=5, sticky="NSEW")


    #-------------------------------------------------------#
    # Graph Frame (jobb oldali keret, ahol az ábrák vannak) #
    #-------------------------------------------------------#
        #graph frame
        for i in range(2):
            self.graph_frame.rowconfigure(i,weight=1, minsize=75)
            self.graph_frame.columnconfigure(0,weight=1, minsize=75)
        #kimeneti függvény
        self.graph_frame.canvas_1 = tk.Canvas(self.graph_frame, width='400', height = '300', bg='white')
        self.graph_frame.canvas_1.grid(row=0, column=0, padx=5,pady=5, sticky="NSEW")
