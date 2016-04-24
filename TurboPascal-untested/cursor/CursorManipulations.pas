(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0010.PAS
  Description: Cursor Manipulations
  Author: SWAG SUPPORT TEAM
  Date: 07-16-93  06:05
*)


{ unit to manipulate the text cursor }

unit Cursor;

INTERFACE

TYPE

  PCursorRec = ^TCursorShape;
  TCursorShape = record
    Start : byte;
    Stop  : byte;
  end;

procedure GetCursorShape (var Shape : TCursorShape);
{ Sets the Start and Stop fields of Shape }

procedure CursorOff;
{ Turns the cursor off }

procedure NormCursorOn;
{ Turns underscore cursor on }

procedure BlockCursorOn;
{ Turns block cursor on }

procedure SetCursorShape (Shape : TCursorShape);
{ Set cursor shape with Start and Stop fields of Shape }

IMPLEMENTATION
VAR
   VideoMode : BYTE ABSOLUTE $0040 : $0049; { Video mode: Mono=7, Color=0-3 }

procedure GetCursorShape (var Shape : TCursorShape); assembler;
  asm
    mov ah,$03
    mov bx,$00
    int $10
    les di,Shape
    mov TCursorShape (es:[di]).Start,ch    {es:[di] is Start field of Shape}
    mov TCursorShape (es:[di]).Stop,cl  {es:[di+1] is Stop field of Shape}
  end;

procedure SetCursorShape; assembler;
  asm
    mov ah,$01             { Service 1, set cursor size }
    mov ch,Shape.Start
    mov cl,Shape.Stop
    int $10
  end;

procedure CursorOff;  assembler;
  asm
    mov ah,$01
    mov ch,$20
    mov cl,$00
    int $10
  end;

procedure NormCursorOn;
  var
    Shape : TCursorShape;
  begin
    if VideoMode = 7 then
      begin
        Shape.Start := $0A;
        Shape.Stop  := $0B;
      end
    else
      begin
        Shape.Start := $06;
        Shape.Stop  := $07;
      end;
    SetCursorShape (Shape);
  end;

procedure BlockCursorOn;
  var
    Shape : TCursorShape;
  begin
    if VideoMode = 7 then
      begin
        Shape.Start := $02;
        Shape.Stop  := $0B;
      end
    else
      begin
        Shape.Start := $02;
        Shape.Stop  := $08;
      end;
    SetCursorShape (Shape);
  end;

END.
