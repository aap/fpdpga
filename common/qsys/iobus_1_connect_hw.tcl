package require -exact qsys 16.1


# 
# module iobus_1_connect
# 
set_module_property DESCRIPTION ""
set_module_property NAME iobus_1_connect
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME iobus_1_connect
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL iobus_1_connect
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file iobus_1_connect.v VERILOG PATH ../iobus_1_connect.v TOP_LEVEL_FILE

# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point iobus_slave0
# 
add_interface iobus_slave0 conduit end
set_interface_property iobus_slave0 associatedClock clock
set_interface_property iobus_slave0 associatedReset reset
set_interface_property iobus_slave0 ENABLED true
set_interface_property iobus_slave0 EXPORT_OF ""
set_interface_property iobus_slave0 PORT_NAME_MAP ""
set_interface_property iobus_slave0 CMSIS_SVD_VARIABLES ""
set_interface_property iobus_slave0 SVD_ADDRESS_GROUP ""

add_interface_port iobus_slave0 s0_iob_poweron iob_poweron Output 1
add_interface_port iobus_slave0 s0_iob_reset iob_reset Output 1
add_interface_port iobus_slave0 s0_datao_clear datao_clear Output 1
add_interface_port iobus_slave0 s0_datao_set datao_set Output 1
add_interface_port iobus_slave0 s0_cono_clear cono_clear Output 1
add_interface_port iobus_slave0 s0_cono_set cono_set Output 1
add_interface_port iobus_slave0 s0_iob_fm_datai iob_fm_datai Output 1
add_interface_port iobus_slave0 s0_iob_fm_status iob_fm_status Output 1
add_interface_port iobus_slave0 s0_rdi_pulse rdi_pulse Output 1
add_interface_port iobus_slave0 s0_ios ios Output 7
add_interface_port iobus_slave0 s0_iob_write iob_write Output 36
add_interface_port iobus_slave0 s0_pi_req pi_req Input 7
add_interface_port iobus_slave0 s0_iob_read iob_read Input 36
add_interface_port iobus_slave0 s0_dr_split dr_split Input 1
add_interface_port iobus_slave0 s0_rdi_data rdi_data Input 1


# 
# connection point iobus_master
# 
add_interface iobus_master conduit end
set_interface_property iobus_master associatedClock clock
set_interface_property iobus_master associatedReset reset
set_interface_property iobus_master ENABLED true
set_interface_property iobus_master EXPORT_OF ""
set_interface_property iobus_master PORT_NAME_MAP ""
set_interface_property iobus_master CMSIS_SVD_VARIABLES ""
set_interface_property iobus_master SVD_ADDRESS_GROUP ""

add_interface_port iobus_master m_iob_poweron iob_poweron Input 1
add_interface_port iobus_master m_iob_reset iob_reset Input 1
add_interface_port iobus_master m_datao_clear datao_clear Input 1
add_interface_port iobus_master m_datao_set datao_set Input 1
add_interface_port iobus_master m_cono_clear cono_clear Input 1
add_interface_port iobus_master m_cono_set cono_set Input 1
add_interface_port iobus_master m_iob_fm_datai iob_fm_datai Input 1
add_interface_port iobus_master m_iob_fm_status iob_fm_status Input 1
add_interface_port iobus_master m_rdi_pulse rdi_pulse Input 1
add_interface_port iobus_master m_ios ios Input 7
add_interface_port iobus_master m_iob_write iob_write Input 36
add_interface_port iobus_master m_pi_req pi_req Output 7
add_interface_port iobus_master m_iob_read iob_read Output 36
add_interface_port iobus_master m_dr_split dr_split Output 1
add_interface_port iobus_master m_rdi_data rdi_data Output 1


