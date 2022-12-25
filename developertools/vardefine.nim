import ../main
import tables

proc define*(n: var TokenTuple) =
    let v = n.value 
    n.value = Vars2[v].vname
    n.kind = Vars2[v].ty
