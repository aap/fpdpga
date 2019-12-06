package require -exact qsys 16.1


# 
# module iobus_6_connect
# 
set_module_property DESCRIPTION ""
set_module_property NAME iobus_6_connect
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME iobus_6_connect
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL iobus_6_connect
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file iobus_6_connect.v VERILOG PATH ../iobus_6_connect.v TOP_LEVEL_FILE

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
# connection point iobus_slave1
# 
add_interface iobus_slave1 conduit end
set_interface_property iobus_slave1 associatedClock clock
set_interface_property iobus_slave1 associatedReset reset
set_interface_property iobus_slave1 ENABLED true
set_interface_property iobus_slave1 EXPORT_OF ""
set_interface_property iobus_slave1 PORT_NAME_MAP ""
set_interface_property iobus_slave1 CMSIS_SVD_VARIABLES ""
set_interface_property iobus_slave1 SVD_ADDRESS_GROUP ""

add_interface_port iobus_slave1 s1_iob_poweron iob_poweron Output 1
add_interface_port iobus_slave1 s1_iob_reset iob_reset Output 1
add_interface_port iobus_slave1 s1_datao_clear datao_clear Output 1
add_interface_port iobus_slave1 s1_datao_set datao_set Output 1
add_interface_port iobus_slave1 s1_cono_clear cono_clear Output 1
add_interface_port iobus_slave1 s1_cono_set cono_set Output 1
add_interface_port iobus_slave1 s1_iob_fm_datai iob_fm_datai Output 1
add_interface_port iobus_slave1 s1_iob_fm_status iob_fm_status Output 1
add_interface_port iobus_slave1 s1_rdi_pulse rdi_pulse Output 1
add_interface_port iobus_slave1 s1_ios ios Output 7
add_interface_port iobus_slave1 s1_iob_write iob_write Output 36
add_interface_port iobus_slave1 s1_pi_req pi_req Input 7
add_interface_port iobus_slave1 s1_iob_read iob_read Input 36
add_interface_port iobus_slave1 s1_dr_split dr_split Input 1
add_interface_port iobus_slave1 s1_rdi_data rdi_data Input 1


# 
# connection point iobus_slave2
# 
add_interface iobus_slave2 conduit end
set_interface_property iobus_slave2 associatedClock clock
set_interface_property iobus_slave2 associatedReset reset
set_interface_property iobus_slave2 ENABLED true
set_interface_property iobus_slave2 EXPORT_OF ""
set_interface_property iobus_slave2 PORT_NAME_MAP ""
set_interface_property iobus_slave2 CMSIS_SVD_VARIABLES ""
set_interface_property iobus_slave2 SVD_ADDRESS_GROUP ""

add_interface_port iobus_slave2 s2_iob_poweron iob_poweron Output 1
add_interface_port iobus_slave2 s2_iob_reset iob_reset Output 1
add_interface_port iobus_slave2 s2_datao_clear datao_clear Output 1
add_interface_port iobus_slave2 s2_datao_set datao_set Output 1
add_interface_port iobus_slave2 s2_cono_clear cono_clear Output 1
add_interface_port iobus_slave2 s2_cono_set cono_set Output 1
add_interface_port iobus_slave2 s2_iob_fm_datai iob_fm_datai Output 1
add_interface_port iobus_slave2 s2_iob_fm_status iob_fm_status Output 1
add_interface_port iobus_slave2 s2_rdi_pulse rdi_pulse Output 1
add_interface_port iobus_slave2 s2_ios ios Output 7
add_interface_port iobus_slave2 s2_iob_write iob_write Output 36
add_interface_port iobus_slave2 s2_pi_req pi_req Input 7
add_interface_port iobus_slave2 s2_iob_read iob_read Input 36
add_interface_port iobus_slave2 s2_dr_split dr_split Input 1
add_interface_port iobus_slave2 s2_rdi_data rdi_data Input 1


# 
# connection point iobus_slave3
# 
add_interface iobus_slave3 conduit end
set_interface_property iobus_slave3 associatedClock clock
set_interface_property iobus_slave3 associatedReset reset
set_interface_property iobus_slave3 ENABLED true
set_interface_property iobus_slave3 EXPORT_OF ""
set_interface_property iobus_slave3 PORT_NAME_MAP ""
set_interface_property iobus_slave3 CMSIS_SVD_VARIABLES ""
set_interface_property iobus_slave3 SVD_ADDRESS_GROUP ""

