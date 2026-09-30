# cue-bf
A Brainfuck interpreter written in CUE.

## Hello World!
```bash
$ cue version
cue version (devel)

CUE language version v0.17.1

Go version go1.26.5
      -buildmode exe
       -compiler gc
       -trimpath true
  DefaultGODEBUG cryptocustomrand=1,tlssecpmlkem=0,urlstrictcolons=0
     CGO_ENABLED 1
          GOARCH amd64
            GOOS linux
         GOAMD64 v1

$ time cue export -e '(#run & { sourceCode: "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", input: [] }).out' ./bf.cue
"Hello World!\n"
cue export -e  ./bf.cue  0.18s user 0.04s system 140% cpu 0.161 total
```

## Sum of space-separated numbers
`input` is a list of bytes, which `strings.Runes` makes from a string. This program reads space-separated numbers of up to three digits from it until the input ends and prints their sum.

```bash
$ time cue export -e '(#run & { sourceCode: ">,[--------------------------------<+>[---------------->>[->+<]<[->+<]<[->+<]<->]<[->>[->>>+<<<]>[->>>>>+<<<<<]>[->>>>>>>+<<<<<<<]<<<<]>,]>[->>>+<<<]>[->>>>>+<<<<<]>[->>>>>>>+<<<<<<<]>>++++++++++<[->-[>+>>]>[+[-<+>]>+>>]<<<<<]>>>>++++++++++<[->-[>+>>]>[+[-<+>]>+>>]<<<<<]>>>>++++++++++<[->-[>+>>]>[+[-<+>]>+>>]<<<<<]>>>[[->+<]>>+<<]>>[-<++++++++++++++++++++++++++++++++++++++++++++++++.<<<<+>>>>>]<<<[[->+<]<<[-]+>>]<<[->>>++++++++++++++++++++++++++++++++++++++++++++++++.<<<<<<+>>>]<[[->+<]<<[-]+>>]<<[->>>++++++++++++++++++++++++++++++++++++++++++++++++.<<<]<++++++++++++++++++++++++++++++++++++++++++++++++.", input: strings.Runes("123 456 789") }).out' ./bf.cue
"1368"
cue export -e  ./bf.cue  1.51s user 0.35s system 140% cpu 1.327 total
```
