{
> Do you have some code that will produce a Program that makes
> self-viewing Text Files (like txt2com)?

 This adds a small Text File to a loader which simply reads through the
 data and sends it to the ANSI driver, so it's good For ANSIs or Text
 Files that will fit in one screen.

 However you could change the loader (if you know assembly) to do paUses
 or output the File to STDOUT so you can use the more-pipe (|more).
}

(* MakeMsg v0.00 - Public Domain by Robert Rothenburg 1993 *)

Program MakeMessage;
Const
  loader : Array [0..14] of Byte =
      ($BE,$0F,$01,$B9,$00,$00,$FC,$AC,$CD,$29,$49,$75,$FA,$CD,$20);
Var
  fin, fout : File;
  nin, nout : String;
  buffer    : Array [0..4095] of Byte;
  i         : Word;

begin
  Writeln('"MakeMsg" v0.00');
  if ParamCount <> 2 then
    Writeln('Usage: MAKEMSG TextFile execFile')
  else
  begin
    nin  := ParamStr(1);
    nout := ParamStr(2);
    Assign(fin, nin);
    reset(fin, 1);
    Assign(fout, nout);
    reWrite(fout, 1);
    i := Filesize(fin);
    loader[4] := lo(i);
    loader[5] := hi(i);
    BlockWrite(fout, loader[0], 15);
    Repeat
      BlockRead(fin, Buffer[0], 4096, i);
      BlockWrite(fout, Buffer[0], i)
    Until i = 0;
    close(fin);
    close(fout);
    Writeln('Done.');
  end;
end.
