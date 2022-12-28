import ../main
import tables

proc define*(n: TokenTuple): (string, TokenKind) =
    return (Vars2[n.value ].vname, Vars2[n.value].ty)