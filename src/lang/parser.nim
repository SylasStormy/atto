import "lexer", strutils

type
    VType* = enum
        VTString, VTNumber, VTSprite16, VTSprite8   VTSprite32, VTSprite64

    InstrType* = enum
        IDec, ISet

    Instr* = ref object
        case tp*: InstrType
        of IDec:
            name*: string
            dectp*: VType
        of ISet:
            varb*: string
            val*: Value

    SpriteValue* = ref object
        case tp: VType
        of VTSprite8:
            val8*: uint8
        of VTSprite16:
            val16*: uint16
        of VTSprite32:
            val32*: uint32
        of VTSprite64:
            val64*: uint64
        else:
            discard

    ValueType* = enum
        VString, VNumber, VSprite, VRef
    Value* = ref object
        case tp: ValueType
        of VString:
            value*: string
        of VNumber:
            nvalue*: int16
        of VSprite:
            svalue*: SpriteValue
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

func parse*(code: seq[Token]): seq[Instr] =
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

    return parsed