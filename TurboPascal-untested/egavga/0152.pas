{
> I wrote a procedure that read a string input from the keyboard and
> returns an integer value. But how can I limit the length of the string
> to be inputed? And can any one please provide a source code that does
> the same thing in graphic mode? Thanx in advance.

   This is old Code, Written originally for a Hercules card, but with a
 little twiddling it should work just fine.  Improvements I can think
 of, Making the cursor blink, Making the cursor the correct size...

    Anyway, here goes.   Hang on this is pretty long!
}

{****************************************************************************}
{                  Unit to Compute in a Very Pascal Way                      }
{****************************************************************************}
{                     Incredible Graphix Utilities                           }
{****************************************************************************}
{****************************************************************************}
{     Version : 3.0                                         JUL  1993        }
{****************************************************************************}
Unit Grfxutil ;
{****************************************************************************}
Interface
{****************************************************************************}
type
     commands = (NON,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,
        F17,F18,F19,F20,F21,F22,F23,F24,F25,F26,F27,F28,F29,F30,F31,F32,F33,
        F34,F35,F36,F37,F38,F39,F40,HOME,UP,PGUP,LFT,RGHT,END1,DWN,PGDN,INS,
        DEL,PRTSRN,ENT,TAB,SPACE,BKSPAC,ESC,SHTAB,CTRLLFT,CTRLRGHT,CTRLUP,
        CTRLDWN,CTRLHOME,CTRLEND1,CTRLPGUP,CTRLPGDN) ;
var
   Greypic     : pointer ;              { The Grey Picture                   }
   comm        : commands ;             { The Command from the keyboard      }
   NoEcho      : Boolean ;              { If Characters are echoed.          }
   Cwn         : String ;
{****************************************************************************}
Function Testbit(testin : longint ; position : byte) : boolean ;
Function SetBit(Testin : longint ; Position : byte) : longint ;
Procedure Report_Mouse_Position ;  { A Debuging and design tool }
Procedure Register_Graphics
             (videodriver,videomode : integer ; var videographicsmode : byte) ;
Procedure clrvp(l1,l2,l3,l4 : integer ) ;
Procedure SAP( P : byte ) ;
Procedure clrpage ;
procedure DblBox (X1,Y1,X2,Y2 : Integer) ;
Procedure Dblwindowbox(x1,y1,x2,y2 : integer ; boxheader : string) ;
Procedure WindowBox(x1,y1,x2,y2 : integer ; boxheader : string) ;
Function  Roll(faces : integer) : integer ;
Function  Getcommand(VAR ch : char) : commands ;



{ These are the ones you are interested in. }
 
Procedure Readxy (X,Y:integer; Var S : string ; L : integer) ;
Function  GetReal(X,Y : integer; am : real; w : integer) : real ;
Function  getInteger(X,Y,N,W : integer) : integer  ;
Procedure Greyoutxy(x,y : integer ; textstring : string) ;
Function YesNoDialog : boolean ;
{****************************************************************************}
implementation uses crt,dos,Graph,bgidriv,bgifont,mousutil;
{****************************************************************************}
Function TestBit ;
var
   maskbit : longint ;
begin
     case position of
     1   : maskbit := 1 ;
     2   : maskbit := 2 ;
     3   : maskbit := 4 ;
     4   : maskbit := 8 ;
     5   : maskbit := 16 ;
     6   : maskbit := 32 ;
     7   : maskbit := 64 ;
     8   : maskbit := 128 ;
     9   : maskbit := 256 ;
     10  : maskbit := 512 ;
     11  : maskbit := 1024 ;
     12  : maskbit := 2048 ;
     13  : maskbit := 4096 ;
     14  : maskbit := 8192 ;
     15  : maskbit := 16384 ;
     16  : maskbit := 32768 ;
     17  : maskbit := 65536 ;
     18  : maskbit := 131072 ;
     19  : maskbit := 262144 ;
     20  : maskbit := 524288 ;
     21  : maskbit := 1048576 ;
     22  : maskbit := 2097152 ;
     23  : maskbit := 4194304 ;
     24  : maskbit := 8388608 ;
     25  : maskbit := 16777216 ;
     26  : maskbit := 33554432 ;
     27  : maskbit := 67108864 ;
     28  : maskbit := 134217728 ;
     29  : maskbit := 268435456 ;
     30  : maskbit := 536870912 ;
     31  : maskbit := 1073741824 ;
     end ;
     if (testin and maskbit) = maskbit then testbit := true
     else testbit := false ;
