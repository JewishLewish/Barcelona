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



include main
main("main.bar")

#let x = stdin "->"
#let input = readLine(stdin).toLower.split(" ")
#
#
#if input[0] != "b" or input[0] != "bar" or input[0] != "barcelona":
#    echo "ERROR: CMD is not detected. Use 'b' or 'bar' or 'barcelona' at the beginning of the cmd prompt."
#else:
#    if input[1] == "r" or input[1] == "run":
#        let file : TaintedString = input[2]
#        main("main.bar")