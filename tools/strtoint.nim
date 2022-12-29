{.compile: "inc.c".}
proc StrInc(a: cstring): int {.importc, varargs}
proc Parsetoint(a: cstring): int {.importc, varargs}

proc PI*(x: string):int = 
    return Parsetoint(x)

proc Cinc*(n: string): string =
    return $StrInc(n)