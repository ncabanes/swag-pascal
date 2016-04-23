{
                =======================================

                      CMOS V1.0 (c) AVC Software
                              Cardware

                 CMOS print  yours CMOS values  for a
                 paper backup.

                 With it, don't be afraid to  lose all
                 your data!  Restore  there with CMOS.

                =======================================


   The purpose of this  program is  to print  the content of  your AMI CMOS

   I've never try  it on  another Bios  than AMERICAN MEGATRENDS  INC. so I
   can't certify that this code should work on every machine.




               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░


}

Uses Printer, Crt;

Const PrnInit  = #27+#69+#27+#38+#108+#49+#79+#27+#40+#115+#49+#55+#72+#27+
                 #38+#108+#53+#46+#49+#52+#67+#27+#38+#108+#55+#48+#70+#27+
                 #38+#108+#55+#69;
      PrnReset = #12+#27+'E';

Const Line1   : String = '┌──────────────────────────────────────────────────────┬───────────────────────┐';
      Line2   : String = '└──────────────────────────────────────────────────────┴───────────────────────┘';
      Line3   : String = '├──────────────────────────────────────────────────────┼───────────────────────┤';
      Line4   : String = '┌──────────────────────────────────────────────────────────────────────────────┐';
      Line5   : String = '└──────────────────────────────────────────────────────────────────────────────┘';

Var St    : Array [1..101] of String[80];
    St2   : String;

Procedure Detect;

Var Port11, Port13, Port2D, Port33, Port34, Port35, Port36 : Byte;
    Sectors      : Byte;
    Head         : Byte;
    Cylindre     : Word;
    PzCylindre   : Word;
    WCylindre    : Word;
    HddType      : Byte;
    HddType2     : Byte;
    R            : LongInt;
    Temp1, Temp2 : Byte;
    AA, BB, CC   : Word;
    TailleHdd    : LongInt;

Begin

Asm

   Mov  Al, 11h
   Out  70h, Al
   In   Al, 71h
   Mov  port11, Al

   Mov  Al, 13h
   Out  70h, Al
   In   Al, 71h
   Mov  Port13, Al

   Mov  Al, 2dh
   Out  70h, Al
   In   Al, 71h
   Mov  Port2d, Al

   Mov  Al, 34h
   Out  70h, Al
   In   Al, 71h
   Mov  Port34, Al

   Mov  Al, 35h
   Out  70h, Al
   In   Al, 71h
   Mov  Port35, Al

   Mov  Al, 33h
   Out  70h, Al
   In   Al, 71h
   Mov  Port33, Al

   Mov  Al, 36h
   Out  70h, Al
   In   Al, 71h
   Mov  Port36, Al

   mov al, 1bh
   out 70h, al
   in al, 71h
   mov temp1, al

   mov al, 1ch
   out 70h, al
   in al, 71h
   mov temp2, al

End;

cylindre := (temp2 Shl 8) + temp1;

asm
   mov al, 1dh
   out 70h, al
   in al, 71h
   mov head, al

   mov al, 23h
   out 70h, al
   in al, 71h
   mov sectors, al

   mov al, 19h
   out 70h, al
   in al, 71h
   mov hddtype, al

   mov al, 1ah
   out 70h, al
   in al, 71h
   mov hddtype2, al


   mov al, 1eh
   out 70h, al
   in al, 71h
   mov temp1, al

   mov al, 1fh
   out 70h, al
   in al, 71h
   mov temp2, al

End;

wcylindre := (temp2 Shl 8) + temp1;

asm

   mov al, 21h
   out 70h, al
   in al, 71h
   mov temp1, al

   mov al, 22h
   out 70h, al
   in al, 71h
   mov temp2, al

End;

pzcylindre := (temp2 Shl 8) + temp1;

Aa := Sectors;
Bb := Head;
Cc := Cylindre;

Asm

   Mov Ax, Aa
   Mov Bx, Bb
   Mul Bx
   Mov Bx, Cc
   Mul Bx
   Mov Word Ptr [R + 2], Dx
   Mov Word Ptr [R    ], Ax
End;

TailleHdd := (((R Div 1024) * 512) Div 1024);

if (((Port13 and 128) shr 7) = 1) then
     St[1] :='Typematic Rate Programming                           │ Enabled'
