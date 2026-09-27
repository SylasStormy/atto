import "lang/lexer", "lang/parser"

let lexed = lexer.tokenize("""
dec age as number
set age 18
""")
echo parse(lexed).repr