import ../main
import tables

proc define*(n: TokenTuple): (string, TokenKind) =
    let v = n.value 
    return (Vars2[v].vname, Vars2[v].ty)