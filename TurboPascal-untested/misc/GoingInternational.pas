(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0091.PAS
  Description: Going International
  Author: BJ�RN FELTEN
  Date: 05-25-94  08:01
*)

unit CaseUtil;

interface

type
  DelimType =
    record
      thousands,
      decimal,
      date,
      time           : array[0..1] of Char;
    end;

  CurrType       = (leads,             { symbol precedes value }
                    trails,            { value precedes symbol }
                    leads_,            { symbol, space, value }
                    _trails,           { value, space, symbol }
                    replace);          { replaced }

  CountryType =
    record
      DateFormat     : Word;           { 0: USA, 1: Europe, 2: Japan }
      CurrSymbol     : array[0..4] of Char;
      Delimiter      : DelimType;      { Separators }
      CurrFormat     : CurrType;       { Way currency is formatted }
      CurrDigits     : Byte;           { Digits in currency }
      Clock24hrs     : Boolean;        { True if 24-hour clock }
      CaseMapCall    : procedure;      { Lookup table for ASCII > $80 }
      DataListSep    : array[0..1] of Char;
      CID            : word;
      Reserved       : array[0..7] of Char;
    end;

  CountryInfo =
    record
      case InfoID: byte of
      1: (IDSize     : word;
          CountryID  : word;
          CodePage   : word;
      TheInfo    : CountryType);
      2: (UpCaseTable: pointer);
      end;

var
  CountryOk : Boolean;            { Could determine country code flag }
  CountryRec    : CountryInfo;

function Upcase(c : Char) : Char;
function LoCase(c : Char) : Char;
function UpperStr(s : string) : string;
function LowerStr(s : string) : string;
procedure UpCaseStr(var s : String);
procedure LoCaseStr(var s : String);

implementation

{$R-,S-,V- }
var
  LoTable   : array[0..127] of byte;
  CRP, LTP  : pointer;

  { Convert a character to upper case }
  function Upcase; Assembler; asm
    mov     al, c
    cmp     al, 'a'
    jb      @2
    cmp     al, 'z'
    ja      @1
    sub     al, ' '
    jmp     @2
@1: cmp     al, 80h
    jb      @2
    sub     al, 7eh
    push    ds
    lds     bx,CountryRec.UpCaseTable
    xlat
    pop     ds
@2:
  end;                                 { UpCase }

  { Convert a character to lower case }
  function LoCase; Assembler;  asm
    mov     al, c
    cmp     al, 'A'
    jb      @2
    cmp     al, 'Z'
    ja      @1
    or      al, ' '
    jmp     @2
@1: cmp     al, 80h
    jb      @2
    sub     al, 80h
    mov     bx,offset LoTable
    xlat
@2:
  end;                                 { LoCase }

  { Convert a string to uppercase }
  procedure UpCaseStr; Assembler;  asm
    cld
    les     di, s
    xor     ax, ax
    mov     al, es:[di]
    stosb
    xchg    ax, cx
    jcxz    @4
    push    ds
    lds     bx,CountryRec.UpCaseTable
@1: mov     al, es:[di]
    cmp     al, 'a'
    jb      @3
    cmp     al, 'z'
    ja      @2
    sub     al, ' '
    jmp     @3
@2: cmp     al, 80h
    jb      @3
    sub     al, 7eh
    xlat
@3: stosb
    loop    @1
    pop     ds
@4:
  end;                                 { UpCaseStr }

  { Convert a string to lower case }
  procedure LoCaseStr; Assembler;  asm
    cld
    les     di, s
    xor     ax, ax
    mov     al, es:[di]
    stosb
    xchg    ax, cx
    jcxz    @4
@1: mov     al, es:[di]
    cmp     al, 'A'
    jb      @3
    cmp     al, 'Z'
    ja      @2
    or      al, ' '
    jmp     @3
@2: cmp     al, 80h
    jb      @3
    sub     al, 80h
    mov     bx, offset LoTable
    xlat
@3: stosb
    loop    @1
@4:
  end;                                 { LoCaseStr }

function UpperStr(s : string) : string;
begin  UpCaseStr(s);  UpperStr:=s end;
function LowerStr(s : string) : string;
begin  LoCaseStr(s);  LowerStr:=s end;

begin                                  { init DoCase unit }
  CRP := @CountryRec;
  LTP := @LoTable;
  asm

    { Exit if Dos version < 3.0 }
    mov     ah, 30h
    int     21h
    cmp     al, 3
    jb      @1

    { Call Dos 'Get country dependent information' function }
    mov     ax, 6501h
    les     di, CRP
    mov     bx,-1
    mov     dx,bx
    mov     cx,41
    int     21h
    jc      @1

    { Call Dos 'Get country dependent information' function }
    mov     ax, 6502h
    mov     bx, CountryRec.CodePage
    mov     dx, CountryRec.CountryID
    mov     CountryRec.TheInfo.CID, dx
    mov     cx, 5
    int     21h
    jc      @1

    { Build LoCase table }
    les     di, LTP
    mov     cx, 80h
    mov     ax, cx
    cld
@3:
    stosb
    inc     ax
    loop    @3
    mov     di, offset LoTable - 80h
    mov     cx, 80h
    mov     dx, cx
    push    ds
    lds     bx, CountryRec.UpCaseTable
    sub     bx, 7eh
@4:
    mov     ax, dx
    xlat
    cmp     ax, 80h
    jl      @5
    cmp     dx, ax
    je      @5
    xchg    bx, ax
    mov     es:[bx+di], dl
    xchg    bx, ax
@5:
    inc     dx
    loop    @4
    pop     ds
    mov     [CountryOk], True
    jmp     @2
@1: mov     [CountryOk], False
@2:
  end;
end.

