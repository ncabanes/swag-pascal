(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0241.PAS
  Description: VGA lines
  Author: EYAL DORON
  Date: 05-27-95  10:38
*)

{
Re:	SWAG: VGA Lines procedure

Here is a contribution to SWAG. It was based on SWAG, so its only right
that it returns there...

Thanks for your work,
   Eyal Doron
}
-----------------------------------------------------------------
procedure VGAlines(n: byte);
{=========================================================================}
{ This routine switches any standard VGA adapter to one of 14 text modes. }
{ It is based on code gathered from the SWAG collection, and the 8x10     }
{ font is based on the one posted by Paul (SL65R@cc.usu.edu) on Usenet.   }
{ Supported modes are 12/14/20/21/25/28/30/34/35/40/43/48/50/60 x 80 .    }
{ Written for TP 6.0. Uses DOS.TPU, and does not require CRT.TPU.         }
{                                                                         }
{ Put together by Eyal Doron, 6/2/95. Use at your own risk.               }
{=========================================================================}
const
  scan200lines = $1200; scan350lines = $1201; scan400lines = $1202;
  font8x16     = $1114; font8x14     = $1111; font8x8      = $1112;
  VGAColorMode = $0003; VGAMonoMode  = $0002;
type
  tchar8x8=array[0..7] of byte;
  tfont8x8=array[0..255] of tchar8x8;
  tchar8x10=array[0..9] of byte;
  tfont8x10=array[0..255] of tchar8x10;
Var
  CrtcReg:Array[1..8] of Word;
  Offset:Word;
  i,j,Data: Byte;
  vmode,scan,font: word;
  char8x8:tchar8x8;
  fontArr8x8:^tfont8x8;
  char8x10:tchar8x10;
  fontArr8x10:^tfont8x10;
  r: registers;
begin
  if not (n in [12,14,20,21,25,28,30,34,35,40,43,48,50,60]) then exit;
  vmode:=VGAColorMode; { Change for mono screens }
  fontArr8x10:=Nil;
  if n in [20,35,40,48] then   { Create 8x10 font from ROM 8x8 font }
  begin
                 {call bios to get font8x8}
    r.ax:=$1130;
    r.bh:=03;
    intr($10,r);
    fontArr8x8:=ptr(r.es,r.bp);
    new(fontArr8x10);
    
                {make char8x10s from char 8x8s}
    for i:=0 to 255 do
    begin
      char8x8:=fontArr8x8^[i];
      for j:=0 to 7 do
        char8x10[j+1]:=char8x8[j];
      case i of
        176..178:
          begin
            char8x10[0]:=char8x8[7];
            char8x10[9]:=char8x8[6]
          end;
        8,10,179..182,185,186,195,197..199,215,216,204,206,219,221,222:
          begin
            char8x10[0]:=char8x8[7];
            char8x10[9]:=char8x8[7]
          end;
        183,184,187,191,194,201,203,209,210,213,214,218,220,244:
          begin
            char8x10[0]:=0;
            char8x10[9]:=char8x8[7]
          end;
        188..192,193,200,202,207,208,211,212,217,223,245:
          begin
            char8x10[0]:=char8x8[0];
            char8x10[9]:=0
          end;
        else
          begin
            char8x10[0]:=0;
            char8x10[9]:=0
          end;
      end;
      fontArr8x10^[i]:=char8x10;
    end;
  end;
  if n in [30,34,48,60] then  { Trick VGA to 480 scan lines }
  begin
    font:=font8x16;
    if n=34 then font:=font8x14
    else if n=60 then font:=font8x8;
    asm                          {First set 400 scan lines and video mode}
      mov ax, scan400lines
      mov bl, 30h
      int 10h
      mov ax, vmode
      int 10h
    end;
    if n=48 then                 { User-defined 8x10 font }
    begin
      with r do
      begin
        ax:=$1110; bx:=$0a00;  cx:=$0100; dx:=0;
        es:=seg(fontArr8x10^); bp:=ofs(fontArr8x10^);
      end;
      intr($10,r);
    end else                     { Usual ROM fonts }
    asm
      mov ax, font
      mov bl, 0h
      int 10h
    end;
    CrtcReg[1]:=$0c11;           {Vertical Display End (unprotect regs. 0-7)}
    CrtcReg[2]:=$0d06;           {Vertical Total}
    CrtcReg[3]:=$3e07;           {Overflow}
    CrtcReg[4]:=$ea10;           {Vertical Retrace Start}
    CrtcReg[5]:=$8c11;           {Vertical Retrace End (& protect regs. 0-7)}
    CrtcReg[6]:=$df12;           {Vertical Display Enable End}
    CrtcReg[7]:=$e715;           {Start Vertical Blanking}
    CrtcReg[8]:=$0616;           {End Vertical Blanking}

    MemW[$0040:$004c]:=8192*((160*n) div 8192 +1); {Change page size in bytes}
    Mem[$0040:$0084]:=n-1;       {Change page length}
    
    Offset:=MemW[$0040:$0063];   {Base of CRTRC}
    Asm
      cli                        {Clear Interrupts}
    End;
  
    For i:=1 to 8 do
      PortW[Offset]:=CrtcReg[i]; {Load Registers}
  
    Data:=Port[$03cc];
    Data:=Data And $33;
    Data:=Data Or $C4;
    Port[$03c2]:=Data;
    Asm
      sti                         {Set Interrupts}
    end;
  end else
  begin
    if n in [12,14,20] then Scan:=Scan200Lines
    else if n in [21,35,43] then Scan:=Scan350Lines
    else Scan:=Scan400Lines;
    if n in [43,50] then font:=font8x8
    else if n in [14,28] then font:=font8x14
    else font:=font8x16;
    asm                           { Scan lines and video mode }
      mov ax, Scan
      mov bl, 30h
      int 10h
      mov ax, vmode
      int 10h
    end;
    if n in [20,35,40] then       { User-defined 8x10 font }
    begin
      r.ax:=$1110;
      r.bx:=$0a00;
      r.cx:=$0100;
      r.dx:=0;
      r.es:=seg(fontArr8x10^);
      r.bp:=ofs(fontArr8x10^);
      intr($10,r);
    end else                      { Video ROM fonts }
    asm
      mov ax, font
      mov bl, 0h
      int 10h
    end;
  end;
  if fontArr8x10<>Nil then dispose(fontArr8x10);
end;



