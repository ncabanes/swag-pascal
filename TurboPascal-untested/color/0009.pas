{
I have seen a lot of applications that use highintensity background
colors in Text mode.  How do they do it??????
}

Program HighInt; {  91-5-30  Robert Mashlan
   Public Domain

   The following Program is an example of how to set the CrtC controller
   in in order that high intensity backgrounds may be displayed instead
   of blinking Characters, or use the the EGA/VGA BIOS to do the same
   thing.
}

Uses
   Dos, Crt;

Const
   HighIntesity = Blink;  (* high intesity attribute mask *)


Procedure HighIntensity( state : Boolean );
(* enables or disables high intensity background colors *)

Const
   BlinkBit   = $20;  (* For mode select port, bit 5 *)
   ModeSelofs = 4;    (* offset from CrtC port base *)

Var
   R : Registers;
   (* BIOS data area Variables *)
   CrtMode     : Byte Absolute $0040:$0065; (* current CrtC mode *)
   CrtPortBase : Word Absolute $0040:$0063; (* CrtC port base addr *)

   Function EgaBios : Boolean;
   { test For the existance of EGA/VGA BIOS }
   Var R : Registers;
   begin
      With R do begin
         AH := $12;
         BX := $ff10;
         Intr($10,R);
         EgaBios := BX <> $ff10;
      end;
   end;

begin
   if EgaBios then With R do begin  (* use EGA/VGA BIOS Function *)
      R.AX := $1003;
      if state then BL := 0
               else BL := 1;
      Intr($10,R);
   end else begin  (* Program CGA/MDA/Herc CrtC controller *)
      if state then  CrtMode := CrtMode and not BlinkBit
               else  CrtMode := CrtMode or BlinkBit;
      Port[ CrtPortBase + ModeSelofs ] := CrtMode;
   end;
end;


begin
   HighIntensity(True);
   if LastMode = 7 then
      TextAttr := $80 + $7E
    else
      Textattr := $80 + $6D;
   ClrScr;
   TextBackGround(green);
   GotoXY(20,11);
   Writeln('What do you think of this background?');
   GotoXY(1,25);
   Repeat Until ReadKey <> #0;
   HighIntensity(False);
   ClrScr;
end.
