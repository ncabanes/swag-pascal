(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0050.PAS
  Description: Show the status of TENTOOL nodes
  Author: SWAG SUPPORT TEAM
  Date: 08-30-97  10:08
*)

 {
 Program Name : Netted.Pas
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
Program Netted;
Uses DOS,CRT,Tentools;
VAR
   Nodelist : NABuffer;
   SSList : NABuffer;
   DisplayList : NABuffer;
   MaxRows,MaxNodes,MaxSS,MaxDisplay : Integer;
   P2 : String;
   QNode : S12;
   CNode : S12;
   I,L : Integer;
   TestLetter : Char;
   NetRet,RetCode : Word;
   Super,WS : Boolean;
   Sorted : Boolean;
   TempNode : S12;
   Param : Array[1..2] of String;

Procedure ErrorOut(ECode : Word);
Begin
   Writeln('Error in Tentools function NODES: ',ECode);
   Halt;
End;

Procedure Help;
Begin
   Writeln('Syntax:  NETTED [<S,W,*,!>] [<nodename>]');
   Writeln(' where    "S" returns Superstations only');
   Writeln('          "W" returns Workstations (& Superstations)');
   Writeln('          "*" (same as "W")');
   Writeln('          "!" returns the status of your local node');
   Writeln('  and  <nodename> returns only the status of that node.');
   Writeln(' NOTE: Usage with a nodename will return to DOS with ErrorCode set');
   Writeln('       to 1 for a return of FALSE, or 0 for TRUE. Usage with "!"');
   Writeln('       will also return a 0 if the local node is "Loaded" or a 1');
   Writeln('       if it is not!');
   Halt;
End;

Function InGroup(NodeName : S12;VAR Group : NABuffer; Max : Integer): Boolean;
{ This function checks for the inclusion of Nodename in the NABuffer array
"Group". Max is the size of the group. }
VAR
   I : Integer;
Begin
   I:=1;
   While ((Group[I]<>Nodename)and(I<Max)) do Inc(I);
   InGroup:=(Group[I]=Nodename);
end;


Begin
   QNode:='';
   TestLetter:=#0;
   If ParamCount=0
   then Help
   else
    begin
       Param[1]:=ParamStr(1);
       If (ParamCount>1)
       then
        begin
           Param[2]:=ParamStr(2);
           If (Length(Param[1])>1)
           then
            begin
               QNode:=Param[1];
               TestLetter:=Upcase(Param[2][1]);
            end
           else
            begin
               QNode:=Param[2];
               TestLetter:=Upcase(Param[1][1]);
            end;
        end
       else
        begin
           if (Length(Param[1])=1)
           then TestLetter:=Upcase(Param[1][1])
           else QNode:=Param[1];
        end;
       If QNode<>''
       then
        begin
           for I:=1 to Length(QNode) do QNode[I]:=Upcase(QNode[I]);
           While length(QNode)<12 do QNode:=QNode+' ';
        end;
    end;
   IF TestLetter='!'
   then
    begin
       if Loaded
       then
        begin
           QNode:=Nodename;
           TextColor(White);
           Write(QNode,' is currently on the Network!');
           Halt(0);
        end
       else
        begin
           TextColor(LightRed);
           Write('This Node is NOT currently on the Network!');
           Halt(1);
        end
    end
   else
    begin
       MaxNodes:=140;
       NetRet:=Nodes(Nodelist,MaxNodes,False); {Full list of Nodes}
       If (NetRet<>0) then ErrorOut(NetRet);
       MaxSS:=140;
       NetRet:=Nodes(SSList,MaxSS,True);       {List of Superstations}
       If (NetRet<>0) then ErrorOut(NetRet);
       If (QNode<>'')
       then
        begin
           Super:=InGroup(QNode,SSList,MaxSS);
           If not Super then WS:=InGroup(QNode,NodeList,MaxNodes)
           else WS:=True;
           Case Testletter of
           #0,'W' : If WS
                    then
                     begin
                        RetCode:=0;
                        TextColor(White);
                     end
                    else
                     begin
                        RetCode:=1;
                        TextColor(LightRed);
                     end;
           'S' : If Super
                 then
                  begin
                     RetCode:=0;
                     TextColor(White);
                  end
                 else
                  begin
                     RetCode:=1;
                     TextColor(LightRed);
                  end;
           else Help;
           end; {Case}
           If Super then Writeln(QNode,' is a Superstation!')
           else if WS then Writeln(QNode,' is a WorkStation!')
           else Writeln(QNode,' is not currently on the network!');
           Halt(RetCode);
        end
       else
        begin
           QNode:=NodeName;
           For I:=1 to Length(QNode) do QNode[I]:=Upcase(QNode[I]);
           While length(QNode)<12 do QNode:=QNode+' ';
           ClrScr;
           {Sort Nodelist}
           Repeat
              Sorted:=True;
              For I:=1 to MaxNodes-1 do
               if Nodelist[I]>Nodelist[I+1] then
                begin
                   TempNode:=Nodelist[I];
                   Nodelist[I]:=NodeList[I+1];
                   Nodelist[I+1]:=TempNode;
                   Sorted:=False;
                end;
           Until Sorted;
           {Sort SSList}
           Repeat
              Sorted:=True;
              For I:=1 to MaxSS-1 do
               if SSlist[I]>SSlist[I+1] then
                begin
                   TempNode:=SSlist[I];
                   SSlist[I]:=SSList[I+1];
                   SSlist[I+1]:=TempNode;
                   Sorted:=False;
                end;
           Until Sorted;
           If (TestLetter='S')
           then
            begin
               Move(SSList,DisplayList,Sizeof(SSList));
               MaxDisplay:=MaxSS;
            end
           else
            begin
               Move(Nodelist,DisplayList,Sizeof(Nodelist));
               MaxDisplay:=MaxNodes;
            end;
           For I:=1 to MaxDisplay do
            begin
               MaxRows:=MaxDisplay div 6;
               If (MaxDisplay mod 6)>0 then Inc(MaxRows);
               GotoXY(((I-1) div MaxRows)*13+1,(I-1) mod MaxRows+2);
{               GotoXY(((I-1) mod 4)*20+1,(I-1) div 4+3); }
               If (DisplayList[I]=QNode)
               then
                begin
                   TextColor(White);
                   Write(DisplayList[I]);
                   If InGroup(DisplayList[I],SSList,MaxSS)
                   then TextColor(LightCyan) else TextColor(White);
                   GotoXY(((I-1) div MaxRows)*13+1,(I-1) mod MaxRows+2);
                   Write(DisplayList[I][1]);
                end
               else
                begin
                   TextColor(LightGreen);
                   Write(DisplayList[I]);
                   If InGroup(DisplayList[I],SSList,MaxSS)
                   then TextColor(LightCyan) else TextColor(LightRed);
                   GotoXY(((I-1) div MaxRows)*13+1,(I-1) mod MaxRows+2);
                   Write(DisplayList[I][1]);
                end;
            end;
          GotoXY(1,MaxRows+3);
          Write(MaxDisplay);
          If (TestLetter='S') then Write(' Superstations ')
          else Write(' Nodes ');
          Writeln('on the Network...');
          Halt(0);
        end;
   End;
End.
