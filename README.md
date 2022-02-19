# OM-py 

## [Download](https://bit.ly/3v20gVe)


OM-py is a bridge between Python and OM environments. What it does is format some types of data that are differently represented. For example, one list of numbers in OM is represented by `(1 2 3 4 5)`. In Python, the same list is represented by `[1, 2, 3, 4, 5]`. Sounds inside OM are represented by a class, for example, `#<sound 23186913>`. To send this `#<sound 23186913>` to Python, we need to save it in a temp folder and then give it to Python by a pathname.

With this library will be able to:
* Use python scripts using OM variables.
* Use VST3, vamp-plugins, tools for analisys and others;
* Easy Visual Python Multithreading with OM-CKN;
* All that Python could do.


## Install OM-Sharp

Go to https://github.com/cac-t-u-s/om-sharp/releases/ and download it from your plataform!




## Install OM Libraries

To install OM External Libraries see the process in: https://cac-t-u-s.github.io/pages/libraries!




## Install Python

### Windows

To install Python on Windows you need first download Python 3.9 in the Python website. 

https://www.python.org/downloads/release/python-399/

At the bottom of the page, you will see the **Windows installer (64-bit)**.

* Download it!

![Python](https://github.com/charlesneimog/OM-py/raw/master/Documentation/Windows%20-%20Python%20Download%20page.png)

* Then double click in the "python-3.9.9-amd64.exe".
* Make sure to mark the option *Add Python 3.9 to PATH*. 
* Click on **Install Now**.

![Path Variables](https://github.com/charlesneimog/OM-py/blob/master/Documentation/Add%20Python%20to%20Path%20variables.png)

* Click in **Close**. 

To make sure that all things are working:
* Open OM-Sharp
* Load om-py;
* Then go to Help-> Help Patches... -> om-py
* Then open the path *use-py-inside-om*.
* Then evaluate the patch!

If you heard a sound probably, it is working!! If not, please let me know!


### Linux

In Linux the process is a little more simple!
* Open the terminal;
* If you have no python in your machine (improbable) type `sudo apt install python3.8`. 
* Then install pip typing, `sudo apt-get -y install python3-pip`.
* Install Virtual Env: `sudo apt install python3.8-venv`.

To make sure that all things are working:
* Open OM-Sharp
* Load om-py;
* Then go to Help-> Help Patches... -> om-py
* Then open the path *use-py-inside-om*.
* Then evaluate the patch!

### MacOS

