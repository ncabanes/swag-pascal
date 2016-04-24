(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0059.PAS
  Description: TENTOOLS spooling to printer
  Author: SWAG SUPPORT TEAM
  Date: 08-30-97  10:09
*)

 {
 Program Name : Sprint.Pas
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
 
{$M 32768,0,32768}
Program Sprint;
Uses CRT,DOS,Tentools;

VAR
   Filename : String;
   TestWord : Word;
   ComSpec : String;
   DOSWord : Word;
Begin
   TestWord:=SetSpool(1,'',[Start,Completion],1);
   If (ParamCount=0)
   then
    begin
       TestWord:=CloseSpool;
       If (TestWord<>0) then Writeln('Creating initial Spool!');
       TestWord:=OpenSpool('');
    end
   else if ParamCount>0
   then
    begin
       Comspec:=GetEnv('COMSPEC');
       Filename:=Paramstr(1);
       SwapVectors;
       Exec(COMSPEC,'/C COPY '+Filename+' LPT1:');
       SwapVectors;
       DOSWord:=DOSError;
       If (DOSWord<>0) then Writeln('Insufficient Memory to Sprint!')
       else
        begin
           TestWord:=CloseSpool;
           Writeln(Filename,' sent to printer!');
           TestWord:=OpenSpool('');
           Writeln('New Spool opened...');
        end;
    end;
End.

