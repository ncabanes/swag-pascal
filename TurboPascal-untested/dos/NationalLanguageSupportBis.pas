(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0038.PAS
  Description: National Language Support
  Author: HELGE OLAV HELGESEN
  Date: 11-21-93  09:44
*)


{
  Borland Pascal 7.0 National Language Support, with support for protected
  mode. Written in october 1993 by Helge Olav Helgesen

  The purpose of this unit is to give you the ability to write country-
  dependant programs. I won't explain much how it works; since you have the
  source, feel free to explore/change the source.

  To do so I have a written a colletion of procedures, which are described
  here:

  procedure CreateTable(cc: Word);
    This one creates a new table with the specified country-code. if you
    specify a value of 0, the default country will be loaded. You should
    check for errors thru GetError and PeekError.
  procedure DumpTable  (const name: string);
    This one was written for debugging only, and shoudn't be used. It saves
    the current translation table to the specific file
  procedure Upper(var s: OpenString);
  procedure Lower(var s: OpenString);
    These two translates a string into upper or lower case only.
  function GetError:  word;
  function PeekError: word;
    These two can be used to get (and clear) the result from last
    CreateTable. GetError clears ErrorCode afterwards, while PeekError
    doesn't.
  function Convert2Time(const dt: DateTime): string8;
    This one will create a formatted string containing the time specified
    in DateTime.Hour, DateTime.Min and DateTime.Sec. The string is formatted
    according to the loaded country.
  function Convert2Date(const dt: DateTime): string8;
    This one does the same as the one above, except that a date is returned
    instead.
  function ConvertR2Currency(no: real): string;
    This one will turn a real value into a formatted string, with the county's
    currency symbol placed right.
    The line 'WriteLn(ConvertR2Currency(1234.123));' will result
    In USA:    $1,234.12
    In Norway: Kr 1.234,12
  function UpChar(Ch: Char): Char;
  function LoChar(Ch: Char): Char;
    These two are written with inline statements, and will thus place the
    expanded code into your program's code segment. Since they became
    fairly large, you shoudn't use them too much.
  procedure DumpAllCountries;
    This one is only compiled in real mode, and is only intended to use with
    debugging. It writes all countries that is available to the screen.
  var Table: TTranslationTable;
    This is *the* 256 byte translation table, which contains the mapping to
    upper and lower chars.
  var ErrorCode: word;
    Result from last CreateTable. This is the Dos error code, as described
    in 'Run-time error messages'.
  var CurrTable: word;
    If last CreateTable successed, this contains the country that is loaded.
  var UnitOK: boolean;
    Is TRUE if
      1) Dos 3+ is loaded
      2) Could allocate real-mode memory (DPMI only)
  var CountryInfo: PCountryInfo;
    This is a pointer to the current countrys info table. This pointer should
    never derefenced unless UnitOK is true. It contains only valid data if
  (CurrTable>0) and UnitOK!

  I haven't done much to optimize the code. So even small changes may
  increase the speed. If you have any comments, suggestion etc. feel free
  to leave me a note.

  You can reach me thru the following nets:
    ILink     - thru Qmail, Programming, ASM and Pascal
    PolarNet  - thru Pascal and Post
    Rime      - thru Common, Pascal and ASM. I'm located at site MIDNIGHT
    ScanNet   - virtually any conference
    SourceNet - thru the Pascal conference
    WEB       - thru the Pascal conference

  You may also reach me at the following bulletin boards:
    Group One BBS       - +1 312 752-1258
    Midnight Sun BBS    - +47 755 84 545
    Programmer's BBS    - +47 22 71 41 07

  In all cases, my name is HELGE HELGESEN. My mail address is:
  Helge Olav Helgesen
  Box 726
  8001 BODOE
  Norway

  Tlf. +47 755 23 694
}
{$S-,B- Do not change these! A change will cause faults! }
{$G+,D+,R-,Q-,L+,O+}
{$IFDEF Windows}Sorry, Windows is not supported...{$ENDIF}

