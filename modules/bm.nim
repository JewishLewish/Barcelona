from std/times import cpuTime

var time: float = 0
var track = 0
proc benchmark*() = 
    if track == 0:
        time = cpuTime()
        track = 1
    else:
        echo "\nExecution time:"
        echo cpuTime() - time
        track = 0
    