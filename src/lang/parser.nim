import "lexer", strutils

type
    VType* = enum
        VTString, VTNumber, VTSprite16, VTSprite8   VTSprite32, VTSprite64

    InstrType* = enum
        IDec, ISet, ILabel, IGo, IEcho, ICall, IEnd, IFind, IMath, IIf

    Instr* = ref object
        case tp*: InstrType
        of IDec:
            name*: string
            dectp*: VType
        of ISet:
            varb*: string
            val*: Value
        of ILabel:
            label*: string
            ind*: int
        of IGo:
            to*: string
        of ICall:
            call*: string
        of IEcho:
            value*: Value
        of IFind:
            find*: string
        of IMath:
            op*: uint8 # 0 add, 1 sub, 2 mul, 3 div, 4 mod
            vrb*: string
            num*: Value
        of IIf:
            first*: Value
            second*: Value
            ifop*: uint8 # 0 ==, 1 !=, 2 >, 3 <, 4 >=, 5 <=
        else:
            discard
        

    ValueType* = enum
        VString, VNumber, VSprite, VRef
    Value* = ref object
        case tp*: ValueType
        of VString:
            value*: string
        of VNumber:
            nvalue*: int16
        of VSprite:
            svalue*: seq[uint8]
            length*: uint8
        of VRef:
            name*: string

func toVType(str: string): VType =
    case str
    of "string": return VTString
    of "number": return VTNumber
    of "sprite8": return VTSprite8
    of "sprite16": return VTSprite16
    of "sprite32": return VTSprite32
    of "sprite64": return VTSprite64
    else: return VTNumber

func toValue(tk: Token): Value =
    if tk.tp == TString: return Value(tp:VString,value:tk.value)
    if tk.tp == TNumber: return Value(tp:VNumber,nvalue:tk.value.parseInt.int16)
    if tk.tp == TIdent: return Value(tp:VRef,name:tk.value)
    else:
        return Value(tp:VNumber,nvalue:0)

proc parse*(code: seq[Token]): seq[Instr] =
    var parsed: seq[Instr]

    var i = 0
    while i < code.len:
        let first = code[i]
        if first.tp != TIdent:
            i.inc
        let remaining = code.len-i
        
        if first.value == "dec" and remaining >= 4 and code[i+2].value == "as":
            parsed.add(Instr(tp:IDec,name: code[i+1].value, dectp: toVType(code[i+3].value)))
            i += 4
        elif first.value == "set" and remaining >= 3 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:ISet,varb:code[i+1].value,val:toValue(code[i+2])))
            i += 3
        elif first.value == "label" and remaining >= 2 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:ILabel,label:code[i+1].value,ind:parsed.len))
            i += 2  
        elif first.value == "go" and remaining >= 2 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:IGo,to:code[i+1].value))
            i += 2
        elif first.value == "call" and remaining >= 2 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:ICall,call:code[i+1].value))    
            i += 2
        elif first.value == "find" and remaining >= 2 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:IFind,find:code[i+1].value))
            i += 2
        elif first.value == "echo" and remaining >= 2:
            parsed.add(Instr(tp:IEcho,value:toValue(code[i+1])))
            i += 2
        elif first.value == "end":
            parsed.add(Instr(tp:IEnd))
            i.inc
        elif first.value == "add" and remaining >= 3 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:IMath,op:0,vrb:code[i+1].value,num:toValue(code[i+2])))
            i += 3
        elif first.value == "sub" and remaining >= 3 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:IMath,op:1,vrb:code[i+1].value,num:toValue(code[i+2])))
            i += 3
        elif first.value == "mul" and remaining >= 3 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:IMath,op:2,vrb:code[i+1].value,num:toValue(code[i+2])))
            i += 3
        elif first.value == "div" and remaining >= 3 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:IMath,op:3,vrb:code[i+1].value,num:toValue(code[i+2])))
            i += 3
        elif first.value == "mod" and remaining >= 3 and code[i+1].tp == TIdent:
            parsed.add(Instr(tp:IMath,op:4,vrb:code[i+1].value,num:toValue(code[i+2])))
            i += 3
        

    return parsed