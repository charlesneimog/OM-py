"""

This code is based on the following: https://github.com/jkitchin/pycse/blob/master/pycse/lisp.py. I just added the ability to send the objects to OM to facilitate the communication between Python and OM. This documentation was writing by Github co-pilot. 

"""

try: 
    import vamp
    import_vamp = True
except:
    import_vamp = False

import ctypes as c


try:
    import numpy as numpy
    import_numpy = True
except:
    import_numpy = False

import os

# ============================================================================= 

class pcolors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    ORANGE = '\033[91m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


# =============================================================================

class PyObject_HEAD(c.Structure):
    _fields_ = [('HEAD', c.c_ubyte * (object.__basicsize__ -
                                      c.sizeof(c.c_void_p))),
                ('ob_type', c.c_void_p)]

_get_dict = c.pythonapi._PyObject_GetDictPtr
_get_dict.restype = c.POINTER(c.py_object)
_get_dict.argtypes = [c.py_object]

# This is how we convert simple types to lisp. Strings go in quotes, and numbers
# basically self-evaluate. These never contain other types.

# =============================================================================
def get_dict(object):
    return _get_dict(object).contents.value

# =============================================================================

def to_om_dict (L):
    for i, j in zip(L.keys(), L.values()):
        dict_key = list()
        dict_values = list()
        dict_key.append(i)
        dict_values.append(j)
        result = dict_key + dict_values
    return result 

# =============================================================================

def lispify(L):
    """Convert a Python object L to a Common Lisp representation."""
    
    if L is None or L == []:
        return 'nil'
    else:
        # LISTS ARE RECURSIVE
        if isinstance(L, tuple):
            s = [element.lisp for element in L]
            return '(' + ' '.join(s) + ')'
        
            if import_numpy:
                if isinstance(L, numpy.ndarray):
                    s = [element.lisp for element in L]
                    return '(' + ' '.join(s) + ')'
                
                if (isinstance(L, numpy.int64) or isinstance(L, numpy.int32) or isinstance(L, numpy.float64) or isinstance(L, numpy.float32)):
                    return L.lisp
                else:
                    None
            else:
                print('Numpy is not installed. Please install numpy!!')

        elif (isinstance(L, list)):
            lispify_list = [lispify(element) for element in L]
            return '(' + ' '.join(lispify_list) + ')'
        elif isinstance(L, dict):
            return lispify(to_om_dict(L))

        # COMPLEX NUMBERS

        elif isinstance(L, complex):
            return '#C({0} {1})'.format(L.real, L.imag)

        # ATOMS

        elif (isinstance(L, float) or isinstance(L, int)):
            return L.lisp



        elif isinstance(L, str):
            new_path = L.replace('\\', '/')
            return new_path.lisp

        elif isinstance(L, None):
            return '()'
        
        else:
            not_supported_type = type(L)
            Warning = (f'{pcolors.FAIL}ERROR: Type not supported, please report that {pcolors.BOLD}{not_supported_type}{pcolors.FAIL} is not a supported type to ]https://github.com/charlesneimog/OM-py/issues/new{pcolors.ENDC}')
            return Warning

# Supported Types: ============================================================

get_dict(str)['lisp'] = property(lambda s:'"{}"'.format(str(s))) # String
get_dict(float)['lisp'] = property(lambda f:'{}'.format(str(f))) # Float
get_dict(int)['lisp'] = property(lambda f:'{}'.format(str(f))) # int
get_dict(complex)['lisp'] = property(lambda complex:'#C({0} {1})'.format(complex.real, complex.imag)) # Complex
get_dict(list)['lisp'] = property(lispify) # List
get_dict(tuple)['lisp'] = property(lispify) # Tuple
get_dict(dict)['lisp'] = property(lispify) # Dict


## =================

if import_numpy:
    get_dict(numpy.int64)['lisp'] = property(lambda f:'{}'.format(str(f))) # Int64
    get_dict(numpy.int32)['lisp'] = property(lambda f:'{}'.format(str(f))) # Int32
    get_dict(numpy.float64)['lisp'] = property(lambda f:'{}'.format(str(f))) # Float64
    get_dict(numpy.float32)['lisp'] = property(lambda f:'{}'.format(str(f))) # Float32
    get_dict(numpy.ndarray)['lisp'] = property(lispify) # Numpy Array

if import_vamp:
    get_dict(vamp.vampyhost.RealTime)['lisp'] = property(lambda f:'{}'.format(str(f))) # Vamp RealTime plugin

# Supported Types: ============================================================

def to_om (L):
    """It will write the values formatted to Lisp."""
    user_path = (os.path.expanduser('~'))
    py_values = os.path.join(user_path, 'py_values.txt')
    file_object = open(py_values, 'a')
    file_object.write(lispify(L))
    file_object.write("\n")
    file_object.close()

## ===========================================================================

def om_print (L):
    import argparse
    from pythonosc import udp_client
    client = udp_client.SimpleUDPClient("127.0.0.1", 1995)
    client.send_message("/om-print", lispify(L))
    return None
