import tables
import toktok
static:
    Program.settings(
        uppercase = true,
        prefix = "Tk_"
    )

tokens:
    Plus      > '+'
    Minus     > '-':
        LArrow  ? '>'
    Greator   > '<':
        RArrow ? '-'
    Multi     > '*'
    Div       > '/':
        BlockComment ? '*' .. "*/"
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
    Assign    > '=':
        EQ      ? '='
    EX        > '!':
        EQN      ? '='
    BTrue     > @["TRUE", "True", "true", "YES", "Yes", "yes", "y"]
    BFalse    > @["FALSE", "False", "false", "NO", "No", "no", "n"]
    Dict      > "mother nature does it all for us."

type
  Variable* = object
    name*: string  # variable's itself value
    vname*: string # variable's holding value
    ty*: TokenKind # type of variable (String, Boolean, etc)

var Vars2* = initTable[string, Variable]()
var Fun = initTable[string, seq[TokenTuple]]()
import developertools/vardefine #This is for Variables and defining them

import tools/[tokparact] #Action Tree
import tools/errors #Errors
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

proc variable*(n: var seq[TokenTuple]) = #This focuses on replacing variables with values. 
    var x: int = 0
    while x < len(n) - 1:
        x = x + 1

        if n[x].value == "fetch":
            if n[x+1].kind == TK_LCOL and n[x+3].kind == TK_RCOL:
                fetch(n, x)
        
        elif n[x].kind == TK_MATH:
            var (b,i) = math(n, Vars2)
            n[x].kind = TK_INTEGER
            n[x].value = $b
            for range in (x .. i):
                n.delete(x+1)
        
        elif n[x].kind == TK_IDENTIFIER:
            n[x].kind = Vars2[n[x].value].ty
            n[x].value = Vars2[n[x].value].vname

            if n[x].kind == TK_DICT and n[x+1].kind == TK_LBRA:
                rd(n, x)

            
      
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
    if n[0].value == "echo":
        variable(n)
        echo n[1].value

    elif n[0].value == "var":
        if n[1].kind == TK_IDENTIFIER:
            if n[2].kind == TK_ASSIGN:
                var x = n[2 .. ^1]
                variable(x)
                n[2 .. ^1] = x

                Vars2[n[1].value] = Variable(name: n[1].value, vname: n[3].value, ty: n[3].kind)

    elif n[0].value == "if":
        if n[4].kind == TK_LSCOL:
            if n[2].kind == TK_EQ or n[2].kind == TK_EQN:
                if whi(n[1], n[2], n[3]):
                    var execute = n[0 .. ^1] #This grabs the appropriate Data
                    var x = 4
                    let y = len(execute) - 1
                    var ex = newSeq[TokenTuple]() #This collects the appropriate data

                    while x < y:
                        x = x + 1
                        if execute[x].kind == TK_SEP:
                            action(ex)
                            ex = newSeq[TokenTuple]()
                        else:
                            add(ex, n[x]) 
                    
                    action(ex)
        
    elif n[0].value == "while":
        if n[4].kind == TK_LSCOL:
            if n[2].kind == TK_EQ or n[2].kind == TK_EQN:

                var ex = newSeq[TokenTuple]() #This collects the appropriate data
                var ex2 = newSeq[seq[TokenTuple]]()
                for x in n[5 .. ^1]:
                    if x.kind == TK_SEP:
                        add(ex2, ex)
                        ex = newseq[TokenTuple]()
                    else:
                        add(ex, x)

                while whi(n[1], n[2], n[3]):
                    for test in ex2:
                        var e = test
                        action(e)
    
    elif n[0].kind == TK_LOOP:
        if n[1].kind == TK_INTEGER:
            
            var ex = newSeq[TokenTuple]() #This collects the appropriate data
            var ex2 = newSeq[seq[TokenTuple]]()
            for x in n[3 .. ^1]:
                if x.kind == TK_SEP:
                    add(ex2, ex)
                    ex = newseq[TokenTuple]()
                else:
                    add(ex, x)
        
            for i in countTo(parseInt(n[1].value) - 1):
                for test in ex2:
                    var test2 = test
                    action(test2)
    

    elif n[0].value == "record":
        record(n)
    
    elif n[0].value == "delete":
        delete(n)
    
    elif n[0].value == "benchmark":
        benchmark()
    
    elif n[0].value == "request":
        request(n)
        Vars2[n[2].value] = Variable(name: n[2].value, vname: n[0].value, ty: TK_DICT)
    
    elif n[0].kind == TK_GARBAGE:
        dealloc Vars2[n[2].value].unsafeAddr
    
    elif n[0].kind == TK_IDENTIFIER:
        var x = Fun[n[0].value][2 .. ^1]
        for ab in actiontree2(x):
            var test = ab
            action(test) 
    
    elif n[0].kind == TK_FUN:
        var FunV = newSeq[TokenTuple]() #-> Collects
        var FunN: string #-> Identifies
        var i: int = -1
        var temp: int = len(n)
        var c: int = 0 #Looks at Right/Left Colons

        while i < temp - 1:
            i = i + 1
            if n[i].kind == TK_FUN:
                if n[i+1].kind == TK_IDENTIFIER:
                    if c == 0:
                        FunN = n[i+1].value
                    else:
                        er(n[i], "You cannot define functions inside of functions.")
            elif n[i].kind == TK_LSCOL:
                c = c + 1
                add(FunV, n[i])
            elif n[i].kind == TK_RSCOL:
                c = c - 1
                add(FunV, n[i])
                if c == 0:
                    Fun[FunN] = FunV
                    FunN = ""
                    FunV = newSeq[TokenTuple]()
            elif n[i].kind == TK_STRING and n[i+1].kind == TK_STRING:
                n[i].value = n[i].value & n[i+1].value
                n.delete(i+1)
                temp = len(n)
                add(FunV, n[i])

            else:
                add(FunV, n[i])

        if c != 0:
            er(n[i], "Failed to properly define a function.")

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


    var c: int = 0 #Looks at Right/Left Colons
    var collect = newSeq[TokenTuple]()
    for x in ac:
        add(collect, x)
        if x.kind == TK_SEP or x.kind == TK_RSCOL:
            if x.kind == TK_RSCOL:
                c = c - 1
            
            if c == 0:
                action(collect)
                collect = newSeq[TokenTuple]()
        elif x.kind == TK_LSCOL:
            c = c + 1