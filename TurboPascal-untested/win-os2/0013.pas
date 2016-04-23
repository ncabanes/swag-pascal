{
Rebooting in itself is rather easy to do...call the right interrupt with
the right values and you go it--most of the time.  I'd noticed that any
reboot I tried to do from my program under windows would fail.  I'm not a
windows programmer and seldom use it, but I do have one program that needs
to be able to call this routine under certain conditions.  A clean reboot
is favored to a lock up or data corruption.  I searched for pascal source
to work under win, but found none.  I finally ran into a short .com file
which did in fact work.  I ran the code through a .com to pas inline
conversion utility and ended up with pages of ugly code.  I finally got
around to converting it into inline assembly code which shortened things up
substantially (10 pages or so-the inline tranlsation was bad, loops were
iterative/non existant).  I then killed the code not necessary for pascal,
and this is what I ended up with:
}

UNIT BOOTSYS;
(* Unit for unconditional reboot (TESTED UNDER DOS 5/6 & WIN 3.0/3.1) *)
(* (C) Copyright 1993 Frank Young, all rights reserved *)
INTERFACE
 
PROCEDURE REBOOT;

IMPLEMENTATION
Procedure Reboot; Assembler;
ASM
  MOV AX,CS
  MOV DS,AX
  MOV ES,AX
  MOV SS,AX
  MOV SP,030Dh
  MOV BYTE PTR [00FFh],00
@LOOP1:
  CALL @LOOP3
  MOV AH,4Ch
  INT 21h
  JMP @LOOP1
  MOV CX,250
@LOOP2:
  ADD [BX+SI],AL
  LOOP @LOOP2
  ADD DL,BH
@LOOP3:
  MOV AX,0040h
  MOV DS,AX
  MOV BX,0072h
  MOV WORD PTR [BX],1234h
@LOOP4:
  IN AL,64h
  TEST AL,02h
  JNZ @LOOP4
  MOV AL,0D1h
  OUT 64,AL
  XOR AL,AL
  OUT 64,AL
  STI
  MOV CX,0003h
@LOOP5:
  MOV AX,[$006C]
@LOOP6:
  CMP AX,[$006C]
  JZ @LOOP6
LOOP @LOOP5
  CLI
  IN AL,60h
  XOR AX,AX
  MOV DS,AX
  MOV ES,AX
  MOV SS,AX
  MOV SP,AX
  MOV AX,0062h
  CLI
  PUSH AX
  MOV AX,$F000
  PUSH AX
  MOV AX,$FFF0
  PUSH AX
  XOR AX,AX
  IRET
end;
 
end.
