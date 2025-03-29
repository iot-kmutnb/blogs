##########################################################
# Goto: https://gotroot.ca/rigol/riglol/
# You need the SN of the DP832 device to generate the key.
##########################################################

import pyvisa
import sys
import time

SN = None

# Print the version of pyvisa
print(f"Using PyVisa v{pyvisa.__version__}")

# Initialize the VISA resource manager with pyvisa-py
rm = pyvisa.ResourceManager('@py') 

for res in rm.list_resources():
    if res.startswith('USB'):
        print( res )
        SN =  res.split("::")[3]

if not SN:
    print( "Not DP832 device found")
    sys.exit()

##########################################################

resource = f"USB0::0x1AB1::0x0E11::{SN}::INSTR"
print('opening resource: ' + resource)
inst = rm.open_resource(resource)

# Show the IDN of the USB device
idn_str = inst.query("*IDN?")
names = ['Vendor', 'Model', 'SN', 'FW']
values = idn_str.strip().split(',')
sysinfo = dict(zip(names, values))
for key,value in sysinfo.items():
    print( f"{key}: {value}" )

##########################################################

TARGET_SN = 'DP8C204605012'

if not SN or SN != TARGET_SN:
    print( f"DP832 not found, expected SN {TARGET_SN}" )
    sys.exit()

# Activate the license by sending the command
license_keys = [
    "MAF2LD36AQUUQ2DQTLAPZS3TGKQT",  # LAN
    "MCF2L436AG8UPHZXTPADZ53TGKYT",  # Analyzer and Monitor
    "DDF2LKJ38GDVCLPRHPC2NUA6S7KT",  # Accuracy
    "MXFLLZ3LA43U484HTLANZP3TGKAT",  # Trigger
    "M2FLL43AA69UXMHNTLASZ73TGKET",  # RS232
]

# Install license keys generated for the specified USB device
for key in license_keys:
    inst.write(f":LIC:SET {key}") 
    time.sleep(2.0)
inst.close()

print('Done')
##########################################################
