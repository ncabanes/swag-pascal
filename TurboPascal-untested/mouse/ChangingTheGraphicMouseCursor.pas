(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0039.PAS
  Description: Changing the Graphic Mouse Cursor
  Author: SAMIEL@FASTLANE.NET
  Date: 08-30-96  09:35
*)

{
Here's a program (unit) I just wrote that has a few nifty
applications.  It captures a 16x16 area on the mode 13h screen and
converts the coordinates to a "mouse" array.  Please note that there
is a demo program included.  You may modify the programs if you wish.
Please e-mail me if you have any comments or questions...

One great application is loading a graphics file and then capturing
the mouse of the screen.  It's good for changing the mouse cursor to
anything you can print (i.e. text, pictures).  Remember, 16x16 isn't a
great deal to work with...

Here's the UNIT... the DEMO PROGRAM follows...

{--- Cut Here ---}

UNIT MCAP;

{
Well, I hope some of you find this somewhat useful...
Feel free to modify the code and such...
E-mail questions or comments to samiel@fastlane.net
Visit http://www.fastlane.net/~samiel
See the demo program...
Code is not optimized (though I tried a little)
Author is not responsible for any damages incurred
Try not to move the Capture box over the mouse...
Capture box outline also included in making 16x16 mouse...
Load a mouse driver!
<ESC> exits!

CAPTURES MOUSE FROM THE 320x200x256c SCREEN (MODE 0x13)

-------+---------------
 Color |     ID
-------+---------------
   0   | Make Color 0
-------+---------------
   15  | Make Color 15
-------+---------------
   1   | Translucent    (Opposite color shows)
-------+---------------
 Other | Transparent    (All other colors are transparent) 
-------+---------------
}

INTERFACE

TYPE
  Box=array [0..255] of byte; {16x16 box to capture 16x16 area}

CONST
  HexString='$'; {Add to the beginning of the hex number (i.e. '0x')}
  Z=255; {Box outline color}
  Capture:Box= {Define 16x16 capture box}
    (Z, 0,0, Z,Z, 0,0, Z,Z, 0,0, Z,Z, 0,0, Z,
     
     0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,
     0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,
     
     Z, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, Z,
     Z, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, Z,
     
     0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,
     0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,
     
     Z, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, Z,
     Z, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, Z,

     0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,
     0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,
     
     Z, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, Z,
     Z, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, Z,
     
     0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,
     0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,
     
     Z, 0,0, Z,Z, 0,0, Z,Z, 0,0, Z,Z, 0,0, Z);

Procedure ResetMouse(var Installed:boolean;var Buttons:word);
Procedure MouseOn;  
Procedure MouseOff;
Procedure GetMouse(FileName:string);

IMPLEMENTATION

Procedure ResetMouse(var Installed:boolean;var Buttons:word);
Var
  tmp1,tmp2:word;
Begin  
  asm
    mov ax,0
    int 33h
    mov tmp1,ax
    mov tmp2,bx
  end;
  if tmp1=$FFFF then
    Installed:=true
  else
    Installed:=false;
  Buttons:=tmp2;
End;

Procedure MouseOn;Assembler;  
Asm
  mov ax,1
  int 33h
End;

Procedure MouseOff;Assembler;
Asm
  mov ax,2
  int 33h
End;

Procedure GetMouse(FileName:string);
Type
  Mouse=array [1..32] of word;
Var
  Installed,Good:boolean;
  Buttons:word;
  F:Text;
  Save:Box;
  x,y:word;
  key:word;
  j,k:word;
  M:Mouse;
  count:word;

  {Other Procedures I was too lazy to make Interfaces for...}
  
  Procedure NewMouse(M:mouse);
  var
    s,o:word;
  begin
    s:=Seg(M);
    o:=Ofs(M);
    asm
      mov ax,9
      mov bx,0
      mov cx,0
      mov es,s
      mov dx,o
      int 33h
    end;
  end;

  function GetKey:word;assembler;
  asm
    mov ax,10h
    int 16h
  end;

  Function D2H(w:word):string;
  Const
    Hex:array [$0..$F] of char=
    '0123456789ABCDEF';
  Var
    tmp:string;
  Begin
    tmp:=Hex[Hi(w) shr 4]+Hex[Hi(w) and $F]+
         Hex[Lo(w) shr 4]+Hex[Lo(w) and $F];
    D2H:=HexString+tmp;
  End;

  procedure GetBox(x,y:word;var B:Box);
  var
    j,k:word;
    tmp:byte;
  begin
    for k:=0 to 15 do
      for j:=0 to 15 do
        B[j+(k*16)]:=mem[$A000:x+j+(320*(y+k))];
  end;

  procedure PutBox(x,y:word;B:Box;IsSaved:boolean);
  var
    j,k:word;
    tmp:byte;
  begin
    for k:=0 to 15 do
      for j:=0 to 15 do
        begin
          tmp:=B[j+16*k];
          if (tmp<>0) or IsSaved then
            mem[$A000:x+j+(320*(y+k))]:=tmp;
        end;
  end;

Begin
  ResetMouse(Installed,Buttons);
  {Check for good file name and installed mouse}
  {$I-}
  assign(F,FileName);
  rewrite(F);
  Good:=(IOResult=0) and (FileName<>'') and Installed;
  if not Good then
    close(F);
  {$I+}
  for j:=1 to 32 do
    M[j]:=$FFFF;
  x:=0;
  y:=0;
  count:=0;
  if Installed then
    begin
      NewMouse(M);
      MouseOn;
    end;
  GetBox(x,y,Save);
  PutBox(x,y,Capture,false);
  repeat
    key:=GetKey;
    case key of
      $4800,$1177,$1157: {Up, w, W}
        if y>0 then
          begin
            PutBox(x,y,Save,true);
            dec(y);
            GetBox(x,y,Save);
            PutBox(x,y,Capture,false);
          end;
      $5000,$1F73,$1F53: {Down, s, S}
        if y<199 then 
          begin
            PutBox(x,y,Save,true);
            inc(y);
            GetBox(x,y,Save);
            PutBox(x,y,Capture,false);
          end;
      $4B00,$1E61,$1E41: {Left, a, A}
        if x>0 then 
          begin
            PutBox(x,y,Save,true);
            dec(x);
            GetBox(x,y,Save);
            PutBox(x,y,Capture,false);
          end;
      $4D00,$2064,$2044: {Right, d, D}
        if x<319 then
          begin
            PutBox(x,y,Save,true);
            inc(x);
            GetBox(x,y,Save);
            PutBox(x,y,Capture,false);
          end;
      $1C0D: {Enter}
        begin
          for j:=1 to 32 do
            M[j]:=0;
          for j:=0 to 15 do 
            begin
              for k:=0 to 15 do
                begin
                  case Save[k+j*16] of
                    0: {Leave as is, color 0}
                      ;
                    1: {Translucent}
                      begin
                        M[j+1]:=M[j+1] OR (1 shl (15-k));
                        M[j+17]:=M[j+17] OR (1 shl (15-k));
                      end;
                    15: {Color 15}
                      begin
                        M[j+17]:=M[j+17] OR (1 shl (15-k));
                      end;
                    else {Transparent}
                      begin
                        M[j+1]:=M[j+1] OR (1 shl (15-k));
                      end;
                  end;
                end;
            end;
          if Installed then
            begin
              ResetMouse(Installed,Buttons);
              NewMouse(M);
              MouseOn;
            end;
          if Good then
            begin
              inc(count);
              writeln(F,'{ Capture #',count:1,'}');
              writeln(F,'(');
              for k:=1 to 8 do
                begin
                  for j:=1 to 4 do
                    begin
                      write(F,D2H(M[j+4*(k-1)]));
                      if (j=4) and (k=8) then
                        {Do Nothing}
                      else
                        write(F,',');
                    end;
                  writeln(F);
                end;
              writeln(F,');');
              writeln(F);
            end;
        end;
    end;
  until key=$011B; {Esc}
  if Installed then
    MouseOff;
  if Good then
    close(F);
End;

BEGIN
  {Nothing Here}
END.

{--- Cut Here ---}

Here's the DEMO Program!

{--- Cut Here ---}

{Demo Program for MCAP}

USES
  MCAP;

VAR
  count:word;

Function SomeColor:byte;
Var
  tmp:byte;
Begin
  { 0 - Color 0
    1 - Translucent
   15 - Color 15 }
  tmp:=random(256);
  if (tmp mod 4=0) then
    tmp:=1
  else if odd(tmp) then
    tmp:=15
  else
    tmp:=0;
  SomeColor:=tmp;
End;

BEGIN
  randomize;
  asm mov ax,13h;int 10h;end; {Set 320x200x256c mode (13h)}
  count:=0;
  repeat
    mem[$A000:count]:=0;
    inc(count);
  until count=(16*320);
  repeat
    mem[$A000:count]:=15;
    inc(count);
  until count=(32*320);
  repeat
    mem[$A000:count]:=1;
    inc(count);
  until count=(48*320);
  repeat
    mem[$A000:count]:=5; {Transparent}
    inc(count);
  until count=(64*320);
  repeat
    mem[$A000:count]:=SomeColor; 
    inc(count);
  until count=(200*320);
  GetMouse('mouse.dat');
  asm mov ax,3h;int 10h;end; {Set 80x25 text mode (3h)}
END.


