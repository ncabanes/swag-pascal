(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0035.PAS
  Description: Complete line editor
  Author: GAYLE DAVIS
  Date: 03-04-97  13:18
*)

{$S-,R-,V-,I-,N-,B-,F-}

{$IFNDEF Ver40}
      {Allow overlays}
      {$F+,O-,X+,A-}
{$ENDIF}

UNIT FastEdit;

INTERFACE

USES Crt, Keys; { keys unit at the end .. cut out }

TYPE

  EntryRec = RECORD
               Row, Col : BYTE;
               Format : STRING [80];
               Prompt : STRING [40];
             END;

TYPE

  CharSet = SET OF CHAR;
  InputTypes = (AnyChars, Alphas, Ups, Lows, Nums, Reals, Dates, Times);

CONST

  Printable : CharSet = [#32..#127];
  European  : CharSet = [#128..#168,#224..#239];    { European characters }
  Term : CharSet = [Esc, Enter, Tab, F2, Up, Down, ^X, ^E];
  ExitOutSet : CharSet = [F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, Up,
  Down, Esc];   FmtChars : CharSet = ['!', '#', '@', '*'];
  PhoneFormat : STRING = '(###) ###-####';
  DateFormat : STRING = '##/##/##';
  TimeFormat : STRING = '##:##';
  NumberFormat : STRING = '###,###,###';
  GIS : STRING[250] = '';
  DOTChar : Char = #4;

VAR
   TC : CHAR;
   BaseOfScreen : WORD;

procedure FastWrite(Strng : String; Row, Col, Attr : Byte);
PROCEDURE GotoRC (Row, Col : BYTE);

FUNCTION FmtStr (STR, Fmt : STRING) : STRING;


PROCEDURE EditLine (VAR S : STRING;
                   Row, Col : BYTE;
                   LegalChars,
                   Term : CharSet;
                   InputAttr : BYTE;
                   FormatStr : STRING;
                   CharType : InputTypes;
                   VAR TC : CHAR);

IMPLEMENTATION
  {$V-}


  PROCEDURE GotoRC (Row, Col : BYTE);
  BEGIN
    INLINE
    ($B4/$02/$31/$DB/$8E/$C3/$26/$8A/$3E/$62/$04/$8A/$76/<Row/$FE/$CE/$8A
    /$56/<Col/$FE/$CA/$CD/$10);
  END;

  procedure  FastWrite(Strng : String; Row, Col, Attr : Byte); assembler;
    { display strings directly on the CRT VERY FAST with color !! }
    asm
        PUSH    DS                     { ;Save DS }
        MOV     CH,Row                 { ;CH = Row }
        MOV     BL,Col                 { ;BL = Column }

        XOR     AX,AX                  { ;AX = 0 }
        MOV     CL,AL                  { ;CL = 0 }
        MOV     BH,AL                  { ;BH = 0 }
        DEC     CH                     { ;Row (in CH) to 0..24 range }
        SHR     CX,1                   { ;CX = Row * 128 }
        MOV     DI,CX                  { ;Store in DI }
        SHR     DI,1                   { ;DI = Row * 64 }
        SHR     DI,1                   { ;DI = Row * 32 }
        ADD     DI,CX                  { ;DI = (Row * 160) }
        DEC     BX                     { ;Col (in BX) to 0..79 range }
        SHL     BX,1                   { ;Account for attribute bytes }
        ADD     DI,BX                  { ;DI = (Row * 160) + (Col * 2) }
        MOV     ES,BaseOfScreen        { ;ES:DI points to BaseOfScreen:Row,Col }

        LDS     SI,DWORD PTR [Strng]   { ;DS:SI points to St[0] }
        CLD                            { ;Set direction to forward }
        LODSB                          { ;AX = Length(St); DS:SI -> St[1] }
        XCHG    AX,CX                  { ;CX = Length; AL = WaitForRetrace }
        JCXZ    @FWExit                { ;If string empty, exit }
        MOV     AH,Attr                { ;AH = Attribute }
      @FWDisplay:
        LODSB                          { ;Load next character into AL }
                                       { ; AH already has Attr }
        STOSW                          { ;Move video word into place }
        LOOP    @FWDisplay             { ;Get next character }
      @FWExit:
        POP     DS                     { ;Restore DS }
    end; {asm block}


  FUNCTION Max ( A, B : LONGINT ) : LONGINT;
  BEGIN (* Max *)

     IF A > B THEN
        Max := A
     ELSE
        Max := B;
  END   (* Max *);

  FUNCTION Min ( A, B : LONGINT ) : LONGINT;
  BEGIN (* Min *)

     IF A < B THEN
        Min := A
     ELSE
        Min := B;
  END   (* Min *);


  FUNCTION rPos(val : CHAR; Str : STRING) : BYTE;
  { return the right position of val in STR }
  VAR
     i : BYTE;
  BEGIN
     For i := Length(Str) DOWNTO 1 DO
         IF Str[i] = val THEN
            BEGIN
            rPos := i;
            EXIT;
            END;
  rPos := 0;
  END;

  function PadR(S : string; Len : Byte) : string;
    {-Return a string right-padded to length Len with Ch}
  var
    O : string;
    SLen : Byte absolute S;
  begin
    if Length(S) >= Len then
      PadR := S
    else begin
      O[0] := Chr(Len);
      Move(S[1], O[1], SLen);
      if SLen < 255 then
        FillChar(O[Succ(SLen)], Len-SLen, #32);
      PadR := O;
    end;
  end;

  function LTrim(const S: String): String;
  var
    I: Integer;
  begin
    I := 1;
    while (I < Length(S)) and (S[I] = ' ') do Inc(I);
    LTrim := Copy(S, I, 255);
  end;

  function RTrim(const S: String): String;
  var
    I: Integer;
  begin
    I := Length(S);
    while S[I] = ' ' do Dec(I);
    RTrim := Copy(S, 1, I);
  end;

  FUNCTION TrimB(const S : STRING) : STRING;
  BEGIN
      TrimB := LTrim(RTrim(S));
  END;

  FUNCTION FmtStr (STR, Fmt : STRING) : STRING;
  VAR
  TempStr : STRING;
  K, I, J : BYTE;
  Dollar, Percent : BOOLEAN;

  BEGIN

  TempStr := '';

      IF (POS (',', Fmt) > 0) THEN
      BEGIN
      Dollar  := POS ('$', Fmt) > 0;
      Percent := POS ('%', Fmt) > 0;
      FOR j := LENGTH (STR) DOWNTO 1 DO
          BEGIN
          i := rPos ('#', Fmt);
          Fmt [i] := STR [j];
          END;

      IF I > 1 THEN
      FOR j := i - 1 DOWNTO 1 DO fmt [j] := #32;

      Fmt := TrimB (Fmt);
      IF Dollar THEN Fmt := '$' + Fmt;
      IF Percent THEN Fmt := Fmt + '%';

      TempStr := Fmt;

      END ELSE
          BEGIN
          J := 0;
          FOR I := 1 TO LENGTH (Fmt) DO
          BEGIN
              IF NOT (Fmt [I] IN ['#', '!', '@', '*']) THEN
              BEGIN
                  TempStr [I] := Fmt [I] ;  {force any none format charcters into string}
                   J := SUCC (J);
              END
              ELSE    {format character}
              BEGIN
                  IF I - J <= LENGTH (STR) THEN
                     TempStr [I] := STR [I - J]
                  ELSE
                     TempStr [I] := ' ';    {pad with underlines}
              END;
          END;

          TempStr [0] := CHAR (LENGTH (Fmt) );  {set initial byte to string length}
          END;

      FmtStr := Tempstr;

  END;  {Func FmtStr}

  PROCEDURE Beep;
{ Generates a sound from the speaker to alert the user.  Useful
  for error handling routines. }
  BEGIN
  Sound(4000);
  Delay(30);
  Nosound;
  END;                    { Beep }

  FUNCTION GetKey (VAR Key : WORD) : BOOLEAN; assembler;
  { determine if key pressed and return it}
  asm
	  MOV	AH, 1
	  INT	16H
	  MOV	AL, 0
	  JE	@@1
	  XOR	AH, AH
	  INT	16H
	  LES	DI, Key
	  MOV	WORD PTR ES : [DI], AX
	  MOV	AL, 1
  @@1 :
  END;


  FUNCTION KeyHit : CHAR;

  VAR
      Char_in,
      WW      : WORD;

  BEGIN
  WHILE NOT GetKey(WW) DO
        BEGIN
        { here you could check for other stuff !! }
        END;
    Char_in := WW;
    { covert the word to our keys format }
    IF (LO (char_in) = 0) AND (HI (char_in) <> 0) THEN
          KeyHit := CHR ( HI (char_in) + 128 )
        ELSE
          KeyHit := CHR (LO (char_in) );
  END;


  FUNCTION KeysOK (VAR C : CHAR; CharType : InputTypes) : BOOLEAN;

  VAR Temp : BOOLEAN;

  BEGIN
    Temp := TRUE;
    CASE CharType OF
      Alphas : Temp := NOT (C IN [#00..#64]-[#32]);
      Ups    : C := UPCASE (C);
      Lows   : IF C IN ['A'..'Z'] THEN C := CHR (ORD (C) + 32);
      Nums   : Temp := (C IN ['0'..'9', '-']);
      Reals  : Temp := (C IN ['0'..'9', '-', '.']);
      Dates  : Temp := (C IN ['0'..'9', '/', '-']);
      Times  : Temp := (C IN ['0'..'9', ':', 'P', 'p', 'A', 'a', 'M', 'm']);
    END;
    KeysOK := Temp;
  END;

  FUNCTION MaxFieldLen (Fmt : STRING) : BYTE;
  VAR j, Len : BYTE;

  BEGIN
    Len := 0;
    FOR j := 1 TO LENGTH (Fmt) DO IF Fmt [j] = '#' THEN Len := SUCC (Len);
    MaxFieldLen := Len;
  END;

  PROCEDURE EditLine (VAR S : STRING;
                     Row, Col : BYTE;
                     LegalChars,
                     Term : CharSet;
                     InputAttr : BYTE;
                     FormatStr : STRING;
                     CharType : InputTypes;
                     VAR TC : CHAR);

  VAR
    SAttr,
    MaxP,
    Len,
    P, P1, P2, P3 : BYTE;
    IStr, SStr : STRING;
    Ch : CHAR;
    KeyStrokes : WORD;
    ForceEND : BOOLEAN;

  LABEL TOP;

    FUNCTION PosCursor (P0 : BYTE) : BYTE;
    BEGIN
      REPEAT
        P0 := SUCC (P0);
      UNTIL (FormatStr [P0] IN FmtChars) OR (P0 >= Len);
      PosCursor := P0;
    END;

    PROCEDURE WriteOutput;
    BEGIN
      { adjust they way p3 acts if long string edit }
      P3 := Max (1, P1 - MaxP + ORD (BOOLEAN (Len <> MaxP) ) );
      IStr := FmtStr (S, FormatStr);
      FastWrite (PadR (COPY (IStr, P3, MaxP), MaxP), Row, Col, InputAttr);
    END;

  BEGIN

    SAttr := TextAttr;
    SStr := S;
    TextAttr := InputAttr;

TOP :

    S          := SStr;
    KeyStrokes := 0;
    ForceEND   := FALSE;
    Ch         := #0;

    WHILE POS ('~', FormatStr) > 0 DO
      BEGIN
        ForceEND := TRUE;
        DELETE (FormatStr, POS ('~', FormatStr), 1);
        FormatStr := LTrim(RTrim (FormatStr));
      END;

    IF FormatStr = '' THEN FormatStr := COPY (GIS, 1, LENGTH (S) );

    Len := LENGTH (FormatStr);
    MaxP := Min (Len, PRED (LO (WindMax) ) );

    IStr := FmtStr (S, FormatStr);

    P1 := 0; { absolute position in string skipping over fmt chars }
    P  := 0; { relative position in string }
    P3 := 1;       { index ofset }

    IF ForceEND THEN
      BEGIN
        P := Min (LENGTH (S), Len);
        IStr := FmtStr (S, FormatStr);
        P1 := LENGTH (RTrim (IStr) ) + 1;
        WHILE (P1 < P) AND (FormatStr [P1] = IStr [P1]) DO P1 := SUCC (P1);
        Keystrokes := p1;
      END ELSE
          IF NOT (FormatStr [1] IN FmtChars) THEN
             P1 := PosCursor (0) ELSE P1 := 1;

    IF ForceEND THEN P2 := PosCursor (0) ELSE P2 := P1; { save P1 }

    WriteOutput;

    REPEAT

      GotoRC (Row, Min (Col + MaxP - 1, Col + P1 - 1) );

      Ch := Keyhit;

      INC (KeyStrokes);

      IF NOT (UPCASE (Ch) IN Term) THEN
         CASE Ch OF

   #128..#168,#224..#239,    { European characters }
   #32..#126 : IF (P1 <= Len) AND
                  (Ch IN LegalChars) AND (KeysOK (Ch, CharType) ) THEN
                 BEGIN

                   IF (KeyStrokes <= 1) THEN
                     BEGIN
                       FastWrite (PadR (' ', MaxP), Row, Col, InputAttr);
                       DELETE (S, 1, LENGTH (S) );
                     END;

                   IF LENGTH (S) = Len THEN DELETE (S, Len, 1);

                   P := SUCC (P);
                   INSERT (Ch, S, P);
                   P1 := PosCursor (P1);
                   WriteOutput;

                 END
               ELSE Beep;
          ^S, Left : IF P > 0 THEN
                          BEGIN
                            P := PRED (P);
                            REPEAT
                              P1 := PRED (P1);
                            UNTIL (FormatStr [P1] IN FmtChars) OR
                            (P1 = P2);
                            WriteOutput;
                          END;
          ^D, Right : IF P < LENGTH (S) THEN
                           BEGIN

                             P := SUCC (P);
                             P1 := PosCursor (P1);

                             WriteOutput;

                           END;
          ^A, Home : BEGIN
                          P := 0; P1 := P2; P3 := 1;
                          WriteOutput;
                        END;
          ^F, EndKey : BEGIN
                         P := Min (LENGTH (S), Len);
                         IStr := FmtStr (S, FormatStr);
                         P1 := LENGTH (RTrim (IStr) ) + 1;
                         WHILE (P1 < P) AND
                         (FormatStr [P1] = IStr [P1]) DO P1 := SUCC (P1);
                         WriteOutput;
                       END;
          ^G, Del : IF LENGTH (S) > 0 THEN
                         BEGIN
                           DELETE (S, P + 1, 1);
                           WriteOutput;
                         END;
          BackSp : IF P > 0 THEN
                        BEGIN
                          DELETE (S, P, 1);
                          P := PRED (P);
                          REPEAT
                            P1 := PRED (P1);
                          UNTIL (FormatStr [P1] IN FmtChars) OR
                          (P1 = P2);

                          WriteOutput;
                        END;
          ^R : IF NOT (Ch IN Term) THEN GOTO TOP;
          ^Y : BEGIN
                 P := 0; P1 := P2; P3 := 1;
                 DELETE (S, 1, LENGTH (S) );
                 WriteOutput;
               END;
        ELSE ;         { nothing }
        END;             {of case}

    UNTIL UPCASE (Ch) IN Term;

    WriteOutput;

    TC := UPCASE (Ch);
    TextAttr := SAttr;

  END;                { EditLine }

  PROCEDURE DefineExitSet (ExitSet : CharSet);
  BEGIN
    ExitOutSet := ExitSet;
  END;

  FUNCTION CheckToExit (TC : CHAR) : BOOLEAN;
  BEGIN
    CheckToExit := (TC IN ExitOutSet);
  END;

BEGIN
  FILLCHAR(GIS, SizeOF(GIS), #35);
  { point our fastwrite at the screen address for color or monochrome }
  ASM
      mov      BaseOfScreen,$B000
      mov      ax,$0F00
      int      $10
      cmp      al,2
      je       @XXX
      cmp      al,7
      je       @XXX
      mov      BaseOfScreen,$B800
  @XXX :
  end;
END.

{ here is the demo  !!! -------------   CUT --------------- }

{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V-,X+,Y+}
{$M 16384,0,655360}

USES Dos, Crt, FastEdit;

VAR
    Name,
    Date  : STRING;


BEGIN
   ClrScr;
   { demo standard input }
   FastWrite('Enter your name : ', 5, 5, 15);
   EditLine (Name, 5, 30, Printable, Term, 95, '################', ALPHAS, TC);

   { demo insert mode input  ..  use the tilde char in front of the format }
   FastWrite('Enter your name : ', 7, 5, 15);
   EditLine (Name, 7, 30, Printable, Term, 95, '~################', ALPHAS, TC);

   { demo formated mode input }
   FastWrite('Enter the date : ', 9, 5, 15);
   EditLine (Date, 9, 30, Printable, Term, 95, DateFormat, Dates, TC);

   GoToRC(20,1);
   WriteLn;
   WriteLn('Name : ',Name);
   WriteLn('Date : ',FmtStr(Date, DateFormat));
   Readkey;

END.


{ ------- UNIT KEYS , CUT HERE AND PASTE INTO NEW FILE (KEYS.PAS) ------- }

Unit Keys;

Interface

Const
  Home   = #199;      Up    = #200;     PgUp  = #201;
  Left   = #203;      Num5  = #204;     Right = #205;
  EndKey = #207;      Down  = #208;     PgDn  = #209;
  Ins    = #210;      Del   = #211;

  CtrlHome = #247;    CtrlUp   = #141;    CtrlPgUp  = #138;
  CtrlLeft = #243;    CtrlNum5 = #143;    CtrlRight = #244;
  CtrlEnd  = #245;    CtrlDown = #145;    CtrlPgDn  = #246;
  CtrlIns  = #146;    CtrlDel  = #147;

  BackSp  = #8;
  Tab     = #9;       STab    = #143;
  Enter   = #13;
  Esc     = #27;

  CtrlPrtScr = #242;

  CtrlA  = #1;     AltA  = #158;        Alt1 = #248;
  CtrlB  = #2;     AltB  = #176;        Alt2 = #249;
  CtrlC  = #3;     AltC  = #174;        Alt3 = #250;
  CtrlD  = #4;     AltD  = #160;        Alt4 = #251;
  CtrlE  = #5;     AltE  = #146;        Alt5 = #252;
  CtrlF  = #6;     AltF  = #161;        Alt6 = #253;
  CtrlG  = #7;     AltG  = #162;        Alt7 = #254;
  CtrlH  = #8;     AltH  = #163;        Alt8 = #255;
  CtrlI  = #9;     AltI  = #151;        Alt9 = #134;
  CtrlJ  = #10;    AltJ  = #164;        Alt0 = #135;
  CtrlK  = #11;    AltK  = #165;        AltMinus  = #136;
  CtrlL  = #12;    AltL  = #166;        AltEquals = #137;
  CtrlM  = #13;    AltM  = #178;
  CtrlN  = #14;    AltN  = #177;
  CtrlO  = #15;    AltO  = #152;
  CtrlP  = #16;    AltP  = #153;
  CtrlQ  = #17;    AltQ  = #144;
  CtrlR  = #18;    AltR  = #147;
  CtrlS  = #19;    AltS  = #159;
  CtrlT  = #20;    AltT  = #148;
  CtrlU  = #21;    AltU  = #150;
  CtrlV  = #22;    AltV  = #175;
  CtrlW  = #23;    AltW  = #145;
  CtrlX  = #24;    AltX  = #173;
  CtrlY  = #25;    AltY  = #149;
  CtrlZ  = #26;    AltZ  = #172;

  F1  = #187;      sF1  = #212;      CtrlF1  = #222;      AltF1  = #232;
  F2  = #188;      sF2  = #213;      CtrlF2  = #223;      AltF2  = #233;
  F3  = #189;      sF3  = #214;      CtrlF3  = #224;      AltF3  = #234;
  F4  = #190;      sF4  = #215;      CtrlF4  = #225;      AltF4  = #235;
  F5  = #191;      sF5  = #216;      CtrlF5  = #226;      AltF5  = #236;
  F6  = #192;      sF6  = #217;      CtrlF6  = #227;      AltF6  = #237;
  F7  = #193;      sF7  = #218;      CtrlF7  = #228;      AltF7  = #238;
  F8  = #194;      sF8  = #219;      CtrlF8  = #229;      AltF8  = #239;
  F9  = #195;      sF9  = #220;      CtrlF9  = #230;      AltF9  = #240;
  F10 = #196;      sF10 = #221;      CtrlF10 = #231;      AltF10 = #241;
  F11 = #139;      sF11 = #141;      CtrlF11 = #154;      AltF11 = #156;
  F12 = #140;      sF12 = #142;      CtrlF12 = #155;      AltF12 = #157;

Implementation

End.
