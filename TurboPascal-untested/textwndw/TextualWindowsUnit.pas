(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0032.PAS
  Description: Textual Windows Unit
  Author: ALEKSANDAR DLABAC
  Date: 03-05-97  06:02
*)

  Unit TextWin;
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██          Textual windows unit        ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██    (C) 1992. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}
   Interface

   Uses Crt, Dos;

   Type TextMem  = array [1..80,1..25] of Record
                                           Char, Attr : byte
                                         End;
        MenuInfo = Record
                     Border, Text, Bar, Hot : byte
                   End;

   Const MaxWindow = 10;
         MaxDepth  = 5;
         Save      = True;  DontSave    = False;
         LeftUp    = 0; RightUp  = 1; LeftDown  = 2; RightDown  = 3;
         ActivW    : byte = 0;
         ESC   = #27; Up   = #72; Down = #80; CR    = #13;
         BAKSP = #8;  Home = #71; Endt = #79; Empty = #255;

   Var MaxX, MaxY   : integer;
       TextModeInfo : Record
                        Adress : word;
                        Wid    : byte;
                        CharH  : byte
                      End;

   Function  InKey : char;
   { InKey is similar to ReadKey, but do not wait if key is not pressed, in
     which case returns value "Empty" (#255). }

   Function  Attribute (Color,Background:byte) : byte;
   { Returns corresponding attribute for given color and backgroung. }

   Procedure TestTextMode;
   { Gets informations about current text mode: number of collumns and
     video address segment. }

   Procedure HideCursor;
   { Make cursor invisible. }

   Procedure ShowCursor;
   { Make cursor visible. }

   Function  GetChar (X,Y:byte) : byte;
   { Returns ASCII code of character at screen position (X,Y) }

   Function  GetAttr (X,Y:byte) : byte;
   { Returns attributes of character at screen position (X,Y) }

   Procedure PutChar (X,Y,Char,Attr:byte);
   { Puts character on screen. Parameters are:
       X, Y - Screen coordinates where character will be placed.
       Char - ASCII code of character to write.
       Attr - Attribute of character to write. }

   Procedure GetScrPart (X,Y,W,H:integer; var A:TextMem);
   { Stores a part of screen to buffer. Parameters are:
       X, Y - Coordinates of upper left corner of rectangular area to
              be stored.
       W, H - Width and height of rectangular area to be sotred,
              respectivelly.
       A    - Buffer variable. }

   Procedure PutScrPart (X,Y,W,H:integer; A:TextMem);
   { Restores a part of screen from buffer. Parameters are the same as
     in procedure GetScrPart. }

   Procedure TextRectangle (X,Y,W,H,Attr:byte);
   { Draws a rectangle. Parameters are:
       X, Y - Coordinates of upper left corner of rectangle.
       W, H - Width and height of rectangle, respectivelly. }

   Function  AvailableWindow : byte;
   { AvailableWindow returns Number of first available window handle }

   Procedure OpenWindow (Wn:byte; X,Y,W,H:integer; Attr:byte; SaveFlg:Boolean);
   { Opens a new window. Parameters are:
       Wn      - window handle (0-MaxWindow) of new window. There must not be
                 another window with same handle. Recomended use od
                 AvailableWindow function.
       X, Y    - Coordinates of upper left corner of window.
       W, H    - Width and height of window.
       Attr    - Atributes of window border. Color inside window will be the
                 same color settled by TextColor/TextBackground procedures.
       SaveFlg - If set to True content of screen will be restored after
                 closing this window. }

   Procedure ActiveWindow (Wn:byte);
   { Sets active window to window which handle is Ws.
     WARNING: Should not be used if there is overlaped windows (except 0).
              Should be used for latest opened window only.}

   Procedure CloseWindow;
   { Closes active window }

   Procedure MoveWindow (Wn:byte; X,Y:integer);
   { Moves window Wn to new coordinate (X,Y) }

   Procedure OpenMenu (X,Y:integer; Corn:byte; Menu:string; var Answer:byte; Info:MenuInfo);
   { OpenMenu opens a menu. Parameters are:
       X, Y   - Coordinates of one corner.
       Corn   - Defines which corner is given by (X,Y). Values of Corn can be
                LeftUp, RightUp, LeftDown, RightDown.
       Menu   - String containing menu items. Items should be separated by
                comma (","). Maximum "MaxOpt" (20) options allowed. For
                example if Menu='First,Second,tHird', menu on screen will
                have three options:
                    First
                    Second
                    tHird
                First upper case in option is hotkey. Pressing "H" key when
                  menu is oppened will cause selecting of third option.
       Answer - If nonzero returns Number of selecter option, otherwise
                ESC taster is pressed, or clicked outside of the menu.
       Info   - Menu color informations. }

   Procedure OpenBox (X,Y,W,H,Corn,Attr:byte);
   { Opens a temporary window (for messages, for example) with single border.
     Parameters are:
       X, Y, Corn - Same like in OpenMenu.
       W, H       - Width and height of box.
       Attr       - atributes of box. }

   Procedure CloseTemp;
   { Closes temporary window }

   Implementation

   Const Depth  : shortint = -1;

   Var   Windat : array [0..MaxWindow] of Record
                                            Open, SaveFlag : Boolean;
                                            Xw, Yw, Ww, Hw,
                                            Xcur, Ycur     : integer;
                                            TextBit        : TextMem;
                                            PrevWind       : byte
                                          End;

         Gd, Gm : integer;

   Function InKey : char;
     Var T : char;
       Begin
         If KeyPressed then T:=ReadKey else T:=Empty;
         InKey:=T
       End;

   Function  Attribute (Color,Background:byte) : byte;
     Begin
       Attribute:=Background shl 4+Color and $0F
     End;

   Procedure TestTextMode;
     Begin
       With TextModeInfo do
         Begin
           If Mem [$0000:$0449]=7 then Adress:=$B000
                                  else Adress:=$B800;
             Case Mem [$0000:$0449] of
               0, 1    : Wid:=40;
               2, 3, 7 : Wid:=80;
               else      Wid:=0
             End;
           CharH:=Mem [$0000:$0485]
         End
     End;

   Procedure HideCursor;
     Var Regs : registers;
       Begin
         With Regs do
           Begin
             AH:=01;
             CH:=$20;
             CL:=$20
           End;
         Intr ($10,Regs)
       End;

   Procedure ShowCursor;
     Var Regs : registers;
       Begin
         With Regs do
           Begin
             AH:=01;
             CH:=TextModeInfo.CharH-3;
             CL:=TextModeInfo.CharH-2
           End;
         Intr ($10,Regs)
       End;

   Function  GetChar (X,Y:byte) : byte;
     Begin
       GetChar:=Mem [TextModeInfo.Adress:((Y-1)*80+X-1)*2]
     End;

   Function  GetAttr (X,Y:byte) : byte;
     Begin
       GetAttr:=Mem [TextModeInfo.Adress:((Y-1)*80+X-1)*2+1]
     End;

   Procedure PutChar (X,Y,Char,Attr:byte);
     Begin
       Mem [TextModeInfo.Adress:((Y-1)*80+X-1)*2]:=Char;
       Mem [TextModeInfo.Adress:((Y-1)*80+X-1)*2+1]:=Attr
     End;

   Procedure GetScrPart (X,Y,W,H:integer; var A:TextMem);
     Var I, J : integer;
       Begin
         Dec (W);
         Dec (H);
         For I:=1 to 80 do
           For J:=1 to 25 do
             Begin
               A [I,J].Char:=0; A [I,J].Attr:=0
             End;
         With TextModeInfo do
           Begin
             If (X<=Wid) and (Y<=25) then
               Begin
                 If X+W>Wid then W:=Wid-X;
                 If Y+H>25 then H:=25-Y;
                 For I:=Y to Y+H do
                   For J:= X to X+W do
                     With A [J-X+1,I-Y+1] do
                       Begin
                         Char:=GetChar (J,I);
                         Attr:=GetAttr (J,I);
                       End
               End
           End
       End;

   Procedure PutScrPart (X,Y,W,H:integer; A:TextMem);
     Var I, J : integer;
       Begin
         Dec (W);
         Dec (H);
         With TextModeInfo do
           Begin
             If (X<=Wid) and (Y<=25) then
               Begin
                 If X+W>Wid then W:=Wid-X;
                 If Y+H>25 then H:=25-Y;
                 For I:=Y to Y+H do
                   For J:= X to X+W do
                     With A [J-X+1,I-Y+1] do
                       PutChar (J,I,Char,Attr)
               End
           End
       End;

   Procedure TextRectangle (X,Y,W,H,Attr:byte);
     Var I : integer;
       Begin
         If X<1 then X:=1;
         If Y<1 then Y:=1;
         If W<0 then
           Begin
             W:=-W; Dec (X,W);
           End;
         If H<0 then
           Begin
             H:=-H; Dec (Y,H);
           End;
         If (X<1) or (Y<1) or (W<2) or (H<2) or
            (W>TextModeInfo.Wid-X+1) or (H>26-Y) then Exit;
         For I:=Y+1 to Y+H-2 do
           Begin
             PutChar (X,I,179,Attr);
             PutChar (X+W-1,I,179,Attr)
           End;
         For I:=X+1 to X+W-2 do
           Begin
             PutChar (I,Y,196,Attr);
             PutChar (I,Y+H-1,196,Attr)
           End;
         PutChar (X,Y,218,Attr);
         PutChar (X+W-1,Y,191,Attr);
         PutChar (X,Y+H-1,192,Attr);
         PutChar (X+W-1,Y+H-1,217,Attr)
       End;

   Function AvailableWindow : byte;
     Var Temp : byte;
       Begin
         Temp:=1;
         While (Temp<=MaxWindow) and WinDat [Temp].Open do Inc (Temp);
         If Temp>MaxWindow then Temp:=0;
         AvailableWindow:=Temp
       End;

   Procedure OpenWindow (Wn:byte; X,Y,W,H:integer; Attr:byte; SaveFlg:Boolean);
     Var I, J : integer;
       Begin
         If (W>TextModeInfo.Wid) or (H>25) then Exit;
         If W<0 then
           Begin
             W:=-W; Dec (X,W)
           End;
         If H<0 then
           Begin
             H:=-H; Dec (Y,H)
           End;
         If X<1 then X:=1;
         If Y<1 then Y:=1;
         With TextModeInfo do If X+W-1>Wid then X:=Wid-W+1;
         If Y+H-1>25 then Y:=26-H;
         If Wn<=MaxWindow then
           With windat [Wn] do
             Begin
               With windat [ActivW] do
                 Begin
                   Xcur:=WhereX; Ycur:=WhereY
                 End;
               PrevWind:=ActivW;
               ActivW:=Wn;
               If W<0 then
                 Begin
                   W:=-W; Dec (X,W)
                 End;
               If H<0 then
                 Begin
                   H:=-H; Dec (Y,H)
                 End;
               MaxX:=W; MaxY:=H; Xw:=X; Yw:=Y; Hw:=H; Ww:=W;
               Xcur:=1; Ycur:=1;
               SaveFlag:=SaveFlg;
               Open:=True;
               If SaveFlag=Save then GetScrPart (X,Y,Ww,Hw,TextBit);
             End;
         TextRectangle (X,Y,W,H,Attr);
         Window (X+1,Y+1,X+W-2,Y+H-2);
         ClrScr
       End;

   Procedure ActiveWindow (Wn:byte);
     Begin
       If Wn<=MaxWindow then
         Begin
           With Windat [ActivW] do
             Begin
               Xcur:=WhereX; Ycur:=WhereY
             End;
           With Windat [Wn] do
             If Open then
               Begin
                 ActivW:=Wn;
                 Window (Xw+1,Yw+1,Xw+Ww-2,Yw+Hw-2);
                 MaxX:=Ww-1; MaxY:=Hw-1;
                 GoToXY (Xcur,Ycur)
               End
         End
     End;

   Procedure CloseWindow;
     Begin
       With Windat [ActivW] do
         If (ActivW>0) and Open then
           Begin
             Open:=False;
             Xcur:=WhereX; Ycur:=WhereY;
             Window (Xw,Yw,Xw+Ww,Yw+Hw);
             If SaveFlag=Save then PutScrPart (Xw,Yw,Ww,Hw,TextBit)
                              else ClrScr;
             If Windat [PrevWind].Open then ActiveWindow (PrevWind)
                                       else ActiveWindow (0)
           End
     End;

   Procedure MoveWindow (Wn:byte; X,Y:integer);
     Var P          : TextMem;
       Begin
         If (Wn>0) and (Wn<=MaxWindow) then
           with windat [Wn] do
             If Open then
               Begin
                 If (X+Ww-1>TextModeInfo.Wid) or (Y+Hw-1>25) then Exit;
                 Xcur:=WhereX; Ycur:=WhereY;
                 GetScrPart (Xw,Yw,Ww,Hw,P);
                 If SaveFlag then PutScrPart (Xw,Yw,Ww,Hw,TextBit)
                             else ClrScr;
                 Xw:=X; Yw:=Y;
                 If SaveFlag then GetScrPart (X,Y,Ww,Hw,TextBit);
                 PutScrPart (X,Y,Ww,Hw,P);
                 Window (X+1,Y+1,X+Ww-1,Y+Hw-1);
                 GoToXY (Xcur,Ycur)
               End
       End;

   Procedure OpenMenu (X,Y:integer; Corn:byte; Menu:string; var Answer:byte; Info:MenuInfo);
     Const Maxopt = 23;
     Var Posib                   : array [1..Maxopt] of Record
                                                          Beg, Wid : byte
                                                        End;
         Options                 : string [Maxopt];
         I, J, W, H, Nopt, Width : byte;

       Procedure GetPossib;
         Var I, J, K : byte;
           Begin
             Options:='';
             I:=0; Width:=0; Nopt:=0;
             Repeat
               J:=Pos (',',Menu);
               If J>0 then
                 Begin
                   Inc (Nopt);
                   Menu [J] := ';';
                   Posib [Nopt].Beg := I+1;
                   Posib [Nopt].Wid := J-I-1;
                   K:=I;
                   Repeat
                     Inc (K);
                     If Menu [K] in ['A'..'Z'] then Options:=Options+Menu [K];
                   Until (K=J) or (menu [K] in ['A'..'Z']);
                   If K=J then Options:=Options+' ';
                   With Posib [Nopt] do If Wid>Width then Width:=Wid;
                 End;
               I:=J
             Until (I=0) or (Nopt=MaxOpt)
           End;

       Procedure MakeChoice;
         Var I, Lin    : byte;
             Key, Ctrl : char;
           Begin
             Window (1,1,TextModeInfo.Wid,25);
             GoToXY (TextModeInfo.Wid,25);
             HideCursor;
             Lin:=1;
             With Info do
               Repeat
                 For I:=1 to Width+2 do
                   Begin
                     PutChar (X+I,Lin+Y,GetChar (X+I,Lin+Y),Bar);
                   End;
                   Repeat
                     Key:=Upcase (ReadKey)
                   Until (Pos (Key, CR+ESC+Options) > 0) or (Key=#0);
                 For I:=1 to Width+2 do
                   If (Options [Lin]<>' ') and (Options [Lin]=Menu [Posib [Lin].Beg+I-2]) then
                     PutChar (X+I,Lin+Y,GetChar (X+I,Lin+Y),Hot)
                                                                                      else
                     PutChar (X+I,Lin+Y,GetChar (X+I,Lin+Y),Text);
                 If Key=#0 then
                   Begin
                     Ctrl:=ReadKey;
                     If (Ctrl=Down) and (Lin<Nopt) then Inc (Lin);
                     If (Ctrl=Up) and (Lin>1) then Dec (Lin);
                     If Ctrl=Home then Lin:=1;
                     If Ctrl=Endt then Lin:=Nopt
                   End;
               Until Key>#0;
             If Key=CR then Answer:=Lin else Answer:=Pos (Key,Options);
             ShowCursor
           End;

       Begin
         If Depth<MaxDepth-1 then
           Begin
             Menu:=Menu+',';
             Inc (Depth);
             GetPossib;
             H:=Nopt+2; W:=Width+4;
             If Corn>RightUp then H:=-H;
             If (Corn=RightUp) or (Corn=RightDown) then W:=-W;
             TextColor (Info.Text and $0F);
             TextBackground (Info.Text shr 4);
             OpenWindow (MaxWindow-Depth,X,Y,W,H,Info.Border,Save);
             For I:=1 to Nopt do
               With Posib [I] do
                 For J:=1 to Width do
                   If J<=Wid then
                   If (Options [I]<>' ') and (Options [I]=Menu [Beg+J-1]) then
                     PutChar (X+J+1,I+Y,Ord (Menu [Beg+J-1]),Info.Hot)
                                                                          else
                       PutChar (X+J+1,I+Y,Ord (Menu [Beg+J-1]),Info.Text)
                            else
                       PutChar (X+J+1,I+Y,32,Info.Text);
             MakeChoice
           End
       End;

   Procedure OpenBox (X,Y,W,H,Corn,Attr:byte);
     Var Wsgn, Hsgn : integer;
       Begin
         If Depth<MaxDepth-1 then
           Begin
             Inc (Depth);
             If Corn>RightUp then Hsgn:=-1 else Hsgn:=1;
             If (Corn=RightUp) or (Corn=RightDown) then Wsgn:=-1 else Wsgn:=1;
             OpenWindow (MaxWindow-Depth,X,Y,Wsgn*W,Hsgn*H,Attr,Save)
           End
       End;

   Procedure CloseTemp;
     Var Actual : byte;
       Begin
         If Depth>-1 then
           Begin
             If ActivW<>MaxWindow-Depth then
               Begin
                 Actual:=ActivW;
                 ActiveWindow (MaxWindow-Depth);
                 CloseWindow;
                 ActiveWindow(Actual)
               End
                                        else
               CloseWindow;
             Dec (Depth);
           End
       End;

   Begin
     TestTextMode
   End.

{ ---------------------- Demo program ---------------------- }

 Program TextWinDemo;

   Uses Crt, TextWin;

   Var I, X, Y : integer;
       Answer  : byte;
       S       : string;
       Info    : MenuInfo;

   Procedure WaitKey;
     Begin
       Repeat Until InKey<>Empty
     End;

   Procedure WriteTitle (Title:string);
     Begin
       TextColor (Yellow);
       TextBackground (Blue);
       ClrScr;
       GoToXY (40-Length (Title) div 2,2);
       Write (Title)
     End;

     Begin
       TextColor (Yellow);
       TextBackground (Blue);
       OpenWindow (0,1,1,80,25,Attribute (White,Green),DontSave);
       WriteTitle ('You can open up to 10 windows (or more if you change MaxWindow constant).');
       Randomize;
       For I:=1 to MaxWindow do
         Begin
           Str (I,S);
           TextColor (I+1);
           TextBackground (7-(I+1) mod 8);
           OpenWindow (I,8+Random (30),5+Random (5),12+Random (30),7+Random (8),Attribute (I,7-I mod 8),Save);
           Writeln ('Window #',S);
           Delay (100)
         End;
       Writeln;
       Write ('Any key...');
       WaitKey;
       For I:=1 to MaxWindow do
         Begin
           CloseWindow;
           Delay (100)
         End;
       WriteTitle ('Press any key to hide cursor...');
       WaitKey;
       HideCursor;
       WriteTitle ('Press any key to show cursor...');
       WaitKey;
       ShowCursor;
       WriteTitle ('Menu demo');
       With Info do
         Begin
           Border:=Attribute (Black,LightGray);
           Text:=Attribute (Black,LightGray);
           Bar:=Attribute (White,Blue);
           Hot:=Attribute (Red,LightGray)
         End;
       OpenMenu (30,10,LeftUp,'An item,Also an item,One more',Answer,Info);
       If Answer<>0 then
         Begin
           OpenMenu (32,11+Answer,LeftUp,'New first option,New second option,New third option',Answer,Info);
           CloseTemp
         End;
       CloseTemp;
       TextColor (Yellow);
       TextBackground (Blue);
       Writeln;
       Writeln;
         Case Answer of
           0 : Write ('You choosed nothing...');
           1 : Write ('You choosed first option...');
           2 : Write ('You choosed second option...');
           3 : Write ('You choosed third option...')
         End;
       WaitKey;
       WriteTitle ('Box demo...');
       OpenBox (30,11,20,3,LeftUp,Attribute (Black,LightGray));
       Write (' This is a box...');
       WaitKey;
       CloseTemp;
       WriteTitle ('Any key to exit...');
       WaitKey;
       Window (1,1,TextModeInfo.Wid,25);
       TextColor (LightGray);
       TextBackground (Black);
       ClrScr
     End.
