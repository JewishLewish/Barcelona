import ../main


proc actiontree2*(n: var seq[TokenTuple]): (seq[seq[TokenTuple]]) = #seperates EVERYTHING
    var collect = newSeq[TokenTuple]()
    var c: int = 0 #Looks at Right/Left Colons
    var ex2 = newSeq[seq[TokenTuple]]()
    for x in n:
        add(collect,x)
        if x.kind == TK_SEP:
            if c == 0:
                add(ex2, collect)
                collect = newSeq[TokenTuple]()
            else:
                continue
        
        if x.kind == TK_LSCOL:
            c = c + 1
        elif x.kind == TK_RSCOL:
            c = c - 1
            if c == 0:
                add(ex2, collect)
                collect = newSeq[TokenTuple]()

    return (ex2)
