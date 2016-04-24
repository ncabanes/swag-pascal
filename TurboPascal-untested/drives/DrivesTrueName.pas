(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0016.PAS
  Description: Drives TRUE name
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:38
*)

Program TrueName;  uses DOS;

   function RealName(FakeName:String):String;
   Var Temp:String;
   begin
     FakeName := FakeName + #0; { ASCIIZ }
     With Regs do
     begin
       AH := $60;
       DS := Seg(FakeName); SI := Ofs(FakeName[1]);
       ES := Seg(Temp);     DI := OfS(Temp[1]);
       INTR($21,Regs);
       DOSERROR := AX * ((Flags And FCarry) shr 7);
       Temp[0] := #255;
       Temp[0] := CHAR(POS(#0,Temp)-1);
     end;
     If DosError <> 0 then Temp := '';
     RealName := Temp;
   end;

begin  writeln( RealName( Paramstr(1) ) end.

