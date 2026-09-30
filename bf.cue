package bf

import (
    "strings"
    "strconv"
    "list"
)

_#uint7ToString: [
    "\u0000", "\u0001", "\u0002", "\u0003", "\u0004", "\u0005", "\u0006", "\u0007", "\u0008", "\u0009", "\u000A", "\u000B", "\u000C", "\u000D", "\u000E", "\u000F",
    "\u0010", "\u0011", "\u0012", "\u0013", "\u0014", "\u0015", "\u0016", "\u0017", "\u0018", "\u0019", "\u001A", "\u001B", "\u001C", "\u001D", "\u001E", "\u001F",
    "\u0020", "\u0021", "\u0022", "\u0023", "\u0024", "\u0025", "\u0026", "\u0027", "\u0028", "\u0029", "\u002A", "\u002B", "\u002C", "\u002D", "\u002E", "\u002F",
    "\u0030", "\u0031", "\u0032", "\u0033", "\u0034", "\u0035", "\u0036", "\u0037", "\u0038", "\u0039", "\u003A", "\u003B", "\u003C", "\u003D", "\u003E", "\u003F",
    "\u0040", "\u0041", "\u0042", "\u0043", "\u0044", "\u0045", "\u0046", "\u0047", "\u0048", "\u0049", "\u004A", "\u004B", "\u004C", "\u004D", "\u004E", "\u004F",
    "\u0050", "\u0051", "\u0052", "\u0053", "\u0054", "\u0055", "\u0056", "\u0057", "\u0058", "\u0059", "\u005A", "\u005B", "\u005C", "\u005D", "\u005E", "\u005F",
    "\u0060", "\u0061", "\u0062", "\u0063", "\u0064", "\u0065", "\u0066", "\u0067", "\u0068", "\u0069", "\u006A", "\u006B", "\u006C", "\u006D", "\u006E", "\u006F",
    "\u0070", "\u0071", "\u0072", "\u0073", "\u0074", "\u0075", "\u0076", "\u0077", "\u0078", "\u0079", "\u007A", "\u007B", "\u007C", "\u007D", "\u007E", "\u007F",
]

_#plus: strings.Runes("+")[0]
_#minus: strings.Runes("-")[0]
_#gt: strings.Runes(">")[0]
_#lt: strings.Runes("<")[0]
_#lbracket: strings.Runes("[")[0]
_#rbracket: strings.Runes("]")[0]
_#period: strings.Runes(".")[0]
_#comma: strings.Runes(",")[0]

_#parse: {
    tokens: [...int]

    _scan: [for i in list.Range(0, len(tokens) + 1, 1) {
        if i == 0 {
            {stack: [], pairs: []}
        }

        if i > 0 {
            if tokens[i - 1] == _#lbracket {
                {
                    stack: [i - 1, for s in _scan[i - 1].stack { s + 0 }]
                    pairs: [for p in _scan[i - 1].pairs { [p[0] + 0, p[1] + 0] }]
                }
            }

            if tokens[i - 1] == _#rbracket {
                {
                    stack: [for k, s in _scan[i - 1].stack if k > 0 { s + 0 }]
                    pairs: [for p in _scan[i - 1].pairs { [p[0] + 0, p[1] + 0] }, [_scan[i - 1].stack[0] + 0, i - 1]]
                }
            }

            if tokens[i - 1] != _#lbracket && tokens[i - 1] != _#rbracket {
                {
                    stack: [for s in _scan[i - 1].stack { s + 0 }]
                    pairs: [for p in _scan[i - 1].pairs { [p[0] + 0, p[1] + 0] }]
                }
            }
        }
    }]

    _pairs: _scan[len(tokens)].pairs

    bracketMap: [for i, _ in tokens {
        [
            for p in _pairs if p[0] == i { p[1] },
            for p in _pairs if p[1] == i { p[0] },
            0,
        ][0]
    }]
}

