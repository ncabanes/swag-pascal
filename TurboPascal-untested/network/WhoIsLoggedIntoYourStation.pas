(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0049.PAS
  Description: Who is logged into your station
  Author: SWAG SUPPORT TEAM
  Date: 08-30-97  10:08
*)

 {
 Program Name : Logged.Pas
 Written By   : Anonymous
 E-Mail       : nothing
 Web Page     : nothing
 Program
 Compilation  : Turbo Pascal 5.0 or later

 Program Description :

 Program to check on WHO is logged to your superstation.
 }


Program Logged;
Uses CRT,PRINTER,DOS,TENTOOLS;  { tentools is ALSO in NETWORK.SWG }

TYPE
   LTABRecIndex = Word;
   LTABRec = Record
    ChainPtr : LTABRecIndex;
    NodeName : Array[1..15] of Char;
    LoggedUser : Array[1..8] of Char;
    Filler : Array[1..8] of Char;
   end;
   LTABHeader = Record
    ChainPtr : LTABRecIndex;
    NextFreeChain : LTABRecIndex; {Word Ptr}
   end;

VAR
   OutScreen : Text;
   LTABOFS,LTABSEG : Word;
   LTABPtr : ^LTABRec;
   LTAB : Array[1..200] of ^LTabRec;
   Head : ^LTABHeader;
   I,J,LogTotal : Integer;
   NextChain,Test : Word;
   ChatLine : String;
   ToNode : S12;
Begin
   Assign(OutScreen,'');
   LTABOFS:=PreConfig^.PCT_LTAB;
   LTABSEG:=Seg(PreConfig^);
   LTABPtr:=PTR(LTABSEG,LTABOFS);
   Head:=PTR(LTABSEG,LTABOFS-4);
(*
   Writeln(Head^.ChainPtr);
   Writeln(Head^.NextFreeChain);
   For I:=1 to 4 do
    begin
       Writeln(SEG(LTabPtr^),':',OFS(LTabPtr^),'  ',LTabPtr^.ChainPtr);
       Writeln(SEG(LTabPtr^),':',OFS(LTabPtr^)+2,'  ',LTabPtr^.NodeName);
       Writeln(SEG(LTabPtr^),':',OFS(LTabPtr^)+17,'  ',LTabPtr^.LoggedUser);
       Writeln(SEG(LTabPtr^),':',OFS(LTabPtr^)+25,'  ',LTabPtr^.Filler);
       LTABPtr:=PTR(LTABSEG,LTABOFS+(I*Sizeof(LTABRec)));
    end;
*)
   LogTotal:=0;
   NextChain:=Head^.ChainPtr;
   While (NextChain<>$FFFF) do
    begin
       LTAB[LogTotal+1]:=PTR(LTABSEG,NextChain);
       Inc(LogTotal);
       NextChain:=LTab[LogTotal]^.ChainPtr;
    end;
   ChatLine:='';
   If LogTotal>0
   then
    begin
       If ParamCount=0
       then
        begin
           for I:=1 to LogTotal do with LTAB[I]^ do
           Writeln(LoggedUser,' is Logged to you from ',NodeName);
        end
       else
        begin
           ChatLine:=ParamStr(1);
           If ParamCount>1 then
           for I:=2 to ParamCount do Chatline:=Chatline+' '+ParamStr(I);
           For I:=1 to LogTotal do with LTAB[I]^ do
            begin
               For J:=1 to 12 do ToNode[J]:=NodeName[J];
                ToNode[0]:=#12;
                Write('Sending message to ',ToNode);
               Test:=Chat(ToNode,Chatline);
               If Test=0 then writeln(' successfully!')
               else writeln(' unsuccessfully (Error: ',Test,')');
            end;
        end;
    end
   else Writeln('No Users Currently Logged to you...');
End.

