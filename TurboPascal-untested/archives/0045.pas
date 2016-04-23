 {
 Program Name : Mounts.Pas
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

Program Mounts;
Uses DOS,CRT,TenTools; { tentools is also in NETWORK.SWG}

TYPE
  Charset = '1'..'Z';
  RDRTable = Array[1..200] of Char;

VAR
  LocalTable : DriveArray;
  PrintTable : PrintArray;
  I,J,H,K,T,L,P : Integer;
  C : Charset;
  SR : SearchRec;
  SA : Word;
  RDR : ^RDRTAble;
  Avail : String;
  Test : Word;

Begin
   If Not Loaded then Halt($FF);
   Avail:='Mounts Unused: ';
   I:=14;
   Test:=Mountlist(LocalTable,PrintTable,I);
   T:=0;
   For C:='A' to Char(I+64) do
   if LocalTable[C].ServerID<>'            ' then Inc(T);
   If T mod 2>0 then T:=T div 2 +1 else T:=T div 2;
   Inc(T,2);
   H:=WhereY;
   If (H>(25-T)) then
   while (H>(25-T)) do
    begin
       GotoXY(1,25);
       Writeln('');
       Dec(H);
    end;
   Dec(T,2);
   GotoXY(1,H);
   J:=1;
   K:=0;
   If ((Test=0)and (I>0))
   then
    begin
       for C:='A' to Char(I+64) do
        begin
           If J<=T then GotoXY(1,H+J-1) else GotoXY(40,H+J-T-1);
           If LocalTable[C].ServerID<>'            '
           then
            begin
               Inc(J);
               Write(C,'=',LocalTable[C].RPath,',',LocalTable[C].ServerID);
            end
           else
            begin
               Inc(K);
               If (K<>1) then Avail:=Avail+',';
               Avail:=Avail+C;
            end;
        end;
       L:=K;
       P:=0;
       For C:='1' to '3' do
        begin
           If J<=T then GotoXY(1,H+J-1) else GotoXY(40,H+J-T-1);
           If PrintTable[C].ServerID<>'            '
           then
            begin
               Write('LPT',C,':=','LPT',PrintTable[C].RPath,',',PrintTable[C].ServerID);
               Inc(J);
               Inc(P);
            end
           else
            begin
               Inc(K);
               If (K<>1) then Avail:=Avail+',';
               Avail:=Avail+'LPT'+C;
            end;
        end;
    end;
   I:=MountsAvail;
   GotoXY(1,H+T+1);
   Writeln(Avail);
   Write('Total Drives Mountable: ',I,'    Drives Mounted: ',I-L);
   If P>0 then Writeln('    Printers Mounted: ',P) else Writeln('');
End.
