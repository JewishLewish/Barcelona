{.deadCodeElim: on.}
import tables
import toktok
static:
    Program.settings(
        uppercase = true,
        prefix = "Tk_"
    )

tokens:
    Plus      > '+':
        Inc     ? '+'
    Minus     > '-':
        LArrow  ? '>'
    Greator   > '<':
        RArrow ? '-'
    Multi     > '*'
    Div       > '/'
    BLOCKCOMMENT   > '#' .. EOL
    LCol      > '('
    RCol      > ')'
    LBRA      > '['
    RBRA      > ']'
    Math      > '$'
    LSCol     > '{'
    RSCol     > '}'
    Sep       > ';'
    IMPORT    > "import"
    FUN       > "fn"
    IF        > "if"
    WHILE     > "while"
    LOOP      > "loop"
    GARBAGE   > "garbage"
    IMPORT    > "import"
    VAR       > "var"
    RETURN    > "return"
    Seperator > ','
    Assign    > '=':
        EQ      ? '='
    EX        > '!':
        EQN      ? '='
    BTrue     > @["TRUE", "True", "true", "YES", "Yes", "yes", "y"]
    BFalse    > @["FALSE", "False", "false", "NO", "No", "no", "n"]
    Dict      > "mother nature does it all for us."


type
  Variable* = object
    vname*: string # variable's holding value
    ty*: TokenKind # type of variable (String, Boolean, etc)

var Vars2* = initTable[string, Variable]()
var Fun = initTable[string, seq[TokenTuple]]()
var Dump* = initTable[string, seq[string]]() #Grabs certain variables from functionsthat would exist temporarily and prepares to dump them.
var ReCache: TokenTuple

import asyncdispatch

import tools/[tokparact, errors] #Action Tree
import tools/lcollect
import modules/dict
import modules/bm
import modules/requests
import modules/mathematics #Mathematics

from strutils import parseInt

iterator countTo(n: int): int =
  var i = 0
  while i <= n:
    yield i
    inc i

proc variable*(n: var seq[TokenTuple], start: int) = #This focuses on replacing variables with values. 
    var x: int = start - 1
    while x < len(n) - 1:
        inc(x)
        
        if n[x].kind == TK_MATH:
            var (b,i) = math(n, Vars2)
            n[x].kind = TK_INTEGER
            n[x].value = $b
            n[x+1 .. i] = []

        elif n[x].kind == TK_IDENTIFIER:
            n[x].kind = Vars2[n[x].value].ty
            n[x].value = Vars2[n[x].value].vname

            if n[x].kind == TK_DICT and n[x+1].kind == TK_LBRA:
                rd(n, x)
        
        elif n[x].kind == TK_INC:
            if n[x-1].kind == TK_INTEGER: 
                n[x-1].value = $(parseInt(n[x-1].value) + 1)
            
            n.delete(x)
            break
      
proc whi(n: var TokenTuple, det: var TokenTuple, n2: var TokenTuple): bool = 

    var x = n.value
    var x2 = n2.value

    if n.kind == TK_IDENTIFIER:
        x = Vars2[n.value].vname

    if n2.kind == TK_IDENTIFIER:
        x2 = Vars2[n2.value].vname

    if det.kind == TK_EQ:
        return x == x2

    elif det.kind == TK_EQN:
        return x != x2

