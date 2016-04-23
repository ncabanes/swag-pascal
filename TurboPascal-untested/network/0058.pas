 {
 Program Name : Ntxavail.Pas
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

Program CheckNextLetter;
Uses CRT,Tentools;
VAR
   NEXT : Char;
Function NextLetter : Char;
VAR
   SDArray : DriveArray;
   KChar,RetChar : Char;
   Ret : Word;
   K : Integer;
Begin
   RetChar:='C';
   K:=20;
   If ((Mountlist(SDArray,K)=0)and (K>0))
   then
    begin
       KChar:='D';
       While not ((SDArray[KChar].ServerID='            ')or(KChar=Char(K+64))) do
       KChar:=Succ(KChar);
       If KChar<>Char(K+64) then RetChar:=KChar else RetChar:=#0;
    end;
   NextLetter:=RetChar;
End;
Begin
   NEXT:=NextLetter;
   If (Next<>#0)
   then
    begin
       Writeln('Next Mountable Drive: ',Next);
       Halt(Ord(Next)-64);
    end
   else
    begin
       Writeln(^G,'No free drives available for mounting...');
       Halt(255);
    end;
End.
