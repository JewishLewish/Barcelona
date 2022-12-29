from strutils import parseInt

{.compile: "inc.c".}
proc Incr(a: cstring): int {.importc, varargs}


proc PI*(n: string): int =
    return parseInt(n) 

proc Cinc*(n: string): int =
    var x: int = Incr(n)
    return x