unit screenio;

interface

uses crt,dos;

const
  SHFTR   = 1;
  SHFTL   = 2;
  CTRL    = 4;
  ALT     = 8;
  SCRL    = 16;
  NUML    = 32;
  CAPL    = 64;
  INS     = 128;
  _BKSPC  = 8;
  _ESC    = 27;
  _UP     = 328;
  _DN     = 336;
  _RIGHT  = 333;
  _LEFT   = 331;
  _PGUP   = 329;
  _PGDN   = 337;
  _HOME   = 327;
  _END    = 335;
  _DEL    = 339;
  _INS    = 338;
  _F1     = 315;
  _F2     = 316;
  _F3     = 317;
  _F4     = 318;
  _F5     = 319;
  _F6     = 320;
  _F7     = 321;
  _F8     = 322;
  _F9     = 323;
  _F10    = 324;
  single  = '┌─┐│└┘';
  double  = '╔═╗║╚╝';
  bellsnd = 50;

type
  ScreenType = array[1..25,1..80] of word;
  str2  = string[2];
  str10 = string[10];
  str20 = string[20];
  str80 = string[80];

procedure InitScrn;
function  CenterNum(Num : longint;Len : byte) : string;
function  FileOpen(var Fn      : text;
                      FileName: String): Boolean;
function  FileVOpen(var Fn      : file;
                      FileName: String): Boolean;
function  Get_Key : Integer;
function  GetKeyScan(SCANBYTE : BYTE) : Boolean;
PROCEDURE GetText(Left,Top,Right,Bottom:INTEGER;VAR dest);
PROCEDURE PutText(Left,Top,Right,Bottom:INTEGER;VAR Source);
procedure GetChar(X,Y           : integer;           { Display Coord }
                  var Character : char;              { the character }
                  var COLOR     : integer);          { its Attribute }
procedure Scroll(  Direction : Char;   { Direction U=Up D=Down }
                   Number,             { Number of lines to be scrolled }
                   COLOR,              { Attribute for the blank lines created }
                   XLeft,              { Column in the upper left corner }
                   YLeft,              { line in the upper left corner }
                   XRight,             { Column in the lower right corner }
                   YRight     : integer);  { Line in lower right corner }
procedure WriteXY(X,Y : Byte;Str : String);
procedure DrawBox(Title,BoxDef : string;TopX,TopY,BotX,BotY,Shadow,Border,WindC : byte);
function  Parse(ParseChr : char;VAR Str : string) : string;
function  SelMenu(Xpos,Ypos,NormColor,HighColor,BordColor,Box : Byte;
                 MenuName,MenuS : string) : Char;
function  Trim_Str(InputStr : string) : string;
procedure soundbell;
procedure InValidInput(Prompt : string);
procedure ClearInvalid;

var
  ErrPrompt : Boolean;

implementation

var
  Screen : ^ScreenType;
  vinput : array[1..240] of word;

procedure soundbell;
  begin
    sound(500);
    delay(bellsnd);
    nosound;
  end;

procedure InValidInput(Prompt : string);
  var
    xpos,oldx,oldy,attr : byte;
  begin
    GetText(1,1,80,3,vinput);
    attr := textattr;
    oldx := wherex;
    oldy := wherey;
    textattr := $5f;
    xpos := 80-3-length(prompt);
    DrawBox('',Single,xpos,1,80,3,$00,$5f,$5f);
    gotoxy(xpos+2,2);
    write(prompt);
    textattr := attr;
    gotoxy(oldx,oldy);
    ErrPrompt := True;
  end;

procedure ClearInvalid;
  begin
    ErrPrompt := False;
    PutText(1,1,80,3,vinput);
  end;

procedure InitScrn;
  begin
    IF LastMode = Mono THEN Screen := Ptr($b000,0)
      ELSE Screen:=Ptr($b800,0);
  end;

function Trim_Str(InputStr : string) : string;
  var
    count  : byte;
  begin
    count := 1;
    while InputStr[count] = ' ' do
      begin
        Delete(InputStr,1,1);
        inc(count);
      end;
    count := Length(InputStr);
    while InputStr[count] = ' ' do
      begin
        Delete(InputStr,Length(InputStr),1);
        dec(count);
      end;
    Trim_Str := InputStr;
  end;

