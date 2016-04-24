(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0035.PAS
  Description: Re: Using PORTS
  Author: PETER LOUWEN
  Date: 02-21-96  21:04
*)

{
   Direct port access
   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
  For access to the 80x86 CPU data ports, Borland Pascal implements two
  predefined arrays, Port and PortW.

  Both are one-dimensional arrays, and each element represents a data port,
  whose port address corresponds to its index.

  The index type is the integer type Word. Components of the port array are of
  type Byte and components of the PortW array are of type Word.

  When a value is assigned to a component of Port or PortW, the value is
  output to the selected port. When a component of Port or PortW is referenced
  in an expression, its value is input from the selected port.

  Use of the Port and PortW arrays is restricted to assignment and reference
  in expressions only; that is, components of Port and PortW cannot be used as
  variable parameters. Also, references to the entire Port or PortW array
  (reference without index) are not allowed.

Simply type "port", put the cursor on it, then press Ctrl+F1.

Reading a port (port nr. $378 in this case): x := Port[$378];
Writing to that same port                  : Port[$378] := x
in which X is a byte variable.

A colourful example:
}

PROGRAM Playing_with_Ports;

{$X+}

USES Crt;

PROCEDURE SetVideomode(CONST mode: byte); ASSEMBLER;
ASM mov AL, mode
    xor AH, AH
    int $10
END;

PROCEDURE SetColor(CONST Color, Blue, Green, Red: byte);
BEGIN port[$3C8] := Color;
      port[$3C9] := Red;
      port[$3C9] := Green;
      port[$3C9] := Blue
END;

{ - Main: }

CONST Color_U_Want = Crt.Blue;  { -- Or whatever. }
      pause        = 500;

VAR Red, Green, Blue: byte;

BEGIN SetVideomode(3);  { -- To be sure. }
      TextBackground(Color_U_Want); clrscr;
      gotoxy(20, 5); write('D a z z l i n g');
      gotoxy(20, 7); write('      o r');
      gotoxy(20, 9); write('    w h a t');
      readkey;
      randomize;
      REPEAT SetColor(Color_U_Want, random(63), random(63), random(63));
             delay(pause)
      UNTIL keypressed;
      delay(pause);
      SetVideomode(3)
END.

A list of what each port does can be found in Ralf Brown's Interrupt List
(filenames INTERnnx.ZIP; "nn" = version number, currently 48, and "x" is a
letter).



