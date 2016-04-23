{
PETER WOKKE

> anyone know a way to set the DAC registers that's faster than int $10?
}

PROGRAM vga_in_mode_13;

{ VGA in Mode $13  320 x 200 and 256 Colors for Turbo Pascal 6.0 }

USES
  Dos, Crt;

Procedure Plot(x, y : Integer; color : Byte);
Begin
  Mem[$A000 : word(y * 320 + x)] := color;
End;

Procedure set_rgb(reg, Red, Green, Blue : Byte);
Begin
  Port[$3C8] := reg;
  Inline($FA);
  Port[$3C9] := Red;
  Port[$3C9] := Green;
  Port[$3C9] := Blue;
  Inline($FB);
End;

Var
  x, y     : Integer;
  reg      : Registers;
  savemode : Byte;
  n        : Byte;
Begin
  reg.AX := $0F00;
  Intr($10, reg);
  savemode := reg.al;

  reg.AX := $0013;
  Intr($10, reg);

  For n := 0 TO 63 Do
    set_rgb(n, n, 0, 0);
  For n := 63 Downto 0 Do
    set_rgb(127 - n, n, 0, 0);
  For n := 128 TO 191 Do
    set_rgb(n, 0, 0, n);

  For y := 0 TO 191 Do
     For x := 0 TO 319 Do
        Plot(x, y, y);
  Readln;

  reg.AX := savemode;
  Intr($10, reg);
END.
