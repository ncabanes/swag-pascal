(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0117.PAS
  Description: Fast Case Translations
  Author: JOHN O'HARROW
  Date: 09-04-95  11:04
*)

{
   ╔══════════════════════════════ X L A T ══════════════════════════════╗
   ║                                                                     ║
   ║      Case Translation Routines for Turbo/Borland Pascal Strings     ║
   ║                                                                     ║
   ║                            Version 2.00                             ║
   ║                                                                     ║
   ║  Copyright (c) 1995, John O'Harrow F.I.A.P. - All Rights Reserved   ║
   ║                   EMAIL john.oharrow@paradise.org                   ║
   ║                                                                     ║
   ║  This unit provides a library of very highly optimised routines     ║
   ║     for the translation of strings into upper/lower case etc.       ║
   ║                                                                     ║
   ╚═════════════════════════════════════════════════════════════════════╝
}

UNIT XLAT;

{================================}INTERFACE{================================}

VAR
  Upper, Lower : ARRAY[Char] OF Char;

  {These case translation tables are initialised according to the }
  {country code information as specified in CONFIG.SYS (DOS 4.0+).}
  {For older DOS versions, the standard case conversion is used.  }
  {These tables may also be accessed directly using, for example, }
  {ResultChar := Upper['x'].  This provides the fastest possible  }
  {replacement for the standard pascal Upcase() function.         }

{-String Case Conversion Procedures-----------------------------------------}

  PROCEDURE MakeUppercase(VAR S : String);
  PROCEDURE MakeLowercase(VAR S : String);

  {These procedures should be used in preference to the equivalent}
  {functions below where speed is important (approx 30% faster).  }

{-String Case Conversion Functions------------------------------------------}

  FUNCTION  Uppercase(CONST S : String) : String;
  FUNCTION  Lowercase(CONST S : String) : String;

{-General Purpose String Translation Procedure - For ASCII/EBCDIC etc.------}

  PROCEDURE Translate(VAR S : String; VAR Table);

{-Inline Macro Conversion Functions-----------------------------------------}

  {Exceptionally Fast but Memory Wasteful Inline Translation Procedure}
  {(10% Faster than Translate but with overhead of 75 Bytes per Call).}
  {**** If anyone knows of a faster procedure, please let me know ****}

  PROCEDURE TranslateFast(VAR S : String; VAR Table);
  INLINE
    ($8C/$DE/         {MOV  SI,DS       }
     $5B/$1F/         {POP  BX,DS       }
     $5F/$07/         {POP  DI,ES       }
     $26/$8A/$0D/     {MOV  CL,ES:[DI]  }
     $81/$E1/$FF/$00/ {AND  CX,00FFh    }
     $74/$33/         {JZ   @@Done      }
     $47/             {INC  DI          }
     $F7/$C7/$01/$00/ {TEST  DI,1       }
     $74/$09/         {JZ    @@Even     }
     $26/$8A/$05/     {MOV   AL,ES:[DI] }
     $D7/             {XLAT             }
     $26/$88/$05/     {MOV   ES:[DI],AL }
     $47/             {INC   DI         }
     $49/             {DEC   CX         }
                      {@@Even:          }
     $D1/$E9/         {SHR   CX,1       }
     $74/$16/         {JZ    @@Last     }
     $9C/             {PUSHF            }
                      {@@Loop:          }
     $26/$8B/$05/     {MOV   AX,ES:[DI] }
     $D7/             {XLAT             }
     $88/$C2/         {MOV   DL,AL      }
     $88/$E0/         {MOV   AL,AH      }
     $D7/             {XLAT             }
     $88/$C6/         {MOV   DH,AL      }
     $26/$89/$15/     {MOV   ES:[DI],DX }
     $83/$C7/$02/     {ADD   DI,2       }
     $49/             {DEC   CX         }
     $7F/$EC/         {JNZ   @@Loop     }
     $9D/             {POPF             }
                      {@@Last:          }
     $73/$07/         {JNC   @@Done     }
     $26/$8A/$05/     {MOV   AL,ES:[DI] }
     $D7/             {XLAT             }
     $26/$88/$05/     {MOV   ES:[DI],AL }
                      {@@Done           }
     $8E/$DE);        {MOV  DS,SI       }

{=============================}IMPLEMENTATION{==============================}

