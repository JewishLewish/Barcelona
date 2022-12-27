import ../main

proc actiontree2*(target: var seq[TokenTuple]): (seq[seq[TokenTuple]]) = #seperates EVERYTHING
    var collect = newSeq[TokenTuple]()
    var c: int = 0 #Looks at Right/Left Colons
    var ex2 = newSeq[seq[TokenTuple]]()
    for x in target[2 .. ^1]:
        add(collect,x)
        if x.kind == TK_SEP or x.kind == TK_RSCOL:
            if x.kind == TK_RSCOL:
                dec(c)
            if c == 0:
                add(ex2, collect)
                collect.setLen(0)
            else:
                continue
        
        elif x.kind == TK_LSCOL:
            inc(c)


    return (ex2)
