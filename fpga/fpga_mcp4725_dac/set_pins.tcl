# set_global_assignment -name FAMILY "Cyclone IV E"
# set_global_assignment -name DEVICE EP4CE6E22C8

set_location_assignment PIN_86 -to NRESET
set_location_assignment PIN_23 -to CLK
set_location_assignment PIN_50 -to STATUS
set_location_assignment PIN_51 -to I2C_SDA
set_location_assignment PIN_52 -to I2C_SCL

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to NRESET
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to STATUS
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to I2C_SDA
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to I2C_SCL

