{
For people who do not find any xsharp Near them, and who would like to test it
anyway i translated some Assembler-Code (not by me) back to to TP6.
I tested it on a 486/33 With multisynch and a 386/40 With an old bw/vga monitor
both worked well. Anyway i cannot guarantee that it works With every pc and is
healthy For every monitor, so be careful.
This Listing changes to 360x480x256 modex and displays some pixels.
Have fun With it !
}
(*Source: VGAKIT Version 3.4
   Copyright 1988,89,90 John Bridges
   Translated to Pascal (why?) by Michael Mrosowski *)

Program ModexTest;

Uses Crt,Dos;

Var
  maxx,maxy : Word;

(*Set Modex 360x480x256 *)

Procedure SetModex;
Const
 VptLen=17;
 Vpt : Array[1..VptLen] of Word =
                    ($6b00 , (* horz total                      *)
                     $5901 , (* horz displayed                  *)
                     $5a02 , (* start horz blanking             *)
                     $8e03 , (* end horz blanking               *)
                     $5e04 , (* start h sync                    *)
                     $8a05 , (* end h sync                      *)
                     $0d06 , (* vertical total                  *)
                     $3e07 , (* overflow                        *)
                     $4009 , (* cell height                     *)
                     $ea10 , (* v sync start                    *)
                     $ac11 , (* v sync end and protect cr0-cr7  *)
                     $df12 , (* vertical displayed              *)
                     $2d13 , (* offset                          *)
                     $0014 , (* turn off dWord mode             *)
                     $e715 , (* v blank start                   *)
                     $0616 , (* v blank end                     *)
                     $e317); (* turn on Byte mode               *)
Var
  regs:Registers;
  i:Integer;
  cr11:Byte;
begin
  maxx:=360;
  maxy:=480;
  regs.ax:=$13;       (*start With standardmode 13h*)
  Intr($10,regs);     (*hi bios!*)

  PortW[$3c4]:=$0604; (*alter sequencer Registers: disable chain 4*)
  PortW[$3c4]:=$0F02; (*    set Write plane mask to all bit planes*)
  FillChar(Mem[$a000:0],43200,0); (* Clearscreen *)
                      (*  ((XSIZE*YSIZE)/(4 planes)) *)

  PortW[$3c4]:=$0100; (*synchronous reset*)
  Port [$3c2]:=$E7;   (*misc output : use 28 Mhz dot clock*)
  PortW[$3c4]:=$0300; (*sequencer   : restart*)

  Port [$3d4]:=$11;   (*select Crtc register cr11*)
  cr11:=Port[$3d5];
  Port [$3d5]:=cr11 and $7F; (*Write protect*)

  For i:=1 to vptlen do (*Write Crtc-Registers*)
    PortW[$3d4]:=Vpt[i];
end;


(*Put pixel in 360x480 (no check)*)

Procedure PutPixel(x,y:Word;c:Byte);
begin
  PortW[$3c4]:=($100 shl (x and 3))+2; (*set EGA bit plane mask register*)
  Mem[$a000:y*(maxx shr 2) + (x shr 2)]:=c;
end;

Var c:Char;
    i,j:Integer;

begin
  SetModex;
  For j:=0 to 479 do  (* Nearly SVGA With your good old 256k VGA*)
    For i:=0 to 359 do
      PutPixel(i,j,(i+j) and $FF);
  c:=ReadKey;
  TextMode(LastMode);
end.