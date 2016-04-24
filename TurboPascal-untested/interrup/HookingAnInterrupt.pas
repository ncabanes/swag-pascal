(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0008.PAS
  Description: Hooking an interrupt
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:40
*)

PROGRAM CatchInt;

USES
   Crt,Dos,Printer;

{This program illustrates how you can modify an
 interrupt service routine to perform special
 services for you.}

 VAR
    OldInt,OldExitProc: pointer;
    IntCount: array[0..255] of byte;

 PROCEDURE GoOldInt(OldIntVector: pointer);
 INLINE (
    $5B/   {POP BX - Get Segment}
    $58/   {POP AX - Get Offset}
    $89/   {MOV SP,BP}
    $EC/
    $5D/   {POP BP}
    $07/   {POP ES}
    $1F/   {POP DS}
    $5F/   {POP DI}
    $5E/   {POP SI}
    $5A/   {POP DX}
    $59/   {POP CX}
    $87/   {XCHG SP,BP}
    $EC/
    $87/   {XCHG [BP],BX}
    $5E/
    $00/
    $87/   {XCHG [BP+2],AX}
    $46/
    $02/
    $87/   {XCHG SP,BP}
    $EC/
    $CB);  {RETF}


 {$F+}

 PROCEDURE NewExitProc;

 VAR I: byte;
 VAR A: char;

 FUNCTION Intr21Desc(IntNbr: byte): string;

 VAR
    St : string[30];

 BEGIN
    CASE IntNbr of
       $25: St := 'Set Interrupt Vector';
       $36: St := 'Get Disk Free Space';
       $3C: St := 'Create File with Handle';
       $3E: St := 'Close FILE';
       $40: St := 'WriteFile or Device';
       $41: St := 'Delete FILE';
       $44: St := 'IOCTL';
       $3D: St := 'Open File with Handle';
       $3F: St := 'Read File or Device';
       $42: St := 'Move File pointer';
    ELSE
        St := 'Unknown DOS Service'
    END;
    Intr21Desc := St;
 END;


 FUNCTION DecToHex(Deci: byte): string;

 CONST
    ConvStr: string[16] = '0123456789ABCDEF';
 BEGIN
    DecToHex := ConvStr[Deci div 16 + 1] +
                ConvStr[Deci mod 16 + 1]
 END;


 BEGIN
      ClrScr;
      ExitProc := OldExitProc;
      SetIntVec($21,OldInt);
      WriteLn('Int   #   Description');
      WriteLn(' #  Times');
      WriteLn;
      FOR I:= 0 TO 255 DO
         BEGIN
            IF IntCount[I] <> 0 THEN
               BEGIN
                  Write(DecToHex(I),'H');
                  Write(' ',IntCount[I]:3);
                  GotoXY(11,WhereY);
                  WriteLn(Intr21Desc(I))
               END
         END
 END;


 PROCEDURE NewInt(AX,BX,CX,DX,SI,
                  DI,SD,ES,BP: Word); INTERRUPT;

 VAR AH: byte;

 BEGIN
   Sound(1220);Delay(10);NoSound;
   AH := Hi(AX);
   IntCount[AH] := IntCount[AH]+1;
   GoOldInt(OldInt)
 END;
 {$F-}

{************ Main Program *****************}

 VAR I: byte;
     F: text;
     TestStr: string[40];

 BEGIN

   ClrScr;

{Install new Exit PROCEDURE}

   OldExitProc := ExitProc;
   ExitProc := @NewExitProc;

{Install new Interrupt Vector}

   GetIntVec($21, OldInt);
   SetIntVec($21, @NewInt);

{********  Testing Section  ***********}

   WriteLn('Starting Testing');Delay(1000);

   FillChar(IntCount,SizeOf(IntCount),#0);

   FOR I:= 0 TO 255 DO
   WriteLn('Testing 1');    {WriteLn's to screens}
                            {do not use the 21H }
                            {Interrupt                }

   Write('TYPE anything TO test keyboard: ');
   ReadLn(TestStr);

   Writeln('Disk Size ',
            DiskSize(3));        {Uses Service 36H}


   Assign (F,'TestFile');
   Rewrite(f);                    {Uses Service 3CH,44H}

   FOR I:=0 TO 255 DO
   WriteLn(F,'This is only A test'); {Service 40H}
   WriteLn(F,'This is A test too');
   WriteLn(f,'Last test');

   Close(f);                    {Uses Service 3EH,40H}

   Assign(F,'TestFile');
   Append(f);            {Uses Service 3DH,3FH,42H,44H}
   Close(F);                    {Uses Service 3EH,40H}

   Assign(F,'TestFile');
   Erase(f)                        {Uses Service 41H}
 END.

