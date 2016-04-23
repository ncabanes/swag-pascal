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