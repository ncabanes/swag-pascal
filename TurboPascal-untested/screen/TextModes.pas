(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0073.PAS
  Description: Text Modes
  Author: CHRIS FORBIS
  Date: 11-26-94  05:06
*)

{
This is some code I did for someone.  I figure they may be one of you all
that need it. Also put it in SWAG if you like it.

This will let you change between the 6 most common text modes!  Nice easy to
read code I think. <grin>

(* Info:                                                                 *)
(*                                                                       *)
(*  Forbis's Cool Text Mode Thing v0.01                                  *)
(*  by: Chris Forbis                                                     *)
(*  CopyRight 1994 . All Rights Reserved                                 *)
(*                                                                       *)
(* About:                                                                *)
(*  I worked on this one day when well I just had to get into 132x25x16! *)
(*  Enjoy!  Please don't hack this up!  If you use  ease give me a little*)
(*  credit where it is due.                                              *)
(*                                                                       *)
(* Getting Hold Of Me:                                                   *)
(*                                                                       *)
(* InterNet:  forbis@vsl.ist.ucf                                         *)
(* FidoNet :  1:363/246                                                  *)
(*            Pascal and Pascal Lessons Areas                            *)
(* BBS     :  Darkened Lands (407)679-3449                               *)
}
program TEXTMODE;

procedure SetMode_80_25_16; assembler;
asm
  mov ax, 03h
  int 10h
end;

procedure SetMode_80_25_2; assembler;
asm
  mov ax, 07h
  int 10h
end;

procedure SetMode_80_60_16; assembler;
asm
  mov ax, 4Eh
  int 10h
end;

procedure SetMode_132_60_16; assembler;
asm
  mov ax, 4Fh
  int 10h
end;

procedure SetMode_132_25_16; assembler;
asm
  mov ax, 50h
  int 10h
end;

procedure SetMode_132_43_16; assembler;
asm
  mov ax, 51h
  int 10h
end;

procedure HelpMenu;
begin
  writeln('■ Forbis''s Cool Text Mode Thing! v0.01');
  writeln('────────────────────────────────────────');
  writeln('Usage: TEXTMODE <MODE>');
  writeln;
  writeln('MODE:');
  writeln('       0 : 80x 25y 16c   Mode: 03h');
  writeln('       1 : 80x 25y 2c    Mode: 07h');
  writeln('       2 : 80x 60y 16c   Mode: 4Eh');
  writeln('       3 : 132x 60y 16c  Mode: 4Fh');
  writeln('       4 : 132x 25y 16c  Mode: 50h');
  writeln('       5 : 132x 43y 16c  Mode: 51h');
  writeln('────────────────────────────────────────');
  writeln('I will not be held liable if this messes');
  writeln('up your machine!');
  writeln('────────────────────────────────────────');
end;

var
  st : string[1];
  ch : char;

begin
  if (paramcount = 0) then begin
    HelpMenu;
  end else begin
    st := paramstr(1);
    ch := st[1];
    case upcase(ch) of
      '0' : SetMode_80_25_16;
      '1' : SetMode_80_25_2;
      '2' : SetMode_80_60_16;
      '3' : SetMode_132_60_16;
      '4' : SetMode_132_25_16;
      '5' : SetMode_132_43_16;
      else HelpMenu;
    end;
  end;
  writeln('Thanks for using Forbis''s Cool Text Mode Thing!');
  readln;
end.

