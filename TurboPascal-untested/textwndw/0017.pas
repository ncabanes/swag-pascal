{
Heres a little Text User Interface! If you use this program and like it then
tell me! All it has is four routines: WinD,WindMen,Shade, and Menu. Here it is:
}

Unit TUI;
Interface
Uses CRT;
Const Winsets = 1;
      WinComponents = 10;


Var
    Item     : array[1..23] of String[80];


Function Menu( NumItems, LightBarFG,LightBarBG,NormalFG,NormalBG,
               StartX,StartY:Byte) : Byte;
Procedure Wind(Y1,X1,Y2,X2,FGCol,BGCol : Integer);
Function WindMen(NumItems, LightBarFG,LightBarBG,NormalFG,NormalBG,
               WinFG,WinBG,StartX,StartY:Byte) : Byte;
Procedure Shade (FG,BG : Byte;Ch : Char);
Implementation
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
TextColor(NormalFG);
TextBackGround(NormalBG);
For Count2:=1 to NumItems do begin
     GotoXY(StartX,(Count2+StartY)-1);
     Write(Item[Count2]);
                               End;
Done:=False;
Repeat
GotoXY(LastX,LastY);
TextColor(NormalFG);
TextBackGround(NormalBG);
Write(Item[LastItem]);
GotoXY(NowX,NowY);
TextColor(LightBarFG);
TextBackGround(LightBarBG);
Write(Item[ItemNow]);
Repeat
Until Keypressed;
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
 End;
If ItemNow>NumItems then begin ItemNow:=1; NowY:=StartY; End;
If ItemNow<1 then begin ItemNow:=NumItems; NowY:=NowY+NumItems; End;

                     End;
If Inchar[1]=#27 then begin Menu:=255; Done:=True; End;
If Inchar[1]=#13 then begin Menu:=ItemNow; Done:=True; End;

Until Done;
TextAttr:=SaveAttr;
GotoXY(SaveX,SaveY);
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
TextColor(FGCol);
TextBackGround(BGCol);
GotoXY(X1,Y1);
Write(WinSet[1,01]);
For Count[1]:=X1+1 to X2-2 do begin
                   Write(Winset[1,02]);
                   End;
Write(WinSet[1,03]);
For Count[1]:=Y1+1 to Y2-1 do begin
      TextColor(FGCol);
      TextBackGround(BGCol);
      GotoXy(X1,Count[1]);
      Write(WinSet[1,04]);
      GotoXy(X2-1,Count[1]);
      Write(WinSet[1,05]);
      If FGCol > 7 then TextColor(FgCol-8) Else TextColor(8);
      TextBackGround(0);
      Write(Winset[1,09]);
      End;
      GotoXY(X1,Y2);
      TextColor(FGCol);
      TextBackGround(BGCol);
                   For Count[1]:=X1 to X2-2 do begin
                   If count[1]<>X1 then Write(Winset[1,07]) else
write(Winset[1,06]);;                   End;
                   Write(WinSet[1,08]);
      If FGCol > 7 then TextColor(FgCol-8) Else TextColor(8);
      TextBackGround(0);
      Write(Winset[1,09]);
      GotoXY(X1+1,Y2+1);
       For Count[1]:=X1+1 to X2 do begin
       Write(Winset[1,09]);
       End;

End;

Function WindMen(NumItems, LightBarFG,LightBarBG,NormalFG,NormalBG,
               WinFG,WinBG,StartX,StartY:Byte) : Byte;
Var SaveX,SaveY,SaveAttr,Selec : Byte;
Begin
SaveX:=WhereX;
SaveY:=WhereY;
SaveAttr:=TextAttr;
Wind(StartY-1,StartX-1,(StartY)+NumItems,StartX+Length(Item[1])+1,WinFG,WinBG);
Selec:=Menu(NumItems,LightbarFG,LightbarBG,NormalFG,NormalBG,StartX,StartY);
GotoXY(SaveX,SaveY);
TextAttr:=SaveAttr;
WindMen:=Selec;
End;

Procedure Shade (FG,BG : Byte;Ch : Char);
Var CNT : Integer;
Begin
ClrScr;
TextColor(FG);
TextBackGround(BG);
For CNT:=1 to 125 do write('▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒');
End;


End.


{ Heres a test program for TUI.PAS ... }

Uses CRT,Tui;

Var Selected : Byte;
CNT      : Integer;
Begin
Shade(13,0,'▒');
WinD(2,2,4,24,9,0);
GotoXY(3,3);
TextColor(10);
WriteLn('                    ');
Repeat
Item[1]:='.∙·──────»>Item 1<«──────∙·.';
Item[2]:='.∙·──────»>Item 2<«──────∙·.';
Item[3]:='.∙·──────»>Item 3<«──────∙·.';
Item[4]:='.∙·──────»>Item 4<«──────∙·.';
Selected:=WindMen(4,14,3,15,1,13,1,30,5);
If Selected<255 then Begin
                           GotoXY(3,3);
                           TextColor(10);
                           WriteLn('You selected item #',Selected)
                           end
                Else Begin
                           GotoXY(3,3);
                           TextColor(10);
                  Write('       ESC!         ');
                  WinD(20,30,22,50,12,0);
                  TextColor(14+16);
                  GotoXY(31,21);
                  Write(' Press Any Key... ');
                  Break; End;
Until 1=0;
Repeat until keypressed;
ClrScr;
End.

{
Ok heres what this means. The syntax for WinD is :
WinD(Col1,Row1,Col2,Row2,ForgroundColor,BackGroundColor);
When you put in the forground color make sure it is atleast 7.. This is because
when the routine prints the SHADOW it prints it in the low intensity version of
the color... so make sure when you give a color there it's high intensity.
Ok now for MENU. This is a function. what you do is load Item[1..23] with a
string. These should all be equal in length or your menu will look really
ragged...Ok call menu like this:
ByteVar:=Menu(NumItems,LightbarFG,LightbarBG,NormalFG,normalBG,StartX,StartY);
And bytevar will equal item# or 255 if ESC was pressed...
Or:
ByteVar:=WindMen(NumItems,LBFG,LBBG,NFG,NBG,WindowFG,WindowBG,StartX,StartY);
All this is a combination between window and menu. It will draw a window
around your menu items :)...
And for the last one:
Shade(FG,BG,CHAR);
Just use it like to shade in magenta with a green background <YUCK!> do
Shade(13,2,'▒');

If you use it please give me credit and maybe a registered version of the
program?
}
