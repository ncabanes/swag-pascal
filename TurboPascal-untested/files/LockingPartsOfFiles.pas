(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0079.PAS
  Description: Locking Parts of Files
  Author: KEN BURROWS
  Date: 09-04-95  11:56
*)

{
> Does anyone know how to lock parts of a file in pascal?  I'm working on JAM
> message base support, and I need to know how to lock it (and check if it's
> locked, etc).  Example code appreciated. (I have to lock the first byte of
> a file.  How exactly would I go about doing this?)
}

function FLock(Lock:byte; Handle: Word; Pos,Len: LongInt): Word; Assembler;
ASM
  mov   AL,Lock   { subfunction 0: lock region   }
                  { subfunction 1: unlock region }
  mov   AH,$5C    { DOS function $5C: FLOCK    }
  mov   BX,Handle { put FileHandle in BX       }
  les   DX,Pos
  mov   CX,ES     { CX:DX begin position       }
  les   DI,Len
  mov   SI,ES     { SI:DI length lockarea      }
  int   $21       { Call DOS ...               }
  jb    @End      { if error then return AX    }
  xor   AX,AX     { else return 0              }
 @End:
end {FLock};

