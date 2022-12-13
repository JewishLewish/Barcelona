import tables
import toktok
import typetraits
import nimpy
let time = pyImport("time")
let start_time = time.time()
static:
    Program.settings(
        uppercase = true,
        prefix = "Tk_"
    )
tokens:
    Plus      > '+'
    Minus     > '-'
    Multi     > '*'
    Div       > '/'
    LCol      > '('
    RCol      > ')'
    Col       > ':'
    Sep       > ';'
    Assign    > '='
    Comment   > '#' .. EOL      # anything from `#` to end of line
    CommentAlt > "/*" .. "*/"   # anything starting with `/*` to `*/`
    Var       > "var"
    Let       > "let"
    Const     > "const"
    BTrue     > @["TRUE", "True", "true", "YES", "Yes", "yes", "y"]
    BFalse    > @["FALSE", "False", "false", "NO", "No", "no", "n"]



proc action(n: seq[TokenTuple]) = 
    if n[0].value == "echo":
        echo n[1].value
    elif n[0].value == "var":
        if n[1].kind == TK_IDENTIFIER:
            if n[2].kind == TK_COL:
                if n[3].kind == TK_IDENTIFIER:
                    if n[4].kind ==  TK_ASSIGN:
                        if n[3].value == "string":
                            echo "Variable time!"
                        else:
                            echo "ERROR! THIS IS NOT AN APPROPRIATE VALUE"

proc main(n: string) =
    var ac = newSeq[TokenTuple]()
    var lex = Lexer.init(fileContents = readFile(n))

    if lex.hasError:
        echo lex.getError
    else:
        while true:
            var curr = lex.getToken()
            if curr.kind == TK_EOF: 
                break
            elif curr.kind == TK_SEP: 
                action(ac)
                ac = newSeq[TokenTuple]()
            else:
                echo (curr.kind)
                add(ac, curr) # tuple[kind: TokenKind, value: string, wsno: col, line: int]



main("main.bar")
let py = pyBuiltinsModule()
discard py.print("The operation time took:")
discard py.print(time.time().to(float) - start_time.to(float))