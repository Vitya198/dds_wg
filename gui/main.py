#This is the main (TopLevel) python file, which is the entry point of the Application
import tkinter as tk
from gui import GUI

if __name__ == '__main__':
    root = tk.Tk()
    logo = tk.PhotoImage(file = "/Users/vikto/images.png")
    root.geometry("800x600")
    root.iconphoto(False, logo)

    #Alkalmazás létrehozása és futtatása
    app = GUI(master=root)
    app.mainloop()