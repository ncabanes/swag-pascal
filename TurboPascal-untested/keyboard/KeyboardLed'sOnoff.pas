(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0114.PAS
  Description: Keyboard LED's On/Off
  Author: SALVATORE MESCHINI
  Date: 08-30-96  09:35
*)


Unit LED;

{This unit is FREE, use it and COPY it...Good PASCAL programming!}

{The author: Salvatore Meschini
             E-MAIL : smeschini@ermes.it
             WWW : http://www.ermes.it/pws/mesk
             Version 1.0 30/06/1996 - Please report ANY bugs/suggestions/...}

{$G+}

 Interface

 Procedure Caps(ONorOFF:boolean);
 Procedure NumLock(ONorOFF:boolean);
 Procedure ScrLock(ONorOFF:boolean);

 Implementation

 Procedure Caps(ONorOFF:boolean);Assembler;

    asm
    cmp ONorOFF,1       {Do you want CAPS ON?}
    je @BeLight         {If yes ...}
    jmp @BeDarkness     {Else...}
    @BeLight:
     MOV SI,40h
     MOV ES,SI
     MOV AL,ES:[0017h]
     OR  AL,40h
     MOV ES,SI
     MOV ES:[0017h],AL
     jmp @FINISH
    @BeDarkness:
     MOV SI,40h
     MOV ES,SI
     MOV AL,ES:[0017h]
     AND AL,0BFh
     MOV ES,SI
     MOV ES:[0017h],AL
    @FINISH:
    end;

  Procedure NumLock(ONorOFF:Boolean);Assembler;
    asm
    cmp ONorOFF,1
    je @BeLight
    jmp @BeDarkness
    @BeLight:
     MOV SI,40h
     MOV ES,SI
     MOV AL,ES:[0017h]
     OR  AL,20h
     MOV ES,SI
     MOV ES:[0017h],AL
     jmp @FINISH
    @BeDarkness:
     MOV SI,40h
     MOV ES,SI
     MOV AL,ES:[0017h]
     AND AL,0DFh
     MOV ES,SI
     MOV ES:[0017h],AL
    @FINISH:
    end;

  Procedure ScrLock(ONorOFF:Boolean);Assembler;
    asm
    cmp ONorOFF,1
    je @BeLight
    jmp @BeDarkness
    @BeLight:
     MOV SI,40h
     MOV ES,SI
     MOV AL,ES:[0017h]
     OR  AL,10h
     MOV ES,SI
     MOV ES:[0017h],AL
     jmp @FINISH
    @BeDarkness:
     MOV SI,40h
     MOV ES,SI
     MOV AL,ES:[0017h]
     AND AL,0EFh
     MOV ES,SI
     MOV ES:[0017h],AL
    @FINISH:
    end;
END.





