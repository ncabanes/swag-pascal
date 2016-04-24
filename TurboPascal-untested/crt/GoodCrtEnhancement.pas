(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0040.PAS
  Description: Good CRT enhancement
  Author: DANIEL DICKMAN
  Date: 08-30-96  09:36
*)

{
Been digging through some old code and found this. I don't know if it will
be useful to anybody now that we're living in the Windows age. However,
why let old code stagnate? This unit is ready to go as is and may be useful
to anyone STILL programming in DOS text mode.

Note: This code is free for anyone to use as they wish. However, usage is
at your OWN risk. I will not accept responsibility for any mishaps, mayhem
or those little elves that appear at four in the mourning after you've
downed
a pint of a liquid you were told only contained 10% alcohol, but was really
90%
proof!


{ CRT2.PAS - by Daniel Dickman (adickman@massmed.org)
  Freeware. Comments, suggestions, enhancements welcome! }
Unit Crt2;

{$O+}

Interface

Type
  { Pointer to the screen }
  PScreen = ^TScreen;
  { Structured type representing the screen }
  TScreen = Record
    Pos : Array [1..25, 1..80] Of Record
      Ch : Char;
      At : Byte;
    End;
  End;

Var
  { Array of multiple screens }
  Screen : Array [0..5] Of PScreen;
  { Current display page }
  Page   : Byte;

{ Sounds a simple beep through the PC speaker. }
Procedure Beep;

{ Ordinarily, the text screen can only display 8 background colours. Using
}
{ this procedure, you can change that so that you can have access to all  
}
{ 16 colours in the background (ie. all the brights). This procedure works
}
{ by disabling the ability for you to have blinking characters. For a more
}
{ technical description, see the manual. If On is True, you can only use 8
}
{ background colours. If it is False, you have access to all 16.          
}
Procedure Blink (On : Boolean);

{ This procedure allows complete control over the cursor size. }
Procedure Cursor (StartLine, EndLine : Byte);

{ This procedure is used to initialise the number of logical screens }
{ specified in Number. }
Procedure InitScreens (Number : Byte);

{ This function reads a character at a certain position on the screen. }
Function ReadChar (X, Y : Byte) : Char;

{ Use this function to read the colour attribute at a certain position }
{ on the screen. }
Function ReadColour (X, Y : Byte) : Byte;

{ This procedure is a functional extension to ReadChar }
Function ReadString (Line, X1, X2 : Byte) : String;

{ As the name suggests, you can use this procedure to set the text screen's
}
{ border colour. }
Procedure SetBorder (Colour : Byte);

{ This procedure allows complete control over the exact colour of each }
{ palette entry. }
Procedure SetPalette (PaletteNum : Word; Red, Green, Blue : Byte);

{ Used internally during initialisation. }
Function VidSeg : Word;

{ A procedure to that writes directly to video memory. }
Procedure FWrite (X, Y : Byte; S : String; At : Byte);

{ A procedure that only writes the background colour }
Procedure FWriteBgColour (Line, X1, X2, At : Byte);

{ A procedure that only writes the foreground colour }
Procedure FWriteFgColour (Line, X1, X2, At : Byte);

{ A procedure that writes both background and foreground colours }
Procedure FWriteColour (Line, X1, X2, At : Byte);

{ A procedure that is the same as Write except that it uses doesn't change
}
{ the screens set colour }
Procedure FWriteText (X, Y : Byte; S : String);

Implementation

Procedure Beep;
Begin
  System.Write (#7);
End;

Procedure Blink (On : Boolean);

  Procedure BlinkAsm (L : Byte); Assembler;
  Asm
    MOV  AH,$10   { Specify Service 10h   }
    MOV  AL,$03   { Specify Function 03h  }
    MOV  BL,L     { $00 = Intensity       }
                  { $01 = Blinking        }
    INT  $10      { BIOS Video Interrupt  }
  End;

Begin
  If On Then
    BlinkAsm ($01)
  Else
    BlinkAsm ($00);
End;

Procedure Cursor (StartLine, EndLine : Byte); Assembler;
Asm
  MOV  AH,01h         { Specify service 01h         }
  MOV  CH,StartLine   { Scan line on which to start }
  MOV  CL,EndLine     { Scan line on which to end   }
  INT  10h            { BIOS video interrupt        }
End;

Procedure InitScreens (Number : Byte);
Var
  A : Integer;
Begin
  For A := 1 To Number Do
    New (Screen[A]);
End;

Function ReadChar (X, Y : Byte) : Char;
Begin
  ReadChar := Screen[Page]^.Pos[Y, X].Ch;
End;

Function ReadString (Line, X1, X2 : Byte) : String;
Var
  Temp : String;
  Counter : Byte;
Begin
  Temp := '';
  For Counter := X1 To X2 Do
    Begin
      Temp := Temp + Screen[Page]^.Pos[Line, Counter].Ch;
    End;
  ReadString := Temp;
End;

Function ReadColour (X, Y : Byte) : Byte;
Begin
  ReadColour := Screen[Page]^.Pos[Y, X].At;
End;

Procedure SetBorder (Colour : Byte); Assembler;
Asm
  MOV  AH,$10      { Specify service 10h  }
  MOV  AL,$01      { Specify function 01h }
  MOV  BH,Colour   { Set border colour    }
  INT  $10         { BIOS video interrupt }
End;

Procedure SetPalette (PaletteNum : Word; Red, Green, Blue : Byte);
Assembler;
Asm
  MOV  AH,$10          { Specify Service 10h    }
  MOV  AL,$10          { Specify Function 10h   }
  MOV  BX,PaletteNum   { Colour Register to set }
  MOV  DH,Red          { Red value to set       }
  MOV  CH,Green        { Green value to set     }
  MOV  CL,Blue         { Blue value to set      }
  INT  $10             { BIOS Video Interrupt   }
End;

Function VidSeg : Word;
Begin
  If Mem[$0000:$0449] = 7 Then
    VidSeg := $B000
  Else
    VidSeg := $B800;
End;

Procedure FWrite (X, Y : Byte; S : String; At : Byte);
Var
  Counter : Byte;
Begin
  For Counter := 1 To Length(S) Do
    Begin
      Screen[Page]^.Pos[Y, X].Ch := S[Counter];
      Screen[Page]^.Pos[Y, X].At := At;
      Inc (X);
    End;
End;

Procedure FWriteText (X, Y : Byte; S : String);
Var
  Counter : Byte;
Begin
  For Counter := X To (Length(S) + X - 1) Do
    Screen[Page]^.Pos[Y, Counter].Ch := S[Counter - X + 1];
End;

Procedure FWriteColour (Line, X1, X2, At : Byte);
Var
  Counter : Byte;
Begin
  For Counter := X1 To X2 Do
    Screen[Page]^.Pos[Line, Counter].At := At;
End;

Procedure FWriteFgColour (Line, X1, X2, At : Byte);
Var
  B : Byte;
  Counter : Byte;
Begin
  For Counter := X1 To X2 Do
    Begin
      B := Screen[Page]^.Pos[Line, Counter].At;
      B := B And 240; {11110000}
      B := B + At;
      Screen[Page]^.Pos[Line, counter].At := B;
    End;
End;

Procedure FWriteBgColour (Line, X1, X2, At : Byte);
Var
  A : Byte;
  C : Byte;
  Counter : Byte;
Begin
  A := At Shl 4;
  For Counter := X1 To X2 Do
    Begin
      C := Screen[Page]^.Pos[Line, Counter].At;
      C := C And 15; {00001111}
      C := C + A;
      Screen[Page]^.Pos[Line, Counter].At := C;
    End;
End;

Begin
  { Set the active page }
  Page := 0;
  { Initialize the physical screen }
  Screen[Page] := Ptr(VidSeg, $0000);
End.

