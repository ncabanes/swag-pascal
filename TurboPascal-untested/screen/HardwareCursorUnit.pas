(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0083.PAS
  Description: Hardware Cursor Unit
  Author: BJ�RN FELTEN
  Date: 05-26-95  22:59
*)

{
{ CURSORUN.PAS }

UNIT cursorUnit;
{
  Hey Guys and Gals! Please don't assume anything about what video
  mode I'm using on my computer! And, thus, don't tangle my
  cursor! This unit provides the =only= proper way to put the cursor
  on and off -- put the code you have been given by other people,
  that sets the cursor to some different, fixed states in order to
  show/hide it, where they all belong: in the Bit Bucket!
}

INTERFACE

type      cursorType = record eLine, sLine: byte end;

var       Cursor: cursorType;
{ since BP can't handle typecasting with macro functions,
  we'll also have use for this one: }
          xCursor: word absolute Cursor;
          oldCursor: word;

function  getCursor: word; inline(
  $B7/0/             { mov bh,0  }
  $B4/3/             { mov ah,3  }
  $CD/$10/           { int 10h   }
  $89/$C8);          { mov ax,cx }
procedure setCursor(C: word); inline(
  $59/               { pop cx    }
  $B4/1/             { mov ah,1  }
  $CD/$10);          { int 10h   }
procedure cursorOn;
procedure cursorOff;
procedure blinkSlow; { those three won't work on EGA/VGA }
procedure blinkFast;
procedure blinkNormal;

IMPLEMENTATION

procedure cursorOn;
begin setCursor(getCursor and not $2000) end;

procedure cursorOff;
begin setCursor(getCursor or $2000) end;

procedure blinkSlow;
begin setCursor(getCursor and not $2000 or $4000) end;

procedure blinkFast;
begin setCursor(getCursor or $6000) end;

procedure blinkNormal;
begin setCursor(getCursor and not $6000) end;

BEGIN { always save old cursor first }
   oldCursor:=getCursor
END.  { of Unit init }


{- And here's a short test program, that'll show you how to use the
   unit cursorUnit -}

program TestCursor; { test of Cursor unit }
{$D-,E-,G+,I-,L-,S-}

uses cursorUnit;

begin
  xCursor:=getCursor;
  with Cursor do begin
    writeln;
    writeln('Present start- and endline of cursor:',sLine:3,eLine:3);
    write  ('Change start to 0 to create block type ');
    sLine:=0;     setCursor(xCursor); readln;
    write  ('Make cursor a thin line ');
    sLine:=eLine; setCursor(xCursor); readln;
    write  ('Turn cursor off preserving present size ');
    cursorOff;    readln;
    write  ('Notice how we get our thin cursor back ');
    cursorOn;     readln;
{ those three won't work properly on EGA/VGA }
   {blinkSlow;    readln;
    blinkFast;    readln;
    blinkNormal;  readln}
  end;
  write('Restore original cursor ');
  setCursor(oldCursor); readln
end.


