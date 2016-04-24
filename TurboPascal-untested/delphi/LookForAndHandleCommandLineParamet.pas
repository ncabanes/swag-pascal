(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0287.PAS
  Description: Look for and handle command line paramet
  Author: CHAMI
  Date: 05-30-97  18:17
*)

--------------------------------------------------------------------------------
Most command line programs and some Windows programs has the ability to
look for and handle parameters passed to it such as /? /HELP /Q. If you
want to add the same capability to your Delphi programs, you can start
with a function like this:

program cmdline;

uses
  SysUtils;

function CmdLineParamFound(
  sParamName : String ) : Boolean;
const
  c_token = '/';
var
  i     : integer;
  sTemp : string;
begin
  result := False;

  for i := 1 to ParamCount do
  begin
    sTemp := ParamStr( i );
    if( c_token = sTemp[ 1 ] )then
    begin
      if( ( c_token +
            UpperCase( sParamName ) ) =
              UpperCase( sTemp ) )then
      begin
        result := True;
        exit;
      end;
    end;
  end;
end;

begin
  if( CmdLineParamFound( 'HELP' ) )then
  begin
    //
    // display help here...
    //
  end;
end.


If you need more help, look up ParamStr() and ParamCount functions in
your help files.

