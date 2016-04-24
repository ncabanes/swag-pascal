(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0035.PAS
  Description: Set/Get Active Video Page
  Author: ROBERT ROTHENBURG
  Date: 11-02-93  04:59
*)

{
Robert Rothenburg

> How do you use video pages, how do you change the current one(I guess
> it's an register?), and if somebody could, explain to me exactly what
> Video Pages are?

Interrupt $10, function 5...which in Turbo Pascal becomes (ta da!):
}

program PageExample;

uses
  DOS;

var
  reg : Registers;

procedure SetActivePage(Page : byte);
begin
  Reg.AH := 5;
  Reg.AL := Page;
  Intr($10, Reg);
end;

(* or, if you've got TP 7... *)

procedure SetActivePage(Page : byte); assembler;
asm
  MOV AH, 5
  MOV AL, Page
  INT $10
end;

{
According to my handy and well-worn "DOS Programmer's Reference", the
valid page numbers are as follows:

Page Numbers:        Video Mode(s):        Video Adapters:
-----------------------------------------------------------------
   0..7               00, 01                 CGA, EGA, MCGA, VGA
   0..3               02, 03                 CGA
   0..7               02, 03                 EGA, MCGA, VGA
   0..7               07, 0Dh                EGA, VGA
   0..3               0Eh                     "    "
   0..1               0Fh, 10h                "    "

Of course my edition was written in 1989 and only goes up to DOS 4 and
doesn't mention SVGA or XGA cards etc.

(I don't even bother with Boreland's BGI drivers.  It's much easier to
use my own BIOS interface units.)
}

