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