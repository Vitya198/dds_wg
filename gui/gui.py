import tkinter as tk
from waveform_gen import DDS
from serial_com import serial_com
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from PIL import ImageTk
import struct

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
 
        self.input_frame= tk.Frame(self.master)
        self.input_frame.pack(side='left')
        
        self.graph_frame = tk.Frame(self.master)
        self.graph_frame.pack(side='right')

        self.input_frame.top_frame = tk.Frame(self.input_frame)
        self.input_frame.top_frame.pack(side='top')
        
        self.input_frame.bottom_frame = tk.Frame(self.input_frame)
        self.input_frame.bottom_frame.pack(side='top')

        #DDS objektum létrehozása
        self.dds = DDS()

        '''
        #soros kommunikációs objektum létrehozása
        self.ser_com = serial_com()

        #Kommunikációs regiszterek címei
        self.NCO_START_REG   = 0x00
        self.FREQ_SET_REG_L  = 0x01
        self.FREQ_SET_REG_H  = 0x02
        self.DAC_SET_REG_L   = 0x03
        self.DAC_SET_REG_H   = 0x04
        '''
        #Létrehozzuk a kreten belüli "alkalmazásokat"
        self.create_widgets()


#--------------------------------------------------------------------------------------------------------#
#                                               Függvények                                               #
#--------------------------------------------------------------------------------------------------------#
    #Ha a megadott érték nem szám és nem a megfelelő intervallumba eseik, akkor False-al térünk vissza
    def check_value(self):
        value = self.input_frame.top_frame.frequency_entry.get()
        if value.isdigit() and 16 <= int(value) <= 20000:
            self.send_freq_number(value)
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
    #def update_label(self):

    #Frekvencia beállítása és elküldése 
    def send_freq_number(self, value):
        freq_step = int(value)  # lekérjük a beviteli mezőben megadott számot
        self.dds.set_frequency(freq_step)  # átadjuk a számot a waveform_gen objektumnak"""
        '''
        #Engedélyezés
        self.ser_com.send_command(self.ser_com.WRITE_COMMAND, self.NCO_START_REG, "0x01")

        #Frekvencia feltöltése 
        self.ser_com.send_command(self.ser_com.WRITE_COMMAND, self.FREQ_SET_REG_L, self.dds.freq_step_l)
        self.ser_com.send_command(self.ser_com.WRITE_COMMAND, self.FREQ_SET_REG_H, self.dds.freq_step_h)
        '''
    #Digital-Analog Átalakító skálázásának beállítása
    def send_dac_data_set(self):
        '''
        dac_set_value = int(self.input_frame.top_frame.dac_set_value_entry.get())

        self.dac_set_value_bytes = struct.pack('>H', dac_set_value)
        
        
        dac_set_value_l = dac_set_value_bytes[0]
        dac_set_value_h = dac_set_value_bytes[1]
        
        #Scale adat feltöltése
        self.ser_com.send_command(self.ser_com.WRITE_COMMAND, self.DAC_SET_REG_L, dac_set_value_l)
        self.ser_com.send_command(self.ser_com.WRITE_COMMAND, self.DAC_SET_REG_H, dac_set_value_h)
        '''
    #Hullámforma ábrájának frissítése
    def update_plot(self):

        xt = self.dds.xt
        yt_t = self.dds.sin_wave_gui
    
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

    #LOADING SINUS WAVE
    def loading_sinus(self):
        '''
        self.ser_com.send_command(self.ser_com.LOAD_DATA_COMMAND, 0, None, None)
        count = 0 
        self.dds.sinus_wave()
        while (count == (self.dds.N-1)):
            self.ser_com.serial_port.load_data(self.dds.sin_wave(count))
            count += 1
            '''
    def loading_square(self):
        ''''''
    def loading_triangle(self):
        ''''''
    def loading_sawtooth(self):
        ''''''       


    #SINUS button szerkesztése
    def toggle_on_off(self):
        if self.input_frame.bottom_frame.load_button["text"] == "SIN":
            self.input_frame.bottom_frame.load_button["text"] = "SIN"
            self.input_frame.bottom_frame.load_button["bg"] = "red"
        else:
            self.input_frame.bottom_frame.on_off_btn["text"] = "SIN"
            self.input_frame.bottom_frame.on_off_btn["bg"] = "green"      
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
        self.input_frame.top_frame.frequency_label = tk.Label(self.input_frame.top_frame, text='Frekvencia (20Hz-20kHz)',font=("Helvetica", 16, "bold"))
        self.input_frame.top_frame.frequency_entry = tk.Entry(self.input_frame.top_frame, validate="key")

        #Létrehozunk egy gombot, amely ellenőrzi a szám helyességét és elküldi az adatot az FPGA-nak, ha helyes
        self.input_frame.top_frame.submit_button = tk.Button(self.input_frame.top_frame, text="Küldés",  command = self.check_value) 

        #Elhelyezzük a gombokat és feliratokat
        self.input_frame.top_frame.frequency_label.grid(row=0, column=0, sticky="NSEW")
        self.input_frame.top_frame.frequency_entry.grid(row=1, column=0, padx=5, pady=5, sticky="NSEW")
        self.input_frame.top_frame.submit_button.grid(row=1, column=1, padx=5, pady=5, sticky="NSEW")

        #DAC set
        self.input_frame.top_frame.dac_label = tk.Label(self.input_frame.top_frame, text='WM873 audio kodek beállítása',font=("Helvetica", 16, "bold"))
        self.input_frame.top_frame.dac_entry = tk.Entry(self.input_frame.top_frame, validate="key")

        #Létrehozunk egy gombot, elküldi az adatot az FPGA-nak
        self.input_frame.top_frame.send_button = tk.Button(self.input_frame.top_frame, text="Küldés",  command = self.send_dac_data_set)
        
        #Elhelyezzük a gombokat és feliratokat
        self.input_frame.top_frame.dac_label.grid(row=2, column=0, sticky="NSEW")
        self.input_frame.top_frame.dac_entry.grid(row=3, column=0, padx=5, pady=5, sticky="NSEW")
        self.input_frame.top_frame.send_button.grid(row=3, column=1, padx=5, pady=5, sticky="NSEW")
        






        #adatok betöltése az fpga-ba 
        self.input_frame.bottom_frame.load_button_sin = tk.Button(self.input_frame.bottom_frame, command = self.loading_sinus(),  width=3, height=1)  
        self.input_frame.bottom_frame.load_button_square = tk.Button(self.input_frame.bottom_frame, command = self.loading_square(),  width=3, height=1)  
        self.input_frame.bottom_frame.load_button_triangle = tk.Button(self.input_frame.bottom_frame, command = self.loading_triangle(),  width=3, height=1)  
        self.input_frame.bottom_frame.load_button_sawtooth = tk.Button(self.input_frame.bottom_frame, command = self.loading_sawtooth(),  width=3, height=1)  
        
        #Elhelyezés

        self.input_frame.bottom_frame.load_button_sin.grid(row=0, column=0,     padx=30, pady=10,sticky="NSEW")
        self.input_frame.bottom_frame.load_button_square.grid(row=0, column=1,  padx=30, pady=10,sticky="NSEW")
        self.input_frame.bottom_frame.load_button_triangle.grid(row=0, column=2,padx=30, pady=10,sticky="NSEW")
        self.input_frame.bottom_frame.load_button_sawtooth.grid(row=0, column=3,padx=30, pady=10,sticky="NSEW")

        #self.input_frame.bottom_frame.columnconfigure(0, weight=1)
        #self.input_frame.bottom_frame.columnconfigure(1, weight=1)
        #self.input_frame.bottom_frame.columnconfigure(2, weight=1)
        #self.input_frame.bottom_frame.columnconfigure(3, weight=1)

        #Alapértelmezetten a betöltés kikapcsolva
        self.input_frame.bottom_frame.load_button_sin["text"] = "SIN"
        self.input_frame.bottom_frame.load_button_sin["bg"] = "green"
        self.input_frame.bottom_frame.load_button_sin["fg"] = "white"
        self.input_frame.bottom_frame.load_button_sin["font"] = 10

        self.input_frame.bottom_frame.load_button_square["text"] = "SQR"
        self.input_frame.bottom_frame.load_button_square["bg"] = "red"
        self.input_frame.bottom_frame.load_button_square["fg"] = "white"
        self.input_frame.bottom_frame.load_button_square["font"] = 10

        self.input_frame.bottom_frame.load_button_triangle["text"] = "TRI"
        self.input_frame.bottom_frame.load_button_triangle["bg"] = "red"
        self.input_frame.bottom_frame.load_button_triangle["fg"] = "white"
        self.input_frame.bottom_frame.load_button_triangle["font"] = 10

        self.input_frame.bottom_frame.load_button_sawtooth["text"] = "SAW"
        self.input_frame.bottom_frame.load_button_sawtooth["bg"] = "red"
        self.input_frame.bottom_frame.load_button_sawtooth["fg"] = "white"
        self.input_frame.bottom_frame.load_button_sawtooth["font"] = 10

        #Módosítás
        self.input_frame.bottom_frame.load_button_sin["command"] = self.toggle_on_off
        self.input_frame.bottom_frame.load_button_square["command"] = self.toggle_on_off
        self.input_frame.bottom_frame.load_button_triangle["command"] = self.toggle_on_off
        self.input_frame.bottom_frame.load_button_sawtooth["command"] = self.toggle_on_off

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
