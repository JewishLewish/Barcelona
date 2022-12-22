import tables
import toktok
import typetraits #This is for debugging

import std/json
import nimpy


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
    Math      > '$'
    LSCol     > '{'
    RSCol     > '}'
    Sep       > ';'
    TRK       > "type"
    FRK       > "fetch"
    FUN       > "fn"
    IF        > "if"
    GARBAGE   > "garbage"
    IMPORT    > "import"
    Assign    > '=':
        EQ      ? '='
    EX        > '!':
        EQN      ? '='
    Comment   > '#' .. EOL      # anything from `#` to end of line
    BTrue     > @["TRUE", "True", "true", "YES", "Yes", "yes", "y"]
    BFalse    > @["FALSE", "False", "false", "NO", "No", "no", "n"]

type
  Variable* = object
    name: string  # variable's itself value
    vname: string # variable's holding value
    ty: TokenKind # type of variable (String, Boolean, etc)

type
    Function* = object
        exlist: seq[TokenTuple]

var Vars2 = initTable[string, Variable]() #Variables
var Fun = initTable[string, seq[TokenTuple]]()

import tools/tokparact
import tools/mathematics

proc variable(n: var seq[TokenTuple]) = #This focuses on replacing variables with values. 
    var x = 0 
    var y = len(n) - 1
    while x < y:
        x = x + 1
        if n[x].kind == TK_IDENTIFIER:
            n[x].kind = Vars2[n[x].value].ty
            n[x].value = Vars2[n[x].value].vname

        elif n[x].kind == TK_LSCOL:
            break

    x = 0 
    y = len(n) - 1
    while x < y:
        x = x + 1
        if n[x].kind == TK_FRK:
            if n[x+1].kind == TK_LCOL and n[x+3].kind == TK_RCOL:
                var jsonfile = parseJson(readFile("main.json"))
                
                n[x].value = jsonfile[n[x+2].value].getStr
                n[x].kind = TK_STRING
                n.delete(x+1)
                n.delete(x+1)
                n.delete(x+1)
                y = len(n) - 1
        
        if n[x].kind == TK_TRK:
            if n[x+1].kind == TK_LCOL and n[x+3].kind == TK_RCOL:

                echo typeof(n[x+2].kind)
                
                if Vars2.hasKey(n[x+2].value):
                    var b = Vars2[n[x+2].value].ty
                    n[x].value = b.astToStr
                    n[x].kind = Vars2[n[x+2].value].ty
                    n.delete(x+1)
                    n.delete(x+1)
                    n.delete(x+1)
                    y = len(n) - 1
                else:
                    n[x].value = n[x+2].kind.astToStr
        
        if n[x].kind == TK_MATH:
            var (b,i) = math(n)
            n[x].kind = TK_INTEGER
            n[x].value = $b
            for range in (x .. i):
                n.delete(x+1)
            
            
            y = len(n) - 1
            
      
