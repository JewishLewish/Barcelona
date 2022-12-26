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
    LSCol     > '{' #Left
    RSCol     > '}' #Right
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

var input = newSeq[string]() #This is what we input into the python fike.
var indent = 0 #Indents for Python Translator
var variables = newSeq[string]() #These are variables that SHOULD NOT BE TOUCHED!


import std/[strformat, strutils]

proc rent(n: var TokenTuple): string = 
    if n.kind == TK_IDENTIFIER:
        return n.value
    elif n.kind == TK_STRING:
        return fmt""" "{n.value}" """.strip
    elif n.kind == TK_INTEGER:
        return n.value
    elif n.kind == TK_MATH:
        

proc translate(n: var seq[TokenTuple]) = 
    var x: string
    if indent != 0:
        for range in (0 .. indent):
            x = x & "   "
    

    if n[0].value == "echo":
        x = x & fmt"""print({rent(n[1])})"""
        add(input, x)
    elif n[0].value == "var":
        x = x & fmt"""{rent(n[1])} = {rent(n[3])} """
        add(input, x)
        add(variables, n[1].value)

    elif n[0].value == "if" or n[0].value == "while":
        var compare: string
        if n[2].kind == TK_EQ:
            compare = "=="
        elif n[2].kind == TK_EQN:
            compare = "!="
        else:
            echo "THIS IS AN ERROR!"
        
        x = x & fmt"""{rent(n[0])} {rent(n[1])} {compare} {rent(n[3])}: """
        add(input, x)

proc pytrans*(n: string) =

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


    var collect = newSeq[TokenTuple]()
    for x in ac:
        add(collect, x)
        if x.kind == TK_SEP or x.kind == TK_RSCOL or x.kind == TK_LSCOL:
            translate(collect)
            collect = newSeq[TokenTuple]()

            if x.kind == TK_RSCOL:
                indent = indent - 1

            elif x.kind == TK_LSCOL:
                indent = indent + 1
    



    let f = open("test.py", fmWrite) #Writes everything it collected.
    defer: f.close()
    for x in input:
        f.writeLine(x)

    
    input = newSeq[string]() #Resets the input.