(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0119.PAS
  Description: Get the serial of a disk
  Author: AVONTURE CHRISTOPHE
  Date: 11-29-96  08:17
*)

{

   Get the serial number of a disk


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

Const
   Hexa : Array [0..15] of Char =
       ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

Type DiskInfo = Record                { Work area }
          Info_Level  : Word;         { Always zero }
          Serial_Num  : LongInt;      { Serial number of the specified disk }
          Volume_Name : String[11];   { 'NO_NAME' or volume name }
          File_Sys    : String[8];    { 'FAT12' or 'FAT16' }
     End;

Var
   Ch1 , Ch2 : Byte;
   Ch3 , Ch4 : Byte;
   DInfo            : DiskInfo;
   First, Second    : Word;

Function Word2Hex(Number: Word) : String;
Begin

  Ch1 := (Number SHR 8) SHR 4;
  Ch2 := (Number SHR 8) - (Ch1 SHL 4);
  Ch3 := (Number AND $FF) SHR 4;
  Ch4 := (Number AND $FF) - (Ch3 SHL 4);

  Word2Hex := Hexa[Ch1]+Hexa[Ch2]+Hexa[Ch3]+Hexa[Ch4];

End;

Begin

   Asm
       Mov Ax, Seg DInfo
       Mov Ds, Ax
       Mov Dx, Offset DInfo           { Load Adress of my target table }
       Mov Ax, 6900h                  { Get Serial Number }
       Mov Bl, 0                      { Drive : 0 default, 1 A:, 2 B:, ... }
       Xor Bh, Bh                     { Always 0 under DOS }
       Int 21h                        { Only if you have DOS 4.0+  }
       Mov Ax, Word Ptr [DInfo.Serial_Num + 2]
       Mov First, Ax                  { First  word of the serial number }
       Mov Ax, Word Ptr DInfo.Serial_Num
       Mov Second, Ax                 { Second word of the serial number }
   End;
   Writeln('Serial number of this disk : ',Word2Hex(First),'-',Word2Hex(Second));
End.
