if {[catch {
    
########################################################################################################
# Config
source "/scratch/anubhav/Coyote/examples_hw/build_hw_8/base.tcl"

if {$cfg(load_apps) eq 1} {
    puts "[color $clr_flow "** HLS compilation ..."]"
    puts "[color $clr_flow "**"]"

    # Applications:
    set vfpga_c0_0 apps/fft


    for {set i 0} {$i < $cfg(n_config)} {incr i} {
        for {set j 0} {$j < $cfg(n_reg)} {incr j} {

            set tmp_val "[format "\$vfpga_c$i\_$j"]" 
            set tmp_path "[format "%s" $tmp_val]"
            set cmd "[format "set tmp_path $tmp_path"]"
            eval $cmd

            # Compile all hls cores
            if {[file isdirectory "/scratch/anubhav/Coyote/examples_hw/$tmp_path/hls"]} {
                set krnls [glob -nocomplain -tails -directory "/scratch/anubhav/Coyote/examples_hw/$tmp_path/hls" -type d *]

                foreach krnl $krnls {
                    # Copy all files
                    file mkdir "$build_dir/$project\_config_$i/user\_c$i\_$j/hdl/ext/$krnl\_hls"
                    set files_hdl [glob -nocomplain "/scratch/anubhav/Coyote/examples_hw/$tmp_path/hls/$krnl/*.hpp" "/scratch/anubhav/Coyote/examples_hw/$tmp_path/hls/$krnl/*.cpp"]
                    if {[llength $files_hdl]} {
                        file copy -force {*}$files_hdl "$build_dir/$project\_config_$i/user\_c$i\_$j/hdl/ext/$krnl\_hls"
                    }

                    # Create project
                    cd $build_dir/$project\_config_$i/user\_c$i\_$j/hdl/ext/$krnl\_hls
                    open_project "$krnl\_c$i\_$j"
                    open_solution "solution1"
                    set_part xcu280-fsvh2892-2L-e
                    
                    if {$cfg(en_uclk) eq 1} {
                        create_clock -period "$cfg(uclk_p)" -name default
                    } else {
                        create_clock -period "$cfg(aclk_p)" -name default
                    }

                    # Add files
                    set_top "$krnl"
                    add_files "$build_dir/$project\_config_$i/user\_c$i\_$j/hdl/ext/$krnl\_hls/$krnl.cpp" -cflags "-std=c++11 -I $build_dir/$project\_config_$i/user\_c$i\_$j/hdl/ext/$krnl\_hls"

                    # Synth
                    csynth_design

                    # Sim (Uncomment for simulation)
                    # csim_design

                    # Export IP
                    export_design -format ip_catalog -ipname "$krnl\_c$i\_$j" -display_name "$krnl\_c$i\_$j" -description "" -vendor "user.org" -version "1.0"

                    file mkdir /scratch/anubhav/Coyote/examples_hw/build_hw_8/iprepo
                    file delete -force /scratch/anubhav/Coyote/examples_hw/build_hw_8/iprepo/$krnl\_c$i\_$j
                    file copy -force $krnl\_c$i\_$j/solution1/impl/ip /scratch/anubhav/Coyote/examples_hw/build_hw_8/iprepo/$krnl\_c$i\_$j/
                }
            }
        }
    }
}

########################################################################################################

} errorstring]} {
    puts "[color $clr_error "** CERR: $errorstring"]"
    puts "[color $clr_error "**"]"
    exit 1
}

exit 0