proc action*(n: var seq[TokenTuple]) = 
    if n[0].kind == TK_IDENTIFIER:
        case n[0].value:
        of "echo":
            variable(n, 1)
            echo n[1].value
        
        of "record":
            record(n)
    
        of "delete":
            delete(n)
    
        of "fetch":
            fetch(n, 0)
            if n[1].kind == TK_LARROW and n[2].kind == TK_IDENTIFIER:
                Vars2[n[2].value] = Variable(vname: n[0].value, ty: n[0].kind)
    
        of "benchmark":
            benchmark()
    
        of "request", "status":
            request(n)
            Vars2[n[2].value] = Variable(vname: n[0].value, ty: n[0].kind)
        else:
            for ab in actiontree2(Fun[n[0].value]):
                var test = ab
                action(test) 
        
            let time = garbage(n[0]) #Async Garbage Disposal

            if n[1].kind == TK_LARROW and n[2].kind == TK_IDENTIFIER:
                Vars2[n[2].value] = Variable(vname: ReCache.value, ty: ReCache.kind)
            n.setLen(0)

            waitfor time


    else: #RESERVE KEYWORDS!
        case n[0].kind:
        of TK_VAR:
            if n[1].kind == TK_IDENTIFIER:
                if n[2].kind == TK_ASSIGN:
                    variable(n, 3)
                    Vars2[n[1].value] = Variable(vname: n[3].value, ty: n[3].kind)

            
        of TK_IF, TK_WHILE:
            if n[4].kind == TK_LSCOL:
                if n[2].kind == TK_EQ or n[2].kind == TK_EQN:
                    var ex2 = factorloop(n, 5)
                    if n[0].value == "if":
                        if whi(n[1], n[2], n[3]):
                            for test in ex2:
                                var test2 = test
                                action(test2)
                    else:
                        while whi(n[1], n[2], n[3]):
                            for test in ex2:
                                var e = test
                                action(e)
        
        of TK_LOOP:
            if n[1].kind == TK_INTEGER:
                var ex2 = factorloop(n, 3)
                for _ in countTo(parseInt(n[1].value) - 1):
                    for test in ex2:
                        var temp = test
                        action(temp)
        
        of TK_GARBAGE:
            Vars2.del(n[1].value)
        
        of TK_FUN:
            var
                FunV = newSeq[TokenTuple]() #-> Collects
                FunN: string #-> Identifies
                i: int = -1
                c: int = 0 #Looks at Right/Left Colons
                Garbage = newSeq[string]()

            while i < len(n) - 1:
                inc(i)
                if n[i].kind == TK_FUN:
                    if n[i+1].kind == TK_IDENTIFIER:
                        if c == 0:
                            FunN = n[i+1].value
                        else:
                            er(n[i], "You cannot define functions inside of functions.")
                elif n[i].kind == TK_LSCOL:
                    inc(c)
                    add(FunV, n[i])
                elif n[i].kind == TK_RSCOL:
                    dec(c)
                    add(FunV, n[i])
                    if c == 0:
                        Fun[FunN] = FunV
                        Dump[FunN] = Garbage
                        FunN = ""
                        FunV.setLen(0)
                        Garbage.setLen(0)
                elif n[i].kind == TK_STRING and n[i+1].kind == TK_STRING:
                    n[i].value = n[i].value & n[i+1].value
                    n.delete(i+1)
                    add(FunV, n[i])

                elif n[i].kind == TK_VAR:
                    if Vars2.haskey(n[i+1].value):
                        er(n[i], "You cannot edit variables inside of functions.")
                        break
                    else:
                        add(FunV, n[i])
                        add(Garbage, n[i+1].value)    
                elif n[i].kind == TK_GARBAGE:
                    warning(n[i], "Garbage syntax isn't required for functions")

                else:
                    add(FunV, n[i])

            if c != 0:
                er(n[i], "Failed to properly define a function.")
    
        of TK_RETURN:
            ReCache = n[1]
        
        else:
            echo n

proc main*(n: string) =

    var ac = newSeq[TokenTuple]()
    var lex = Lexer.init(fileContents = readFile(n))

    if lex.hasError:
        echo lex.getError
    else:
        while true:
            let curr = lex.getToken()
            
            if curr.kind == TK_EOF: 
                add(ac, curr)
                break
            elif curr.kind == TK_BLOCKCOMMENT:
                continue
            else:
                add(ac, curr) # tuple[kind: TokenKind, value: string, wsno: col, line: int]
    
    if declared(lex.addr):dealloc(lex.addr)


    var c: int = 0 #Looks at Right/Left Colons
    var collect = newSeq[TokenTuple]()
    for x in ac:
        add(collect, x)
        case x.kind:
        of TK_SEP, TK_RSCOL:
            if x.kind == TK_RSCOL:
                dec(c)
            
            if c == 0:
                action(collect)
                collect.setLen(0)
        of TK_LSCOL:
            inc(c)
        else:
            continue

    Vars2 = initTable[string, Variable]() #Dumps all variables at end of code to preserve memory.
    Fun = initTable[string, seq[TokenTuple]]() #Dumps all functions at end of code to preserve memory.
    Dump = initTable[string, seq[string]]() #Dumps Fuctions's variables. 