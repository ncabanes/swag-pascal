(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0023.PAS
  Description: uuencoder
  Author: RAPHAEL VANNEY
  Date: 11-22-95  13:33
*)

{
Some time ago, I posted here an uuencoder with the following comment :

8<--------------------------------------------------------------
This is the fastest I could come up with ; I suspect it's fairly
faster than the one that was posted earlier. Going still faster
would require some change in the algorithm, which I'm much to
lazy to go through <g>.
8<--------------------------------------------------------------

I was recently toying with this UU matter, and came onto that piece of
code in the SWAGS ; I found it amazingly slow, which it actually is, so
here's the new release (about 10 times faster ; I've given up lazyness
for that one).

Please note that the warning still applies :

Beware, this program does not check before overwritting an existing .uue
file. Generally speaking, the error checking is quite light.

{$r-,s-,q-}    { for the sake of speed only }
{$v-}

Uses DOS ;

Const
     BytesPerLine   = 45 ;         { maximum bytes per encoded line }
     Masque6bits    = $3f ;        { mask for six lower bits }

Procedure EncodeBuffer(Var Buf ; Len : Integer ; Var Res : String) ;
{ UUEncodes Len bytes from Buf into Res }
Assembler ;
Asm
     Push DS
     ClD
     LDS  SI, Buf        { source buffer }
     LES  DI, Res        { destination buffer }
     Mov  CX, Len        { source length }
     Inc  DI             { ES:DI points to first char of Res }
     Mov  AL, CL
     Add  AL, ' '
     StoSB               { store coded number of bytes in line }
     Mov  DL, 1          { DL will hold the actual length of Res }
@1:
     { This loops process 3 input bytes to make 4 output characters }
     LodSB               { 1st byte }
     Mov  BL, AL         { save it }
     ShR  AL, 2          { keep 6 most significant bits (msb) }
     Add  AL, ' '        { encode }
     StoSB               { store in Res }
     ShL  BL, 4          { BL's 4 msb contains 1st byte's 4 lsb }
     LodSB               { load 2nd byte }
     Mov  BH, AL         { save it }
     ShR  AL, 4          { AL's 4 lsb contains 2nd byte's 4 msb }
     Or   AL, BL
     And  AL, Masque6bits{ clear out 2 msb }
     Add  AL, ' '        { encode }
     StoSB               { store 2nd char }
     LodSB               { load 3rd byte }
     Mov  BL, AL         { save it }
     And  BH, $0f        { BH now holds 4 lsb of 2nd byte }
     ShL  AL, 1          { rotate BH:AL... }
     RCL  BH, 1          { ...left 2 bits so that... }
     ShL  AL, 1          { ...6 lsb of BH contains 4 lsb of 2nd byte... }
     RCL  BH, 1          { ...and 2 msb of 3rd byte (clear ?) }
     Mov  AL, BH
     Add  AL, ' '        { encode 3rd char }
     StoSB               { store it }
     Mov  AL, BL         { BL contains 3rd byte }
     And  AL, Masque6bits{ keep only 6 lsb }
     Add  AL, ' '        { encode }
     StoSB               { store 4th char }
     Add  DL, 4          { add 4 to resulting string's length }
     Sub  CX, 3          { 3 bytes processed }
     JA   @1             { if more to process, loop }
     Mov  DI, Word Ptr Res
     Mov  ES:[DI], DL    { store resulting string's length }
     Pop  DS
End ;

Procedure ReplaceSpaceWithBackQuote(Var Str : String) ;
{ Replaces ' ' with '`' in Str }
Assembler ;
Asm
     LES  DI, Str
     Mov  CL, ES:[DI]
     XOr  CH, CH
     ClD
     Inc  DI
     Mov  AX, '`'*256+' '
#1:
     JCXZ @2
     RepNE ScaSB
     JNE  @2
     Mov  ES:[DI-1], AH
     Jmp  #1
@2:
End ;

Var  { buffers for input and output files }
     InBuf     : Array[1..100*BytesPerLine] Of Byte ;
     OutBuf    : Array[1..8192] Of Char ;

Procedure EncodeFile(FName : String) ;
Var  InF  : File ;            { input file }
     OutF : Text ;            { output file }
     OutB : String[BytesPerLine*4 Div 3+4] ; { output buffer }
     Lus  : Word ;            { # of bytes read from input file }
     InP  : Word ;            { current pos in input buffer }
     Nb   : Word ;            { # of bytes to process }

     Rep  : PathStr ;
     Nom  : NameStr ;
     Ext  : ExtStr ;
Begin
     { Open input file }

     Assign(InF, FName) ;
     {$i-}
     ReSet(InF, 1) ;
     {$i+}
     If IOResult<>0 Then
     Begin
          WriteLn('Can''t open ', FName) ;
          Exit ;
     End ;

     FSplit(FName, Rep, Nom, Ext) ;

     { Create (erase) output file in current directory }

     Assign(OutF, Nom+'.UUE') ;
     ReWrite(OutF) ;
     SetTextBuf(OutF, OutBuf, SizeOf(OutBuf)) ;
     WriteLn(OutF, 'begin 644 ', Nom, Ext) ;

     While Not EOF(InF) Do
     Begin
          { Fill the input buffer }

          BlockRead(InF, InBuf, SizeOf(InBuf), Lus) ;
          InP:=1 ;
          If Lus<SizeOf(InBuf) Then     { this 0-filling is optional }
               FillChar(InBuf[Lus+1], SizeOf(InBuf)-Lus, 0) ;

          While InP<=Lus Do
          Begin
               { Process BytesPerLine bytes at a time }

               Write('.') ;
               Nb:=Lus-InP+1 ;
               If Nb>BytesPerLine Then Nb:=BytesPerLine ;
               EncodeBuffer(InBuf[InP], Nb, OutB) ;
               ReplaceSpaceWithBackQuote(OutB) ;
               WriteLn(OutF, OutB) ;
               Inc(InP, Nb) ;
          End ;
     End ;

     Close(InF) ;

     { write UUE footer }

     WriteLn(OutF, '`') ;
     WriteLn(OutF, 'end') ;
     Close(OutF) ;
End ;

Begin
     If ParamCount<>1 Then
     Begin
          WriteLn('UUE2 <file name>') ;
          Halt(1) ;
     End ;
     EncodeFile(ParamStr(1)) ;
End.

