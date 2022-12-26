import ../main
import tables

proc define*(n: var TokenTuple) =
    let v = n.value 
    n.value = Vars2[v].vname
    n.kind = Vars2[v].ty

proc clean*(x: string) = 
    dealloc Vars2[x].ty.addr
    dealloc Vars2[x].vname.addr
    dealloc Vars2[x].addr #Not sure why this doesn't work?