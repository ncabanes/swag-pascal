(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0044.PAS
  Description: File Browser Package
  Author: DANIEL PERRENOUD
  Date: 02-28-95  09:53
*)

{
**************************************************************************
*                                                                        *
*     File Browser Package V1.0       by Daniel Perrenoud                *
*     ~~~~~~~~~~~~~~~~~~~~~~~~~                                          *
*     o Released to the Public domain, feel free to use and copy         *
*       this program without any restriction.                            *
*     o Please credit me if your program uses these routines.            *
*     o Your comments are welcome. You can contact me on                 *
*                                  e-mail: d_perren@kla.com              *
*                                                                        *
*                                  or by post:                           *
*                                                                        *
*                                  Daniel Perrenoud                      *
*                                  Mont-Pugin 8                          *
*                                  CH-2400 Le Locle                      *
*                                  SWITZERLAND                           *
*                                                                        *
*     !!! Please compile me with range checking turned OFF  !!!          *
*                                                                        *
*                                                                        *
**************************************************************************

This set of routine makes possible to display and walk through a text file
of any length. The content of the currently selected line as well as the
selected line number are available in global variables. The text file is
diplayed in a window fully parametrable by the user (position, size,
color). For better performance, use File Browser together with a disk
caching program like MS-DOS SmartDrive.

Six functions and procedures are available for File Browser control:


---> Procedure InitFB(FN:str255;WUX,WUY,WLX,WLY,BC,FC,SBC,SFC:Word)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     InitFB initialises the File Browser and displays the first screen
     of the file. The first line is selected.

     Parameters:  FN:       Path and file name to display (MS-DOS format)
                  WUX,WUY:  Upper left corner of the window
                  WLX,WLY:  Lower right corner of the window
                  BC:       Background color of normal text
                  FC:       Foreground color of normal text
                  SBC:      Background color of selected line
                  SFC:      Foreground color of selected line



---> Function UpArrow:Boolean
     ~~~~~~~~~~~~~~~~~~~~~~~~
     UpArrow tries to select the previous line. It returns FALSE if the
     previous line is not selectable because the top line is already
     selected.



---> Function DnArrow:Boolean
     ~~~~~~~~~~~~~~~~~~~~~~~~
     DnArrow tries to select the next line. It returns FALSE if the
     next line is not selectable because the bottom line is already
     selected.



---> Function PgUp:Boolean
     ~~~~~~~~~~~~~~~~~~~~~
     PgUp tries to display the previous screen of text. If the top line
     is reached before one complete screen has scrolled, PgUp returns
     FALSE and only the possible number of lines is scrolled.



---> Function PgDn:Boolean
     ~~~~~~~~~~~~~~~~~~~~~
     PgDn tries to display the next screen of text. If the bottom line
     is reached before one complete screen has scrolled, PgDn returns
     FALSE and only the possible number of lines is scrolled.



---> Procedure CloseFB
     ~~~~~~~~~~~~~~~~~
     CloseFB stops File Browser activity. It must be used when FB is
     no longer used in order to close the open files.


The status of File Browser can be read through two variables:


---> SelAbsInd:Longint
     ~~~~~~~~~~~~~~~~~
     Selected line number. SelAbsInd=0 if the first line is selected.


---> Image[SelCirInd]:Str255
     ~~~~~~~~~~~~~~~~~~~~~~~
     Text of selected line. The CR or LF charaters have been removed.



This file is ready to be compiled by TP4.0 or better. A short example is
included, showing how FB works.

CAUTION: FB routines change the window attributs by using the PASCAL
         WINDOW procedure.


Future extensions:
~~~~~~~~~~~~~~~~~~
o Left and right scrolling to display long lines
o Direct access to a specific line number
o Find text module
o Tag-untag line handling
o Mouse support
o Speed improvement by writing some ASM modules.
o A decent error handling!

Let me know if you have other ideas ( e-mail: d_perren@kla.com )
}


program FileBrws;

uses           DOS,CRT;

type  Str255=String[255];

const NbRec=        255;
      FrontCst=     0;
      BackCst=      1;
      CRcst=        $0D;
      LFcst=        $0A;


var   FileBrowse:                               array[0..2] of File;
      CurLine,Packet:                           array[0..2] of Str255;
      Image:                                    array[0..25] of Str255;
      PacketInd,Numread:                        array[0..2] of Word;
      FirstCirInd,ScrInd,SelCirInd:             Word;
      MaxLine,VWUX,VWUY,VWLX,VWLY:              Word;
      ColListBG,ColListFG,ColSListBG,ColSListFG:Word;
      Ch,TmpChar:                               Char;
      EndFile,EOP,Again,Dummy,ExtKey:           Boolean;
      FileName:                                 Str255;
      FilLinNum:                                Array[0..2] of Longint;
      SelAbsInd:                                Longint;

