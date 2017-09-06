(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0011.PAS
  Description: PASSWORD.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:40
*)

{ JL>Help me guys. I'm learning about reading from a File. I am creating a
 JL>Program that will let you set passWord and test a passWord.

 JL>Also how do you make the screen print a Character like .... instead of a
 JL>Word.  So when you enter in a passWord like in BBS it won't show it?

------------------------------------X----------------------------------------
}

Program TestPW;

{
Programmer      : Chet Kress (FidoNet 1:283/120.4)
Been Tested?    : YES, this has been tested.  It works!
original Date   : 01/01/93
Current Version : v1.0
Language        : Turbo Pascal v7.0
Purpose         : Make a passWord routine
}

Uses Crt;

Procedure TestPassWord;

Const
  DataFile = 'PW.DAT'; {The name of the data File containing the passWord}
  {Just have one line in the PW.DAT File, and use that as the passWord}

Var
  PassWordFile : Text; {The name assigned to the data File}
  PassCH : Char; {A Character that the user has entered}
  TempPassWord : String; {The temporary passWord from the user}
  ThePW : String; {The Real passWord from the data File}

begin {TestPassWord}
  Assign (PassWordFile, DataFile);
  Reset (PassWordFile);
  ClrScr;
  TempPassWord := '';
  Write ('Enter passWord: ');
{
  I replaced the Readln With this Repeat..Until loop so you can see the
  "periods" instead of the Characters (like you wanted).  This is a simple
  routine, but it should suffice For what you want it to do.  It has some
  error checking and backspacing is available too.
}
  Repeat
    PassCH :=  ReadKey;
    if (PassCH = #8) and (Length(TempPassWord) > 0) then
      begin
        Delete (TempPassWord, Length(TempPassWord), 1);
        GotoXY (WhereX-1, WhereY);
        Write (' ');
        GotoXY (WhereX-1, WhereY);
      end;
    if (PassCH >= #32) and (PassCH <= #255) then
      begin
        TempPassWord := TempPassWord + PassCH;
        Write ('.');
      end;
  Until (PassCH = #13);
  Writeln;
  Readln (PassWordFile, ThePW);        { <-- You Forgot to add this line }
  if TempPassWord = ThePW then
    begin
      Writeln ('You have received access.');
      Writeln ('Loading Program.');
      { Do whatever else you want to here }
    end
  else
    begin
      Writeln ('Wrong PassWord.');
    end;
  Close (PassWordFile);
end; {TestPassWord}

begin {Main}
  TestPassWord;
end. {Main}
