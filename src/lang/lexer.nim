import strutils

type
    TokenType* = enum
        TString, TNumber, TIdent, TComma, TNl
    
    Token* = object
        value*: string
        tp*: TokenType

func tokenize*(text: string): seq[Token] =
    var tokens: seq[Token]

    var i = 0
    while i < text.len:
        let ch = text[i]
        if ch == '"':
            i.inc
            var str = ""
            while i < text.len and text[i] != ch:
                str &= $text[i]
                i.inc
            i.inc
            tokens.add(Token(tp: TString, value: str))
        elif ch == ',':
            i.inc
            tokens.add(Token(tp: TComma))
        elif ch == '\n':
            i.inc
            tokens.add(Token(tp: TNl))
        elif ch.isAlphaAscii or ch == '_':
            var str = ""
            while i < text.len and text[i].isAlphaNumeric:
                str &= $text[i]
                i.inc
            i.inc
            tokens.add(Token(tp: TIdent, value: str))
        elif ch.isDigit or ch == '-':
            var str = ""
            while i < text.len and (text[i].isDigit or text[i] == '.'):
                str &= $text[i]
                i.inc
            i.inc
            tokens.add(Token(tp: TNumber, value: str))
        else:
            i.inc
            
    return tokens