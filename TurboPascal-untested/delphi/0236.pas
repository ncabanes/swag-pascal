{
Hi, This is an easy made screensaver, viewing FLI files from
Autodesk animator, it's not optimized for reading FLC files, since
that would be a larger project, which i dont have enough spare-time
for now!

The "Treatframe" and "Getclock" routine was taken from Eirik Pedersens
fli player, found in snipet: "misc". I had to change Treatframe a litle
just to handle the palette. Use at your own risk.

There's not much documentation, but if there's so much you don't understand,
send me a mail, and i'll try to answer it as soon as possible!



Tommy Andersen
email: tommy.andersen@dialogue.telemax.no
snail: Tommy Andersen
       Andebuveien 11
       3170  SEM
       Norway
}


Program Fliplay;

Uses
  Forms,
  Unit1 in 'UNIT1.PAS' {Form1};

{$R *.RES}

Begin
   { Prevent multiple instances }
   IF HPrevinst <> 0 Then Exit;

   Application.CreateForm(TForm1, Form1);
   Application.Run;
End.

{ -------------  Cut out and save as UNIT1.PAS ----------------- }

Unit Unit1;

Interface

Uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

Const
  CLOCK_HZ              = 4608;                   { Frequency of clock }
  MONItoR_HZ            = 70;                     { Frequency of monitor }
  CLOCK_SCALE           = CLOCK_HZ div MONItoR_HZ;
  CDATA                 = $040;                   { Port number of timer 0 }
  CMODE                 = $043;                   { Port number of timers control Word }
  Scale_FLI             = False;                  { Set this to true if saver shall use whole screen }

Type
  Big_Buffer_Type = Array[0..65534] of Byte;
  FliHeaderType = Record
                     Size          : Longint;
                     Magic         : Word;
                     Frames        : Word;
                     Width         : Word;
                     Height        : Word;
                     Bitsperpixel  : Word;
                     Flags         : Integer;
                     Speed         : Integer;
                     Nexthead      : Longint;
                     Framesintable : Longint;
                     hfile         : Integer;
                     hframe1offset : Longint;
                     Strokes       : Longint;
                     Session       : Longint;
                     Reserved      : Array [1..88] of Byte;
                  End;
  FrameHeaderType = Record
                       Size   : LongInt;
                       Magic  : Word; { $F1FA }
                       Chunks : Word;
                       Expand : Array[1..8] of Byte;
                    End;


  TForm1 = Class(TForm)
    OpenDialog1: TOpenDialog;
    Procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  Private
    { Private declarations }
  Public
    { Public declarations }
    Start_Screensaver        : Boolean;
    MouseMovement            : Byte;
    Fli_Filename             : String;
    Screensaver_Ini_filename : String;
    ScreenBitmap             : TBitmap;


    Flifilestream            : TMemoryStream;
    FliScreenstream          : TMemoryStream;
    Screen_Buffer            : ^Big_Buffer_Type;
    File_Buffer              : ^Big_Buffer_Type;
    FLI_Header               : FLIHeaderType;
    FLI_FrameHeader          : FrameHeaderType;
    FLI_Speed                : Longint;
    FLI_Nexttime             : Longint;
    Fli_FrameNr              : Word;
    FLI_SecondPosition       : Longint;


    Procedure Get_INI_Filename;
    Procedure Read_INI_Settings;
    Procedure Write_INI_Settings;

    Procedure Create_Bitmap;
    Procedure Show_Next_Frame;
    Procedure Load_FLI_File;
    Procedure Kill_FLI_Screensaver;
  End;

Var
  Form1: TForm1;

Implementation

{$R *.DFM}

Uses Inifiles;


Function GetClock:LongInt; Assembler; {Taken from the FLILIB source}
{ this routine returns a clock With occassional spikes where time
  will look like its running backwards 1/18th of a second.  The resolution
  of the clock is 1/(18*256) = 1/4608 second.  66 ticks of this clock
  are supposed to be equal to a monitor 1/70 second tick.}