end ;

{****************************************************************************}
{ This function sets the state of a bit in a variable as large as a longint.
You call it with the value of the variable and the position (counting from
right to left naturally).  If the bit is already set, then it will turn it
off, if it is off then it will turn it on. }
Function setBit ;
var
   maskbit : longint ;
begin
     case position of
     1   : maskbit := 1 ;
     2   : maskbit := 2 ;
     3   : maskbit := 4 ;
     4   : maskbit := 8 ;
     5   : maskbit := 16 ;
     6   : maskbit := 32 ;
     7   : maskbit := 64 ;
     8   : maskbit := 128 ;
     9   : maskbit := 256 ;
     10  : maskbit := 512 ;
     11  : maskbit := 1024 ;
     12  : maskbit := 2048 ;
     13  : maskbit := 4096 ;
     14  : maskbit := 8192 ;
     15  : maskbit := 16384 ;
     16  : maskbit := 32768 ;
     17  : maskbit := 65536 ;
     18  : maskbit := 131072 ;
     19  : maskbit := 262144 ;
     20  : maskbit := 524288 ;
     21  : maskbit := 1048576 ;
     22  : maskbit := 2097152 ;
     23  : maskbit := 4194304 ;
     24  : maskbit := 8388608 ;
     25  : maskbit := 16777216 ;
     26  : maskbit := 33554432 ;
     27  : maskbit := 67108864 ;
     28  : maskbit := 134217728 ;
     29  : maskbit := 268435456 ;
     30  : maskbit := 536870912 ;
     31  : maskbit := 1073741824 ;
     end ;
     setbit := testin xor maskbit ;
end ;

{****************************************************************************}

Procedure Report_Mouse_position ;
{ This is a debugging and Designing tool, it reports the X,Y position of the
mouse and shows free memory in the upper right corner of the screen. }
var
   msxstr,msystr : string[6] ;
   Memstr : string[10] ;

Begin
     str(memavail,memstr) ;
     str(getmousex,msxstr) ;
     str(getmouseY,msystr) ;
     msxstr := 'X: ' + msxstr ;
     msystr := 'Y: ' + msystr ;
     settextstyle(0,0,1) ;
     setfillstyle(solidfill,darkgray) ;
     bar(getmaxx-30,3,getmaxx-4,20) ;
     bar(530,5,580,15) ;
     setcolor(white) ;
     outtextxy(530,5,memstr);
     outtextxy(getmaxx-53,4,msxstr) ;
     outtextxy(getmaxx-53,13,msystr) ;
end ;
{****************************************************************************}
{ Loads and registers the graphics driver }
Procedure Register_Graphics
(videodriver,videomode : integer ; var videographicsmode : byte) ;
var
  GraphDriver, GraphMode, Error : integer;
  gotgrafix : boolean ;
  mode : byte ;
  regs : registers ;
{*************************************************}
procedure Abort(Msg : string);
begin
  Writeln(Msg, ': ', GraphErrorMsg(GraphResult));
  Halt(4);
end;
{*************************************************}
begin   { Register Graphix  }
     if RegisterBGIdriver(@EGAVGADriverProc) < 0 then Abort('EGA/VGA');
{     if RegisterBGIdriver(@HercDriverProc) < 0 then Abort('Herc');
     if RegisterBGIdriver(@ATTDriverProc) < 0 then Abort('AT&T');
     if RegisterBGIdriver(@PC3270DriverProc) < 0 then Abort('PC 3270');
}
                           { Register all the fonts }
{     if RegisterBGIfont(@GothicFontProc) < 0 then Abort('Gothic');
     if RegisterBGIfont(@SansSerifFontProc) < 0 then Abort('SansSerif');
     if RegisterBGIfont(@SmallFontProc) < 0 then Abort('Small');
     if RegisterBGIfont(@TriplexFontProc) < 0 then Abort('Triplex');
}     graphdriver := videodriver ;
     graphmode := videomode ;

     initgraph(graphdriver,graphmode,'') ;
     if GraphResult <> grOk then             { any errors? }
     begin
          Writeln('Graphics init error: ', GraphErrorMsg(GraphDriver));
          Halt(4);
     end;