_#evalChunk: {
    tokens: [...int]
    positions: [...int]
    bracketMap: [...int]
    input: [...uint8]
    size: int
    wrapAround: bool | *true
    start: {
        ip: uint
        pointer: uint
        memory: [...int]
        output: [...uint8]
        inputPointer: uint
    }

    _#step: {
        in: {
            halted: false
            ip: uint
            pointer: uint
            memory: [...int]
            output: [...uint8]
            inputPointer: uint
        }

        if tokens[in.ip] == _#plus {
            out: {
                halted: false
                ip: in.ip + 1
                pointer: in.pointer + 0
                memory: [for i, c in in.memory {
                    if i == in.pointer {
                        [
                            if wrapAround && c + 1 == 256 { 0 },
                            c + 1,
                        ][0]
                    }
                    if i != in.pointer { c + 0 }
                }]
                output: [for c in in.output { c + 0 }]
                inputPointer: in.inputPointer + 0
            }
        }

        if tokens[in.ip] == _#minus {
            out: {
                halted: false
                ip: in.ip + 1
                pointer: in.pointer + 0
                memory: [for i, c in in.memory {
                    if i == in.pointer {
                        [
                            if wrapAround && c - 1 == -1 { 255 },
                            c - 1,
                        ][0]
                    }
                    if i != in.pointer { c + 0 }
                }]
                output: [for c in in.output { c + 0 }]
                inputPointer: in.inputPointer + 0
            }
        }

        if tokens[in.ip] == _#lt {
            if in.pointer == 0 {
                out: error("\"<\" at position \(positions[in.ip]) moves the pointer to the left of the first cell")
            }

            if in.pointer > 0 {
                out: {
                    halted: false
                    ip: in.ip + 1
                    pointer: in.pointer - 1
                    memory: [for c in in.memory { c + 0 }]
                    output: [for c in in.output { c + 0 }]
                    inputPointer: in.inputPointer + 0
                }
            }
        }

        if tokens[in.ip] == _#lbracket {
            out: {
                halted: false
                if in.memory[in.pointer] == 0 {
                    ip: bracketMap[in.ip] + 1
                }
                if in.memory[in.pointer] != 0 {
                    ip: in.ip + 1
                }
                pointer: in.pointer + 0
                memory: [for c in in.memory { c + 0 }]
                output: [for c in in.output { c + 0 }]
                inputPointer: in.inputPointer + 0
            }
        }

        if tokens[in.ip] == _#rbracket {
            out: {
                halted: false
                if in.memory[in.pointer] == 0 {
                    ip: in.ip + 1
                }
                if in.memory[in.pointer] != 0 {
                    ip: bracketMap[in.ip] + 1
                }
                pointer: in.pointer + 0
                memory: [for c in in.memory { c + 0 }]
                output: [for c in in.output { c + 0 }]
                inputPointer: in.inputPointer + 0
            }
        }

        if tokens[in.ip] == _#gt {
            out: {
                halted: false
                ip: in.ip + 1
                pointer: in.pointer + 1
                if in.pointer + 1 == len(in.memory) {
                    memory: [for c in in.memory { c + 0 }, 0]
                }
                if in.pointer + 1 < len(in.memory) {
                    memory: [for c in in.memory { c + 0 }]
                }
                output: [for c in in.output { c + 0 }]
                inputPointer: in.inputPointer + 0
            }
        }

        if tokens[in.ip] == _#period {
            if in.memory[in.pointer] < 0 || in.memory[in.pointer] > 255 {
                out: error("\".\" at position \(positions[in.ip]) outputs \(in.memory[in.pointer]), which is not a byte")
            }

            if in.memory[in.pointer] >= 0 && in.memory[in.pointer] <= 255 {
                out: {
                    halted: false
                    ip: in.ip + 1
                    pointer: in.pointer + 0
                    memory: [for c in in.memory { c + 0 }]
                    output: [for c in in.output { c + 0 }, in.memory[in.pointer] + 0]
                    inputPointer: in.inputPointer + 0
                }
            }
        }

        if tokens[in.ip] == _#comma {
            out: {
                halted: false
                ip: in.ip + 1
                pointer: in.pointer + 0
                memory: [for i, c in in.memory {
                    if i == in.pointer {
                        if in.inputPointer < len(input) { input[in.inputPointer] + 0 }
                        if in.inputPointer >= len(input) { 0 }
                    }
                    if i != in.pointer { c + 0 }
                }]
                output: [for c in in.output { c + 0 }]
                inputPointer: in.inputPointer + 1
            }
        }
    }

    // states[j] refers to states[j - 1] directly rather than through a let:
    // a let that refers to j resolves to a new vertex holding its expression
    // instead of to the list element, so each element is evaluated again
    // inside the next element's copy, and the work doubles with each element.
    // The conditions are nested ifs because && evaluates both of its operands,
    // and a halted state has none of the fields the second one would read.
    states: [for j in list.Range(0, size + 1, 1) {
        if j == 0 {
            {
                halted: false
                ip: start.ip + 0
                pointer: start.pointer + 0
                memory: [for c in start.memory { c + 0 }]
                output: [for c in start.output { c + 0 }]
                inputPointer: start.inputPointer + 0
            }
        }

        if j > 0 {
            if states[j - 1].halted {
                {halted: true}
            }

            if !states[j - 1].halted {
                if states[j - 1].ip == len(tokens) {
                    {halted: true}
                }

                if states[j - 1].ip < len(tokens) {
                    (_#step & {
                        in: {
                            halted: false
                            ip: states[j - 1].ip
                            pointer: states[j - 1].pointer
                            memory: states[j - 1].memory
                            output: states[j - 1].output
                            inputPointer: states[j - 1].inputPointer
                        }
                    }).out
                }
            }
        }
    }]

    _running: [for s in states if !s.halted { s }]

    last: _running[len(_running) - 1]
    done: len(_running) < len(states)
}

