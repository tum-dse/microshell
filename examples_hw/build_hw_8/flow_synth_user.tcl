if {[catch {
    
########################################################################################################

# Config
source "/scratch/anubhav/Coyote/examples_hw/build_hw_8/base.tcl"

# Synth user
source "$build_dir/synth_user.tcl"

puts ""
puts "[color $clr_cmplt "**"]"
puts "[color $clr_cmplt "** User synthesis completed"]"
puts "[color $clr_cmplt "**"]"
puts ""

########################################################################################################

} errorstring]} {
    puts "[color $clr_error "** CERR: $errorstring"]"
    puts "[color $clr_error "**"]"
    exit 1
}

exit 0
