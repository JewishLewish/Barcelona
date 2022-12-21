#Barcelona CMD Prompt
#
#
# Start Commands 
# _______________________
# barcelona, bar, b
#
#
#
# Options
# _______________________
# r / run -> Opens a barcelona coded file (or ending in .bar)
# t / translate <python/rust> -> Translates the barcelona file to a python or rust file 

import strutils
import main

while true:
    write(stdout, "This is the prompt -> ")
    let input = readLine(stdin).toLower.split(" ")


    if input[0] in ["b", "bar", "barcelona"]:
        if input[1] == "r" or input[1] == "run":
            echo " "
            main(input[2])
            echo " "
            break
    else:
        echo "Error."