# cue-bf
A Brainfuck interpreter written in CUE.

## Hello World!
```bash
$ cue version
cue version v0.11.0

go version go1.23.3
      -buildmode exe
       -compiler gc
       -trimpath true
     CGO_ENABLED 0
          GOARCH amd64
            GOOS linux
         GOAMD64 v1
cue.lang.version v0.11.0

$ cue export -e '(#run & { sourceCode: "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", input: [] }).out' ./bf.cue
"Hello World!\n"
```

It also works with `CUE_EXPERIMENT=evalv3`, and it is fatser than evalv2!

```bash
$ time cue export -e '(#run & { sourceCode: "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", input: [] }).out' ./bf.cue
"Hello World!\n"
cue export -e  ./bf.cue  37.10s user 1.26s system 144% cpu 26.581 total

$ time CUE_EXPERIMENT=evalv3 cue export -e '(#run & { sourceCode: "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", input: [] }).out' ./bf.cue
"Hello World!\n"
CUE_EXPERIMENT=evalv3 cue export -e  ./bf.cue  57.95s user 2.14s system 389% cpu 15.416 total
```
