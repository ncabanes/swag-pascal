{
I saw someone could use a menu unit like the one used with RA/FD/ALLFIX..
Well... I have one... :

·oO BEGIN Menus.Pas Oo·
(* This unit is (c) 1995 by Archangel/DMA
   You can use this unit, or parts of it in your own programs as
   long as you mention my name somewhere (I didn't code it all for
   fun you know =])

   It's a pretty straightforward unit, if you don't get it, try to
   look at the code some more and probably you'll understand. Or you
   can read the comments.

   About comments, there are not much comments since I'm not good at
   commenting my own sources...

*)
{$G+,F+,X+,V-,R-,O+}
{$M 8192,0,128000}                           { Set up some local stack space }
Unit RAMenu;
Interface
Type
  SaveRecord = Record                         { Record used for 'pushscreen' }
                 Case UseDisk: Boolean of                        { Use disk? }
                   TRUE : (FName: string[12]);              { Yes? What file }
                   FALSE: (MemPtr: Pointer);                    { No? Where? }
               End;
  SaveStackType = array[1..50] of SaveRecord;                   { Save stack }
  SubMenuRecord = record                     { Record used to store submenus }
                    ItemName : string[40];        { Name of item (displayed) }
                    ItemProc : Procedure;     { Pointer to procedure to exec }
                    ItemHelp : string[79];                    { The helpline }
                  end;
  SubMenuType = array[1..20] of SubMenuRecord;                 { One submenu }
  MainMenuRecord = record             { Record used to store main menu items }
                     ItemName : string[20];
                     ItemHelp : string[79];
                     SubMenu  : SubMenuType;      { Submenu of this mainmenu }
                   end;
  MainMenuType = array[1..10] of MainMenuRecord;  { The total menu structure }
  VRecord = record                                       { Video memory type }
              VChar : char;
              VAttr : byte;
            End;
  VMemType = array[1..25,1..80] of VRecord;                   { Video memory }
  TabType = array[1..10] of Byte;                             { A table type }
  TabType2 = array[1..20] of Byte;                            { A table type }

Var
  Menu        : ^MainMenuType;
  XTab        : TabType;
  SubRemP     : TabType2;
  ColorMem    : VMemType absolute $B800:0000;
  MonoMem     : VMemType absolute $B000:0000;
  Mono        : Boolean;
  VideoSegment: Word;
  OldExit     : Pointer;
  CommentColor: byte;                                   { Color of helplines }
Const
  StackMaxMem : Byte=10;

(* STACKMAXMEM

   This is something to consider, this constant holds the amount of screens
   saved in memory before the unit starts saving on disks. Since I've only
   built in total screen saving, 10 screens will take up 40000 bytes. If
   you need that memory either set it to a lower value or set it to '1'.

*)

Function GetAttr(X,Y: Byte): Byte;
{ Get attribute from a position }
Procedure SetAttr(X,Y,Attr: byte);
{ Set attribute on a position }

Procedure VWriteCh(Ch: char;x,y: byte);
{ Write a character to the video memory with the attribute stored in
  'textattr'}
Procedure VWriteStr(S: string;fg,bg,x,y: byte);
{ Write a string to the video memory with the colors 'fg' and 'bg' and
  start writing on 'x', 'y' }
Procedure Color(fg,bg: byte);
{ Set the current colors to 'fg' and 'bg' }

Procedure DrawBox(x1,y1,x2,y2,bfg,bbg,wfg,wbg: byte;Title: string;TFG,TBG:
byte);{ Draw a box, variables are:

  x1,y1,x2,y2: Upper left and lower right corners
  bfg,bbg    : Color of the box
  wfg,wbg    : Color of the inside of the box
  Title      : A title to give to the box, special chars are:
               '!'  - Put title on upper left side
               '@'  - Centre title on upper side
               '#'  - Put title on upper right side
  Tfg,Tbg    : Color of the title

  Example:

  DrawBox(1,1,80,25,11,0,7,0,'!Upper left',15,0);
}

Procedure ErrorMessage(Message: string);
{ Displays an errormessage }
Procedure Message(Message: string);
{ Displays a normal message }
Function AskBox(S,T: String;bfg,bbg,tfg,tbg: Byte): Boolean;
{ Ask a Yes/No question, returns TRUE on yes }

Procedure CursorOff;
{ Turns cursor off }
Procedure CursorOn;
{ Turns cursor on }