function CenterNum(Num : longint;Len : byte) : string;
  var
    Tstr : string;
    SLen,TVal : byte;
  begin
    Str(Num,Tstr);
    SLen := Length(Tstr);
    if SLen < Len then
      repeat
        Insert(' ',Tstr,Slen+1);
        inc(Slen);
        if SLen < Len then Insert(' ',Tstr,1);
        inc(Slen);
      until Slen >= Len else if Slen > Len then Delete(Tstr,Len+1,Slen-Len);
    Centernum := Tstr;
  end;

function FileVOpen(var Fn      : file;
                      FileName: String): Boolean;
{ Boolean function that returns True if the file exists;otherwise,
 it returns False. Closes the file if it exists. }
begin
 {$I-}
 Assign(Fn, FileName);

 FileMode := 2;  { Set file access to read/write }
 Reset(Fn);
 {$I+}
 FileVOpen := (IOResult = 0) and (FileName <> '');
end;  { FileExists }

function FileOpen(var Fn      : text;
                      FileName: String): Boolean;
{ Boolean function that returns True if the file exists;otherwise,
 it returns False. Closes the file if it exists. }
begin
 {$I-}
 Assign(Fn, FileName);

 FileMode := 2;  { Set file access to read/write }
 Reset(Fn);
 {$I+}
 FileOpen := (IOResult = 0) and (FileName <> '');
end;  { FileExists }

function Get_Key : Integer;
  Var CH : Char;
      Int : Integer;
  begin
    CH := ReadKey;
    If CH = #0 then
      begin
        CH := ReadKey;
        int := Ord(CH);
        inc(int,256);
      end else Int := Ord(CH);
    Get_Key := Int;
  end;

function GetKeyScan(SCANBYTE : BYTE) : Boolean;
  var
    Regs : Registers;
  begin
    Regs.ah := $2;
    intr($16,Regs);
    if (Regs.al and SCANBYTE <> 0) then GetKeyScan := true
      else GetKeyScan := False;
  end;

PROCEDURE GetText(Left,Top,Right,Bottom:INTEGER;VAR dest);
  TYPE
    DestType = ARRAY[1..2000] OF WORD;
  VAR
    d      : 1..2000;
    x      : 1..80;
    y      : 1..25;
  BEGIN
    d := 1;
    FOR y:=Top TO Bottom DO
      FOR x:= Left TO Right DO
        BEGIN
          DestType(Dest)[d] := Screen^[y,x];
          inc(d);
        END
  END;

PROCEDURE PutText(Left,Top,Right,Bottom:INTEGER;VAR Source);
  TYPE
    SourceType = ARRAY[1..2000] OF WORD;
  VAR
    x      : 1..80;
    y      : 1..25;
    s      : 1..2000;
  BEGIN
    s := 1;
    FOR y := Top TO Bottom DO
      FOR x := Left TO Right DO
        BEGIN
          Screen^[y,x] := SourceType(Source)[s];
          inc(s);
        END
  END;

procedure GetChar(X,Y           : integer;           { Display Coord }
                  var Character : char;              { the character }
                  var COLOR     : integer);          { its Attribute }
  var
    Regs : Registers;           { Register-Variable for the Interrupt }

begin
  gotoxy(X,Y);                  { cursor on the position indicated }
  Regs.ah := 8;                 { Get Function number for char. and Attribute }
  Regs.bh := 0;                 { display page }
  Intr($10,Regs);               { Invoke DOS registers }
  Character := chr(Regs.al);    { ASCII-Code of character }
  COLOR := Regs.ah;             { Attribute of the character }
end;

procedure Scroll(  Direction : Char;   { Direction U=Up D=Down }
                   Number,             { Number of lines to be scrolled }
                   COLOR,              { Attribute for the blank lines created }
                   XLeft,              { Column in the upper left corner }
                   YLeft,              { line in the upper left corner }
                   XRight,             { Column in the lower right corner }
                   YRight     : integer);  { Line in lower right corner }

var Regs : Registers;       { Register variable for calling Interrupt }

begin
  if Direction = 'U' then
    Regs.ah := 6                        { Scroll Up }
  else Regs.ah := 7;                    { Scroll Down }
  Regs.al := Number;
  Regs.bh := COLOR;                     { Color of empty line(s) }
  Regs.ch := YLeft-1;                   { Upper left }
  Regs.cl := XLeft-1;                   { coordinates }
  Regs.dh := YRight-1;                  { Lower right }
  Regs.dl := XRight-1;                  { coordinates }
  Intr($10,Regs);                       { Call BIOS-Video-Interrupt }
