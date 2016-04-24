(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0001.PAS
  Description: Copy File #1
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

Program Copy;

Var InFile, OutFile : File;
    Buffer          : Array[ 1..512 ] Of Char;
    NumberRead,
    NumberWritten   : Word;

begin
   If ParamCount <> 2 Then Halt( 1 );
   Assign( InFile, ParamStr( 1 ) );
   Reset ( InFile, 1 );     {This is Reset For unTyped Files}
   Assign  ( OutFile, ParamStr( 2 ) );
   ReWrite ( OutFile, 1 );  {This is ReWrite For unTyped Files}
   Repeat
      BlockRead ( InFile, Buffer, Sizeof( Buffer ), NumberRead );
      BlockWrite( OutFile, Buffer, NumberRead, NumberWritten );
   Until (NumberRead = 0) or (NumberRead <> NumberWritten);
   Close( InFile );
   Close( OutFile );
end.

