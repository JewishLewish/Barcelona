from strutils import parseInt

{.compile: "inc.c".}
proc StrInc(a: cstring): int {.importc, varargs}


proc PI*(n: string): int =
    return parseInt(n) 

proc Cinc*(n: string): string =
    return $StrInc(n)