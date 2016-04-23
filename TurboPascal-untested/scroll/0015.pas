Program VGASLIDE; {requirements TP6 or higher + register-compatible VGA}


uses CRT,grstuff;

var
  t,slide:word;
  ch:char;

Procedure VgaBase(Xscroll,Yscroll:integer);
  var dum:byte;
 Begin
  Dec(SLIDE,(Xscroll+320*Yscroll));   { slide scrolling state         }
  Port[$03d4]:=13;                    { LO register of VGAMEM offset  }
  Port[$03d5]:=(SLIDE shr 2) and $FF; { use 8 bits:  [9..2]           }
  Port[$03d4]:=12;                    { HI register of VGAMEM offset  }
  Port[$03d5]:= SLIDE shr 10;         { use 6 bits   [16..10]         }
  Dum:=Port[$03DA];                   { reset to input by dummy read  }
  Port[$03C0]:=$20 or $13;            { smooth pan = register $13     }
  Port[$03C0]:=(SLIDE and 3) Shl 1;   { use bits [1..0], make it 0-2-4-6
}
 End;


BEGIN {main}

  setvidmode($13);
  SLIDE:=0;

  { draw a quick test pattern directly to video memory }
  For T:= 0 to 63999 do MEM[$A000:T]:=(T mod (317 + T div 10000)) and
255;

  repeat
   Vgabase(-1,-1);  { scroll smoothly in UPPER LEFT direction }
   Delay(14);
  until Keypressed;
  ch:=Readkey;

  repeat
   Vgabase( 1, 1);  { scroll smoothly in LOWER RIGHT direction }
   Delay(14);
  until Keypressed;
  ch:=Readkey;
  setvidmode($3);

END.