_#eval: {
    tokens: [...int]
    positions: [...int]
    bracketMap: [...int]
    input: [...uint8]
    wrapAround: bool | *true
    firstSize: int

    // Each depth runs twice as many steps as the one before it, so the number
    // of steps has no bound while the depth stays around log2 of it.
    _#impl: [depth = =~"^\\d+$"]: {
        let next = "\(strconv.Atoi(depth) + 1)"

        start: {
            ip: uint
            pointer: uint
            memory: [...int]
            output: [...uint8]
            inputPointer: uint
        }
        size: int

        _s: _#evalChunk & {
            "tokens": tokens
            "positions": positions
            "bracketMap": bracketMap
            "input": input
            "wrapAround": wrapAround
            "size": size
            "start": start
        }

        if _s.done {
            out: [_s.last]
        }

        if !_s.done {
            out: [for o in ((_#impl & {(next): _})[next] & {
                "start": {
                    ip: _s.last.ip
                    pointer: _s.last.pointer
                    memory: _s.last.memory
                    output: _s.last.output
                    inputPointer: _s.last.inputPointer
                }
                "size": size * 2
            }).out { o }]
        }
    }

    out: ((_#impl & {"0": _})["0"] & {
        start: {ip: 0, pointer: 0, memory: [0], output: [], inputPointer: 0}
        size: firstSize
    }).out[0]
}

#run: {
    sourceCode: string
    input: [...uint8]
    wrapAround: bool | *true

    out: string

    _runes: strings.Runes(sourceCode)
    _positions: [for i, r in _runes if list.Contains([_#plus, _#minus, _#gt, _#lt, _#lbracket, _#rbracket, _#period, _#comma], r) { i }]
    _tokens: [for p in _positions { _runes[p] }]

    _evaluated: (_#eval & {
        tokens: _tokens
        positions: _positions
        bracketMap: (_#parse & {tokens: _tokens}).bracketMap
        "input": input
        "wrapAround": wrapAround
        firstSize: 64
    }).out

    out: strings.Join([for c in _evaluated.output { _#uint7ToString[c] }], "")
}