unit NLS;

interface

uses {$IFDEF DPMI}WinAPI,{$ENDIF}Dos;

type
  TTranslationTable = array[0..1, 0..127] of char;
  AChar = record { ASCIIZ char from Country Info }
    Letter: char;
    Dummy: byte;
  end; { AChar }
  PCountryInfo = ^TCountryInfo;
  TCountryInfo = record
    DTFormat: word;                { Date/Time format     }
    CurrSym:  array[0..4] of char; { currency symbol      }
    ThouSep,                       { thousand separator   }
    DeciSep,                       { decimal separator    }
    DateSep,                       { date separator       }
    TimeSep:  AChar;               { time separator       }
    CurrFmt:  byte;                { currency format      }
    Digits:   byte;                { digits after decimal }
    TimeFmt:  boolean;             { FALSE=12h else 24h   }
    CaseMap:  pointer;             { real mode case map   }
    DataSep:  AChar;               { data list separator  }
    RFU:      array[0..9] of byte; { not used             }
  end; { TCountryInfo }
  String8 = string[12];

var
  Table: TTranslationTable;  { the translation table                   }
  ErrorCode: word;           { error code from last create table       }
  CurrTable: word;           { current country loaded, or 0 if none    }
  UnitOK: boolean;           { true if extentions are allowed          }
  CountryInfo: PCountryInfo; { NB! Protected Mode selector under DPMI! }

procedure CreateTable(cp: word);
  { -creates new table }
procedure DumpTable  (const name: string);
  { -saves table to disk, mainly written for debugging purposes }
procedure Upper      (var s: OpenString);
  { -translate string to upper case (A NAME) }
procedure Lower      (var s: OpenString);
  { -translate string to lower case (a name) }
function  GetError:  word;
  { -get and clear error }
function  PeekError: word;
  { -get error }
function  Convert2Time(const dt: DateTime): string8;
  { -converts time part of DateTime rec info country dep. string }
function  Convert2Date(const dt: DateTime): string8;
  { -converts date part into XX:YY:ZZ country dep. }
function  ConvertR2Currency(no: real): string;
  { -converts real value to currency }
function  UpChar(Ch: Char): Char;
  { -converts char to upper case }
inline($58/        { pop ax }
       $88/$c4/    { mov ah, al }
       $a8/$80/    { test al, 80h }
       $74/$10/    { je @1 }
       $8b/$d8/    { mov bx, ax }
       $32/$ff/    { xor bh, bh }
       $8a/$a7/    { mov ah, [bx+ }
       >Table-$80/ { Table-80h] }
       $84/$e4/    { test ah, ah }
       $74/$0d/    { le @2 }
       $88/$e0/    { mov al, ah }
       $eb/$09/    { jmp @2 }
{@1:}  $f6/$d4/    { not ah }
       $f6/$c4/$60/{ test ah, 60h }
       $75/$02/    { jne @2 }
       $34/$20     { xor al, 20h }
{@2:} );
function  LoChar(Ch: Char): Char;
  { -translates Ch to lower char }
inline($58/        { pop ax }
       $a8/$80/    { test al, 80h }
       $74/$10/    { le @1 }
       $8b/$d8/    { mov bx, ax }
       $32/$ff/    { xor bh, bh }
       $8a/$a7/    { mov ah, [bx+ }
       >Table/     { TABLE] }
       $0a/$e4/    { or ah, ah }
       $74/$0c/    { je @2 }
       $88/$e0/    { mov al, ah }
       $eb/$08/    { jmp @2 }
{@1:}  $88/$c4/    { mov ah, al }
       $a8/$c0/    { test al, 0c0h }
       $74/$08/    { je @2 }
       $34/$20     { xor al, 20h }
{@2:} );

{$IFDEF MSDOS}
procedure DumpAllCountries;
  { -dumps all country codes supported. For debugging. Works only in real mode }
{$ENDIF}