Function WaitKey:Char;
var   WK:         Char;
begin
  ExtKey:=FALSE;
  repeat
  until keypressed;
  WK:=ReadKey;
  if WK=#0 then
  begin
    ExtKey:=TRUE;
    WK:=ReadKey;
  end;
  WaitKey:=WK
end;

Procedure Initialize;
begin
  assign(FileBrowse[0],FileName);
  assign(FileBrowse[1],FileName);
  assign(FileBrowse[2],FileName);
  reset(FileBrowse[0],1);
  reset(FileBrowse[1],1);
  reset(FileBrowse[2],1);
  window(VWUX,VWUY,VWLX+1,VWLY);
  ClrScr;
end;

Procedure CloseFB;
begin
  close(FileBrowse[0]);
  close(FileBrowse[1]);
  close(FileBrowse[2]);
end;

Procedure ReadPrevPacket(FN:integer);
begin
  seek(FileBrowse[FN],(FilePos(FileBrowse[FN])-Numread[FN]-NbRec));
  blockread(FileBrowse[FN],Packet[FN][1],NbRec,Numread[FN]);
  Packet[FN][0]:=chr(Numread[FN]);
  PacketInd[FN]:=NbRec;
end;

Function ReadNextLine(FN:integer):Boolean;
var   EOP:        Boolean;
      CurLinInd:  Word;

begin
  ReadNextLine:=FALSE;
  if (EndFile=FALSE) or (FN=BackCst) then
  begin
    CurLinInd:=1;
    repeat
      repeat
        TmpChar:=Packet[FN][PacketInd[FN]];
        CurLine[FN][CurLinInd]:=TmpChar;
        inc(CurLinInd);
        inc(PacketInd[FN]);
        EOP:=(PacketInd[FN]>Length(Packet[FN]))
      until ((ord(TmpChar)=CRcst) OR (EOP));
      if EOP then
        if Numread[FN]<>NbRec then
          EndFile:=TRUE
        else
          begin
            blockread(FileBrowse[FN],Packet[FN][1],NbRec,Numread[FN]);
            Packet[FN][0]:=chr(Numread[FN]);
            PacketInd[FN]:=1;
          end;
    until ((ord(TmpChar)=CRcst) or (EndFile));
    ReadNextLine:=TRUE;
    inc(FilLinNum[FN]);
    CurLine[FN][0]:=chr(CurLinInd-1);
  end;
end;


Procedure Read1stLine(FN:integer);
var   CurLinInd:  Word;
      EOP:        Boolean;

begin
  EndFile:=FALSE;
  reset(FileBrowse[FN],1);
  blockread(FileBrowse[FN],Packet[FN][1],NbRec,Numread[FN]);
  Packet[FN][0]:=chr(Numread[FN]);
  PacketInd[FN]:=1;
  CurLinInd:=1;
  repeat
    repeat
      TmpChar:=Packet[FN][PacketInd[FN]];
      CurLine[FN][CurLinInd]:=TmpChar;
      inc(CurLinInd);
      inc(PacketInd[FN]);
      EOP:=(PacketInd[FN]>Length(Packet[FN]))
    until ((ord(TmpChar)=CRcst) OR (EOP));
    if EOP then
      if Numread[FN]<>NbRec then
        EndFile:=TRUE
      else
        begin
          blockread(FileBrowse[FN],Packet[FN][1],NbRec,Numread[FN]);
          Packet[FN][0]:=chr(Numread[FN]);
          PacketInd[FN]:=1;
        end;
  until ((ord(TmpChar)=CRcst) or (EndFile));
  CurLine[FN][0]:=chr(CurLinInd-1);
  FilLinNum[FN]:=0;
end;


Function ReadPrevLine(FN:integer):Boolean;
var   Dummy:      Boolean;
      CurLinInd:  Word;
      i:          Integer;

