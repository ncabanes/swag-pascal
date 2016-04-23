{
> I've seen few times an effect which fades the DOS screen before demo or
> something, how's it done?
> And how can I freeze DOS screen to memory so that I can write it again
> after demo or game has ended?
> And I want to know other that kind of 'effects' (or what ever they are
> called..)..

Here's some bits & pieces from a VGA library I'm writing... note that the fades
only work on VGA....
}

{$G+} {Yes, it does unfortunately use 286 opcodes to eliminate snow. Sorry.}
Program VGA_Stuff;
Uses Crt;
Type
 CharAttr=Record  {How a character looks in screen memory}
  Ch:Char;        {The character to display}
  Attr:Byte;      {The foreground+(background*16). bright backgrounds=flashing}
 End;

 TextScreen=Array[1..25,1..80] Of CharAttr;
                  {This represents 1 screen. Note the Y,X order}

 DAC_Trio=Record
  Red,Green,Blue:Byte;
 End;             {One pallette register. Note that it's always in that order}

Var
 Physical_TScreen:TextScreen Absolute $B800:0; {The real screen}
 Starting_TScreen:TextScreen;                  {Another screen, in memory}

Procedure WaitForRetrace;
 {Waits for vertical retrace. This is to assure the same speed across all PCs,
  and to eliminate interference. Waits at most 1/70th of a second.}
Begin
 Asm
  MOV  DX,$3DA;
@Wait1:
  IN   AL,DX
  TEST AL,8         {retrace hapening?}
  JNZ   @Wait1      {Yep, wait for it to end}
@Wait2:
  IN   AL,DX
  TEST AL,8         {Retrace happening?}
  JZ  @Wait2        {nope, wait to finish}
 End
End;

Procedure SetPal(Var P; Start:Byte; Count:Word);
{P is an array of DAC_Trio's, set up with the colours we want.
 The start is the first colour to set, the count is how many. Note that there's
only 256 registers, so count should be no more than 256. Also, they will wrap
round; starting at 128 & count=256 will set the register 128 to the first trio,
and so forth, till the last trio at 127.}
Begin
 WaitForRetrace; {To eliminate snow.}
 Asm
  MOV  DX,$3C8
  MOV  AL,Start
  OUT  DX,AL
  INC  DX
  MOV  BX,DS
  LDS  SI,P
  MOV  CX,Count
  ADD  CX,Count
  ADD  CX,Count
  REP  OUTSB
  MOV  DS,BX
 End;
End;

Procedure GetPal(Var P; Start:Byte; Count:Word);
{Gets a number of pallette registers. P should be an array of DAC_Trio's, start
 should be the first one to get, and count should be the number of registers to
get.}Begin
 Asm
  MOV  DX,$3C7
  MOV  AL,Start
  OUT  DX,AL
  INC  DX
  INC  DX
  MOV  BX,ES
  LES  DI,P
  MOV  CX,Count
  ADD  CX,Count
  ADD  CX,Count
  REP  INSB
  MOV  ES,BX
 End;
End;

Procedure Fade_Out;
{Gets the current pallette & fades it out.}
Var
 Pal:Array[0..255] Of Dac_Trio;
 Loop1,Loop2:Byte;
Begin
 GetPal(Pal,0,255);
 For Loop1:=1 To 64 Do
  Begin
   For Loop2:=0 To 255 Do
    Begin
     If Pal[Loop2].Red>0 Then
      Dec(Pal[Loop2].Red);
     If Pal[Loop2].Green>0 Then
      Dec(Pal[Loop2].Green);
     If Pal[Loop2].Blue>0 Then
      Dec(Pal[Loop2].Blue);
    End;
   WaitForRetrace;
   {Put WaitForRetrace; here to slow it down to suit. Each one slows it down
    one screenframe}
   SetPal(Pal,0,255);
  End;
End;

Procedure Fade_In(Var P);
{Fades the screen in from black to whatever colours are set in P. P should be
an array of DAC_Trio's}Var
 NewPal:Array[0..255] Of Dac_Trio Absolute P;
 Pal:Array[0..255] Of Dac_Trio;
 Loop1,Loop2:Byte;
Begin
 FillChar(Pal,SizeOf(Pal),0); {Set to black}
 SetPal(Pal,0,256);
 For Loop1:=63 DownTo 0 Do
  Begin
   For Loop2:=0 To 255 Do
    Begin
     If NewPal[Loop2].Red>Loop1 Then
      Inc(Pal[Loop2].Red);
     If NewPal[Loop2].Green>Loop1 Then
      Inc(Pal[Loop2].Green);
     If NewPal[Loop2].Blue>Loop1 Then
      Inc(Pal[Loop2].Blue);
    End;
   {Put WaitForRetrace; here to slow it down to suit. Each one slows it down
    one screenframe}
   WaitForRetrace;
   SetPal(Pal,0,255);
  End;
End;

Var Loop:Word;
    Orig_Pal:Array[0..255] Of Dac_Trio;

Begin
 Starting_TScreen:=Physical_TScreen;  {Make a copy of the origonal screen}
 GetPal(Orig_Pal,0,256);              {Make a copy of origonal pallette}

 For Loop:=1 To 4000 Do
  Mem[$B800:Loop]:=Random(127); {Fill screen with garbage!}

 Fade_Out;
 Physical_TScreen:=Starting_TScreen;  {Restore origonal screen}

 Fade_In(Orig_Pal);                   {Fade in to origonal colours}
End.
