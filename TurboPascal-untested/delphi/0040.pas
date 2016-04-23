
The following code demonstrates how to bring up the WinHelp "Search"
dialog for your application's help file.  You can use TApplication's
HelpCommand method to send the Help_PartialKey command to the WinHelp
system. The parameter for this command should be a PChar (cast to a
longint to circumvent typechecking) that contains the string on
which you'd like to search.  The example below uses an empty string,
which invokes "Search" dialog and leaves the edit control in the

dialog empty.

procedure TForm1.SearchHelp;
var
  P: PChar;
begin
  Application.HelpFile := 'c:\delphi\bin\delphi.hlp';
  P := StrNew('');
  Application.HelpCommand(Help_PartialKey, longint(P));
  StrDispose(P);
end;


