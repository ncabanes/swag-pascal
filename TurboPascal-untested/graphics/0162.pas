
{Hi !!!

 Thanx for answering on my mail, here are two sources which i grabed from
 Data Master 1.0 for VGA, it will probably work on other cards, but i tested
 them only on VGA 640x480x16 in Turbo Pascal 7.0

 There are two sources:
 1. SaveScn.Pas       (Capture Graphical Screens to file)
    Creates simple Graphical look of screen, and save it to file.
    All procedures are independent and can be cuted to another programs
    which deal with graphics. It can save all or just a part of screen.
    Procedures Ikona and BIkona are taked from unit Grafika and they are
    creation of Kristijan Lukacin (programmer for graphics on Data Master, 
    i deal with files, and other non-graphics, or with little graphics parts 
    of program).
 
 2. ReadScrn.Pas      (Reading and Showing Saved Images)
    This will show saved image to screen (here isn't solved showing saved
    images of edge of screen, if ANY part of saved image goes over screen
    edge nothing will be showed on screen).
  

Thanx !!!

                AMATRIX Software Developement Coorporation
                             1994, Croatia
                       Communication with us thrue

        E-mail: piko@cromath.math.hr

        Snail mail: Varoska 67
                    41040 Zagreb
                    Croatia

                    Markusevacka cesta
                    41000 Zagreb
                    Croatia

        Fax/Phone: (99 385)(0)41 283 505,  contact person Kresimir Mihalj
                   (99 385)(0)41 277 221,  contact person Kristijan Lukacin

}

{***************************************************************************}

