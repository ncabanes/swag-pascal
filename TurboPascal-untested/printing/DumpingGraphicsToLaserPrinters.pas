(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0055.PAS
  Description: Dumping graphics to laser printers
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)

unit Print_La;

INTERFACE

procedure dump_laser;

IMPLEMENTATION


Uses Graph,Dos,Printer;

Const
  d = 'l';

Var
  MaxX, MaxY : Integer;

Procedure dump_laser;

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
  For reg := 0 to maxx do begin
    Write(lst, chr(27), '*b', (maxy + 1) div 8, 'W');
    For kol := ((maxy + 1) div 8) - 1 downto 0 do begin
      bbyt := 0;
      For b := 0 to 7 do begin
        if getpixel(reg, kol * 8 + b) in[0,8] then    { = 0 }
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

begin
  MaxX := GetMaxX;
  MaxY := GetMaxY;
  hplaser
end;

begin
end.


