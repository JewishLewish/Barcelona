import sys
import tokenize
from io import BytesIO
import json
from pyparsing import *
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
        elif token.type == 3:
            command.append(token)
        elif token.type == 54:
            command.append(token)
        else:
            command.append(token)

def parse(commands):
    text = []
    for x in commands:
        text.append(x.string)
    text[0] = text[0].lower()

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
                text[a] = "".join(jsonhelp("g", fetch.parseString(''.join(text[a:]).replace("\"", ""))[1], " "))
                commands, text = p("".join(text))
                b = len(text)

            else:
                if type(Vars[commands[a].string]) == list:
                    if text[a+1] != "[":
                        text[a] = str(Vars[commands[a].string])
                    elif text[a+1] == "[" and text[a+3] == "]":
                        text[a] = str(Vars[commands[a].string][int(text[a+2])])
                        text.pop(a+1)
                        text.pop(a+1)
                        text.pop(a+1)

                        commands, text = p("".join(text))
                        b = len(text)
                else:
                    text[a] = Vars[commands[a].string]

        elif commands[a].string in "{}":
            break


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
                Vars[temp] = str(var.parseString(result[2])[1:-1])[2:-3].replace(" ","").split(",")

            else:
                Vars[result[0]] = result[2]

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
            return j[data1]

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


if __name__ == '__main__':
    main('main.bar')


