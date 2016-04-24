(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0046.PAS
  Description: VGA ClrScr #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{   The following Turbo Pascal Program displays HARDWARE SCROLLinG
   For 100% Compatible VGA cards,in mode $13.
   I'd be grateful if anyone interested
   could test this and report the results :
}

Program VGASLIDE; {requirements TP6 or higher + register-Compatible VGA
}

Uses Crt;

Var
  t,slide:Word;
  ch:Char;

Procedure VgaBase(Xscroll,Yscroll:Integer);
  Var dum:Byte;
 begin
  Dec(SLIDE,(Xscroll+320*Yscroll));   { slide scrolling state         }
  Port[$03d4]:=13;                    { LO register of VGAMEM offset  }
  Port[$03d5]:=(SLIDE shr 2) and $FF; { use 8 bits:  [9..2]           }
  Port[$03d4]:=12;                    { HI register of VGAMEM offset  }
  Port[$03d5]:= SLIDE shr 10;         { use 6 bits   [16..10]         }
  Dum:=Port[$03DA];                   { reset to input by dummy read  }
  Port[$03C0]:=$20 or $13;            { smooth pan = register $13     }
  Port[$03C0]:=(SLIDE and 3) Shl 1;   { use bits [1..0], make it 0-2-4-6
}
 end;


begin {main}

  Asm                {inITIALIZE vga mode $13 using BIOS}
  MOV AX,00013h
  inT 010h
  end;

  SLIDE:=0;

  { draw a quick test pattern directly to video memory }
  For T:= 0 to 63999 do MEM[$A000:T]:=(T mod (317 + T div 10000)) and 255;

  Repeat
   Vgabase(-1,-1);  { scroll smoothly in UPPER LEFT direction }
   Delay(14);
  Until KeyPressed;
  ch:=ReadKey;

  Repeat
   Vgabase( 1, 1);  { scroll smoothly in LOWER RIGHT direction }
   Delay(14);
  Until KeyPressed;
  ch:=ReadKey;

  Asm
  MOV AX,00003h   {reset to Textmode}
  inT 010h
  end;

end.

