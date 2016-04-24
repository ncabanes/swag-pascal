(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0015.PAS
  Description: Drive Serial Number
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:38
*)

{
>How can [a disk serial number] be read from TP? Can it be changed other than
>by re-Formatting? I can't find any reference to serial number
>in the Dos 5.0 users guide except a passing one in the section
>on the ForMAT command.
}
Uses Dos;
Var  regs : Registers;
     LabelInfo : Record
       InfoLevel : Word;    {Always 0}
       SerialNum : LongInt;
       VolumeLabel : Array [1..11] of Char;
       FileSystemType : Array [1..8] of Char;
     end;
begin

  if lo(DosVersion)<4 then
    begin
      Writeln ('Only works With Dos 4.0 or higher');
      Exit;
    end;

  LabelInfo.InfoLevel := 0;       {Set Info level (0 is the only legal value)}
  With regs do
     begin
       ax := $6900;  {Function $69 With 0 in AL gets, With 1 in AL sets}
       bl := 0;      {Drive, 0 For default, 1 For A:, 2 For B:, ...}
       ds := seg(LabelInfo);  {DS:DX points at structure}
       dx := ofs(LabelInfo);
       es := 0;      {Do not have garbage in segment Registers}
       flags := 0;   {  or in flags}

       MsDos(Regs);

       if Odd(flags) then   {Carry set if error}
         begin
             Case AX of
               1:  Writeln ('Illegal attempt to get Label from network drv');
               5:  Writeln ('No Extended BPB on disk (Format old)');
             else  Writeln ('Unknown error');
             end;
         end;
    end;

{On return, fills SerialNum, VolumeLabel, and FileSystemType fields.
  places 'FAT12   ' or 'FAT16   ' in FileSystemType, For 12- or 16-bit FAT
entries.  With AL=1, will use info you store in LabelInfo to set disk's
extended BPB}