proc whi(n: var TokenTuple, det: var TokenTuple, n2: var TokenTuple): bool = 

    var x = ""
    var x2 = ""

    if n.kind == TK_IDENTIFIER:
        x = Vars2[n.value].vname
    else:
        x = n.value

    if n2.kind == TK_IDENTIFIER:
        x2 = Vars2[n.value].vname
    else:
        x2 = n2.value

    if det.kind == TK_EQ:
        if x == x2:
            return true
        else:
            return false
    elif det.kind == TK_EQN:
        if x != x2:
            return true
        else:
            return false

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
        variable(n)
        
        if n[4].kind == TK_LSCOL:
            if n[2].kind == TK_EQ:
                if n[1].value == n[3].value:
                    var execute = n[0 .. ^1] #This grabs the appropriate Data
                    var x = 4
                    var y = len(execute) - 1
                    var ex = newSeq[TokenTuple]() #This collects the appropriate data

                    while x < y:
                        x = x + 1
                        if execute[x].kind == TK_SEP:
                            action(ex)
                            ex = newSeq[TokenTuple]()
                        else:
                            add(ex, n[x]) 
                    
                    action(ex)


            elif n[2].kind == TK_EQN:
                if n[1].value != n[3].value:
                    var execute = n[0 .. ^1] #This grabs the appropriate Data
                    var x = 4
                    var y = len(execute) - 1
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
                while whi(n[1], n[2], n[3]):
                    var execute = n[0 .. ^1] #This grabs the appropriate Data
                    var x = 4
                    var y = len(execute) - 1
                    var ex = newSeq[TokenTuple]() #This collects the appropriate data

                    while x < y:
                        x = x + 1
                        if execute[x].kind == TK_SEP:
                            action(ex)
                            ex = newSeq[TokenTuple]()
                        else:
                            add(ex, n[x]) 
                    
                    action(ex)
    
    elif n[0].value == "loop":
        if n[1].kind == TK_INTEGER:
            var i = 1
            while i != 5:
                i = i + 1

                var x = 2
                var y = len(n) - 1
                var ex = newSeq[TokenTuple]()

                while x < y:
                    x = x + 1
                    if n[x].kind == TK_RSCOL:
                       break
                    elif n[x].kind == TK_SEP: 
                        action(ex)
                        ex = newSeq[TokenTuple]()
                    else:
                        add(ex, n[x]) 
    

    elif n[0].value == "record":
        let jsonfile = parseJson(readFile("main.json"))
        jsonfile[n[1].value] = %* n[3].value

        let f = open("main.json", fmWrite)
        defer: f.close()
        f.write(jsonfile)
    
    elif n[0].value == "delete":
        var jsonfile = parseJson(readFile("main.json"))
        delete(jsonfile, n[1].value)

        let f = open("main.json", fmWrite)
        defer: f.close()
        f.write(jsonfile)
    
    elif n[0].kind == TK_GARBAGE:
        dealloc Vars2[n[2].value].unsafeAddr
    
    elif n[0].kind == TK_IDENTIFIER:
        var x = Fun[n[0].value][2 .. ^1]
        var (b, i) = actiontree2(x)
        var i2 = 0
        while i2 != i:
            action(b[i2])
            i2 = i2 + 1

#proc actiontree(n: var seq[TokenTuple]) = #seperates EVERYTHING
#    var collect = newSeq[TokenTuple]()
#    var c = 0 #Looks at Right/Left Colons
#    var i = 0
#    var body = initTable[int, seq[TokenTuple]]()
#    for x in n:
#        add(collect,x)
#        if x.kind == TK_SEP:
#            if c == 0:
#                body[i] = collect
#                action(body[i])
#                collect = newSeq[TokenTuple]()
#                i = i + 1
#            else:
#                continue
#        
#        if x.kind == TK_LSCOL:
#            c = c + 1
#        elif x.kind == TK_RSCOL:
#            c = c - 1
#            if c == 0:
#                body[i] = collect
#                action(body[i])
#                collect = newSeq[TokenTuple]()
#                i = i + 1

proc parse(n: var seq[TokenTuple]) = #Seperates each function. With "main" being the target one.
    var FunV = newSeq[TokenTuple]() #-> Collects
    var FunN = "String" #-> Identifies
    var i = -1
    var temp = len(n)
    var c = 0 #Looks at Right/Left Colons
    while i < temp - 1:
        i = i + 1
        if n[i].kind == TK_FUN:
            if n[i+1].kind == TK_IDENTIFIER:
                if c == 0:
                    FunN = n[i+1].value
                else:
                    echo "Error, you cannot put functions isnide of functions."
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
        elif n[i].kind == TK_BLOCKCOMMENT:
            continue
        else:
            add(FunV, n[i])

    var x = Fun["main"][2 .. ^1]
    var (b, a) = actiontree2(x)
    var i2 = 0
    while i2 != a:
        action(b[i2])
        i2 = i2 + 1
    #actiontree(x)

proc main*(n: string) =
    var ac = newSeq[TokenTuple]()
    #var lex = Lexer.init(fileContents = readFile(n))
    
    var output = ""
    for x in lines(n):
        add(output, x)
    var lex = Lexer.init(fileContents = output)


    if lex.hasError:
        echo lex.getError
    else:
        while true:
            var curr = lex.getToken()
            if curr.kind == TK_EOF: 
                add(ac, curr)
                break
            else:
                add(ac, curr) # tuple[kind: TokenKind, value: string, wsno: col, line: int]
    

    parse(ac)