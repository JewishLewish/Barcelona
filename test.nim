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
    Sep       > ';'
    Assign    > '='
    Comment   > '#' .. EOL      # anything from `#` to end of line
    CommentAlt > "/*" .. "*/"   # anything starting with `/*` to `*/`
    Var       > "var"
    Let       > "let"
    Const     > "const"
    BTrue     > @["TRUE", "True", "true", "YES", "Yes", "yes", "y"]
    BFalse    > @["FALSE", "False", "false", "NO", "No", "no", "n"]




proc main(n: string) =
    var ac = newSeq[TokenTuple]()
    var lex = Lexer.init(fileContents = readFile(n))

    if lex.hasError:
        echo lex.getError
    else:
        while true:
            var curr = lex.getToken()
            if curr.kind == TK_EOF: break
            add(ac, curr) # tuple[kind: TokenKind, value: string, wsno: col, line: int]

    var syntax = newSeq[string]()
    for x in ac:
        echo x
        if x.kind == TK_LCOL:
            add(syntax, "(")
        if x.kind == TK_RCOL:
            add(syntax, ")")
        else:
            add(syntax, x.value)

    


    

main("main.bar")
let py = pyBuiltinsModule()
discard py.print("The operation time took:")
discard py.print(time.time().to(float) - start_time.to(float))