End ; { Register Graphics }

{****************************************************************************}
{ Clears a viewport passed to it and resets the viewport }
{ instead of writing it so many times!! }
Procedure clrvp(l1,l2,l3,l4 : integer ) ;
var
   vp : viewporttype ;
begin
     getviewsettings(vp) ;
     setviewport(l1,l2,l3,l4,clipon) ;
     clearviewport ;
     setviewport(vp.x1,vp.y1,vp.x2,vp.y2,vp.clip) ; { Restore the viewport }
end ;
{****************************************************************************}
{ Sets Apage, activepage, visualpage }
Procedure SAP ;

begin   { SAP }
     setactivepage(p) ; setvisualpage(p) ;
end ;   { SAP }
{****************************************************************************}
{ Clears the current page number }
Procedure clrpage ;

begin   { Clrpage }
     clrvp(0,0,getmaxx,getmaxy) ;
end ;   { Clrpage }
{****************************************************************************}
{ Puts down a double Lined Box }
procedure DblBox ;

begin   { DblBox }
     line(x1,y1,x2,y1) ; line(x1 + 2,y1 + 2,x2 - 2,y1 + 2) ;
     line(x1,y2,x2,y2) ; line(x1 + 2,y2 - 2,x2 - 2,y2 - 2) ;
     line(x1,y1,x1,y2) ; line(x1 + 3,y1 + 3,x1 + 3,y2 - 3) ;
     line(x2,y1,x2,y2) ; line(x2 - 3,y1 + 3,x2 - 3, y2 - 3) ;
end ;   { DblBox }
{****************************************************************************}
{ Creates a double lined box with an optional header }
Procedure Dblwindowbox(x1,y1,x2,y2 : integer ; boxheader : string) ;
var
   oldstyle : textsettingstype ;
begin
     line(x1,y1,x2,y1) ;
     if length(boxheader) = 0 then line(x1 + 2,y1 + 2,x2 - 2,y1 + 2)
     else line(x1,y1 + textheight('H') + 2,x2,y1 + textheight('H') + 2) ;
     line(x1,y2,x2,y2) ;
     line(x1 + 2,y2 - 2,x2 - 2,y2 - 2) ;
     line(x1,y1,x1,y2) ;
     line(x1 + 2,y1 + 2,x1 + 2,y2 - 2) ;
     line(x2,y1,x2,y2) ;
     line(x2 - 2,y1 + 2,x2 - 2, y2 - 2) ;
     line(x1+2,y1,x1+2,y1+10) ;
     line(x2-2,y1,x2-2,y1+10) ;
     if length(boxheader) >0 then
     begin
          gettextsettings(oldstyle);
          settextjustify(1,0) ;
          outtextxy(x1+ ((x2-x1) div 2),y1+ textheight('H') + 2,boxheader) ;
          with oldstyle do
          begin
               settextjustify(horiz,vert) ;
               settextstyle(font,direction,charsize) ;
          end ;
     end ;
end ;
{****************************************************************************}
{ Creates a Single lined box with an optional header }
Procedure windowbox(x1,y1,x2,y2 : integer ; boxheader : string) ;
var
   oldstyle : textsettingstype ;
begin
     line(x1,y1,x2,y1) ;
     if length(boxheader) > 0 then
      line(x1,y1 + textheight('H') + 2,x2,y1 + textheight('H') + 2) ;
     line(x1,y2,x2,y2) ;
     line(x1,y1,x1,y2) ;
     line(x2,y1,x2,y2) ;
     if length(boxheader) >0 then
     begin
          gettextsettings(oldstyle);
          settextjustify(1,0) ;
          outtextxy(x1+((x2-x1) div 2),y1+textheight('H') + 1,boxheader) ;
          with oldstyle do
          begin
               settextjustify(horiz,vert) ;
               settextstyle(font,direction,charsize) ;
          end ;
     end ;
end ;

{****************************************************************************}
{ An Any sided Die }
Function Roll(faces : integer) : integer ;
begin
     roll := random(faces) + 1 ;
