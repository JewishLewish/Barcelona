import ../main
import std/json

proc record*(n: var seq[TokenTuple]) = 
    let jsonfile = parseJson(readFile("main.json"))
    jsonfile[n[1].value] = %* n[3].value

    let f = open("main.json", fmWrite)
    defer: f.close()
    f.write(jsonfile)

proc delete*(n: var seq[TokenTuple]) =
    var jsonfile = parseJson(readFile("main.json"))
    delete(jsonfile, n[1].value)

    let f = open("main.json", fmWrite)
    defer: f.close()
    f.write(jsonfile)

proc fetch*(n :var seq[TokenTuple], x: int) =
    var jsonfile = parseJson(readFile("main.json"))
    n[x].value = jsonfile[n[x+1].value].getStr
    n[x].kind = TK_STRING
    n.delete(x+1)