(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0047.PAS
  Description: EXISTDD Update
  Author: GAYLE DAVIS
  Date: 10-28-93  11:30
*)

{ Updated DRIVES.SWG on October 13, 1993 }

{ This give all the info on a bootable drive }
{ it replaces the EXIST-DD in DRIVES.SWG which DID NOT work }
{ updated by GDAVIS 10/13/93 }

Uses
  Crt,Dos;

Type
  bootrecptr = ^bootRecord;
  bootRecord = Record
       nj       : Array[0..2] of Byte;       {offset  0   Near jump code   }
       oem      : Array[0..7] of Byte;       {        3   OEM name and ver }
       Bytesec  : Word;                      {       11   Bytes/Sector     }
       sectclus : Byte;                      {       13   Sectors/cluster  }
       ressect  : Word;                      {       14   Reserved sectors }
       fattables: Byte;                      {       16   FAT tables       }
       direntrys: Word;                      {       17   Directory entries}
       logsec   : Word;                      {       19   Logical sectors  }
       MDS      : Byte;                      {       21   Media descriptor }
       FatSects : Word;                      {       22   FAT sectors      }
       Secstrak : Word;                      {       24   Sectors/track    }
       NumHeads : Word;                      {       26   Number of heads  }
       HidnSecs : Word;                      {       28   Hidden sectors   }
       bootcode : Array[0..415] of Byte;     {       30   boot code        }
       partcode : Array[0..15] of Byte;      {      446   partition info   }
       bootcode2: Array[0..49] of Byte;      {      462   rest of boot code}
     end;

Var
  boot : bootRecord;      { the boot Record Variable }

  FUNCTION DiskRead (Drive : CHAR; SSect, NSect : WORD; VAR Buffer) : WORD;
    { Read absolute disk sectors }

  VAR
      kbuff  : ARRAY [0..$1f] OF BYTE; {Read Ralf Brown's interrupt listing}
      kPtr   : POINTER;                {Int 25h - ES:[BP+1E] may change    }
      bufPtr : POINTER;

  BEGIN

    kPtr   := @kbuff;
    BufPtr := @buffer;

    Asm
      push  es
      push  bp
      push  di
      les   di, kPtr       { move past first 31 bytes   }
      mov   al, drive      { Gets the passed parameter. }
      AND   al, 1fh        { Cvt from ASCII to drive num }
      DEC   al             { Adjust because A: is drive 0 }
      mov   cx, nsect      { number of sectors to read }
      mov   dx, ssect      { starting at sector.. }
      push  ds
      lds   bx, bufptr      { Get the address of the buffer }
      mov   bp, di
      push  si
      INT   25h            { Do the drive read. }
      pop   si             { Remove the flags int 25h leaves on stack}
      pop   si
      pop   ds
      pop   di
      pop   bp
      pop   es
      jc    @1
      mov   @result, 0       { No errors, so set Function to zero }
      jmp   @Escape
      @1 :
      mov   @result, ax

    @Escape :
    END;
  END;

Procedure bootlook(Drive : Char);
Var
  ReadResult : WORD;
  I          : Integer;
begin
  { Get diskette info }
  ReadResult := DiskRead(Drive,0,1,boot);
  if ReadResult <> 0 then
  begin
  { Error code here , there are LOTS of them.. see a good DOS book
    most common will be :
    2 = Drive NOT ready
    7 = unknown media .. not a boot disk
    8 = sector not found .. not a boot disk }
  Writeln(LO(ReadResult));
  end
  else
  begin
  WITH Boot DO
  BEGIN
  { I'll just print a few of the possible items }
  Write('OEM         :  ');
  FOR I := 0 TO 7 DO WRITE(CHR(OEM[i]));
  Writeln;
  WriteLn('Dir Entrys  : ',DirEntrys : 4);
  WriteLn('Fat Tables  : ',FatTables : 4);
  WriteLn('Num Heads   : ',NumHeads : 4);
  WriteLn('Secs p/Trk  : ',SecsTrak : 4);
  WriteLn('Hidden Secs : ',HidnSecs : 4);
  END;
  end;

end;  { Procedure bootlook }

BEGIN
ClrScr;
BootLook('B');  { if drive isn't bootable, you'll get an error (7) }
Readkey;        { try it, this is a safe procedure                 }
END.

