PROGRAM TESTFONT;
USES VGAfnt,Crt;
VAR I: Integer;
BEGIN               {MAXIMUM STRING LENGTH                39}
VideoMode($13);     {         1         2         3        X}
                    {123456789012345678901234567890123456789}
FOR I:=1 TO 255 DO SetColors(I,(I MOD 63),(I MOD 13)+20,11);
FOR I:=0 TO 255 DO DrawString((I MOD 39)*8,
                                 ((I DIV 39)*9)+1,I,0,Chr(i));
readkey;
VideoMode($3);
END.
{
This driver doesn't draw a string put does display all ascii codes to the
vga screen. Syntax for DrawString is as follows:
          DrawString(Xcor,Ycor,Color,Incr, string);
          Xcor:=x coordinate
          Ycor:=Y coordinate
color:=color to start 1-256 [may be 0-255]
Incr:Number to add to color inbetween chars
               Example     This is a String

This first would be color 1, the last color 16.
String:=andy string..andy ascii code up to 39 characters.

Char above and beyond 39 will be truncated and not displayed. The code NEEDS
improvement.  If you can do so, then DO SO. Idea's.  Have a defaul font for
EACH graphic video mode. Have it chosen when VideoMode is change, along with
CHarHeight & charWidth. Create a program that allows you to modify each
character WITHOUT having to text edit the FONT.TXT pascal typed structyre.

    This program is only a building block. It can be made into a great graphic
font program. Play with it and learn.
}

PROGRAM FX; {FonteXtract}
{This program makes a Pascal represenation type of the ascii chart by
 extracting the default font from memory.
 ERRORS: now very few}
VAR   Fl   : Text;
      I    : integer;
      FontAddrSeg,
      FontAddrOfs,
      DOtLines          : word;
 
PROCEDURE GetChar;
 PROCEDURE FontAddr(Font:byte);
 { Returns segment- and offset address of fonts with input of
  a Code, representing the font:
  Font 2 : 8x14 Font
       3 : 8x8 Font, 1. part, ASCII 00h..7Fh
       4 : 8x8 Font, 2. part, ASCII 80h..FFh
       5 : 9*14 substitutes
       6 : VGA 8x16 Font
       7 : VGA 9*16 substitutes }
  BEGIN
   ASM
    push bp       {BP will be changed by this function}
    mov ax,1130h
    mov bh,font
    int 10h
    mov FontAddrSeg,es      {will become $C000}
    mov FontAddrOfs,bp      {offset in VGA-BIOS}
    mov DotLines,cx         {bytes per char}
    pop bp
   END;
  END;  {FontAddr}
VAR NC, BC, IT  :Integer;
    MMC    :word;
    TEMP   :byte;
    DStr        :STRING;
 
BEGIN
DStr:='';
FontAddr(3);
WriteLN(FL, 'Alpha: LettersType = (');
FOR NC:=$0 TO $FF DO BEGIN               {Number of chars in font  }
    WriteLN(FL, '{',NC,'}');              {Title the block by ascii }
    WriteLN(FL,   '(');
    FOR BC:=0 TO 7 DO BEGIN              {Number of rows}
        TEMP:=Mem[FontAddrSeg:
                  FontAddrOfs+(NC*8)+(Bc)];   {Get the first line of the
character}
        FOR IT:=7 DOWNTO 0 DO BEGIN           {Get the bit representation}
            IF (temp AND (1 SHL IT)) <> 0 THEN BEGIN
               DStr:=DStr+'$B';
               IF (BC=7) AND (IT=0) THEN BEGIN
                  IF NC=$FF THEN DStr:=DStr+'));'
                  ELSE DStr:=DStr+'),';
               END
               ELSE DStr:=DStr+',';
            END
            ELSE BEGIN
               DStr:=DStr+' 0';
               IF (BC=7) AND (IT=0) THEN BEGIN
                  IF NC=$FF THEN DStr:=DStr+'));'
                  ELSE DStr:=DStr+'),';
               END
               ELSE DStr:=DStr+',';
            END;
        END;
        WriteLN(FL,DStr);
        DStr:='';                       {Clear dummy string}
    END;
    WriteLN(FL);                        {Separate the blocks}
    END;
END;
 
BEGIN
  assign(FL,'Font.TXT');
  ReWrite(FL);
  GETCHAR;    {get it from Mem and make a representation of it}
  close(FL);
END.

