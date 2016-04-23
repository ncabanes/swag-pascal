
{ THREE DIFFERENT WAYS TO WRITE TO SCREEN WITH ROW AND COLUMN }
{ TWO ARE VERY FAST AND ALLOW COLOR }

procedure QWrite( Column, Line , Color : byte; S : STRING );

var
   VMode  : BYTE ABSOLUTE $0040 : $0049; { Video mode: Mono=7, Color=0-3 }
   NumCol : WORD ABSOLUTE $0040 : $004A; { Number of CRT columns (1-based) }
   VSeg   : WORD;
   OfsPos : integer;  { offset position of the character in video RAM }
   vPos   : integer;
   sLen   : Byte ABSOLUTE S;

Begin
  If VMode in [0,2,7] THEN VSeg := $B000 ELSE VSeg := $B800;
  OfsPos   := (((pred(Line) * NumCol) + pred(Column)) * 2);
  FOR vPos := 0 to pred(sLen) do
      MemW[VSeg : (OfsPos + (vPos * 2))] :=
                     (Color shl 8) + byte(S[succ(vPos)])
End;


procedure fastwrite(x, y, f, b: byte; s : STRING);

{ Does a direct video write -- extremely fast.
  X, Y = screen location of first byte;
  S = string to display;
  F = foreground color;
  B = background color. }

type  videolocation = record    { the layout of a two-byte video location }
        videodata: char;        { character displayed }
        videoattribute: byte;   { attributes }
        end;

var cnter: byte;
    videosegment: word;         { the location of video memory }
    monosystem: boolean;        { mono vs. color }
    vidptr: ^videolocation;     { pointer to video locations }

begin

{ Find the memory location where the string will be displayed at, according to
  the monitor type and screen location.  Then associate the pointer VIDPTR with
  that memory location: VIDPTR is a pointer to type VIDEOLOCATION.  Insert a
  character and attribute; now go to the next character and video location. }

  monosystem := (lastmode in [0,2,7]);
  if monosystem then videosegment := $b000 else videosegment := $b800;
  vidptr := ptr(videosegment, 2*(80*(y - 1) + (x - 1)));
  for cnter := 1 to length(s) do begin
    vidptr^.videoattribute := (b shl 4) + f;  { high nibble=bg; lo nibble=fg }
    vidptr^.videodata := s[cnter];            { put character at location }
    inc(vidptr);                              { go to next video location }
    end;
  end;


Procedure Print(x,y : Byte; S : String);
BEGIN
  ASM
  MOV DH, Y    { DH = Row (Y) }
  MOV DL, X    { DL = Column (X) }
  DEC DH       { Adjust For Zero-based Bios routines }
  DEC DL       { Turbo Crt.GotoXY is 1-based }
  MOV BH,0     { Display page 0 }
  MOV AH,2     { Call For SET CURSOR POSITION }
  INT 10h
  END;
WRITE(S);
END;
