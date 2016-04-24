(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0280.PAS
  Description: VGA Textfont & Color changer
  Author: NILTON CASTILLO ALBARRACIN
  Date: 11-29-96  08:17
*)

Unit NEWFONT; {VGA Textfont & color changer. Source.}
        {
                Version: 1.0 (Beta/not all mode tested)

                Author: Nilton Castillo Albarracín.
                        ncastill@araucaria.cec.uchile.cl
                        El Boldo 275 Est.Central Santiago Chile

                Tested on a VGA card only. CardWare. Use at own risk!
                I take no responsability of any damage that may occur
                to your hardware. Currently I've tested only the modes with
                CharSizeByte=16.
-----------------------------------------------------------------------------
          SETRGB(color,R,G,B)  Sets the Red/Green/Blue values for the
                               desired color (0 to 15).
                               R, G & B go from 0 to 63.
-----------------------------------------------------------------------------
          SetFont(filename:string;csb:byte)
                               Loads a new font into memory.
                               csb is the charsize of the font in bytes,
                               it depends on the current graphical/text mode
-----------------------------------------------------------------------------
          SETMODE(mode)        Sets the graphical/text mode
                               Warning: Some modes may damage your monitor.
                               Below is a listing of save modes.
-----------------------------------------------------------------------------
          GetMode:word;        Get the current graphical/text mode
-----------------------------------------------------------------------------
          Border (color);      Change the border color.
-----------------------------------------------------------------------------

                 Mode     Alpha  Resolution Colors CharSize CharSizeBytes(CSB)
                 ------------------------------------------------------
                 $3(VGA)  80x25  640x350     16     8x16     16
                 $7(Vga)  80x25  720x400      2     9x16     18?
                 $7(Ega)  80x25  720x350      2     9x14
                 $50      80x30  640x480     16     8x16     16
                 $51      80x43  640x473     16     8x11     11
                 $52      80x60  640x480     16     8x8      8
                 $53     132x25 1056x350     16     8x14     14
                 $54     132x30 1056x480     16     8x16     16
                 $55     132x43 1056x473     16     8x11     11
                 $56     132x60 1056x480     16     8x8      8

              These are 'save' modes to use, all VGA monitors should support
              these modes. Higher modes may not be that kind to your monitor.

        Q: What is CardWare?
        A: It's like shareware: if you like it, send me a postcard.
           (with nice stamps on it! :) )

        Q: How do I make my own fonts?
        A: For textmode fonts, download EVAFONT.ZIP an editor by
           Pete Kvitek. It's excelent!
           For a font collection: Fntcol16.zip... many fonts, but no editor!

        Q: I need this to work for mode $10,$12 or $13 ...
        A: Email me, and I will send you some hints to make the fonts
           load in these modes...


        }
interface
         procedure SetRGB (color:integer;r,g,b:byte);
         procedure SetFont(filename:string;csb:byte);
         procedure SetMode(Mode: word);
         Function  GetMode:word;
         procedure Border(color: byte);

implementation
uses DOS;
var  FONT:array[0..4095] of byte;

procedure Border(color: byte);
begin
     asm
      mov AX,$0B00;
      mov BH,$00;
      mov BL,color;
      int 10h
    end;
end;

procedure SetRGB (color:integer;r,g,b:byte);
begin
     if color>5 then    { this is to make color changes work with        }
          case color of { textcolor() & textbackground()...but why?      }
          6: color:=20; { note: for fast palette fadings use color 0 to 5}
          8: color:=56;
          9: color:=57;
          10: color:=58;
          11: color:=59;
          12: color:=60;
          13: color:=61;
          14: color:=62;
          15: color:=63;
          end;
    asm
      mov AX,$1010;
      mov BX,color;
      mov DH,R;
      mov CH,G;
      mov CL,B;
      int 10h
    end;
end;

procedure SETFont(filename:string;csb:byte); {ONLY for TextModes}
var
  Regs : Registers;
  f:file;
  d:integer;
begin
     assign(f,filename);
     reset(f,1);
     blockread(f,font,sizeof(font),d);
     close(f);

      regs.AH:=$11;
      regs.AL:=$0;
      regs.BH:=csb; {bytes per char}
      regs.BL:=0; {what is this? }
      regs.CX:=$254; {how many chars}
      regs.DX:=$0; {start at char code}
      regs.ES:=seg(font);
      regs.BP:=ofs(font);
      Intr ($10, Regs);
end;
procedure SetMode (Mode : word);
begin
  asm
    mov ax,Mode;
    int 10h
  end;
end;
Function Getmode:word;
begin
getmode:=Mem[$0040:$0049];
end;

END.


