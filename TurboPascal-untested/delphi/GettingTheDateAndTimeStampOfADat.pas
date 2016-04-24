(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0293.PAS
  Description: Getting the date and time stamp of a dat
  Author: JOHN RUTHERFORD
  Date: 08-30-97  10:08
*)


{==============================================================================}
function FileDateTime( const cFileName:string ; cDateTime: char ) : string ;
{ accepts filename in a string and the cDateTime case/type to return }
var
   iFile : integer   ;  {handle to open file}
   fBuff : TOfStruct ;  {Win API structure for file information}
   cDate : string    ;  {actually holds the file Date and Time}
   tDate : tDateTime ;  {Delphi type actually a double}
   iTime : longInt   ;
   aName : array [0..99] of char ; {easy pre-sized pChar type }
begin
     {help to find actual path}
     if cFileName = 'Children.dbf' then
        strPCopy( aName, '\aDelph16\Stella\Data\' + cFileName )
     else
        strPCopy( aName, cFileName ) ;

     try
        iFile := _lopen( aName, OF_SHARE_COMPAT );
        iTime :=  FileGetDate(iFile);
        tDate :=  FileDateToDateTime( iTime);
        cDate :=  DateTimeToStr( tDate );
     {  showMessage( 'Date/time ' +cTime );  }

        case cDateTime OF      {Date, Time, Both}
          'D' : FileDateTime := copy(cDate, 1, pos(' ', cDate)-1) ;
          'T' : FileDateTime := copy(cDate, length(cDate)-8, length(cDate)) ;
          'B' : FileDateTime := cDate ;
        end ;

     _lclose(iFile) ;
     except
           showMessage('FileDateTime FAILED');
     end
end ;
{==============================================================================}

john.rutherford@emarkt.com

