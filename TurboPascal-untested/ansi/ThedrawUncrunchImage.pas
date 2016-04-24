(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0009.PAS
  Description: THEDRAW UNCRUNCH Image
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{Reading in a thedraw image :)
}
Procedure UNCRUNCH (Var Addr1,Addr2; BlkLen:Integer);

begin
  Inline (
    $1E/               {       PUSH    DS             ;Save data segment.}
    $C5/$B6/ADDR1/     {       LDS     SI,[BP+Addr1]  ;Source Address}
    $C4/$BE/ADDR2/     {       LES     DI,[BP+Addr2]  ;Destination Addr}
    $8B/$8E/BLKLEN/    {       MOV     CX,[BP+BlkLen] ;Length of block}
    $E3/$5B/           {       JCXZ    Done}
    $8B/$D7/           {       MOV     DX,DI          ;Save X coordinate For
later.}
    $33/$C0/           {       xor     AX,AX          ;Set Current attributes.}
    $FC/               {       CLD}
    $AC/               {LOOPA: LODSB                  ;Get next Character.}
    $3C/$20/           {       CMP     AL,32          ;if a control Character,
jump.}
    $72/$05/           {       JC      ForeGround}
    $AB/               {       StoSW                  ;Save letter on screen.}
    $E2/$F8/           {Next:  LOOP    LOOPA}
    $EB/$4C/           {       JMP     Short Done}
                       {ForeGround:}
    $3C/$10/           {       CMP     AL,16          ;if less than 16, then
change the}
    $73/$07/           {       JNC     BackGround     ;Foreground color.
otherwise jump.}
    $80/$E4/$F0/       {       and     AH,0F0H        ;Strip off old
Foreground.}
    $0A/$E0/           {       or      AH,AL}
    $EB/$F1/           {       JMP     Next}
                       {BackGround:}
    $3C/$18/           {       CMP     AL,24          ;if less than 24, then
change the}
    $74/$13/           {       JZ      NextLine       ;background color.  if
exactly 24,}
    $73/$19/           {       JNC     FlashBittoggle ;then jump down to next
line.}
    $2C/$10/           {       SUB     AL,16          ;otherwise jump to
multiple output}
    $02/$C0/           {       ADD     AL,AL          ;routines.}
    $02/$C0/           {       ADD     AL,AL}
    $02/$C0/           {       ADD     AL,AL}
    $02/$C0/           {       ADD     AL,AL}
    $80/$E4/$8F/       {       and     AH,8FH         ;Strip off old
background.}
    $0A/$E0/           {       or      AH,AL}
    $EB/$DA/           {       JMP     Next}
                       {NextLine:}
    $81/$C2/$A0/$00/   {       ADD     DX,160         ;if equal to 24,}
    $8B/$FA/           {       MOV     DI,DX          ;then jump down to}
    $EB/$D2/           {       JMP     Next           ;the next line.}
                       {FlashBittoggle:}
    $3C/$1B/           {       CMP     AL,27          ;Does user want to toggle
the blink}
    $72/$07/           {       JC      MultiOutput    ;attribute?}
    $75/$CC/           {       JNZ     Next}
    $80/$F4/$80/       {       xor     AH,128         ;Done.}
    $EB/$C7/           {       JMP     Next}
                       {MultiOutput:}
    $3C/$19/           {       CMP     AL,25          ;Set Z flag if
multi-space output.}
    $8B/$D9/           {       MOV     BX,CX          ;Save main counter.}
    $AC/               {       LODSB                  ;Get count of number of
times}
    $8A/$C8/           {       MOV     CL,AL          ;to display Character.}
    $B0/$20/           {       MOV     AL,32}
    $74/$02/           {       JZ      StartOutput    ;Jump here if displaying
spaces.}
    $AC/               {       LODSB                  ;otherwise get Character
to use.}
    $4B/               {       DEC     BX             ;Adjust main counter.}
                       {StartOutput:}
    $32/$ED/           {       xor     CH,CH}
    $41/               {       inC     CX}
    $F3/$AB/           {       REP StoSW}
    $8B/$CB/           {       MOV     CX,BX}
    $49/               {       DEC     CX             ;Adjust main counter.}
    $E0/$AA/           {       LOOPNZ  LOOPA          ;Loop if anything else to
do...}
    $1F);              {Done:  POP     DS             ;Restore data segment.}
end; {UNCRUNCH}

