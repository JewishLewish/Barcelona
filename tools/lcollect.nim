import ../main

proc factorloop*(n: var seq[TokenTuple], start: int): (seq[seq[TokenTuple]]) =
    var ex = newSeq[TokenTuple]() #This collects the appropriate data
    var ex2 = newSeq[seq[TokenTuple]]()
    for x in n[start .. ^1]:
        if x.kind == TK_SEP:
            add(ex2, ex)
            ex.setLen(0)
        else:
            add(ex, x)
    
    return ex2