Asm
  mov  ah,0                                         { get tick count from Dos and use For hi 3 Bytes }
  int  01ah                                         { lo order count in DX, hi order in CX }
  mov  ah,dl
  mov  dl,dh
  mov  dh,cl

  mov  al,0                                         { read lo Byte straight from timer chip }
  out  CMODE,al                                         { latch count }
  mov  al,1
  out  CMODE,al                                         { set up to read count }
  in   al,CDATA                                         { read in lo Byte (and discard) }
  in   al,CDATA                                         { hi Byte into al }
  neg  al                                         { make it so counting up instead of down }
End;

Procedure TForm1.Get_INI_Filename;
Var
  Buffer : Array[0..255] of Char;
  Size   : Word;

Begin
   Size := GetSystemDirectory(Buffer, 256);
   IF Size <> 0 Then
   Begin
      Screensaver_Ini_filename := StrPas(Buffer);
      Screensaver_Ini_filename[0] := Chr(Size);
   End
    Else Screensaver_Ini_filename := 'C:\';



   { Make sure filename got the last expected slash }
   IF Screensaver_Ini_filename[Length(Screensaver_Ini_filename)] <> '\' Then
      Screensaver_Ini_filename := Screensaver_Ini_filename + '\';


   Screensaver_Ini_filename := Screensaver_Ini_filename + 'FLIPLAY.INI';
End;

Procedure TForm1.Write_INI_Settings;
Var
  Inifile : TInifile;

Begin
   Inifile := TInifile.Create(Screensaver_Ini_filename);
   Inifile.WriteString('FLI-Screensaver', 'Filename', Fli_Filename);
   Inifile.Free;
End;

Procedure TForm1.Read_INI_Settings;
Var
  Inifile : TInifile;

Begin
   Inifile := TInifile.Create(Screensaver_Ini_filename);
   Fli_Filename := Inifile.ReadString('FLI-Screensaver', 'Filename', '');
   Inifile.Free;
End;

Procedure TForm1.Load_FLI_File;
Var
  Temp : Word;

Begin
   Fli_FrameNr := 0;
   FliFileStream.Clear;

   IF FileExists(Fli_Filename) Then
   Begin
      Try
        FliFileStream.LoadFromFile(Fli_Filename);
      Except
        FliFileStream.Clear;
      End;

      IF (FliFileStream.Size > 128) Then
      Begin
         FliFileStream.Seek(0, 0);
         Temp := FliFileStream.Read(Fli_Header, 128);

         IF (Temp = 128) and (Fli_Header.Magic = $AF11) Then
         Begin
            { Ok }
            FLI_Speed := Fli_Header.Speed;
            FLI_Speed := FLI_Speed*CLOCK_SCALE;
            FLI_NextTime := 0;
         End
          Else FliFileStream.Clear;

      End;
   End;
End;

Procedure TForm1.Create_Bitmap;
Type
  BitmapHeader = Record
                    ID    : Word;
                    FSize : LongInt;
                    Ver   : LongInt;
                    Image : LongInt;
                    Misc  : LongInt;
                    Width : LongInt;
                    Height: LongInt;
                    Num   : Word;
                    Bits  : Word;
                    Comp  : LongInt;
                    ISize : LongInt;
                    XRes  : LongInt;
                    YRes  : LongInt;
                    PSize : LongInt;
                    Res   : LongInt;
                 End;

Var
  BmpHeader : BitmapHeader;
  T, myByte : Byte;
  MSize     : LongInt;