{$M 9182,0,0}
{ $A+        Align Data ..Word                }
{ $B-        Boolean Evaluation..Short Circuit}
{ $D-        Debug Information..Off           }
{ $E-        Emulation..Off      not needed in units}
{ $F-        Force Far Calls..Off             }
{ $G-        286 Code..Off                    }
{ $I+        I/O Checking..On                 }
{ $K-        Smart callbacks..Off             }
{ $L-        Local Symbols..Off               }
{ $N-        80x87 Code..Off                  }
{ $O-        Overlay Code Generaton..Off      }
{ $P-        Open string parameters..Disabled }
{ $Q-        Overflow Checking..Off           }
{ $R-        Range Checking..Off              }
{ $S-        Stack Checking..Off              }
{ $T-        Type-Checked Pointers..Off       }
{ $V-        Relaxed Var-String Checking      }
{ $W-        Windows Stack Frame..Off         }
{ $X+        Extended Syntax..On              }
{ $Y-        Symbol reference information..Off}
UNIT VGAfnt;
INTERFACE
PROCEDURE DrawString(Xcor,YCor,color:WORD; Incr:Integer;line:STRING);
 TYPE PalBuf256 = ARRAY[1..768] OF integer;
  PROCEDURE VideoMode(Mode : BYTE);
  PROCEDURE SetColPal(Color, Red, Gren, Blue : Word);
  PROCEDURE SetColors ( Color, Red, Green, Blue : integer );
  PROCEDURE PutDot(x,y:WoRd;color:integer);
  PROCEDURE Set256Pal( Palbuf: PalBuf256 );
IMPLEMENTATION
TYPE
  BitType      = ARRAY[0..8*8-1] OF word;
  LettersType  = ARRAY[0..255] OF BitType;     {a..z}
CONST
  CharWidth   = 8;
  CharHeight  = 8;
  VGA_Segment = $0A000;
  {coded chart of font made by FX pascal extracter}{$I FONT.TXT }
PROCEDURE VideoMode ( Mode : BYTE );
    BEGIN ASM
        Mov  AH,00
        Mov  AL,Mode
        Int  10h
    END; END;
PROCEDURE SetColPal(Color, Red, Gren, Blue : Word); ASSEMBLER;
ASM
        mov dx,$03c8;      mov ax,color;
        out dx,al;               inc dx;
        mov ax,red;           out dx,al;
        mov ax,gren;          out dx,al;
        mov ax,blue;          out dx,al;
END;
PROCEDURE SetColors ( Color, Red, Green, Blue : integer );
BEGIN
 Port[$3C8] := Color;
 Port[$3C9] := Red;
 Port[$3C9] := Green;
 Port[$3C9] := Blue;
END;
PROCEDURE PutDot(x,y:word;color:integer);
BEGIN            {test}
    Mem[VGA_Segment:((y-1)*320)+x] := color;
END;
PROCEDURE Set256Pal( Palbuf: PalBuf256 );
VAR I : Integer;
BEGIN
  FOR I :=0 TO 255 DO BEGIN
      SetColPal(I, PalBuf[ (I*3)], PalBuf[ (I*3) +1], PalBuf[ (I*3) +2]);
  END;
END;
 
{================ String writin' stuff ===================================}
PROCEDURE DrawString(Xcor,YCor,color:WORD;Incr:Integer;Line:string);
VAR I,Temp,B   : Integer;          {INCR: INC COLOR WITH EACH CHAR}
    Individual: BitType;           {LINE: WHAT TO DRAW}
BEGIN
  FOR I:=1 TO length(Line) DO BEGIN
    IF (line[i]<>' ') AND (Xcor+CharWidth<320) THEN BEGIN
       Individual:=Alpha[ ORd(line[I]) ];
 {Chr} FOR b:=0 TO (CharHeight)* (charWidth)-1 DO BEGIN
       Temp:=Individual[b];
       IF temp<> 0 THEN
           PutDot(Xcor+(B MOD CharWidth),Ycor+(B DIV CharHeight),color);
           {Skip blanks}
 {END} END;
    END;
    Inc(xcor,CharWidth);
    Inc(color,IncR)
  END;
END;
BEGIN
END.

(*
    The following code can be used to make and display a single VGA font.
    The first program is FX. It is used to extract an 8x8 default font from
memory and translate it into a pascal typed structure: simple to {$I}nclude
into a unit.
    The Second pogram in VGAfnt. It includes the VGA putdot & SetColors 
procedures used to draw a string to the screen. 
    The third program is a test driver for VGAfnt. It sets the palette and
displays all font chars to the screen.

    To run and test FIRST run FX. It will create FONT.TXT, the file to be
included in VGAfnt. SECOND compile VGAfnt with FONT.TXT in the same
directory. THIRD build TESTFONT; this will gather all up and allow you to
quickly test the unit.

    Have fun and enjoy. Modifications ARE welcome. Just post you mod.s so
all can enjoy.
*)
