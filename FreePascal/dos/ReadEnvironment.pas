(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0092.PAS
  Description: Read Environment
  Author: JOSE ANTONIO NODA
  Date: 09-04-95  10:45
*)

(*
   Program Name : Read Environment v.1.0
   Compiler     : Turbo Pascal v.6.0

   Jose Antonio Noda
   Compuserve ID   100667,2523

*)

Program ReadEnvironment;

Uses Crt, Dos;

Function Hex(a : word; b : byte) : string;
const
  digit   : array[$0..$F] of char = '0123456789ABCDEF';
var
  i       : byte;
  xstring : string;
Begin
  xstring:='';
  for i:=1 to b do
  Begin
    Insert(digit[a and $000F], xstring, 1);
    a:=a shr 4
    end;
  hex:=xstring
end;

procedure ReadEnviro;
var
  {temp, temp1, envseg, envlen, envused: word;
  foundit, endfound: boolean;
  osmajor : byte;
  osminor : byte;}
  i       : Word;
Begin
  {temp:=MemW[PrefixSeg:$16];
  foundit:=false;
  while not foundit do
    begin
    temp1:=MemW[temp:$16];
    if (temp1 = 0) or (temp1 = temp) then
      foundit:=true
    else
      temp:=temp1
    end;
  envseg:=MemW[temp:$2C];
  if (envseg = 0) or ((osminor > 19) and (osminor < 30)) then
    envseg:=temp + MemW[temp-1:3] + 1;
  envlen:=MemW[envseg - 1:3] * 16;
  envused:=0;
  endfound:=false;
  while not endfound do
    if MemW[envseg:envused] = 0 then
      endfound:=true
    else
      Inc(envused);
  Inc(envused, 2);
  Writeln('Environment');
  Write('   Segment ');
  Write(hex(envseg, 4));
  Write('  Size  ');
  Write(envlen:4);
  Write('  Used  ');
  Write(envused:4);
  Write('  Free  ');
  Writeln((envlen - envused):4);
  Writeln;}
  Writeln('Variables');
  Writeln;
  for i:=1 to envcount do begin
    writeln(envstr(i))
  end
end;

Begin
  ClrScr;
  Writeln('┌─────────────────────────────────────────────────────────────────────────────┐');
  Writeln('│            Read Environment v.1.0          (C) Jose Antonio Noda.           │');
  Writeln('└─────────────────────────────────────────────────────────────────────────────┘');
  Writeln;
  ReadEnviro;
  Writeln;
end.

