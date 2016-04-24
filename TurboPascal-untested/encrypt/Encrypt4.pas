(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0007.PAS
  Description: ENCRYPT4.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:40
*)

{ JC> I was wondering what Format you Programmers out there use to make
 JC> registration codes.  I was fooling around With a letter standing For
 JC> another letter but thats too simple.  How can I go about writing
 JC> bullet proof (or at least bullet resistant)  registration codes.  BTW,
 JC> this is not an over the modem Type Program.  if you understand what
 JC> I'm TRYinG to say, I wopuld RealLY appreciate a response.  Thanks a
 JC> lot!!!
}


Program RegCode;

Uses Crt;

Var
  ch : Char;
  Name : String;

Function MakeRegCode(S:String): LongInt;

Var
 I: LongInt;
 B: Byte;

begin
 I:=0;   { Could make this something else if you want it more random looking }
 For B:=1 to Length(S)
  Do I:=I+ord(S[B]); { Could make it ord(S[B]+SomeValue) to make it more
                interesting }
 MakeRegCode:=I;
end;

begin

 Writeln;
 Writeln;
 Write('Enter SysOp Name : ');
 Readln(Name);
 Writeln;
 Writeln('The resultant code was ',MakeRegCode(Name));
 Writeln;
 ch:=ReadKey;

end.


{You can also add a BBS Name or a City or anything else you want. just keep on
adding it to the I Var in the MakeRegCode proc.  to check to see if a reg code
is valid, just Compare the registration code he already has (in a cfg File
comewhere I assume) With the one generated this part of code.  if they match,
then is is a good code... if not... then he didn't register.
}

