(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0031.PAS
  Description: Change the cursor aspect in textmode
  Author: AVONTURE CHRISTOPHE
  Date: 03-04-97  13:18
*)

{

   Change the cursor aspect in text mode


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

Type
   CursorType = (cNormal, cInsert);

PROCEDURE Set_Cursor (cType : CursorType); ASSEMBLER;

ASM

    Cmp  cType, cNormal
    Je   @Normal

    Mov  Ah, 01h
    Mov  Cl, 15h
    Mov  Ch, 01h

    Jmp  @Call

@Normal:

    Mov  Ah, 01h
    Mov  Cx, 0607h

@Call:

    Int  10h

END;

Begin

   { Set the cursor normal }

   Set_Cursor (cNormal);

   { Set the cursor like a square -like used in an insert mode- }

   Set_Cursor (cInsert);

End;