Begin
   FLIScreenStream.Clear;


   MSize := 64000;
   MSize := MSize + 1024;
   MSize := MSize + 54;

   BmpHeader.ID          := 19778;
   BmpHeader.FSize       := MSize;
   BmpHeader.Ver         := 0;
   BmpHeader.Image       := 54 + (256*4);
   BmpHeader.Misc        := 40;
   BmpHeader.Width       := 320;
   BmpHeader.Height      := 200;
   BmpHeader.Num         := 1;
   BmpHeader.Bits        := 8;
   BmpHeader.Comp        := bi_RGB;
   BmpHeader.ISize       := BmpHeader.FSize - BmpHeader.Image;
   BmpHeader.XRes        := 0;
   BmpHeader.YRes        := 0;
   BmpHeader.Res         := 0;

   FLIScreenStream.Write(BmpHeader.ID, 2);
   FLIScreenStream.Write(BmpHeader.FSize, 4);
   FLIScreenStream.Write(BmpHeader.Ver, 4);
   FLIScreenStream.Write(BmpHeader.Image, 4);
   FLIScreenStream.Write(BmpHeader.Misc, 4);
   FLIScreenStream.Write(BmpHeader.Width, 4);
   FLIScreenStream.Write(BmpHeader.Height, 4);
   FLIScreenStream.Write(BmpHeader.Num, 2);
   FLIScreenStream.Write(BmpHeader.Bits, 2);
   FLIScreenStream.Write(BmpHeader.Comp, 4);
   FLIScreenStream.Write(BmpHeader.ISize, 4);
   FLIScreenStream.Write(BmpHeader.XRes, 4);
   FLIScreenStream.Write(BmpHeader.YRes, 4);
   FLIScreenStream.Write(BmpHeader.Res, 4);


   FLIScreenStream.Seek(54, 0);
   { Create palette }
   For T := 0 To 255 do
   Begin
      { Blue }
      myByte := T;
      FLIScreenStream.Write(myByte, 1);

      { Green }
      FLIScreenStream.Write(myByte, 1);

      { Red }
      FLIScreenStream.Write(myByte, 1);

      myByte := 0;
      FLIScreenStream.Write(myByte, 1);
   End;


   FillChar(Screen_Buffer^, 64000, 0);
   FLIScreenStream.Write(Screen_Buffer^, 64000);
End;

Procedure TForm1.Kill_FLI_Screensaver;
Begin
   Freemem(Screen_Buffer, 64000);
   Freemem(File_Buffer, 65535);
   Flifilestream.Free;
   FliScreenstream.Free;
   ScreenBitmap.Free;
   Halt(0);
End;

Procedure TForm1.FormCreate(Sender: TObject);
Var
  Param : String;
  S     : String;

