(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0060.PAS
  Description: Log off TENTOOL nodes
  Author: SWAG SUPPORT TEAM
  Date: 08-30-97  10:09
*)


{
 Program Name : Unlog.Pas
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

Program Unlog;
Uses DOS,CRT,TenTools;

TYPE
  Charset = 'A'..'Z';
  RDRTable = Array[1..200] of Char;

VAR
  LocalTable : DriveArray;
  LoginList : LogArray;
  I,J : Integer;
  L,U : Word;
  C : Charset;
  SR : SearchRec;
  SA : Word;
  RDR : ^RDRTAble;

Begin
   ClrScr;
   TextColor(LightCyan);
   I:=13;
{   If ((Mountlist(LocalTable,I)=0)and (I>0))
   then for C:='D' to Char(I+64) do if LocalTable[C].ServerID<>''
   then
    begin
       Writeln('Unmounting ',C,'=',LocalTable[C].RPath,',',LocalTable[C].ServerID,'...');
       U:=Unmount(C);
       Writeln('Logging off ',LocalTable[C].ServerID,'!');
       L:=Logoff(LocalTable[C].ServerID);
    end;
}   If ((LogList(LoginList,I)=0) and (I>0))
   then
    for J:=0 to I-1 do
    begin
       Writeln('Logging off ',LoginList[J]);
       L:=Logoff(LoginList[J]);
    end;
End.

