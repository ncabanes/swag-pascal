{ ANSI_IO  [ANSI Input / Output Unit]

  Written: 01/15/97-01/31/97
  Author: Chad Moore
  Requirements:
    - 80386+ CPU
    - Color CGA+ video adaptor (for 80x25C Textmode)
    - Borland Turbo Pascal 6.0+ to compile
    Recommended System:
    - Color VGA video adaptor (for extended textmodes such as 80x50
      or 80x43 on EGA)
  Notes:
    - This unit currently does not support changing the current video
      mode.  If you would like to enter a different mode such as 80x28,
      80x30, 80x35, 80x43, 80x50, or 80x60 you must use a different
      unit or your own code.
    - When using the virtual screen set up for direct video output, all
      cursor movements are still virtual.  The actual text cursor will
      not be modified by this program.  (This does not hinder the unit
      in any way.)
    - To modify the screen size for direct video output, simply modify
      the constant values below.
  History:
    v1.00: 01/15/97-01/20/97
      - Features:
        ■ Object oriented code
        ■ Error handling
        ■ Buffered output (for scrolling)
        ■ Also supports direct video output
    v1.01: 01/21/97
      - FIXED: cursor positioning errors
      - FIXED: error handling errors
    v1.02: 01/23/97
      - UPDATED: Changed 'ANSIHandlerObj.WriteCh' to support
        CR/LF characters.
      - FIXED: virtical wrap-around errors
      - UPDATED: direct virtual screen routines _may_ support any
        screen type (ex: 80x25, 80x43, 80x50), including non-standard
        modes (ex: 80x28, 80x30)
      - UPDATED: added "scrolling" to direct video output
    v1.03: 01/26/97-01/28/97
      - FIXED: 'ANSIHandlerObj.ClearFromCursorToEndOfLine' only worked
        when 'VirtualScreen.Cursor.Y' was equal to 0.
      - UPDATED: virtual screen routines were optomized-- some routines
        were written in inline ASM, some lookup constants were added
        to speed up some routines.
      - UPDATED: 286 instructions for faster virtualscreen writing.
      - UPDATED: removed a lot of "if" statements by adding a
        single video screen size constant.
    v1.04: 01/28/97-01/31/97
      - Features:
        ■ ANSI routines for both input and output.  These routines
          can be used for converting an image -> ANSI code or ANSI
          codes -> an image!
        ■ Much faster routines for faster loading and displaying!
      - UPDATED: Changed 'VirtualScreenObj.WriteCh' to support
        CR/LF characters.
      - FIXED: WriteCh (ansi) didn't support the 'H' or 'f' commands
        w/o parameters.  (now defaults to 1,1)
      - UPDATED: 386 instructions for faster virtualscreen writing.

  Compiled with Borland International's Turbo Pascal 7.0 for DOS.
  Tested on an Intel 486SX-20MHz system w/ a color VGA display.

  Disclaimer:

  There is no garentee that comes with this source code; the author of
  this unit is NOT responsible for any direct or indirect damages
  caused by this program.  Use it at your own risk.

  Contacting the author:

  NOTE: All comments/questions/suggestions are welcome!  Also, any
        additions or modifications are welcome!

  Chad Moore can be reached via Internet e-mail at: war@usaor.net

  Or send a letter to: Chad Moore
                       535 Mellon Ave.
                       Rochester, PA
                       15074-1237
}

{$G+} { Enable 286/287 instructions }
unit ANSI_IO;

interface

