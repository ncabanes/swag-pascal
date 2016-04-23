{$S-,R-,V-,I-,B-,F+}

{$IFNDEF Ver40}
  {$I OPLUS.INC}
{$ENDIF}

{*********************************************************}
{*                  TPWRDSTR.PAS 1.0                     *}
{*          Copyright (c) Ken Henderson 1990.            *}
{*                                                       *}
{*                                                       *}
{*                 All rights reserved.                  *}
{*********************************************************}

unit TPWrdStr;
  {-Routines to support strings which use a word in the place of Turbo Pascal's
    byte for holding the length of a string -- theoretically allowing strings
    as large as 64k.}

interface

uses
  TpString;

const
  MaxWrdStr = 1024;          {Maximum length of WrdStr - increase up to 65519}
  NotFound = 0;              {Returned by the Pos functions if substring not found}

type
  WrdStr = array[-1..MaxWrdStr] of Char;
  WrdStrPtr = ^WrdStr;

function WrdStr2Str(var A : WrdStr) : string;
  {-Convert WrdStr to Turbo string, truncating if longer than 255 chars}

procedure Str2WrdStr(S : string; var A : WrdStr);
  {-Convert a Turbo string into an WrdStr}

function LenWrdStr(A : WrdStr) : Word;
  {-Return the length of an WrdStr string}

procedure CopyWrdStr(var A : WrdStr; Start, Len : Word; var O : WrdStr);
  {-Return a substring of a. Note start=1 for first char in a}

procedure DeleteWrdStr(var A : WrdStr; Start, Len : Word);
  {-Delete len characters of a, starting at position start}

procedure ConcatWrdStr(var A, B, C : WrdStr);
  {-Concatenate two WrdStr strings, returning a third}

procedure ConcatStr(var A : WrdStr; S : string; var C : WrdStr);
  {-Concatenate a string to an WrdStr, returning a new WrdStr}

procedure InsertWrdStr(var Obj, A : WrdStr; Start : Word);
  {-Insert WrdStr obj at position start of a}

procedure InsertStr(Obj : string; var A : WrdStr; Start : Word);
  {-Insert string obj at position start of a}

function PosStr(Obj : string; var A : WrdStr) : Word;
  {-Return the position of the string obj in a, returning NotFound if not found}

function PosWrdStr(var Obja, A : WrdStr) : Word;
  {-Return the position of obja in a, returning NotFound if not found}

function WrdStrToHeap(var A : WrdStr) : WrdStrPtr;
  {-Put WrdStr on heap, returning a pointer, nil if insufficient memory}

procedure WrdStrFromHeap(P : WrdStrPtr; var A : WrdStr);
  {-Return an WrdStr from the heap, empty if pointer is nil}

procedure DisposeWrdStr(P : WrdStrPtr);
  {-Dispose of heap space pointed to by P}

function ReadLnWrdStr(var F : Text; var A : WrdStr) : Boolean;
  {-Read an WrdStr from text file, returning true if successful}

function WriteWrdStr(var F : Text; var A : WrdStr) : Boolean;
  {-Write an WrdStr to text file, returning true if successful}

procedure WrdStrUpcase(var A, B : WrdStr);
  {-Uppercase the WrdStr in a, returning b}

procedure WrdStrLocase(var A, B : WrdStr);
  {-Lowercase the WrdStr in a, returning b}

procedure WrdStrCharStr(Ch : Char; Len : Word; var A : WrdStr);
  {-Return an WrdStr of length len filled with ch}

procedure WrdStrPadCh(var A : WrdStr; Ch : Char; Len : Word; var B : WrdStr);
  {-Right-pad the WrdStr in a to length len with ch, returning b}

procedure WrdStrPad(var A : WrdStr; Len : Word; var B : WrdStr);
  {-Right-pad the WrdStr in a to length len with blanks, returning b}

procedure WrdStrLeftPadCh(var A : WrdStr; Ch : Char; Len : Word; var B : WrdStr);
  {-Left-pad the WrdStr in a to length len with ch, returning b}

procedure WrdStrLeftPad(var A : WrdStr; Len : Word; var B : WrdStr);
  {-Left-pad the WrdStr in a to length len with blanks, returning b}

procedure WrdStrTrimLead(var A, B : WrdStr);
  {-Return an WrdStr with leading white space removed}

procedure WrdStrTrimTrail(var A, B : WrdStr);
  {-Return an WrdStr with trailing white space removed}

