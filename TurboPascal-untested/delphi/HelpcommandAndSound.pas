(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0060.PAS
  Description: HelpCommand and Sound
  Author: N. FERNANDES
  Date: 11-24-95  10:15
*)



     procedure TForm1.HelpSearch(Sender: TObject);
     var
        HelpMacro:pchar;
     begin
          HelpMacro:='Search()';
          with Application do begin
               Application.HelpContext(1);
               HelpCommand(HELP_COMMAND,longint(HelpMacro));
          end;
     end;
        

