import "parser", tables

type
    Runtime* = object
        variables*: Table[string, Value]
        labels*: Table[string, int]
        callstack*: seq[int]

func getValue(rnt: Runtime, v: Value): Value =
    if v.tp != VRef: return v
    if v.name in rnt.variables:
        return rnt.variables[v.name]

proc declareVar(rnt: var Runtime, name: string, tp: VType) =
    case tp
    of VTString: rnt.variables[name] = Value(tp:VString, value:"")
    of VTNumber: rnt.variables[name] = Value(tp:VNumber, nvalue:0)
    of VTSprite8: rnt.variables[name] = Value(tp:VSprite, svalue: @[], length: 8)
    of VTSprite16: rnt.variables[name] = Value(tp:VSprite, svalue: @[], length: 16)
    of VTSprite32: rnt.variables[name] = Value(tp:VSprite, svalue: @[], length: 32)
    of VTSprite64: rnt.variables[name] = Value(tp:VSprite, svalue: @[], length: 64)

proc stringValue(v: Value): string = 
    case v.tp
    of VString: return v.value
    of VNumber: return $v.nvalue
    of VSprite: return v.svalue.repr
    else: return "reference passed error"

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
            else:
                i.inc
                # error
            i.inc
        of ILabel:
            rnt.labels[ins.label] = ins.ind
            i.inc
        of IGo:
            if not (ins.to in rnt.labels):
                i.inc
                # error
            i = rnt.labels[ins.to]
        of IEcho:
            echo stringValue(rnt.getValue(ins.value))
            i.inc
        of ICall:
            if not (ins.call in rnt.labels):
                i.inc
                # error
            rnt.callstack.add(i)
            i = rnt.labels[ins.call]
        of IEnd:
            if rnt.callstack.len == 0:
                i.inc
                # error
            let popped = rnt.callstack.pop
            i = popped + 1
        of IFind:
            while i < code.len:
                if code[i].tp == ILabel and code[i].label == ins.find:
                    break
                elif code[i].tp == ILabel and code[i].label != ins.find:
                    rnt.labels[code[i].label] = code[i].ind
                i.inc
        of IMath:
            let varb = ins.vrb
            if not (varb in rnt.variables):
                # error
                i.inc
            let first = rnt.variables[varb]
            let second = rnt.getValue(ins.num)
            if first.tp != second.tp:
                # error
                i.inc

            if first.tp == VString and ins.op == 0:
                first.value &= second.value
            elif first.tp == VNumber:
                var res = 0
                case ins.op
                of 0:
                    res = (first.nvalue + second.nvalue)
                of 1:
                    res = (first.nvalue - second.nvalue)
                of 2:
                    res = (first.nvalue * second.nvalue)
                of 3:
                    res = (first.nvalue / second.nvalue).int16
                of 4:
                    res = (first.nvalue mod second.nvalue)
                else:
                    res = 0
                first.nvalue = res.int16
                i.inc
            else:
                i.inc
                # error