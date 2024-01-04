from waveform_gen import DDS

# Adatok létrehozása
upload_data = DDS()

data = upload_data.sinus_wave()
# Memória mérete
memory_size = 1024

# Fájl megnyitása írásra
with open(r'C:\Users\vikto\Desktop\Direct_digital_synthesizer\main\memory.mif', 'w') as f:
    # Fejléc írása
    f.write('DEPTH = {};\n'.format(memory_size))
    f.write('WIDTH = 8;\n')
    f.write('ADDRESS_RADIX = HEX;\n')
    f.write('DATA_RADIX = HEX;\n')
    f.write('CONTENT\n')
    f.write('BEGIN\n')

    # Memória tartalmának felsorolása
    for i, value in enumerate(data):
        if value < 0:
            value += 256
        f.write('{:03X} : {:02X};\n'.format(i, value))
    # Fájl lezárása
    f.write('END;\n')













