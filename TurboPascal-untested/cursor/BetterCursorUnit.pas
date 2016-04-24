(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0027.PAS
  Description: Better Cursor Unit
  Author: BRAD ZAVITSKY
  Date: 11-22-95  13:25
*)


unit Cursor;

interface

const
  ThinCursor = $0707;
  OvrCursor  = $0307;
  InsCursor  = $0607;
  BarCursor  = $000D;
  HideCursor = $2607;
  ShowCursor = $0506;

procedure SetCursor(Ctype: Word);

implementation

procedure SetCursor(Ctype: Word); assembler;
asm
  mov ax, $0100
  mov cx, CType
  int $10
end;

end.