Function TopMenu: Byte;
{ Start the mainmenu }
Procedure SubMenu(Var Which: Byte);
{ Execute a submenu }
Procedure SetXTab;
{ Used to get a table for the menu positions }

Procedure PopScreen;
{ Save a screen to savestack}
Procedure PushScreen;
{ Restore a screen from savestack }

Procedure HelpLine(S: string);
{ Prints a helpline on line 25 }
Procedure ClearHelp;
{ Clear line 25}

Implementation
Uses Crt,Dos;
Var
  SaveCurHi   : Byte; { High scan line of cursor }
  SaveCurLo   : Byte; { Low scanline of cursor }

  RemTop      : Byte; { Temp save for top menu position }
  SaveStack   : ^SaveStackType; { Screen save stack }
  SaveStackPtr: Byte; { Screen save stack pointer }

Procedure WaitKey;  { Waits for a key }
Begin
  ReadKey;
End;

Function FStr(A: Longint): string; { Turns a longint to a string }
Var
  Temp : string;
Begin
  Str(A,Temp);
  FStr :=Temp;
End;

Function FVal(S: string): Longint; { Turns a string into a longint }
Var
  Temp: Longint;
  Code: Integer;
Begin
  Val(S,Temp,Code);
  FVal :=Temp;
End;

Function ForceBack(s: string): string; { Adds a '\' to a string if it's not
there }Begin
  If S[length(s)]<>'\' then S :=s+'\';
  ForceBack :=s;
End;

Function LZ(w : Word) : String;
Var
  S : String;
begin
  Str(w:0,s);
  if Length(s)=1 then s := '0' + s;
  LZ := s;
end;

Procedure ClrScr; { Clears the screen, keeping the current unit colors }
Var
  Bak : byte;
Begin
  Bak :=TextAttr;
  TextColor(7);
  TextBackGround(0);
  Crt.ClrScr;
  TextAttr :=Bak;
End;

Function Expand(S: string;Len: Byte): String; { Expand a string }
Begin
  Expand :=S;
  If Length(S)>Len then Exit;
  While Length(s)<Len do S :=S+' ';
  Expand :=S;
End;

