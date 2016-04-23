{
> I know that a double-byte char system exists on the PC for
> producing characters beyond the 256 ASCII chars. How is this mode
> initialized and manipulated? I am interested in creating far more than
> 256 characters and writing them to the screen in text mode, and this
> appears to be the only way.

 Don't think that can be done in normal Text Block Mode.
 But if you flip your Video in Graphics you could always create Display
 Driver to imulate many charactors.
   There is a mode that lets you change one of the Charactor Attribute
 Bits normal use to be used to select a different charactor set, but when
 you do this you also lost that option of what that bit was prior.
 here is the interrupt call
}

Procedure Set512CharSet; Assembler;
Asm
  Mov     AH, 11H;
  Mov     AL, 03H;
  Mov     BL, $12; {Selects the Charactor Sets VIA Bit 3 in Char Attri
  { BL must be loaded so the Video COntroler knows which Block to use }
  { Depending on wether Bit 3 of the Charactor Attri is on of Off }
  { The Upper 4 bits selects a block number to use for The On state of
  { Bit 3, the ,Lower Four Bits Selects the OF State of Bit 3 }
  Int     10H;
End;

{
 So after this, when ever you use TextColor(8 - 15) you will get the
 Next Charactor set, ou lose the Intensity option..
 this means only 7 8 colors. like the Background..
 But you can chage the pallets.
INt 10h
Function 10h
Subfunction 00h
BX = 0712H
INT 10H;
{ Function always loaded in AH reg, Subs in AL. }