else St[1] :='Typematic Rate Programming                           │ Disabled';

if (((Port13 and 96) shr 5) = 0) then
     St[2] :='Typematic Rate Delay (msec)                          │ 250'
else if (((Port13 and 96) shr 5) = 1) then
     St[2] :='Typematic Rate Delay (msec)                          │ 500'
else if (((Port13 and 96) shr 5) = 2) then
     St[2] :='Typematic Rate Delay (msec)                          │ 750'
else if (((Port13 and 96) shr 5) = 3) then
     St[2] :='Typematic Rate Delay (msec)                          │ 1000';

if (((Port13 and  28) shr 2) = 0) then
     St[3] :='Typematic Rate (Chars/Sec)                           │ 6'
else if (((Port13 and  28) shr 2) = 1) then
     St[3] :='Typematic Rate (Chars/Sec)                           │ 8'
else if (((Port13 and  28) shr 2) = 2) then
     St[3] :='Typematic Rate (Chars/Sec)                           │ 10'
else if (((Port13 and  28) shr 2) = 3) then
     St[3] :='Typematic Rate (Chars/Sec)                           │ 12'
else if (((Port13 and  28) shr 2) = 4) then
     St[3] :='Typematic Rate (Chars/Sec)                           │ 15'
else if (((Port13 and  28) shr 2) = 5) then
     St[3] :='Typematic Rate (Chars/Sec)                           │ 20'
else if (((Port13 and  28) shr 2) = 6) then
     St[3] :='Typematic Rate (Chars/Sec)                           │ 24'
else if (((Port13 and  28) shr 2) = 7) then
     St[3] :='Typematic Rate (Chars/Sec)                           │ 30';

St[4] := Line3;

if (((Port11 and  64) shr 6) = 1) then
     St[5] := 'Above 1 MB Memory Test                               │ Enabled'
else St[5] := 'Above 1 MB Memory Test                               │ Disabled';

if (((Port11 and  32) shr 5) = 1) then
     St[6] := 'Memory Test Tick Sound                               │ Enabled'
else St[6] := 'Memory Test Tick Sound                               │ Disabled';

if (((Port11 and  16) shr 4) = 1) then
     St[7] := 'Memory Parity Error Check                            │ Enabled'
else St[7] := 'Memory Parity Error Check                            │ Disabled';

St[8] := Line3;

if (((Port11 and   8) shr 3) = 1) then
     St[9] := 'Hit <DEL> message display                            │ Enabled'
else St[9] := 'Hit <DEL> message display                            │ Disabled';

if (((Port11 and   4) shr 2) = 1) then
     St[10] := 'Hard Disk Type 47 Data Area                          │ DOS 1KB'
else St[10] := 'Hard Disk Type 47 Data Area                          │ 0:300';

if (((Port11 and   2) shr 1) = 1) then
     St[11] := 'Wait for <F1> if any error                           │ Enabled'
else St[11] := 'Wait for <F1> if any error                           │ Disabled';

St[12] := Line3;

if ((Port11 and   1) = 1) then
     St[13] := 'System Boot Up Num Lock                              │ On'
else St[13] := 'System Boot Up Num Lock                              │ Off';

St[14] := Line3;

if ((Port35 and   1) = 1) then
     St[15] :='Numeric Processor Test                               │ Enabled'
else St[15] :='Numeric Processor Test                               │ Disabled';

if (((Port2d and 128) shr 7) = 1) then
     St[16] := 'Weitek Processor                                     │ Present'
else St[16] := 'Weitek Processor                                     │ Absent';

St[17] := Line3;

if (((Port2d and  64) shr 6) = 1) then
     St[18] := 'Floppy Drive Seek at Boot                            │ Enabled'
else St[18] := 'Floppy Drive Seek at Boot                            │ Disabled';

if (((Port2d and  32) shr 5) = 1) then
     St[19] := 'System Boot Up Sequence                              │ A:, C:'
else St[19] := 'System Boot Up Sequence                              │ C:, A:';

if (((Port2d and  16) shr 4) = 1) then
     St[20] := 'System Boot Up CPU Speed                             │ High'
else St[20] := 'System Boot Up CPU Speed                             │ Low';