implementation

{$IFDEF DPMI}
type
  TBit32 = record
    Low, High: word;
  end; { Bit32 }
  TCallRealMode = record { DPMI structure used to call real mode procs }
    EDI,   ESI, EBP, RFU1, EBX,
    EDX,   ECX, EAX: TBit32;
    Flags, rES, rDS, rFS,
    rGS,   rIP, rCS, rSP,
    rSS:   word;
  end; { TCallRealMode }

var
  ciSelector: TBit32;  { selector and segment to CountryInfo     }
  MyExitProc: pointer; { DPMI exit proc to deallocate Dos memory }
{$ENDIF}

type
  string2 = string[2];
  Pstring = ^String;

function Convert2Digit(no: word): string2;
var
  s: string8;
begin
  Str(no:2, s);
  if s[0]>#2 then delete(s, 1, byte(s[0])-2);
  if s[1]=#32 then s[1]:='0';
  Convert2Digit:=s;
end; { Convert2Digit }

{$IFDEF MSDOS}
procedure DumpAllCountries;
  function TestCountry(no: word): boolean; assembler;
  var dummy: TCountryInfo;
  asm
    push ds
    mov  ax, ss
    mov  ds, ax
    lea  dx, dummy
    mov  ax, $38ff
    mov  bx, no
    or   bh, bh
    je   @1
    mov  al, bl
@1: int  $21
    pop  ds
    jc   @x
    xor  ax, ax
@x:
  end; { DumpAllcountries.TestCountry }
var
  x: word;
begin
  for x:=0 to 900 do if not TestCountry(x) then write(x:10);
end; { DumpAllCountries }
{$ENDIF}

function Convert2Time;
const
  AM: string2 = 'AM';
  PM: string2 = 'PM';
  function To12(no: word): word;
  begin
    if no>12 then To12:=no-12 else To12:=no;
  end; { Convert2Time.To12 }
  function AmPm(no: word): Pstring;
  begin
    if no>12 then AmPm:=@PM else AmPm:=@AM;
  end; { Convert2Time.AmPm }
var
  Delemiter: char;
begin { Convert2Time }
  if UnitOK and (ErrorCode=0) then
    Delemiter:=CountryInfo^.TimeSep.Letter
  else
    Delemiter:=':';
  if UnitOK and (CurrTable>0) and CountryInfo^.TimeFmt then
    Convert2Time:=Convert2Digit(dt.Hour)+Delemiter+ { time }
                  Convert2Digit(dt.Min)+Delemiter+  { min  }
                  Convert2Digit(dt.Sec)
  else
    Convert2Time:=Convert2Digit(To12(dt.Hour))+Delemiter+ { time }
                  Convert2Digit(dt.Min)+Delemiter+        { min  }
                  Convert2Digit(dt.Sec)+#32+AMPM(dt.Hour)^{ sec  }
end; { Convert2Time }

function Convert2Date;
var
  Dele: char;
begin
  if UnitOK and (CurrTable>0) then
    Dele:=CountryInfo^.DateSep.Letter
  else
    Dele:='/';
  if UnitOK and (CurrTable>0) and (CountryInfo^.DTFormat>0) then
  case CountryInfo^.DTFormat of
    1: Convert2Date:=Convert2Digit(dt.Day)+Dele+   { date  }
                     Convert2Digit(dt.Month)+Dele+ { month }
                     Convert2Digit(dt.Year);       { year  }
    2: Convert2Date:=Convert2Digit(dt.Year)+Dele+  { year  }
                     Convert2Digit(dt.Month)+Dele+ { month }
                     Convert2Digit(dt.Day);
  end { case }
  else { if }
    Convert2Date:=   Convert2Digit(dt.Month)+Dele+ { month }
                     Convert2Digit(dt.Day)+Dele+   { day   }
                     Convert2Digit(dt.Year);       { year  }
