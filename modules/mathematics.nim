import ../main
import tables
import mathexpr
let e = newEvaluator()

proc math*(n: var seq[TokenTuple], Vars2: Table[string, Variable]): (int, int) = 
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
                c = c + 1
            elif x.kind == TK_RCOL:
                add(expression, ")")
                c = c - 1
                if c == 0:
                    track = 0
                    break

            elif x.kind == TK_IDENTIFIER:
                add(expression, Vars2[x.value].vname)

        elif x.kind == TK_MATH:
            track = 1

    
    return (e.eval(expression).int, i)