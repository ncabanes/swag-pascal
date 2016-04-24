(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0016.PAS
  Description: Operating Modes
  Author: FRED JOHNSON
  Date: 01-27-94  12:17
*)

{
If you ever wanted to tell what Operating System Mode you are using,
this /ditty/ will do the trick.  It sets a global integer to a value
which represents the Mode being used.  There is also a demo_prog at the
end of the unit.
}

unit mode;

interface

var
  OperatingMode : integer;

{ This integer holds a value of 0, 1, 2 or 3, which is an indicator
  if the machine is in:
    Dos Mode              (0),
    Windows Standard Mode (1),
    Windows Enhanced Mode (2),
    DESQview mode         (3); }
implementation

function wincheck : integer;
begin
 asm
   mov  ax,   $4680
   int  $2f
   mov  dl,   $1
   or   ax,   ax
   jz   @finished
   mov  ax,   $1600
   int  $2f
   mov  dl,   $2
   or   al,   al
   jz   @Not_Win
   cmp  al,   $80
   jne  @finished
  @Not_Win:
   mov  ax,   $1022
   mov  bx,   $0
   int  $15
   mov  dl,   $3
   cmp  bx,   $0a01
   je   @finished
   xor  dl,   dl
  @finished:
   xor  ah,   ah
   mov  al,   dl
   mov  @Result, ax
 end;
end;

begin
   OperatingMode := Wincheck;
end.

program Use_Mode;

uses
  mode;

const
  xModeStringArr : Array[0..3] of string[16] =
     ('Dos Mode', 'Windows Standard', 'Windows Enhanced', 'DESQview Mode');
begin
   Write(xModeStringArr[OperatingMode]);
end.

