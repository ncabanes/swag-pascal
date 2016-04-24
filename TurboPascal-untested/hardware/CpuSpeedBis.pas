(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0033.PAS
  Description: Cpu & Speed
  Author: MAYNARD PHILBROOK
  Date: 08-24-94  13:58
*)

{
 SM> Does anyone have any code to tell me WHAT KIND of CPU is
 SM> installed on a computer, and how fast the CPU is??  I'm using TP 6.0.
 SM> Thanks! Also, while I'm at it, how about some code to detect if a
 SM> co-processor is installed (Optional) Thanks!
 SM> -!-

 well here is somthing i used to get a scale for the Delay command i have
 in my drop in replacement CRT Unit, this will get a scale of the machine
 runing so that if the program gets run on different speed machines the
 code will analize it to produce the scale so DELAY will properly work on
 different machines.

 the speed is a Word Variable i use in the normal area of pascal

 my 486 sx priduces aprox 39,450 at 33Mhz, when 8 mhz is runing it will
 produce aprox 10,500..
  So with that i think you can figure out somthing..
}

VAR
    Speed : WORD;

BEGIN

Asm
 STI
 Mov AX, $0040;
 Mov ES, AX;
 Mov Bl, [ES:$006c]; { Get jiffy clock current value }
 And BL, $01;        { monitor bit 0 only }
 Xor AX, AX;         { with need a 48 bit reference for fast machines }
 Xor DX, DX;         { clear AX, DX, SI }
 Xor SI, SI;
        { the following is to syncronize the clock to insure that we are at
       starting of a new clock count }
@lp:
 Mov BH, [ES:$006c]; { Now get the jiffy again }
 and BH, $01;        { only need to check bit }
 cmp BL,BH;          { if clock is still the same then it has incremented }
 Je @lp;
        { Now we know the clock at the start of a new timing cycle }
@Lp1:
 Inc  AX;   { Increment 48 bit counters now }
 Jnz @lp2;
 Inc DX;
 Jz @lp2;
 Inc SI;
@Lp2:
 Mov BH, [ES:$006c];
 And BH, $01;
 Cmp BL, BH;
 Jne @Lp1;    { Loop back increment counters until jiffy bit 0 changes }
 SHR SI,1;    { now we scale down the 48 bits into a 16 bit reference }
 RCR DX,1;
 RCR AX,1;
 SHR DX,1;

 RCR AX,1;   { if you need more resolution then exclude one of then RCR,SHR}
 SHR DX,1;   { you would also need to use DX reg of you do as the 32 bit }

 RCR AX,1;
 SHR AX,1;

 Mov Speed,AX;  { Set Scale Factor }
End;

WriteLn(Speed);

END.

