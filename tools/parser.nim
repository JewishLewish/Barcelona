import ../main

proc parser2*(n: var seq[TokenTuple]): array[0 .. 10,(string, seq[TokenTuple])] = 
    var c: int = 0 #Looks at Right/Left Colons

    var ar: array[0 .. 10,(string, seq[TokenTuple])]
    var i = -1
    var collect = newSeq[TokenTuple]()
    var ast: (string, seq[TokenTuple])

    for x in n:
        add(collect, x)
        if x.kind == TK_SEP:
            if c == 0:
                i = i + 1

                if collect[0].kind == TK_FUN:
                    ast = ("FUN", collect)
                elif collect[0].kind in [TK_IF, TK_WHILE, TK_LOOP]:
                    ast = ("COND", collect)
                elif collect[0].kind == TK_IDENTIFIER:
                    ast = ("ACT", collect)

                ar[i] = ast
                collect = newSeq[TokenTuple]()
            
        elif x.kind == TK_LSCOL:
            c = c + 1
        elif x.kind == TK_RSCOL:
            c = c - 1
            if c == 0:
                i = i + 1
                var ast = ("INPUT", collect)
                ar[i] = ast
                collect = newSeq[TokenTuple]()
    
    return ar