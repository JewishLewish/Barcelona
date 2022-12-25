import std/[httpclient, json]
import ../main
let client = newHttpClient()
client.headers = newHttpHeaders({ "Content-Type": "application/json" })

proc request*(n: var seq[TokenTuple]) = 
    var pop = 0
    let response2 = client.getContent(n[2].value)
    if n[3].kind != TK_RCOL:
        var dict = parseJson(response2)
        n[0].value = $dict[n[3].value]
        n[0].kind = TK_STRING
        pop = 3
    else:
        n[0].value = response2
        n[0].kind = TK_DICT
        pop = 2

    for range in (0 .. pop):
        n.delete(1)



proc rd*(n: var seq[TokenTuple], target: int) = 
    var dict = parseJson(n[target].value) #{"type":"users","count":51}
    var result: string
    while true:
        if n[target + 1].kind == TK_LBRA and n[target + 3].kind == TK_RBRA:
            result = $dict[n[target + 2].value]
            n.delete(1)
            n.delete(1)
            n.delete(1)
        else:
            break

    
    echo result
