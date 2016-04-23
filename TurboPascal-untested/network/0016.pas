{
>To anyone that can help me, this is my problem: I want to program a simple
>E-Mail program for Novel Network v2.1.  But i have one problem.  While in
>a pascal programmed program, how do i find out the user login name
>automatically?

I tested this code on Novell 3.11, but the API calls should also work on your
2.1 network.  The login time is also available as a by-product.
}

program ShowUser;

uses Dos;

type
  NovTime = record
    LoginYear  : byte;       { 0 to 99; if < 80, year is in 21st century }
    LoginMonth : byte;       { 1 to 12 }
    LoginDay   : byte;       { 1 to 31 }
    LoginHour  : byte;       { 0 to 23 }
    LoginMin   : byte;       { 0 to 59 }
    LoginSec   : byte;       { 0 to 59 }
    LoginDOW   : byte;       { 0 to 6, 0 = Sunday, 1 = Monday ... }
  end;


{ GetConnInfo --------------------------------------------------------------}
{ -----------                                                               }

function GetConnInfo(     Connection : Byte;
                      var ConnName   : string;
                      var ConnTime   : NovTime ) : Byte;
VAR
  NameArray : array[ 0..48 ] of Byte absolute ConnName;
  NovRegs   : Registers;

  Request : record
    Len   : Word;
    Func  : Byte;
    Conn  : Byte
  end;

  Reply    : record
    Len    : Word;
    ID     : Longint;
    Obj    : Word;                        { Object type }
    Name   : array[ 1..48 ] of Byte;
    Time   : NovTime;
    Filler : Byte       { Isn't in my Novell docs, but won't work without!  }
  end;


begin
  with Request do                      { Initialize request buffer:         }
  begin
    Len := 2;                                    { Buffer length,           }
    Func := $16;                                 { API function,            }
    Conn := Connection                           { Connection # to query    }
  end;

  Reply.Len := SizeOf( Reply ) - 2;    { Initialize reply buffer length     }

  with NovRegs do
  begin
    AH := $E3;                         { Connection Services API call       }
    DS := Seg( Request );              { Location of request buffer         }
    SI := Ofs( Request );
    ES := Seg( Reply );                { Location of reply buffer           }
    DI := Ofs( Reply );
    MsDos( NovRegs );                  { Make the call                      }
    GetConnInfo := AL                  { Completion code is function result }
  end;

  with Reply do
  begin
    Obj := Swap( Obj );                          { If object is a user and  }
    if ( Obj = 1 ) and ( NovRegs.AL = 0 ) then   {   call was successful,   }
    begin
      ConnTime := Time;                          { Return login time        }
      Move( Name, NameArray[ 1 ], 48 );          { Convert ASCIIZ to string }
      NameArray[ 0 ] := 1;
      while ( NameArray[ NameArray[ 0 ] ] <> 0 )
            and ( NameArray[ 0 ] < 48 ) do
        Inc( NameArray[ 0 ] );
      Dec( NameArray[ 0 ] )
    end
  end
end;


{ GetConnNo ----------------------------------------------------------------}
{ ---------                                                                 }

function GetConnNo : byte;

var
  NovRegs : Registers;

begin
  NovRegs.AH := $DC;
  MsDos( NovRegs );
  GetConnNo := NovRegs.AL
end;


{ MAIN =====================================================================}
{ ====                                                                      }

var
  UserName  : string;
  LoginTime : NovTime;

begin
  GetConnInfo( GetConnNo, UserName, LoginTime );
  WriteLn( 'User''s name is ', UserName )
end.
