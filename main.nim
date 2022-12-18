import tables
import toktok
import typetraits #This is for debugging

import std/json
import nimpy

var j2 = parseJson("""{"nodes": []}""")

static:
    Program.settings(
        uppercase = true,
        prefix = "Tk_"
    )

tokens:
    Plus      > '+'
    Minus     > '-':
        LArrow  ? '>'
    Multi     > '*'
    Div       > '/':
        BlockComment ? '*' .. "*/"
    LCol      > '('
    RCol      > ')'
    Num      > "#"
    LSCol     > '{'
    RSCol     > '}'
    Col       > ':'
    Sep       > ';'
    TRK       > "type"
    FRK       > "fetch"
    Period    > '.'
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
        exlist*: seq[TokenTuple]


var Vars2 = initTable[string, Variable]() #Variables
var FunEX = initTable[string, Function]() #Collects Functions

include tools/objtostring

proc variable(n: var seq[TokenTuple]) = #This focuses on replacing variables with values. 
    var x = 0 
    var y = len(n) - 1
    while x < y:
        x = x + 1
        if n[x].kind == TK_IDENTIFIER:
            n[x].value = Vars2[n[x].value].vname
            n[x].kind = TK_STRING

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
                        

        
proc whi(n: var TokenTuple, n2: var TokenTuple): bool = 

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

    if x == x2:
        return true
    else:
        return false
proc action(n: var seq[TokenTuple]) = 
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
                        if execute[x].kind == TK_COL:
                            if ex[0].value == "if":
                                if execute[x-1].kind == TK_RSCOL:
                                    echo "This is a funny easteregg."
                                else:
                                    add(ex, n[x]) 
                                    continue
                            else: 
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
                        if execute[x].kind == TK_COL:
                            if ex[0].value == "if":
                                if execute[x-1].kind == TK_RSCOL:
                                    echo "This should never touch lol"
                                else:
                                    add(ex, n[x]) 
                                    continue
                            else: 
                                action(ex)
                                ex = newSeq[TokenTuple]()
                        else:
                            add(ex, n[x]) 

                    action(ex)
        
    elif n[0].value == "while":
        if n[4].kind == TK_LSCOL:
            if n[2].kind == TK_EQ:
                while whi(n[1], n[3]):
                    var x = 4
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
    
    elif n[0].value == "fun":
        var i = -1
        for x in n:
            i = i + 1
            if x.kind == TK_LSCOL:break
        
        i = i - 2 #Area between here takes in the center. -> fun name ->(var_name var_type)<- {
        if n[1].kind == TK_IDENTIFIER:
            FunEX[n[1].value] = Function(exlist: n[i+2 .. ^1])
            echo FunEX[n[1].value].exlist
    
    elif FunEX.hasKey(n[0].value):
        var execute = FunEX[n[0].value].exlist #This grabs the appropriate Data
        echo execute
        var x = 0
        var y = len(execute) - 1
        var ex = newSeq[TokenTuple]() #This collects the appropriate data

        while x < y:
            x = x + 1
            echo x
            if execute[x].kind == TK_COL:
                action(ex)
                ex = newSeq[TokenTuple]()
            else:
                add(ex, n[x]) 

        action(ex)

proc main(n: string) =
    var ac = newSeq[TokenTuple]()
    var lex = Lexer.init(fileContents = readFile(n))
    
    var output: TaintedString
    for x in lines(n):
        add(output, x)
    lex = Lexer.init(fileContents = output)


    if lex.hasError:
        echo lex.getError
    else:
        while true:
            var curr = lex.getToken()
            if curr.kind == TK_EOF: 
                action(ac)
                break
            elif curr.kind == TK_COL:
                echo ac
                action(ac)
                ac = newSeq[TokenTuple]()
            else:
                add(ac, curr) # tuple[kind: TokenKind, value: string, wsno: col, line: int]


main("main.bar")