{$S-} {Disable Stack Checking to Increase Speed and Reduce Size}

  PROCEDURE MakeUppercase(VAR S : String); ASSEMBLER;
  ASM
    LES   DI,S               {ES:DI => S}
    MOV   CL,ES:[DI]         {Get Length(S)}
    AND   CX,00FFh           {CX = Length(S), ZF Set if Null String}
    JZ    @@Done             {Finished if S is a Null String}
    MOV   BX,OFFSET Upper    {DS:BX => Translation Table}
    INC   DI                 {ES:DI => S[1]}
    TEST  DI,1               {Is ES:DI on a Word Boundary?}
    JZ    @@Even             {Yes - Ok}
    MOV   AL,ES:[DI]         {No  - Translate 1st Char}
    XLAT
    MOV   ES:[DI],AL
    INC   DI
    DEC   CX
  @@Even:                    {ES:DI now Alligned on a Word Boundary}
    SHR   CX,1               {CX = Characters Pairs to Translate}
    JZ    @@Last             {Skip if no Character Pairs}
    PUSHF                    {Save Carry Flag - Set of Odd Char Left}
  @@Loop:
    MOV   AX,ES:[DI]         {Translate Next 2 Characters}
    XLAT
    MOV   DL,AL
    MOV   AL,AH
    XLAT
    MOV   DH,AL
    MOV   ES:[DI],DX
    ADD   DI,2
    DEC   CX
    JNZ   @@Loop             {Repeat for each Pair of Chars}
    POPF                     {Restore Carry Flag}
  @@Last:
    JNC   @@Done             {Finished if No Odd Char to Translate}
    MOV   AL,ES:[DI]         {Translate Last Char}
    XLAT
    MOV   ES:[DI],AL
  @@Done:
  END; {MakeUppercase}

  PROCEDURE MakeLowercase(VAR S : String); ASSEMBLER;
  ASM
    LES   DI,S               {ES:DI => S}
    MOV   CL,ES:[DI]         {Get Length(S)}
    AND   CX,00FFh           {CX = Length(S), ZF Set if Null String}
    JZ    @@Done             {Finished if S is a Null String}
    MOV   BX,OFFSET Lower    {DS:BX => Translation Table}
    INC   DI                 {ES:DI => S[1]}
    TEST  DI,1               {Is ES:DI on a Word Boundary?}
    JZ    @@Even             {Yes - Ok}
    MOV   AL,ES:[DI]         {No  - Translate 1st Char}
    XLAT
    MOV   ES:[DI],AL
    INC   DI
    DEC   CX
  @@Even:                    {ES:DI now Alligned on a Word Boundary}
    SHR   CX,1               {CX = Characters Pairs to Translate}
    JZ    @@Last             {Skip if no Character Pairs}
    PUSHF                    {Save Carry Flag - Set of Odd Char Left}
  @@Loop:
    MOV   AX,ES:[DI]         {Translate Next 2 Characters}
    XLAT
    MOV   DL,AL
    MOV   AL,AH
    XLAT
    MOV   DH,AL
    MOV   ES:[DI],DX
    ADD   DI,2
    DEC   CX
    JNZ   @@Loop             {Repeat for each Pair of Chars}
    POPF                     {Restore Carry Flag}
  @@Last:
    JNC   @@Done             {Finished if No Odd Char to Translate}
    MOV   AL,ES:[DI]         {Translate Last Char}
    XLAT
    MOV   ES:[DI],AL
  @@Done:
  END; {MakeLowercase}

  FUNCTION Uppercase(CONST S : String) : String; ASSEMBLER;
  ASM
    LES   SI,@Result         {SS:SI => Result}
    LES   DI,S               {ES:DI => S}
    MOV   CL,ES:[DI]         {Get Length(S)}
    MOV   SS:[SI],CL
    AND   CX,00FFh           {CX = Length(S), ZF Set if Null String}
    JZ    @@Done             {Finished if S is a Null String}
    MOV   BX,OFFSET Upper    {DS:BX => Translation Table}
    INC   DI                 {ES:DI => S[1]}
    INC   SI
    TEST  DI,1               {Is ES:DI on a Word Boundary?}
    JZ    @@Even             {Yes - Ok}
    MOV   AL,ES:[DI]         {No  - Translate 1st Char}
    XLAT
    MOV   SS:[SI],AL
    INC   DI
    INC   SI
    DEC   CX
  @@Even:                    {ES:DI now Alligned on a Word Boundary}
    SHR   CX,1               {CX = Characters Pairs to Translate}
    JZ    @@Last             {Skip if no Character Pairs}
    PUSHF                    {Save Carry Flag - Set of Odd Char Left}
  @@Loop:
    MOV   AX,ES:[DI]         {Translate Next 2 Characters}
    XLAT
    MOV   DL,AL
    MOV   AL,AH
    XLAT
    MOV   DH,AL
    MOV   SS:[SI],DX
    ADD   DI,2
    ADD   SI,2
    DEC   CX
    JNZ   @@Loop             {Repeat for each Pair of Chars}
    POPF                     {Restore Carry Flag}
  @@Last:
    JNC   @@Done             {Finished if No Odd Char to Translate}
    MOV   AL,ES:[DI]         {Translate Last Char}
    XLAT
    MOV   SS:[SI],AL
  @@Done:
  END; {Uppercase}

  FUNCTION Lowercase(CONST S : String) : String; ASSEMBLER;
  ASM
    LES   SI,@Result         {SS:SI => Result}
    LES   DI,S               {ES:DI => S}
    MOV   CL,ES:[DI]         {Get Length(S)}
    MOV   SS:[SI],CL
    AND   CX,00FFh           {CX = Length(S), ZF Set if Null String}
    JZ    @@Done             {Finished if S is a Null String}
    MOV   BX,OFFSET Upper    {DS:BX => Translation Table}
    INC   DI                 {ES:DI => S[1]}
    INC   SI
    TEST  DI,1               {Is ES:DI on a Word Boundary?}
    JZ    @@Even             {Yes - Ok}
    MOV   AL,ES:[DI]         {No  - Translate 1st Char}
    XLAT
    MOV   SS:[SI],AL
    INC   DI
    INC   SI
    DEC   CX
  @@Even:                    {ES:DI now Alligned on a Word Boundary}
    SHR   CX,1               {CX = Characters Pairs to Translate}
    JZ    @@Last             {Skip if no Character Pairs}
    PUSHF                    {Save Carry Flag - Set of Odd Char Left}
  @@Loop:
    MOV   AX,ES:[DI]         {Translate Next 2 Characters}
    XLAT
    MOV   DL,AL
    MOV   AL,AH
    XLAT
    MOV   DH,AL
    MOV   SS:[SI],DX
    ADD   DI,2
    ADD   SI,2
    DEC   CX
    JNZ   @@Loop             {Repeat for each Pair of Chars}
    POPF                     {Restore Carry Flag}
  @@Last:
    JNC   @@Done             {Finished if No Odd Char to Translate}
    MOV   AL,ES:[DI]         {Translate Last Char}
    XLAT
    MOV   SS:[SI],AL
  @@Done:
  END; {Lowercase}

  PROCEDURE Translate(VAR S : String; VAR Table); ASSEMBLER;
  ASM
    LES   DI,S        {ES:DI => S}
    MOV   CL,ES:[DI]  {Get Length(S)}
    AND   CX,00FFh    {CX = Length(S), ZF Set if Null String}
    JZ    @@Finish    {Finished if S is a Null String}
    MOV   SI,DS       {Save DS}
    LDS   BX,Table    {DS:BX => Translation Table}
    INC   DI          {ES:DI => S[1]}
    TEST  DI,1        {Is ES:DI on a Word Boundary?}
    JZ    @@Even      {Yes - Ok}
    MOV   AL,ES:[DI]  {No  - Translate 1st Char}
    XLAT
    MOV   ES:[DI],AL
    INC   DI
    DEC   CX
  @@Even:             {ES:DI now Alligned on a Word Boundary}
    SHR   CX,1        {CX = Characters Pairs to Translate}
    JZ    @@Last      {Skip if no Character Pairs}
    PUSHF             {Save Carry Flag - Set of Odd Char Left}
  @@Loop:
    MOV   AX,ES:[DI]  {Translate Next 2 Characters}
    XLAT
    MOV   DL,AL
    MOV   AL,AH
    XLAT
    MOV   DH,AL
    MOV   ES:[DI],DX
    ADD   DI,2
    DEC   CX
    JNZ   @@Loop      {Repeat for each Pair of Chars}
    POPF              {Restore Carry Flag}
  @@Last:
    JNC   @@Done      {Finished if No Odd Char to Translate}
    MOV   AL,ES:[DI]  {Translate Last Char}
    XLAT
    MOV   ES:[DI],AL
  @@Done:
    MOV   DS,SI       {Restore Saved DS}
  @@Finish:
  END; {Translate}

