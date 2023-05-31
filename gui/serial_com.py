import serial

class serial_com:
    def __init__(self, serial_port_name='COM0', baud_rate=9600):
        # Az FPGA-val való kommunikációhoz használt soros port neve és sebessége
        self.serial_port_name = serial_port_name
        self.baud_rate = baud_rate

        # A soros port létrehozása és megnyitása
        self.serial_port = serial.Serial(self.serial_port_name, self.baud_rate)

        # A parancsok definíciói
        self.WRITE_COMMAND      = 0
        self.READ_COMMAND       = 1
        self.LOAD_COMMAND       = 2

    # Az FPGA-ban lévő regiszterek értékeinek beállításai 
    def send_command(self, command, address=None, data=None, data_number=None):

        # Konvertáljuk az address és a data változókat bytes típusba
        self.command_bytes = bytes([command])
        self.address_bytes = bytes([address])
        self.data_bytes = bytes([data]) if data is not None else None

        # Az elküldendő üzenet összeállítása
        self.message = bytearray()
        self.message.append(command)   #parancs összeállítása
        self.message.append(address)   #cím összeállítása
        if command == self.WRITE_COMMAND:
            self.message.append(data)   #ha WRITE parancs van, akkor adat összeállítása

        # Az üzenet elküldése a soros porton
        self.serial_port.write(self.message)    #adatok elküldése

        #Üzenet olvasása a soros porton
        if command == self.READ_COMMAND:
            data = self.serial_port.read(1)     #Az olvasott válasz visszatérése
            return data
        else:
            return None

        # Az adatok betültése az FPGA block ram-jába
    def load_data(self, data=None):
        # Az elküldendő üzenet összeállítása
        self.message = bytearray()
        self.message.append(data)

        # Az üzenet elküldése a soros porton
        self.serial_port.write(self.message)
        

        
