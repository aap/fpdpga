# TCL File Generated by Component Editor 18.0
# Fri Oct 04 07:05:29 PDT 2019
# DO NOT MODIFY


# 
# memory_32k "memory_32k" v1.0
#  2019.10.04.07:05:29
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module memory_32k
# 
set_module_property DESCRIPTION ""
set_module_property NAME memory_32k
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME memory_32k
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL memory_32k
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file memory_32k.v VERILOG PATH ../memory_32k.v TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


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

add_interface_port clock i_clk clk Input 1


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

add_interface_port reset i_reset_n reset_n Input 1


# 
# connection point mem_slave
# 
add_interface mem_slave conduit end
set_interface_property mem_slave associatedClock clock
set_interface_property mem_slave associatedReset reset
set_interface_property mem_slave ENABLED true
set_interface_property mem_slave EXPORT_OF ""
set_interface_property mem_slave PORT_NAME_MAP ""
set_interface_property mem_slave CMSIS_SVD_VARIABLES ""
set_interface_property mem_slave SVD_ADDRESS_GROUP ""

add_interface_port mem_slave o_readdata readdata Output 36
add_interface_port mem_slave o_waitrequest waitrequest Output 1
add_interface_port mem_slave i_address address Input 18
add_interface_port mem_slave i_read read Input 1
add_interface_port mem_slave i_write write Input 1
add_interface_port mem_slave i_writedata writedata Input 36

