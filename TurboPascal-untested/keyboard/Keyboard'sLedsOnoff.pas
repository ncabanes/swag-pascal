(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0120.PAS
  Description: Keyboard's LEDs ON/OFF
  Author: SALVATORE MESCHINI
  Date: 05-30-97  18:17
*)


Unit LED;

{The author: Salvatore Meschini
             E-MAIL : smeschini@ermes.it
             WWW : http://www.ermes.it/pws/mesk
             Version 1.1 }

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
     MOV AH,1
     INT 16h
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
     MOV AH,1
     INT 16h
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
     MOV AH,1
     INT 16h
    end;
END.

(* -------------------------- DEMO ---------------------------- *)

USES LED;

{Make your own light effects!!!}

var i:byte;

(* The following procedure isn't affected by hardware! *)
procedure Wait(Ticks: Word); assembler; (* 18 Ticks = 1 second *)
ASM
 mov CX,Ticks
 @Attendi:
  push AX
  push ES
  mov AX,0000
  mov ES,AX
  mov AX,ES:[046Ch]
  @Lab1:
  cmp AX,ES:[046Ch]
  je @Lab1
  pop ES
  pop AX
  loop @Attendi
END;

function KeyPressed: Boolean;
  
  var
    Premuto: Byte;

  begin
    Inline(
      $B4/$0B/               {    MOV AH,+$0B         }
      $CD/$21/               {    INT $21             }
      $88/$86/>Premuto);     {    MOV >Premuto[BP],AL }
    KeyPressed := (Premuto = $FF);
  end;

begin
repeat
      NumLock(TRUE);
       wait(1);
      NumLock(FALSE);
      Caps(TRUE);
       wait(1);
      Caps(FALSE);
      ScrLock(True);
       wait(1);
      Scrlock(false);
      Caps(TRUE);
       wait(1);
      Caps(FALSE);
until keypressed;
end.