end; { Convert2Time }

function ConvertR2Currency;
  function GetCurrency: string8;
  var
    s: string8;
  begin
    s:=CountryInfo^.CurrSym;
    while s[byte(s[0])]=#0 do dec(s[0]);
    GetCurrency:=s;
  end; { ConvertR2Currency.GetCurrency }
  function FormatString(s: string): string;
  var
    Comma, Digits: byte;
    c: integer;
    Dele: char;
  begin
    Dele:=CountryInfo^.ThouSep.Letter;     { get thousand delemiter          }
    Digits:=Pos('.', s);                   { digits before delemither        }
    Comma:=Digits;                         { save comma position             }
    if Digits=0 then Digits:=Length(s)+1;  { start rightmost if no comma     }
    c:=Digits-3;                           { init counter                    }
    while c>2 do
    begin
      Insert(Dele, s, c);                  { insert thousand delemither      }
      Dec(c, 3);                           { adjust pointer                  }
      if Comma>0 then Inc(Comma);          { increase comma position(if any) }
    end; { while }
    if Comma>0 then                        { adjust comma, if any            }
      s[Comma]:=CountryInfo^.DeciSep.Letter;
    FormatString:=s;
  end; { ConvertR2Currency.FormatString }
  function PlaceCurrency(s: string): string;
  var
    x: byte;
  begin
    x:=Pos(CountryInfo^.DeciSep.Letter, s);
    Delete(s, x, 1);
    Insert(GetCurrency, s, x);
    PlaceCurrency:=s;
  end; { ConvertR2Currency.PlaceCurrency }
var
  s: string[20];
begin { ConvertR2Currency }
  if UnitOK and (CurrTable>0) then
  begin
    Str(no:20:CountryInfo^.Digits, s);
    while s[1]=#32 do delete(s, 1, 1);
    s:=FormatString(s);
  end
  else
  begin
    Str(no:20:2, s);
    while s[1]=#32 do delete(s, 1, 1);
  end; { if/else }
  if UnitOK and (CurrTable>0) then
  case CountryInfo^.CurrFmt of
    0: s:=GetCurrency+s;
    1: s:=s+GetCurrency;
    2: s:=GetCurrency+#32+s;
    3: s:=s+#32+GetCurrency;
    4: s:=PlaceCurrency(s);
  end; { case }
  ConvertR2Currency:=s;
end; { ConvertR2Currency }

procedure DumpTable;
var
  f: file of TTranslationTable;
begin
  assign(f, name);
  rewrite(f);
  write(f, Table);
  close(f);
end;

procedure CreateTable;
var
  b: byte;
  c, d: char;
  procedure GetCountryInfo(cp: word);
  var
    r: Registers;
  begin
    r.AX:=$38FF;
    if cp>255 then r.BX:=cp else r.AL:=Lo(cp);
    r.DS:=Seg(CountryInfo^);
    r.DX:=Ofs(CountryInfo^);
    MsDos(r);
    if r.Flags and 1=1 then ErrorCode:=r.AX;
    if ErrorCode=0 then CurrTable:=r.BX else CurrTable:=0;
  end; { CreateTable.GetCoutryInfo }
  function CallCaseMap(Letter: char): char; assembler;
{$IFNDEF MSDOS}
  var
    regs: TCallRealMode;
{$ENDIF}
  asm
    mov  al, Letter
  {$IFNDEF MSDOS}
    mov  word ptr regs.EAX, ax
    mov  regs.rSP, 0
    mov  regs.rSS, 0
    les  di, CountryInfo
    mov  ax, word ptr es:[di].TCountryInfo.CaseMap
    mov  regs.RIP, ax
    mov  ax, word ptr es:[di].TCountryInfo.CaseMap+2
    mov  regs.RCS, ax
    mov  ax, ss
    mov  es, ax
    lea  di, regs
    xor  cx, cx
    mov  ax, $301
    int  $31 { execute real mode proc }
    mov  ax, word ptr regs.EAX
  {$ELSE}
    les  di, CountryInfo
    call es:[di].TCountryInfo.CaseMap
  {$ENDIF}
  end; { CreateTable.CallCaseMap }
  procedure MapIn(NewChar, OldChar: char);
  begin
    Table[0, byte(OldChar) and $7f]:=NewChar;
    Table[1, byte(NewChar) and $7f]:=OldChar;
  end; { CreateTable.MapIn }
