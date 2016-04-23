{
>: : DDE must be used for my task as WPWIN6 does not support OLE automation.
>
>
>        How can I call the Word Processor to print a DOC or mail merge?
>
>Dennis

Below is some sample code starting WPerfect and establishing a DDE link with it.
For talking to WinWord I use an OLE link. WordPerfect 6.x does not support OLE automation, hence
the need to revert to a DDE link to control Word Perfect.
}

procedure TFormCases.CreateWordPerfect(MyDocName : String13; Path : String );
var tme : TModuleEntry; h : Word; B : Boolean;
begin
 with DDEClientConv1 do  begin
  ServiceApplication := GWPPath; { Word Perfect path location as a string }
   tme.dwSize := sizeof(TModuleEntry);
   h := ModuleFindName(@tme,'WPWIN60');
   if (h<=0) then begin
    SayActivity('',txtWLIS,txtStartWP,''); {splash message screen }
    SetLink('WPWIN60_Macros', 'Commands');
    B:=OpenLink;
    HideActivity; { hide slplash message}
   end; { h <=0 }
   B:= SetLink('WPWIN60_Macros', 'Commands');
   B:=OpenLink;
   if  not B then ShowMessage('WordPerfect DDE Link failed');

   StrPCopy(@Cstr,'Type("Normally WinLaw would create '+Path+' at this point.")');
   B:= ExecuteMacro(@CStr,False);
   StrPCopy(@Cstr,'HardReturn()');
   ExecuteMacro(@CStr,False);
   StrPCopy(@Cstr,'Type("For now it demonstates controlling Word Perfect.")');
   B:= ExecuteMacro(@CStr,False);
   StrPCopy(@Cstr,'HardReturn()');
   B:= ExecuteMacro(@CStr,False);
   StrPCopy(@Cstr,'HardReturn()');
   ExecuteMacro(@CStr,False);
   StrPCopy(@Cstr,'AppActivate("WordPerfect")');
   B:= ExecuteMacro(@Cstr,False);
   {if (not B) then ShowMessage('Activation WP failed');}
   CloseLink;
  end;
end;
