 {
 Program Name : 10Time.Pas
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

Program TenTime;
Uses CRT,TenTools;

VAR
   I : Integer;
   W : Word;
   L,K : Longint;
   SB : StatusBlock;
   DT : DateTimeRec;
   Mins,Secs : String[2];
Begin
   If ParamCount<1
   then Writeln('Syntax: 10Time <Node>')
   else
    begin
       W:=TenConfig(0,0,0);
       W:=Get10Time(ParamStr(1),DT);
       If W=0
       then With DT do
        begin
           Str(Minute:2,Mins);
           If Mins[1]=' ' then Mins[1]:='0';
           Str(Second:2,Secs);
           If Secs[1]=' ' then Secs[1]:='0';
           Writeln('Date: ',Month,'/',Day,'/',Year,' Time: ',Hour,':',Mins,':',Secs);
        end;
    end;
End.
