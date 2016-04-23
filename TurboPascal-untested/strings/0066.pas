{$O-}
UNIT Strings;
INTERFACE

  FUNCTION Dupe(C : Char; Len : Byte) : String;
  FUNCTION ADupe(C : Char; Len : Byte) : String;
  FUNCTION Pad(S : String; C : Char;
                           Len : Byte) : String;
  FUNCTION APad(S : String; C : Char;
                            Len : Byte) : String;
  FUNCTION LeftPad(S : String; C : Char;
                               Len : Byte) : String;
  FUNCTION ALeftPad(S : String; C : Char;
                                Len : Byte) : String;
  FUNCTION Chop(S : String; len: Byte): String;
  FUNCTION AChop(S : String; len: Byte): String;
  FUNCTION LeftChop(S : String; len: Byte): String;
  FUNCTION ALeftChop(S : String; len: Byte): String;
  PROCEDURE Trim(VAR S : String; C : Char);
  PROCEDURE TrimLead(VAR S : String; C : Char);

IMPLEMENTATION

  FUNCTION Dupe(C : Char; Len : Byte) : String;
  VAR Temp : String;
  BEGIN
    FillChar(Temp[1], Len, C);
    Temp[0] := Char(Len);
    Dupe := Temp;
  END;

  FUNCTION ADupe(C : Char;
                 Len : Byte) : String; Assembler;
  ASM
    LES DI, @Result
    CLD
    XOR CH, CH
    MOV CL, Len       {length in CX}
    MOV AX, CX        {and in AX}
    STOSB             {store length byte}
    MOV AL, C
    REP STOSB         {fill string with char}
  END;

  FUNCTION Pad(S : String; C : Char; Len : Byte) : String;
  BEGIN
    IF length(S) < len THEN
      FillChar(S[succ(length(S))], Len-length(S), C);
    S[0] := char(Len);
    Pad := S;
  END;

  FUNCTION APad(S : String; C : Char;
                Len : Byte) : String; Assembler;
  ASM
    PUSH DS
    LDS SI, S        {DS:SI points to S}
    LES DI, @Result  {ES:DI points to result}
    LODSB            {read existing length}
    XOR AH, AH
    MOV CX, AX
    MOV AL, Len      {Set result to desired length}
    STOSB            {Transfer length to result}
    MOV BX, CX
    REP MOVSB        {Now S is in @Result}
    XOR CH, CH
    MOV CL, Len      {Get desired length in CX}
    SUB CX, BX       {Subtract current length}
    JLE @NoPad       {If difference < 0, no pad}
      MOV AL, C      {Put char in AL}
      REP STOSB      {Fill rest of string}
    @NoPad:
    POP DS
  END;

  FUNCTION LeftPad(S : String; C : Char;
                               Len : Byte) : String;
  BEGIN
    IF length(S) < Len THEN
      BEGIN
        MOVE(S[1], S[succ(Len - length(S))], length(S));
        FillChar(S[1], Len - length(S), C);
      END;
    S[0] := Char(Len);
    LeftPad := S;
  END;

  FUNCTION ALeftPad(S : String; C : Char;
                    Len : Byte) : String; Assembler;
  ASM
    PUSH DS
    CLD
    LES DI, @Result  {ES:DI points to result}
    MOV AL, Len
    XOR AH, AH
    MOV CX, AX       {Desired length in CX}
    STOSB            {length byte of result}
    LDS SI, S        {DS:SI points to S}
    LODSB            {AL has length of S}
    MOV BL, AL       {remember length of S}
    SUB CX, AX       {subtract actual from desired}
    JLE @NoPad       {if diff < 0, don't pad}
      MOV AL, C      {fill at start of string}
      REP STOSB
    @NoPad:
    MOV CL, BL       {get back length of S}
    REP MOVSB        {copy rest of S}
    POP DS
  END;

  FUNCTION Chop(S : String; len : Byte): String;
  BEGIN
    IF length(S) > len THEN
      S[0] := Char(Len);
    Chop := S;
  END;

  FUNCTION AChop(S : String;
                 len: Byte): String; Assembler;
  ASM
    PUSH DS
    LDS SI, S
    LES DI, @Result
    LODSB
    XOR AH, AH
    XCHG AX, CX
    CMP CL, Len       {if length > len,...}
    JB @NoChop
      MOV CL, Len     {... set length to len}
    @NoCHop:
    MOV AL, CL        {store length}
    STOSB
    REP MOVSB         {copy Len chars to result}
    POP DS
  END;

  FUNCTION LeftChop(S : String; len: Byte): String;
  BEGIN
    IF length(S) > len THEN
      BEGIN
        MOVE(S[succ(length(S) - len)],
             S[1], Len);
        S[0] := Char(Len);
      END;
    LeftChop := S;
  END;

  FUNCTION ALeftChop(S : String;
                 len: Byte): String; Assembler;
  ASM
    PUSH DS
    LDS SI, S
    LES DI, @Result
    LODSB
    XOR AH, AH
    XCHG AX, CX
    CMP CL, Len       {if length > len,...}
    JB @NoChop
      ADD SI, CX      {point to end of string}
      MOV CL, Len     {set length to len}
      SUB SI, CX      {point to new start of string}
    @NoCHop:
    MOV AL, CL        {store length}
    STOSB
    REP MOVSB         {copy Len chars to result}
    POP DS
  END;

  PROCEDURE Trim(VAR S : String; C : Char);
  BEGIN
    WHILE S[length(S)] = C DO Dec(S[0]);
  END;

  PROCEDURE TrimLead(VAR S : String; C : Char);
  VAR P : Byte;
  BEGIN
    P := 1;
    WHILE (S[P] = C) AND (P <= length(S)) DO Inc(P);
    CASE P OF
      0 : S[0] := #0; {string was 255 of C!}
      1 : ; {not found}
      ELSE
        Move(S[P], S[1], succ(length(S) - P));
        Dec(S[0], pred(P));
    END;
  END;

END.