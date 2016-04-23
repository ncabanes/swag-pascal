{

This is the fastest I could come up with ; I suspect it's fairly
faster than the one that was posted earlier. Going still faster
would require some change in the algorithm, which I'm much to
lazy to go through <g>.

Beware, this program does not check before overwritting an existing
.uue file. Generally speaking, the error checking is quite light.
}

{$r-,s-,q-}    { for the sake of speed only }

Uses DOS ;

Const
     LongueurLigne  = 60 ;         { max length of output line }
     Masque6bits    = $3f ;        { mask for six lower bits }
     BufSize        = 2048 ;       { size of input buffer }
     Espace         = 32 ;

Var  InBuf     : Array[0..BufSize] Of Byte ; { [0] is unused but necessary }
     InPtr     : Word ;            { pointer in input buffer }
     InQty     : Word ;            { # of bytes available in input buffer }
     InFile    : File ;            { input file }
     OutSt     : String ;          { output string }
     OutFile   : Text ;            { output file }
     SrcBytes  : Byte ;            { number of source bytes in current line }

Procedure RefillBuffer ;
{ Refills the buffer from the input file ; properly sets InQty and InPtr }
Begin
     BlockRead(InFile, InBuf[1], BufSize, InQty) ;
     InPtr:=0 ;
End ;

Function GetByte : Byte ; Assembler ;
{ Fetches a byte from the input file (i.e. input buffer) }
{ Only AL and SI are modified by this function }
Asm
     Mov  SI, InPtr
     Cmp  SI, InQty
     JL   @1
     PushA
     Call ReFillBuffer
     PopA
@1:
     Inc  InPtr
     Mov  SI, InPtr
     Cmp  SI, InQty
     JLE  @2
     XOr  AL, AL
     Jmp  @3
@2:
     Mov  AL, [SI+Offset InBuf]
     Inc  SrcBytes
@3:
End ;

Procedure FlushOutSt ;
{ Flushes the current line to the output file }
Begin
     OutSt[1]:=Chr(Espace+SrcBytes) ;
     WriteLn(OutFile, OutSt) ;
     OutSt:=' ' ;
     SrcBytes:=0 ;
     Write('.') ;
End ;

Procedure PutByte ; Assembler ;
{ Sends a byte to the output file (i.e. the output buffer) }
{ modifies only AL and SI ; parameter in AL }
Asm
     Add  AL, Espace
     Cmp  AL, Espace
     JNE  @1
     Mov  AL, '`'
@1:
     Inc  Byte Ptr OutSt      { increments string length }
     Mov  BL, Byte Ptr OutSt
     XOr  BH, BH              { BX <- Length(OutSt) }
     Mov  Byte Ptr OutSt[BX], AL
     Cmp  BX, LongueurLigne
     JNG  @2
     PushA
     Call FlushOutSt
     PopA
@2:
End ;

Procedure EncodeFile ;
{ Converts a binary file to a .uue file }
Var  a, b, c   : Byte ;            { three-bytes buffer }
Begin
     Repeat
          Asm
               { remember, GetByte and PutByte modify only AL and SI }

               Call GetByte
               Mov  DH, AL         { first byte in DH }
               Call GetByte
               Mov  DL, AL         { second byte in DL }
               Call GetByte
               Mov  CH, AL         { third byte in CH }

               Mov  AL, DH
               ShR  AL, 2
               Call PutByte

               Mov  AX, DX
               ShR  AX, 4
               And  AL, Masque6bits
               Call PutByte

               Mov  AH, DL
               Mov  AL, CH
               ShR  AX, 6
               And  AL, Masque6bits
               Call PutByte

               Mov  AL, CH
               And  AL, Masque6bits
               Call PutByte
          End ;
     Until (EOF(InFile) And (InPtr>=InQty)) ;
End ;

Procedure Initialise ;
{ Initializes the stuff }
Var  Rep  : DirStr ;
     Nom  : NameStr ;
     Ext  : ExtStr ;
Begin
     InPtr:=0 ;
     InQty:=0 ;
     Assign(InFile, ParamStr(1)) ;
     ReSet(InFile, 1) ;
     FSplit(ParamStr(1), Rep, Nom, Ext) ;
     Assign(OutFile, Rep+Nom+'.UUE') ;
     ReWrite(OutFile) ;
     OutSt:=' ' ;
     SrcBytes:=0 ;
     WriteLn(OutFile, 'begin 644 ', Nom, Ext) ;
End ;

Procedure Termine ;
{ Terminate the job }
Begin
     If Length(OutSt)>1 Then
     Begin
          OutSt[1]:=Chr(Espace+SrcBytes) ;
          WriteLn(OutFile, OutSt) ;
     End ;
     Writeln(OutFile, '`') ;       { write an "empty" line }
     WriteLn(OutFile, 'end') ;

     Close(OutFile) ;
     Close(InFile) ;
End ;

Begin
     If ParamCount<>1 Then
     Begin
          WriteLn('UUE2 <source_file_name>') ;
          Halt(1) ;
     End ;
     Initialise ;
     EncodeFile ;
     Termine ;
End.
