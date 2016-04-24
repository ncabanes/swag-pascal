(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0041.PAS
  Description: SB Talk Unit
  Author: MIRKO HOLZER
  Date: 05-25-94  08:22
*)

{
> Hi! I have the following problem:
> I'm trying to get my Sound Blaster card (version 1.0) to speak a string,
> like the SAY.EXE program that comes with SB.

(Sorry for the german comments, but I'm to lazy to rewrite them ≡:-|) }

Program Talk;
{ by Mirko Holzer; 16.2.1994 }

Uses
  Crt,
  Dos,
  Strings;

Const
  cSBTalkSig='FB ';

Type
  tTalkEpStruc=record
    Signature: array[0..2] of char;  {Signatur: "FB "}
    MajorVers: byte;                 {Hauptversion ??}
    Entry: pointer;                  {Treiber Einsprungadresse}
    Unknown: array[0..23] of byte;   {Weiß nicht was da drin steht...}
    DataLen: byte;                   {Länge des zu sprechenden Strings}
    TalkStr: array[0..255] of char;  {Zu sprechender String}
  end;
  pTalkEpStruc=^tTalkEpStruc;

Var
  sbt: pTalkEpStruc;
  eing: string;


Function ChkSBT: pointer; assembler;
asm
  mov ax,$FBFB
  mov bx,0
  mov es,bx
  int $2F
  mov dx,es
  mov ax,bx
end;

Procedure TalkIt(var sb: pTalkEpStruc; what: string);
Var
  SBCall: pointer;
begin
  sb^.DataLen:=Length(what);
  StrPCopy(sb^.TalkStr,what);
  SBCall:=sb^.Entry;
  asm
    les di,sb
    mov bx,di
    mov al,$07
    call [sbcall]
  end;
end;



begin
  sbt:=ChkSBT;
  ClrScr;
  Writeln('SBTalker - Test');
  Writeln('16.2.94 von Mirko Holzer');
  Writeln;
  If sbt^.Signature<>cSBTalkSig then
  begin
    Writeln('The program sbtalk.exe is not installed.');
    Writeln('Programm beendet.');
    Writeln;
    Halt;
  end;
  TalkIt(sbt,'Hello, here is S B talker speaking... Please enter your string '+
             'or press enter to stop the program.');
  Writeln('Zu sprechenden String eingeben oder <ENTER> drücken für Ende.');
  Repeat
    eing:='';
    Readln(eing);
    TalkIt(sbt,eing);
  Until eing='';
  TalkIt(sbt,'Look out for Demos from.... Terrible Minds Productions');
  Writeln;
end.



