(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0029.PAS
  Description: 286/8088 code
  Author: GREG ESTABROOKS
  Date: 05-25-94  08:03
*)

{
SE>I have Borland Pascal 7.0 and I ran acrost the idea of 286 and 8088 code
SE>specs in a program.  How can you detect for a 286 CPU and if present,
SE>switch $G to $G+ ?

 There should be a program somewhere in your TP disks that has a routine
 that detects whether or not a 286+ CPU is pressent. Unfortunately you
 can't have it change the status of $G. It's either on or off. You can
 either leave it on , detect CPU type, if its the wrong type leave a
 mesage and abort the program or not use the $G directive at all.

 Here is a simple CPU detection routine in case you can't find the one I
 mentioned:
}

CONST
      CPU     :ARRAY[0..3] Of STRING[13] =('8088/V20','80286',
                                          '80386/80486','80486');
FUNCTION CpuType :WORD; ASSEMBLER;
                 {  Returns a value depending on the type of CPU        }
                 {          0 = 8088/V20 or compatible                  }
                 {          1 = 80286    2 = 80386/80486+               }
ASM
  Xor DX,DX                             {  Clear DX                     }
  Push DX
  PopF                                  {  Clear Flags                  }
  PushF
  Pop AX                                {  Load Cleared Flags           }
  And AX,$0F000                         {  Check hi bits for F0h        }
  Cmp AX,$0F000
  Je @Quit                              {  Quit if 8088                 }
  Inc DX
  Mov AX,$0F000                         {  Now Check For 80286          }
  Push AX
  PopF
  PushF
  Pop AX
  And AX,$0F000                         {  If The top 4 bits aren't set }
  Jz @Quit                              {  Its a 80286+                 }
  Inc DX                                {  Else its a 80386 or better   }
@Quit:
  Mov AX,DX                             {  Return Result in AX          }
END;{CpuType}

BEGIN
  Writeln('Your CPU is a ',CPU[CpuType]);
END.

