import ../main
import tables


proc actiontree2*(n: var seq[TokenTuple]): (Table[system.int, seq[TokenTuple]], int) = #seperates EVERYTHING
    var collect = newSeq[TokenTuple]()
    var c = 0 #Looks at Right/Left Colons
    var i = 0
    var body = initTable[int, seq[TokenTuple]]()
    for x in n:
        add(collect,x)
        if x.kind == TK_SEP:
            if c == 0:
                body[i] = collect
                collect = newSeq[TokenTuple]()
                i = i + 1
            else:
                continue
        
        if x.kind == TK_LSCOL:
            c = c + 1
        elif x.kind == TK_RSCOL:
            c = c - 1
            if c == 0:
                body[i] = collect
                collect = newSeq[TokenTuple]()
                i = i + 1

    return (body, i)
