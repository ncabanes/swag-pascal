 {
 Program Name : Devices.Pas
 Written By   : Anonymous
 E-Mail       : nothing
 Web Page     : nothing
 Program
 Compilation  : Turbo Pascal 5.0 or later

 Program Description :

 Usefulness for BBS'S and general communications.
 For a detailed description of this code source, please,
 read the file TENTOOLS.DOC. Thank you
 }

Program Devices;
Uses CRT,Tentools;  { ten tools also available in SWAG !! }
VAR
   SaveUser : S8;
   SavePW : PW8;
   Dlist : DeviceArray;
   I,D,E : Integer;
   ServerName : S12;
   RetCode : Word;
Begin
   If ParamCount<1
   then
    begin
       Writeln('Enter a Node name as a parameter!');
       Halt;
    end
   else ServerName:=ParamStr(1);
   SaveUser:=Username;
   SetUsername('OPERATOR');
   For I:=1 to Length(Servername) do ServerName[I]:=Upcase(ServerName[I]);
   RetCode:=Login(ServerName,SavePW);
   If (RetCode=0)
   then
    begin
       RetCode:=GetDevices(ServerName,DList,D);
       If Retcode=0
       then
        begin
           for E:=0 to D-1 do
            Writeln(Dlist[E]);
        end
       else
        Writeln('Error: ',Retcode);
    end
   else Writeln('Error Logging into ',Servername,' : ',RetCode);
   SetUsername(SaveUser);
End.
