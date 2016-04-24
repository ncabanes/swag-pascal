(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0038.PAS
  Description: Adding to Program Manager
  Author: SWAG SUPPORT TEAM
  Date: 11-22-95  15:50
*)


{Here is what's left from what I got from borland some time ago.
The DDEClient is a component you drop on the form (System, DdeClientItem). }


Var Macro : String;
Var Cmd: array[0..255] of Char;
NewPrg,Desc : String;
Begin
    { Create the group, does nothing if it existst } 
    Name := 'StartUp';
    Macro := Format('[CreateGroup(%s)]', [Name]) + #13#10;
    StrPCopy (Cmd, Macro);
    DDEClient.OpenLink;
    if not DDEClient.ExecuteMacro(Cmd, False) then
      MessageDlg(<ErrorMsg>, mtInformation, [mbOK], 0);

    { Then you add you program }
    NewPrg := 'C:\HELLO.EXE';      {Full path of the program you}
    Desc := 'Say Hello';           {Description that appears under the icon|    

    Macro := '[AddItem('+NewPrg+','+Desc+')]'+ #13#10;
    StrPCopy (Cmd, Macro);
    if not f1_.DDEClient.ExecuteMacro(Cmd, False) then
      MessageDlg(<errorMsg>,mtInformation, [mbOK], 0);

    { To make sure the group is saved }

    StrPCopy (Cmd,'[ShowGroup(nonexist,1)]');
    DDEClient.ExecuteMacro(Cmd, False);


     { Now... this part doesn't work and I don't know why }   
     { Anybody who knows why is welcome }

    StrPCopy (Cmd,'[reload()]');
    DDEClient.ExecuteMacro(Cmd, False);


     { and close the link }
    DDEClient.CloseLink;
End;

A procedure to get all groups from the program manager using a DDEclientconv:
{This example needs a listbox called AllGroups}

procedure GetGroups(Sender: TObject);
var
Thedata: pchar; 	{pchar that holds the groups}
dat: char;		{used to process each group}
charcount: word;		
 Theitem,theline:string;

begin
{get allgroups items}
charcount:=0;
TheData:= DDEClientConv2.RequestData('Groups');
theline:='';
repeat
       application.processmessages;
       dat:=Thedata[charcount];{get character from the Thedata}
       if (dat=chr(10)) {or (dat=chr(13))} then
          begin
            	while Pos(char(10), Theline) > 0 do
            		delete(Theline,pos(char(10),Theline),1);
            	while Pos(char(13), Theline) > 0 do
            		delete(Theline,pos(char(13),Theline),1);
          	If theline='' then continue;
          	allgroups.items.add(theline); {Allgroups is a LISTBOX}
          	theline:='';
          end;
       Theline:=theline+dat;
       inc(charcount);
until charcount>=strlen(Thedata);
strdispose(Thedata);
end;

