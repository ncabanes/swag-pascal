(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0084.PAS
  Description: Set Typo rate and Delay
  Author: VARIOUS
  Date: 08-24-94  17:53
*)

{
 IL> INT 16 - KEYBOARD - SET TYPEMATIC RATE AND DELAY

I wrote a little utility a long time ago, that you might find a bit handy...
I'm sure I have the code around here somewhere (rummage..)  Ah here :

for the typematic, delay is in increments of 250, and rate is in decrements
of one...
Sean Graham.....
}

procedure cursor(t, b: byte); assembler; { Set cursor attribs }
asm
   mov ax, $0100
   mov ch, t
   mov cl, b
   int $10
end;

procedure v50; assembler;                { Go to 50 line mode }
asm
   mov ax,1202h
   mov bl,30h
   int 10h
   mov ax,3
   int 10h
   mov ax,1112h
   xor bl, bl
   int 10h
end;

procedure v25; assembler;                { Go to 25 line mode }
asm
   mov ax,$0003
   int $10
end;

procedure typematic(rate, delay: byte); assembler;
asm
   mov ah, 3
   mov al, 5             {Set Typematic Rate And Delay        }
   mov bh, rate          {00h = 30/sec to 1fh = 2/sec         }
   mov bl, delay         {00h = 250ms to 03h = 1000ms         }
   int $16
end;


 {Int $16 Function $03; { Set type matic Rate }
 {MAYNARD PHILBROOK,Re  Keyboard Speed Adjust}

 Procedure SetTypeRate(Kdelay, Krate:Byte);
  Begin
   asm
    Mov AX,$0305; { on a PC jr, AL reg has extra Functions }
    Mov BH, Kdelay;
    Mov BL, Krate;
    Int $16;
   End;
  End;

