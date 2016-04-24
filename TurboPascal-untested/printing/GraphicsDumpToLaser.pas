(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0025.PAS
  Description: Graphics Dump to Laser
  Author: JAN BARENDREGT
  Date: 11-02-93  05:47
*)

{
> I wrote a computer Program that produces 8 bit 480 x 640 hi res images,
> and I would like to know if anyone is familiar With a routine that can
> print these images out on a Printer.
> The preferable Printer For the task is a HP LaserJet II.
>
> I would like to be able to tell the LaserJet exactly which pixel dots
> to print, and I don't mind if I have to give bit information to the
> Printer line-by-line.
>

Below is some (old) code to make a screendump in Graphics mode, for
both HP laser II and Epson. I haven't tested this For SVGA, but if
you give MaxX and MaxY the right values, I can't see where it would
go wrong.

Jan Barendregt
}
Uses
  Graph,
  Dos,
  Printer;

Const
  d = 'l';

Var
  MaxX, MaxY : Integer;

Procedure dump;
Var
  ymax,
  bbyt,
  b2   : Byte;
  psf  : File of Byte;
  regs : Registers;

  Procedure out(ch : Char);
  begin
    regs.ax := ord(ch);
    regs.dx := 0;
    intr($17, regs);
  end;

  Procedure hplaser;
  Var
    b,
    reg,
    kol : Word;
  begin
    assign(psf, 'lpt1');
    reWrite(psf);
    Write(lst, chr(27), 'E');
    Write(lst, chr(27), '*t100R', chr(27), '*r0A');
    For reg := 0 to maxx do
    begin
      Write(lst, chr(27), '*b', (maxy + 1) div 8, 'W');
      For kol := ((maxy + 1) div 8) - 1 downto 0 do
      begin
        bbyt := 0;
        For b := 0 to 7 do
        begin
          if getpixel(reg, kol * 8 + b) = 0 then
            b2 := 0
          else
            b2 := 1;
          bbyt := bbyt or (b2 shl b);
        end;
        out(chr(bbyt));
      end;
    end;
    Write(lst, chr(27), '*rB');
    Write(lst, chr(12));
    Write(lst, chr(27), 'E');
    close(psf);
  end;

  Procedure epson;
  Var
    k, j, i : Byte;

    Function xget(x, y : Integer) : Byte;
    begin
      regs.ah := $0D;
      regs.cx := x;
      regs.dx := y;
      intr(16, regs);
      xget := regs.al;
    end;

  begin
    out(chr($1B));
    out(chr($33));
    out(chr($18));
    out(chr($0D));
    out(chr($0A));
    For j := 0 to (maxy shr 3) do
    begin
      out(chr($1B));
      out(chr($4C));
      out(chr((maxx + 1) mod 256));
      out(chr((maxx + 1) div 256));
      For i := 0 to maxx do
      begin
        bbyt := 0;
        For k := 0 to 7 do
          if (xget(i, (j shl 3) + k) <> 0) then
            bbyt := bbyt or (128 shr k);
        out(chr(bbyt));
      end;
      out(chr(13));
      out(chr(10));
    end;
  end;

begin
  MaxX := GetMaxX;
  MaxY := GetMaxY;

  if d = 'l' then
    hplaser
  else
    epson;
end;


Var
  Gd, Gm,
  Radius : Integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, 'e:\bp\bgi');
  For Radius := 1 to 5 do
    Circle(100, 100, Radius * 10);
  Readln;
  Dump;
  CloseGraph;
end.

