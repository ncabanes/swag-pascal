(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0023.PAS
  Description: ARJ Password Cracker
  Author: JON ZARATE
  Date: 11-26-94  04:55
*)

{
> Do somebody have a ARJ 2.41 Password finder, because I have packed
> some of my pascal codes and grabled it with password and now .... hmmmm
> I can't extract the ARJ file with the password.  I must have typed a
> different password when I pascked those files.

In my next two messages is ARJCRACK.PAS.  It's a program that may
help you find that password.  It's EXTREMELY slow, but if you are
really really really (did i say really? :)) ) desperate about it
you might want to give it a try.

You will need to place this in a FAST machine (one you won't need
for a LONG while) along with ARJ.EXE and the password-encrypted
archive on the same drive & directory.

Tips to speed it up:

 + Using "ARJ v archive," pick the smallest file you can find (but not
   less than about 10 bytes), that was archived using the store method
   (no compression)
 + Move ARJ.EXE, ARJCRACK.EXE and the archive in a ram drive.
 + Remove some characters in PassSet that you think you never used
   as the password (maybe  ~ ` ^ etc..)
 + Run it in plain old DOS *NOT* under Windows or DESQview or OS2.
 + Start off the [last_password] parameter with "a" x minimum-password-
   length-that-you-normaly-use.  Something like:

   arjcrack sources small.pas aaaa
                              ^^^^
             if you're sure that you never use passwords that are less
             than 4 characters

jon.zarate@vidgame.com
}

{$M 8192, 0, 0}
{$V-}{$S-}{$G+}{$X+}{$R-}

uses
 Crt, Dos;


const
 PassSet : String =
   'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' +
   '0123456789`=\[];'',./~!@#$%^&*()_{}:';

var
 Pw  : String;
 Arc : String;
 Fn  : String;
 Prev: String;

procedure Sounder(R : Integer);
var
 N : Integer;

begin
 N:=2000;
 repeat
  Sound(N);
  N:=N + R;
  if (N < 50) then N:=2000 else
  if (N > 2000) then N:=50;
  Delay(2);
 until (KeyPressed);
 NoSound;
end;

procedure Crack;
var
 I : Word;
 Pw: String[40];
 J : Word;
 X : Word;
 Y : Word;
 Z : array[1..41] of Byte;
 C : Word;

begin
 FillChar(Z, SizeOf(Z), 0);

 if (Prev <> '') then
  begin
   for I:=1 to Length(Prev) do
    begin
     Z[I]:=Pos(Prev[I], PassSet);
     if (Z[I] = 0) then
      begin
       writeln('Invalid character in [last_password]');
       Halt;
      end;
    end;

   Pw:=Prev;
   X:=Length(Pw);
   J:=X;
  end else
  begin
   Pw:=PassSet[1];
   Z[1]:=1;
   X:=1;
   J:=1;
  end;


 repeat
  Pw[1]:=PassSet[Z[1]];

  writeln;
  writeln;
  writeln('////////////////////////////////////////////////////////////');
  writeln('ARJ t ', Arc, ' ', Fn, ' -g', Pw);
  writeln;
  SwapVectors;
  Exec('ARJ.EXE', 't ' + Arc + ' ' + Fn + ' -g' + Pw);
  SwapVectors;
  writeln('////////////////////////////////////////////////////////////');

  C:=DosExitCode;

  if ((C = 0) and (DosError = 0)) then
   begin
    writeln;
    writeln;
    writeln('Hey I found it!!');
    writeln('The password is -- ', Pw);
    writeln;
    Sounder(10);
    Halt
   end;

  if ((C <> 3) or (DosError <> 0)) then
   begin
    writeln;
    writeln('Duhh... What happened?? Why did I get an EXITCODE of ',
      C, ' and a DOSERROR of ', DosError, '??');
    Sounder(-30);
    Halt
   end;

  if (KeyPressed) then
   begin
    writeln('ARJCRACK aborted.');
    writeln('Last password used was --> ', Pw, ' <--');
    Halt;
   end;

  inc(Z[1]);
  for I:=1 to X do
   begin
    if (Z[I] > Length(PassSet)) then
     begin
      Z[I]:=1;
      inc(Z[I + 1]);
      if (I = J) then
       begin
        inc(J);
        inc(X);
        Pw[0]:=Chr(X);
        Pw[X]:=PassSet[1];
       end;
     end;
     Pw[I]:=PassSet[Z[I]];
    end;
 until (X > Length(Pw));

 writeln('Sorry, I can''t find the password!!');
 Sounder(-2);
end;

begin
 writeln;
 writeln;
 writeln('ARJ Password Cracker Version 0.10');
 writeln('by Jonathan Zarate');
 writeln;
 writeln('Password character set: ', PassSet);
 writeln;
 if ((ParamCount < 2) or (ParamCount > 3)) then
  begin
   writeln('Usage: ARJCRACK <archive> <file_to_crack> [last_password]');
   Halt;
  end;

 Arc:=ParamStr(1);
 Fn:=ParamStr(2);
 Prev:=ParamStr(3);
 Crack;
end.

