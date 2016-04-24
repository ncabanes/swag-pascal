(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0256.PAS
  Description: SWAG GRAPHICS - Animation
  Author: WESLEY BURNS
  Date: 05-30-97  18:17
*)


------------------------------ ANIMATION TUTOR -------------------------------
Written by: Wesley Burns
EMail: microcon@iafrica.com
EMail me if you have any more questions!
------------------------------------------------------------------------------

 TWO POINTERS WILL BE NEEDED
  VAR BScreen^, VScreen:Pointer
  GetMEM(BScreen, 64000); {Pointer 1}
  GetMEM(VScreen, 64000); {Pointer 2}

 STEPS IN ANIMATING
  1. DRAW BACKGROUND(STATIC) SCREEN TO POINTER 1.
  2. COPY BACKGROUND TO VIRTUAL SCREEN(POINTER 2).
  3. DRAW ALL NEW GRAPHICS TO VIRTUAL SCREEN(POINTER 2).
  4. WHEN STEP 3 IS DONE, COPY IT TO VIDEO RAM ($A000)
  5. IF BACKGROUND HAS NOT CHANGED YET, THEN GO TO STEP 2, ELSE GO TO STEP 1

------------------------------------------------------------------------------
Program Test;
Var BScreen, VScreen:Pointer
USES CRT;

Begin
 GetMem(BScreen, 64000); {64000 bytes holds one screen page}
 GetMem(VScreen, 64000);

 {STEP 1 - DRAW BACKGROUND}
  FILLCHAR(BScreen^, 64000, 1); {PLANE BLUE SCREEN}
  {LOOK IN THE MEMORY PART OF SWAG FOR FAST MEMORY FILLING}

  REPEAT
   {STEP 2 - COPY BACKGOUND TO POINTER 2}
    MOVE(BScreen^, VScreen^, 64000);
    {LOOK IN THE MEMORY PART OF SWAG FOR FAST MEMORY MOVING PROCEDURE}
 
   {STEP 3 - DRAW YOUR SPITES}
    {LOOK IN THE GRAPHICS PART OF SWAG FOR MY PROCEDURE ON FAST MASKING
SPRITES}
 
   {WAIT RETRACE - LOOK IN SWAG FOR A WAIT RETRACE PROCEDURE -
    SMOOTHS UP YOUR GRAPHICS}

   {STEP 4 - COPY YOUR NEW FRAME TO SCREEN}
    MOVE(VScreen^, MEM[$A000:0000], 64000)
    {LOOK IN THE MEMORY PART OF SWAG FOR FAST MEMORY MOVING PROCEDURE}
  
   {STEP 5 - UPDATE BACKGROUND OF GAME, IF NEEDED}
  UNTIL KEYPRESSED;

 FreeMem(BScreen, 64000); FreeMem(VScreen, 64000);
End.




