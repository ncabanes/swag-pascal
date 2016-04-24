(*
  Category: SWAG Title: JOYSTICK ROUTINES
  Original name: 0002.PAS
  Description: JOYSTCK2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{
Anyone know how to read the Joystick.... I only need Joy(1) read....
I have used 1 Procedure i d/led, but all it did was tell me if the buttons
were down (it didnt work in telling me which direction (it should of))
}
Program JOYSTICK;

Uses Crt, Dos;

(*
WRITTEN BY JAMES P. MCADAMS - 25 DECEMBER 1984

Program DEMONSTRATinG THE USE of TURBO PASCAL to ACCESS THE
IBM-PC GAME CONTROL ADAPTER. THE TWO Function CALLS ARE EACH
CompLETE in ITSELF. EITHER ONE or BOTH CAN BE MOVED to ANY
Program THAT NEEDS THE USE of JOYSTICKS or PADDLES.
*)



Var
I: Integer;
TEMP: Byte;


   Function BUTtoN_PRESSED (WHICH_ONE: Char): Boolean;
   (* RETURN True if THE BUTtoN IS PRESSED *)
   Const
      JOYPorT = $201; (* LOCATION of THE GAME PorT *)
   Var
      MASK: Byte;
   begin
   if not (WHICH_ONE in ['A'..'D']) then WHICH_ONE := 'A';
   Case WHICH_ONE of
      'A': MASK := 16;
      'B': MASK := 32;
      'C': MASK := 64;
      'D': MASK := 128;
      end;
   BUTtoN_PRESSED := (PorT [JOYPorT] and MASK) = 0;
   end; (* BUTtoN_PRESSED *)


   Function JOYSTICK_POS (WHICH_ONE: Char): Integer;
   (*
   With A KRAFT JOYSTICK, VALUES RETURNED ARE in THE RANGE 4 to ABOUT
   140. if YOUR MACHinE RUNS FASTER THAN A STandARD IBM-PC or if YOU
   MODifY YOUR GAME ADAPTER CARD With BIGGER CAPACItoRS, YOU WILL
   GET LARGER COUNTS and YOU MUST MODifY "MAXCOUNT".

   CALLinG A JOYSTICK THAT IS not in USE or ONE THAT HAS GONE
   OVER-RANGE (COUNT REACHED MAXCOUNT) YIELDS A VALUE of 0.
   *)
   Const
      MAXCOUNT =  2000; (* MODifY THIS if YOU CAN GET LONGER COUNTS     *)
      JOYPorT  = $201; (* For inForMATION ONLY: LOC of GAME inPUT PorT *)
   Var
      COUNTER: Integer;
      MASK: Byte;
   begin
   if not (WHICH_ONE in ['A'..'D']) then WHICH_ONE := 'A';
   Case WHICH_ONE of
      'A': MASK := 1;
      'B': MASK := 2;
      'C': MASK := 4;
      'D': MASK := 8;
      end;
   (*
   THIS ASSEMBLY CODE CAUses THE CX REGISTER to COUNT doWN FROM "MAXCOUNT"
   toWARD ZERO. WHEN CX REACHES ZERO or WHEN THE ONE-SHOT ON THE GAME
   ADAPTER TIMES OUT, THE LOOPinG StoPS and "COUNTER" IS ASSIGNED THE NUMBER
   of COUNTS THAT toOK PLACE. MAXCOUNT SHOULD BE CHOSEN SO THAT CX NEVER
   REACHES 0 SO THAT THE USABLE RANGE of THE JOYSTICK WILL not BE LIMITED.
   *)
   Inline (
      $B9/MAXCOUNT/       (*       MOV CX,MAXCOUNT inITIALIZE doWN-COUNTER *)
      $BA/JOYPorT/        (*       MOV DX,JOYPorT  PorT ADDR of JOYSTICKS  *)
      $8A/$A6/MASK/       (*       MOV AH,MASK[BP] MASK For DESIRED 1-SHOT *)
      $EE/                (*       OUT DX,AL       START THE ONE-SHOTS     *)
      $EC/                (* READ: in  AL,DX       READ THE ONESHOTS       *)
      $84/$C4/            (*      TEST AL,AH       CHECK DESIRED ONE-SHOT  *)
      $E0/$FB/            (*    LOOPNZ READ        Repeat Until TIMED OUT  *)
      $89/$8E/COUNTER);   (*       MOV COUNTER[BP],CX  THIS MAKES CX AVAIL-*)
                          (*                           ABLE to TURBO       *)
   if COUNTER = 0
      then JOYSTICK_POS := 0 (* OVER-RANGE or not in USE *)
      else JOYSTICK_POS := MAXCOUNT - COUNTER;
   end; (* JOYSTICK_POS *)


begin    (***** DEMO Program - MAin CODE *****)
ClrScr;
GotoXY (1, 2);
WriteLN ('JOYSTICKS':10, 'BUTtoNS':10);
Write   ('A':5, 'B':5, 'A':5, 'B':5);

While True do (* PRESS CTRL C to StoP THE Program *)
   begin
   GotoXY (1, 5);
   Write (JOYSTICK_POS ('A'):5, JOYSTICK_POS ('B'):5);
   if BUTtoN_PRESSED ('A')
      then Write ('PRES':5)
      else Write ('UP':5);
   if BUTtoN_PRESSED ('B')
      then Write ('PRES':5)
      else Write ('UP':5);
   end;
end.