end ;
{****************************************************************************}
{ Returns A Commandkey From A Keypress or a Character }
{ The Function will return a command and it will  record the key in
the variable parameter.  So you can use it to find any key pressed on
the keyboard.}
Function  Getcommand(VAR ch : char) : commands ;
Var
     C : Commands ;
     funckey : boolean ;
     newcommand : boolean ;

Begin  { Get Command }
     newcommand := false ;
     C := NON ;
     if keypressed then
     begin
          newcommand := true ;
          Ch := Readkey ;
     end ;
     if newcommand then
     begin  { get the command }
     If Ch <> #0 Then Funckey := False
     Else
     Begin
          Funckey := True ;
          Ch := Readkey ;
     End ;
     If Funckey Then
     Case Ch Of
 { The Normal Function Keys }
     #59 : C := F1 ;        {F1}
     #60 : C := F2 ;        {F2}
     #61 : C := F3 ;        {F3}
     #62 : C := F4 ;        {F4}
     #63 : C := F5 ;        {F5}
     #64 : C := F6 ;        {F6}
     #65 : C := F7 ;        {F7}
     #66 : C := F8 ;        {F8}
     #67 : C := F9 ;        {F9}
     #68 : C := F10 ;       {F10}
   { Shifted Function Keys }
     #133,#84 : C := F11 ;  {F11}
     #134,#85 : C := F12 ;  {F12}
     #86 : C := F13 ;       {F13}
     #87 : C := F14 ;       {F14}
     #88 : C := F15 ;       {F15}
     #89 : C := F16 ;       {F16}
     #90 : C := F17 ;       {F17}
     #91 : C := F18 ;       {F18}
     #92 : C := F19 ;       {F19}
     #93 : C := F20 ;       {F20}
   { Cntl Function Keys }
     #94 : C := F21 ;       {F21}
     #95 : C := F22 ;       {F22}
     #96 : C := F23 ;       {F23}
     #97 : C := F24 ;       {F24}
     #98 : C := F25 ;       {F25}
     #99 : C := F26 ;       {F26}
     #100 : C := F27 ;      {F27}
     #101 : C := F28 ;      {F28}
     #102 : C := F29 ;      {F29}
     #103 : C := F30 ;      {F30}

   { Alt Function Keys }
     #104 : C := F31 ;      {F31}
     #105 : C := F32 ;      {F32}
     #106 : C := F33 ;      {F33}
     #107 : C := F34 ;      {F34}
     #108 : C := F35 ;      {F35}
     #109 : C := F36 ;      {F36}
     #110 : C := F37 ;      {F37}
     #111 : C := F38 ;      {F38}
     #112 : C := F39 ;      {F39}
     #113 : C := F40 ;      {F40}
         { The Keypad }
     #71 : C := HOME;   {HOME}
     #72 : C := UP ;   {UP}
     #73 : C := PGUP ;   {PGUP}
     #75 : C := LFT ;   {LEFT}
     #77 : C := RGHT ;   {RIGHT}
     #79 : C := END1 ;   {END}
     #80 : C := DWN ;   {DOWN}
     #81 : C := PGDN ;   {PGDN}
     #82 : C := INS ;   {INS}
     #83 : C := DEL ;   {DEL}
     #114 : C := PRTSRN ; { Cntl - PrtSc }
     #15 : C := SHTAB ;  { Shft Tab }
     End  { Case }
     else    { Not a function Key }
     case ch of
     #13 : C := ENT ;    { Return }
     #27 : C := ESC ;    { Escape }
     #32 : C := SPACE ;  { Space Bar }
     #9  : C := TAB ;    { Tab }
     #8  : C := BKSPAC ; { Back Space }
     end ;   { Case }
     end ;
     Getcommand := C ;
End ;  {Getcommand}
{****************************************************************************}
Procedure readxy ;

Var
     Ch : Char ;
     Done,Nomore,Inson,Funckey,curson : Boolean ;
     Curp,Cx,Cy,Sx,Sy,StrCnt,I,x1,x2,y1,y2 : Integer ;
     Outstr : string ;
     cmmd : commands ;
     Spac : integer ;
{*******************************************}
{ Place the Cursor and update the cursor on flag }
{ With I we can force the cursor on or off or let it operate automaticly
if I = 0 then turn the cursor off, if 1 then automatic, if 2 then on. }
Procedure PpCur(I : integer) ;
var
   udc : boolean ;
