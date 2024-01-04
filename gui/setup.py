#Először elnavigálunk a fájlokat tartalmazó mappába
#Majd bas-en futtatjuk a következő parancsot: "python setup.py build"
#Ez létrehozza nekünk a "main.exe" fájlt, ami a build könyvtárban található meg

from cx_Freeze import setup, Executable

setup(
    name='myapp',
    version='1.0',
    description='My application',
    executables=[Executable('main.py')],
)