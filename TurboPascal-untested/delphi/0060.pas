

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