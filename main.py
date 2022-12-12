import sys
import tokenize
from io import BytesIO
import json
from pyparsing import *
import time
start_time = time.time()
Vars = {}
FunA = {}
digits = "012345689"

def main(file):
    ac = []

    with open(file, 'rb') as f:
        for token in tokenize.tokenize(f.readline):
            ac.append(token)
    ac.pop(0)

    command = []
    for token in ac:
        if token.type == 4:
            parse(command)
            command.clear()
        elif token.type == 0 or token.type == 62:
            continue
        else:
            command.append(token)
    
    print('\033[42m', "Process finished --- %s seconds ---" % (time.time() - start_time))
    return

def parse(commands):
        text = []
        for x in commands:
            text.append(x.string)
        text[0] = text[0].lower()
        Keywords = ["fetch", "eval"]
        Ignore = ["box", "open", "while"]

        if text[0] not in Ignore:
            a = -1
            b = len(commands)
            while a < b - 1:
                a = a + 1

                if a == 0 or a == 1:
                        continue
                
                if commands[a].string in "{}":
                    break

                if commands[a].type == 1:
                    if commands[a].string.lower() in Keywords:
                        continue
                    else:
                        text[a] = str(Vars[commands[a].string])
                        commands, text = p("".join(text))

            a = -1
            b = len(commands)

            while a < b - 1:
                if text[0] == "box" or text[0] == "open":
                    break

                a = a + 1
                if commands[a].type == 1:
                    if a == 0 or a == 1:
                        continue

                    if text[a] in "fetch":
                        fetch = "fetch(" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("()") | White(' ',max=1))) + ")"
                        text[a:a+4] = ["".join(text[a:a+4])]
                        text[a] = "\"" + "".join(jsonhelp("g", fetch.parseString(''.join(text[a:]).replace("\"", ""))[1], " "))[1:-1] + "\""
                        commands, text = p("".join(text))
                        b = len(text)

                    #elif text[a] in "get":
                    #    print(text)
                    #    get = "[" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("[]"))) + "]" + ".get(" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("()") | White(' ', max=1))) + ")"
                    #    print(text[a-5:a+4])
                    #    x = get.parseString("".join(text[a-2:a+4]))
                    #    index = int(x[a])
                    #    y = "".join(x[1]).split(",")

                    #    if type(y[index]) == str:
                    #        result = y[index].replace("\'", "\"")

                    #    text[a-2] = result
                    #    text.pop(a-1)
                    #    text.pop(a-1)
                    #    text.pop(a-1)
                    #    text.pop(a-1)
                    #    text.pop(a-1)

                    #    commands, text = p("".join(text))
                    #    b = len(text)

                    elif text[a] in "eval":
                        e = "eval" + "[" + Combine(OneOrMore(CharsNotIn("[]") | White(' ',max=1))) + "]"
                        x = e.parseString("".join(text[a:]))
                        text[a] = str(eval(x[1]))
                        for x in range(text.index("]") - text.index("[") + 1):
                            text.pop(a+1)
                        
                        commands, text = p("".join(text))
                        b = len(text)

                elif commands[a].string in "{}":
                    break


        ast(commands)

def jsonhelp(action, data1, data2): #json feature
        if action == "re":
            with open("main.json", "r+") as outfile:
                j = json.loads(outfile.read())
                j[data1] = data2

            with open("main.json", "w") as outfile:
                json.dump(j, outfile, indent=4)

        elif action == "d":
            with open("main.json", "r+") as outfile:
                j = json.loads(outfile.read())
                del j[data1]

            with open("main.json", "w") as outfile:
                json.dump(j, outfile, indent=4)

        elif action == "g":
            with open("main.json", "r+") as outfile:
                j = json.loads(outfile.read())
                if type(j[data1]) == int:
                    return str(j[data1])
                elif type(j[data1]) == str:
                    return ("\"" + j[data1] + "\"")

def fstart(c):
        command = []
        x = 0

        for token in c:
            if token.string == "{" or token.string == "}":
                if x == 0:
                    x = 1
                else:
                    x = 0

            if token.string == ":":
                if x == 0:
                    parse(command)
                    command.clear()
                else:
                    command.append(token)
            elif token.type == 0 or token.type == 62:
                continue
            elif token.type == 3:
                command.append(token)
            elif token.type == 54:
                command.append(token)
            else:
                command.append(token)

        parse(command)

