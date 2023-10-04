# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param project.vivado.isBlockSynthRun true
set_msg_config -msgmgr_mode ooc_run
create_project -in_memory -part xc7a100tcsg324-3

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.cache/wt [current_project]
set_property parent.project_path E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.xpr [current_project]
set_property XPM_LIBRARIES XPM_CDC [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo e:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_ip -quiet E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xci
set_property used_in_implementation false [get_files -all e:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk_board.xdc]
set_property used_in_implementation false [get_files -all e:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xdc]
set_property used_in_implementation false [get_files -all e:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1

set cached_ip [config_ip_cache -export -no_bom  -dir E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1 -new_name sys_clk -ip [get_ips sys_clk]]

if { $cached_ip eq {} } {
close [open __synthesis_is_running__ w]

synth_design -top sys_clk -part xc7a100tcsg324-3 -mode out_of_context

#---------------------------------------------------------
# Generate Checkpoint/Stub/Simulation Files For IP Cache
#---------------------------------------------------------
# disable binary constraint mode for IPCache checkpoints
set_param constraints.enableBinaryConstraints false

catch {
 write_checkpoint -force -noxdef -rename_prefix sys_clk_ sys_clk.dcp

 set ipCachedFiles {}
 write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ sys_clk_stub.v
 lappend ipCachedFiles sys_clk_stub.v

 write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ sys_clk_stub.vhdl
 lappend ipCachedFiles sys_clk_stub.vhdl

 write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ sys_clk_sim_netlist.v
 lappend ipCachedFiles sys_clk_sim_netlist.v

 write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ sys_clk_sim_netlist.vhdl
 lappend ipCachedFiles sys_clk_sim_netlist.vhdl
set TIME_taken [expr [clock seconds] - $TIME_start]

 config_ip_cache -add -dcp sys_clk.dcp -move_files $ipCachedFiles -use_project_ipc  -synth_runtime $TIME_taken  -ip [get_ips sys_clk]
}

rename_ref -prefix_all sys_clk_

# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef sys_clk.dcp
create_report "sys_clk_synth_1_synth_report_utilization_0" "report_utilization -file sys_clk_utilization_synth.rpt -pb sys_clk_utilization_synth.pb"

if { [catch {
  write_verilog -force -mode synth_stub E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode synth_stub E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_verilog -force -mode funcsim E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_sim_netlist.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode funcsim E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_sim_netlist.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}


} else {


}; # end if cached_ip 

add_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_stub.v -of_objects [get_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xci]

add_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_stub.vhdl -of_objects [get_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xci]

add_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_sim_netlist.v -of_objects [get_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xci]

add_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_sim_netlist.vhdl -of_objects [get_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xci]

add_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk.dcp -of_objects [get_files E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xci]

if {[file isdir E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.ip_user_files/ip/sys_clk]} {
  catch { 
    file copy -force E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_sim_netlist.v E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.ip_user_files/ip/sys_clk
  }
}

if {[file isdir E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.ip_user_files/ip/sys_clk]} {
  catch { 
    file copy -force E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_sim_netlist.vhdl E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.ip_user_files/ip/sys_clk
  }
}

if {[file isdir E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.ip_user_files/ip/sys_clk]} {
  catch { 
    file copy -force E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_stub.v E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.ip_user_files/ip/sys_clk
  }
}

if {[file isdir E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.ip_user_files/ip/sys_clk]} {
  catch { 
    file copy -force E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_stub.vhdl E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.ip_user_files/ip/sys_clk
  }
}
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
