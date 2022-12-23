import ../main


proc er*(n: var TokenTuple, p: string) = #seperates EVERYTHING
    let x = n
    echo "Error at line: "
    echo $x.line
    echo "Problem:"
    echo p
    quit()

