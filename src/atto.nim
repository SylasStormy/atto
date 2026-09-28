import "lang/lexer", "lang/parser", "lang/runtime"

let lexed = lexer.tokenize("""
dec age as number
set age 18
""")
let parsed = parse(lexed)

var rnt = Runtime()
rnt.execute(parsed)