(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0021.PAS
  Description: PALETTE tricks
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{ FD>  Hey Greg, do you think you could tell me how to access
 FD> Mode-X, preferably the source, if it's no trouble.... :)

not a problem....  Mostly I do Graphics and stuff With C, but when it all comes
down to it, whether you use Pascal or C For the outer shell the main Graphics
routines are in Assembler (For speed) or use direct hardware port access
(again, For speed).
The following is a demo of using palette scrolling techniques in Mode 13h (X)
to produce a flashy "bouncing bars" effect often seen in demos:
}

Program PaletteTricks;
{ Speccy demo in mode 13h (320x200x256) }

Uses Crt;

Const CGA_CharSet_Seg = $0F000;     { Location of BIOS CGA Character set }
      CGA_CharSet_ofs = $0FA6E;
      CharLength      = 8;          { Each Char is 8x8 bits,  }
      NumChars        = 256;        { and there are 256 Chars }
      VGA_Segment     = $0A000;     { Start of VGA memory     }
      NumCycles       = 200;        { Cycles/lines per screen }
      Radius          = 80;

      DispStr         : String =    ' ...THIS IS A LITTLE '+
      'SCROLLY, DESIGNED to TEST SOME GROOVY PASCAL ROUTinES...'+
      '                                                        ';

      { Colours For moving bars... Each bar is 15 pixels thick }
      { Three colours are palette entries For RGB values...    }
      Colours : Array [1..15*3] of Byte =
                 (  7,  7, 63,
                   15, 15, 63,
                   23, 23, 63,
                   31, 31, 63,
                   39, 39, 63,
                   47, 47, 63,
                   55, 55, 63,
                   63, 63, 63,
                   55, 55, 63,
                   47, 47, 63,
                   39, 39, 63,
                   31, 31, 63,
                   23, 23, 63,
                   15, 15, 63,
                    7,  7, 63  );


Type  OneChar = Array [1..CharLength] of Byte;

Var   CharSet:  Array [1..NumChars] of OneChar;
      Locs:     Array [1..NumCycles] of Integer;
      BarLocs:  Array [1..4] of Integer;         { Location of each bar }
      CurrVert,
      Count:    Integer;
      Key:      Char;
      MemPos:   Word;

Procedure GetChars;
{ Read/copy BIOS Character set into Array }
  Var NumCounter,
      ByteCounter,
      MemCounter:       Integer;
  begin
      MemCounter:=0;
      For NumCounter:=1 to NumChars do
        For ByteCounter:=1 to CharLength do
          begin

CharSet[NumCounter][ByteCounter]:=Mem[CGA_CharSet_Seg:CGA_CharSet_ofs+MemCounter];
            inC(MemCounter);
          end;
  end;


Procedure VideoMode ( Mode : Byte );
{ Set the video display mode }
  begin
      Asm
        MOV  AH,00
        MOV  AL,Mode
        inT  10h
      end;
  end;


Procedure SetColor ( Color, Red, Green, Blue : Byte );
{ Update the colour palette, to define a new colour }
  begin
      Port[$3C8] := Color;      { Colour number to redefine }
      Port[$3C9] := Red;        { Red value of new colour   }
      Port[$3C9] := Green;      { Green "   "   "    "      }
      Port[$3C9] := Blue;       { Blue  "   "   "    "      }
  end;


Procedure DispVert ( Var CurrLine : Integer );
  { Display next vertical 'chunk' of the Character onscreen }
  Var Letter:    OneChar;
      VertLine,
      Count:     Integer;
  begin
      { Calculate pixel position of start of letter: }
      Letter := CharSet[ord(DispStr[(CurrLine div 8)+1])+1];
      VertLine := (CurrLine-1) Mod 8;

      { Push the Character, pixel-by-pixel, to the screen: }
      For Count := 1 to 8 do
        if Letter[Count] and ($80 Shr VertLine) = 0
          then Mem[VGA_Segment:185*320+(Count-1)*320+319] := 0
          else Mem[VGa_Segment:185*320+(Count-1)*320+319] := 181;
  end;

Procedure CalcLocs;
{ Calculate the location of the top of bars, based on sine curve }
  Var Count:    Integer;
  begin
      For Count := 1 to NumCycles do
        Locs[Count] := Round(Radius*Sin((2*Pi/NumCycles)*Count))+Radius+1;
  end;


Procedure DoCycle;
{  Display the bars on screen, by updating the palette entries to
   reflect the values from the COLOUR Array, or black For blank lines }

  Label Wait,Retr,BarLoop,PrevIsLast,Continue1,Continue2,Rep1,Rep2;

  begin
       Asm
          { First, wait For start of vertical retrace: }
          MOV   DX,3DAh
Wait:     in    AL,DX
          TEST  AL,08h
          JZ    Wait
Retr:     in    AL,DX
          TEST  AL,08h
          JNZ   Retr

          { then do bars: }
           MOV   BX,0
BarLoop:
           PUSH  BX
           MOV   AX,Word PTR BarLocs[BX]
           MOV   BX,AX
           DEC   BX
           SHL   BX,1
           MOV   AX,Word PTR Locs[BX]
           PUSH  AX
           CMP   BX,0
           JE    PrevIsLast
           DEC   BX
           DEC   BX
           MOV   AX,Word PTR Locs[BX]
           JMP   Continue1

PrevIsLast:
           MOV   AX,Word PTR Locs[(NumCycles-1)*2]

Continue1:
           MOV   DX,03C8h
           OUT   DX,AL
           inC   DX
           MOV   CX,15*3
           MOV   AL,0
Rep1:
           OUT   DX,AL
           LOOP  Rep1

           DEC   DX
           POP   AX
           OUT   DX,AL
           inC   DX
           MOV   CX,15*3
           xor   BX,BX
Rep2:
           MOV   AL,Byte Ptr Colours[BX]
           OUT   DX,AL
           inC   BX
           LOOP  Rep2

           POP   BX
           inC   Word PTR BarLocs[BX]
           CMP   Word PTR BarLocs[BX],NumCycles
           JNG   Continue2

           MOV   Word PTR BarLocs[BX],1
Continue2:
           inC   BX
           inC   BX
           CMP   BX,8
           JNE   BarLoop

        end;
      end;


begin

    VideoMode($13);             { Set video mode 320x200x256 }
    Port[$3C8] := 1;            { Write palette table entry }
    For Count := 1 to 180 do    { Black out the first 180 colours, }
      SetColor(Count,0,0,0);    { one colour will be used per line }

    { Now colour each scan line using the given palette colour: }
    MemPos := 0;
    For Count := 1 to 180 do
      begin
        FillChar(Mem[VGA_Segment:MemPos],320,Chr(Count));
        MemPos := MemPos + 320;
      end;

    SetColor(181,63,63,0);
    CalcLocs;
    For Count := 1 to 4 do
      BarLocs[Count] := Count*10;

    GetChars;
    CurrVert := 1;
    Repeat
      DoCycle;
      For Count := 1 to 8 do
        Move(Mem[VGA_Segment:185*320+(Count-1)*320+1],
             Mem[VGA_Segment:185*320+(Count-1)*320],319);
      DispVert(CurrVert);
      inC(CurrVert);
      if CurrVert > Length(DispStr) * 8
        then CurrVert := 1;

    Until KeyPressed;   { Repeat Until a key is pressed... }

    Key := ReadKey;     { Absorb the key pressed }
    VideoMode(3);       { Reset video mode back to Textmode } end.
end.