St[21] := Line3;

if (((Port2d and   8) shr 3) = 1) then
     St[22] := 'External Cache Memory                                │ Enabled'
else St[22] := 'External Cache Memory                                │ Disabled';

if (((Port2d and   4) shr 2) = 1) then
     St[23] := 'Internal Cache Memory                                │ Enabled'
else St[23] := 'Internal Cache Memory                                │ Disabled';

St[24] := Line3;

if (((Port2d and   2) shr 1) = 1) then
     St[25] := 'Fast Gate A20 Option                                 │ Enabled'
else St[25] := 'Fast Gate A20 Option                                 │ Disabled';

if ((Port2d and   1) = 1) then
     St[26] := 'Turbo Switch Function                                │ Enabled'
else St[26] := 'Turbo Switch Function                                │ Disabled';

if (((Port34 and  64) shr 6) = 1) then
     St[27] := 'Password Checking Option                             │ Always'
else St[27] := 'Password Checking Option                             │ Setup';

St[28] := Line3;

if (((Port35 and   4) shr 2) = 1) then
     St[29] :='Video   ROM Shadow C000, 32K                         │ Enabled'
else St[29] :='Video   ROM Shadow C000, 32K                         │ Disabled';

if (((Port34 and  32) shr 5) = 1) then
     St[30] := 'Adaptor ROM Shadow C800, 32K                         │ Enabled'
else St[30] := 'Adaptor ROM Shadow C800, 32K                         │ Disabled';

if (((Port34 and   8) shr 3) = 1) then
     St[31] := 'Adaptor ROM Shadow D000, 32K                         │ Enabled'
else St[31] := 'Adaptor ROM Shadow D000, 32K                         │ Disabled';

if (((Port34 and   2) shr 1) = 1) then
     St[32] :='Adaptor ROM Shadow D800, 32K                         │ Enabled'
else St[32] :='Adaptor ROM Shadow D800, 32K                         │ Disabled';

if (((Port35 and 128) shr 7) = 1) then
     St[33] :='Adaptor ROM Shadow E000, 32K                         │ Enabled'
else St[33] :='Adaptor ROM Shadow E000, 32K                         │ Disabled';

if (((Port35 and  32) shr 5) = 1) then
     St[34] :='Adaptor ROM Shadow E800, 32K                         │ Enabled'
else St[34] :='Adaptor ROM Shadow E800, 32K                         │ Disabled';

St[35] := Line3;

if (((Port34 and 128) shr 7) = 1) then
     St[36] := 'BootSector Virus Protection                          │ Enabled'
else St[36] := 'BootSector Virus Protection                          │ Disabled';

if (((Port33 and  16) shr 4) = 1) then
     St[37] :='AUTO Config Function                                 │ Enabled'
else St[37] :='AUTO Config Function                                 │ Disabled';

St[38] := Line3;

if (((Port36 and 192) shr 6) = 0) then
     St[39] :='DRAM Speed Option                                    │ Slowest'
else if (((Port36 and 192) shr 6) = 1) then
     St[39] :='DRAM Speed Option                                    │ Slower'
else if (((Port36 and 192) shr 6) = 2) then
     St[39] :='DRAM Speed Option                                    │ Faster'
else if (((Port36 and 192) shr 6) = 3) then
     St[39] :='DRAM Speed Option                                    │ Fastest';

if (((Port33 and  32) shr 5) = 1) then
     St[40] :='DRAM Write CAS Pulse                                 │ 1 T'
else St[40] :='DRAM Write CAS Pulse                                 │ 2 T';

if (((Port35 and  64) shr 6) = 1) then
     St[41] :='DRAM Write Cycle                                     │ 0 W/S'
else St[41] :='DRAM Write Cycle                                     │ 1 W/S';

if (((Port34 and   4) shr 2) = 1) then
     St[42] := 'DRAM Hidden Refresh                                  │ Enabled'
else St[42] :='DRAM Hidden Refresh                                  │ Disabled';

St[43] := Line3;

if (((Port36 and   8) shr 3) = 1) then
     St[44] :='Cache Write Back Option                              │ W/THROUGH'
else St[44] :='Cache Write Back Option                              │ W/BACK';

