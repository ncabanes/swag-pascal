
{ This program uses a proc from my pascal library that I use to get
  true names. Written and tested with tp4  should work with any tp and
  dos 3.1+  gm 05/94 }
uses
  dos;
  {--05/93 gary a. mays --}
  {  this procedure uses the undocumented dos function $60 to fetch the
     canonical name of a file or path specification }
  procedure canonicalize(path: string; var canonical: string;
                          var stat: word);
    var
      regs : registers;
      i : integer;
      bytes : byte absolute canonical;
  begin
    with regs do
    begin
      stat := 0;
      ah := $60;
      path := path + chr(0); { convert to asciz }
      ds := seg(path[1]); { asciz name }
      si := ofs(path[1]);
      es := seg(canonical[1]);{ points to 128 byte result buffer }
      di := ofs(canonical[1]);{ result is asciz }
      msdos(regs); { returns canonical name: does not have to exist... }
      if flags and fcarry > 0 then
        stat := ax
      else
      begin
        bytes := 0;
        while canonical[bytes + 1] <> #0 do inc(bytes); {conv to ascii}
        { not tested on a network - this test will fail on net drive }
        if canonical[2] <> ':' then { bad because of bad path }
          stat := 3;
      end;
    end;
  end; {canonicalize}

  var
    stat : word;
    path : string;
    canonical : string;
begin
  if paramstr(1) = '' then
    path := '.'
  else
    path := paramstr(1);
  canonicalize(path, canonical, stat);
  case stat of
  0: writeln(canonical);
  2: writeln('Invalid path: ',path);
  3: writeln('Invalid drive or malformed path: ',path);
  else writeln('Status: ',stat,' for ',path);
  end; {case}
end.


IL>  I'm looking for an equivalent to the DOS command TRUENAME. Here's an

program TruePath;
uses OpString,DOS;
var
  OldName, NewName : String;
  RegisterSet : Registers;
Begin
  OldName:=ParamStr(1);
  OldName[Length(OldName)+1] := #0;
  NewName[0] := #0;
  With RegisterSet do
  Begin
    AH := $60;
    AL := 0;
    DS := Seg(OldName[1]);
    SI := Ofs(OldName[1]);
    ES := Seg(NewName[1]);
    DI := Ofs(NewName[1]);
  End;
  MsDos(RegisterSet);
  If Odd(RegisterSet.Flags) Then
    Writeln('Failure ',RegisterSet.AX) (* failure code *)
  Else
  Begin
    NewName[0]:=#255;
    NewName[0]:=Chr(Pos(#0,NewName));
    Writeln(NewName);
  End;
End.