Function BasePath: String; { Get the program's own path }
Var
  P: PathStr;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
Begin
  P :=ParamStr(0);
  FSplit(P,D,N,E);
  BasePath :=ForceBack(FExpand(D));
End;

Procedure SetXTab; { Set the XTab for the menus }
Var
  Tel : byte;
Begin
  For Tel :=2 to 10 do XTab[Tel]
:=XTab[Tel-1]+Length(Menu^[Tel-1].ItemName)+2;End;

Procedure PushScreen;
Var
  SaveStackFile : File of VMemType;
Begin
  If SaveStackPtr=50 then
  Begin
    ErrorMessage('Screen save stack overflow');
    Halt(10);
  End;
  If (MaxAvail<10000) or (SaveStackPtr>StackMaxMem) then
  With SaveStack^[SaveStackPtr] do
  Begin
    UseDisk :=TRUE;
    FName :=BasePath+'SAV'+FStr(SaveStackPtr)+'.TMP';
    Assign(SaveStackFile,FName);
    {$i-}
    Rewrite(SaveStackFile);
    {$i+}
    If IOResult<>0 then
    Begin
      ErrorMessage('Cannot open temporary file for writing');
      Halt(10);
    End;
    Case Mono of
      TRUE : Write(SaveStackFile,MonoMem);
      FALSE: Write(SaveStackFile,ColorMem);
    End;
    Close(SaveStackFile);
  End
  Else With SaveStack^[SaveStackPtr] do
  Begin
    GetMem(MemPtr,4000);
    Case Mono of
      TRUE : Move(MonoMem,MemPtr^,4000);
      FALSE: Move(ColorMem,MemPtr^,4000);
    End;
  End;
  Inc(SaveStackPtr);
End;

Procedure PopScreen;
Var
  SaveStackFile : File of VMemType;
  Temp          : VMemType;
Begin
  If SaveStackPtr=1 then Exit;
  Dec(SaveStackPtr);
  With SaveStack^[SaveStackPtr] do
  Begin
    If UseDisk then
    Begin
      Assign(SaveStackFile,FName);
      {$i-}
      Reset(SaveStackFile);
      {$i+}
      If IOResult<>0 then
      Begin
        ErrorMessage('Cannot open temporary file for reading');
        Halt(10);
      End;
      Read(SaveStackFile,Temp);
      Close(SaveStackFile);
      Case Mono of
        TRUE : Move(Temp,MonoMem,4000);
        FALSE: Move(Temp,ColorMem,4000);
      End;
    End else
    Begin
      Case Mono of
        TRUE : Move(MemPtr^,MonoMem,4000);
        FALSE: Move(MemPtr^,ColorMem,4000);
      End;
      FreeMem(MemPtr,4000);
      MemPtr :=NIL;
    End;
  End;
End;

Procedure CursorOff; assembler;
ASM
  MOV           AX,0300h
  MOV           BH,0
  INT           10h
  MOV           [SaveCurHi],CH
  MOV           [SaveCurLo],CL
  MOV           AX,0100h
  MOV           CX,2000h
  INT           10h
END;

Procedure CursorOn; assembler;
ASM
  MOV           AX,0100h
  MOV           CH,[SaveCurHi]
  MOV           CL,[SaveCurLo]
  INT           10h
END;

Procedure Color(fg,bg: byte);
Begin
  TextColor(Fg);
  TextBackground(bg);
End;

Function GetAttr(X,Y: Byte): Byte;
Begin
  Case Mono of
    TRUE : GetAttr :=MonoMem[Y,X].VAttr;
    FALSE: GetAttr :=ColorMem[Y,X].VAttr;
  End;
End;

Procedure SetAttr(X,Y,Attr: byte);
Begin
  Case Mono of
    TRUE : MonoMem[Y,X].VAttr :=Attr;
    FALSE: ColorMem[Y,X].VAttr :=Attr;
  End;
End;

Function MakeAttr(Fg,Bg: Byte): Byte; { Creates an attribute out of a
foreground/background color }Begin
  MakeAttr :=Fg+16*Bg;
End;

Procedure SetAttrRange(X1,X2,Y,Attr: Byte); { Sets the attribute over a range
}Var
  Tel : Byte;
Begin
  For Tel :=1 to x2-x1 do SetAttr(x1-1+Tel,Y,Attr);
End;

Procedure VWrite(Ch: char;x,y: byte);
Begin
  Case Mono of
    TRUE : With MonoMem[Y,X] do
           Begin
             VChar :=Ch;
             VAttr :=TextAttr;
           End;
    FALSE: With ColorMem[Y,X] do
           Begin
             VChar :=Ch;
             VAttr :=TextAttr;
           End;
  End;
End;

Procedure VWriteCh(Ch: char;x,y: byte);
Begin
  VWrite(ch,x,y);
End;

Procedure VWriteStr(S: string;fg,bg,x,y: byte);
Var
  Tel : byte;
  Bak : byte;
Begin
  Bak :=TextAttr;
  Color(Fg,Bg);
  For Tel :=1 to length(s) do VWrite(S[Tel],x-1+tel,y);
  TextAttr :=Bak;
End;

{ Returns the appropriate shade color for the 'drawbox' routine }
Function ReturnShade(X,Y: byte): Byte;
Var
  TA : Byte;
  FG : Byte;
  BG : Byte;
Begin
  TA :=GetAttr(x,y);
  BG :=TA SHR 4;
  FG :=TA-BG;
  If Fg>8 then
  Begin
    Dec(Fg,8);
    Bg :=0;
  End
  else
  Begin
    Fg :=8;
    Bg :=0;
  End;
  ReturnShade :=Fg+(16*Bg);
End;

Procedure DrawBox(x1,y1,x2,y2,bfg,bbg,wfg,wbg: byte;Title: string;TFG,TBG:
byte);Var
  Tel,Tel2: byte;
  A,B: Word;
Begin
  A :=WindMax;
  B :=WindMin;
  Color(wfg,wbg);
  Window(x1,y1,x2,y2);
  Crt.ClrScr;
  WindMax :=A;
  WindMin :=B;
  Color(bfg,bbg);
  For Tel :=1 to x2-x1 do
  Begin
    VWriteCh('═',x1-1+tel,y1);
    VWriteCh('═',x1-1+tel,y2);
  End;
  For Tel :=1 to y2-y1 do
  Begin
    Color(bfg,bbg);
    VWriteCh('│',x1,y1-1+tel);
    Color(bfg,bbg);
    VWriteCh('│',x2,y1-1+tel);
  End;
  VWriteCh('╛',x2,y2);
  VWriteCh('╕',x2,y1);
  VWriteCh('╘',x1,y2);
  VWriteCh('╒',x1,y1);
  For Tel :=1 to x2-x1 do SetAttr(x1+Tel,y2+1,ReturnShade(x1+Tel,y2+1));
  For Tel :=1 to (y2-y1)+1 do SetAttr(x2+1,y1+Tel,ReturnShade(x2+1,y1+Tel));
  If Title<>'' then
  Begin
    If Title[1]='!' then VWriteStr(' '+Copy(Title,2,Length(Title)-1)+'',Tfg,Tbg,x1+2,y1);
    If Title[1]='@' then VWriteStr(''+Copy(Title,2,Length(Title)-1)+' ',Tfg,Tbg,x2-Length(Title)-2,y1);
    If Title[1]='#' then VWriteStr(' '+Copy(Title,2,Length(Title)-1)+'',Tfg,Tbg,x1+((x2-x1) div 2)-(Length(Title) div 2),y1);
    End;
End;

Procedure HelpLine(S: string);
Begin
  VWriteStr(Expand(S,79),CommentColor,0,2,25);
End;

Procedure ClearHelp;
Begin
  VWriteStr(Expand(' ',79),7,0,2,25);
End;

Procedure Message(Message: string);
Const
  Prompt = 'Press any key';
Var
  A   : Byte;
Begin
  PushScreen;
  ClearHelp;
  Message :=Message+' - '+Prompt;
  A :=40-(Length(Message) div 2);
  DrawBox(a,11,a+Length(Message)+1,15,12,4,14,4,'',15,4);
  VWriteStr(Message,14,4,a+1,13);
  WaitKey;
  PopScreen;
End;

Procedure ErrorMessage(Message: string);
Const
  Prompt = 'Press any key';
Var
  A   : Byte;
Begin
  PushScreen;
  ClearHelp;
  Message :=Message+' - '+Prompt;
  A :=40-(Length(Message) div 2);
  DrawBox(a,11,a+Length(Message)+1,15,12,4,14,4,'!ERROR',15,4);
  VWriteStr(Message,14,4,a+1,13);
  WaitKey;
  PopScreen;
End;

Function AskBox(S,T: String;bfg,bbg,tfg,tbg: Byte): Boolean;
Var
  A   : Byte;
  Ch  : Char;
Begin
  PushScreen;
  A :=40-(Length(S) div 2);
  DrawBox(a,12,a+Length(S)+1,14,Bfg,Bbg,Tfg,Tbg,T,Tfg,TBg);
  VWriteStr(S,Tfg,Tbg,a+1,13);
  Repeat
    Ch :=UpCase(ReadKey);
  Until Ch in ['Y','N'];
  AskBox :=(Ch='Y');
  PopScreen;
End;

{ Used internally for the submenu's }
Function GetLastX(SubRec: SubMenuType): Byte;
Var
  Temp : Byte;
  Tel  : Byte;
Begin
  Temp :=0;
  For Tel :=1 to 20 do with SubRec[Tel] do If ItemName<>'' then If
Length(ItemName)>Temp then Temp :=Length(ItemName);  GetLastX :=Temp;
End;

{ Used internally for the submenu's }
Function GetLastY(SubRec: SubMenuType): Byte;
Var
  Temp : Byte;
  Tel  : Byte;
Begin
  Temp :=0;
  For Tel :=1 to 20 do With SubRec[Tel] do If ItemName<>'' then Inc(Temp);
  GetLastY :=Temp;
End;

{ Used internally for the main menu }
Function TopItems: Byte;
Var
  Tel : Byte;
  Temp: Byte;
Begin
  Temp :=0;
  For Tel :=1 to 10 do If Menu^[Tel].ItemName<>'' then Inc(Temp);
  TopItems :=Temp;
End;

{ Draws the main menu }
Procedure DrawTop;
Var
  Tel : Byte;
Begin
  For Tel :=1 to TopItems do VWriteStr(Menu^[Tel].ItemName,7,0,XTab[Tel],1);
End;

{ Draws a sub menu }
Procedure DrawMenu(Which: Byte;Var LastX,LastY: Byte);
Var
  Tel    : Byte;
Begin
  LastX :=GetLastX(Menu^[Which].SubMenu);
  LastY :=GetLastY(Menu^[Which].SubMenu);
  DrawBox(XTab[Which],2,XTab[Which]+LastX+1,2+LastY+1,11,0,7,0,'',0,0);
  For Tel :=1 to LastY do
VWriteStr(Menu^[Which].SubMenu[Tel].ItemName,7,0,XTab[Which]+1,2+Tel);
DrawTop;  VWriteStr(Menu^[Which].ItemName,1,3,XTab[Which],1);
End;

Procedure SubMenu(Var Which: Byte);
Var
  MPos  : Byte;
  OPos  : Byte;
  LastY : Byte;
  LastX : Byte;
  TI    : Byte;
  OW    : Byte;
Begin
  DrawTop;
  PushScreen;
  TI :=TopItems;
  MPos :=SubRemP[Which];
  OPos :=MPos;
  OW :=0;
  DrawMenu(Which,LastX,LastY);
  While True Do
  Begin

VWriteStr(Expand(Menu^[Which].SubMenu[MPos].ItemName,LastX),1,7,XTab[Which]+1,2+MPos);
HelpLine(Menu^[Which].SubMenu[MPos].ItemHelp);
    If MPos<>OPos then
VWriteStr(Expand(menu^[Which].SubMenu[OPos].ItemName,LastX),7,0,XTab[Which]+1,2 +OPos);
OPos :=MPos;    OW :=Which;
    Case ReadKey of
      #0: Case ReadKey of
            #80: If MPos<LastY then Inc(MPos) else MPos :=1;
            #77: Begin
                   PopScreen;
                   PushScreen;
                   SubRemP[Which] :=MPos;
                   If Which<TI then Inc(Which) else Which :=1;
                   DrawMenu(Which,LastX,LastY);
                   RemTop :=Which;
                   MPos :=SubRemP[Which];
                   OPos :=MPos;
                 End;
            #75: Begin
                   PopScreen;
                   PushScreen;
                   SubRemP[Which] :=MPos;
                   If Which>1 then Dec(Which) else Which :=TI;
                   DrawMenu(Which,LastX,LastY);
                   RemTop :=Which;
                   MPos :=SubRemP[Which];
                   OPos :=MPos;
                 End;
            #72: If MPos>1 then Dec(MPos) else MPos :=LastY;
          End;
     #13: Begin
            SubRemP[Which] :=MPos;
            PushScreen;
            Menu^[Which].SubMenu[MPos].ItemProc;
            PopScreen;
          End;
     #27: Begin
            SubRemP[Which] :=MPos;
            PopScreen;
            Exit;
          End;
    End;
  End;
End;

Function TopMenu: Byte;
Var
  MPos,OPos: Byte;
  TI       : Byte;
Begin
  DrawTop;
  PushScreen;
  MPos :=RemTop;
  OPos :=MPos;
  TI :=TopItems;
  While True do
  Begin
    VWriteStr(Menu^[MPos].ItemName,1,3,XTab[MPos],1);
    HelpLine(Menu^[MPos].ItemHelp);
    If OPos<>MPos then VWriteStr(Menu^[OPos].ItemName,7,0,XTab[OPos],1);
    OPos :=MPos;
    Case ReadKey of
      #0: Case ReadKey of
            #77: If MPos<TI then Inc(MPos) else MPos :=1;
            #75: If MPos>1 then Dec(MPos) else MPos :=TI;
            #80: Begin
                   TopMenu :=MPos;
                   RemTop :=MPos;
                   Exit;
                 End;
          End;
     #13: Begin
            TopMenu :=MPos;
            RemTop :=MPos;
            Exit;
          End;
    End;
  End;
End;

Procedure ExitProcedure;
Var
  Tel : byte;
  T   : file;
Begin
  Color(7,0);
  Crt.ClrScr;
  CursorOn;
End;

Var
  Tel : byte;

Begin
  Case LastMode of
    7: VideoSegment :=$B000;
    3: VideoSegment :=$B800;
    else VideoSegment :=$B800;
  End;
  OldExit :=ExitProc;
  ExitProc :=@ExitProcedure;
  CursorOff;
  SaveStackPtr :=1;
  XTab[1] :=2;
  FillChar(SubRemP,SizeOf(SubRemP),1);
  RemTop :=1;
  New(Menu);
  New(SaveStack);
  FillChar(SaveStack^,SizeOf(SaveStack^),0);
  FillChar(Menu^,SizeOf(Menu^),0);
  CommentColor :=7;
End.
