if {[catch {
    
########################################################################################################

unset ::env(PYTHONPATH)
unset ::env(PYTHONHOME)

# Config
source "/scratch/anubhav/Coyote/examples_hw/build_hw_8/base.tcl"

# Create user
source "$build_dir/cr_user.tcl"

########################################################################################################
# Projects created
########################################################################################################
puts ""
puts "[color $clr_cmplt "**"]"
puts "[color $clr_cmplt "** App project creation flow completed"]"
puts "[color $clr_cmplt "**"]"
puts ""

########################################################################################################

} errorstring]} {
    puts "[color $clr_error "** CERR: $errorstring"]"
    puts "[color $clr_error "**"]"
    exit 1
}

exit 0
