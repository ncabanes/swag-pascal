{
From: JIM ROBB
Subj: Re: Netware "User name"

  I need a way to get the current user name from the netware shell.
  For instance, if I'm logged into server MYSERVER as user SUPERVISOR,
  I need some way to get 'supervisor' as the user name...

This should do the job.  The two calls are "Get Connection Number" (DCh) and
"Get Connection Information" (E3h 16h), both from the Connection Services API.
The calls work with Advanced Netware 1.0 and all later versions.  Code tested
on 3.11 NetWare.

Beware the weak error-checking - the program doesn't check the version of
Netware, or even that the user is logged onto the network.
}

program WhoBeMe;

uses Dos;


procedure GetUserName( var UserName : string );

var
  Request : record                     { Request buffer for "Get Conn Info" }
    Len  : Word;                       { Buffer length - 2                  }
    Func : Byte;                       { Subfunction number ( = $16 )       }
    Conn : Byte                        { Connection number to be researched }
  end;

  Reply    : record                    { Reply buffer for "Get Conn Info"   }
    Len    : Word;                     { Buffer length - 2                  }
    ID     : Longint;                  { Object ID (hi-lo order)            }
    Obj    : Word;                     { Object type (hi-lo order again)    }
    Name   : array[ 1..48 ] of Byte;   { Object name as ASCII string        }
    Time   : array[ 1.. 7 ] of Byte;   { Y, M, D, Hr, Min, Sec, DOW         }
                                       { Y < 80 is in the next century      }
                                       { DOW = 0 -> 6, Sunday -> Saturday   }
    Filler : Byte                      { Call screws up without this!       }
  end;

  Regs   : Registers;
  W      : Word;

begin
  Regs.AX := $DC00;                    { "Get Connection Number"            }
  MsDos( Regs );
                                       { "Get Connection Information"       }

  with Request do                      { Initialize request buffer:         }
  begin
    Len := 2;                                    { Buffer length,           }
    Func := $16;                                 { API function,            }
    Conn := Regs.AL                    { Returned in previous call!         }
  end;

  Reply.Len := SizeOf( Reply ) - 2;    { Initialize reply buffer length     }

  with Regs do
  begin
    AH := $E3;                         { Connection Services API call       }
    DS := Seg( Request );              { Location of request buffer         }
    SI := Ofs( Request );
    ES := Seg( Reply );                { Location of reply buffer           }
    DI := Ofs( Reply );
    MsDos( Regs )
  end;

  if ( Regs.AL = 0 )                        { Success code returned in AL   }
       and ( Hi( Reply.Obj ) = 1 )          { Obj of 1 is a user,           }
       and ( Lo( Reply.Obj ) = 0 ) then     {   stored Hi-Lo                }
    with Reply do
    begin
      Move( Name, UserName[ 1 ], 48 );           { Convert ASCIIZ to string }
      UserName[ 0 ] := #48;
      W := 1;
      while ( UserName[ W ] <> #0 )
            and ( W < 48 ) do
        Inc( W );
      UserName[ 0 ] := Char( W - 1 )
    end
  else
    UserName := ''
end;

var
  TheName : string;

begin
  GetUserName( TheName );
  WriteLn( 'I be ', TheName )
end.
