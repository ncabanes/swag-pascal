(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0033.PAS
  Description: EXE File Format Header
  Author: JOHN STEPHENSON
  Date: 05-26-95  23:05
*)

{
> Now my only questions are, does
> anybody know the structure of an EXE header, and where do batch files
> fit into this whole mess.  Also, anybody know if I'm wrong?

 Batch files are interpreted by the COMMAND.COM, or NDOS.COM etc.  They
can not be run by any interrupt.

 The structure of an .exe header is:
}
  exehdr = record
    sig: array[1..2] of Char; { 4Dh, 5Ah signature (sometimes 5Ah, 4Dh) }
    rem512,         { image size remainder (program size mod 512, not including header)}
    pages,          { number of 512-byte pages needed to hold .EXE file (incl header)}
    RelocSize,      { number of relocation items}
    hsize,          { header size in paragraphs}
    minextra,       { minimum extra paragraphs needed}
    maxextra,       { maximum extra paragraphs needed}
    SSeg,           { stack segment}
    SOfs,           { stack offset}
    chksum: Word;   { word checksum of entire file}
    Entry: Pointer; { initial CS:IP}
    Reloc,          { offset of relocation table}
    Overlay: Word;  { overlay number}
    Junk: array[$1c..$3b] of Byte;
    New_Exe_Ofs: LongInt;
  end;

