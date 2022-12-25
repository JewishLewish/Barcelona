import std/[httpclient, json]
import ../main
let client = newHttpClient()
client.headers = newHttpHeaders({ "Content-Type": "application/json" })

proc request*(n: var seq[TokenTuple]) = 
    var pop = 0
    let response2 = client.getContent(n[2].value)
    n[0].value = response2
    n[0].kind = TK_DICT
    pop = 2

    for range in (0 .. pop):
        n.delete(1)



proc rd*(n: var seq[TokenTuple], target: int) = 
    var dict = parseJson(n[target].value) #{"type":"users","count":51}
    var result: string
    while true:
        if n[target + 1].kind == TK_LBRA and n[target + 3].kind == TK_RBRA: #This is checking to make sure it has a clean syntax
            result = $dict[n[target + 2].value] #type -> "users" 
            dict = parsejson(result)
            n.delete(1)
            n.delete(1)
            n.delete(1)
        else:
            break

    
    echo result