begin
  CurLinInd:=1;
  ReadPrevLine:=FALSE;
  if FilLinNum[FN]>0 then
  begin
    if PacketInd[FN]>1 then
      dec(PacketInd[FN])
    else
      ReadPrevPacket(FN);
    TmpChar:=' ';
    for i:=1 to 2 do
    begin
      while (ord(TmpChar)<>CRcst) and ((FilLinNum[FN]<>0) or (PacketInd[FN]<>1)) do
      begin
        if PacketInd[FN]>1 then
          dec(PacketInd[FN])
        else
          ReadPrevPacket(FN);
        TmpChar:=Packet[FN][PacketInd[FN]];
      end;
      TmpChar:=' ';
      dec(FilLinNum[FN]);
      EndFile:=FALSE;
    end;
    if FilLinNum[FN]<>-1 then
      inc(PacketInd[FN]);
    if PacketInd[FN]>Length(Packet[FN]) then
    begin
      blockread(FileBrowse[FN],Packet[FN][1],NbRec,Numread[FN]);
      Packet[FN][0]:=chr(Numread[FN]);
      PacketInd[FN]:=1;
    end;
    Dummy:=ReadNextLine(FN);
    ReadPrevLine:=TRUE;
  end;
end;


Function CleanString(ALine:str255):str255;
var   i,j:        Integer;

begin
  j:=1;
  i:=1;
  repeat
    if (ord(ALine[i])<>CRcst) and (ord(ALine[i])<>LFcst) then
    begin
      CleanString[j]:=ALine[i];
      inc(j);
    end;
    inc(i);
  until (i>ord(ALine[0])) or (j>VWLX-VWUX+1);
  CleanString[0]:=chr(j-1);
end;


Procedure DispSelLine;

begin
  TextBackground(ColSListBG);
  TextColor(ColSListFG);
  GotoXY(1,ScrInd+1);
  write(Image[SelCirInd]);
end;


Procedure UndispSelLine;

begin
  TextBackground(ColListBG);
  TextColor(ColListFG);
  GotoXY(1,ScrInd+1);
  write(Image[SelCirInd]);
end;


Function IncMod(i:Word):Word;

begin
    IncMod:=(i+1) mod MaxLine;
end;


Function DecMod(i:Word):Word;

begin
    DecMod:=(i+MaxLine-1) mod MaxLine;
end;


Procedure RefreshScreen;
var   CleanLine:  Str255;
      i,j:        Word;

begin
  i:=FirstCirInd;
  j:=1;
  TextBackground(ColListBG);
  TextColor(ColListFG);
  ClrScr;
  repeat
    GotoXY(1,j);
    write(Image[i]);
    i:=IncMod(i);
    inc(j);
  until i=FirstCirInd;
  DispSelLine;
end;


Procedure FirstScreen;
var   CleanLine:  Str255;
      i:          Integer;
      LineOK:     Boolean;

begin
  FirstCirInd:=0;
  Read1stLine(FrontCst);
  CleanLine:=CleanString(CurLine[FrontCst]);
  Image[FirstCirInd]:=CleanLine;
  TextBackground(ColListBG);
  TextColor(ColListFG);
  GotoXY(1,FirstCirInd+1);
  write(CleanLine);
  FirstCirInd:=IncMod(FirstCirInd);
  repeat
    LineOK:=ReadNextLine(FrontCst);
    CleanLine:=CleanString(CurLine[FrontCst]);
    Image[FirstCirInd]:=CleanLine;
    GotoXY(1,FirstCirInd+1);
    write(CleanLine);
    FirstCirInd:=IncMod(FirstCirInd);
  until (FirstCirInd=0) or (LineOK=FALSE);
  Read1stLine(BackCst);
  SelCirInd:=0;
  SelAbsInd:=0;
  ScrInd:=0;
  DispSelLine;
end;


Function ScrollUp:Boolean;
var   IsScrolled: Boolean;
      Dummy:      Boolean;
      CleanLine:  Str255;

begin
  IsScrolled:=ReadNextLine(FrontCst);
  if IsScrolled then
  begin
    CleanLine:=CleanString(CurLine[FrontCst]);
    Image[FirstCirInd]:=CleanLine;
    FirstCirInd:=IncMod(FirstCirInd);
    TextBackground(ColListBG);
    TextColor(ColListFG);
    GotoXY(1,1);
    DelLine;
    GotoXY(1,MaxLine);
    write(CleanLine);
    Dummy:=ReadNextLine(BackCst);
  end;
  ScrollUp:=IsScrolled;
end;


Function ScrollDn:Boolean;
var   IsScrolled: Boolean;
      Dummy:      Boolean;
      CleanLine:  Str255;

begin
  IsScrolled:=ReadPrevLine(BackCst);
  if IsScrolled then
  begin
    CleanLine:=CleanString(CurLine[BackCst]);
    FirstCirInd:=DecMod(FirstCirInd);
    Image[FirstCirInd]:=CleanLine;
    TextBackground(ColListBG);
    TextColor(ColListFG);
    GotoXY(1,1);
    InsLine;
    GotoXY(1,1);
    write(CleanLine);
    Dummy:=ReadPrevLine(FrontCst);
  end;
  ScrollDn:=IsScrolled;
