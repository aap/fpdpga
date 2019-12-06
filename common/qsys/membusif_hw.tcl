# TCL File Generated by Component Editor 18.0
# Fri Oct 04 05:47:48 PDT 2019
# DO NOT MODIFY


# 
# membusif "membusif" v1.0
#  2019.10.04.05:47:48
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module membusif
# 
set_module_property DESCRIPTION ""
set_module_property NAME membusif
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME membusif
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL membusif
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file membusif.v VERILOG PATH ../membusif.v TOP_LEVEL_FILE


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

add_interface_port reset reset reset_n Input 1


# 
# connection point slave
# 
add_interface slave avalon end
set_interface_property slave addressUnits WORDS
set_interface_property slave associatedClock clock
set_interface_property slave associatedReset reset
set_interface_property slave bitsPerSymbol 8
set_interface_property slave burstOnBurstBoundariesOnly false
set_interface_property slave burstcountUnits WORDS
set_interface_property slave explicitAddressSpan 0
set_interface_property slave holdTime 0
set_interface_property slave linewrapBursts false
set_interface_property slave maximumPendingReadTransactions 0
set_interface_property slave maximumPendingWriteTransactions 0
set_interface_property slave readLatency 0
set_interface_property slave readWaitTime 1
set_interface_property slave setupTime 0
set_interface_property slave timingUnits Cycles
set_interface_property slave writeWaitTime 0
set_interface_property slave ENABLED true
set_interface_property slave EXPORT_OF ""
set_interface_property slave PORT_NAME_MAP ""
set_interface_property slave CMSIS_SVD_VARIABLES ""
set_interface_property slave SVD_ADDRESS_GROUP ""

add_interface_port slave s_address address Input 2
add_interface_port slave s_write write Input 1
add_interface_port slave s_read read Input 1
add_interface_port slave s_writedata writedata Input 32
add_interface_port slave s_readdata readdata Output 32
add_interface_port slave s_waitrequest waitrequest Output 1
set_interface_assignment slave embeddedsw.configuration.isFlash 0
set_interface_assignment slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment slave embeddedsw.configuration.isPrintableDevice 0


# 
# connection point membus_master
# 
add_interface membus_master conduit end
set_interface_property membus_master associatedClock clock
set_interface_property membus_master associatedReset reset
set_interface_property membus_master ENABLED true
set_interface_property membus_master EXPORT_OF ""
set_interface_property membus_master PORT_NAME_MAP ""
set_interface_property membus_master CMSIS_SVD_VARIABLES ""
set_interface_property membus_master SVD_ADDRESS_GROUP ""

add_interface_port membus_master m_rq_cyc rq_cyc Output 1
add_interface_port membus_master m_rd_rq rd_rq Output 1
add_interface_port membus_master m_wr_rq wr_rq Output 1
add_interface_port membus_master m_ma ma Output 15
add_interface_port membus_master m_sel sel Output 4
add_interface_port membus_master m_fmc_select fmc_select Output 1
add_interface_port membus_master m_mb_write mb_write Output 36
add_interface_port membus_master m_wr_rs wr_rs Output 1
add_interface_port membus_master m_mb_read mb_read Input 36
add_interface_port membus_master m_addr_ack addr_ack Input 1
add_interface_port membus_master m_rd_rs rd_rs Input 1
