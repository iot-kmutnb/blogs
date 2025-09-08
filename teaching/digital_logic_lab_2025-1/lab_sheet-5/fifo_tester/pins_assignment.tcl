#============================================================
# FPGA assignments
#============================================================

#set_global_assignment -name FAMILY "MAX 10 FPGA"
#set_global_assignment -name DEVICE 10M50DAF484C7G

#============================================================
# CLOCK
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLK
set_location_assignment PIN_P11 -to CLK

#============================================================
# PUSH BUTTONS
#============================================================

set_instance_assignment -name IO_STANDARD "3.3 V SCHMITT TRIGGER" -to RST_N
set_instance_assignment -name IO_STANDARD "3.3 V SCHMITT TRIGGER" -to TEST
set_location_assignment PIN_B8 -to RST_N
set_location_assignment PIN_A7 -to TEST

#============================================================
# LEDS
#============================================================

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FULL
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to EMPTY
set_location_assignment PIN_A8  -to FULL
set_location_assignment PIN_A9  -to EMPTY

#============================================================
# 7-Segment Display
#============================================================

foreach i {0 1 2 3 4 5 6 7} {
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[$i]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[$i]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[$i]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[$i]
}

set_location_assignment PIN_C14 -to HEX0[0]
set_location_assignment PIN_E15 -to HEX0[1]
set_location_assignment PIN_C15 -to HEX0[2]
set_location_assignment PIN_C16 -to HEX0[3]
set_location_assignment PIN_E16 -to HEX0[4]
set_location_assignment PIN_D17 -to HEX0[5]
set_location_assignment PIN_C17 -to HEX0[6]
set_location_assignment PIN_D15 -to HEX0[7]

set_location_assignment PIN_C18 -to HEX1[0]
set_location_assignment PIN_D18 -to HEX1[1]
set_location_assignment PIN_E18 -to HEX1[2]
set_location_assignment PIN_B16 -to HEX1[3]
set_location_assignment PIN_A17 -to HEX1[4]
set_location_assignment PIN_A18 -to HEX1[5]
set_location_assignment PIN_B17 -to HEX1[6]
set_location_assignment PIN_A16 -to HEX1[7]

set_location_assignment PIN_B20 -to HEX2[0]
set_location_assignment PIN_A20 -to HEX2[1]
set_location_assignment PIN_B19 -to HEX2[2]
set_location_assignment PIN_A21 -to HEX2[3]
set_location_assignment PIN_B21 -to HEX2[4]
set_location_assignment PIN_C22 -to HEX2[5]
set_location_assignment PIN_B22 -to HEX2[6]
set_location_assignment PIN_A19 -to HEX2[7]

set_location_assignment PIN_F21 -to HEX3[0]
set_location_assignment PIN_E22 -to HEX3[1]
set_location_assignment PIN_E21 -to HEX3[2]
set_location_assignment PIN_C19 -to HEX3[3]
set_location_assignment PIN_C20 -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_location_assignment PIN_E17 -to HEX3[6]
set_location_assignment PIN_D22 -to HEX3[7]


#============================================================
# Slide Switches
#============================================================

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PUT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to GET
set_location_assignment PIN_C10 -to PUT
set_location_assignment PIN_C11 -to GET