if (((Port36 and   4) shr 2) = 1) then
     St[45] :='Cache Write Cycle Option                             │ 2 T'
else St[45] :='Cache Write Cycle Option                             │ 3 T';

if (((Port36 and  32) shr 5) = 1) then
     St[46] :='Cache Burst Read Cycle                               │ 2 T'
else St[46] :='Cache Burst Read Cycle                               │ 1 T';

St[47] := Line3;

if ((Port36 and   7) = 0) then
     St[48] :='Bus Clock Frequency Select                           │ 7.15 MHz'
else if ((Port36 and   7) = 1) then
     St[48] :='Bus Clock Frequency Select                           │ 1/10 CLK'
else if ((Port36 and   7) = 2) then
     St[48] :='Bus Clock Frequency Select                           │ 1/8 CLK'
else if ((Port36 and   7) = 3) then
     St[48] :='Bus Clock Frequency Select                           │ 1/6 CLK'
else if ((Port36 and   7) = 4) then
     St[48] :='Bus Clock Frequency Select                           │ 1/5 CLK'
else if ((Port36 and   7) = 5) then
     St[48] :='Bus Clock Frequency Select                           │ 1/4 CLK'
else if ((Port36 and   7) = 6) then
     St[48] :='Bus Clock Frequency Select                           │ 1/3 CLK'
else if ((Port36 and   7) = 7) then
     St[48] :='Bus Clock Frequency Select                           │ 1/2 CLK';

if (((Port35 and   8) shr 3) = 1) then
     St[49] :='Video Cacheable Option                               │ Enabled'
else St[49] :='Video Cacheable Option                               │ Disabled';

if ((Port34 and   1) = 1) then
     St[50] :='BIOS Cacheable Option                                │ Enabled'
else St[50] :='BIOS Cacheable Option                                │ Disabled';

if (((Port34 and  16) shr 4) = 1) then
     St[51] := 'Latch Local Bus Device                               │ ?'
else St[51] := 'Latch Local Bus Device                               │ T3';

if (((Port33 and  64) shr 6) = 1) then
     St[52] :='Local Bus Ready                                      │ ?'
else St[52] :='Local Bus Ready                                      │ SYNC';

St[53] := Line3;

if (((Port11 and 128) shr 7) = 1) then
     St[54] := 'Mouse support Option                                 │ Enabled'
else St[54] := 'Mouse support Option                                 │ Disabled';

if (((Port35 and   2) shr 1) = 1) then
     St[55] :='Auto Cacheable Area                                  │ Enabled'
else St[55] :='Auto Cacheable Area                                  │ Disabled';



St[56] := Line1;
Str (HddType:21, St2);
St[57] := '│ First hard disk type                                 │ '+St2+' │';
Str (HddType2:21, St2);
St[58] := '│ Second hard disk type                                │ '+St2+' │';
St[59] := Line3;
Str (Cylindre:21, St2);
St[60] := '│ Cylinders number                                     │ '+St2+' │';
Str (WCylindre:21, St2);
St[61] := '│ Number of Write Precompensation cylinders            │ '+St2+' │';
Str (PzCylindre:21, St2);
St[62] := '│ Number of Parking Zone cylinders                     │ '+St2+' │';
Str (Head:21, St2);
St[63] := '│ Head number                                          │ '+St2+' │';
Str (Sectors:21, St2);
St[64] := '│ Sectors number                                       │ '+St2+' │';
St[65] := Line3;
Str (TailleHdd:21, St2);
St[66] := '│ First hard disk size (in MB)                         │ '+St2+' │';
St[67] := Line2;

St[68] := Line4;
St[69] := '│ The first array represent the Advanced CMOS Setup.   These values  are very  │';
St[70] := '│ important for a correct use of your computer.                                │';
St[71] := '│                                                                              │';
St[72] := '│ Keep  this page near your  PC then, you could restore these  values if there │';
St[73] := '│ are deleted by a defect software  (your PC should''nt run normally)           │';
St[74] := Line5;
St[75] := '';
St[76] := Line4;
St[77] := '│ Le premier tableau  représente l''"Advanced CMOS Setup".    Ces valeurs sont  │';
St[78] := '│ essentielles pour un fonctionnement correct de votre ordinateur.             │';
St[79] := '│                                                                              │';
St[80] := '│ Conservez toujours cette page près de votre ordinateur pour  pouvoir, en cas │';
St[81] := '│ de besoin, restorer ces données (avec des  données incorrectes, votre  PC ne │';
St[82] := '│ fonctionnera plus correctement).                                             │';
St[83] := Line5;
St[84] := '│ Conservez toujours cette page près de votre ordinateur pour  pouvoir, en cas │';
St[85] := '│ de besoin, restorer ces données (avec des  données incorrectes, votre  PC ne │';
St[86] := '│ fonctionnera plus correctement).                                             │';

