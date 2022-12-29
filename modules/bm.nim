from std/times import cpuTime
import asyncdispatch

var time: float = 0
var track:int8 = 0
proc benchmark*() {.async.}= 
    if track == 0:
        time = cpuTime()
        track = 1
    else:
        echo "\nExecution time:"
        echo cpuTime() - time
        track = 0
    