(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0001.PAS
  Description: Center Text
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:08
*)

{
>Anyways, does anyone here have a quick and easy Procedure or
>Function For centering Text?
}

Program CenterIt_Demo;

Uses
  Crt;

{ Display a String centered on the screen. }
Procedure DisplayCenter(st_Temp : String; by_Yaxis : Byte);
begin
  GotoXY(((Succ(Lo(WindMax)) - Length(st_Temp)) div 2), by_Yaxis);
  Writeln(st_Temp);
end; {DisplayCenter. }

Var
  by_OldAttr : Byte;

begin
  ClrScr;
  DisplayCenter('The Spirit of Elvis says... Hi!', 10);
  ReadKey;
end.