def iwstates(c, r): #c = commands, #r = results,
    if r[0] == "if(":
        if r[2] == "==":
            if r[1] == r[3]:
                fstart(c[7:-1])
            else:
                return
        elif r[2] == "=!":
            if r[1] != r[3]:
                fstart(c[8:-1])
        else:
            print("INAPPROPRIATE PROCEDURE!")

    elif r[0] == "while(":
        if r[2] == "==":
            while r[1] == r[3]:
                fstart(c[7:-1])
            else:
                return

        elif r[2] == "=!":
            y = r[1]
            while r[1] != r[3]:
                r[1] = Vars[y]
                fstart(c[8:-1])
            else:
                return
        else:
            print("INAPPROPRIATE PROCEDURE!")

def p(c):
    ac = []
    for x in tokenize.tokenize(BytesIO(c.encode('utf-8')).readline):
        ac.append(x)
    ac.pop(0)

    command = []
    for token in ac:
        if token.type == 4:
            continue
        elif token.type == 0 or token.type == 62:
            continue
        elif token.type == 3:
            command.append(token)
        elif token.type == 54:
            command.append(token)
        else:
            command.append(token)

    text = []
    for x in command:text.append(x.string)
    return command, text

def ast(commands): #Abstract Syntax Tree
    text = []
    for x in commands:
        text.append(x.string)
    text[0] = text[0].lower()

    if text[0].lower() == "echo":
        echo = Word(alphas) + "(" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("()") | White(' ',max=1))) + ")"
        result = echo.parseString(''.join(text).replace("\"", ""))
        print(result[2])

    elif text[0].lower() == "record":
        rec = "record" + "(" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("(),") | White(' ', max=1))) + "," + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("()") | White(' ', max=1))) + ")"
        result = rec.parseString(''.join(text).replace("\"", ""))
        jsonhelp("re", result[1], result[3])

    elif text[0].lower() == "delete":
        dele = "delete" + "(" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("(),") | White(' ', max=1))) + ")"
        result = dele.parseString(''.join(text).replace("\"", ""))
        jsonhelp("d", result[1], "")

    elif text[0].lower() == "open":
        s = "open" + "(" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("(),") | White(' ', max=1))) + ")"
        result = s.parseString(''.join(text).replace("\"", ""))
        fstart(FunA[result[1]])

    elif text[0].lower() == "box":
        f = "box" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("=>") | White(' ', max=1)))
        result = f.parseString(''.join(text).replace("\"", ""))
        FunA[result[1]] = commands[5:-1]
    
    elif text[0].lower() == "if":
        f = "if" + "(" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("=="))) + Word("=!" or "==") + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn(")") | White(' ', max=1))) + ")"
        result = f.parseString(''.join(text).replace("\"", ""))
        iwstates(commands, result)

    elif text[0].lower() == "while":
        print(text)
        f = "while" + "(" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("=="))) + Word("=!" or "==") + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn(")") | White(' ', max=1))) + ")"
        result = f.parseString(''.join(text).replace("\"", ""))
        print(Vars[result[1]])
        iwstates(commands, result)

    elif text[0].lower() == "close":
        print("Close Statement -> System Exited!")
        sys.exit()

    elif commands[0].type == 1:
        if commands[1].string == "=":
            var = Word(alphas) + "=" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("()") | White(' ',max=1)))
            result = var.parseString(' '.join(text))

            if "[" in result[2]:
                temp = result[0]
                var = "[" + Combine(OneOrMore(CharsNotIn(printables) | CharsNotIn("[]") | White(' ', max=1))) + "]"
                print(str(var.parseString(result[2].replace("\"", ""))[1:-1])[2:-2].replace(" ","").split(","))
                Vars[temp] = str(var.parseString(result[2].replace("\"", ""))[1:-1])[2:-2].replace(" ","").split(",")

            else:
                Vars[result[0]] = result[2]

if __name__ == '__main__':
    main('main.bar')