end;


Function DnArrow:Boolean;
Var   Success:    Boolean;

begin
  window(VWUX,VWUY,VWLX+1,VWLY);
  UndispSelLine;
  Success:=TRUE;
  If IncMod(SelCirInd)=FirstCirInd then
  begin
    Success:=ScrollUp;
    If Success then
    begin
      SelCirInd:=IncMod(SelCirInd);
      inc(SelAbsInd);
    end
    else;
  end
  else
  begin
    SelCirInd:=IncMod(SelCirInd);
    inc(SelAbsInd);
    inc(ScrInd);
  end;
  DnArrow:=Success;
  DispSelLine;
end;


Function UpArrow:Boolean;
Var   Success:    Boolean;

begin
  window(VWUX,VWUY,VWLX+1,VWLY);
  UndispSelLine;
  Success:=TRUE;
  If SelCirInd=FirstCirInd then
  begin
    Success:=ScrollDn;
    If Success then
    begin
      SelCirInd:=DecMod(SelCirInd);
      Dec(SelAbsInd);
    end
    else;
  end
  else
  begin
    SelCirInd:=DecMod(SelCirInd);
    dec(SelAbsInd);
    dec(ScrInd);
  end;
  UpArrow:=Success;
  DispSelLine;
end;


Function PgUp:Boolean;
Var   Complete,Dummy:   Boolean;
      i:                Word;
      CleanLine:        Str255;

begin
  window(VWUX,VWUY,VWLX+1,VWLY);
  i:=MaxLine;
  repeat
    Complete:=ReadPrevLine(BackCst);
    If Complete then
    begin
      CleanLine:=CleanString(CurLine[BackCst]);
      FirstCirInd:=DecMod(FirstCirInd);
      Image[FirstCirInd]:=CleanLine;
      SelCirInd:=DecMod(SelCirInd);
      Dec(SelAbsInd);
      Dec(i);
      Dummy:=ReadPrevLine(FrontCst);
    end;
  until (i=0) or (Complete=FALSE);
  RefreshScreen;
end;


Function PgDn:Boolean;
Var   Complete,Dummy:   Boolean;
      i:                Word;
      CleanLine:        Str255;

begin
  window(VWUX,VWUY,VWLX+1,VWLY);
  i:=MaxLine;
  repeat
    Complete:=ReadNextLine(FrontCst);
    If Complete then
    begin
      CleanLine:=CleanString(CurLine[FrontCst]);
      Image[FirstCirInd]:=CleanLine;
      FirstCirInd:=IncMod(FirstCirInd);
      SelCirInd:=IncMod(SelCirInd);
      inc(SelAbsInd);
      Dec(i);
      Dummy:=ReadNextLine(BackCst);
    end;
  until (i=0) or (Complete=FALSE);
  RefreshScreen;
end;


Procedure InitFB(FN:str255;WUX,WUY,WLX,WLY,BC,FC,SBC,SFC:Word);

begin
  FileName:=FN;
  ColListBG:=BC;
  ColListFG:=FC;
  ColSListBG:=SBC;
  ColSListFG:=SFC;
  VWUX:=WUX;
  VWUY:=WUY;
  VWLX:=WLX;
  VWLY:=WLY;
  MaxLine:=1+WLY-WUY;
  Initialize;
  FirstScreen;
end;

{------------------- END OF FILE BROWSER MODULE ---------------------------}

{
The following program shows a way to use the File Browser. It displays
its own source code (!!) and handles the arrows and PgUp PgDn keys.
The current line number and current line content are displayed on the
bottom line.
Be sure to place THIS source code (filebrws.pas) in the directory from
which you run this program!
Press q to quit.
}

begin
  ClrScr;
  InitFB('Browse.pas',1,1,70,20,Black,LightGray,LightGray,Black);
  repeat
    Ch:=WaitKey;
    if ExtKey then
    begin
      if Ch=#80 then Dummy:=DnArrow;
      if Ch=#72 then Dummy:=UpArrow;
      if Ch=#73 then Dummy:=PgUp;
      if Ch=#81 then Dummy:=PgDn;
      window(1,25,80,25);
      TextBackground(ColListBG);
      TextColor(ColListFG);
      write(SelAbsInd);
      write(':');
      write(Image[SelCirInd]);
    end;
  until (ExtKey=FALSE) and (Ch='q');
  CloseFB;
end.

