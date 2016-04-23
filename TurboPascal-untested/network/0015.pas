{
>I need a way to get the current user name from the netware shell.
>For instance, if I'm logged into server MYSERVER as user SUPERVISOR,
>I need some way to get 'supervisor' as the user name.  (Kind of like
>WHOAMI would return: You are user SUPERVISOR on server MYSERVER)

In our library of routines we've developed (and continue to do so) lots of
routines for Novell Netware.  The following routines (developed by Peter Ogden
is to and myself) are to get the current user and I hope I've removed all our
inter-library references so that it's of use to you:
}

type
  String48 = string [48];

const
  NetError : Integer = 0;

function GetConnNo : Byte; assembler;

asm
        MOV  AX, $DC00
        INT  $21
end;

procedure GetConnInfo (ConnectionNum : Byte; var ObjType : Word;
                            var ObjName : String48);

var
  ReqBuf :     record
                      Size       : Word;
                      FixedValue : Byte;
                      ConnNumber : Byte;
                 end;

  ReplyBuf :     record
                      Size       : Word;
                      ID         : LongInt;
                      ObType     : Word;
                      Name       : array [1..48] of Byte;
                      Reserved   : Byte;
                      LoginTime  : array [1..7] of Byte;
                 end;

  Regs        : Registers;
  Counter     : Integer;
  NameString  : String;

begin
  with ReqBuf do
  begin
       Size := SizeOf (ReqBuf) - 2;
       FixedValue := $16;
       ConnNumber := ConnectionNum;
  end;

  ReplyBuf.Size := SizeOf (ReplyBuf) - 2;
  with Regs do
  begin
       AH := $E3;
       DS := Seg (ReqBuf);
       SI := Ofs (ReqBuf);
       ES := Seg (ReplyBuf);
       DI := Ofs (ReplyBuf);
       MsDos (Regs);

       NetError := AL;
       if NetError <> 0 then
       begin
            ObjType := 0;
            ObjName := '';
       end
       else
            with ReplyBuf do
            if ID <> 0 then
            begin
                 Counter := 1;
                 NameString := '';
                 while (Name[Counter] <> 0) do
                 begin
                      NameString := NameString + Chr (Name [Counter]);
                      Inc (Counter);
                 end;
                 ObjName := NameString;
                 ObjType := Swap (ObType);
            end
            else
            begin
                 ObType := 0;
                 ObjName := '';
            end;
  end;
end;

function GetUserID : String48;

var
  CN : Byte;
  UserName : String48;
  ObjType : Word;

begin
  CN := GetConnNo;
  GetConnInfo (CN, ObjType, UserName);
  GetUserID := UserName;
end;


I use this with Novell Netware 386 v3.11, as that is the Network that most of
our Commercial Applications have been developed for.  I know speed ups are
possible especially in processing the ASCIIZ, but hey we only call this routine
once in an application so it's not high on our priorities for optimisation.

