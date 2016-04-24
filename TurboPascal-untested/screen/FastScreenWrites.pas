(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0053.PAS
  Description: Fast Screen Writes
  Author: MICHAEL HOENIE
  Date: 01-27-94  12:00
*)

{
├>Ok, here is a simple problem that is really annoying me!
├>Whenever I try to put a character at position x=80, y=25, the screen
├>scrolls up one line.

Don't use gotoxy(); and write(); statements. Try this one:
}
  Procedure FastWrite(col,row,Attrib:Byte; Str:string80);
  begin
    inline
      ($1E/$1E/$8A/$86/row/$B3/$50/$F6/$E3/$2B/$DB/$8A/$9E/col/
      $03/$C3/$03/$C0/$8B/$F8/$be/$00/$00/$8A/$BE/attrib/
      $8a/$8e/str/$22/$c9/$74/$3e/$2b/$c0/$8E/$D8/$A0/$49/$04/
      $1F/$2C/$07/$74/$22/$BA/$00/$B8/$8E/$DA/$BA/$DA/$03/$46/
      $8a/$9A/str/$EC/$A8/$01/$75/$FB/$FA/$EC/$A8/$01/$74/$FB/
      $89/$1D/$47/$47/$E2/$Ea/$2A/$C0/$74/$10/$BA/$00/$B0/
      $8E/$DA/$46/$8a/$9A/str/$89/$1D/$47/$47/$E2/$F5/$1F);
  end;


