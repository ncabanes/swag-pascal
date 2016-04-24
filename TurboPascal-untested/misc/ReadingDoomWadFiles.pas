(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0162.PAS
  Description: Reading DOOM WAD Files
  Author: DAVID O'SHEA
  Date: 09-04-95  11:06
*)


{
>does anyone know the file format for a doom wad in pascal? This would
>really be helpful for me. Thanx a lot.
I bet you really wanted a few pages of mostly uncommented source code, right?
And not just that, but it's pretty poorly written too :)

}
Program WADRead;
{$M 65520, 0, 0}

{Interface}

Uses DOS, Crt, Strings, Mode13h;  { unit MODE13H at end of snipet }

Type
  String8 = String [8];
  TWAD_Type = (Internal, Patch);
  StringZ8 = Array [1..8] Of Char;

  TRawPalette = Array [1..768] Of Byte;
  PRawPalette = ^TRawPalette;

Const
TWAD_TypeString: Array [1..2] Of String [4] = ('IWAD', 'PWAD');

Var
WAD_File: File;
  WAD_Name: String;
  WAD_Type: TWAD_Type;
  WAD_NumEntries, WAD_DirectoryPointer: LongInt;
  RawTexture: Array [1..32767] Of Byte;
  RawPalette: Array [1..768 * 14] Of Byte;

{Implementation}

{Add a backslash to the end of a directory name}
{From my TTString unit, part of my TurboTools library}
Function TT_AddSlash (S : String) : String;
Var
  L : Byte Absolute S;

