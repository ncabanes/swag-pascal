Hi! Someone was needing help speeding up a duplicate line finder.
Here is what I came up with (it's tested, TP 6.0)
It needs the txtSeek unit I'm also posting here. I converted txtSeek
from some code I found here (written in German), hope that person
doesn't mind...

{D-,I-,L-,R-,X+}
unit TxtSeek;
interface

 function TextFilePos(var f:text):LongInt;         {FilePos}
 function TextFileSize(var f:text):LongInt;        {FileSize}
 procedure TextSeek(var f:text;Pos:LongInt);       {Seek}
 procedure TextSeekRel(var f:text; Count:Longint); {Relative Seek}

implementation
uses dos;

const
 sAbs=0;     { for use with DosSeek }
 sRel=1;
 sEnd=2;

function DosSeek(handle:word; posn:LongInt; func:byte):longint;assembler;asm
 mov ah,$42; mov al,func; mov bx,handle;
 mov dx,word ptr posn; mov cx,word ptr posn+2; int $21;
 jnc @S; mov inOutRes,ax; xor ax,ax; xor dx,dx; @S:
 end;

function TextFilePos(var f:text):LongInt;begin
 textFilePos:=DosSeek(Textrec(f).handle,0,sRel)
               -TextRec(f).BufEnd+TextRec(f).BufPos;
 end;

function TextFileSize(var f:text):LongInt;var Temp:LongInt;begin
 case TextRec(f).Mode of
  fmInput:with Textrec(f) do begin
           Temp:=DosSeek(handle, 0, sRel);
           textFileSize:=DosSeek(handle, 0, sEnd);
           DosSeek(handle, Temp, sAbs);
           end;
  fmOutput:textFileSize:=TextFilePos(f);
  else begin
   textFileSize:=0;
   InOutRes:=1;
   end;
  end;
 end;

procedure TextSeek(var f:text; Pos:LongInt);begin
 dosSeek(textRec(f).handle, pos, sAbs);
 textRec(f).bufPos:=textRec(f).bufEnd;  {force read}
 end;

procedure TextSeekRel(var f:text; Count:LongInt);begin
 dosSeek(textRec(f).handle, count, sRel);
 textRec(f).bufPos:=textRec(f).bufEnd;  {force read}
 end;

end.

<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

{$A-,B-,D-,E-,F-,G+,I-,L-,N-,O-,R-,S-,V-,X+}
{$M $800,$8000,$8000} {require heap memory}
Uses Crt,txtSeek;

type bufType=array[0..32767] of char;  {try this, it's a nice round binary #}
Var
 buff:^bufType;
 f, f2:Text;
 looking,s,parm:String[80];
 n,siz:Longint;
 dupes:word;

Procedure CheckError(Err:integer); Begin
 TextColor(12);
 Case Err Of
  -1: WriteLn('You must specify a file on the command line.');
  2: WriteLn('Can''t find "', parm,'"');
  4: WriteLn('Too many open files to open ', parm);
  3,5..162: WriteLn('Error in reading ', parm);
  End;
 if err<>0 then begin WriteLn; Halt(1);end;
 End;

Begin
 If Paramcount<1 Then CheckError(-1);
 parm:=paramstr(1);
 Assign(f,parm);
 New(buff);
 SetTextBuf(f,buff^);
 Reset(f);
 checkError(IoResult);
 Assign(f2,'FINDDUPE.$$$');
 ReWrite(f2);
 checkError(IoResult);
 siz:=textFileSize(f);
 Writeln('Deleting duplicate lines');
 write('  0% complete');
 n := 0;
 dupes:=0;
 Reset(f);
 While not eof(f) Do Begin
  Readln(f,Looking);
  n:=textFilePos(f);
  repeat
   Readln(f, s);
   until (s=looking) or eof(f);
  if eof(f)then writeln(f2, looking) else inc(dupes);
  Write(^M,(n*100)div siz:3);
  textSeek(f, n);
  End;
 Close(f);
 erase(f);   {erase original file}
 Close(f2);
 rename(f2,parm);  {rename temp file on top of it}
 dispose(buff);
 writeln(^M'Found ',dupes,' duplicates');
 End.


 * OLX 2.2 * This tagline was created with 100% recycled electrons...

--- Maximus 2.01wb
 * Origin: >>> Sun Mountain BBS <<< (303)-665-6922 (1:104/123)
              