const
  { Release information }
  Version = $0104;
  { Defaults }
  VideoSegment = $B800; { $B800 for color; DOES NOT SUPPORT MONO }
  TextModeLength = 25; { # of lines in selected textmode }
  TextModeWidth = 80;
  { Virtual screen constants }
  VirtualScreenLength = 400; { Set to 'TextModeRows' for __ONLY__ direct video output }
  VirtualScreenWidth = 80;
  VirtualScreenSize = VirtualScreenLength * VirtualScreenWidth;
  { ANSI parameter constants }
  ParameterBufferLength = 5;
  ParameterBufferSize = ParameterBufferLength * 3;
  { ANSI Error values }
  ANSIErrorListLength = 7;
  ANSIErrorList : array [0..ANSIErrorListLength - 1] of string = (
  'None',
  'ANSI routines not initialized',
  'Virtual screen not initialized',
  'Invalid format',
  'Too many parameters',
  'Parameter too long',
  'Cannot execute command'
  );

type
  PosRec = record
    X : Byte;
    Y : Integer;
  end;
  ScreenCharRec = record
    Character,
    Attribute : Byte;
  end;
  PScreenType = ^ScreenType;
  ScreenType = array [0..VirtualScreenSize - 1] of ScreenCharRec;
  VirtualScreenObj = object
    ActiveAttribute : Byte;
    DirectVideo : Boolean;
    Data : PScreenType;
    MemForData : Word;
    EndOfBuffer : Boolean; { Not used w/ direct video }
    Cursor : PosRec;
    Initialized : Boolean;
    procedure Error ( Command : Byte );
    function Init : Byte;
    function InitDirectVideo : Byte;
    procedure DeInit;
    procedure Clear;
    procedure GotoXY ( X : Byte; Y : Integer );
    procedure ScrollScreenUp; { Direct video __ONLY__ }
    procedure WriteCR;
    procedure WriteCh ( Ch : Char );
    procedure WriteStr ( Str : string );
    procedure WriteStrLn ( Str : string );
  end;
  ANSIHandlerObj = object
    ParameterBuffer : array [0..ParameterBufferLength - 1,0..2] of Char;
    ParameterRow,
    ParameterColumn : Byte;
    LastCharacter : Char;
    Escape, EscapeSequence : Boolean;
    SavedCursor : PosRec;
    LastError : Byte;
    procedure Init;
    procedure DeInit;
    procedure ClearParameterBuffer;
    function ReturnParameters : string;
    function Attribute : Boolean;
    function ClearCommand : Boolean;
    function EraseFromCursorToEndOfLine : Boolean;
    function PositionCursor ( Command : Char ) : Boolean;
    function CursorUp : Boolean;
    function CursorDown : Boolean;
    function CursorRight : Boolean;
    function CursorLeft : Boolean;
    function CursorUpCommand : Boolean;
    function CursorDownCommand : Boolean;
    function CursorRightCommand : Boolean;
    function CursorLeftCommand : Boolean;
    procedure SaveCursorLocation;
    procedure RestoreCursorLocation;
    function ProcessCommand ( Command : Char ) : Boolean;
    function WriteCh ( Ch : Char ) : Byte;
    procedure WriteStr ( Str : string );

    function SetClearScreen : string;
    function SetAttribute ( FromAttribute : Integer; ToAttribute : Byte ) : string;
    function SetCursorPosition ( X, Y : Byte ) : string;
    function SetCursorUp ( Num : Byte ) : string;
    function SetCursorDown ( Num : Byte ) : string;
    function SetCursorLeft ( Num : Byte ) : string;
    function SetCursorRight ( Num : Byte ) : string;
    function SetSaveCursorPosition : string;
    function SetRestoreCursorPosition : string;
  end;

var
  ScreenWidth, ScreenLength, ScreenSize : Word;
  VirtualScreen : VirtualScreenObj;
  ANSIHandler : ANSIHandlerObj;

implementation

procedure VirtualScreenObj.Error ( Command : Byte );

type
  ErrRec = record
    Msg : string;
    Cmd : Byte;
      { Cmd:  $00 : None }
      {       $01 : Halt }
  end;

const
  NumErrorTypes = $02;
  ErrorHandler : array [0..NumErrorTypes - 1] of ErrRec = (
  (Msg : ''; Cmd : $00),
  (Msg : 'Out of Memory'; Cmd : $01)
  { This format of storing the errors & commands is very configurable }
  );

begin
  if ErrorHandler[Command].Msg <> '' then begin
    WriteLn;
    WriteLn('ERROR: ', ErrorHandler[Command].Msg);
  end;
  case ErrorHandler[Command].Cmd of
    $01 : begin
      Halt($0000);
    end;
  end;
end;

function VirtualScreenObj.Init : Byte;
begin
  Init := $00;
  MemForData := SizeOf(Data^);
  if MaxAvail > MemForData then begin
    { Get memory }
    GetMem(Data, MemForData);
    { Initialize values }
    Clear;
    EndOfBuffer := False;
    ActiveAttribute := 7;
    ScreenLength := VirtualScreenLength;
    ScreenWidth := VirtualScreenWidth;
    ScreenSize := ScreenLength * ScreenWidth;
    Initialized := True;
    DirectVideo := False;
  end
  else Init := $01;
end;

function VirtualScreenObj.InitDirectVideo : Byte;
begin
  InitDirectVideo := $00;
  { Set Data -> VideoSegment:$0000 }
  Data := Ptr(VideoSegment,$0000);
  ScreenLength := TextModeLength;
  ScreenWidth := TextModeWidth;
  ScreenSize := TextModeLength * TextModeWidth;
  DirectVideo := True;
  { Initialize values }
  Clear;
  EndOfBuffer := False;
  Cursor.X := 0;
  Cursor.Y := 0;
  ActiveAttribute := 7;
  Initialized := True;
end;

procedure VirtualScreenObj.DeInit;
begin
  FreeMem(Data, MemForData);
  ScreenWidth := 0;
  ScreenLength := 0;
  ScreenSize := 0;
end;

procedure VirtualScreenObj.Clear;

var
  AA : Byte;

begin
  AA := VirtualScreen.ActiveAttribute;
  asm
    mov cx,VideoSegment
    mov es,cx
    xor di,di
    mov cx,ScreenSize        { CX = ScreenSize/2 }
    shr cx,1                 { CX = ScreenSize/4 }
    mov ah,AA
    mov al,$20
    db 66h; shl ax,16        { move AX to high word of EAX }
    mov ah,AA
    mov al,$20               { set AX again }
    db 66h; rep stosw        { REP STOSD }
  end;
  Cursor.X := 0; Cursor.Y := 0;
  EndOfBuffer := False;
end;

procedure VirtualScreenObj.GotoXY ( X : Byte; Y : Integer );
begin
  if (Cursor.Y < ScreenLength) and (Cursor.X < ScreenWidth) then begin
    Cursor.X := X;
    Cursor.Y := Y;
    EndOfBuffer := False;
  end;
end;

procedure VirtualScreenObj.ScrollScreenUp;
begin
  { adjust display }
  Move(Mem[$B800:160],Mem[$B800:0],ScreenSize shl 1);
  Dec(Cursor.Y);
end;

procedure VirtualScreenObj.WriteCR;
begin
  Cursor.X := 0;
  Inc(Cursor.Y);
  if DirectVideo then begin
    while Cursor.Y >= ScreenLength do ScrollScreenUp;
  end
  else begin
    if Cursor.Y >= ScreenLength then begin
      EndOfBuffer := True;
      while Cursor.Y >= ScreenLength do Dec(Cursor.Y);
    end;
  end;
end;

procedure VirtualScreenObj.WriteCh ( Ch : Char );

var
  Value : Integer;

begin
  Value := Cursor.Y * ScreenWidth + Cursor.X;
  { This speeds up the routine ever so SLIGHTLY... }
  if Ch = #10 then begin
    Cursor.X := 0;
  end
  else if Ch = #13 then begin
    Inc(Cursor.Y);
    if DirectVideo then begin
      while Cursor.Y >= ScreenLength do ScrollScreenUp;
    end
    else begin
      if Cursor.Y >= ScreenLength then begin
        EndOfBuffer := True;
        while Cursor.Y >= ScreenLength do Dec(Cursor.Y);
      end;
    end;
  end
  else begin
    VirtualScreen.Data^[Value].Character := Ord(Ch);
    VirtualScreen.Data^[Value].Attribute := ActiveAttribute;
    Inc(Cursor.X);
    if Cursor.X >= ScreenWidth then begin
      Cursor.X := 0;
      Inc(Cursor.Y);
      if DirectVideo then begin
        while Cursor.Y >= ScreenLength do ScrollScreenUp;
      end
      else begin
        if Cursor.Y >= ScreenLength then begin
          EndOfBuffer := True;
          while Cursor.Y >= ScreenLength do Dec(Cursor.Y);
        end;
      end;
    end;
  end;
end;

procedure VirtualScreenObj.WriteStr ( Str : string );

var
  I : Byte;

begin
  for I := 1 to Length(Str) do WriteCh(Str[I]);
end;

procedure VirtualScreenObj.WriteStrLn ( Str : string );

var
  I : Byte;

begin
  for I := 1 to Length(Str) do WriteCh(Str[I]);
  WriteCR;
end;

procedure ANSIHandlerObj.Init;
begin
  LastError := 0;
  Escape := False;
  EscapeSequence := False;
  ClearParameterBuffer;
end;

procedure ANSIHandlerObj.DeInit;
begin
  LastError := 1;
end;

procedure ANSIHandlerObj.ClearParameterBuffer;
begin
  FillChar(ParameterBuffer,ParameterBufferSize,#255);
  ParameterRow := 0;
  ParameterColumn := 0;
end;

function ANSIHandlerObj.ReturnParameters : string;

var
  I, J : Integer;
  ParameterString : string;

begin
  ParameterString := '';
  for J := 0 to ParameterRow do
    if J = ParameterRow then begin
      for I := 0 to ParameterColumn do begin
        if (I = 0) and (J > 0) then
          if ParameterBuffer[J,I] <> #255 then ParameterString := ParameterString + ';';
        if ParameterBuffer[J,I] <> #255 then ParameterString := ParameterString + ParameterBuffer[J,I];
      end;
    end
    else begin
      for I := 0 to 2 do begin
        if (I = 0) and (J > 0) then ParameterString := ParameterString + ';';
        if ParameterBuffer[J,I] <> #255 then ParameterString := ParameterString + ParameterBuffer[J,I];
      end;
    end;
  ReturnParameters := ParameterString;
end;

function ANSIHandlerObj.Attribute : Boolean;

const
  Colors : array [0..7] of Byte = (0, 4, 2, 6, 1, 5, 3, 7);

var
  I, Foreground, Background,
  Number, OldAttribute : Byte;
  Intensity, Blink : Boolean;

begin
  Attribute := True;
  OldAttribute := VirtualScreen.ActiveAttribute;
  if OldAttribute >= 128 then begin
    Blink := True;
    OldAttribute := OldAttribute - 128;
  end
  else Blink := False;
  Background := (OldAttribute shr 4);
  if (OldAttribute mod 16) > 7 then begin
    Intensity := True;
    Foreground := (OldAttribute mod 16) - 8;
  end
  else begin
    Intensity := False;
    Foreground := (OldAttribute mod 16);
  end;
  for I := 0 to ParameterBufferLength - 1 do begin
    if ParameterBuffer[I,0] <> #255 then begin
      if ParameterBuffer[I,1] = #255 then begin
        Number := Ord (ParameterBuffer[I,0]) - 48;
      end
      else if ParameterBuffer[I,2] = #255 then begin
        Number := (Ord (ParameterBuffer[I,0]) - 48) * 10;
        Number := Number + (Ord (ParameterBuffer[I,1]) - 48);
      end
      else begin
        Number := (Ord (ParameterBuffer[I,0]) - 48) * 100;
        Number := Number + (Ord (ParameterBuffer[I,1]) - 48) * 10;
        Number := Number + (Ord (ParameterBuffer[I,2]) - 48);
      end;
      case Number of
        0 : begin
          Foreground := 7;
          Background := 0;
          Intensity := False;
          Blink := False;
        end;
        1 : Intensity := True;
        5 : Blink := True;
        7 : begin
          OldAttribute := Foreground;
          Foreground := Background;
          Background := OldAttribute;
        end;
        30..37 : Foreground := Colors [Number - 30];
        40..47 : Background := Colors [Number - 40];
        else begin { Unknown command }
          Attribute := False;
          { In this instance, the unknown command is ignoured and the
            current block is not terminated.  If desired, uncomment
            the next line. }
          { Exit; }
        end;
      end;
    end;
  end;
  VirtualScreen.ActiveAttribute := Background shl 4;
  if Intensity then VirtualScreen.ActiveAttribute := VirtualScreen.ActiveAttribute + (Foreground + 8)
  else VirtualScreen.ActiveAttribute := VirtualScreen.ActiveAttribute + Foreground;
  if Blink then VirtualScreen.ActiveAttribute := VirtualScreen.ActiveAttribute + 128;
end;

function ANSIHandlerObj.ClearCommand : Boolean;
begin
  ClearCommand := True;
  if ParameterRow = 0 then begin
    if ParameterBuffer[0,0] = #255 then ClearCommand := False
    else if ParameterBuffer[0,1] = #255 then begin
      case ParameterBuffer[0,0] of
{        '0' : ; }{ Clear from cursor up? }
{        '1' : ; }{ Clear from cursor down? }
        '2' : VirtualScreen.Clear; { Clear screen }
        else ClearCommand := False;
      end;
    end
    else if ParameterBuffer[0,2] = #255 then ClearCommand := False;
  end
  else ClearCommand := False;
end;

function ANSIHandlerObj.EraseFromCursorToEndOfLine : Boolean;

var
  ValueY : Word;
  I, X, AA, Count : Byte;

begin
  EraseFromCursorToEndOfLine := True;
  if VirtualScreen.Initialized then begin
    X := VirtualScreen.Cursor.X;
    if VirtualScreen.DirectVideo then begin
      ValueY := VirtualScreen.Cursor.Y * ScreenWidth;
      Count := ScreenWidth - X;
    end
    else begin
      ValueY := VirtualScreen.Cursor.Y * ScreenWidth;
      Count := ScreenWidth - X;
    end;
    AA := VirtualScreen.ActiveAttribute;
    asm
      mov cx,VideoSegment
      mov es,cx
      mov di,ValueY
      shl di,1
      xor ah,ah
      mov al,X
      shl ax,1
      add di,ax
      shl di,1
      xor ch,ch
      mov cl,Count
      shr cl,1
      mov ah,AA              { Set AX }
      mov al,$20
      db 66h; shl ax,16      { Shift AX -> high end of EAX }
      mov ah,AA              { Set AX }
      mov al,$20
      db 66h; rep stosw      { REP STOSD }
    end;
    VirtualScreen.WriteCR;
  end
  else EraseFromCursorToEndOfLine := False;
end;

function ANSIHandlerObj.PositionCursor ( Command : Char ) : Boolean;

var
  Number : Byte;

begin
  PositionCursor := True;
  if ParameterRow = 1 then begin
    if ParameterBuffer[0,1] = #255 then Number := Ord (ParameterBuffer[0,0]) - 48
    else if ParameterBuffer[0,2] = #255 then begin
      Number := 10 * (Ord (ParameterBuffer[1,0]) - 48);
      Number := Number + (Ord (ParameterBuffer[1,1]) - 48);
    end
    else begin
      Number := 100 * (Ord (ParameterBuffer[0,0]) - 48);
      Number := Number + (10 * (Ord (ParameterBuffer[0,1]) - 48));
      Number := Number + (Ord (ParameterBuffer[0,2]) - 48);
    end;
    if (Number > 0) and (Number <= ScreenLength) then VirtualScreen.Cursor.Y := Number - 1;
    if ParameterBuffer[1,1] = #255 then Number := Ord (ParameterBuffer[1,0]) - 48
    else if ParameterBuffer[1,2] = #255 then begin
      Number := 10 * (Ord (ParameterBuffer[1,0]) - 48);
      Number := Number + (Ord (ParameterBuffer[1,1]) - 48);
    end
    else begin
      Number := 100 * (Ord (ParameterBuffer[1,0]) - 48);
      Number := Number + (10 * (Ord (ParameterBuffer[1,1]) - 48));
      Number := Number + (Ord (ParameterBuffer[1,2]) - 48);
    end;
    if (Number > 0) and (Number <= ScreenWidth) then VirtualScreen.Cursor.X := Number - 1;
  end
  else begin
    VirtualScreen.Cursor.X := 0;
    VirtualScreen.Cursor.Y := 0;
  end;
end;

function ANSIHandlerObj.CursorUp : Boolean;
begin
  CursorUp := True;
  if VirtualScreen.Cursor.Y > 0 then begin
    Dec(VirtualScreen.Cursor.Y);
  end
  else CursorUp := False;
end;

function ANSIHandlerObj.CursorDown : Boolean;
begin
  CursorDown := True;
  if VirtualScreen.Cursor.Y < ScreenLength - 1 then begin
    Inc(VirtualScreen.Cursor.Y);
  end
  else CursorDown := False;
end;

function ANSIHandlerObj.CursorRight : Boolean;
begin
  CursorRight := True;
  if VirtualScreen.Cursor.X < ScreenWidth - 1 then begin
    Inc(VirtualScreen.Cursor.X);
  end
  else begin
    if VirtualScreen.Cursor.Y < ScreenLength - 1 then begin
      Inc(VirtualScreen.Cursor.Y);
      VirtualScreen.Cursor.X := 0;
    end
    else CursorRight := False;
  end;
end;

function ANSIHandlerObj.CursorLeft : Boolean;
begin
  CursorLeft := True;
  if VirtualScreen.Cursor.X > 0 then begin
    Dec(VirtualScreen.Cursor.X);
  end
  else CursorLeft := False;
end;

function ANSIHandlerObj.CursorUpCommand : Boolean;

var
  I, Number : Byte;

begin
  CursorUpCommand := True;
  if ParameterRow = 0 then begin
    if ParameterBuffer[0,0] = #255 then Number := 1
    else if ParameterBuffer[0,1] = #255 then Number := Ord (ParameterBuffer[0,0]) - 48
    else if ParameterBuffer[0,2] = #255 then begin
      Number := 10 * (Ord (ParameterBuffer[0,0]) - 48);
      Number := Number + (Ord (ParameterBuffer[0,1]) - 48);
    end
    else begin
      Number := 100 * (Ord (ParameterBuffer[0,0]) - 48);
      Number := Number + (10 * (Ord (ParameterBuffer[0,1]) - 48));
      Number := Number + (Ord (ParameterBuffer[0,2]) - 48);
    end;
    if Number > 0 then for I := 1 to Number do begin
      if not CursorUp then CursorUpCommand := False;
    end;
  end
  else CursorUpCommand := False;
end;

function ANSIHandlerObj.CursorDownCommand : Boolean;

var
  I, Number : Byte;

begin
  CursorDownCommand := True;
  if ParameterRow = 0 then begin
    if ParameterBuffer[0,0] = #255 then Number := 1
    else if ParameterBuffer[0,1] = #255 then Number := Ord (ParameterBuffer[0,0]) - 48
    else if ParameterBuffer[0,2] = #255 then begin
      Number := 10 * (Ord (ParameterBuffer[0,0]) - 48);
      Number := Number + (Ord (ParameterBuffer[0,1]) - 48);
    end
    else begin
      Number := 100 * (Ord (ParameterBuffer[0,0]) - 48);
      Number := Number + (10 * (Ord (ParameterBuffer[0,1]) - 48));
      Number := Number + (Ord (ParameterBuffer[0,2]) - 48);
    end;
    if Number > 0 then for I := 1 to Number do begin
      if not CursorDown then CursorDownCommand := False;
    end;
  end
  else CursorDownCommand := False;
end;

function ANSIHandlerObj.CursorRightCommand : Boolean;

var
  I, Number : Byte;

begin
  CursorRightCommand := True;
  if ParameterRow = 0 then begin
    if ParameterBuffer[0,0] = #255 then Number := 1
    else if ParameterBuffer[0,1] = #255 then Number := Ord (ParameterBuffer[0,0]) - 48
    else if ParameterBuffer[0,2] = #255 then begin
      Number := 10 * (Ord (ParameterBuffer[0,0]) - 48);
      Number := Number + (Ord (ParameterBuffer[0,1]) - 48);
    end
    else begin
      Number := 100 * (Ord (ParameterBuffer[0,0]) - 48);
      Number := Number + (10 * (Ord (ParameterBuffer[0,1]) - 48));
      Number := Number + (Ord (ParameterBuffer[0,2]) - 48);
    end;
    if Number > 0 then for I := 1 to Number do begin
      if not CursorRight then CursorRightCommand := False;
    end;
  end
  else CursorRightCommand := False;
end;

function ANSIHandlerObj.CursorLeftCommand : Boolean;

var
  I, Number : Byte;

begin
  CursorLeftCommand := True;
  if ParameterRow = 0 then begin
    if ParameterBuffer[0,0] = #255 then Number := 1
    else if ParameterBuffer[0,1] = #255 then Number := Ord (ParameterBuffer[0,0]) - 48
    else if ParameterBuffer[0,2] = #255 then begin
      Number := 10 * (Ord (ParameterBuffer[0,0]) - 48);
      Number := Number + (Ord (ParameterBuffer[0,1]) - 48);
    end
    else begin
      Number := 100 * (Ord (ParameterBuffer[0,0]) - 48);
      Number := Number + (10 * (Ord (ParameterBuffer[0,1]) - 48));
      Number := Number + (Ord (ParameterBuffer[0,2]) - 48);
    end;
    if Number = 255 then VirtualScreen.Cursor.X := 0 { Cursor at beginning of line }
    else if Number > 0 then for I := 1 to Number do begin
      if not CursorLeft then CursorLeftCommand := False;
    end;
  end
  else CursorLeftCommand := False;
end;

procedure ANSIHandlerObj.SaveCursorLocation;
begin
  SavedCursor.X := VirtualScreen.Cursor.X;
  SavedCursor.Y := VirtualScreen.Cursor.Y;
end;

procedure ANSIHandlerObj.RestoreCursorLocation;
begin
  VirtualScreen.Cursor.X := SavedCursor.X;
  VirtualScreen.Cursor.Y := SavedCursor.Y;
end;

function ANSIHandlerObj.ProcessCommand ( Command : Char ) : Boolean;
begin
  ProcessCommand := True;
  case Command of
    'm' : begin
      if not Attribute then
        ProcessCommand := False;
    end;
    'H','f' : begin
      if not PositionCursor(Command) then
        ProcessCommand := False;
    end;
    'J' : begin
      if not ClearCommand then
        ProcessCommand := False;
    end;
    'K' : begin
      if not EraseFromCursorToEndOfLine then
        ProcessCommand := False;
    end;
    'A' : begin
      if not CursorUpCommand then
        ProcessCommand := False;
    end;
    'B' : begin
      if not CursorDownCommand then
        ProcessCommand := False;
    end;
    'C' : begin
      if not CursorRightCommand then
        ProcessCommand := False;
    end;
    'D' : begin
      if not CursorLeftCommand then
        ProcessCommand := False;
    end;
    's' : SaveCursorLocation;
    'u' : RestoreCursorLocation;
  end;
  Escape := False;
  EscapeSequence := False;
end;

function ANSIHandlerObj.WriteCh ( Ch : Char ) : Byte;
begin
  WriteCh := 0; { No errors }
  if LastError = 1 then begin
    WriteCh := 1; { Error #1 }
  end
  else if not VirtualScreen.Initialized then begin
    WriteCh := 2; { Error #2 }
  end
  else case Ch of
    #10 : begin { Line feed }
      if Escape then begin
        if EscapeSequence then begin
          Escape := False;
          EscapeSequence := False;
          VirtualScreen.WriteStr(#27#91 + ReturnParameters);
          Inc(VirtualScreen.Cursor.Y);
          if VirtualScreen.DirectVideo then begin
            while VirtualScreen.Cursor.Y >= ScreenLength do VirtualScreen.ScrollScreenUp;
          end
          else begin
            if VirtualScreen.Cursor.Y >= ScreenLength then begin
              VirtualScreen.EndOfBuffer := True;
              while VirtualScreen.Cursor.Y >= ScreenLength do Dec(VirtualScreen.Cursor.Y);
            end;
          end;
          WriteCh := 3; { Error #3 }
        end
        else begin
          Escape := False;
          VirtualScreen.WriteCh(#27);
          Inc(VirtualScreen.Cursor.Y);
          if VirtualScreen.DirectVideo then begin
            while VirtualScreen.Cursor.Y >= ScreenLength do VirtualScreen.ScrollScreenUp;
          end
          else begin
            if VirtualScreen.Cursor.Y >= ScreenLength then begin
              VirtualScreen.EndOfBuffer := True;
              while VirtualScreen.Cursor.Y >= ScreenLength do Dec(VirtualScreen.Cursor.Y);
            end;
          end;
          WriteCh := 3; { Error #3 }
        end;
      end
      else begin
        Inc(VirtualScreen.Cursor.Y);
        if VirtualScreen.DirectVideo then begin
          while VirtualScreen.Cursor.Y >= ScreenLength do VirtualScreen.ScrollScreenUp;
        end
        else begin
          if VirtualScreen.Cursor.Y >= ScreenLength then begin
            VirtualScreen.EndOfBuffer := True;
            while VirtualScreen.Cursor.Y >= ScreenLength do Dec(VirtualScreen.Cursor.Y);
          end;
        end;
      end;
    end;
    #13 : begin { CR }
      if Escape then begin
        if EscapeSequence then begin
          Escape := False;
          EscapeSequence := False;
          VirtualScreen.WriteStr(#27#91 + ReturnParameters);
          VirtualScreen.Cursor.X := 0;
          WriteCh := 3; { Error #3 }
        end
        else begin
          Escape := False;
          VirtualScreen.WriteCh(#27);
          VirtualScreen.Cursor.X := 0;
          WriteCh := 3; { Error #3 }
        end;
      end
      else VirtualScreen.Cursor.X := 0;
    end;
    #27 : begin { Esc }
      if Escape then begin
        if EscapeSequence then begin
          Escape := True;
          EscapeSequence := False;
          VirtualScreen.WriteStr(#27#91 + ReturnParameters);
          WriteCh := 3; { Error #3 }
        end
        else VirtualScreen.WriteCh(#27);
      end
      else Escape := True;
    end;
    #91 : begin { [ }
      if Escape then begin
        if EscapeSequence then begin
          Escape := False;
          EscapeSequence := False;
          VirtualScreen.WriteStr(#27#91 + ReturnParameters + Ch);
          WriteCh := 3; { Error #3 }
        end
        else begin
          EscapeSequence := True;
          ClearParameterBuffer;
        end;
      end
      else VirtualScreen.WriteCh(Ch);
    end;
    '0'..'9' : begin
      if Escape then begin
        if EscapeSequence then begin
          if ParameterColumn <= 2 then begin
            ParameterBuffer[ParameterRow,ParameterColumn] := Ch;
            Inc (ParameterColumn);
          end
          else begin
            Escape := False;
            EscapeSequence := False;
            VirtualScreen.WriteStr(#27#91 + ReturnParameters + Ch);
            WriteCh := 5; { Error #5 }
          end;
        end
        else begin
          Escape := False;
          VirtualScreen.WriteStr(#27 + Ch);
          WriteCh := 3; { Error #3 }
        end;
      end
      else VirtualScreen.WriteCh(Ch);
    end;
    ';' : begin
      if Escape then begin
        if EscapeSequence then begin
          if LastCharacter in ['0'..'9'] then begin
            Inc(ParameterRow);
            if ParameterRow > ParameterBufferLength - 1 then begin
              ParameterRow := ParameterBufferLength - 1;
              Escape := False;
              EscapeSequence := False;
              VirtualScreen.WriteStr(#27#91 + ReturnParameters + ';');
              WriteCh := 4; { Error #4 }
            end
            else ParameterColumn := 0;
          end
          else begin
            Escape := False;
            EscapeSequence := False;
            VirtualScreen.WriteStr(#27#91 + ReturnParameters + ';');
            WriteCh := 3; { Error #3 }
          end;
        end
        else begin
          Escape := False;
          VirtualScreen.WriteStr(#27 + ';');
          WriteCh := 3; { Error #3 }
        end;
      end
      else VirtualScreen.WriteCh(';');
    end;
    'm','H','f','J','K','A','B','C','D','s','u' : begin
      if Escape then begin
        if EscapeSequence then begin
          if LastCharacter = ';' then begin
            Escape := False;
            EscapeSequence := False;
            VirtualScreen.WriteStr(#27#91 + ReturnParameters + ';' + Ch);
            WriteCh := 3; { Error #3 }
          end
          else begin
            if not ProcessCommand(Ch) then begin
              VirtualScreen.WriteStr(#27#91 + ReturnParameters + Ch);
              WriteCh := 6; { Error #6 }
            end;
          end;
        end
        else begin
          Escape := False;
          VirtualScreen.WriteStr(#27 + Ch);
        end;
      end
      else VirtualScreen.WriteCh(Ch);
    end;
    else begin
      if Escape then begin
        if EscapeSequence then begin
          Escape := False;
          EscapeSequence := False;
          VirtualScreen.WriteStr(#27#91 + ReturnParameters + Ch);
          WriteCh := 3; { Error #3 }
        end
        else begin
          Escape := False;
          VirtualScreen.WriteStr(#27 + Ch);
          WriteCh := 3; { Error #3 }
        end;
      end
      else VirtualScreen.WriteCh(Ch);
    end;
  end;
  LastCharacter := Ch;
end;

procedure ANSIHandlerObj.WriteStr ( Str : string );

var
  I : Byte;

begin
  for I := 1 to Length(Str) do ANSIHandler.WriteCh(Str[I]);
end;

function ANSIHandlerObj.SetClearScreen : string;
{ This function returns the ANSI string for clearing the screen
  (written for saving an image in ANSI characters) }
begin
  SetClearScreen := '[2J';
end;

function ANSIHandlerObj.SetAttribute ( FromAttribute : Integer; ToAttribute : Byte ) : string;
{ This function returns the ANSI string for setting the attribute
  (written for saving an image in ANSI characters) }
const
  Colors : array [0..7] of Char = ('0', '4', '2', '6', '1', '5', '3', '7');

var
  Str : string;
  WasBlink, WasInten : Boolean;
  WasBG, WasFG : Byte;
  NowBlink, NowInten : Boolean;
  NowBG, NowFG : Byte;
  Param : Boolean;

begin
  Param := False;
  Str := '';
  if FromAttribute <> -1 then begin
    if FromAttribute > 127 then WasBlink := True
    else WasBlink := False;
    if FromAttribute mod 16 > 7 then begin
      WasInten := True;
      WasFG := FromAttribute mod 16 - 8;
    end
    else begin
      WasInten := False;
      WasFG := FromAttribute mod 16;
    end;
    WasBG := FromAttribute div 16;
  end
  else begin
    Str := #27#91#48; { '[0' }
    Param := True;
    WasBlink := False;
    WasInten := False;
    WasBG := 0;
    WasFG := 7;
  end;
  if ToAttribute > 127 then NowBlink := True
  else NowBlink := False;
  if ToAttribute mod 16 > 7 then begin
    NowInten := True;
    NowFG := ToAttribute mod 16 - 8;
  end
  else begin
    NowInten := False;
    NowFG := ToAttribute mod 16;
  end;
  NowBG := ToAttribute div 16;
  if ((WasBlink) and (not NowBlink)) or ((WasInten) and (not NowInten)) then begin
    Str := #27#91#48; { '[0' }
    Param := True;
    WasBlink := False;
    WasInten := False;
    WasBG := 0;
    WasFG := 7;
  end;
  if NowBlink then
    if not WasBlink then begin
      if Param then Str := Str + ';5'
      else begin
        Str := #27#91 + '5';
        Param := True;
      end;
    end;
  if NowInten then
    if not WasInten then begin
      if Param then Str := Str + ';1'
      else begin
        Str := #27#91 + '1';
        Param := True;
      end;
    end;
  if NowBG <> WasBG then begin
    if Param then Str := Str + ';4' + Colors[NowBG]
    else begin
      Str := #27#91 + '4' + Colors[NowBG];
      Param := True;
    end;
  end;
  if NowFG <> WasFG then begin
    if Param then Str := Str + ';3' + Colors[NowFG]
    else begin
      Str := #27#91 + '3' + Colors[NowFG];
      Param := True;
    end;
  end;
  if Param then Str := Str + #109; { Str + 'm' }
  SetAttribute := Str;
end;

function NumStr ( N : Byte ) : string;
{ Used for following routines ONLY }
const
  NM : array [0..2] of Byte = (1,10,100);

var
  I, Num, Digits : Byte;
  Str : string;

begin
  Str := '';
  Digits := 0;
  Num := N;
  for I := 2 downto 0 do
    if (Num div NM[I] > 0) or (Digits > 0) then begin
      Str := Str + Chr(Num div NM[I] + 48);
      Num := Num mod NM[I];
      Inc(Digits);
    end;
  NumStr := Str;
end;

function ANSIHandlerObj.SetCursorPosition ( X, Y : Byte ) : string;
{ This function returns the ANSI string for setting the cursor position
  (written for saving an image in ANSI characters) }
var
  Str : string;

begin
  if (X = 0) and (Y = 0) then Str := '[H'
  else Str := '[' + NumStr(Y + 1) + ';' + NumStr(X + 1) + 'H';
  SetCursorPosition := Str;
end;

function ANSIHandlerObj.SetCursorUp ( Num : Byte ) : string;
{ This function returns the ANSI string for moving the cursor up
  (written for saving an image in ANSI characters) }
var
  Ch : string;

begin
  Ch := NumStr(Num);
  if Ch = #48 then Ch := '';
  SetCursorUp := '[' + Ch + 'A';
end;

function ANSIHandlerObj.SetCursorDown ( Num : Byte ) : string;
{ This function returns the ANSI string for moving the cursor down
  (written for saving an image in ANSI characters) }
var
  Ch : string;

begin
  Ch := NumStr(Num);
  if Ch = #48 then Ch := '';
  SetCursorDown := '[' + Ch + 'B';
end;

function ANSIHandlerObj.SetCursorLeft ( Num : Byte ) : string;
{ This function returns the ANSI string for moving the cursor left
  (written for saving an image in ANSI characters) }
var
  Ch : string;

begin
  Ch := NumStr(Num);
  if Ch = #48 then Ch := '';
  SetCursorLeft := '[' + Ch + 'D';
end;

function ANSIHandlerObj.SetCursorRight ( Num : Byte ) : string;
{ This function returns the ANSI string for moving the cursor right
  (written for saving an image in ANSI characters) }
var
  Ch : string;

begin
  Ch := NumStr(Num);
  if Ch = #48 then Ch := '';
  SetCursorRight := '[' + Ch + 'C';
end;

function ANSIHandlerObj.SetSaveCursorPosition : string;
{ This function returns the ANSI string for saving the cursor position
  (written for saving an image in ANSI characters) }
begin
  SetSaveCursorPosition := '[s';
end;

function ANSIHandlerObj.SetRestoreCursorPosition : string;
{ This function returns the ANSI string for restoring the cursor position
  (written for saving an image in ANSI characters) }
begin
  SetRestoreCursorPosition := '[u';
end;

begin
  VirtualScreen.Initialized := False;
  ANSIHandler.LastError := 1;
  ScreenWidth := 0;
  ScreenLength := 0;
  ScreenSize := 0;
end.