(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0003.PAS
  Description: GET-ID2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:52
*)

{
>  Okay, here goes.  I am using Borland Pascal 7.0 under MS-Dos 5.0.
>Basically, the Program I am writing will be run under Novell Netware
>3.11.  What I need to do is determine the User's full user name.  I
>could do this using Novell Interrupts, but they are impossible to figure
>out (At least For me).  So what I wanted to do, was use Novell's
>"WHOAMI" command.  What this does is return the user's full name and

Well, I think you'll find it harder to to a Dos exec and parse the output after
reading it from a File than asking Netware what it is.  Plus you must depend on
the user having access to use the command.  I'm on some Novell networks where
that command File is not present because it wasn't considered important.
Here's how to get the user name from Netware...
}
Program UserID;

Uses
  Dos, Strings;

Type
  RequestBuf = Record
    RequestLen    : Word; { Number of Bytes in the rest of the Record }
    SubFunction   : Byte; { Function from Novell we are requesting }
    ConnectionNum : Byte; { Connection number that is making the call }
  end;

  ReplyBuf = Record
    ReplyLength : Word;    { Number of Bytes in the rest of the Record }
    ObjectId    : LongInt; { Novell refers to everything by Objects like users}
    ObjectType  : Word;
    ObjectName  : Array[1..48] of Char;
    LoginTime   : Array[1..7] of Char;
  end;

Var
  I:Word;
  ReqBuf   : RequestBuf;
  RepBuf   : ReplyBuf;
  Regs     : Registers;
  UserName : String[48];

begin
  Regs.AH := $DC;
  MsDos(Regs); { Get the connection number }

  ReqBuf.RequestLen    := 2;        { User ID request, must give connection }
  ReqBuf.SubFunction   := $16;      { number                                }
  ReqBuf.ConnectionNum := Regs.AL;

  RepBuf.ReplyLength := 61; { Return buffer For name }

  Regs.AH := $E3;         { Call Novell For user name }
  Regs.DS := Seg(ReqBuf); { Passing it the request buffer indicating }
  Regs.SI := Ofs(ReqBuf); { the data we want and a reply buffer to send }
  Regs.ES := Seg(RepBuf); { us back the information }
  Regs.DI := Ofs(RepBuf);
  MsDos(Regs);

  { Object name now contians the users ID, use the StringS Unit Functions }
  { to print the null-terminated String }
  WriteLn(StrPas(@RepBuf.ObjectName));
end.

{
That will read in a Novell User ID For you.
}

