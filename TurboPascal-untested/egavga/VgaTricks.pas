(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0036.PAS
  Description: VGA Tricks
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
Sorry it took so long - anyway here's a new batch of VGA TRICKS :
First there's your basic equipment - synchronizing with
the vertical Crt retrace.
( You can use this For hardware VGA scrolling synchronisation too, just
substitute the Delay(14) in my old routine For a call to this
Procedure.)
}

Procedure VRET;Assembler; {works For CGA,EGA and VGA cards}
Asm
  MOV  DX, $03DA
  MOV  AH, 8
@Wau: in   AL, DX
  TEST AL, AH
  JNZ  @Wau     { wait Until out of retrace }
@Wai: in   AL, DX
  TEST AL, AH
  JZ   @Wai     { wait Until inside retrace }
end

{
The following is Really new, as Far as I know: breaking the color
barrier by displaying more than 64 different colors on a Text mode
screen. (But it will work For Text and Graphics color modes.)
It displays the effect For approximately SEC seconds, affecting
the black background and any black Characters. note that if
you have the border set to black too, the bars will expand into it.
}

Procedure ColorBars(Sec:Byte);Assembler;
Asm
  MOV AL,Sec
  MOV AH,70      { assume a 70 Hz mode (= 400 lines like mode 3 or $13)}
  MUL AH
  MOV CX,AX
  MOV DX,$03DA
  in AL,DX
  MOV DX,$03C0   { assume color nr 0 = default Text background.. }
  MOV AL,$20+0   { set color nr 0 .. }
  OUT DX,AL
  MOV AL,0       { .. to DAC color 0 }
  OUT DX,AL
@Doscreen:
  xor SI,SI
  CLI
  MOV DX,$03DA
  MOV AH,8
@Wau: in AL,DX
  TEST AL,AH
  JNZ @Wau       { wait Until out of retrace }
@Wai: in AL,DX
  TEST AL,AH
  JZ @Wai        { wait Until inside retrace }
@Doline:
  STI
  MOV DX,$03C8  { point to DAC[0] }
  MOV AL,0
  OUT DX,AL
  inC SI        { line counter }
  MOV BX,SI
  ADD BX,CX     { prepare For color effect }
  MOV DI,$03C9
  CLI
  MOV DX,$03DA
@Whu: in AL,DX
  RCR AL,1
  JC @Whu       { wait Until out of horizontal retrace }
@Whi: in AL,DX
  RCR AL,1
  JNC @Whi      { wait Until inside retrace }
  MOV DX,DI
  XCHG BX,AX  { tinker With these to change the chromatic effect}
  OUT DX,AL   { dynamic Red }
  ADD AL,AL
  OUT DX,AL   { dynamic Green }
  XCHG SI,AX
  OUT DX,AL   { static Blue }
  XCHG SI,AX
  CMP SI,200    { paint 200 lines }
  JBE  @doline
  DEC DX         { last line }
  MOV AL,0       { reset to black For remainder of screen }
  OUT DX,AL
  inC DX
  OUT DX,AL
  OUT DX,AL
  OUT DX,AL
  STI
Loop @Doscreen
end;


