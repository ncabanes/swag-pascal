(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0149.PAS
  Description: Re: System Commands
  Author: MICHAEL VINCZE
  Date: 08-30-96  09:35
*)


{
> How do you get Delphi to execute system commands such as copy and rename?
> I tried using WINEXEC, but it doesn't recognize copy. It does handle the
> commands if I put them in a .bat file. I need this application to work
> across all three platforms (95, NT, 3.1). Do I have to do this with bat
> files? (yuck)
>
> Joe Silva
>
> p.s. Please reply via mail too. Thanks.

Try something like the following:
}

  procedure CopyDos (FileIn, FileOut: PChar);
  var
    CommandLine: array[0..$FF] of Char;
  begin
  StrCopy (CommandLine, GetEnvVar ('COMSPEC'));
  StrCat  (CommandLine, ' /c copy ');
  StrCat  (CommandLine, FileIn);
  StrCat  (CommandLine, ' ');
  StrCat  (CommandLine, FileOut);
  WinExec (CommandLine, sw_Hide);
  end;

COMSPEC is necessary in case you are running DR DOS.

Best regards,
Michael Vincze
vincze@ti.com

