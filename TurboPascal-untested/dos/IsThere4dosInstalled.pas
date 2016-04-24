(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0030.PAS
  Description: Is there 4DOS installed
  Author: MIKE DICKSON
  Date: 09-26-93  10:18
*)

(*
From: MIKE DICKSON
Subj: IS There 4DOS
*)

        FUNCTION Running4DOS : Boolean;
        VAR Regs : Registers;
        begin
           With Regs do
              begin
                 ax := $D44D;
                 bx := $00;
              end;
           Intr ($2F, Regs);
           if Regs.ax = $44DD then Running4DOS := TRUE
                              else Running4DOS := FALSE
        end;


