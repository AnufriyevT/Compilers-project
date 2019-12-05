gppg.exe /no-lines iterative.y
csc.exe /r:QUT.ShiftReduceParser.dll iterative.cs -recurse:ast\*.cs  -recurse:semantic\*.cs 