{             Save all or just part of graphical screen to file

{***************************************************************************}
PROGRAM SaveImage;
USES Graph, Dos, CRT;
Var GD, GM: Integer;
    hmm: Boolean;

Procedure CIkona(x1,y1,x2,y2,text:integer;tekstikone:string); {Ikone}
  Begin
   SetColor(White);
   SetFillStyle(SolidFill,2);
   Bar(x1,y1,x2,y2);
   SetColor(Black);
   SetLineStyle(0,0,1);
   Rectangle(x1-1,y1-2,x2+1,y2+1);
   SetColor(White);
   Line(x1,y1-1,x2,y1-1);
   Line(x1,y1,x1,y2-1);
   SetColor(DarkGray);
   Line(x1+1,y2,x2,y2);
   Line(x2,y2,x1,y2);
   SetTextStyle(0,0,0);
   SetColor(DarkGray);
   OutTextXY(x1+5,y1+4+text,TekstIkone);
   SetColor(White);
   OutTextXY(x1+3,y1+2+text,TekstIkone);
  end {Ikona};

Procedure Ikona(x1,y1,x2,y2,text:integer;tekstikone:string); {Ikone}
  Begin
   SetColor(White);
   SetFillStyle(SolidFill,LightGray);
   Bar(x1,y1,x2,y2);
   SetColor(Black);
   SetLineStyle(0,0,1);
   Rectangle(x1-1,y1-2,x2+1,y2+1);
   SetColor(White);
   Line(x1,y1-1,x2,y1-1);
   Line(x1,y1,x1,y2-1);
   SetColor(DarkGray);
   Line(x1+1,y2,x2,y2);
   Line(x2,y2,x1,y2);
   SetTextStyle(0,0,0);
   SetColor(DarkGray);
   OutTextXY(x1+5,y1+4+text,TekstIkone);
   SetColor(White);
   OutTextXY(x1+3,y1+2+text,TekstIkone);
  end {Ikona};

Procedure BIkona(x1,y1,x2,y2,text:integer;tekstikone:string);  {Stisnuta Ikona}  Begin
   SetColor(White);
   SetFillStyle(SolidFill,LightGray);
   Bar(x1,y1,x2,y2);
   SetColor(Black);
   SetLineStyle(0,0,1);
   Rectangle(x1-1,y1-2,x2+1,y2+1);
   SetColor(Black);
   Line(x1,y1-1,x2,y1-1);
   Line(x1,y1,x1,y2-1);
   SetColor(DarkGray);
   Line(x1+1,y2,x2,y2);
   Line(x2,y2,x1,y2);
   SetTextStyle(0,0,0);
   SetColor(White);
   OutTextXY(x1+5,y1+4+text,TekstIkone);
   SetColor(DarkGray);
   OutTextXY(x1+3,y1+2+text,TekstIkone);
   Delay(300);
  end {Bikona};


PROCEDURE Make_Amatrix_Image_Data;
VAR ch: Char;
    k:LongInt;
    st: String;
    d: Text;
    e,z,w: File Of Char;
BEGIN
     Assign(d,'IMAGE.AID');
     Rewrite(d);
     Writeln(d,'Amatrix Image Data Version 1.0 (c) 1994 by Amatrix');
     Writeln(d, 'Developed By Kresimir Mihalj');
     Writeln(d);
     Write(d,'AISD/3 ');
     k:=0;
     Assign(e,'IMAGE2.TMP');
     Reset(e);
     WHILE Not Eof(e) DO
     BEGIN
          Read(e,Ch);
          k:=k+1;
     END;
     Append(d);
     Reset(e);
     Writeln(d,k);
     WHILE Not Eof(e) DO
     BEGIN
          Read(e,Ch);
          Write(d,Ch);
     END;
     Close(e);
     Append(d);
     Writeln(d);
     Write(d,'AIDD/3 ');
     k:=0;
     Assign(w,'IMAGE3.TMP');
     Reset(w);
     WHILE Not Eof(w) DO
     BEGIN
          Read(w,Ch);
          k:=k+1;
     END;
     Reset(w);
     Writeln(d,k);
     WHILE Not Eof(w) DO
     BEGIN
          Read(w,Ch);
          Write(d,Ch);
     END;
     Writeln(d);
     Close(w);

     Write(d,'AID/3 ');
     Assign(z,'IMAGE1.TMP');
     Reset(z);
     k:=0;
     WHILE Not Eof(z) DO
     BEGIN
          Read(z,Ch);
          k:=k+1;
     END;
     Reset(z);
     Writeln(d,k);
     WHILE Not Eof(z) DO
     BEGIN
          Read(z,Ch);
          Write(d,Ch);
     END;
     Close(z);
     Close(d);
END;

PROCEDURE Save_Image_in_Temp_Files(X1,Y1,X2,Y2: Integer);
VAR Size,Result: Word;
    P: Pointer;
    Ch: Char;
    yy1,yy2,k: Integer;
    g: File of Word;
    h: File of Integer;
    f: File;

BEGIN
     Assign(F,'IMAGE1.TMP');
     reWrite(F,1);
     Assign(g, 'IMAGE2.TMP');
     Rewrite(g);
     Assign(h, 'IMAGE3.TMP');
     Rewrite(h);
     k:=(Y2-Y1) DIV 3;
     Write(h,k);
     Size:=ImageSize(x1,y1,x2,y1+k);
     Write(g,Size);
     GetMem(P,Size);
     GetImage(x1,y1,x2,y1+k,P^);
     BlockWrite(F,P^,Size,Result);
     if Ioresult <> 0 then Halt(2);
     FreeMem(P,Size);

     Size:=ImageSize(x1,y1+k,x2,y1+(k*2));
     Write(g,Size);
     GetMem(P,Size);
     GetImage(x1,y1+k,x2,y1+(k*2),P^);
     BlockWrite(F,P^,Size,Result);
     if Ioresult <> 0 then Halt(2);
     FreeMem(P,Size);

     Size:=ImageSize(x1,y1+(k*2),x2,y2);
     Write(g,Size);
     GetMem(P,Size);
     GetImage(x1,y1+(k*2),x2,y2,P^);
     BlockWrite(F,P^,Size,Result);
     if Ioresult <> 0 then Halt(2);
     FreeMem(P,Size);
     Make_Amatrix_Image_Data;
     Rewrite(f);
     close(F);
     Erase(f);
     Rewrite(g);
     Close(g);
     Erase(g);
     Rewrite(h);
     Close(h);
     Erase(h);
END;



BEGIN
     Gd:=Detect;
     InitGraph(Gd, Gm, '\turbo\tp\');  { CHANGE THIS !!! }
     if GraphResult <> grOk then Halt(1);
{********* Create some graphics *********}
     ikona(200,160,440,380,0,' ');
     Bikona(205,165,435,375,0,' ');
     Ikona(210,170,430,195,0,' ');
     Ikona(210,202,430,245,0,' ');
     Ikona(210,252,430,370,0,' ');
     SetTextStyle(0,0,2);
     SetColor(1);
     OutTextXY(238,177,'WARNING !!!');
     SetColor(5);
     OutTextXY(237,176,'WARNING !!!');
     SetColor(4);
     OutTextXY(236,175,'WARNING !!!');
     SetColor(13);
     OutTextXY(235,174,'WARNING !!!');
     SetTextStyle(0,0,1);
     SetColor(9);
     OutTextXY(221,212,'Delete also include wipe !');
     SetColor(15);
     OutTextXY(219,210,'Delete also include wipe !');
     SetColor(9);
     OutTextXY(221,221,'Deleted  files  cannot  be');
     SetColor(15);
     OutTextXY(219,219,'Deleted  files  cannot  be');
     SetColor(9);
     OutTextXY(221,231,'undeleted  in  any  way  !');
     SetColor(15);
     OutTextXY(219,229,'undeleted  in  any  way  !');
     SetColor(8);
     OutTextXY(270,260,'Erase & Wipe');
     SetColor(15);
     OutTextXY(268,258,'Erase & Wipe');
     SetColor(9);
     OutTextXY(270,280,'command1.com');
     SetColor(15);
     OutTextXY(268,278,'command1.com');
     SetColor(9);
     OutTextXY(305,290,'arhs');
     SetColor(15);
     OutTextXY(303,288,'arhs');
     SetColor(9);
     OutTextXY(282,300,'123456789');
     SetColor(15);
     OutTextXY(280,298,'123456789');
     SetColor(9);
     OutTextXY(279,310,'22-12-1994');
     SetColor(15);
     OutTextXY(277,308,'22-12-1994');
     SetColor(9);
     OutTextXY(286,320,'12:12:12');
     SetColor(15);
     OutTextXY(284,318,'12:12:12');
     Ikona(237,342,273,360,0,' ');
     Ikona(240,345,270,357,0,'Yes');
     Ikona(297,342,325,360,0,' ');
     Ikona(300,345,322,357,0,'No');
     Ikona(349,342,407,360,0,' ');
     Ikona(352,345,404,357,0,'Always');
{ ********* end of graphic **************}
     Save_Image_in_Temp_Files(0,0,639,479);  {Save whole screen to file}
     REPEAT UNTIL Keypressed;
END.

{***************************************************************************}

{                        Show saved image to screen

{***************************************************************************}
Program ShowPic;
USES Graph, Dos, CRT;
Var GD, GM: Integer;
    X, Y, Button: Integer ;
    hmm: Boolean;
    Size,Result: Word;
    P: Pointer;
    Ch: Char;
    f: File;
    g: File Of Word;
    h: File Of Integer;

Procedure CIkona(x1,y1,x2,y2,text:integer;tekstikone:string); {Ikone}
  Begin
   SetColor(White);
   SetFillStyle(SolidFill,2);
   Bar(x1,y1,x2,y2);
   SetColor(Black);
   SetLineStyle(0,0,1);
   Rectangle(x1-1,y1-2,x2+1,y2+1);
   SetColor(White);
   Line(x1,y1-1,x2,y1-1);
   Line(x1,y1,x1,y2-1);
   SetColor(DarkGray);
   Line(x1+1,y2,x2,y2);
   Line(x2,y2,x1,y2);
   SetTextStyle(0,0,0);
   SetColor(DarkGray);
   OutTextXY(x1+5,y1+4+text,TekstIkone);
   SetColor(White);
   OutTextXY(x1+3,y1+2+text,TekstIkone);
  end {Ikona};

Procedure Ikona(x1,y1,x2,y2,text:integer;tekstikone:string); {Ikone}
  Begin
   SetColor(White);
   SetFillStyle(SolidFill,LightGray);
   Bar(x1,y1,x2,y2);
   SetColor(Black);
   SetLineStyle(0,0,1);
   Rectangle(x1-1,y1-2,x2+1,y2+1);
   SetColor(White);
   Line(x1,y1-1,x2,y1-1);
   Line(x1,y1,x1,y2-1);
   SetColor(DarkGray);
   Line(x1+1,y2,x2,y2);
   Line(x2,y2,x1,y2);
   SetTextStyle(0,0,0);
   SetColor(DarkGray);
   OutTextXY(x1+5,y1+4+text,TekstIkone);
   SetColor(White);
   OutTextXY(x1+3,y1+2+text,TekstIkone);
  end {Ikona};

Procedure BIkona(x1,y1,x2,y2,text:integer;tekstikone:string);  {Stisnuta Ikona}  Begin
   SetColor(White);
   SetFillStyle(SolidFill,LightGray);
   Bar(x1,y1,x2,y2);
   SetColor(Black);
   SetLineStyle(0,0,1);
   Rectangle(x1-1,y1-2,x2+1,y2+1);
   SetColor(Black);
   Line(x1,y1-1,x2,y1-1);
   Line(x1,y1,x1,y2-1);
   SetColor(DarkGray);
   Line(x1+1,y2,x2,y2);
   Line(x2,y2,x1,y2);
   SetTextStyle(0,0,0);
   SetColor(White);
   OutTextXY(x1+5,y1+4+text,TekstIkone);
   SetColor(DarkGray);
   OutTextXY(x1+3,y1+2+text,TekstIkone);
   Delay(300);
  end {Bikona};

Procedure TS(Var ad:Text; Pos:LongInt); {Seek for Text Files}
Type dW=Array[0..1] of Word;
Var ap:LongInt;
    ds: LongInt;
    Rg:Registers;
    erg:LongInt;
begin
     With Rg do
     begin
          ah:=$42;
          al:=1;
          bx:=TextRec(ad).Handle;
          cx:=dW(Pos)[1];
          dx:=dW(Pos)[0];
          MSDos(Rg);
          if Flags and fCarry<>0 then
          begin
               InOutRes:=ax;
               ds:=0
          end
          else ds:=rg.ax+rg.dx*65536;
     end;
     ap:=ds-TextRec(ad).Bufend+TextRec(ad).BufPos;
     if ap<>pos then With Textrec(ad) do
     begin
          if Mode=fmOutput then flush(ad);
          With Textrec(ad) do
          begin
               if (ap+(bufend-bufpos)<Pos) or (ap>Pos) then
               begin
                    bufpos:=0;
                    bufend:=0;
                    With Rg do
                    begin
                         ah:=$42;
                         al:=0;
                         bx:=TextRec(ad).Handle;
                         cx:=dW(pos)[1];
                         dx:=dW(pos)[0];
                         MSDos(Rg);
                         if Flags and fCarry<>0 then
                         begin
                              InOutRes:=ax;
                              ds:=0
                         end
                         else ds:=rg.ax+rg.dx*65536;
                    end;
               end
               else
               begin
                    inc(bufpos, pos-ap);
               end;
          end;
     end;
end;

PROCEDURE Make_Image_Temp_Files;
VAR ch: Char;
    k,KK,Per,Per1:LongInt;
    m,pos: Integer;
    st: String;
    d: TEXT;
    e,z,w: File Of Char;
    ok:Boolean;

BEGIN
     ikona(170,180,470,300,0,' ');
     Bikona(175,185,465,295,0,' ');
     ikona(180,190,460,290,0,' ');
     SetColor(8);
     OutTextXY(258,198,'Reading Image');
     SetColor(15);
     OutTextXY(256,196,'Reading Image');
     Ikona(210,235,430,265,0,' ');
     Bikona(215,240,425,260,0,' ');
     Assign(d,'IMAGE.AID');
     Reset(d);
     TS(d,84);
     st:='';
     FOR kk:=1 TO 7 DO
     BEGIN
          Read(d, Ch);
          st:=st+ch;
     END;
     IF (st='AISD/3 ') THEN OK:=True;
     IF ok THEN
     BEGIN
          Readln(d,k);
          Assign(e,'IMAGE2.TMP');
          REWRITE(e);
          FOR kk:=1 TO k DO
          BEGIN
               Read(d,ch);
               Write(e,ch);
          END;
          Readln(d);
          Close(e);
     END;
     ok:=False;
     st:='';
     FOR kk:=1 TO 7 DO
     BEGIN
          Read(d,ch);
          st:=st+ch;
     END;
     IF (st='AIDD/3 ') THEN ok:=True;
     IF ok THEN
     BEGIN
          Readln(d,k);
          ASSIGN(w,'IMAGE3.TMP');
          REWRITE(w);
          FOR kk:=1 TO k DO
          BEGIN
               Read(d,ch);
               Write(w,ch);
          END;
          Readln(d);
          Close(w);
     END;
     ok:=False;
     st:='';
     FOR kk:=1 TO 6 DO
     BEGIN
          Read(d,ch);
          st:=st+ch;
     END;
     IF (st='AID/3 ') THEN ok:=True;
     IF ok THEN
     BEGIN
          Readln(d,k);
          per:=k DIV 100;
          per1:=Per;
          m:=0;
          pos:=0;
          ASSIGN(z,'IMAGE1.TMP');
          REWRITE(z);
          FOR kk:=1 TO k DO
          BEGIN
               Read(d,ch);
               Write(z,ch);
               IF kk=per THEN
               BEGIN
                    m:=m+2;
                    { ******* Bar for reading image *********}
                    CIkona(220,245,220+m,255,0,' ');
                    Per:=Per+Per1;
                    pos:=pos+1;
                    Str(pos,st);
                    st:=st+' %';
                    SetFillStyle(1,7);
                    Bar(307,211,340,229);
                    SetColor(8);
                    OutTextXY(310,220,st);
                    SetColor(15);
                    OutTextXY(308,218,st);
               END;
          END;
          Close(z);
     END;
     Close(d);
     ClearDevice;
END;

PROCEDURE Show_Pic(X,Y : Integer);  {This shows image}
VAR k: Integer;
BEGIN
     Assign(F,'IMAGE1.TMP');
     reset(F,1);
     Assign(g, 'IMAGE2.TMP');
     Reset(g);
     ASSIGN(h,'IMAGE3.TMP');
     Reset(h);

     Read(g,Size);
     GetMem(P,Size);
     BlockRead(F,P^,Size,Result);
     PutImage(X,Y,P^,NormalPut);
     FreeMem(P,Size);

     Read(h,k);
     Read(g,Size);
     GetMem(P,Size);
     BlockRead(F,P^,Size,Result);
     PutImage(x,y+k,P^,NormalPut);
     FreeMem(P,Size);

     Read(g,Size);
     GetMem(P,Size);
     BlockRead(F,P^,Size,Result);
     PutImage(x,y+(k*2),P^,NormalPut);
     FreeMem(P,Size);
     Rewrite(f);
     close(F);
     Erase(f);
     Rewrite(g);
     Close(g);
     Erase(g);
END;

BEGIN
     ClrScr;
     Gd:=Detect;
     InitGraph(Gd, Gm, '\turbo\tp\'); { CHANGE THIS !! }
     if GraphResult <> grOk then Halt(1);
     IF Gd<>9 THEN
     BEGIN
          SetColor(White);
          OutTextXY(10, GetMaxY DIV 2, 'Sorry but this was tested only on VGA');
          OutTextXY(10, (GetMaxY DIV 2)+10, 'It will probably work on other card,');
          OutTextXY(10, (GetMaxY DIV 2)+20, 'but all graphics here are for 640x480x16');
          OutTextXY(10, (GetMaxY DIV 2)+40, 'All you have to do is to remove this lines');
          OutTextXY(10, (GetMaxY DIV 2)+50, 'and try. Probably you need to change something');
          OutTextXY(10, (GetMaxY DIV 2)+10, 'like colors, constants and so on ...');
          Delay(10000);
          CloseGraph;
          Halt(1);
     END;
     Make_Image_Temp_Files;
     Show_Pic(0,0);
     REPEAT UNTIL Keypressed;
END.

