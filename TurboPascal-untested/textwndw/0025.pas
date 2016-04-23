
Unit TUI;
Interface
Uses CRT;
Const Winsets = 1;
      WinComponents = 10;


Var
    Item     : array[1..23] of String[80];
    Print    : Boolean;

Function Menu( NumItems, LightBarFG,LightBarBG,NormalFG,NormalBG,
               StartX,StartY:Byte) : Byte;
Procedure Wind(Y1,X1,Y2,X2,FGCol,BGCol : Integer);
Function WindMen(NumItems, LightBarFG,LightBarBG,NormalFG,NormalBG,
               WinFG,WinBG,StartX,StartY:Byte) : Byte;
Procedure Shade (FG,BG : Byte;Ch : Char);
Procedure TXTFG(Clr : Byte);
Procedure TXTBG(Clr : Byte);
Procedure Locate(X,Y : Byte);
Procedure Prnt(Strng : String);
Procedure PrntLN(Strng : String);
function IntToStr(I: Longint): String;
implementation
Procedure TXTFG(Clr : Byte);
Begin
Repeat Until Print;
Print:=False;
TextColor(CLR);
Print:=True;
End;
Procedure TXTBG(Clr : Byte);
Begin
Repeat Until Print;
Print:=False;
TextBackGround(CLR);
Print:=True;
End;
Procedure Locate(X,Y : Byte);
Begin
Repeat Until Print; Print:=False;
GotoXY(X,Y);
Print:=True;
End;
Procedure Prnt(Strng : String);
Begin
Repeat Until Print; Print:=False;
Write(Strng);
Print:=True;
End;
Procedure PrntLN(Strng : String);
Begin
Repeat Until Print; Print:=False;
WriteLn(Strng);
Print:=True;
End;
function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

Function Menu( NumItems, LightBarFG,LightBarBG,NormalFG,NormalBG,
               StartX,StartY:Byte) : Byte;
Var MenuStrings : Array[1..25] of String;
    NowX,NowY,LastX,LastY,SaveAttr,SaveX,SaveY : Byte;
    ItemNow,LastItem : Byte;
    InChar : Array[1..5] of Char;
    TmpStr : String;
    Count1,Count2,Count3,Count4  : Byte;
    Done   : Boolean;
    StartItem : Byte;

Begin
SaveX:=WhereX;
SaveY:=WhereY;
StartItem:=1;
SaveAttr:=TextAttr;
NowX:=StartX;
NowY:=StartY;
LastX:=NowX;
LastY:=NowY;
ItemNow:=StartItem;
LastItem:=StartItem;
TXTFG(NormalFG);
TXTBG(NormalBG);
For Count2:=1 to NumItems do begin
Locate(StartX,(Count2+StartY)-1);
If Print then      PRNT(Item[Count2]);
                               End;
Done:=False;
Repeat
 Locate(LastX,LastY);
 TXTFG(NormalFG);
 TXTBG(NormalBG);
 PRNT(Item[LastItem]);
 Locate(NowX,NowY);
 TXTFG(LightBarFG);
 TXTBG(LightBarBG);
 PRNT(Item[ItemNow]);
Repeat Until Keypressed;
{If NOT keypressed then begin Menu:=0; Done:=True; End;}
Inchar[1]:=ReadKey;
If Inchar[1]=#0 then begin Inchar[1]:=ReadKey;
LastX:=NowX;
LastY:=NowY;
LastItem:=ItemNow;
 Case InChar[1] of
                 'P' : Begin Inc(NowY); Inc(ItemNow) End;
                 'H' : Begin Dec(NowY); Dec(ItemNow) End;
                 'K' : Begin Dec(NowY); Dec(ItemNow) End;
                 'M' : Begin Inc(NowY); Inc(ItemNow) End;
                 'G' : Begin NowY:=StartY; ItemNow:=1 End;
                 'O' : Begin NowY:=StartY+(NumItems-1); ItemNow:=NumItems End;
 End;
If ItemNow>NumItems then begin ItemNow:=1; NowY:=StartY; End;
If ItemNow<1 then begin ItemNow:=NumItems; NowY:=NowY+NumItems; End;

                     End;
If Inchar[1]=#27 then begin Menu:=255; Done:=True; End;
If Inchar[1]=#13 then begin Menu:=ItemNow; Done:=True; End;

Until Done;
TextAttr:=SaveAttr;
 Locate(SaveX,SaveY);
End;

Procedure Wind(Y1,X1,Y2,X2,FGCol,BGCol : Integer);
Var
Count : Array [1..4] of Byte;
TmpVar : Array [1..10] of Integer;
 WinSet : Array [1..WinSets,1..WinComponents] of Char;

Begin
          Winset[1,01]:='█'; {Top left}
          Winset[1,02]:='▀'; {Top}
          Winset[1,03]:='█'; {Top right}
          Winset[1,04]:='▌'; {Left side}
          Winset[1,05]:='▐'; {Right side}
          Winset[1,06]:='█'; {Bottom Left}
          Winset[1,07]:='▄'; {Bottom}
          Winset[1,08]:='█'; {Bottom Right}
          Winset[1,09]:='▒'; {Shadow}
 TXTFG(FGCol);
 TXTBG(BGCol);
 Locate(X1,Y1);
 PRNT(WinSet[1,01]);
For Count[1]:=X1+1 to X2-2 do begin
                    PRNT(Winset[1,02]);
                   End;
 PRNT(WinSet[1,03]);
For Count[1]:=Y1+1 to Y2-1 do begin
       TXTFG(FGCol);
       TXTBG(BGCol);
       Locate(X1,Count[1]);
       PRNT(WinSet[1,04]);
       Locate(X2-1,Count[1]);
       PRNT(WinSet[1,05]);
      If FGCol > 7 then  TXTFG(FgCol-8)
                        Else  TXTFG(8);
       TXTBG(0);
       PRNT(Winset[1,09]);
      End;
       Locate(X1,Y2);
       TXTFG(FGCol);
       TXTBG(BGCol);
                   For Count[1]:=X1 to X2-2 do begin
                   If count[1]<>X1 then  PRNT(Winset[1,07])
                   else  PRNT(Winset[1,06]);;
                   End;
                   PRNT(WinSet[1,08]);
      If FGCol > 7 then  TXTFG(FgCol-8) Else  TXTFG(8);
       TXTBG(0);
       PRNT(Winset[1,09]);
       Locate(X1+1,Y2+1);
       For Count[1]:=X1+1 to X2 do begin
        PRNT(Winset[1,09]);
       End;

End;

Function WindMen(NumItems, LightBarFG,LightBarBG,NormalFG,NormalBG,
               WinFG,WinBG,StartX,StartY:Byte) : Byte;
Var SaveX,SaveY,SaveAttr,Selec : Byte;
Begin
SaveX:=WhereX;
SaveY:=WhereY;
SaveAttr:=TextAttr;
Wind(StartY-1,StartX-1,(StartY)+NumItems,StartX+Length(Item[1])+1,WinFG,WinBG)
;Selec:=Menu(NumItems,LightbarFG,LightbarBG,NormalFG,NormalBG,StartX,StartY);
Locate(SaveX,SaveY);
TextAttr:=SaveAttr;
WindMen:=Selec;
End;

Procedure Shade (FG,BG : Byte;Ch : Char);
Var CNT : Integer;
Begin
 TXTFG(FG);
 TXTBG(BG);
 For CNT:=0 to 4000 do begin
 If Odd(Cnt) then Mem[$B800:Cnt]:=TextAttr
             else
                 Mem[$B800:Cnt]:=Ord(Ch);
             end;
End;

Begin
Print:=True;
End.
