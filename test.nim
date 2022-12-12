import tables
import toktok

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
    Assign    > '='
    Comment   > '#' .. EOL      # anything from `#` to end of line
    CommentAlt > "/*" .. "*/"   # anything starting with `/*` to `*/`
    Var       > "var"
    Let       > "let"
    Const     > "const"
    BTrue     > @["TRUE", "True", "true", "YES", "Yes", "yes", "y"]
    BFalse    > @["FALSE", "False", "false", "NO", "No", "no", "n"]

when isMainModule:
    var lex = Lexer.init(fileContents = readFile("main.bar"))
    if lex.hasError:
        echo lex.getError
    else:
        while true:
            var curr = lex.getToken()           # tuple[kind: TokenKind, value: string, wsno, col, line: int]
            if curr.kind == TK_EOF: break
            echo curr