add_interface_port iobus_slave3 s3_iob_poweron iob_poweron Output 1
add_interface_port iobus_slave3 s3_iob_reset iob_reset Output 1
add_interface_port iobus_slave3 s3_datao_clear datao_clear Output 1
add_interface_port iobus_slave3 s3_datao_set datao_set Output 1
add_interface_port iobus_slave3 s3_cono_clear cono_clear Output 1
add_interface_port iobus_slave3 s3_cono_set cono_set Output 1
add_interface_port iobus_slave3 s3_iob_fm_datai iob_fm_datai Output 1
add_interface_port iobus_slave3 s3_iob_fm_status iob_fm_status Output 1
add_interface_port iobus_slave3 s3_rdi_pulse rdi_pulse Output 1
add_interface_port iobus_slave3 s3_ios ios Output 7
add_interface_port iobus_slave3 s3_iob_write iob_write Output 36
add_interface_port iobus_slave3 s3_pi_req pi_req Input 7
add_interface_port iobus_slave3 s3_iob_read iob_read Input 36
add_interface_port iobus_slave3 s3_dr_split dr_split Input 1
add_interface_port iobus_slave3 s3_rdi_data rdi_data Input 1


# 
# connection point iobus_slave4
# 
add_interface iobus_slave4 conduit end
set_interface_property iobus_slave4 associatedClock clock
set_interface_property iobus_slave4 associatedReset reset
set_interface_property iobus_slave4 ENABLED true
set_interface_property iobus_slave4 EXPORT_OF ""
set_interface_property iobus_slave4 PORT_NAME_MAP ""
set_interface_property iobus_slave4 CMSIS_SVD_VARIABLES ""
set_interface_property iobus_slave4 SVD_ADDRESS_GROUP ""

add_interface_port iobus_slave4 s4_iob_poweron iob_poweron Output 1
add_interface_port iobus_slave4 s4_iob_reset iob_reset Output 1
add_interface_port iobus_slave4 s4_datao_clear datao_clear Output 1
add_interface_port iobus_slave4 s4_datao_set datao_set Output 1
add_interface_port iobus_slave4 s4_cono_clear cono_clear Output 1
add_interface_port iobus_slave4 s4_cono_set cono_set Output 1
add_interface_port iobus_slave4 s4_iob_fm_datai iob_fm_datai Output 1
add_interface_port iobus_slave4 s4_iob_fm_status iob_fm_status Output 1
add_interface_port iobus_slave4 s4_rdi_pulse rdi_pulse Output 1
add_interface_port iobus_slave4 s4_ios ios Output 7
add_interface_port iobus_slave4 s4_iob_write iob_write Output 36
add_interface_port iobus_slave4 s4_pi_req pi_req Input 7
add_interface_port iobus_slave4 s4_iob_read iob_read Input 36
add_interface_port iobus_slave4 s4_dr_split dr_split Input 1
add_interface_port iobus_slave4 s4_rdi_data rdi_data Input 1


# 
# connection point iobus_slave5
# 
add_interface iobus_slave5 conduit end
set_interface_property iobus_slave5 associatedClock clock
set_interface_property iobus_slave5 associatedReset reset
set_interface_property iobus_slave5 ENABLED true
set_interface_property iobus_slave5 EXPORT_OF ""
set_interface_property iobus_slave5 PORT_NAME_MAP ""
set_interface_property iobus_slave5 CMSIS_SVD_VARIABLES ""
set_interface_property iobus_slave5 SVD_ADDRESS_GROUP ""

add_interface_port iobus_slave5 s5_iob_poweron iob_poweron Output 1
add_interface_port iobus_slave5 s5_iob_reset iob_reset Output 1
add_interface_port iobus_slave5 s5_datao_clear datao_clear Output 1
add_interface_port iobus_slave5 s5_datao_set datao_set Output 1
add_interface_port iobus_slave5 s5_cono_clear cono_clear Output 1
add_interface_port iobus_slave5 s5_cono_set cono_set Output 1
add_interface_port iobus_slave5 s5_iob_fm_datai iob_fm_datai Output 1
add_interface_port iobus_slave5 s5_iob_fm_status iob_fm_status Output 1
add_interface_port iobus_slave5 s5_rdi_pulse rdi_pulse Output 1
add_interface_port iobus_slave5 s5_ios ios Output 7
add_interface_port iobus_slave5 s5_iob_write iob_write Output 36
add_interface_port iobus_slave5 s5_pi_req pi_req Input 7
add_interface_port iobus_slave5 s5_iob_read iob_read Input 36
add_interface_port iobus_slave5 s5_dr_split dr_split Input 1
add_interface_port iobus_slave5 s5_rdi_data rdi_data Input 1


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


