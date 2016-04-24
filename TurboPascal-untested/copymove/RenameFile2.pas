(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0014.PAS
  Description: Rename File #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{
>I am interested in the source in Assembler or TP to move a File from one
>directory to another by means of the FAT table.  I have seen several
>small utilities to do this but I was unable to understand them after
>reverse engineering/disassembly.  (Don't worry, they were PD).  <G>
>Anyway, any help would be appreciated.  Thanks.

You don't Really need to do much. Dos Interrupt (21h), Function 56h, will
rename a File, and in essence move it if the source and destination
directories are not the same. That's all there is to it. I know Function
56h is available in Dos 3.3 and above. I am not sure about prior
versions.

On entry: AH      56H
          DS:DX   Pointer to an ASCIIZ String containing the drive, path,
                  and Filename of the File to be renamed.
          ES:DI   Pointer to an ASCIIZ String containing the new path and
                  Filename
On return AX      Error codes if carry flag set, NONE if carry flag not set

Below is some crude TP code I Typed on the fly. It may not be exactly right
but you get the idea.
}

Uses
  Dos;
Var
  Regs        : Registers;
  Source,
  Destination : PathStr;

begin
  { Add an ASCII 0 at the end of the Strings to male them ASCIIZ
    Strings, without actually affecting their actual lengths }
  Source[ord(Source[0])] := #0;
  Destination[ord(Destination[0])] := #0;

  { Set the Registers }
  Regs.AH := $56;
  Regs.DS := Seg(Source[1]);
  Regs.DX := ofs(Source[1]);
  Regs.ES := Seg(Destination[1]);
  Regs.DI := ofs(Destination[1]);

  { Do the Interrupt }
  Intr($21,Regs);
end.

