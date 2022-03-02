# OM-py 

## [Download](https://bit.ly/3v20gVe)


OM-py is a bridge between Python and OM environments. What it does is format some types of data that are differently represented. For example, one list of numbers in OM is represented by `(1 2 3 4 5)`. In Python, the same list is represented by `[1, 2, 3, 4, 5]`. Sounds inside OM are represented by a class, for example, `#<sound 23186913>`. To send this `#<sound 23186913>` to Python, we need to save it in a temp folder and then give it to Python by a `pathname`.

Besides that, it will run the python code, and bring the formatted result to OM. For that, we have two main OM-boxes: `py` and `py-code`. The `py` is like and object and will send to OM-Sharp all python vars insinde `to_om()`. The example below, will return 4 to `OM`.

```lisp
(py_var () 
"
from om_py.python_to_om import to_om
sum = 2 + 2 
to_om(sum) # If you want to use something inside OM, you need to print it.

"  )
```
Use variables inside OM is simple:

```lisp
(py_var (my_om_number) 
"
from om_py.python_to_om import to_om
sum = 2 + my_om_number
to_om(sum) # If you want to use something inside OM, you need to print it.

"  )
```
With `my_om_number` inside py_var it will open and input in the `py` box. 

<img src="https://user-images.githubusercontent.com/31707161/154814603-fdd34ca7-6e6d-4d3c-9c53-4d401eebc769.png" width=75% height=75%>

-----------------------------------------------------

OM-py work with vscode too. For that select `py` or `py-code` box and press `c`.

<img src="https://user-images.githubusercontent.com/31707161/154815586-2ecb119a-fa45-4de2-9817-1d0e477f49c1.gif" width=100% height=100%>

-----------------------------------------------------
## Use your own enviroment

If you want, you can define your own Python enviroment in external: 

![image](https://user-images.githubusercontent.com/31707161/154857500-1623c6b3-98b5-4234-97a9-77bbdac87936.png)

**Copy and paste your `PATH_ENVIROMENT` +:

1. **`Scripts/activate.bat` for Windows;**
2. **`bin/activate` for Ubuntu.**

-----------------------------------------------------

A beautiful example for spatialization:


<img src="https://user-images.githubusercontent.com/31707161/154816977-b9e1cef0-796a-457a-8380-f1af2f2093c9.gif" width=100% height=100%> 

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
* If you have no python in your machine (improbable) type `sudo apt install python3.8` 
* Then install pip typing, `sudo apt-get -y install python3-pip`
* Install Virtual Env: `sudo apt install python3.8-venv`
* Then create the om-py Virtual Env: `python3.8 -m venv YOUR_OM_TEMP_FOLDER/Python`

![Tmp Files](https://github.com/charlesneimog/OM-py/blob/master/Documentation/tmp-file%20example.png)


In my case: `python3.8 -m venv /home/neimog/Documents/OM#/temp-files/Python`.

To make sure that all things are working:
* Open OM-Sharp
* Load om-py;
* Then go to Help-> Help Patches... -> om-py
* Then open the path *use-py-inside-om*.
* Then evaluate the patch!

### MacOS

Coming soon!! I need a MacOS computer!

