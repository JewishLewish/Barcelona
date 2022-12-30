import ../main
import tables
import mathexpr
let e = newEvaluator()

{.compile: "math.c".}
proc evaluate(a: cstring): int {.importc.}

proc math*(n: seq[TokenTuple], Vars2: Table[string, Variable]): (int, int) = 
    var expression:string = ""
    var i = 0
    var c:int8 = 0
    var track = 0
    
    for x in n:
        if track == 1:
            inc(i)
            if x.kind == TK_INTEGER:
                add(expression, x.value)
            elif x.kind == TK_PLUS:
                add(expression, "+")
            elif x.kind == TK_LCOL:
                add(expression, "(")
                inc(c)
            elif x.kind == TK_RCOL:
                add(expression, ")")
                dec(c)
                if c == 0:
                    dec(track)
                    break

            elif x.kind == TK_IDENTIFIER:
                add(expression, Vars2[x.value].vname)

        elif x.kind == TK_MATH:
            inc(track)

    return (e.eval(expression).int, i)