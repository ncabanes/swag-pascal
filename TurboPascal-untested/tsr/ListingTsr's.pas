(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0024.PAS
  Description: Listing TSR's
  Author: ALEX KARIPIDIS
  Date: 05-25-94  08:24
*)

{
Well, here it is, a program that lists TSRs loaded.
Anybody willing to enhance it so that it checks the HMA for TSRs too?

Oh, were do I send this so that it gets into the next SWAGS release?  I was
unable to find such a program in the all the SWAGS until (and inclusive) the
latest February '94 release...

{ ------------ Cut Here ----------- }

Program ListTSRs;

{
   Written by Alex Karipidis on the 8th of March 1994.
   Donated to the public domain.  Use this code freely.

   You can contact me at:
     Fidonet  : 2:410/204.4
     Hellasnet: 7:2000/50.4
     SBCnet   : 14:2100/201.4
     Zyxelnet : 16:800/108.4
     Pascalnet: 115:3005/1.4

   If you enhance/improve this code in any way, I would appreciate it if you
   sent me a copy of your version.

   I will not be responsible for any damage caused by this code.

   This program will print a list of all programs currently loaded in
   memory.
}

Type

  pMCB_Rec = ^MCB_Rec;
  MCB_Rec = Record
    ChainID    : Byte; { 77 if part of MCB chain, 90 if last MCB allocated }
    Owner      : Word; { PSP segment address of the MCB's owner }
    Paragraphs : Word; { Paragraphs related to this MCB }
  end;

Var
  MCB                  : pMCB_Rec;
  InVarsSeg, InVarsOfs : Word;
  EnvSeg, Counter      : Word;

begin
  { Dos service 52h returns the address of the DOS "invars" table in ES:BX }
           { !!! This is an undocumented DOS function !!! }
  asm
    MOV   AH,52h
    INT   21h
    MOV   InVarsSeg,ES
    MOV   InVarsOfs,BX
  end;

  {
    The word before the "invars" table is the segment of the first MCB
    allocated by DOS.
  }
  MCB := Ptr (MemW [InVarsSeg:InVarsOfs-2], 0);

  While MCB^.ChainID <> 90 do  { While valid MCBs exist... }
  begin

    If MCB^.Owner = Seg (MCB^) + 1 then { If MCB owns itself, then... }
    begin
      Write ('In memory: ');  { We've found a program in memory }

      {
        The word at offset 2Ch of the program's PSP contains the value of
        the program's environment data area.  That's were the program's name
        is located.
      }
      EnvSeg := MemW [MCB^.Owner:$2C];

      {
        The environment also contains the environment variables as ASCIIZ
        (null-terminated) strings.  Two consecutive null (0) bytes mean that
        the environment variables have ended and the program name follows
        after 4 bytes.  That is also an ASCIIZ string.
      }
      Counter := 0;
      While (Mem [EnvSeg:Counter  ] <> 0) or  { Find 2 consecutive }
            (Mem [EnvSeg:Counter+1] <> 0) do  { null bytes.        }
        inc (counter);

      inc (counter,4); { Program name follows after 4 bytes }

      While Mem [EnvSeg:Counter] <> 0 do { Print program name }
      begin
        Write (Char (Mem [EnvSeg : Counter]));
        Inc (counter);
      end;

      WriteLn;

    end;

    { Point to next MCB }
    MCB := Ptr (Seg (MCB^) + MCB^.Paragraphs + 1, 0);
  end;

  {
    Note: The last MCB is not processed!
          It is assumed that it is this program's MCB.
          In your programs, this may or may not be the case.
  }

end.

