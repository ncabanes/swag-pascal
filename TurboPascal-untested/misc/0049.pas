{
KAI ROHRBACHER

I'm looking For a way to tell BorlandPascal that an allocated _data_
block should now be treated as an executable routine (in Protected Mode).
Here is a little example to show the problem; it runs w/o problems in
Real Mode, but results in a GP-fault (despite the use of the alias-selector!):
}

Program SelfModify;

Const
  AnzNOPs = 10;

Type
  TTestProc = Procedure;

Var
  code : Pointer;
  Run  : TTestProc;
  pb   : ^Byte;
  pw   : ^Word Absolute pb;
  i    : LongInt;

begin
  GetMem(code, AnzNOPs + 7); {7 Bytes For proc header & end}
  pb := code; {pb = ^start of routine to build}

  pb^ := $55;
  INC(pb);   {push bp}
  pw^ := $E589;
  INC(pw); {mov bp,sp}
  For i := 1 to AnzNOPs DO
  begin
    pb^ := $90;
    INC(pb); {nop's}
  end;
  pb^ := $5D;
  INC(pb);   {pop bp}
  pb^ := $CA;
  INC(pb);
  pw^ := $0000;          {retf 0}

  {$IFDEF DPMI}
  WriteLN('Protected Mode');
  code:= Ptr(Seg(code) + SelectorInc, Ofs(code)); {alias-selector}
  {$else}
  WriteLN('Real Mode');
  {$endIF}

  Run := TTestProc(code); {that's a Type-cast!}
  Run; {call routine}

  FreeMem(code, AnzNOPs + 7);
  WriteLN('Alive and kicking!');
end.
