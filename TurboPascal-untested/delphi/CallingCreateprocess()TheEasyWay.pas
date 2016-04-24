(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0404.PAS
  Description: Calling CreateProcess() the easy way
  Author: SWAG SUPPORT TEAM
  Date: 01-02-98  07:34
*)


Calling CreateProcess() the easy way.

If you look up the CreateProcess() function in Win32 help, you'll notice
that there are more than three dozen parameters that you can optionally
setup before calling it. The good news is that you have to setup only a
small number of those parameters to make a simple CreateProcess() call as
demonstrated in the following function:

function CreateProcessSimple(
  sExecutableFilePath : string )
    : string;
var
  pi: TProcessInformation;
  si: TStartupInfo;
begin
  FillMemory( @si, sizeof( si ), 0 );
  si.cb := sizeof( si );

  CreateProcess(
    Nil,

    // path to the executable file:
    PChar( sExecutableFilePath ),

    Nil, Nil, False,
    NORMAL_PRIORITY_CLASS, Nil, Nil,
    si, pi );

  // "after calling code" such as
  // the code to wait until the
  // process is done should go here

  CloseHandle( pi.hProcess );
  CloseHandle( pi.hThread );
end;


Now, all you have to do is call CreateProcessSimple(), let's say to
run Windows' Notepad:

CreateProcessSimple( 'notepad' );



