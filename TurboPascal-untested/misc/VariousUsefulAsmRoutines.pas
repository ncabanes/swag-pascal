(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0137.PAS
  Description: Various Useful ASM Routines
  Author: JOHN STEPHENSON
  Date: 05-26-95  22:58
*)


{ Updated MISC.SWG on May 26, 1995 }

{
This unit has many many features, including, but not limited to:

 o InterNational upper and lower casing functions.
 o Easy reference to the keys, via consts
 o Easy access to direct screen writes (written in Assembler of course)
 o FAST wild card compare routine (thanks to Arne de Bruijn)
 o Access to miscellanous video commands, like blinkon and blinkoff, cursor
   on, and cursor off.
 o Much more to improve in overall performance of your code.
 
{$A+,B-,D-,E+,F-,G-,I-,L+,N-,O-,R-,S-,V+,X+}
{$M 16384,0,655360}
Unit AsmMisc; { by John MD Stephenson }
{ Country specific case conversation and other info retrieval.
  Donated to the public domain by Björn Felten @ 2:203/208. }
{ Arne de.Bruijn wrote the WildComp function }
{ The UnCrunch routine comes from TheDraw - public domain }
{ All other code is written by myself, or Public Domain }

{┌────────────────────────────────────────────────────────────────────────┐}
{│                              } Interface {                             │}
{└────────────────────────────────────────────────────────────────────────┘}
Uses Dos,Crt;

{ For easy reference to keys }
Const
  _Home     = #71;
  _End      = #79;
  _Up       = #72;
  _Down     = #80;
  _Left     = #75;
  _Right    = #77;
  _PageUp   = #73;
  _PageDown = #81;
  _Insert   = #82;
  _Delete   = #83;
  _CtrlPageUp   = #132;
  _CtrlPageDown = #118;
  _CtrlHome     = #119;
  _CtrlEnd      = #117;

  _F1       = #59;
  _F2       = #60;
  _F3       = #61;
  _F4       = #62;
  _F5       = #63;
  _F6       = #64;
  _F7       = #65;
  _F8       = #66;
  _F9       = #67;
  _F10      = #68;

  { First row }
  _AltQ     = #16;
  _AltW     = #17;
  _AltE     = #18;
  _AltR     = #19;
  _AltT     = #20;
  _AltY     = #21;
  _AltU     = #22;
  _AltI     = #23;
  _AltO     = #24;
  _AltP     = #25;

  { Second row }
  _AltA     = #30;
  _AltS     = #31;
  _AltD     = #32;
  _AltF     = #33;
  _AltG     = #34;
  _AltH     = #35;
  _AltJ     = #36;
  _AltK     = #37;
  _AltL     = #38;

  { Forth row }
  _AltZ     = #44;
  _AltX     = #45;
  _AltC     = #46;
  _AltV     = #47;
  _AltB     = #48;
  _AltN     = #49;
  _AltM     = #50;

  { Number row }
  _Alt1     = #120;
  _Alt2     = #121;
  _Alt3     = #122;
  _Alt4     = #123;
  _Alt5     = #124;
  _Alt6     = #125;
  _Alt7     = #126;
  _Alt8     = #127;
  _Alt9     = #128;
  _Alt0     = #129;
  _Alt_Dash = #130;
  _Alt_Equal= #131;

  { Variations }

  _AltF1    = #104;
  _AltF2    = #105;
  _AltF3    = #106;
  _AltF4    = #107;
  _AltF5    = #108;
  _AltF6    = #109;
  _AltF7    = #110;
  _AltF8    = #111;
  _AltF10   = #112;

  _ShiftF1  = #84;
  _ShiftF2  = #85;
  _ShiftF3  = #86;
  _ShiftF4  = #87;
  _ShiftF5  = #88;
  _ShiftF6  = #89;
  _ShiftF7  = #90;
  _ShiftF8  = #91;
  _ShiftF10 = #92;

type
  DelimType = record
    thousands,
    decimal,
    date,
    time: array[0..1] of Char;
  end;

  CurrType = (leads,             { symbol precedes value }
              trails,            { value precedes symbol }
              leads_,            { symbol, space, value }
              _trails,           { value, space, symbol }
              replace);          { replaced }

  datefmt = (USA,Europe,Japan);

  CountryType = record
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

  CountryInfo =  record
    case InfoID: byte of
      1: (IDSize     : word;
          CountryID  : word;
          CodePage   : word;
          TheInfo    : CountryType);
      2: (UpCaseTable: pointer);
  end;

var
  CountryOk          : Boolean;    { Could determine country code flag }
  CountryRec         : CountryInfo;
  Maxwidth,maxheight : Byte;
  ScreenSize         : Word;

{══════════════════════════════════════════════════════════════════════════}
Procedure BlinkOff;
Procedure BlinkOn;
Procedure CLI; Inline($FA);
Procedure CursorOff;
Procedure CursorOn;
Procedure GetBorder(var color: byte);
Procedure SetBorder(color: byte);
Procedure PutAttrs(x,y: byte; times: word);
Procedure PutChars(x,y: byte; chr: char; times: word);
Procedure PutString(x,y: byte; s: string);
Procedure ReallocateMemory(P: Pointer);
Procedure Retrace;
Procedure StuffChar(c: char);
Procedure STI; Inline($FB);
Procedure UnCrunch(var Addr1,Addr2; BlkLen: Word);
{──────────────────────────────────────────────────────────────────────────}
Function Execute(Name,tail: pathstr): Word;
Function FileExists(filename: PathStr): Boolean;
Function LoCase(c: Char) : Char;
Function LoCaseStr(s: String): String;
Function Upcase(c: Char) : Char;
Function UpCaseStr(s: String): String;
Function WildComp(NameStr,SearchStr: String): Boolean;
{══════════════════════════════════════════════════════════════════════════}
type
  screentype = array[0..7999] of byte;
Var
  Segment   : word;
  Screenaddr: ^screentype;
  LoTable   : array[0..127] of byte;
  CRP, LTP  : pointer;

{┌────────────────────────────────────────────────────────────────────────┐}
{│                            } Implementation {                          │}
{└────────────────────────────────────────────────────────────────────────┘}

Procedure SetBorder(color : byte);  assembler;
asm
  mov ax, $1001
  mov bh, color
  int $10
End;

Procedure GetBorder(var color : byte); assembler;
asm
  mov ax, $1008
  int $10
  les DI, color
  mov [ES:DI], bh
end;

procedure CursorOff; assembler;
asm
  mov ah, $01   { Cursor function }
  mov cx, $FFFF { Set new cursor value }
  int $10       { Video interrupt }
end;

procedure CursorOn; assembler;
asm
  mov ah, $01   { Cursor function }
  mov cx, 1543  { Set new cursor value }
  int $10       { Video interrupt }
end;

procedure StuffChar(c : char); assembler;
asm
  mov ah, $05
  mov cl, c   { cl = c }
  xor ch, ch  { ch = 0 }
  int $16
end;

Procedure BlinkOff; assembler;
{ Note that the BL is the actual register, but BH _should_ also be set to 0 }
asm
  mov ax, $1003
  mov bx, $0000
  int $10
end;

Procedure BlinkOn; assembler;
{ Note that the BL is the actual register, but BH _should_ also be set to 0 }
asm
  mov ax, $1003
  mov bx, $0001
  int $10
end;

Procedure Retrace; assembler;
{ waits for a vertical retrace }
  asm
    mov dx, $03DA
   @loop1:
    in al, dx
    test al, 8
    jz @loop1
   @loop2:
    in al, dx
    test al, 8
    jnz @loop2
  end;

procedure UnCrunch(var Addr1,Addr2; BlkLen:Word); assembler;
{ From TheDraw, not my procedure }
asm
  PUSH    DS             { Save data segment.}
  LDS     SI, Addr1      { Source Address}
  LES     DI, Addr2      { Destination Addr}
  MOV     CX, BlkLen     { Length of block}
  JCXZ    @Done
  MOV     DX,DI          { Save X coordinate for later.}
  XOR     AX,AX          { Set Current attributes.}
  CLD
 @LOOPA:
  LODSB                  { Get next character.}
  CMP     AL,32          { If a control character, jump.}
  JC      @ForeGround
  STOSW                  { Save letter on screen.}
 @Next:
  LOOP    @LOOPA
  JMP     @Done
 @ForeGround:
  CMP     AL,16          { If less than 16, then change the}
  JNC     @BackGround    { foreground color.  Otherwise jump.}
  AND     AH,0F0h        { Strip off old foreground.}
  OR      AH,AL
  JMP     @Next
 @BackGround:
  CMP     AL,24          { If less than 24, then change the}
  JZ      @NextLine      { background color.  If exactly 24,}
  JNC     @FlashBitToggle{ then jump down to next line.}
  SUB     AL,16          { Otherwise jump to multiple output}
  ADD     AL,AL          { routines.}
  ADD     AL,AL
  ADD     AL,AL
  ADD     AL,AL
  AND     AH,8Fh         { Strip off old background.}
  OR      AH,AL
  JMP     @Next
 @NextLine:
  ADD     DX,160         { If equal to 24,}
  MOV     DI,DX          { then jump down to}
  JMP     @Next          { the next line.}
 @FlashBitToggle:
  CMP     AL,27          { Does user want to toggle the blink}
  JC      @MultiOutput   { attribute?}
  JNZ     @Next
  XOR     AH,128         { Done.}
  JMP     @Next
 @MultiOutput:
  CMP     AL,25          { Set Z flag if multi-space output.}
  MOV     BX,CX          { Save main counter.}
  LODSB                  { Get count of number of times}
  MOV     CL,AL          { to display character.}
  MOV     AL,32
  JZ      @StartOutput   { Jump here if displaying spaces.}
  LODSB                  { Otherwise get character to use.}
  DEC     BX             { Adjust main counter.}
 @StartOutput:
  XOR     CH,CH
  INC     CX
  REP STOSW
  MOV     CX,BX
  DEC     CX             { Adjust main counter.}
  LOOPNZ  @LOOPA         { Loop if anything else to do...}
 @Done:
  POP     DS             { Restore data segment.}
end;

Procedure ReallocateMemory(P : Pointer); Assembler;
Asm
  Mov  AX, PrefixSeg
  Mov  ES, AX
  Mov  BX, word ptr P+2
  Cmp  Word ptr P,0
  Je   @OK
  Inc  BX
 @OK:
  Sub  BX, AX
  Mov  AH, $4A
  Int  $21
  Jc   @Out
  Les  DI, P
  Mov  Word Ptr HeapEnd,DI
  Mov  Word Ptr HeapEnd+2,ES
 @Out:
End;

Function Execute(Name, tail : pathstr) : Word; Assembler;
Asm
  Push Word Ptr HeapEnd+2
  Push Word Ptr HeapEnd
  Push Word Ptr Name+2
  Push Word Ptr Name
  Push Word Ptr Tail+2
  Push Word Ptr Tail
  Push Word Ptr HeapPtr+2
  Push Word Ptr HeapPtr
  Call ReallocateMemory
  Call SwapVectors
  Call Dos.Exec
  Call SwapVectors
  Call ReallocateMemory
  Mov  AX, DosError
  Or   AX, AX
  Jnz  @Done
  Mov  AH, $4D
  Int  $21 { Return error in will be in AX (if any) }
 @Done:
End;

Procedure Putchars(x, y : byte; chr : char; times : word);
{ Procedure to fill a count amount of characters from position x, y }
var offst: word;
begin
  offst := (pred(y)*maxwidth+pred(x))*2;
  asm
    mov es, segment   { Segment to start at       }
    mov di, offst     { Offset to start at        }
    mov al, chr       { Data to place             }
    mov ah, textattr  { Colour to use             }
    mov cx, times     { How many times            }
    cld               { Forward in direction      }
    rep stosw         { Store the word (cx times) }
  end;
end;


Procedure PutAttrs(x,y: byte; times: word);
{ This procedure is to fill a certain amount of spaces with a colour       }
{ (from cursor position) and doesn't move cursor position!                 }
var offst: word;
begin
  offst := succ((pred(y)*maxwidth+pred(x))*2);
  asm
    mov es, segment
    mov di, offst
    mov cx, times
    mov ah, 0
    mov al, textattr
    cld
   @s1:
    stosb
    inc di    { Increase another above what the stosb already loops }
    loop @s1  { Loop until cx = 0                                   }
  end;
end;

Procedure PutString(x, y: byte; s: string);
Begin
  { Does a direct video write -- extremely fast. }
  asm
    mov dh, y         { move X and Y into DL and DH (DX) }
    mov dl, x

    xor al, al
    mov ah, textattr  { load color into AH }
    push ax           { PUSH color combo onto the stack }

    mov ax, segment
    push ax           { PUSH video segment onto stack }

    mov bx, 0040h     { check 0040h:0049h to get number of screen columns }
    mov es, bx
    mov bx, 004ah
    xor ch, ch
    mov cl, es:[bx]
    xor ah, ah        { move Y into AL; decrement to convert Pascal coords }
    mov al, dh
    dec al
    xor bh, bh        { shift X over into BL; decrement again }
    mov bl, dl
    dec bl
    cmp cl, $50       { see if we're in 80-column mode }
    je @eighty_column
    mul cx            { multiply Y by the number of columns }
    jmp @multiplied
   @eighty_column:    { 80-column mode: it may be faster to perform the }
    mov cl, 4         {   multiplication via shifts and adds: remember  }
    shl ax, cl        {   that 80d = 1010000b , so one can SHL 4, copy  }
    mov dx, ax        {   the result to DX, SHL 2, and add DX in.       }
    mov cl, 2
    shl ax, cl
    add ax, dx
   @multiplied:
    add ax, bx        { add X in }
    shl ax, 1         { multiply by 2 to get offset into video segment }
    mov di, ax        { video pointer is in DI }
    lea si, s         { string pointer is in SI }
    SEGSS lodsb
    cmp al, 00h       { if zero-length string, jump to end }
    je @done
    mov cl, al
    xor ch, ch        { string length is in CX }
    pop es            { get video segment back from stack; put in ES }
    pop ax            { get color back from stack; put in AX (AH = color) }
   @write_loop:
    SEGSS lodsb       { get character to write }
    mov es:[di], ax   { write AX to video memory }
    inc di            { increment video pointer }
    inc di
    loop @write_loop  { if CX > 0, go back to top of loop }
   @done:             { end }
  end;
end;

function WildComp(NameStr,SearchStr: String): Boolean; assembler;
{
 Compare SearchStr with NameStr, and allow wildcards in SearchStr.
 The following wildcards are allowed:
 *ABC*        matches everything which contains ABC
 [A-C]*       matches everything that starts with either A,B or C
 [ADEF-JW-Z]  matches A,D,E,F,G,H,I,J,W,V,X,Y or Z
 ABC?         matches ABC, ABC1, ABC2, ABCA, ABCB etc.
 ABC[?]       matches ABC1, ABC2, ABCA, ABCB etc. (but not ABC)
 ABC*         matches everything starting with ABC
 (for using with DOS filenames like DOS (and 4DOS), you must split the
  filename in the extention and the filename, and compare them seperately)
}
var
  LastW: word;
asm
  cld
  push ds
  lds si,SearchStr
  les di,NameStr
  xor ah,ah
  lodsb
  mov cx,ax
  mov al,es:[di]
  inc di
  mov bx,ax
  or cx,cx
  jnz @ChkChr
  or bx,bx
  jz @ChrAOk
  jmp @ChrNOk
  xor dh,dh
 @ChkChr:
  lodsb
  cmp al,'*'
  jne @ChkQues
  dec cx
  jz @ChrAOk
  mov dh,1
  mov LastW,cx
  jmp @ChkChr
 @ChkQues:
  cmp al,'?'
  jnz @NormChr
  inc di
  or bx,bx
  je @ChrOk
  dec bx
  jmp @ChrOk
 @NormChr:
  or bx,bx
  je @ChrNOk
 {From here to @No4DosChr is used for [0-9]/[?]/[!0-9] 4DOS wildcards...}
  cmp al,'['
  jne @No4DosChr
  cmp word ptr [si],']?'
  je @SkipRange
  mov ah,byte ptr es:[di]
  xor dl,dl
  cmp byte ptr [si],'!'
  jnz @ChkRange
  inc si
  dec cx
  jz @ChrNOk
  inc dx
 @ChkRange:
  lodsb
  dec cx
  jz @ChrNOk
  cmp al,']'
  je @NChrNOk
  cmp ah,al
  je @NChrOk
  cmp byte ptr [si],'-'
  jne @ChkRange
  inc si
  dec cx
  jz @ChrNOk
  cmp ah,al
  jae @ChkR2
  inc si              {Throw a-Z < away}
  dec cx
  jz @ChrNOk
  jmp @ChkRange
 @ChkR2:
  lodsb
  dec cx
  jz @ChrNOk
  cmp ah,al
  ja @ChkRange        {= jbe @NChrOk; jmp @ChkRange}
 @NChrOk:
  or dl,dl
  jnz @ChrNOk
  inc dx
 @NChrNOk:
  or dl,dl
  jz @ChrNOk
 @NNChrOk:
  cmp al,']'
  je @NNNChrOk
 @SkipRange:
  lodsb
  cmp al,']'
  loopne @SkipRange
  jne @ChrNOk
 @NNNChrOk:
  dec bx
  inc di
  jmp @ChrOk
 @No4DosChr:
  cmp es:[di],al
  jne @ChrNOk
  inc di
  dec bx
 @ChrOk:
  xor dh,dh
  dec cx
  jnz @ChkChr        { Can't use loop, distance >128 bytes }
  or bx,bx
  jnz @ChrNOk
 @ChrAOk:
  mov al,1
  jmp @EndR
 @ChrNOk:
  or dh,dh
  jz @IChrNOk
  jcxz @IChrNOk
  or bx,bx
  jz @IChrNOk
  inc di
  dec bx
  jz @IChrNOk
  mov ax,[LastW]
  sub ax,cx
  add cx,ax
  sub si,ax
  dec si
  jmp @ChkChr
 @IChrNOk:
  mov al,0
 @EndR:
  pop ds
end;

Function Upcasestr(S : String) : String; Assembler;
Asm
  PUSH    DS
  LDS     SI,S
  LES     DI,@Result
  CLD
  LODSB
  STOSB
  xor     CH,CH
  MOV     CL,AL
  JCXZ    @OUT
 @LOOP:
  LODSB
  xor ah, ah
  push ax
  call upcase
  StoSb
  Loop    @Loop
 @OUT:
  POP   DS
end;

Function Locasestr(S : String) : String; Assembler;
Asm
  PUSH    DS
  LDS     SI,S
  LES     DI,@Result
  CLD
  LODSB
  STOSB
  xor     CH,CH
  MOV     CL,AL
  JCXZ    @OUT
 @LOOP:
  LODSB
  xor ah, ah
  push ax
  call locase { So we're not duping a lot of instructions }
  STOSB
  LOOP    @LOOP
 @OUT:
  POP   DS
end;

{ Convert a character to upper case }

function UpCase; Assembler;
asm
  mov     al, c
  cmp     al, 'a'
  jb      @2
  cmp     al, 'z'
  ja      @1
  sub     al, ' '
  jmp     @2
 @1:
  cmp     al, 80h
  jb      @2
  sub     al, 7eh
  push    ds
  lds     bx,CountryRec.UpCaseTable
  xlat
  pop     ds
 @2:
end; { UpCase }

  { Convert a character to lower case }

function LoCase; Assembler;
asm
  mov     al, c
  cmp     al, 'A'
  jb      @2
  cmp     al, 'Z'
  ja      @1
  or      al, ' '
  jmp     @2
 @1:
  cmp     al, 80h
  jb      @2
  sub     al, 80h
  mov     bx,offset LoTable
  xlat
 @2:
end;                                 { LoCase }

Function FileExists(filename: PathStr): Boolean; Assembler;
Asm
  Push Ds
  Lds  Si, [filename]      { Make ASCIIZ }
  Xor  Ah, Ah
  Lodsb
  XChg Ax, Bx
  Mov  Byte Ptr [Si+Bx], 0
  Mov  Dx, Si
  Mov  Ax, 4300h           { Get file attributes }
  Int  21h
  Mov  Al, False
  Jc   @1                  { Fail? }
  Inc  Ax
 @1: 
  Pop  Ds
end;  { FileExists }


Begin
  { Init the video addresses }
  if lastmode = 7 then segment := $B000 else segment := $B800;
  screenaddr := ptr(segment,$0000);
  
  { Init the video }
  Maxwidth := succ(lo(windmax));  { Get maximum window positions, which are   }
  Maxheight := succ(hi(windmax)); { the maxwidth and maxheight to be precise! }
  ScreenSize := maxheight*maxwidth*2; { For easy references to move commands. }

  { Init the tables for Upcasing }
  Crp := @CountryRec;
  Ltp := @LoTable;
  asm
    { Exit if Dos version < 3.0 }
    mov     ah, 30h
    int     21h
    cmp     al, 3
    jb      @1
    { Call Dos 'Get extended country information' function }
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
   @1:
    mov     [CountryOk], False
   @2:
  end;
end.


