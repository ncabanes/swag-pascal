{
> No, actually there is no way to get 65536 bytes all in one go in real
> mode. Maybe you can do that in DPMI, maybe not.


 Sure you can.

 {$M $4000, 0, $7FFF}   { Reduce the TP heap }
 { This is required!!! }

 Function Alloc(NumPara : Word) : Word; Assembler;
 { Allocates the specified number of paragraphs (16 byte segments) }
 { in: NumPara - then number of paragraphs to allocate             }
 { out: $ffff - Couldn't allocate memory                           }
 {      other - segment pointer to memory (offset always 0)        }

 Asm
   Mov  ah,48h
   Mov  bx,NumPara
   Inc  bx
   Int  21h
   Jnc  @AllocOK
   Mov  ax,$FFFF
  @AllocOK:
 End;

 Procedure DeAlloc(Segment : Word); Assembler;
 { De-Allocates the memory at segment SEGMENT }

 Asm
   Mov  ah,49h
   Mov  es,Segment
   Int  21h
 End;

{
 Now you can allocate as much memory as your heart desires. You can typecast
 it by doint this:

   DataPointer := Ptr(Alloc(Sizeof(DataStructure) Div 16, 0);

 Pascal won't recognize anything over 64K (or allow it in type defs), but it
 can be done, and can be quite useful sometimes, especially for graphic file
 viewers where the file is usally over 64K, but it is nice to have it
 contigious in memory. In order to make this really useful, you should under-
 stand segments and offsets, but cause Pascal automatically strips the high
 bits off a longint index, you can't directly access the information.
}
