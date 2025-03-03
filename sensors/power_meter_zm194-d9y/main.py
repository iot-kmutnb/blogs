import tkinter as tk
from tkinter import ttk
import minimalmodbus

print( f"Minimalmodbus version: {minimalmodbus.__version__}" )

# Serial port settings
default_dev_addr = 1
default_port_name = '/dev/ttyUSB0'
default_baudrate = 9600
FUNC_CODE = 0x03

params = [
    {"reg_addr": 0x0000, "name": "Ua", "unit": "V"},
    {"reg_addr": 0x0002, "name": "Ub", "unit": "V"},
    {"reg_addr": 0x0004, "name": "Uc", "unit": "V"},
    {"reg_addr": 0x000C, "name": "Ia", "unit": "A"},
    {"reg_addr": 0x000E, "name": "Ib", "unit": "A"},
    {"reg_addr": 0x0010, "name": "Ic", "unit": "A"},
    {"reg_addr": 0x0022, "name": "PFa", "unit": "-"},
    {"reg_addr": 0x0024, "name": "PFb", "unit": "-"},
    {"reg_addr": 0x0026, "name": "PFc", "unit": "-"},
    {"reg_addr": 0x0018, "name": "P", "unit": "kW"},
    {"reg_addr": 0x0020, "name": "Q", "unit": "kVAR"},
    {"reg_addr": 0x0030, "name": "S", "unit": "kVA"},
    {"reg_addr": 0x0032, "name": "Freq", "unit": "Hz"},
]

class PowerMeterGUI:
    def __init__(self, root):
        self.device = None
        self.connected = False

        self.root = root
        self.root.title("3-Phase Power Meter")
        self.root.geometry("500x600")
        self.root.configure(bg='white')      
        
        # Input fields
        self.frame_top = ttk.Frame(root)
        self.frame_top.pack(pady=10)
        
        ttk.Label(self.frame_top, text="Device ID:").grid(
            row=0, column=0, padx=5, pady=8)
        self.dev_id_entry = ttk.Entry(self.frame_top, width=4,justify="right")
        self.dev_id_entry.grid(row=0, column=1, padx=5, pady=2)
        self.dev_id_entry.insert(0, str(default_dev_addr))
        
        ttk.Label(self.frame_top, text="Port:").grid(
            row=0, column=2, padx=5, pady=8)
        self.port_entry = ttk.Entry(self.frame_top, width=12, justify="right")
        self.port_entry.grid(row=0, column=3, padx=5, pady=2)
        self.port_entry.insert(0, default_port_name)
        
        ttk.Label(self.frame_top, text="Baudrate:").grid(
            row=0, column=4, padx=5, pady=8)
        self.baudrate_entry = ttk.Entry(self.frame_top, width=7, justify="right")
        self.baudrate_entry.grid(row=0, column=5, padx=5, pady=8)
        self.baudrate_entry.insert(0, str(default_baudrate))
        
        # Labels and values frame
        self.frame_values = ttk.Frame(root)
        self.frame_values.pack(pady=10)
        
        self.labels = {}
        self.values = {}
        for i, param in enumerate(params):
            ttk.Label(self.frame_values, text=f"{param['name']}:", 
                      font=("Arial", 12, "bold")).grid(row=i, column=0, padx=10, pady=5, sticky="w")
            value_label = ttk.Label(self.frame_values, text="---", 
                      font=("Arial", 12), width=10, anchor="e", relief=tk.SUNKEN)
            value_label.grid(row=i, column=1, padx=5, pady=5, sticky="e")
            unit_label = ttk.Label(self.frame_values, text=param['unit'], 
                      font=("Arial", 12))
            unit_label.grid(row=i, column=2, padx=5, pady=5, sticky="w")
            self.labels[param['name']] = param['name']
            self.values[param['name']] = value_label
        
        # Buttons frame
        self.frame_buttons = ttk.Frame(root)
        self.frame_buttons.pack(padx=14, pady=20)

        self.connect_button = ttk.Button(self.frame_buttons, text="Connect", 
                                         command=self.toggle_connection)
        self.connect_button.grid(row=0, column=0, padx=14, pady=8)
                        
        self.exit_button = ttk.Button(self.frame_buttons, text="Exit", 
                                      command=root.quit)
        self.exit_button.grid(row=0, column=1, padx=14, pady=8) 

    def toggle_connection(self):
        if self.connected:
            self.device = None
            self.connect_button.config(text="Connect")
            self.connected = False
        else:
            dev_addr = int(self.dev_id_entry.get())
            port = self.port_entry.get()
            baudrate = int(self.baudrate_entry.get())
            
            try:
                self.device = minimalmodbus.Instrument(port, dev_addr, debug=False)
                self.device.serial.baudrate = baudrate
                self.device.serial.bytesize = 8
                self.device.serial.parity = minimalmodbus.serial.PARITY_NONE
                self.device.mode = minimalmodbus.MODE_RTU
                self.device.serial.stopbits = 1
                self.device.serial.timeout = 0.1
                self.connect_button.config(text="Disconnect")
                self.connected = True
                self.update_values()
            except Exception as e:
                print("Connection failed:", e)
    
    def update_values(self):
        if not self.connected or self.device is None:
            return
        try:
            for param in params:
                value = self.device.read_long(registeraddress=param["reg_addr"], 
                                              functioncode=FUNC_CODE)
                value = value / 1000.0
                self.values[param["name"]].config(text=f"{value:.3f}")
        except IOError:
            print("Failed to read from the device!")
        self.root.after(1000, self.update_values)

if __name__ == "__main__":
    root = tk.Tk()
    app = PowerMeterGUI(root)
    root.mainloop()
