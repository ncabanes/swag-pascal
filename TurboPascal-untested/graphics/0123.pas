
Program ViewASCi;

{ Simple SCi Viewer - By Simeon Spry

This code will display a SCi (320*200*256) file. I would reccomend that you
add code to find out if the SCi File name is valid. I had some, but I got
it out of a book so it *might* be copyrighted :-(. You also might want to
save the old pallete and restore it afterwards I didn't do it because I
lost my reference.

This may be freely distributed, if you incorporate any portions of this
code into a part of anything you MUST give me some credit.
}


Procedure ViewSci( SciF : STRING);
 CONST    Header : Array[1..4] OF CHAR = ('R','I','X','3');

 VAR     SciFile : File;
         HeaderBuf : Array[1..10] OF CHAR;
         NewPal    : Array[1..768] OF BYTE; { 3 Bytes Per colour, 3*256 = 768}
         OldPal    : Array[1..768] OF BYTE; { "  "  "}
         Screen    : Array[1..64000] OF BYTE ABSOLUTE $A000:0000; { Direct to
the screen }
         i         : integer;
 Procedure SetPal(Pallete : Array OF BYTE);
 VAR
   PalPtr : POINTER;
 BEGIN
  PalPtr := @Pallete;
  asm
   mov ax,1012h
   xor bx,bx
   mov cx,0100h
   les dx,PalPtr
   int 10h
  end;
 END;

 Procedure WaitForKey;assembler;
  ASM
   xor ax,ax
   int 16h
  END;
Procedure SetMode(Mode : BYTE); assembler;
  ASM
    mov ah, 00
    mov al, mode
    int 10h
  END;

 BEGIN
  { Open The File }
  assign(SciFile, SciF);
  Reset(SciFile,1);

  { Check The Header }
  BlockRead(SciFile,HeaderBuf,SizeOF(HeaderBuf));
  For i := 1 to 4 DO
   Begin
    If HeaderBuf[i] <> Header[i] Then
     BEGIN
      WriteLn;
      WriteLn(' Invalid SCI File. ');
      WriteLn;
      Halt(1);
     END;
   End;

 { Set Mode $13 }
 SetMode($13);

 { Read Pallete into a 768 Byte Buffer & DisPlay. }
  BlockRead(SciFile,NewPal,768);
  SetPal(NewPal);

 { Read 64000 bytes then write DIRECTLY to Video Memory }
  BlockRead(SCIFile,Screen,64000);
  cLOSE(SCIFILE);
 { Wait Until Key Pressed }
 WaitForKey;

 { Set Text Mode }
  SetMode($3);
END;

Var SciFile : String[12];

BEGIN
   { Ask For File To View }
  WriteLn('SCi Viewer - By Simeon Spry');
  Write('View File: ');
  ReadLn(SciFile);

   { View SCi File }
  ViewSCI( SciFile );

   { Display Made-By Message }
  WriteLn('Simple SCi Viewer by Simeon Spry');
  WriteLn;
END.
