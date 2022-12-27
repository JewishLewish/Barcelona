import ../main
import std/terminal

proc er*(n: var TokenTuple, p: string) = #seperates EVERYTHING
    let x = n
    stdout.styledWriteLine(fgCyan, "--> Line: ", $x.line)
    stdout.styledWriteLine(fgRed, " # Error")
    stdout.styledWriteLine(fgRed, " # ")
    stdout.styledWriteLine(fgRed, " #    ", p)
    stdout.styledWriteLine(fgRed, " #    |")
    stdout.styledWriteLine(fgRed, " #    |")
    stdout.styledWriteLine(fgRed, " #    V")
    stdout.styledWriteLine(fgRed, " #    ", n.value)
    stdout.styledWriteLine(fgRed, " # ")
    quit()


proc warning*(n: var TokenTuple, p:string) = #Gives warning
    let x = n
    stdout.styledWriteLine(fgCyan, "--> Line: ", $x.line)
    stdout.styledWriteLine(fgYellow, " # Warning")
    stdout.styledWriteLine(fgYellow, " # ")
    stdout.styledWriteLine(fgYellow, " #    ", p)
    stdout.styledWriteLine(fgYellow, " #    |")
    stdout.styledWriteLine(fgYellow, " #    |")
    stdout.styledWriteLine(fgYellow, " #    V")
    stdout.styledWriteLine(fgYellow, " #    ", n.value)
    stdout.styledWriteLine(fgYellow, " # ")

