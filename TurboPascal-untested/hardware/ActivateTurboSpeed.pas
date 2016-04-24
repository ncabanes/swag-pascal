(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0010.PAS
  Description: Activate TURBO Speed
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)

{ Does anyone out there know how to set the Software Turbo Speed on Mother
 boards without hitting the Turbo Switch or the <Ctrl> <Alt> <-> key to
 slow the system and or Speed it up again? Thanks...
}

Program speed;
Uses Dos,Crt;

Procedure do_speed(mode : String);
Var
 reg : Registers;
 oldmem : Byte;

begin
 oldmem := mem[$40:$17];
 if UpCase(mode[1]) = 'N' then
 begin
  reg.al := 74;
  Writeln('Speed set to NorMAL MODE');
 end else
 begin
  reg.al := 78;
  Writeln('Speed set to TURBO MODE');
 end;
 mem[$40:$17] := 140;
 reg.ah := $4F;
 intr($15,reg);
 mem[$40:$17] := oldmem;
end;

begin
 if paramcount < 1 then
 begin
  Writeln(' Speed.exe (c) by Werner Schlagnitweit 2:310/3.0');
  Writeln(' This Program should work on all machines which ');
  Writeln(' use the CTRL-ALT-+ key to toggle the speed     ');
  Writeln;
  Writeln(' Usage : Speed N  For normal NON TURBO mode');
  Writeln('         Speed T  For normal TURBO mode    ');
  halt;
 end else do_speed(paramstr(1));
end.

