(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0091.PAS
  Description: Reading Multiple Keys
  Author: JORT BLOEM
  Date: 11-26-94  05:08
*)

{
> There has been MANY times that I've wanted to read MORE THAN ONE key at
> the same time.. with ReadKey, it seems impossible!  For programming games,
> it seems fall quite short!  So I began to look directly at the
> keyboard buffer..  but it all seemed to be CRIPTIC!
With readkey it is impossible. The keyboard buffer doesnt help either. Take a
look at this code:
}

{$M 2000,0,0}
{$R-,S-,I-,D-,F+,V-,B-,N-,L+}
Program BinClock;
Uses DOS,CRT;
Var Old_Keyb:Pointer;
    Keyz:Set Of 0..127;
    Loop:Byte;

Procedure STI;
 Inline($FB);

Procedure CLI;
 Inline($FA);

Procedure CallOld(Sub:Pointer);
 Begin
  Inline($9C/$FF/$5E/$06);
 End;

Procedure My_Keyb;
 Interrupt;
Var B:Byte;
Begin
 CallOld(Old_Keyb);
 B:=Port[$60];
 If B>=$80 Then
  Keyz:=Keyz-[B And $7F]
 Else
  Keyz:=Keyz+[B];
 STI;
End;

Begin
 ClrScr;
 Keyz:=[];
 GetIntVec($09,Old_Keyb);
 SetIntVec($09,@My_Keyb);
 Repeat
  While KeyPressed Do
   If ReadKey=#0 Then;
  GotoXY(1,1);
  ClrEol;
  For Loop:=1 To 127 Do
   Begin
    If Loop In Keyz Then
     Write('*',Loop,'*');
   End;
 Until 1 In Keyz;
End.

{
> Did I miss something is KBD 101 class?  Could anyone here shed some light
> on  this.. a lookup chart would be a great thing, but algorithms are
> useful too ;)

each key has it's own number. On the origonal PC keyboard,you start at <ESC>
(1) and read across... <!>=2, <@>=3 (I've used shifted to diferentiate
between the key 2 and the scancode 2 etc), then down... but that got shifted
around... I usually use the above program to find the correct key, then code
it into my prog...
}
