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

_#tokens: {
    gt: strings.Runes(">")[0]
    lt: strings.Runes("<")[0]
    plus: strings.Runes("+")[0]
    minus: strings.Runes("-")[0]
    period: strings.Runes(".")[0]
    comma: strings.Runes(",")[0]
    lbracket: strings.Runes("[")[0]
    rbracket: strings.Runes("]")[0]
}

_#Token: or([for token in _#tokens { token }])

_#isToken: {
    rune: uint

    out: (rune & _#Token) != _|_
}

_#lex: {
    sourceCode: string

    out: {
        tokens: [for rune in strings.Runes(sourceCode) if (_#isToken & { "rune": rune }).out {rune}]
    }
}

_#parse: {
    tokens: [..._#Token]

    let numTokens = len(tokens)

    _#impl: [depth = =~"^\\d+$"]: {
        let next = "\(strconv.Atoi(depth) + 1)"

        i: uint
        lbrackets: [...uint]
        bracketMap: { [_]: uint }

        if i == numTokens {
            out: [bracketMap]
        }

        if i < numTokens {
            let token = tokens[i]

            if token == _#tokens.lbracket {
                out: [] + ((_#impl & {(next): _})[next] & {
                    "lbrackets": [i] + lbrackets
                    "bracketMap": bracketMap
                    "i": i + 1
                }).out
            }

            if token == _#tokens.rbracket {
                out: [] + ((_#impl & {(next): _})[next] & {
                    "lbrackets": list.Drop(lbrackets, 1)
                    "bracketMap": bracketMap & {
                        "\(lbrackets[0])": i
                        "\(i)": lbrackets[0]
                    }
                    "i": i + 1
                }).out
            }

            if token != _#tokens.lbracket && token != _#tokens.rbracket {
                out: [] + ((_#impl & {"\(next)": _})[next] & {
                    "lbrackets": lbrackets
                    "bracketMap": bracketMap
                    "i": i + 1
                }).out
            }
        }
    }

    out: {
        "tokens": tokens
        bracketMap: ((_#impl & {"0": _})["0"] & {
            lbrackets: []
            bracketMap: {}
            i: 0
        }).out[0]
    }
}

_#eval: {
    tokens: [..._#Token]
    bracketMap: { [_]: uint }
    input: [...uint8]
    memorySize: uint

    let numTokens = len(tokens)

    _#impl: [depth = =~"^\\d+$"]: {
        let next = "\(strconv.Atoi(depth) + 1)"

        memory: [...int]
        output: [...uint8]
        instructionPointer: uint
        pointer: uint
        inputPointer: uint

        if instructionPointer == numTokens {
            out: [{
                "memory": memory
                "output": output
                "pointer": pointer
                "inputPointer": inputPointer
            }]
        }

        if instructionPointer < numTokens {
            let token = tokens[instructionPointer]

            if token == _#tokens.gt {
                out: [] + ((_#impl & {(next): _})[next] & {
                    "memory": memory
                    "output": output
                    "instructionPointer": instructionPointer + 1
                    "pointer": pointer + 1
                    "inputPointer": inputPointer + 0
                }).out
            }

            if token == _#tokens.lt {
                out: [] + ((_#impl & {(next): _})[next] & {
                    "memory": memory
                    "output": output
                    "instructionPointer": instructionPointer + 1
                    "pointer": pointer - 1
                    "inputPointer": inputPointer + 0
                }).out
            }

            if token == _#tokens.plus {
                out: [] + ((_#impl & {(next): _})[next] & {
                    "memory": [for i, cell in memory {
                        if i == pointer {
                            cell + 1
                        }

                        if i != pointer {
                            cell + 0
                        }
                    }]
                    "output": output
                    "instructionPointer": instructionPointer + 1
                    "pointer": pointer + 0
                    "inputPointer": inputPointer + 0
                }).out
            }

            if token == _#tokens.minus {
                out: [] + ((_#impl & {(next): _})[next] & {
                    "memory": [for i, cell in memory {
                        if i == pointer {
                            cell - 1
                        }
                        if i != pointer {
                            cell + 0
                        }
                    }]
                    "output": output
                    "instructionPointer": instructionPointer + 1
                    "pointer": pointer + 0
                    "inputPointer": inputPointer + 0
                }).out
            }

            if token == _#tokens.period {
                out: [] + ((_#impl & {(next): _})[next] & {
                    "memory": memory
                    "output": output + [memory[pointer]]
                    "instructionPointer": instructionPointer + 1
                    "pointer": pointer + 0
                    "inputPointer": inputPointer + 0
                }).out
            }

            if token == _#tokens.comma {
                out: [] + ((_#impl & {(next): _})[next] & {
                    "memory": [for i, cell in memory {
                        if i == pointer {
                            if inputPointer < len(input) {
                                input[inputPointer]
                            }
                            if inputPointer >= len(input) {
                                0
                            }
                        }
                        if i != pointer {
                            cell + 0
                        }
                    }]
                    "output": output
                    "instructionPointer": instructionPointer + 1
                    "pointer": pointer + 0
                    "inputPointer": inputPointer + 1
                }).out
            }

            if token == _#tokens.lbracket {
                if memory[pointer] == 0 {
                    out: [] + ((_#impl & {(next): _})[next] & {
                        "memory": memory
                        "output": output
                        "instructionPointer": bracketMap["\(instructionPointer)"] + 1
                        "pointer": pointer + 0
                        "inputPointer": inputPointer + 0
                    }).out
                }

                if memory[pointer] != 0 {
                    out: [] + ((_#impl & {(next): _})[next] & {
                        "memory": memory
                        "output": output
                        "instructionPointer": instructionPointer + 1
                        "pointer": pointer + 0
                        "inputPointer": inputPointer + 0
                    }).out
                }
            }

            if token == _#tokens.rbracket {
                if memory[pointer] == 0 {
                    out: [] + ((_#impl & {(next): _})[next] & {
                        "memory": memory
                        "output": output
                        "instructionPointer": instructionPointer + 1
                        "pointer": pointer + 0
                        "inputPointer": inputPointer + 0
                    }).out
                }

                if memory[pointer] != 0 {
                    out: [] + ((_#impl & {(next): _})[next] & {
                        "memory": memory
                        "output": output
                        "instructionPointer": bracketMap["\(instructionPointer)"] + 1
                        "pointer": pointer + 0
                        "inputPointer": inputPointer + 0
                    }).out
                }
            }
        }
    }

    out: ((_#impl & {"0": _})["0"] & {
        memory: [for _ in list.Range(0, memorySize, 1) {0}]
        output: []
        instructionPointer: 0
        pointer: 0
        inputPointer: 0
    }).out[0]
}

#run: {
    sourceCode: string
    input: [...uint8]
    memorySize: uint

    out: string

    _lexed: (_#lex & {
        "sourceCode": sourceCode
    }).out

    _parsed: (_#parse & _lexed).out

    _evaluated: (_#eval & _parsed & {
        "input": input
        "memorySize": memorySize
    }).out

    out: strings.Join([for c in _evaluated.output { _#uint7ToString[c] }], "")
}
