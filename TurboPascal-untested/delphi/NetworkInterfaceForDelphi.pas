(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0067.PAS
  Description: Network Interface for DELPHI
  Author: VARIOUS AUTHORS
  Date: 11-24-95  10:16
*)

(*
   I hope somebody finds the following code useful.
This code has been adapted from ALLSWAG.  It returns the Network
station number, user name and full name.  I have tested it with
Novell Netware 3.12 and WFW.

    At least I hope this will save some of you some time.  It took me
some time to figure out exactly how to get it done.  (Now it appears
clearer :))

Even if you don't understand the details, you can still use the
functions.  For the sake of those like me, who are new to the
language:  You can copy the code in between the dotted lines and put
it in a file and use it as a unit.
*)

unit General;

interface
function StationNumber:byte;
Function GetNetUserName : String;
Function GetNetFullName(User_Name : String) : String;

implementation
function StationNumber:byte;  { MY logical Station(connection)-Number }
var
 RetVal : Byte;
begin
 asm
   MOV AH, $DC;
   INT 21H
   MOV RetVal, AL;
 end;
 Result := Retval;
end;


Function GetNetUserName : String;

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

  W      : Word;
  RetVal : Byte;

begin
                                       { "Get Connection Information"       }
  with Request do                      { Initialize request buffer:         }
  begin
    Len := 2;                                    { Buffer length,           }
    Func := $16;                                 { API function,            }
    Conn := StationNumber                    { Returned in previous call!         }
  end;

  Reply.Len := SizeOf( Reply ) - 2;    { Initialize reply buffer length     }

  asm
   push ds
   push ss
   push es
    MOV AH, $E3;                         { Connection Services API call       }
    LEA SI, Request               { Location of request buffer         }
    PUSH SS
    POP DS
    LEA DI, Reply                { Location of reply buffer           }
    PUSH SS
    POP ES
    INT 21H
    MOV RetVal, AL
    pop ES
    pop SS
    pop DS
  end;

  if ( RetVal = 0 )                        { Success code returned in AL   }
       and ( Hi( Reply.Obj ) = 1 )          { Obj of 1 is a user,           }
       and ( Lo( Reply.Obj ) = 0 ) then     {   stored Hi-Lo                }
    with Reply do
    begin
      Move( Name, Result[ 1 ], 48 );           { Convert ASCIIZ to string }
      Result[ 0 ] := #48;
      W := 1;
      while ( Result[ W ] <> #0 )
            and ( W < 48 ) do
        Inc( W );
      Result[ 0 ] := Char( W - 1 )
    end
  else
    Result := ''
end;


Function GetNetFullName(User_Name : String) : String;
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
  Reply.ReplyBufferLength := SizeOf(Reply) - 2;

 asm
  PUSH SS
  PUSH DS
  MOV AH, $E3;
  LEA SI, Request
  PUSH SS
  POP DS
  LEA DI,Reply
  PUSH SS
  POP ES
  INT 21H
  POP DS
  POP SS
 end;

  Temp := '';
  Counter := 1;
  While (Reply.PropertyValue[Counter] <> #0) do
  begin
    Temp := Temp + Reply.PropertyValue[Counter];
    inc(Counter);
  end;
  Result := Temp;
end;
end.
-------------Code Ends------------------------

Sajan Thomas
Computer and Communication Services Department
Milwaukee School of Engineering
Milwaukee, WI 53202
Tel. (414)-277-7498
(Internet Address: THOMAS@MSOE.EDU)

-------------------------------------------------------------------------------

   Here is a function to get the login date and time from Netware.
The function returns the result in TDateTime format, which can be
formatted with any of the built-in routines.
e.g.
DateString := FormatDateTime('"I  logged in on" dddd, mmmm d, yyyy, ' +
'"at" hh:mm AM/PM', GetLoginTime(stationnumber)); 
 returns the login date and time for the current user. ( It uses the 
StationNumber function that I posted yesterday).
   You can find out the login date and time for any station, provided 
you _know_ the station number.  The results of the function when 
supplied a non-existant station number is unpredictable!!
   Again, this function has been adapted from material found in the 
ALLSWAG.ZIP file.

  Hope this helps someone.

Enjoy,
Sajan.


----code begins--------------------
Function GetLoginTime(LogicalStationNo: Integer):TDateTime;
Var
  I,X            : Integer;
  RequestBuffer  : Record
                     PacketLength : Integer;
                     FunctionVal  : Byte;
                     ConnectionNo : Byte;
                   end;
  ReplyBuffer    : Record
                     ReturnLength : Integer;
                     UniqueID1    : Packed Array [1..2] of Byte;
                     UniqueID2    : Packed Array [1..2] of Byte;
                     ConnType     : Packed Array [1..2] of Byte;
                     ObjectName   : Packed Array [1..48] of Byte;
                     LoginTime    : Packed Array [1..8] of Byte;
                   end;
  Month          : String[3];
  Year,
  Day,
  Hour,
  Minute         : String[2];
  retval : byte;

Begin
  With RequestBuffer Do begin
    PacketLength := 2;
    FunctionVal := 22;  { 22 = Get Station Info }
    ConnectionNo := LogicalStationNo;
  end;
  ReplyBuffer.ReturnLength := 62;
  asm
    push ds
    push ss
    mov ah, $e3;
    lea SI, RequestBuffer
    push ss
    pop ds
    lea di, ReplyBuffer
    push ss
    pop es
    int 21h
    mov retval, al
    pop ss
    pop ds
  end;
  if RetVal = 0 then
   begin
    With ReplyBuffer Do
     begin
       Str(LoginTime[1]:2,Year);
       Str(LoginTime[2], Month);
       Str(LoginTime[3]:2,Day);
       Str(LoginTime[4]:2,Hour);
       Str(LoginTime[5]:2,Minute);
       if Day[1] = ' ' then Day[1] := '0';
       if Hour[1] = ' ' then Hour[1] := '0';
       if Minute[1] = ' ' then Minute[1] := '0';
       Result := StrToDateTime(Month+'/'+Day+'/'+Year+' ' + Hour + ':' + Minute);
    end { With };
   end;
End;
----------code ends-----------------

Sajan Thomas
Computer and Communication Services Department
Milwaukee School of Engineering
Milwaukee, WI 53202
Tel. (414)-277-7498
(Internet Address: THOMAS@MSOE.EDU)

unit Netapi;

interface
type
 TFileServerName = array [0..48] of char;
 TNodeAddress = record
    nodeHi : longint;
    nodeLo : Integer;
    end;


Function GetConnectionNumber:Longint;
Function GetConnectionID(fileServerName:TFileServerName; var connectionID:integer):Integer;
Function GetDefaultConnectionID:Integer;
Procedure GetFileServerName(connID:integer; var fileservername:TFileServerName);
Function GetInternetAddress(connectionNumber : longint; var networkNumber: longint;
         var physicalNodeAddress:TNodeAddress; var socketNumber: integer):Integer;
Function IntSwap(unswappedInteger : integer):Integer;
Function LongSwap(unswappedLong : longint):Longint;
Function GetNetworkNumber : String;
Function GetNodeAddress : String;
{Call example: FileServerName(GetDefaultConnectionID) }
Function FileServerName(connID : integer) : String;


implementation
Uses SysUtils;
Function GetInternetAddress; external 'NWNETAPI';
Function GetConnectionNumber; external 'NWNETAPI';
Function GetConnectionID; external 'NWNETAPI';
Function GetDefaultConnectionID; external 'NWNETAPI';
Procedure GetFileServerName; external 'NWNETAPI';
Function IntSwap; external 'NWNETAPI';
Function LongSwap; external 'NWNETAPI';

Function GetNetworkNumber : String;
 var
  networkno : longint;
  nodeaddr : TNodeAddress;
  socketno : integer;
Begin
 GetInternetAddress(GetConnectionNumber,networkno, nodeaddr, socketno);
 Result := IntToHex(LongSwap(networkno), 1);
End;



Function GetNodeAddress : String;
 var
  networkno : longint;
  nodeaddr : TNodeAddress;
  socketno : integer;
Begin
 GetInternetAddress(GetConnectionNumber,networkno, nodeaddr, socketno);
 Result := IntToHex(longswap(nodeaddr.nodehi), 1) +
           IntToHex(lo(nodeaddr.nodelo), 1) +
           IntToHex(hi(nodeaddr.nodelo), 1);
End;

Function FileServerName(connID : integer) : String;
Var
 FSName : TFileServerName;
Begin
 FillChar(FSName, 48, ' ');  {need to initialize it}
 GetFileServerName(connID, FSName);
 Result := StrPas(FSName);
End;

end.
---------- code ends---------------

Enjoy,
Sajan.

Sajan Thomas
Computer and Communication Services Department
Milwaukee School of Engineering
Milwaukee, WI 53202
Tel. (414)-277-7498
(Internet Address: THOMAS@MSOE.EDU)