begin   { ppcur }
     udc := false ;
     if (cx >= x1) and (cx < x2) then udc := true ;
     if udc then
     begin
          case I of
          0 : setcolor(black) ;
          1 : if curson then setcolor(black) else setcolor(white) ;
          2 : setcolor(white) ;
          end ;
          if inson then setlinestyle(0,$FFFF,3) else setlinestyle(0,$FFFF,1) ;
          line(cx,cy+textheight('H')+1,cx+textwidth('X'),cy+textheight('H')+1)
;          curson := not(curson) ;
          if I = 2 then curson := true ;
          if I = 0 then curson := false ;
     end ;
     setcolor(white) ;
end ;   { ppcur }

{*******************************************}
{ Go to the end of the line, wherever it may be... }
Procedure Goend ;
Begin
     ppcur(0) ; { Erase the old cursor }
     Cx := Sx + Length(S) * Spac ;
     Strcnt := Length(S) + 1 ;
     ppcur(2) ; { Place the new cursor }
End ;


{*******************************************}
Begin   { Readpgrf }
     curson := false ; Strcnt := 1 ; Inson := False ;
     Outstr := '' ; Nomore := False ;
     spac := textwidth('X') ;
     Sx := X ;
     Sy := Y ;
     Cx := Sx ;
     Cy := Sy ;    { Set the Current x & y }

     y2 := y + spac ;
     x1 := x ;
     x2 := x1 + L * spac ;
     y1 := y ;
     moveto(x,y) ;
     outtext(S) ;
     ppcur(2) ;
     Done := False ; While Not Done Do
     Begin
          ch := chr(1) ; { Clears the char }
          cmmd := getcommand(ch) ;
          if (cmmd <> NON) and (cmmd <> SPACE) then
          Case CMMD Of
          HOME : Begin   {HOME}
                      Strcnt := 1 ;
                      ppcur(1) ;
                      Cx := Sx ;
                      Cy := Sy ;
                      ppcur(2) ;
                 End ;
          LFT  : Begin   { Left }
                      If Cx >= X1 + Spac Then
                      Begin
                           if cx <= x2 - spac then ppcur(1) ;
                           Cx := Cx - Spac ;
                           ppcur(2) ;
                           Dec(Strcnt) ;
                           If Strcnt < 1 Then Strcnt := 1 ;
                      End ;
                 End ;  { UP }
          RGHT : Begin   { Right }
                      If Cx < X2 - Spac Then
                      Begin
                           ppcur(1) ;
                           Cx := Cx + Spac ;
                           ppcur(1) ;
                           If Strcnt = Length(S) + 1 Then
                           Begin
                                Insert(' ',S,Strcnt) ;
                                outtextxy(Cx,Cy,' ') ;
                                Inc(Strcnt) ;
                           End
                           Else Inc(Strcnt) ;
                      end ;
                 End ;   {RIGHT}
          END1 : Goend ;
          INS  : Begin   { INS }

                      If Inson = False Then
                      begin
                      If Integer(Length(S) * Spac)
                       < Integer(X2 - X1 - Spac) Then Inson := True ;
                      end else
                      begin
                           ppcur(0) ;
                           Inson := False ;
                      end ;
                      ppcur(2) ;
                 End ;   { INS }
          DEL  : If Strcnt < Length(S) + 1 Then
                 Begin
                      Delete(S,Strcnt,1) ;
                      Moveto(Cx,Cy) ;
                      For I := Strcnt To Length(S) Do
                       if noecho then Outstr := outstr + '.'
                        else outstr := Outstr + S[I] ;
                      clrvp(Cx,Cy,X2,Y2) ;
                      Outtextxy(cx,cy,Outstr) ;
                      Outstr := '' ;
                      ppcur(2) ;
                 End ;
          BKSPAC : If Strcnt > 1 Then
                 Begin
                      If Cx <= X2 - Spac Then
                      ppcur(0) ;
                      dec(Cx,Spac) ;   { Right - Normal   }
                      If Cx < 0 Then Cx := 0 ;
                      Nomore := False ;
                      Dec(Strcnt) ;
                      If Strcnt < Length(S) Then
                      Begin
                           Moveto(Cx,Cy) ;
                           Delete(S,Strcnt,1) ;
                           For I := Strcnt To Length(S) Do
                            if noecho then Outstr := outstr + '.'
                            else Outstr := Outstr + S[I] ;
                           clrvp(Cx,cy,x2,y2) ;
                           Outtextxy(cx,cy,Outstr) ;
                           Outstr := '' ;
                           ppcur(2) ;
                      End
                      Else
                      Begin
                           ppcur(0) ;
                           If Length(S) <= 1 Then
                            S:= '' Else Delete(S,Strcnt,1) ;
                            clrvp(cx,cy,x2,y2) ;
                            ppcur(2) ;
                      End ;
                 End ;
          ESC :  Begin  { ESC }
                      ppcur(1) ;
                      S := '' ;
                      clrvp(X1,Y1,X2,Y2) ;
                      Cx := Sx ; Cy := Sy ;
                      ppcur(1) ;
                      nomore := false ;
                      Strcnt := 1 ;
                 End ;
          ENT   : Done := True ;      { Return }
          end  { Case cmmd }
          Else   { Not a command But A Key }
          case ch of
          ' '..'~':     Begin
                         If Integer(Length(S) * Spac) >
                               (x2 - X1 - Spac) Then Nomore := True ;
                         If (Inson = False)
                                  And
                            (Strcnt < Length(S) + 1)
                            Then Nomore := False ;
                         If Not Nomore Then
                         Begin { Not Nomore }
                              ppcur(1) ;
                              If Inson Then
                              Begin  { Inson }
                                   Insert(Ch,S,Strcnt) ;
                                   If Strcnt < Length(S) Then
                                   Begin  { < Length }
                                   clrvp(Cx,Cy,X2,Y2) ;
                                        Moveto(Cx,Cy) ;
                                        For I := Strcnt To Length(S) Do
                                         if noecho then Outstr := outstr + '.'
                                         else Outstr := Outstr + S[I] ;
                                        Outtext(Outstr) ;
                                        Outstr := '' ;
                                        Inc(Strcnt) ;
                                   End  { < Length }
                                   Else
                                   Begin  { = Length }
                                        if noecho then outtextxy(cx,cy,'.')
                                        else outtextxy(Cx,Cy,ch) ;
                                        curson := false ;
                                        Inc(Strcnt) ;
                                   End ;  { = Length }
                              End { Inson }
                              Else
                              Begin  { Ins Off }
                                   Delete(S,Strcnt,1) ;
                                   Insert(Ch,S,Strcnt) ;
                                   Inc(Strcnt) ;