procedure WrdStrTrim(var A, B : WrdStr);
  {-Return an WrdStr with leading and trailing white space removed}

procedure WrdStrCenterCh(var A : WrdStr; Ch : Char; Width : Word; var B : WrdStr);
  {-Return an WrdStr centered in an WrdStr of Ch with specified width}

procedure WrdStrCenter(var A : WrdStr; Width : Word; var B : WrdStr);
  {-Return an WrdStr centered in an WrdStr of blanks with specified width}

function CompWrdStr(var a1, a2 : WrdStr) : Boolean;
  {-Return equivalence of a1 and a2}

  {==========================================================================}

implementation
const
 Blank : char = #32;

  function WrdStr2Str(var A : WrdStr) : string;
    {-Convert WrdStr to Turbo string, truncating if longer than 255 chars}
  var
    S : string;
    Len : Word absolute A;
    Slen : byte Absolute S;
  begin
    if Len > 255 then SLen := 255
    else Slen := Len;
    Move(A[1], S[1], SLen);
    WrdStr2Str := S;
  end;

  procedure Str2WrdStr(S : string; var A : WrdStr);
    {-Convert a Turbo string into an WrdStr}
  var
    slen : byte absolute S;
    alen : word absolute A;
  begin
    Move(S[1], A[1], slen);
    alen := slen;
  end;

  function LenWrdStr(A : WrdStr) : Word;
    {-Return the length of an WrdStr string}
  var
    alen : Word absolute A;
  begin
    LenWrdStr := alen;
  end;

  procedure CopyWrdStr(var A : WrdStr; Start, Len : Word; var O : WrdStr);
    {-Return a substring of a. Note start=1 for first char in a}
  var
    alen : Word absolute A;
    olen : Word absolute O;
  begin
    if Start > alen then
      Olen := 0
    else begin
      {Don't copy more than exists}
      if Start+Len > alen then
        Len := Succ(alen-Start);
      Move(A[Start], O[1], Len);
      Olen := Len;
    end;
  end;

  procedure DeleteWrdStr(var A : WrdStr; Start, Len : Word);
    {-Delete len characters of a, starting at position start}
  var
    alen : Word Absolute A;
    mid : Word;
  begin
    if Start <= alen then begin
      {Don't do anything if start position exceeds length of string}
      mid := Start+Len;
      if mid <= alen then begin
        {Move right remainder of string left}
        Move(A[mid], A[Start], len);
        Dec(alen,len);
      end else
        {Entire end of string deleted}
        alen := Pred(Start);
    end;
  end;

  procedure ConcatWrdStr(var A, B, C : WrdStr);
    {-Concatenate two WrdStr strings, returning a third}
  var
    alen : Word absolute A;
    blen : Word absolute B;
    clen : Word absolute C;
    temp : Word;
  begin

    {Put a into the result}
    Move(A[1], C[1], alen);

    {Store as much of b as fits into result}
    Temp := blen;
    if alen+blen > MaxWrdStr then
      Temp := MaxWrdStr-alen;
    Move(B[1], C[Succ(alen)], Temp);

    {Terminate the result}
    clen := alen+blen;
  end;

  procedure ConcatStr(var A : WrdStr; S : string; var C : WrdStr);
    {-Concatenate a string to an WrdStr, returning a new WrdStr}
  var
    alen : Word absolute A;
    clen : Word absolute C;
    slen : Byte absolute S;
  begin

    {Put a into the result}
    Move(A[1], C[1], alen);

    {Store as much of s as fits into result}
    if alen+slen > MaxWrdStr then
      slen := MaxWrdStr-alen;
    Move(S[1], C[succ(alen)], slen);

    {Terminate the result}
    clen := alen+slen;
  end;

  procedure InsertWrdStr(var Obj, A : WrdStr; Start : Word);
    {-Insert WrdStr obj at position start of a}
  var
    alen : Word absolute A;
    olen : Word absolute Obj;
    mid, temp : Word;
  begin

    if Start > alen then
      {Concatenate if start exceeds alen}
      Start := Succ(alen)

    else begin
      {Move right side characters right to make space for insert}
      mid := Start+olen;
      if mid <= MaxWrdStr then
        {Room for at least some of the right side characters}
        if alen+olen <= MaxWrdStr then
          {Room for all of the right side}
          Move(A[Start], A[mid], Succ(alen-Start))
        else
          {Room for part of the right side}
          Move(A[Start], A[mid], Succ(MaxWrdStr-mid));
    end;

    {Insert the obj string}
    temp := Olen;
    if Start+olen > MaxWrdStr then
      temp := Succ(MaxWrdStr-Start);
    Move(Obj[1], A[Start], temp);

    {Terminate the string}
    if alen+olen <= MaxWrdStr then
      Inc(alen,olen)
    else
      alen := MaxWrdStr;
  end;

  procedure InsertStr(Obj : string; var A : WrdStr; Start : Word);
    {-Insert string obj at position start of a}
  var
    alen : Word absolute A;
    olen : byte absolute Obj;
    mid,temp : Word;
  begin

    if Start > alen then
      {Concatenate if start exceeds alen}
      Start := succ(alen)

    else begin
      {Move right side characters right to make space for insert}
      mid := Start+olen;
      if mid <= MaxWrdStr then
        {Room for at least some of the right side characters}
        if alen+olen <= MaxWrdStr then
          {Room for all of the right side}
          Move(A[Start], A[mid], Succ(alen-Start))
        else
          {Room for part of the right side}
          Move(A[Start], A[mid], Succ(MaxWrdStr-mid));
    end;

    {Insert the obj string}
    temp := olen;
    if Start+olen > MaxWrdStr then
      temp := Succ(MaxWrdStr-Start);
    Move(Obj[1], A[Start], temp);

    {Terminate the string}
    if alen+olen <= MaxWrdStr then
      Inc(alen,olen)
    else
      alen := MaxWrdStr;
  end;

  {$L TPWrdStr}
  function Search(var Buffer; BufLength : Word; var Match; MatLength : Word) : Word;
    external;
  procedure WrdStrUpcase(var A, B : WrdStr);
    {-Upper case WrdStr A, returning it in B}
  var
    alen : Word absolute A;
    x : Word;
  begin
    For x:=1 to alen do A[x]:=UpCase(A[x]);
    Move(A,B,alen+2);
  end;
  procedure WrdStrLocase(var A, B : WrdStr);
    {-Lower case WrdStr A, returning it in B}
  var
    alen : Word absolute A;
    x : Word;
  begin
    For x:=1 to alen do A[x]:=LoCase(A[x]);
    Move(A,B,alen+2);
  end;

  function CompWrdStr(var a1, a2 : WrdStr) : Boolean;
    {-Compare WrdStr's a1 and a2 and return equivalence}
  var
   alen1 : Word absolute A1;
   alen2 : Word absolute A2;
   x : Word;
  begin
    CompWrdStr := false;
    If (alen1=alen2) then  {possibly equal, let's check it out}
    begin
      for x:=1 to alen1 do if (A1[x]<>A2[x]) then exit;
      CompWrdStr := true;  {If we made it to here, they must be equal}
    end;
  end;

  function PosStr(Obj : string; var A : WrdStr) : Word;
    {-Return the position of the string obj in a, returning NotFound if not found}
  var
    alen : Word absolute A;
    olen : Byte absolute Obj;
    PosFound : Word;
  begin
    PosFound := Search(A[1], alen, Obj[1], olen);
    If (PosFound = $FFFF) then {Search didn't find it}
       PosFound := 0;
    PosStr := Succ(PosFound);
  end;

  function PosWrdStr(var Obja, A : WrdStr) : Word;
    {-Return the position of obja in a, returning NotFound if not found}
  var
    alen : Word absolute A;
    olen : Word absolute Obja;
    PosFound : Word;
  begin
    PosFound := Search(A[1], alen, Obja[1], olen);
    If (PosFound = $FFFF) then {Search didn't find it}
       PosFound := 0;
    PosWrdStr := Succ(PosFound);
  end;

  function WrdStrToHeap(var A : WrdStr) : WrdStrPtr;
    {-Put WrdStr on heap, returning a pointer, nil if insufficient memory}
  var
    alen : Word;
    P : WrdStrPtr;
  begin
    alen := LenWrdStr(A)+2;
    if MaxAvail >= alen then begin
      GetMem(P, alen);
      Move(A, P^, alen);
      WrdStrToHeap := P;
    end else
      WrdStrToHeap := nil;
  end;

  procedure WrdStrFromHeap(P : WrdStrPtr; var A : WrdStr);
    {-Return an WrdStr from the heap, empty if pointer is nil}
  var
    alen : Word absolute a;
    plen : Word absolute p;
  begin
    if P = nil then
      Alen := 0
    else
      Move(P^, A, Plen+2);
  end;

  procedure DisposeWrdStr(P : WrdStrPtr);
    {-Dispose of heap space pointed to by P}
  begin
    if P <> nil then
      FreeMem(P, LenWrdStr(P^)+2);
  end;

  procedure WrdStrCharStr(Ch : Char; Len : Word; var A : WrdStr);
    {-Return an WrdStr of length len filled with ch}
  var
    alen : Word absolute A;
  begin
    if Len = 0 then
      Alen := 0
    else begin
      if Len > MaxWrdStr then
        Len := MaxWrdStr;
      FillChar(A[1], Len, Ch);
      Alen := Len;
    end;
  end;

  procedure WrdStrPadCh(var A : WrdStr; Ch : Char; Len : Word; var B : WrdStr);
    {-Right-pad the WrdStr to length len with ch, returning b}
  var
    alen : Word Absolute A;
    blen : Word Absolute B;
  begin
    if alen >= Len then
      {Return the input string}
      Move(A, B, alen+2)
    else begin
      if Len > MaxWrdStr then
        Len := MaxWrdStr;
      Move(A[1], B[1], alen);
      FillChar(B[succ(alen)], Len-alen, Ch);
      Blen := len;
    end;
  end;

  procedure WrdStrPad(var A : WrdStr; Len : Word; var B : WrdStr);
    {-Right-pad the WrdStr to length len with blanks, returning b}
  begin
    WrdStrPadCh(A, Blank, Len, B);
  end;

  procedure WrdStrLeftPadCh(var A : WrdStr; Ch : Char; Len : Word; var B : WrdStr);
    {-Left-pad the WrdStr in a to length len with ch, returning b}
  var
    alen : Word absolute A;
    blen : Word absolute B;
  begin
    if alen >= Len then
      {Return the input string}
      Move(A, B, alen+2)
    else begin
      FillChar(B[1], Len-alen, Ch);
      Move(A[1], B[Succ(Len-alen)], alen);
      BLen := Len;
    end;
  end;

  procedure WrdStrLeftPad(var A : WrdStr; Len : Word; var B : WrdStr);
    {-Left-pad the WrdStr in a to length len with blanks, returning b}
  begin
    WrdStrLeftPadCh(A, Blank, Len, B);
  end;

  procedure WrdStrTrimLead(var A, B : WrdStr);
    {-Return an WrdStr with leading white space removed}
  var
    alen : Word absolute A;
    apos : Word;
  begin
    apos := 1;
    while (apos < alen) and (A[apos] <= Blank) do
      Inc(apos);
    Move(A[apos], B[1], Succ(alen-apos));
  end;

  procedure WrdStrTrimTrail(var A, B : WrdStr);
    {-Return an WrdStr with trailing white space removed}
  var
    alen : Word absolute A;
    blen : Word absolute B;
  begin
    while (alen > 1) and (A[Pred(alen)] <= Blank) do
      Dec(alen);
    Move(A, B, alen+2);
  end;

  procedure WrdStrTrim(var A, B : WrdStr);
    {-Return an WrdStr with leading and trailing white space removed}
  var
    blen : Word Absolute B;
  begin
    WrdStrTrimLead(A, B);
    while (blen > 1) and (B[Pred(blen)] <= Blank) do
      Dec(blen);
  end;

  procedure WrdStrCenterCh(var A : WrdStr; Ch : Char; Width : Word; var B : WrdStr);
    {-Return an WrdStr centered in an WrdStr of Ch with specified width}
  var
    alen : Word absolute A;
    blen : Word absolute B;
  begin
    if alen >= Width then
      {Return input}
      Move(A, B, alen+2)
    else begin
      FillChar(B[1], Width, Ch);
      Move(A[1], B[Succ((Width-alen) shr 1)], alen);
      Blen := Width;
    end;
  end;

  procedure WrdStrCenter(var A : WrdStr; Width : Word; var B : WrdStr);
    {-Return an WrdStr centered in an WrdStr of blanks with specified width}
  begin
    WrdStrCenterCh(A, Blank, Width, B);
  end;

type
  {text buffer}
  TextBuffer = array[0..65520] of Byte;

  {structure of a Turbo File Interface Block}
  FIB = record
          Handle : Word;
          Mode : Word;
          BufSize : Word;
          Private : Word;
          BufPos : Word;
          BufEnd : Word;
          BufPtr : ^TextBuffer;
          OpenProc : Pointer;
          InOutProc : Pointer;
          FlushProc : Pointer;
          CloseProc : Pointer;
          UserData : array[1..16] of Byte;
          Name : array[0..79] of Char;
          Buffer : array[0..127] of Char;
        end;

const
  FMClosed = $D7B0;
  FMInput = $D7B1;
  FMOutput = $D7B2;
  FMInOut = $D7B3;
  CR : Char = ^M;

  function ReadLnWrdStr(var F : Text; var A : WrdStr) : Boolean;
    {-Read an WrdStr from text file, returning true if successful}
  var
    CrPos : Word;
    alen : Word absolute A;
    blen : Word;

    function RefillBuf(var F : Text) : Boolean;
      {-Refill buffer}
    var
      Ch : Char;
    begin
      with FIB(F) do begin
        BufEnd := 0;
        BufPos := 0;
        Read(F, Ch);
        if IoResult <> 0 then begin
          {Couldn't read from file}
          RefillBuf := False;
          Exit;
        end;
        {Reset the buffer again}
        BufPos := 0;
        RefillBuf := True;
      end;
    end;


  begin
    with FIB(F) do begin

      {Initialize the WrdStr length and function result}
      alen := 0;
      ReadLnWrdStr := False;

      {Make sure file open for input}
      if Mode <> FMInput then
        Exit;

      {Make sure something is in buffer}
      if BufPos >= BufEnd then
        if not(RefillBuf(F)) then
          Exit;

      {Use the Turbo text file buffer to build the WrdStr}
      repeat

        {Search for the next carriage return in the file buffer}
        CrPos := Search(BufPtr^[BufPos], Succ(BufEnd-BufPos), CR, 1);

        if CrPos = $FFFF then begin
          {CR not found, save the portion of the buffer seen so far}
          blen := BufEnd-BufPos;
          if alen+blen > MaxWrdStr then
            blen := MaxWrdStr-alen;

          Move(BufPtr^[BufPos], A[alen], blen);
          Inc(alen, blen);

          {See if at end of file}
          if eof(F) then begin
            {Force exit with this line}
            CrPos := 0;
            {Remove trailing ^Z}
            while (alen > 1) and (A[Pred(alen)] = ^Z) do
              Dec(alen);
          end else if not(RefillBuf(F)) then
            Exit;

        end else begin
          {Save up to the CR}
          blen := CrPos;
          if alen+blen > MaxWrdStr then
            blen := MaxWrdStr-alen;
          Move(BufPtr^[BufPos], A[alen], blen);
          Inc(alen, blen);

          {Inform Turbo we used the characters}
          Inc(BufPos, Succ(CrPos));

          {Skip over following ^J}
          if BufPos < BufEnd then begin
            {Next character is within current buffer}
            if BufPtr^[BufPos] = Ord(^J) then
              Inc(BufPos);
          end else begin
            {Next character is not within current buffer}
            {Refill the buffer}
            if not(RefillBuf(F)) then
              Exit;
            if BufPos < BufEnd then
              if BufPtr^[BufPos] = Ord(^J) then
                Inc(BufPos);
          end;

        end;

      until (CrPos <> $FFFF) or (alen > MaxWrdStr);

      {Return success and terminate the WrdStr}
      ReadLnWrdStr := True;

    end;
  end;

  function WriteWrdStr(var F : Text; var A : WrdStr) : Boolean;
    {-Write an WrdStr to text file, returning true if successful}
  var
    S : string;
    alen : Word absolute A;
    apos : Word;
    slen : Byte absolute S;
  begin
    apos := 1;
    WriteWrdStr := False;

    {Write the WrdStr as a series of strings}
    while apos < alen do begin
      slen := alen-apos;
      if slen > 255 then
        slen := 255;
      Move(A[apos], S[1], slen);
      Write(F, S);
      if IoResult <> 0 then
        Exit;
      Inc(apos, slen);
    end;

    WriteWrdStr := True;
  end;

end.


{ -----------------    XX3402 Code for TPWRDSTR.OBJ ------------------}
{ Cut HERE and save save to a files (TPWRDSTR.XX).  From DOS execute:
{               XX3402 D TPWRDSTR.XX to create TPWRDSTR.OBJ           }

*XX3402-000257-280390--72--85-53814----TPWRDSTR.OBJ--1-OF--1
U+s+13FEJp72IpFG9Y3HHQq66++++3FpQa7j623nQqJhMalZQW+UJaJmQqZjPW+l9X+lW6UI
+21dk9Bw3+lII3RGF3BIIWt-IoqHW-E+ECaU83gG13FEEoxBHIxC9Y3HHLu6+k-+uImK+U++
O7M4++F1HoF3FNU5+0V0++6-+TCA4E+8JJ-1EJB3I377HE+8H2x1EJB3I377HE-TY+o+++24
IoJ-IYB6++++dcU2+20W+N4UFU+-++-JWykSzAFy1cjTWosAWpM4VR7o7AJq08l88wdq4z8i
RFS3obEAIJRKWwfndZtTKLLgHsj58wDf+nD+G-y9tJr80U+VWU6++5E+
***** END OF BLOCK 1 *****

{ -----------------------   CUT HERE  -----------------------------------  }

{  -------------     ASSEMBLER CODE FOR TPWRDSTR.ASM  -------------------  }
{  USE TASM TO COMPILE }
;******************************************************
;                  TPWRDSTR.ASM 1.0
;             WrdStr string manipulation
;        Copyright (c) TurboPower Software 1987.
; Portions copyright (c) Sunny Hill Software 1985, 1986
;     and used under license to TurboPower Software
;                All rights reserved.
;******************************************************

        INCLUDE TPCOMMON.ASM

;****************************************************** Code

CODE    SEGMENT BYTE PUBLIC

        ASSUME  CS:CODE

        PUBLIC  Search

        EXTRN   UpCasePrim : FAR
        EXTRN   LoCasePrim : FAR

Upcase  MACRO                           ;UpCase character in AL
        PUSH   BX
        CALL   UpCasePrim
        POP    BX
        ENDM

Locase  MACRO                           ;LoCase character in AL
        PUSH   BX
        CALL   LoCasePrim
        POP    BX
        ENDM

;****************************************************** Search

;  function Search(var Buffer; BufLength : Word;
;                  var Match;  MatLength : Word) : Word; external;
;Search through Buffer for Match.
;BufLength is length of range to search.
;MatLength is length of string to match
;Returns number of bytes searched to find St, FFFF if not found

;equates for parameters:
MatLength       EQU     WORD PTR [BP+6]
Match           EQU     DWORD PTR [BP+8]
BufLength       EQU     WORD PTR  [BP+0Ch]
Buffer          EQU     DWORD PTR [BP+0Eh]

Search  PROC FAR

        StackFrameBP
        PUSH    DS                      ;Save DS
        CLD                             ;Go forward

        LES     DI,Buffer               ;ES:DI => Buffer
        MOV     BX,DI                   ;BX = Ofs(Buffer)

        MOV     CX,BufLength            ;CX = Length of range to scan
        MOV     DX,MatLength            ;DX = Length of match string

        TEST    DX,DX                   ;Length(Match) = 0?
        JZ      Error                   ;If so, we're done

        LDS     SI,Match                ;DS:SI => Match buffer
        LODSB                           ;AL = Match[1]; DS:SI => Match[2]
        DEC     DX                      ;DX = MatLength-1
        SUB     CX,DX                   ;CX = BufLength-(MatLength-1)
        JBE     Error                   ;Error if BufLength is less

;Search for first character in St
Next:   REPNE   SCASB                   ;Search forward for Match[1]
        JNE     Error                   ;Done if not found
        TEST    DX,DX                   ;If Length = 1 (DX = 0) ...
        JZ      Found                   ; the "string" was found

        ;Search for remainder of St

        PUSH    CX                      ;Save CX
        PUSH    DI                      ;Save DI
        PUSH    SI                      ;Save SI

        MOV     CX,DX                   ;CX = Length(St) - 1
        REPE    CMPSB                   ;Does rest of string match?

        POP     SI                      ;Restore SI
        POP     DI                      ;Restore DI
        POP     CX                      ;Restore CX

        JNE     Next                    ;Try again if no match

;Calculate number of bytes searched and return in St
Found:  DEC     DI                      ;DX = Offset where found
        MOV     AX,DI                   ;AX = Offset where found
        SUB     AX,BX                   ;Subtract starting offset
        JMP     Short Done              ;Done

;Match was not found
Error:  XOR     AX,AX                   ;Return
        DEC     AX                      ;Return FFFF

Done:   POP     DS                      ;Restore DS
        ExitCode 10

Search  ENDP

CODE    ENDS

        END
{ END OF TPWRDSTR.ASM }
{-------------------------------   CUT HERE ------------------------- }
