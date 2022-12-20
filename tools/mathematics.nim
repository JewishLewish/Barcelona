import ../main

import mathexpr
let e = newEvaluator()

proc math*(n: var seq[TokenTuple]): (int, int) = 
    var expression = ""
    var i = 0
    var c = 0
    var track = 0
    
    for x in n:
        if track == 1:
            i = i + 1
            if x.kind == TK_INTEGER:
                add(expression, x.value)
            elif x.kind == TK_PLUS:
                add(expression, "+")
            elif x.kind == TK_LCOL:
                add(expression, "(")
            elif x.kind == TK_RCOL:
                add(expression, ")")


        if x.kind == TK_MATH:
            track = 1
        elif x.kind == TK_LCOL:
            c = c + 1
        elif x.kind == TK_RCOL:
            c = c - 1
            if c == 0:
                track = 0

    return (e.eval(expression).int, i)