begin { CreateTable }
  if (ErrorCode>0) or not UnitOK then exit; { leave if any pending error }
  FillChar(Table, sizeof(Table), 0);
  GetCountryInfo(cp);
  if ErrorCode>0 then exit; { leave if any error occured }
  for b:=0 to 127 do
  begin
    c:=CallCaseMap(char(b+128));
    if c<>char(b+128) then MapIn(c, char(b+128));
  end; { for }
end; { CreateTable }

procedure UpCase; assembler;
{
  This translates the incoming char in AL into upper case if it is defined
  in the translation table.
  Please note that if you enable stack checking, this proc won't work...
}
asm
  test al, $80
  je   @1
  xor  ah, ah
  mov  bx, ax
  mov  ah, byte[Table+bx-$80]
  test ah, ah
  je   @x
  mov  al, ah
  jmp  @x
@1:
  cmp  al, 'z'
  jg   @x
  cmp  al, 'a'
  jl   @x
  xor  al, $20
@x:
end; { UpChar }

procedure LowChar; assembler;
asm
  test al, $80
  je   @1
  mov  bx, ax
  xor  bh, bh
  mov  ah, byte[Table+bx]
  or   ah, ah
  je   @x
  mov  al, ah
  jmp  @x
@1:
  cmp  al, 'Z'
  jg   @x
  cmp  al, 'A'
  jl   @x
  xor  al, $20
@x:
end; { LowChar }

procedure Upper; assembler;
asm
  les  di, s
  mov  cl, es:[di]
  xor  ch, ch
  jcxz @x
  inc  di
@1:
  mov  al, es:[di]
  call UpCase
  mov  es:[di], al
  inc  di
  loop @1
@x:
end; { Upper }

procedure Lower; assembler;
asm
  les  di, s
  mov  cl, es:[di]
  xor  ch, ch
  jcxz @x
  inc  di
@1:
  mov  al, es:[di]
  call LowChar
  mov  es:[di], al
  inc  di
  loop @1
@x:
end; { Lower }

function GetError; assembler;
asm
  mov  ax, ErrorCode
  mov  ErrorCode, 0
end; { GetError }

function PeekError; assembler;
asm
  mov  ax, ErrorCode
end; { PeekError }

{$IFNDEF MSDOS}
procedure Leave; far;
begin
  ExitProc:=MyExitProc;           { change to old handler }
  GlobalDosFree(ciSelector.High); { release Dos memory    }
end; { Leave }

procedure InitExitProc;
begin
  MyExitProc:=ExitProc; { save old handler }
  ExitProc:=@Leave; { save my own handler  }
end; { InitExitProc }
{$ENDIF}

begin { NLS }
  UnitOk:=Lo(DosVersion)>=3; { does only work for Dos 3+ }
  if UnitOK then { allocate memory }
  begin
  {$IFDEF DPMI}
    longint(ciSelector):=GlobalDosAlloc(sizeof(TCountryInfo));
    if ciSelector.Low=0 then UnitOK:=False; { if not enough Dos memory }
    CountryInfo:=Ptr(ciSelector.Low, 0); { make protected mode pointer }
    if UnitOK then InitExitProc; { change exit proc                    }
  {$ELSE}
    if MaxAvail>sizeof(CountryInfo^) then{ allocate if enough memory   }
      New(CountryInfo)
    else
      UnitOK:=False; { or disable extentions }
  {$ENDIF}
  end; { if UnitOK }
end.