{=Non Interfaced Routines (Used in Unit Initialisation)=====================}

  FUNCTION DosMajorVersion : Byte;
    {-Return DOS Major Version Number}
  INLINE(
    $B4/$30/    {mov ah,$30}
    $CD/$21);   {int $21}

  PROCEDURE SetCountrySpecificUppercase;
    {-Translate 'Upper' into its country specific uppercase equivalent}
  INLINE(
    $BA/>Upper/ {mov dx,Upper}
    $B9/>256/   {mov cx,256}
    $B8/>$6521/ {mov ax,$6521}
    $CD/$21);   {int $21}

  PROCEDURE InitialiseCaseConversion;
  VAR
    C : Char;
  BEGIN
    ASM
      MOV SI,Offset Upper
      MOV DI,Offset Lower
      XOR BX,BX
    @@Loop:
      MOV [SI+BX],BL
      MOV [DI+BX],BL
      INC BL
      JNZ @@Loop
    END;
    IF DosMajorVersion < 4 THEN
      FOR C := #0 TO #255 DO
        Upper[C] := System.UpCase(C) {Use Standard Case Conversion}
    ELSE
      SetCountrySpecificUppercase; {Use International Case Conversion}
    FOR C := #255 DOWNTO #0 DO
      IF C <> Upper[C] THEN {Set Lowercase conversion Table from Uppercase}
        Lower[Upper[C]] := C;
  END; {InitialiseCaseConversion}

{=Unit Initialisation=======================================================}

BEGIN
  InitialiseCaseConversion;
END.

