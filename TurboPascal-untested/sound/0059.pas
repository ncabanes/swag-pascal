{
> - trying to produce a 400hz sound in one channel and a 404hz sound in
> another... How difficult will that be for me?  Do I even need to invest
> in a book, or might someone have some code floating around ... *GRiN*

Well, I can help you for the PC Speaker, I've once picked this source up from a
Dutch pascal echo:------------------------------
}

Unit SoundU;
Interface
Uses
 Dos;

Procedure DoubleSound(Freq1,Freq2,Duration,SampleFrequency:Real);
{Play two tones simulatisly: Does sort of:
 Sound(Freq1) + Sound(Freq2)
 Delay(Duration/SampeFrequency*1000)
 NoSound;
}

Procedure Cli;
{ disable interrupt }
Inline($fa);

Procedure Sti;
{ enable interrupt }
Inline($fb);

Implementation

Type { general multitype record for typecasting }
 mtype = Record
  Case Byte Of
   2: (o,s: Word);
   4: (l: LongInt);
 End;

Const
 Clk8253 = 1193180; { Clock input to 8253A-5 timerchip }

Var
 old_vector: Pointer; { pointer to original interrupt interrupt }
 dacptr1,dacptr2: Word;{ pointer to start of buffer }
 step1,step2: mtype; { table step value }
 Frac1,Frac2: Word; { fractional part of pointer }
 OnsShotTable: Array[0..255] Of Byte; { Table of Timer 2 ReLoad Values }
 SineTable: Array[0..255] Of Byte; { Sine Table }
 Timer0Reload: Word;
 CountDown: Word;
 factor: Real;

{$S-}
procedure Int8; Assembler;
asm
 push ax
 push bx
 push cx
 push ds
 mov ax,Seg @Data
 mov ds,ax
 cmp CountDown,0  { Timeout ? }
 jz @Exit
 dec CountDown
 mov bx,dacptr1  { Get first sample }
 mov ax,step1.o
 add Frac1,ax
 adc bx,step1.s
 mov dacptr1,bx
 and bx,$ff
 mov al,[bx+offset SineTable]
 cbw
 mov cx,ax
 mov bx,dacptr2  { Get second sample }
 mov ax,step2.o
 add Frac2,ax
 adc bx,step2.s
 mov dacptr2,bx
 and bx,$ff
 mov al,[BX+Offset SineTable]
 cbw
 add ax,cx   { Add samples }
 sar ax,1   { Adjust }
 add al,$80   { Signed to Absolute }
 mov bx,Offset OnsShotTable { Now, lookup Timer 2 Reload value }
 xlat
 out $42,al   { Reload timer channel 2 }
@Exit:
 mov al,$20   { send End_Of_Interrupt }
 out $20,al
 pop ds
 pop cx
 pop bx
 pop ax
 sti    { Position not critical }
 iret
end;
{$S+}

Procedure DoubleSound(Freq1,Freq2,Duration,SampleFrequency:Real);
Var
 I:Byte;
Begin
 {INIT}
 Timer0Reload:=Round(Clk8253/SampleFrequency);
 SampleFrequency:=Round(Clk8253/Timer0Reload);
 factor:=Clk8253/(SampleFrequency*(256+5));
 For I:=0 To 255 Do OnsShotTable[I]:=1+Round(I*factor);
 For I:=0 To 255 Do SineTable[I]:=Byte(Round(Sin((2*Pi*I)/256)*127));
 { Calculate first SineTable Stepvalue }
 step1.l:=Round(65536.0*freq1*256.0/SampleFrequency);
 dacptr1:=0;
 Frac1:=0;
 { Calculate second SineTable Stepvalue }
 step2.l:=Round(65536.0*freq2*256.0/SampleFrequency);
 dacptr2:=0;
 Frac2:=0;
 { Calculate Timeout value }
 CountDown:=Round(SampleFrequency*duration);
 { OK, time to enable our int8 procedure }
 GetIntVec(8,old_vector);
 cli;
 SetIntVec(8,@Int8);
 { initialize 8253 timer-chip }
 { 8255 PPI, Enable Speaker, Speaker input Gate = output from 8253 channel 2 }
 port[$61]:=port[$61] Or $03;
 port[$43]:=$90; { Channel 2, Read/Write only LSB, Mode 0=OneShot, Binary }
 { Set Interrupt 8 frequency (samplefrequency) }
 port[$43]:=$36; { Channel 0, Read/Write LSB then MSB, Mode 3=SqrW, Binary }
 port[$40]:=Lo(Timer0Reload); { LSB }
 port[$40]:=Hi(Timer0Reload); { MSB }
 sti; { Start PC Speak'ing }
 Repeat
  { BEEP'ING }
 Until CountDown=0;
 cli;
 SetIntVec(8,old_vector); { restore original int8 vector }
 port[$43]:=$36;
 port[$40]:=$00;
 port[$40]:=$00;
 sti;
end; { output_sound }

end.