St[87] := Line4;
St[88] := '│            This program is a distributed freely as a Cardware.               │';
St[89] := '│        Please send-me a postcard from where you live.  Thank You!            │';
St[90] := '│                                                                              │';
St[91] := '│        Ce programme est distribué gratuitement en tant que Cardware.         │';
St[92] := '│     Veuillez, svp, m''envoyer une carte postale bien de chez vous. Merci!     │';
St[93] := '│                                                                              │';
St[94] := '│                                                                              │';
St[95] := '│                                  AVC SOFTWARE                                │';
St[96] := '│                              AVONTURE CHRISTOPHE                             │';
St[97] := '│                                                                              │';
St[98] := '│                         BOULEVARD EDMOND MACHTENS 157/53                     │';
St[99] := '│                                B-1080 BRUXELLES                              │';
St[100] :='│                                    BELGIQUE                                  │';
St[101] := Line5;

End;

Var I, J, K  : Byte;
    F        : Text;
    Ch       : Char;

Begin

  Detect;

  ClrScr;
  TextAttr := 30;
  WriteLn('');
  WriteLn('┌───────────────────────────────────────────────────────────────────────┐');
  WriteLn('│ CMOS : Create a Backup of your CMOS values   (c)  AVONTURE Christophe │');
  WriteLn('└───────────────────────────────────────────────────────────────────────┘');
  WriteLn('');
  TextAttr := 14;
  WriteLn('');
  WriteLn('');
  WriteLn('  This program use Standard Printer Escape Code...');
  WriteLn('');
  WriteLn('  Check your printer...  Put it OnLine...  ');
  WriteLn('');
  WriteLn('');
  WriteLn('  Press a Key to start the printing...  Or Escape to abort...');
  WriteLn('');

  REPEAT
  UNTIL KeyPressed;

  Ch := ReadKey; IF Ch = #0 THEN Ch := ReadKey;

  IF Ch = #27 THEN
     Halt;


  WriteLn ('  Printing in progress ...');
  WriteLn ('');

  Write (Lst,PrnInit);

  Write (Lst,'                                                              CMOS '+
       '(c) AVC Software '+#1+' AVONTURE Christophe           October 96');

  Write (Lst,#13+#10);
  Write (Lst,#13+#10);
  Write (Lst,#13+#10);

  Write (Lst,Line1+#13+#10);

  For I := 1 To 55 Do Begin
      St2 := St[I];
      If (St2[1] <> '├') then Begin
         K := 76-Length(St[I]);
         St2 := '';
         For J :=  1 to K Do St2 := St2 + ' ';
         If I in [3..18] then
            Write (Lst,'│ '+St[I]+St2+' │'+'               '+St[(68-3)+I]+#13+#10)
         Else If I in [25..36] then
            Write (Lst,'│ '+St[I]+St2+' │'+'               '+St[(56-25)+I]+#13+#10)
         Else If I in [42..55] then
            Write (Lst,'│ '+St[I]+St2+' │'+'               '+St[(87-42)+I]+#13+#10)
         Else Write (Lst,'│ '+St[I]+St2+' │'+#13+#10);
      End
      Else If I in [3..18] then
              Write (Lst,St[I]+'               '+St[(68-3)+I]+#13+#10)
           Else If I in [25..36] then
              Write (Lst,St[I]+'               '+St[(56-25)+I]+#13+#10)
           Else If I in [42..55] then
              Write (Lst,St[I]+'               '+St[(87-42)+I]+#13+#10)
           Else Write (Lst,St[I]+#13+#10);
  End;

  Write (Lst,Line2+'               '+St[101]+#13+#10);

  Write (Lst,PrnReset);

end.