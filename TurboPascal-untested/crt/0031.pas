{
CL>Does anyone know how to make the Num Lock,Caps Lock, and Scroll lock lights
CL>turn on and off?

--------------------------------8<-----------------
$40:$17  BYTE    Keyboard status flags 1:
                    bit 7 =1 INSert active
                    bit 6 =1 Caps Lock active
                    bit 5 =1 Num Lock active
                    bit 4 =1 Scroll Lock active
                    bit 3 =1 either Alt pressed
                    bit 2 =1 either Ctrl pressed
                    bit 1 =1 Left Shift pressed
                    bit 0 =1 Right Shift pressed


Port[$3F2] w   diskette controller DOR (Digital Output Register)
                 bit 7-6    reserved PS/2
                 bit 7 = 1  drive 3 motor enable
                 bit 6 = 1  drive 2 motor enable
                 bit 5 = 1  drive 1 motor enable
                 bit 4 = 1  drive 0 motor enable
                 bit 3 = 1  diskette DMA enable (reserved PS/2)
                 bit 2 = 1  FDC enable  (controller reset)
                       = 0  hold FDC at reset
                 bit 1-0    drive select (0=A 1=B ..)
}

Program BlinkBlink;
{ you MUST have a diskette in drive 'B' to use this }
Uses CRT;

CONST DiskCtr       = $03F2;

VAR   i,j           : Byte;
      OldKB         : Byte;
      KBStat        : Byte Absolute $40:$17;

      Out           : Byte;
      ch:char;

BEGIN
  i:=$40;
  j:=0;
  OldKB:=KBStat;

  Writeln('So blink Drive B: ... Taste druecken');
  {Eigentlich sollte auch Drive A: blinken, aber das klappt bei mir irgend-}
  {wie nicht :-( }

  Repeat
    Delay(500);
    Out:=j OR $F0;
    Port[DiskCtr]:=Out;
    j:=(j+1) MOD 2;
  Until Keypressed;

  ch:=ReadKey;

  Writeln('Und so die Tastatur-LEDs ... Taste druecken');

  Repeat
    KBStat:=i;
    Delay(100);
    if Keypressed  then nosound;
    i:=i SHR 1;
    If i=$8 then
      i:=$40;
  Until Keypressed;
  KBStat:=OldKB;
END.
