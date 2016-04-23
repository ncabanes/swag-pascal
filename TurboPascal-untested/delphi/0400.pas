
How can I extract the logged username from Novell server?

There is a API function called GetUserName :

procedure TForm1.Button1Click(Sender: TObject);
var
   lpBuffer : PChar;
   nSize    : DWORD;
begin
     GetMem(lpBuffer,nSize);
     Try
        if GetUserName(lpBuffer,nSize) then
           Edit1.Text := StrPas(lpBuffer);
     Finally
        FreeMem(lpBuffer,nSize);
     end;
end;

Also, an other API WNetGetUser - retrieves the current default user name or
the user name used to establish a network connection.

See the API Help for more details.
