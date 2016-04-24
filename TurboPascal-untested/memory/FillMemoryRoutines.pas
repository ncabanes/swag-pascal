(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0035.PAS
  Description: FILL Memory Routines
  Author: SWAG SUPPORT TEAM
  Date: 11-21-93  09:30
*)

UNIT Fill;
(**) INTERFACE (**)
  PROCEDURE FillWord(VAR Dest; Count, What : Word);
  PROCEDURE FillOthr(VAR Dest; Count : Word; What : Byte);
  PROCEDURE FillPatt(VAR Dest, Patt; Count, Siz : Word);
  PROCEDURE FillPattOthr(VAR Dest, Patt; Count,
              Siz : Word);

(**) IMPLEMENTATION (**)
  PROCEDURE FillWord(VAR Dest; Count, What : Word);
              Assembler;
  ASM
    LES DI, Dest    {ES:DI points to destination}
    MOV CX, Count   {count in CX}
    MOV AX, What    {word to fill with in AX}
    CLD             {forward direction}
    REP STOSW       {perform the fill}
  END;

  PROCEDURE FillOthr(VAR Dest; Count : Word; What : Byte);
              Assembler;
  ASM
    LES DI, Dest    {ES:DI points to destination}
    MOV CX, Count   {count in CX}
    MOV AL, What    {byte to fill with in AL}
    CLD             {forward direction}
    @TheLoop:
    STOSB           {store one byte}
    INC DI          {skip one byte}
    Loop @TheLoop
  END;

  PROCEDURE FillPatt(VAR Dest, Patt; Count, Siz : Word);
              Assembler;
  ASM
    MOV CX, Siz
    JCXZ @Out
    XCHG CX, DX     {size of pattern in DX}
    MOV CX, Count   {count in CX}
    JCXZ @Out
    PUSH DS
    LES DI, Dest    {ES:DI points to destination}
    LDS SI, Patt    {DS:SI points to pattern}
    MOV BX, SI      {save SI in BX}
    CLD             {forward direction}
    @PatLoop:
      PUSH CX         {save count for outer loop}
      MOV CX, DX      {put inner count in CX}
      MOV SI, BX      {DS:SI points to source}
      REP MOVSB       {make one copy of pattern}
      POP CX          {restore count for outer loop}
    LOOP @PatLoop
    POP DS
    @Out:
  END;

  PROCEDURE FillPattOthr(VAR Dest, Patt; Count,
              Siz : Word); Assembler;
  ASM
    MOV CX, Siz
    JCXZ @Out
    XCHG CX, DX     {size of pattern in DX}
    MOV CX, Count   {count in CX}
    JCXZ @Out
    PUSH DS
    LES DI, Dest    {ES:DI points to destination}
    LDS SI, Patt    {DS:SI points to pattern}
    MOV BX, SI      {save SI in BX}
    CLD             {forward direction}
    @PatLoop:
      PUSH CX         {save count for outer loop}
      MOV CX, DX      {put inner count in CX}
      MOV SI, BX      {DS:SI points to source}
      @TheLoop:
        LODSB         {get a byte from pattern..}
        STOSB         {.. and store in destination}
        INC DI        {skip a byte}
      LOOP @TheLoop
      POP CX          {restore count for outer loop}
    LOOP @PatLoop
    POP DS
    @Out:
  END;

END.
