import os
import sys
import json

from jinja2 import Environment, FileSystemLoader

# Args
arg1 = sys.argv[1] # Name
arg2 = sys.argv[2] # Config
arg3 = sys.argv[3] # vfid

# Dirs
root_dir = '/scratch/anubhav/Coyote/examples_hw/../'
build_dir = '/scratch/anubhav/Coyote/examples_hw/build_hw_8'
proj_dir = build_dir + '/test' + '_config_' + str(arg2) + '/user_c' + str(arg2) + '_' + str(arg3)
output_dir = proj_dir + '/hdl'

# Open
f = open(output_dir + '/vfpga_top.svh','r')
filedata = f.read()
f.close()

root, dirs, files = next(os.walk('/scratch/anubhav/Coyote/examples_hw/' + str(arg1) + '/hdl'), ([],[],[]))
for d in dirs:
    # Core hdl
    filedata = filedata.replace(d, d + '_c' + str(arg2) + '_' + str(arg3))

root, dirs, files = next(os.walk('/scratch/anubhav/Coyote/examples_hw/' + str(arg1) + '/hls'), ([],[],[]))
for d in dirs:
    # Core hls
    filedata = filedata.replace(d, d + '_c' + str(arg2) + '_' + str(arg3))

# Write and close
f = open(output_dir + '/vfpga_top.svh','w')
f.write(filedata)
f.close()
