{
In SWAG9408, Jose Campione provided TXLATE5, a fast case conversion
procedure.  In response to the included request for suggestions and
improvements, please find attached my uppercase translation procedure,
which although very similar, is approx 10-15% faster.  This is
primarily achieved by using DEC CX and JNZ @Dest instead of LOOP @Dest
in the conversion loop (much faster on 386/486's).

Feel free to include the source code in the next SWAG release if you
wish to.

====================================================================
}
UNIT XLAT;

{$S-}

INTERFACE

VAR
  Upper : ARRAY[Char] OF Char; {Uppercase Translation Table}
{
This case translation table is initialised according to the country  
code information specified in the CONFIG.SYS file (DOS 4.0+).      
For older DOS versions, the standard character translations are used.

The 'Upper' array may also be accessed directly, eg: Ch := Upper['x']. 
This is the fastest possible replacement for the Upcase() function. 
}
  PROCEDURE MakeUppercase(VAR S : String);

IMPLEMENTATION

  PROCEDURE MakeUppercase(VAR S : String); ASSEMBLER;
  ASM
    LES   DI,S
    MOV   CL,ES:[DI]
    AND   CX,00FFh
    JZ    @@Done
    MOV   BX,Offset Upper
  @@Loop:
    INC   DI
    MOV   AL,ES:[DI]
    XLAT
    MOV   ES:[DI],AL
    DEC   CX
    JNZ   @@Loop
  @@Done:
  END;

{-Non Interfaced Routines (Initialise translation table)------------}

  FUNCTION DosMajorVersion : Byte;
    {-Return DOS Major Version Number}
  INLINE(
    $B4/$30/  {mov ah,$30}
    $CD/$21); {int $21}

  PROCEDURE SetCountrySpecificUppercase;
    {-Convert 'Upper' into its country specific uppercase equivalent}
  INLINE(
    $BA/>Upper/ {mov dx,Upper}
    $B9/>256/   {mov cx,256}
    $B8/>$6521/ {mov ax,$6521}
    $CD/$21);   {int $21}

  PROCEDURE InitialiseCaseConversion;
  VAR
    C : Char;
  BEGIN
    FOR C := #0 TO #255 DO
      Upper[C] := C;
    IF DosMajorVersion < 4 THEN
      FOR C := #0 TO #255 DO
        Upper[C] := System.UpCase(C) {Use Standard Case Conversion}
    ELSE
      SetCountrySpecificUppercase; {Use International Case Conversion}
  END; {InitialiseCaseConversion}

{=Unit Initialisation==============================================}

BEGIN
  InitialiseCaseConversion;
END.
