(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0017.PAS
  Description: Input Routine
  Author: EDDY JANSSON
  Date: 11-26-94  05:00
*)

{ Version 1.5 of...
  Yet Another, Quite General Input Routine (YA-QGIR, pronounced YA-QJUGEER)
  --------------------------------------------------------------------------
  This one is (C)1993,1994 Eddy Jansson, P.I - No Rights Reserved.
  The following routines may be used in your own programs, as long as
  you promise to modify them to meet your own needs.

  Ofcourse I take *NO* responsability for any injuries inflicted on man
  or animal or cause of dataloss from these routines. These routines
  may NOT be used in whole, or in part, in any life supporting, nuclear
  or weapon related systems.

 // Eddy Jansson    FidoNet: 2:206/406
                   InterNet: eddy.jansson@haricot.ct.se

Usage of the Input Routine:

Function Input(X,Y: Byte;StartStr,BackG,PassChar: String;MaxLen,StartPos:
               Integer;AcceptSet: CharSet;Ins: Boolean;var InputStatus: Byte):
String;
X,Y         Where on screen to put the input.
StartStr    Default input string.
BackG       Background Character, eg ' ' or '░' etc.
PassChar    If defined this character will be displyed instead of the input
stream.MaxLen      MaxLen of Input.
StartPos    Where in input string to place the cursor, -1 = End of StartStr
AcceptSet   Which characters should be accepted as input, often [#32..#255]
            NOTE: if you include #8 in this mask, you cannot use delete.
Ins         Begin in INSERT or OVERWRITE mode (Boolean)
InputStatus Upon exit from the input routine this variable will hold:
            13 = Input terminated with Enter.
            27 = Input terminated with ESC.
            72 = User pressed UpArrow
            80 = User pressed DownArrow
            73 = User pressed Page Up
            81 = User pressed Page Down
            etc...

 Next Version: Window (ie; edit 255 chars in a 16 char window)
               ExitChar Mask
}

Uses Crt;

type
 CharSet = Set of #0..#255; { This MUST be present for the routine to work }

var
 S      :String[80];
 IS     :Byte;

{ ------ START OF GENERAL ROUTINES ------ }

Function Left(s: String;nr: byte): String;
begin
 Delete(s,nr+1,length(s));
 Left:=s;
end;

Function Mid(s: String;nr,nr2: byte): String;
begin
 Delete(s,1,nr-1);
 Delete(s,nr2+1,length(s));
 Mid:=s;
end;

Procedure WriteXY(x,y: Byte;s: String);
var
loop:   Word;
begin (* This can be _higly_ optimized *)
 for loop:=x to x+length(s)-1 do
Mem[$B800:(loop-1)*2+(y-1)*160]:=Ord(S[loop-x+1]);end;

Function RepeatChar(s: String;antal: byte): String;
var
 temp: String;
begin
temp:=s[1];
 While Length(temp)<Antal do Insert(s[1],temp,1);
RepeatChar:=Temp;
end;

Procedure NormalCursor; Assembler;
asm
 mov ah,1
 mov ch,6
 mov cl,7
 int $10
end;

Procedure BlockCursor; Assembler;
asm
 mov ah,1
 mov ch,0
 mov cl,7
 int $10
end;

{ ------ END OF GENERAL ROUTINES ------ }

Function Input(X,Y: Byte;StartStr,BackG,PassChar: String;MaxLen,StartPos:
               Integer;AcceptSet: CharSet;Ins: Boolean;var InputStatus: Byte):
String;{Version 1.5}
Var
P         :Byte;
Exit      :Boolean;
ch        :Char;
ext       :Char;
s         :String;
t         :String[1];

begin
Exit:=False;                                      { Don't quit on me yet! }
if Length(PassChar)>1 then PassChar:=PassChar[1]; { Just in Case... ;-) }
if Length(BackG)>1 then BackG:=BackG[1];
if Length(BackG)=0 then BackG:=' ';
if Length(StartStr)>MaxLen then StartStr:=Left(StartStr,MaxLen);
if StartPos>Length(StartStr) then StartPos:=Length(StartStr);
if StartPos=-1 then StartPos:=Length(StartStr);
If StartPos>=MaxLen then StartPos:=MaxLen-1;

s:=StartStr;                                { Put StartStr into Edit Buffer }
WriteXY(X,Y,RepeatChar(BackG,MaxLen));

if StartStr<>'' then begin
if passchar='' then WriteXY(X,Y,StartStr) else
                    WriteXY(X,Y,RepeatChar(PassChar,Length(StartStr)));
end;

p:=StartPos;
GotoXY(X+StartPos,Y);

repeat
 if Ins then NormalCursor else BlockCursor;
 ext:=#0;
 ch:=ReadKey;
 if ch=#0 then ext:=ReadKey;
 if ch=#27 then begin
                 InputStatus:=27;
                 Exit:=True;
                end;
{   (ch<#255) and (ch>#31) }
if ch in AcceptSet then
 begin   { Welcome to the jungle...}
  t:=ch;
   if (p=length(s)) and (Length(s)<MaxLen) then
    begin
     s:=s+t;
     if PassChar='' then WriteXY(X+P,Y,T) else WriteXY(X+P,Y,PassChar);
     Inc(p);
    end else
     if length(s)<MaxLen then begin
      if Ins then Insert(T,S,P+1) else s[p+1]:=Ch;
      if PassChar='' then WriteXY(X+P,Y,Copy(S,P+1,Length(S))) else
WriteXY(X+Length(S)-1,Y,PassChar);      Inc(p);
     end else if (Length(s)=MaxLen) and (not Ins) then
      begin
       s[p+1]:=ch;
       if PassChar='' then WriteXY(X+P,Y,T) else WriteXY(X+P,Y,PassChar);
       Inc(p);
      end;
   ch:=#0;
   if p>MaxLen-1 then p:=MaxLen-1;
   GotoXY(X+P,Y);
  end else begin

 case ch of { CTRL-Y }
  #25:   begin
          WriteXY(X,Y,RepeatChar(BackG,Length(S)));
          P:=0;
          S:='';
          GotoXY(X,Y);
         end;

 {Backspace}
 #8: If (P>0) then
  begin
   if (p+1=MaxLen) and (p<length(s)) then Ext:=#83 else
    begin
     Delete(S,P,1);
     Dec(P);
     GotoXY(X+P,Y);
      if PassChar='' then WriteXY(X+P,Y,Copy(S,P+1,Length(s))+BackG) else
       if P>0 then WriteXY(X+Length(s)-1,Y,PassChar+BackG) else
        WriteXY(X+Length(s),Y,BackG);
    end;
  end;

  #9: begin { Exit on TAB }
       InputStatus:=9;
       Exit:=True;
      end;

 #13: begin
       InputStatus:=13;
       Exit:=True;
      end;
 end; { Case CH of }

 case ext of
 #75: if P>0 then begin
 {Left Arrow}      Dec(P);
                   GotoXY(X+P,Y);
                  end;

 #77: if (P<Length(s)) and (P+1<MaxLen) then begin
 {Right Arrow}             Inc(P);
                           GotoXY(X+P,Y);
                          end;

 #82: Ins:=Not(Ins); {Insert}
 {Delete}
 #83: If P<Length(s) then
  begin
   Delete(S,P+1,1);
    if PassChar='' then WriteXY(X+P,Y,Copy(S,P+1,Length(s))+BackG) else
     if p>0 then WriteXY(X+Length(S)-1,Y,PassChar+BackG) else
      WriteXY(X+Length(S),Y,BackG);
   end;

 #71: begin
       p:=0;
       GotoXY(X+P,Y);
      end;

 #79: begin
       p:=Length(s);
       if p>=MaxLen then P:=MaxLen-1;
       GotoXY(X+P,Y);
      end;

 #72,#73,#80,#81,#59..#68:
  begin
   InputStatus:=Ord(Ext);
   Exit:=True;
  end;

 end; {Case of EXT }
end; { if not normal char }

until Exit;
Input:=S;
end;

BEGIN
 Write('Enter Your Name: ');
 S:=Input(WhereX,WhereY,'KLoPPeR','░','',35,-1,[#32..#175],True,IS);
 WriteLn;
 WriteLn('Hello '+S+', have a nice day today!');
END.

