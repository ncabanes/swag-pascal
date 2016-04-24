(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0002.PAS
  Description: DETCADLB.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

Uses
  Crt; (* Crt Needed For Delay Routine *)

Function AdlibCard : Boolean;
 (* Routine to determine if a Adlib compatible card is installed *)
Var
  Val1,Val2 : Byte;
begin
  Port[$388] := 4;      (* Write 60h to register 4 *)
  Delay(3);             (* Which resets timer 1 and 2 *)
  Port[$389] := $60;
  Delay(23);
  Port[$388] := 4;      (* Write 80h to register 4 *)
  Delay(3);             (* Which enables interrupts *)
  Port[$389] := $80;
  Delay(23);
  Val1 := Port[$388];   (* Read status Byte *)
  Port[$388] := 2;      (* Write ffh to register 2 *)
  Delay(3);             (* Which is also Timer 1 *)
  Port[$389] := $FF;
  Delay(23);
  Port[$388] := 4;      (* Write 21h to register 4 *)
  Delay(3);             (* Which will Start Timer 1 *)
  Port[$389] := $21;
  Delay(85);            (* wait 85 microseconds *)
  Val2 := Port[$388];   (* read status Byte *)
  Port[$388] := 4;      (* Repeat the first to steps *)
  Delay(3);             (* Which will reset both Timers *)
  Port[$389] := $60;
  Delay(23);
  Port[$388] := 4;
  Delay(3);
  Port[$389] := $80;    (* Now test the status Bytes saved *)
  If ((Val1 And $e0) = 0) And ((Val2 And $e0) = $c0) Then
    AdlibCard := True    (* Card was found *)
  Else
    AdlibCard := False;  (* No Card Installed *)
end;

begin
  ClrScr;                       (* Clear the Screen *)
  Write(' Adlib Card ');        (* Prepare Response *)
  If AdlibCard Then
    Writeln( 'Found!')           (* There is one *)
  Else
    Writeln('Not Found!');       (* Not! *)
end.

