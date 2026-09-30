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
cue export -e  ./bf.cue  0.67s user 0.09s system 129% cpu 0.593 total
```