end;

procedure WriteXY(X,Y : Byte;Str : String);
  begin
    GotoXY(X,Y);
    Write(Str);
  end;

procedure DrawBox(Title,BoxDef : string;TopX,TopY,BotX,BotY,Shadow,Border,WindC : byte);
  var
    count,space,
    TX,TY,BX,BY,OldC : byte;
  begin
    OldC := Textattr;
    TX := Lo(WindMin);
    TY := Hi(WindMin);
    BX := Lo(WindMax);
    BY := Hi(WindMax);
    if Shadow > 0 then
      begin
        TextAttr := Shadow;
        Window(TopX+2,TopY+1,BotX+2,BotY+1);
        clrscr;
      end;
    TextAttr := WindC;
    Window(TopX,TopY,BotX,BotY);
    if windC <> $00 then clrscr;
    Window(TX+1,TY+1,BX+1,BY+1);
    TextAttr := Border;

    WriteXY(TopX,TopY,BoxDef[1]);
    for count := 1 to BotX-TopX-1 do
      write(BoxDef[2]);
    write(BoxDef[3]);

    For count := TopY+1 to BotY-1 do
      begin
        WriteXY(TopX,Count,BoxDef[4]);
        WriteXY(BotX,Count,BoxDef[4]);
      end;

    WriteXY(TopX,BotY,BoxDef[5]);
    for count := 1 to BotX-TopX-1 do
      write(BoxDef[2]);
    write(BoxDef[6]);

    If Length(Title)+2 < (BotX-TopX-2) then
      begin
        GotoXY(TopX+ (Round((BotX-TopX)/2) - Round((Length(Title)/2)+1)) ,TopY);
        if Title <> '' then write(' ',Title,' ');
      end;

    TextAttr := OldC;
  end;

function Parse(ParseChr : char;VAR Str : string) : string;
  var
    count : byte;
  begin
    count := Pos(ParseChr,Str);
    if count > 0 then
      begin
        Parse := Copy(Str,1,count-1);
        Str   := Copy(Str,count+1,Length(Str)-count);
      end else Parse := '';
  end;

function SelMenu(Xpos,Ypos,NormColor,HighColor,BordColor,Box : Byte;
                 MenuName,MenuS : string) : Char;
  type
    MenuRec = record
      mstr  : string[12];
      xpos : byte;
    end;
  var
    Selection : integer;
    x,lastm,lastx,
    y,Xlen    : byte;
    MenuArr   : array[1..20] of MenuRec;
    CH        : Char;
  begin
    lastm := 0;
    lastX := xpos;
    Repeat
      inc(LastM);
      MenuArr[LastM].mstr := ' '+Parse('|',MenuS)+' ';
      MenuArr[LastM].xpos := LastX;
      LastX := Length(MenuArr[LastM].mstr)+LastX;
    until MenuS = '';
    x := Length(MenuArr[LastM].mstr)+MenuArr[LastM].xpos;
    if Box = 1 then DrawBox(MenuName,single,Xpos-1,Ypos-1,x,Ypos+1,0,BordColor,NormColor);
    Gotoxy(Xpos,Ypos);
    for x := 1 to lastM do
      Write(MenuArr[x].mstr);
    x := 1;
    repeat
      case selection of
        333 : inc(x);
        331 : dec(x);
      end;
      if x = lastm+1 then x := 1;
      if x = 0 then x := lastm;
      textattr := HighColor;
      WriteXY(MenuArr[x].xpos,Ypos,MenuArr[x].mstr);
      gotoxy(menuArr[x].xpos+1,Ypos);
      selection := Get_Key;
      gotoxy(menuArr[x].xpos+1,Ypos);
      textattr := NormColor;
      WriteXY(MenuArr[x].xpos,Ypos,MenuArr[x].mstr);
    until (selection > 333) or (selection < 331);
    if selection = 13 then
      begin
        y := 2;
        while y < Length(MenuArr[x].mstr)-1 do
          begin
            Ch := MenuArr[x].mstr[y];
            If (CH >= 'A') and (CH <= 'Z') then SelMenu := CH;
            inc(y);
          end;
      end else SelMenu := Chr(Selection);
  end;

var
  keyval : integer;

begin
  ErrPrompt := False;
  InitScrn;
end.