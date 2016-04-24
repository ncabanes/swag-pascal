(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0020.PAS
  Description: Re: Get Server Date
  Author: JIM ROBB
  Date: 05-25-94  08:22
*)

{
 MP> Can someone show me what a PASCAL procedure would look like to
 MP> encapsulate the following information (from Brown's int list):
 MP> INT 21 - Novell NetWare - FILE SERVER - GET FILE SERVER DATE AND TIME

I tested this on our Novell 3.11 network:
}

program ServDate;

uses Dos;

type
  tDateAndTime = record
    Year      : Byte;
    Month     : Byte;
    Day       : Byte;
    Hours     : Byte;
    Minutes   : Byte;
    Seconds   : Byte;
    DayOfWeek : Byte
  end;

  String9 = string[ 9 ];

const
  DayArray : array[ 0..6 ] of String9 =
             ( 'Sunday', 'Monday', 'Tuesday', 'Wednesday',
               'Thursday', 'Friday', 'Saturday' );

  MonthArray : array[ 1..12 ] of String9 =
               ( 'January', 'February', 'March', 'April', 'May', 'June',
                 'July', 'August', 'September', 'October', 'November',
                 'December' );


function GetFileServerDateAndTime( var DTBuf : tDateAndTime ) : Byte;

var NovRegs : Registers;

begin
  with NovRegs do
  begin
    AH := $E7;
    DS := Seg( DTBuf );
    DX := Ofs( DTBuf );
    MSDos( NovRegs );
    GetFileServerDateAndTime := AL
  end
end;

var
  DateAndTime : tDateAndTime;
  ResultCode  : Byte;

begin
  ResultCode := GetFileServerDateAndTime( DateAndTime );
  if ResultCode = 0 then
    with DateAndTime do
    begin
      Write( 'File server date/time = ', DayArray[ DayOfWeek ], ', ',
             MonthArray[ Month ], ' ', Day );
      if ( Year < 80 ) then
        Write( ', 20', Year )
      else
        Write( ', 19', Year );
      WriteLn( ' at ', Hours, ':', Minutes, ':', Seconds )
    end
  else
    WriteLn( 'Date/time call unsuccessful' )
end.

