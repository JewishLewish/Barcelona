import std/[httpclient, json]
import ../main
import ../developertools/vardefine

let client = newHttpClient()
client.headers = newHttpHeaders({ "Content-Type": "application/json" })

proc request*(n: var seq[TokenTuple]) = #request("name of location", "auth") ...
    var pop = 0 #Gets rid of certain variables

    if n[2].kind == TK_IDENTIFIER:
        (n[2].value, n[2].kind) = define(n[2])

    if n[3].kind == TK_SEPERATOR: #THis is for variables
        if n[4].kind == TK_IDENTIFIER:
            (n[4].value, n[4].kind) = define(n[4])

        client.headers["Authorization"] = n[4].value
        pop = pop + 2
    
    let response2 = client.get(n[2].value)
    case n[0].value
    of "request":
        n[0].value = response2.body
        n[0].kind = TK_DICT
    of "status":
        n[0].value = response2.status
        n[0].kind = TK_STRING

    pop = pop + 3

    n[1 .. pop] = []



proc rd*(n: var seq[TokenTuple], target: int) = 
    var dict = parseJson(n[target].value) #{"type":"users","count":51}
    var result: string
    while true:
        if n[target + 1].kind == TK_LBRA and n[target + 3].kind == TK_RBRA: #This is checking to make sure it has a clean syntax
            result = $dict[n[target + 2].value] #type -> "users" 
            dict = parsejson(result) #Redefines the Json Dictionary
            n.delete(1)
            n.delete(1)
            n.delete(1)
        else:
            break

    
    echo result