clrvp(cx,cy,cx+textwidth(ch),cy+textheight(ch)) ;
if noecho then outtextxy(cx,cy,'.')                                   else
outtextxy(Cx,Cy,ch) ;                                   if strcnt <= length(s)
then                                       begin
                                            ch := s[strcnt] ;
                                            if noecho then outtextxy(cx,cy,'.')
                                            else outtextxy(Cx + spac,Cy,ch) ;
                                       end ;
                                   curson := false ;
                              End ;  { Ins Off }
                              Cx := Cx + Spac ;
                              If Cx <= X2 - Spac Then ppcur(2) ;
                         End    { Not Nomore }
                    End ;   { Real Chars }
          End ; { Case }
     End ;    { Not Done  }
     S[0] := chr(length(s)) ;
     if curson then ppcur(0) ;
End ;  {readxy}
{****************************************************************************}
{ Get an Amount of Type Real from a Location }
Function Getreal ;
var
   istr : string ;
   cod : integer ;
begin   { get Amount }
     str(am:1:2,istr) ;
     repeat
          readxy(x,y,istr,w) ; val(istr,am,cod) ;
     until cod = 0 ;
     getreal := am ;
end ;   { get Amount }
{****************************************************************************}
{ Get an Amount of type integer from a location x,y  }
Function getinteger  ;
var
   istr : string ;
   cod : integer ;
begin   { Getinteger }
     str(n,istr) ;
     repeat
          readxy(X,y,istr,w) ; val(istr,n,cod) ;
     until cod = 0 ;
     getinteger := n ;
