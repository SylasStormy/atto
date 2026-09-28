import "parser", tables

type
    Runtime* = object
        variables*: Table[string, Value]
        labels*: Table[string, int]

func getValue(rnt: Runtime, v: Value): Value =
    if v.tp != VRef: return v
    if v.name in rnt.variables:
        return rnt.variables[v.name]

proc declareVar(rnt: var Runtime, name: string, tp: VType) =
    case tp
    of VTString: rnt.variables[name] = Value(tp:VString, value:"")
    of VTNumber: rnt.variables[name] = Value(tp:VNumber, nvalue:0)
    of VTSprite8: rnt.variables[name] = Value(tp:VSprite, svalue: @[])
    of VTSprite16: rnt.variables[name] = Value(tp:VSprite, svalue: @[])
    of VTSprite32: rnt.variables[name] = Value(tp:VSprite, svalue: @[])
    of VTSprite64: rnt.variables[name] = Value(tp:VSprite, svalue: @[])

proc execute*(rnt: var Runtime, code: seq[Instr]) =
    var i = 0
    while i < code.len:
        let ins = code[i]
        case ins.tp
        of IDec:
            rnt.declareVar(ins.name, ins.dectp)
            i.inc
        of ISet:
            if ins.varb in rnt.variables:
                rnt.variables[ins.varb] = rnt.getValue(ins.val)
            i.inc