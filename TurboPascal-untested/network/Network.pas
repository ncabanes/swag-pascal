(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0010.PAS
  Description: Network 
  Author: KERRY SOKALSKY
  Date: 08-27-93  21:49
*)

{
-> I don't have an answer to your question, but would you happen to know
-> how to return a user's full name (as stored in syscon)?  Thanks.

I assume you already have the user's login name.  Here is a procedure
that will get a user's full name.  If you are going to do a lot of
Netware programming I suggest you get "Programmers Guide to Netware" by
Charles Rose. ISBN # 0-07-607029-8.  It documents all of the Netware
functions and also talks about IPX/SPX programming.
}

Uses
  Dos;

Var
  Regs : Registers;

Function Full_Name(User_Name : String) : String;
Type
  RequestBuffer = Record
    RequestBufferLength : Word;
    Code                : Byte;
    ObjectType          : Word;
    ObjectNameLength    : Byte;
    ObjectName          : Array[1..48] of char;
    SegmentNumber       : Byte;
    PropertyNameLength  : Byte;
    PropertyName        : Array[1..15] of char;
  end;

  ReplyBuffer = Record
    ReplyBufferLength : Word;
    PropertyValue     : Array[1..128] of char;
    MoreSegments      : Byte;
    PropertyFlags     : Byte;
  end;

Var
  Request : RequestBuffer;
  Reply   : ReplyBuffer;
  PropertyName : String[15];
  Counter : Byte;
  Temp    : String[128];

begin
  PropertyName := 'IDENTIFICATION';
  Request.RequestBufferLength := SizeOf(Request) - 2;
  Request.Code := $3D;
  Request.SegmentNumber := 1;
  Request.ObjectType := $0100;
  Request.ObjectNameLength := SizeOf(Request.ObjectName);
  FillChar(Request.ObjectName, SizeOf(Request.ObjectName), #0);

  For Counter := 1 to length(User_Name) do
    Request.ObjectName[Counter] := User_Name[Counter];

  Request.PropertyNameLength := SizeOf(Request.PropertyName);
  FillChar(Request.PropertyName, SizeOf(Request.PropertyName), #0);

  For Counter := 1 to Length(PropertyName) do
    Request.PropertyName[Counter] := PropertyName[Counter];

  Regs.AH := $E3;
  Regs.DS := Seg(Request);
  Regs.SI := Ofs(Request);

  Reply.ReplyBufferLength := SizeOf(Reply) - 2;
  Regs.ES := Seg(Reply);
  Regs.DI := Ofs(Reply);

  MSDos(Regs);

  Temp := '';
  Counter := 1;
  While (Reply.PropertyValue[Counter] <> #0) do
  begin
    Temp := Temp + Reply.PropertyValue[Counter];
    inc(Counter);
  end;
  Full_Name := Temp;
end;

begin
  Writeln(Full_Name('SOKALSKY'));
end.