end ;   { Getinteger }
{****************************************************************************}
{ Outputs using Outtextxy then GREY's out the text }
Procedure Greyoutxy(x,y : integer ; textstring : string) ;
var
   size,I : integer ;

begin
     size := textwidth(textstring) div length(textstring) ;
     outtextxy(x,y,textstring) ;
     for I := 0 to length(textstring)-1 do
        putimage(x + size*I,y,greypic^,andput) ;  { Greyout }
end;
{****************************************************************************}
Function YesNoDialog : boolean ;
const
     boxx = 150 ;
     Boxy = 150 ;
Var
   menudone,Yesno : Boolean ;
   oldstyle : textsettingstype ;
   boxheight,boxwidth,oldcolor,numpressed : word ;
   msx,msy : word ;
   Imagebuffer : pointer ;
   Size : word ;

begin  { YesNo Dialog }
     Yesno := false ;
     menudone := false ;
     hidemousecursor ;
     { Save what is under the window before opening it. Also save
        the old textstyle }
     gettextsettings(oldstyle) ;
     oldcolor := getcolor ;
     settextstyle(0,0,1) ;
     boxheight := textheight('H') * 3 ;
     Boxwidth := textwidth('H') * 15;
     size := imagesize(boxx,boxy,boxx + boxwidth,boxy + boxheight) ;
     getmem(imagebuffer,size) ;
     getimage(boxx,boxy,boxx + boxwidth,boxy + boxheight,imagebuffer^) ;

     { Now we put the image of the menu down. }
     setfillstyle(1,lightgray) ;
     bar(boxx+3,boxy+3,boxx + boxwidth-3,boxy + boxheight-3) ;
     setcolor(green) ;
     dblbox(boxx,boxy,boxx + boxwidth,boxy + boxheight) ;
     setcolor(brown) ;
     outtextxy(boxx+8,boxy+textheight('H'),' Yes  |  No') ;
     setcolor(oldcolor) ;
     showmousecursor ;
     repeat
          if (getmousex <> msx) or (getmousey <> msy) then
          begin
               msx := getmousex ;
               msy := getmousey ;
          end ;
          if buttonpressed then
          { where was the button pressed?}
          begin
               msx := getmousex ;
               msy := getmousey ;
               if ((msx > boxx+4) and (msx < boxx+boxwidth))
                  and
                  ((msy > boxy) and (msy < boxy+boxheight)) then
                  { it's in the menu box }
               begin
                    { where in the menu Box? }
                    if (msx > boxx) and (msx < boxx+ (boxwidth div 2))
                    then yesno := true ;
                    menudone := true ;
               end ;
          end ;
     until menudone ;
     { when we are done we want to restore all the old settings. }
     with oldstyle do
     begin
          settextjustify(horiz,vert) ;
          settextstyle(font,direction,charsize) ;
     end ;
     { and put the screen back to what it was.. }
     hidemousecursor ;
     putimage(boxx,boxy,imagebuffer^,normalput) ;
     freemem(imagebuffer,size) ;
     showmousecursor ;
     setcolor(oldcolor) ;
     yesnodialog := yesno ;
end;
{****************************************************************************}
End.   { End of grfxutil }
{
    The routines you might be interested in are in the later half of
 that unit In the previous posts.  It provided a fully editable
 Graphical Data Entry (either string, real, or integer) line.  It
 supports the arrow keys, Home, end, backspace, del, insert, and escape
 clears the whole line.  Enter accepts the input.  You can specify how
 many characters wide the input field should be, and the numerical input
 routines, Getreal, and getinteger do some primitive checking to make
 sure that input is correct.  Also, (it's been a long time since I've
 used this so bear with my bad memory) I believe you call them with the
 value of an already initialized variable so that if the user just hits
 enter it doesn't change the value.  I've used it in conjunction with a
 mouse pointer and since the readxy routine is command driven (using the
 getcommand supplied in there too,) you can issue it an enter with the
 mouse buttons.  So you can click around in various fields with your
 mouse.  Of course you have to make that routine yourself!

    Oh!  I should tell you, delete the refferences to mouseutil and the
 single mouse function, sorry, I shouldn't have included that one with
 it.. You might not have mousutil!
}