Begin
  If (L > 0) And (S [L] <> '\') Then
  Begin
    Inc (L);
    S [L] := '\';
  End;
  TT_AddSlash := S;
End;

{Fill out string with spaces}
{From TTString}
Function TT_PadString (S: String; L: Integer) : String;
Var
  I: Integer;

Begin
  For I := Length (S) + 1 To L Do
    S [I] := #32;
  S [0] := Chr (L);
  TT_PadString := S;
End;


{Open the specified WAD file}
{If FileName = '' then try DOOM.WAD, DOOM2.WAD, then search}
{for the first WAD in the directory}
Function WAD_Open (FileName: String): Boolean;
Function WAD_OpenFile: Boolean;
Var
FileFound: SearchRec;

Begin
If Length (FileName) = 0 Then Begin
  {User hasn't specified a file name, open in the current directory}

    {Try to open DOOM.WAD in the current directory}
    Assign (WAD_File, 'DOOM.WAD');
    {$I-}
    Reset (WAD_File, 1);
    {$I+}
    If IOResult = 0 Then Begin
    {Succesfully opened DOOM.WAD}
      GetDir (0, WAD_Name);
      WAD_Name := TT_AddSlash (WAD_Name) + 'DOOM.WAD';
      WAD_OpenFile := True;
      Exit;
    End;

    {Couldn't open DOOM.WAD, try DOOM2.WAD}
    Assign (WAD_File, 'DOOM2.WAD');
    {$I-}
    Reset (WAD_File, 1);
    {$I+}
    If IOResult = 0 Then Begin
    {Succesfully opened DOOM2.WAD}
      GetDir (0, WAD_Name);
      WAD_Name := TT_AddSlash (WAD_Name) + 'DOOM2.WAD';
      WAD_OpenFile := True;
      Exit;
    End;

    {Couldn't open DOOM2.WAD, try opening the first WAD we find}
    FindFirst ('*.WAD', AnyFile, FileFound);
    If DOSError = 0 Then Begin
    {Found a WAD file}
      GetDir (0, WAD_Name);
      WAD_Name := TT_AddSlash (WAD_Name) + FileFound. Name;
      Assign (WAD_File, WAD_Name);
      {$I-}
      Reset (WAD_File, 1);
      {$I+}
      WAD_OpenFile := (IOResult = 0);
      Exit;
    End;

    {Couldn't open or find any WADs}
    WAD_OpenFile := False;
    Exit;
  End Else Begin
  {User specified a WAD file name}
    Assign (WAD_File, FileName);
    {$I-}
    Reset (WAD_File, 1);
    {$I+}
    If IOResult = 0 Then Begin
    {Succesfully opened specified WAD file}
      WAD_Name := FExpand (FileName);
      WAD_OpenFile := True;
      Exit;
    End;

    {Unable to open specified WAD file}
    WAD_OpenFile := False;
  End;
End;

Var
IDString: Array [1..4] Of Char;

Begin
  If WAD_OpenFile Then Begin
    {Check the first 4 byte to determine WAD type (and if it's valid)}
  BlockRead (WAD_File, IDString, 4);
    If IDString = TWAD_TypeString [1] Then
    WAD_Type := Internal
    Else If IDString = TWAD_TypeString [2] Then
    WAD_Type := Patch
    Else Begin
    WAD_Open := False;
      Exit;
    End;
    {Read in the other header data, number of entries and the pointer to}
    {the directory at the end of the file}
    BlockRead (WAD_File, WAD_NumEntries, 4);
    BlockRead (WAD_File, WAD_DirectoryPointer, 4);
  End Else
  WAD_Open := False;
End;

{Read in directory entry EntryNum (0 based)}
Function WAD_ReadEntry (EntryNum: LongInt; var Start, Length: LongInt; var Ent
Var
EntryNameZ: StringZ8;

Begin
  {$I-}
Seek (WAD_File, WAD_DirectoryPointer + (EntryNum * 16));
  {$I+}
  If IOResult = 0 Then Begin
  BlockRead (WAD_File, Start, 4);
  BlockRead (WAD_File, Length, 4);
  BlockRead (WAD_File, EntryNameZ, 8);
  EntryName := StrPas (@EntryNameZ);
    WAD_ReadEntry := True;
  End Else
    WAD_ReadEntry := False;
End;

{Search for directory entry with name EntryName (case sensitive)}
Function WAD_FindEntry (EntryName: String8): LongInt;
Var
EntryNum, Start, Length: LongInt;
  CurEntryName: String8;

Begin
For EntryNum := 0 To WAD_NumEntries - 1 Do
  If Not WAD_ReadEntry (EntryNum, Start, Length, CurEntryName) Then Begin
    WAD_FindEntry := -2;
      Exit;
    End Else
    If CurEntryName = EntryName Then Begin
      WAD_FindEntry := EntryNum;
        Exit;
      End;
  WAD_FindEntry := -1;
End;

{Read in the data for a directory entry.  Use WAD_ReadEntry first}
Function WAD_ReadEntryData (Start, Length: LongInt; Data: Pointer): Boolean;
Begin
  {$I-}
Seek (WAD_File, Start);
  BlockRead (WAD_File, Data^, Length);
  {$I+}
  WAD_ReadEntryData := (IOResult = 0);
End;

Procedure WAD_DisplayTile (RawTexture: Array of Byte);
Var
Line: Byte;

Begin
  For Line := 0 To 63 Do
  Move (RawTexture [Line * 64], Mem [$A000:Line * 320], 64);
{  Repeat Until KeyPressed;
  TextMode (LastMode);}
End;

Procedure WAD_SetPalette (RawPalette: PRawPalette); {[1..768]}
Var
Color: Byte;

Begin
For Color := 0 To 255 Do
    Mode13h. SetCol (Color, RawPalette^ [Color * 3 + 1] div 4 ,
RawPalette^ [Color * 3 + 2] div 4,
RawPalette^ [Color * 3 + 3] div 4);
End;

Procedure WAD_DisplaySprite (RawSprite: Array of Byte);
Var
Width, Height, Left, Top, X, Y, Column: Word;
  ColumnOffset, PixelOffset: LongInt;
  Pixel, Count: Byte;

Begin
Move (RawSprite [0], Width, 2);
  Move (RawSprite [2], Height, 2);
  Move (RawSprite [4], Left, 2);
  Move (RawSprite [6], Top, 2);
  For Column := 1 To Width Do Begin
    X := Column - 1;
  Move (RawSprite [4 + Column * 4], ColumnOffset, 4);

    Repeat
    {for each post}
      If Not (RawSprite [ColumnOffset] = $FF) Then Begin
    Y := RawSprite [ColumnOffset];
      Count := RawSprite [ColumnOffset + 1];
      For PixelOffset := ColumnOffset + 3 To ColumnOffset + Count + 2 Do Begi
        Inc (Y);
        PlotPixel (X, Y, RawSprite [PixelOffset]);
      End;
      ColumnOffset := ColumnOffset + Count + 4;
      End;
    Until RawSprite [ColumnOffset] = $FF;
  End;
End;

Var
Entry, Start, Length: LongInt;
  Success: Boolean;
  EntryName, WhichEntry: String8;

Begin
  ClrScr;
  WriteLn ('Enter path to WAD file');
  Write (': ');
  ReadLn (WAD_Name);

  Success := WAD_Open (WAD_Name);
  If Not Success Then Begin
  WriteLn ('Unable to open ' + WAD_Name);
    Halt;
  End;

  WriteLn ('Opened: ', WAD_Name);
  WriteLn ('Wad type: ', Ord (WAD_Type));
  WriteLn ('Num entries: ', WAD_NumEntries);
  WriteLn ('Pointer to Directory: ', WAD_DirectoryPointer);

  WriteLn;
  WriteLn ('Press any key to continue...');
  Repeat Until KeyPressed;
  ReadKey;

  WriteLn;
  WriteLn ('Directory Entries: ');
  For Entry := 0 To WAD_NumEntries - 1 Do Begin
    WAD_ReadEntry (Entry, Start, Length, EntryName);
  Write (TT_PadString (EntryName, 10));
  End;

  WriteLn ('Display which title?');
  Write (': ');
  ReadLn (WhichEntry);
  If WhichEntry = '' Then
  Halt;

Mode13h.Init;
  WAD_ReadEntry (WAD_FindEntry ('PLAYPAL'), Start, Length, EntryName);
  WAD_ReadEntryData (Start, Length, @RawPalette);
  WAD_ReadEntry (WAD_FindEntry (WhichEntry), Start, Length, EntryName);
  WAD_ReadEntryData (Start, Length, @RawTexture);
  WAD_SetPalette (@RawPalette [6145]);
{  WAD_DisplayTile (RawTexture);}
  WAD_DisplaySprite (RawTexture);
  For Entry := 8 DownTo 0 Do Begin
    Mode13h. WaitRetrace;
WAD_SetPalette (@RawPalette [768 * Entry+ 1]);
    Delay (20);

  End;
  Repeat Until KeyPressed;
  TextMode (LastMode);
End.
***

Now you need my boring Mode13h unit:

*** C:\TP\WORK\MODE13H.PAS
Unit Mode13h;

Interface

Procedure GetCol(C : Byte; Var R, G, B : Byte);
Procedure SetCol(C, R, G, B : Byte);
Procedure Init;
Procedure PlotPixel (X, Y: Word; Color: Byte);
Procedure WaitRetrace;

Implementation

Const PelAddrRgR  = $3C7;
      PelAddrRgW  = $3C8;
      PelDataReg  = $3C9;

Procedure GetCol(C : Byte; Var R, G, B : Byte);
Begin
   Port[PelAddrRgR] := C;
   R := Port[PelDataReg];
   G := Port[PelDataReg];
   B := Port[PelDataReg];
End;

Procedure SetCol(C, R, G, B : Byte);
Begin
   Port[PelAddrRgW] := C;
   Port[PelDataReg] := R;
   Port[PelDataReg] := G;
   Port[PelDataReg] := B;
End;

Procedure Init; Assembler;
Asm
mov ax, 13h
  int 10h
End;

Procedure PlotPixel (X, Y: Word; Color: Byte); Assembler;
Asm
push es
  push di
  mov ax, Y
  mov bx, ax
  shl ax, 8
  shl bx, 6
  add ax, bx
  add ax, X
  mov di, ax
  mov ax, 0A000h
  mov es, ax
  mov al, Color
  mov es:[di], al
  pop di
  pop es
End;

Procedure WaitRetrace; Assembler;
Asm;
  mov     dx, 03DAh
@@WaitRetrace_LoopA:
  in      al, dx
  and     al, 08h
  jnz     @@WaitRetrace_LoopA
@@WaitRetrace_LoopB:
  in      al, dx
  and     al, 08h
  jz      @@WaitRetrace_LoopB
End;

Begin
End.

