{
   I found the following code in my Utils unit and repackaged into a new
   unit. It compiles and works on my PC, but as Im sure everyone will
   agree, this programming style is rather dirty! It assumes the keyboard
   buffer is in the same location in memory on every pc. I really should
   be using an interrupt but never got around to it.
   Remember that you have a limit of only 16 characters in the buffer.

   Anywayz hope it helps...

   {-----------------------------------CUT HERE------------------------}

UNIT KeyStuff;

Interface

Var
  keyrec : array [1..16] of
             record
               ch ,
               scan : char;
             end absolute $0000:1054;
  KeyPtr1: byte absolute 0000:1050;
  KeyPtr2: byte absolute 0000:1052;

  Procedure AdvanceKeyTail;
  Procedure AdvanceKeyHead;
  procedure FlushBuffer;
  procedure StuffBufferKey(ch,Scan : char);
  procedure StuffBuffer(W:word);
  procedure StuffBufferStr(Str:string);
  function  tail:byte;
  Function  head:byte;

Implementation
uses dos;

Procedure AdvanceKeyTail;
{Moves the keyboard tail ptr forward}
begin
  inc(KeyPtr1,2);
  if keyptr1 > 60 then keyptr1 := 30;
end;

Procedure AdvanceKeyHead;
{Moves the keyboard Head ptr forward.
Turbo's KeyPressed function will now return True}
begin
  inc(KeyPtr2,2);
  if keyptr2 > 60 then keyptr2 := 30;
end;

procedure FlushBuffer;
{Clear Keyboard Buffer}
var Regs: registers;
begin
   with Regs do
   begin
      Ax := ($0c shl 8) or 6;
      Dx := $00ff;
   end;
   Intr($21,Regs);
end;

procedure StuffBufferKey(ch,Scan : char);
{Puts keyboard scan code directly into the buffer
Examples. #65,#0 = Simulate an 'A' being pressed
          #0,#59 = Simulate the F1 key being pressed
}
begin
   keyrec[head].ch := ch;
   keyrec[head].scan := scan;
   AdvanceKeyhead;
end;

procedure StuffBuffer(W:word);
{Put Word directly into the buffer}
begin
   keyrec[head].ch := chr(lo(w));
   keyrec[head].scan := chr(hi(w));
   AdvanceKeyhead;
end;

procedure StuffBufferStr(Str:string);
{Stuffs a string into the buffer. Remember the max of 16 chars.}
var I,L : byte;
begin
   if Str <> '' then
   begin
      I := 1;
      L := length(Str);
      while I <= L do
      begin
         StuffBuffer(ord(Str[I]));
         inc(I);
      end;
   end;
end;

function Tail:byte;
{Returns number between 1 and 16 showing where tail is}
begin
  tail := KeyPtr1 div 2 - 14;
end;

Function Head:byte;
{Returns number between 1 and 16 showing where head is}
begin
  head := KeyPtr2 div 2 - 14;
end;

end.

   {-----------------------------------CUT HERE------------------------}

*********************
Example of use...
*********************

Uses Keystuff;

begin
  StuffBufferStr('Hello There!'#13);
  Write('>');
  Readln;
  halt;
end.
