(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0305.PAS
  Description: CRT32
  Author: FRANK ZIMMER
  Date: 08-30-97  10:08
*)


Implementation of Turbo Pascal CRT-Unit for Win32
Console Subsystem

_________________ Make file CRT32.inf ________________________________
filename=Crt32
replacements=
fileversion=1.0.0127
filedescription=Implementation of Turbo Pascal CRT-Unit for Win32 Console Subsystem
target=Delphi 2.0
author name=Frank Zimmer
author e-mail=fzimmer@compuserve.com
autor URL=
file status=freeware
full source=
category=Miscellaneous

_________________ Make file CRT32.int ________________________________
{$APPTYPE CONSOLE}
unit crt32;
{# freeware}
{# version 1.0.0127}
{# Date 18.01.1997}
{# Author Frank Zimmer}
{# description
 Copyright ⌐ 1997, Frank Zimmer, 100703.1602@compuserve.com
 Version: 1.0.0119
 Date:    18.01.1997

 an Implementation of Turbo Pascal CRT-Unit for Win32 Console Subsystem
 testet with Windows NT 4.0
 At Startup you get the Focus to the Console!!!!

 implemention now ( *are not in the original Crt-Unit):
 Procedure and Function:
   ClrScr
   ClrEol
   WhereX
   WhereY
   GotoXY
   InsLine
   DelLine
   HighVideo
   LowVideo
   NormVideo
   TextBackground
   TextColor
   Delay             // use no processtime
   KeyPressed
   ReadKey           // use no processtime
   Sound             // with Windows NT your could use the Variables SoundFrequenz, SoundDuration
   NoSound
   *TextAttribut     // Set TextBackground and TextColor at the same time, usefull for Lastmode
   *FlushInputBuffer // Flush the Keyboard and all other Events
   *ConsoleEnd       // output of 'Press any key' and wait for key input when not pipe
   *Pipe             // True when the output is redirected to a pipe or a file

 Variables:
   WindMin           // the min. WindowRect
   WindMax           // the max. WindowRect
   *ViewMax          // the max. ConsoleBuffer start at (1,1);
   TextAttr          // Actual Attributes only by changing with this Routines
   LastMode          // Last Attributes only by changing with this Routines
   *SoundFrequenz    // with Windows NT your could use thise Variables
   *SoundDuration    // how long bells the speaker  -1 until ??, default = -1
   *HConsoleInput    // the Input-handle;
   *HConsoleOutput   // the Output-handle;
   *HConsoleError    // the Error-handle;


 This Source is freeware, have fun :-)

 History
   23.01.97   Sound, delay, Codepage inserted and setfocus to the console
   24.01.97   Redirected status
}

interface
uses windows,messages;
{$ifdef win32}
const
  Black           = 0;
  Blue            = 1;
  Green           = 2;
  Cyan            = 3;
  Red             = 4;
  Magenta         = 5;
  Brown           = 6;
  LightGray       = 7;
  DarkGray        = 8;
  LightBlue       = 9;
  LightGreen      = 10;
  LightCyan       = 11;
  LightRed        = 12;
  LightMagenta    = 13;
  Yellow          = 14;
  White           = 15;

  Function WhereX: integer;
  Function WhereY: integer;
  procedure ClrEol;
  procedure ClrScr;
  procedure InsLine;
  Procedure DelLine;
  Procedure GotoXY(const x,y:integer);
  procedure HighVideo;
  procedure LowVideo;
  procedure NormVideo;
  procedure TextBackground(const Color:word);
  procedure TextColor(const Color:word);
  procedure TextAttribut(const Color,Background:word);
  procedure Delay(const ms:integer);
  function KeyPressed:boolean;
  function ReadKey:Char;
  Procedure Sound;
  Procedure NoSound;
  procedure ConsoleEnd;
  procedure FlushInputBuffer;
  Function Pipe:boolean;

var
  HConsoleInput:thandle;
  HConsoleOutput:thandle;
  HConsoleError:Thandle;
  WindMin:tcoord;
  WindMax:tcoord;
  ViewMax:tcoord;
  TextAttr : Word;
  LastMode : Word;
  SoundFrequenz :Integer;
  SoundDuration : Integer;
{$endif win32}

implementation
_________________ Make file CRT32.pas ________________________________
{$APPTYPE CONSOLE}
unit crt32;
{# freeware}
{# version 1.0.0127}
{# Date 18.01.1997}
{# Author Frank Zimmer}
{# description
 Copyright ⌐ 1997, Frank Zimmer, 100703.1602@compuserve.com
 Version: 1.0.0119
 Date:    18.01.1997

 an Implementation of Turbo Pascal CRT-Unit for Win32 Console Subsystem
 testet with Windows NT 4.0
 At Startup you get the Focus to the Console!!!!

 ( with * are not in the original Crt-Unit):
 Procedure and Function:
   ClrScr
   ClrEol
   WhereX
   WhereY
   GotoXY
   InsLine
   DelLine
   HighVideo
   LowVideo
   NormVideo
   TextBackground
   TextColor
   Delay             // use no processtime
   KeyPressed
   ReadKey           // use no processtime
   Sound             // with Windows NT your could use the Variables SoundFrequenz, SoundDuration
   NoSound
   *TextAttribut     // Set TextBackground and TextColor at the same time, usefull for Lastmode
   *FlushInputBuffer // Flush the Keyboard and all other Events
   *ConsoleEnd       // output of 'Press any key' and wait for key input when not pipe
   *Pipe             // True when the output is redirected to a pipe or a file

 Variables:
   WindMin           // the min. WindowRect
   WindMax           // the max. WindowRect
   *ViewMax          // the max. ConsoleBuffer start at (1,1);
   TextAttr          // Actual Attributes only by changing with this Routines
   LastMode          // Last Attributes only by changing with this Routines
   *SoundFrequenz    // with Windows NT your could use these Variables
   *SoundDuration    // how long bells the speaker  -1 until ??, default = -1
   *HConsoleInput    // the Input-handle;
   *HConsoleOutput   // the Output-handle;
   *HConsoleError    // the Error-handle;


 This Source is freeware, have fun :-)

 History
   18.01.97   the first implementation
   23.01.97   Sound, delay, Codepage inserted and setfocus to the console
   24.01.97   Redirected status
}

interface
uses windows,messages;
{$ifdef win32}
const
  Black           = 0;
  Blue            = 1;
  Green           = 2;
  Cyan            = 3;
  Red             = 4;
  Magenta         = 5;
  Brown           = 6;
  LightGray       = 7;
  DarkGray        = 8;
  LightBlue       = 9;
  LightGreen      = 10;
  LightCyan       = 11;
  LightRed        = 12;
  LightMagenta    = 13;
  Yellow          = 14;
  White           = 15;

  Function WhereX: integer;
  Function WhereY: integer;
  procedure ClrEol;
  procedure ClrScr;
  procedure InsLine;
  Procedure DelLine;
  Procedure GotoXY(const x,y:integer);
  procedure HighVideo;
  procedure LowVideo;
  procedure NormVideo;
  procedure TextBackground(const Color:word);
  procedure TextColor(const Color:word);
  procedure TextAttribut(const Color,Background:word);
  procedure Delay(const ms:integer);
  function KeyPressed:boolean;
  function ReadKey:Char;
  Procedure Sound;
  Procedure NoSound;
  procedure ConsoleEnd;
  procedure FlushInputBuffer;
  Function Pipe:boolean;

var
  HConsoleInput:tHandle;
  HConsoleOutput:thandle;
  HConsoleError:Thandle;
  WindMin:tcoord;
  WindMax:tcoord;
  ViewMax:tcoord;
  TextAttr : Word;
  LastMode : Word;
  SoundFrequenz :Integer;
  SoundDuration : Integer;

{$endif win32}

implementation
{$ifdef win32}
uses sysutils;
var
  StartAttr:word;
  OldCP:integer;
  CrtPipe : Boolean;
  German : boolean;

procedure ClrEol;
var tC :tCoord;
  Len,Nw: integer;
  Cbi : TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(HConsoleOutput,cbi);
  len := cbi.dwsize.x-cbi.dwcursorposition.x;
  tc.x := cbi.dwcursorposition.x;
  tc.y := cbi.dwcursorposition.y;
  FillConsoleOutputAttribute(HConsoleOutput,textattr,len,tc,nw);
  FillConsoleOutputCharacter(HConsoleOutput,#32,len,tc,nw);
end;

procedure ClrScr;
var tc :tcoord;
  nw: integer;
  cbi : TConsoleScreenBufferInfo;
begin
  getConsoleScreenBufferInfo(HConsoleOutput,cbi);
  tc.x := 0;
  tc.y := 0;
  FillConsoleOutputAttribute(HConsoleOutput,textattr,cbi.dwsize.x*cbi.dwsize.y,tc,nw);
  FillConsoleOutputCharacter(HConsoleOutput,#32,cbi.dwsize.x*cbi.dwsize.y,tc,nw);
  setConsoleCursorPosition(hconsoleoutput,tc);
end;

Function WhereX: integer;
var cbi : TConsoleScreenBufferInfo;
begin
  getConsoleScreenBufferInfo(HConsoleOutput,cbi);
  result := tcoord(cbi.dwCursorPosition).x+1
end;

Function WhereY: integer;
var cbi : TConsoleScreenBufferInfo;
begin
  getConsoleScreenBufferInfo(HConsoleOutput,cbi);
  result := tcoord(cbi.dwCursorPosition).y+1
end;

Procedure GotoXY(const x,y:integer);
var coord :tcoord;
begin
  coord.x := x-1;
  coord.y := y-1;
  setConsoleCursorPosition(hconsoleoutput,coord);
end;

procedure InsLine;
var
 cbi : TConsoleScreenBufferInfo;
 ssr:tsmallrect;
 coord :tcoord;
 ci :tcharinfo;
 nw:integer;
begin
  getConsoleScreenBufferInfo(HConsoleOutput,cbi);
  coord := cbi.dwCursorPosition;
  ssr.left := 0;
  ssr.top := coord.y;
  ssr.right := cbi.srwindow.right;
  ssr.bottom := cbi.srwindow.bottom;
  ci.asciichar := #32;
  ci.attributes := cbi.wattributes;
  coord.x := 0;
  coord.y := coord.y+1;
  ScrollConsoleScreenBuffer(HconsoleOutput,ssr,nil,coord,ci);
  coord.y := coord.y-1;
  FillConsoleOutputAttribute(HConsoleOutput,textattr,cbi.dwsize.x*cbi.dwsize.y,coord,nw);
end;

procedure DelLine;
var
 cbi : TConsoleScreenBufferInfo;
 ssr:tsmallrect;
 coord :tcoord;
 ci :tcharinfo;
 nw:integer;
begin
  getConsoleScreenBufferInfo(HConsoleOutput,cbi);
  coord := cbi.dwCursorPosition;
  ssr.left := 0;
  ssr.top := coord.y+1;
  ssr.right := cbi.srwindow.right;
  ssr.bottom := cbi.srwindow.bottom;
  ci.asciichar := #32;
  ci.attributes := cbi.wattributes;
  coord.x := 0;
  coord.y := coord.y;
  ScrollConsoleScreenBuffer(HconsoleOutput,ssr,nil,coord,ci);
  FillConsoleOutputAttribute(HConsoleOutput,textattr,cbi.dwsize.x*cbi.dwsize.y,coord,nw);
end;

procedure TextBackground(const Color:word);
begin
  LastMode := TextAttr;
  textattr := (color shl 4) or (textattr and $f);
  SetConsoleTextAttribute(hconsoleoutput,textattr);
end;

procedure TextColor(const Color:word);
begin
  LastMode := TextAttr;
  textattr := (color and $f) or (textattr and $f0);
  SetConsoleTextAttribute(hconsoleoutput,textattr);
end;

procedure TextAttribut(const Color,Background:word);
begin
  LastMode := TextAttr;
  textattr := (color and $f) or (Background shl 4);
  SetConsoleTextAttribute(hconsoleoutput,textattr);
end;

procedure HighVideo;
begin
  LastMode := TextAttr;
  textattr := textattr or $8;
  SetConsoleTextAttribute(hconsoleoutput,textattr);
end;

procedure LowVideo;
begin
  LastMode := TextAttr;
  textattr := textattr and $f7;
  SetConsoleTextAttribute(hconsoleoutput,textattr);
end;

procedure NormVideo;
begin
  LastMode := TextAttr;
  textattr := startAttr;
  SetConsoleTextAttribute(hconsoleoutput,textattr);
end;

procedure FlushInputBuffer;
begin
  FlushConsoleInputBuffer(hconsoleinput)
end;

function keypressed:boolean;
var NumberOfEvents:integer;
begin
  GetNumberOfConsoleInputEvents(hconsoleinput,NumberOfEvents);
  result := NumberOfEvents > 0;
end;

function ReadKey: Char;
var
  NumRead:       Integer;
  InputRec:      TInputRecord;
begin
  while not ReadConsoleInput(HConsoleInput,
                             InputRec,
                             1,
                             NumRead) or
           (InputRec.EventType <> KEY_EVENT) do;
  Result := InputRec.KeyEvent.AsciiChar
end;

procedure delay(const ms:integer);
begin
  sleep(ms);
end;

Procedure Sound;
begin
  windows.beep(SoundFrequenz,soundduration);
end;

Procedure NoSound;
begin
  windows.beep(soundfrequenz,0);
end;

procedure ConsoleEnd;
begin
  if isconsole and not crtpipe then
  begin
    if wherex > 1 then writeln;
    textcolor(green);
    setfocus(GetCurrentProcess);
    if german then write('Bitte eine Taste drⁿcken!')
              else write('Press any key!');
    normvideo;
    FlushInputBuffer;
    ReadKey;
    FlushInputBuffer;
  end;
end;

function Pipe:boolean;
begin
  result := crtpipe;
end;

procedure init;
var
  cbi : TConsoleScreenBufferInfo;
  tc : tcoord;
begin
 SetActiveWindow(0);
 HConsoleInput := GetStdHandle(STD_InPUT_HANDLE);
 HConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);
 HConsoleError := GetStdHandle(STD_Error_HANDLE);
 if getConsoleScreenBufferInfo(HConsoleOutput,cbi) then
 begin
   TextAttr := cbi.wAttributes;
   StartAttr := cbi.wAttributes;
   lastmode  := cbi.wAttributes;
   tc.x := cbi.srwindow.left+1;
   tc.y := cbi.srwindow.top+1;
   windmin := tc;
   ViewMax := cbi.dwsize;
   tc.x := cbi.srwindow.right+1;
   tc.y := cbi.srwindow.bottom+1;
   windmax := tc;
   crtpipe := false;
 end else crtpipe := true;
 SoundFrequenz := 1000;
 SoundDuration := -1;
 oldCp := GetConsoleoutputCP;
 SetConsoleoutputCP(1252);
 german := $07 = (LoWord(GetUserDefaultLangID) and $3ff);
end;

initialization
  init;
finalization
 SetConsoleoutputCP(oldcp);
{$endif win32}
end.

