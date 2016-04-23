{
  If  you are ready to delve into pure VGA-register programming, you can
  realize  graphic  modes  up  to  400x600x256 pixels on any vanilla-VGA
  card;  watch  out  for  TWEAK*.*  for a cute tool to create such modes
  yourself easily.

  Here's  a  small example for a 360x256x256 mode, give it a try on your
  system:
}

{Purpose  : Demonstrate 360x256x256 graphics resolution              }
{Author   : Kai Rohrbacher, kai.rohrbacher@logo.ka.sub.org           }
{Language : TurboPascal 6.0   }
{Date     : 17.07.1994        }
{Remarks  : Register set generated with Robert Schmidt's TWEAK1.6beta}
{           adopted to Pascal by myself. No guarantees, use on your  }
{           own risk!}
{           If you directly want to play around with Bob's TWEAK,    }
{           here is the original register file:
begin 644 360x256b.256
MP@,`Y]0#`&O4`P%9U`,"6M0#`X[4`P1>U`,%BM0#!B/4`P>RU`,(`-0#"6'4
M`Q`*U`,1K-0#$O_4`Q,MU`,4`-0#%0?4`Q8:U`,7X\0#`0'$`P0&S@,%0,X#
*!@7``Q!!P`,3````
`
end
}

USES Dos;
CONST ATTRCON_ADDR = $3c0;
      MISC_ADDR = $3c2;
      VGAENABLE_ADDR = $3c3;
      SEQ_ADDR = $3c4;
      GRACON_ADDR = $3ce;
      CRTC_ADDR = $3d4;
      STATUS_ADDR = $3da;

TYPE Register=RECORD
      prt:WORD;
      index:BYTE;
      value:BYTE
     END;
    RegisterPtr=^Register;
CONST Mode360x256: ARRAY[0..24] OF Register =
 (
  ( prt:$3c2; index:$0; value:$e7),
  ( prt:$3d4; index:$0; value:$6b),
  ( prt:$3d4; index:$1; value:$59),
  ( prt:$3d4; index:$2; value:$5a),
  ( prt:$3d4; index:$3; value:$8e),
  ( prt:$3d4; index:$4; value:$5e),
  ( prt:$3d4; index:$5; value:$8a),
  ( prt:$3d4; index:$6; value:$23),
  ( prt:$3d4; index:$7; value:$b2),
  ( prt:$3d4; index:$8; value:$0),
  ( prt:$3d4; index:$9; value:$61),
  ( prt:$3d4; index:$10; value:$a),
  ( prt:$3d4; index:$11; value:$ac),
  ( prt:$3d4; index:$12; value:$ff),
  ( prt:$3d4; index:$13; value:$2d),
  ( prt:$3d4; index:$14; value:$0),
  ( prt:$3d4; index:$15; value:$7),
  ( prt:$3d4; index:$16; value:$1a),
  ( prt:$3d4; index:$17; value:$e3),
  ( prt:$3c4; index:$1; value:$1),
  ( prt:$3c4; index:$4; value:$6),
  ( prt:$3ce; index:$5; value:$40),
  ( prt:$3ce; index:$6; value:$5),
  ( prt:$3c0; index:$10; value:$41),
  ( prt:$3c0; index:$13; value:$0)
 );

{
   readyVgaRegs() does the initialization to make the VGA ready to
  accept any combination of configuration register settings.

  This involves enabling writes to index 0 to 7 of the CRT controller
  (port $3d4), by clearing the most significant bit (bit 7) of index
  $11.
}

PROCEDURE readyVgaRegs;
VAR v:INTEGER;
BEGIN
  port[$3d4]:=$11;
  v:=port[$3d5] AND $7f;
  port[$3d4]:=$11;
  port[$3d5]:=v;
END;

{
  outReg sets a single register according to the contents of the
  passed Register structure.
}
PROCEDURE outReg(r:Register);
VAR dummy:BYTE;
BEGIN
 IF r.prt=ATTRCON_ADDR
  THEN BEGIN
        dummy:=port[STATUS_ADDR];     { reset read/write flip-flop }
        port[ATTRCON_ADDR]:= r.index OR $20; { ensure VGA output is enabled }
        port[ATTRCON_ADDR]:= r.value;
       END
 ELSE IF (r.prt=MISC_ADDR) OR (r.prt=VGAENABLE_ADDR)
  THEN port[r.prt]:=r.value   {  directly to the port }
 ELSE BEGIN
       port[r.prt]:=r.index;  {  index to port        }
       port[r.prt+1]:=r.value;{  value to port+1        }
      END;
END;

{
  outRegArray sets n registers according to the array pointed to by r.
  First, indexes 0-7 of the CRT controller are enabled for writing.
}
PROCEDURE outRegArray(r:RegisterPtr; n:INTEGER);
BEGIN
 readyVgaRegs;
 WHILE n>0 DO
  BEGIN
   DEC(n);
   outReg(r^);
   ASM
    LES DI,r
    ADD DI,TYPE Register
    MOV WORD PTR [r],DI
   END;
  END;
END;



VAR y,lastMode:INTEGER;
    regs:REGISTERS;
BEGIN
 {Save old BIOS mode}
 regs.AH := $0f; INTR($10,regs); lastMode := regs.AL;

 {Set mode 13h to make sure the EGA palette set is correct for a }
 {256color mode}
 regs.AX := $13; INTR($10,regs);

  { Note that no initialization is neccessary now.  The Register array
      is linked in as global data, and is directly accessible.  Take
      note of the way the number of Register elements in the array is
     calculated: }

 outRegArray(@Mode360x256, sizeof(Mode360x256) DIV sizeof(Register));
 portw[$3c4]:=$0f02; { Enable all 4 planes }

  { Fill the screen with a blend of red and blue lines, defining the
     palette on the fly. }

  port[$3c8]:=0;         { start with color 0 }
  FOR y:=0 TO 255 DO
   BEGIN
    port[$3c9]:= y SHR 2;        { red component }
    port[$3c9]:= 0;              { green component }
    port[$3c9]:= (256-y) SHR 2;  { blue component }
    FillChar(Mem[SegA000:y*90],90,y);
   END;

 y:=0;
 WHILE y<256 DO
  BEGIN
   MEM[SegA000:y*90]:=255;
   inc(y,8)
  END;
  readln;

  { The picture is drawn, so wait for user to get tired of it. }

  { Restore the saved mode number.  Borland's textmode() won't work, as the
      C library still thinks we're in the mode it detected at startup.
     The palette will be set to the BIOS mode's default. }

  regs.AX := lastMode; INTR($10,regs);

END.