Begin
   Flifilestream    := TMemoryStream.Create;
   FliScreenstream  := TMemoryStream.Create;
   ScreenBitmap     := TBitmap.Create;


   Param := Uppercase( Paramstr(1) );
   Caption := 'FLI screensaver, made by Tommy Andersen!';
   Application.Title := Caption;


   Getmem(Screen_Buffer, 64000);
   Getmem(File_Buffer, 65535);


   Get_INI_Filename;
   Read_INI_Settings;


   { Config screensaver? }
   IF Param = '/C' Then
   Begin
      { Yes }
      Start_Screensaver := False;
      Windowstate := wsMinimized;


      S     := '';
      Param := FLI_Filename;
      While Pos('\', Param) > 0 do
      Begin
         S := S + Copy(Param, 1, Pos('\', Param));
         Delete(Param, 1, Pos('\', Param));
      End;
      Opendialog1.Initialdir := S;
      Opendialog1.Filename := Param;


      Opendialog1.Filter := 'FLI files|*.FLI|All files|*.*';
      IF Opendialog1.Execute Then
      Begin
         FLI_Filename := Opendialog1.Filename;
         Write_INI_Settings;
      End;


      Kill_FLI_Screensaver;
   End
    Else
     Begin
        { No! Start screensaver! }
        Create_Bitmap;
        Load_FLI_File;


        Start_Screensaver := True;
        Windowstate       := wsMaximized;
{
        Formstyle         := fsStayOnTop;
}
        Borderstyle       := bsNone;
        Color             := clBlack;
        MouseMovement     := 0;
     End;

End;

Procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y : Integer);
Begin
   IF MouseMovement > 2 Then Kill_FLI_Screensaver;
   Inc(MouseMovement);
End;

Procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
Begin
   Kill_FLI_Screensaver;
End;

Procedure TForm1.Show_Next_Frame;
Type
  Paltype = Array[0..767] of Byte;

Var
  Temp    : Word;
  Nextpos : Longint;
  Palette : ^Paltype;
  Paladdr : Word;

Procedure TreatFrame(Var Buffer, ScreenBuffer, Palette; Chunks:Word); Assembler;
{ this is the 'workhorse' routine that takes a frame and put it on the screen }
{ chunk by chunk }
Label
  Color_Loop, Copy_Bytes, Copy_Bytes2, Exit, Fli_Black, Fli_Brun, Fli_Color,
  Fli_Copy, Fli_Lc, Fli_Loop, Jump_Over, Line_Loop, Line_Loop2, Next_Line,
  Next_Line2, Pack_Loop, Pack_Loop2, C_Loop;

Asm
  Cli

  push ds
  lds  si,Buffer                                 { let DS:SI point at the frame to be drawn }

Fli_Loop:                                        { main loop that goes through all the chunks in a frame }
  cmp  Chunks,0                                  { are there any more chunks to draw? }
  je   Exit
  dec  Chunks                                    { decrement Chunks For the chunk to process now }

  mov  ax,[Word ptr ds:si+4]                     { let AX have the ChunkType }
  add  si,6                                      { skip the ChunkHeader }

  cmp  ax,0Bh                                    { is it a FLI_COLor chunk? }
  je   Fli_Color
  cmp  ax,0Ch                                    { is it a FLI_LC chunk? }
  je   Fli_Lc
  cmp  ax,0Dh                                    { is it a FLI_BLACK chunk? }
  je   Fli_Black
  cmp  ax,0Fh                                    { is it a FLI_BRUN chunk? }
  je   Fli_Brun
  cmp  ax,10h                                    { is it a FLI_COPY chunk? }
  je   Fli_Copy
  jmp  Fli_Loop                                  { This command should not be necessary since the Program should make one - }
                                                 { - of the other jumps }

Fli_Color:
  mov  bx,[Word ptr ds:si]                       { number of packets in this chunk (allways 1?) }
  add  si,2                                      { skip the NumberofPackets }
  mov  al,0                                      { start at color 0 }
  xor  cx,cx                                     { reset CX }

Color_Loop:
  or   bx,bx                                     { set flags }
  jz   Fli_Loop                                  { Exit if no more packages }
  dec  bx                                        { decrement NumberofPackages For the package to process now }

  mov  cl,[Byte ptr ds:si+0]                     { first Byte in packet tells how many colors to skip }
  add  al,cl                                     { add the skiped colors to the start to get the new start }

  mov  cl,[Byte ptr ds:si+1]                     { next Byte in packet tells how many colors to change }
  or   cl,cl                                     { set the flags }
  jnz  Jump_Over                                 { if NumberstoChange=0 then NumberstoChange=256 }
  inc  ch                                        { CH=1 and CL=0 => CX=256 }
Jump_Over:
  add  al,cl                                     { update the color to start at }
  mov  di,cx                                     { since each color is made of 3 Bytes (Red, Green & Blue) we have to - }
  shl  cx,1                                      { - multiply CX (the data counter) With 3 }
  add  cx,di                                     { - CX = old_CX shl 1 + old_CX   (the fastest way to multiply With 3) }
  add  si,2                                      { skip the NumberstoSkip and NumberstoChange Bytes }


  { Find start position }
  Les  di, Palette
  Mov  CL, AL
@LLL:
  Cmp  CL, 0
  Je   C_Loop
  Dec  CL
  Add  di, 3
  Jmp  @LLL

C_Loop:
  Cmp  CX, 0
  Je   Color_Loop
  Dec  CX
  Mov  AL, [Byte ptr DS:SI]
  Add  AL, AL
  Add  AL, AL
  Mov  [Byte ptr ES:DI], AL
  Inc  SI
  Inc  DI
  Jmp  C_Loop


Fli_Lc:
  Les  di, ScreenBuffer

  mov  di,[Word ptr ds:si+0]                     { put LinestoSkip into DI - }
  mov  ax,di                                     { - to get the offset address to this line we have to multiply With 320 - }
  shl  ax,8                                      { - DI = old_DI shl 8 + old_DI shl 6 - }
  shl  di,6                                      { - it is the same as DI = old_DI*256 + old_DI*64 = old_DI*320 - }
  add  di,ax                                     { - but this way is faster than a plain mul }
  mov  bx,[Word ptr ds:si+2]                     { put LinestoChange into BX }
  add  si,4                                      { skip the LinestoSkip and LinestoChange Words }
  xor  cx,cx                                     { reset cx }

Line_Loop:
  or   bx,bx                                     { set flags }
  jz  Fli_Loop                                   { Exit if no more lines to change }
  dec  bx

  mov  dl,[Byte ptr ds:si]                       { put PacketsInLine into DL }
  inc  si                                        { skip the PacketsInLine Byte }
  push di                                        { save the offset address of this line }

Pack_Loop:
  or   dl,dl                                     { set flags }
  jz   Next_Line                                 { Exit if no more packets in this line }
  dec  dl
  mov  cl,[Byte ptr ds:si+0]                     { put BytestoSkip into CL }
  add  di,cx                                     { update the offset address }
  mov  cl,[Byte ptr ds:si+1]                     { put BytesofDatatoCome into CL }
  or   cl,cl                                     { set flags }
  jns  Copy_Bytes                                { no SIGN means that CL number of data is to come - }
                                                 { - else the next data should be put -CL number of times }
  mov  al,[Byte ptr ds:si+2]                     { put the Byte to be Repeated into AL }
  add  si,3                                      { skip the packet }
  neg  cl                                        { Repeat -CL times }
  rep  stosb
  jmp  Pack_Loop                                 { finish With this packet }

Copy_Bytes:
  add  si,2                                      { skip the two count Bytes at the start of the packet }
  rep  movsb
  jmp  Pack_Loop                                 { finish With this packet }

Next_Line:
  pop  di                                        { restore the old offset address of the current line }
  add  di,320                                    { offset address to the next line }
  jmp  Line_Loop


Fli_Black:
  Les  di, ScreenBuffer

  xor  di,di
  mov  cx,32000                                  { number of Words in a screen }
  xor  ax,ax                                     { color 0 is to be put on the screen }
  rep  stosw
  jmp  Fli_Loop                                  { jump back to main loop }


Fli_Brun:
  Les  di, ScreenBuffer

  xor  di,di
  mov  bx,200                                    { numbers of lines in a screen }
  xor  cx,cx

Line_Loop2:
  mov  dl,[Byte ptr ds:si]                       { put PacketsInLine into DL }
  inc  si                                        { skip the PacketsInLine Byte }
  push di                                        { save the offset address of this line }

Pack_Loop2:
  or   dl,dl                                     { set flags }
  jz   Next_Line2                                { Exit if no more packets in this line }
  dec  dl
  mov  cl,[Byte ptr ds:si]                       { put BytesofDatatoCome into CL }
  or   cl,cl                                     { set flags }
  js   Copy_Bytes2                               { SIGN meens that CL number of data is to come - }
                                                 { - else the next data should be put -CL number of times }
  mov  al,[Byte ptr ds:si+1]                     { put the Byte to be Repeated into AL }
  add  si,2                                      { skip the packet }
  rep  stosb
  jmp  Pack_Loop2                                { finish With this packet }

Copy_Bytes2:
  inc  si                                        { skip the count Byte at the start of the packet }
  neg  cl                                        { Repeat -CL times }
  rep  movsb
  jmp  Pack_Loop2                                { finish With this packet }

Next_Line2:
  pop  di                                        { restore the old offset address of the current line }
  add  di,320                                    { offset address to the next line }
  dec  bx                                        { any more lines to draw? }
  jnz  Line_Loop2
  jmp  Fli_Loop                                  { jump back to main loop }


Fli_Copy:
  Les  di, ScreenBuffer

  xor  di,di
  mov  cx,32000                                  { number of Words in a screen }
  rep  movsw
  jmp  Fli_Loop                                  { jump back to main loop }


Exit:
  mov  ax, 0
  mov  es, ax
  pop  ds

  Sti
end;

Procedure ReadPalette;
Var
  T, Zero : Byte;

Begin
   FLIScreenstream.Seek(54, 0);
   For T := 0 to 255 do
   Begin
      FLIScreenStream.Read(Palette^[T*3+2], 1); { Blue }
      FLIScreenStream.Read(Palette^[T*3+1], 1); { Green }
      FLIScreenStream.Read(Palette^[T*3], 1); { Red }
      FLIScreenStream.Read(Zero, 1);         { Zero }
   End;
End;

Procedure WritePalette;
Var
  T, Zero : Byte;

Begin
   Zero := 0;

   FLIScreenStream.Seek(54, 0);
   For T := 0 to 255 do
   Begin
      FLIScreenStream.Write(Palette^[T*3+2], 1); { Blue }
      FLIScreenStream.Write(Palette^[T*3+1], 1); { Green }
      FLIScreenStream.Write(Palette^[T*3], 1); { Red }
      FLIScreenStream.Write(Zero, 1);         { Zero }
   End;
End;

Procedure Write_To_Screen;
Var
  Y : Word;

Begin
   FLIScreenStream.Seek(1078, 0);

   For Y := 199 downto 0 do
   Begin
      FLIScreenStream.Write(Screen_Buffer^[Y*320], 320);
   End;
End;


Begin
   IF GetClock < FLI_Nexttime Then Exit;


   IF (FliFileStream.Size > 128) Then
   Begin
      FillChar(FLI_FrameHeader, 16, 0);
      FliFileStream.Read(FLI_FrameHeader.Size, 4);
      FliFileStream.Read(FLI_FrameHeader.Magic, 2);
      FliFileStream.Read(FLI_FrameHeader.Chunks, 2);
      FliFileStream.Read(FLI_FrameHeader.Expand, 8);

      IF (FLI_FrameHeader.Magic = $F1FA) Then
      Begin
         FLI_FrameHeader.Size := FLI_FrameHeader.Size - 16;
         FliFileStream.Read(File_Buffer^, FLI_FrameHeader.Size);

         Getmem(Palette, 768);
         Paladdr := Seg(Palette^);
         ReadPalette;
         TreatFrame(File_Buffer^, Screen_Buffer^, Palette^, FLI_FrameHeader.Chunks);
         WritePalette;
         Freemem(Palette, 768);

         Write_To_Screen;


         IF FLI_FrameNr = 0 Then
         Begin
            FLI_SecondPosition := FliFileStream.Position;
         End;


         Inc(Fli_FrameNr);
         IF Fli_FrameNr > FLI_Header.Frames Then
         Begin
            FliFileStream.Seek(FLI_SecondPosition, 0);
            Fli_FrameNr := 1;
         End;


         FLI_NextTime := GetClock + FLI_Speed;
      End;
   End;
End;

Procedure TForm1.FormPaint(Sender: TObject);
Begin
   IF not Start_Screensaver Then Exit;
   Start_Screensaver := False;

   While True do
   Begin
      Show_Next_Frame;


      FLIScreenStream.Seek(0, 0);
      Try
        ScreenBitmap.LoadFromStream(FLIScreenStream);
      Except
      End;

      IF not Scale_FLI Then Canvas.Draw((Screen.Width div 2) - 160, (Screen.Height div 2) - 100, ScreenBitmap)
         Else Canvas.StretchDraw(ClientRect, ScreenBitmap);

      Application.ProcessMessages;
   End;
End;

End.

{ -------------  Cut out and save as UNIT1.DFM ----------------- }

object Form1: TForm1
  Left = 216
  Top = 168
  Width = 435
  Height = 300
  Caption = 'Form1'
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'System'
  Font.Style = []
  PixelsPerInch = 96
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnMouseMove = FormMouseMove
  OnPaint = FormPaint
  TextHeight = 16
  object OpenDialog1: TOpenDialog
    Left = 4
    Top = 4
  end
end
