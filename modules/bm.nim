{.compile: "timings.c".}
proc timing(a: cdouble): cint {.importc, varargs.}

var t:cint = 0
var track = 0
proc benchmark*() = 
    if track == 0:
        t = timing(0)
        inc(track)
    else:
        echo "\nExecution time:"
        echo (timing(0) - t)/1000
        dec(track)
    