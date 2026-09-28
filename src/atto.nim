import "lang/lexer", "lang/parser", "lang/runtime"

let lexed = lexer.tokenize("""
dec i as number
label loop
    add i 1
    echo i
    go loop
""")
let parsed = parse(lexed)

var rnt = Runtime()
rnt.execute(parsed)