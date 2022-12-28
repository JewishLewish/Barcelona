import ../main
import asyncdispatch
import tables

proc factorloop*(n: seq[TokenTuple], start: int8): (seq[seq[TokenTuple]]) =
    var ex = newSeq[TokenTuple]() #This collects the appropriate data
    var ex2 = newSeq[seq[TokenTuple]]()
    for x in n[start .. ^1]:
        if x.kind == TK_SEP:
            add(ex2, ex)
            ex.setLen(0)
        else:
            add(ex, x)
    
    return ex2


proc garbage*(n: TokenTuple) {.async.} = #Garbage is Async. 
    for x in Dump[n.value]:
        Vars2.del(x)