(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0005.PAS
  Description: REG1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)


  Registers Demo

PB>        Procedure GetScreenType (Var SType: Char);
PB>        Var
PB>          Regs: Registers;
PB>        begin
PB>          Regs.AH := $0F;
PB>          Intr($10, Regs);
PB>          if Regs.AL = 7 then
PB>              sType := 'M';        <<<<<
PB>          else
PB>              sType := 'C';
PB>        end;

   This Procedure would be ideal For a Function...
           Function GetScreenType:Char;
           ...
           if Regs.AL=7 then
              GetScreenType := 'M'
           else
              GetScreenType := 'C';
           ...

