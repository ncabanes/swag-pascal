(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0028.PAS
  Description: Novell Reading
  Author: KEVIN R. PIERCE
  Date: 08-25-94  09:10
*)

Unit Litl_Nov;

(**********************************************************************)
(*    by Kevin R. Pierce                                              *)
(*       December 29, 1991                                            *)
(*    Kev1n@aol.com                                                   *)
(**********************************************************************)
interface

type
  LoginTime    = array[0..6] of byte;

  ConnectionInfo = record
                     Object_ID   : longint;
                     Object_Type : word;
                     Object_Name : array[1..48] of char;
                     Login_Time  : LoginTime;
                     ApplicationNumber     : word;    {swap & display Hex}
                   end;

  CnxnInfoREQUEST = record
                      ReqBuffLen : word;  {always = 2}
                      Mask       : byte;  {always = 16h}
                      CnxnNo     : byte;  { >1 }
                    end;

  CnxnInfoREPLY = record
                    RepBuffLen : word;  {always = SIZEOF(ConnectionInfo) }
                    Data       : ConnectionInfo;
                  end;


function  NOV_GetConnectionNumber:integer;
procedure NOV_GetConnectionInformation(connection:byte; var
Result:ConnectionInfo);

(**********************************************************************)
implementation

uses
  dos;

function NOV_GetConnectionNumber:integer;
  var
    buf : registers;
  begin
    buf.AH:=$DC;
    intr($21,buf);
    NOV_GetConnectionNumber:=buf.AL;
  end;

procedure NOV_GetConnectionInformation(connection:byte; var
Result:ConnectionInfo);
  var
    buf : registers;
    req : CnxnInfoREQUEST;
    rep : CnxnInfoREPLY;
  begin
    with buf do
      begin
        AH:=$E3;
        DS:=seg(req);
        SI:=ofs(req);
        ES:=seg(rep);
        DI:=ofs(rep);
      end;
    with req do
      begin
        ReqBuffLen := Sizeof(req)-2;
        Mask       := $16;
        CnxnNo     := Connection;
      end;
    fillchar(rep,sizeof(rep),0);
    rep.RepBuffLen:=Sizeof(rep)-2;
    intr($21,buf);
    Result:=rep.data;
  end;

end.



