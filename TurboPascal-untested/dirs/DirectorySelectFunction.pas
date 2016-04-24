(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0029.PAS
  Description: Directory Select Function
  Author: SWAG SUPPORT TEAM
  Date: 02-22-94  11:40
*)

Program DIRSEL;
Uses
   Crt,Dos;  { ** needed for DIRSELECT functions ** }

{ ** The following Type & Var declarations are for the main program only  ** }
{ ** However, the string length of the returned parameter from DIRSELECT  ** }
{ ** must be a least 12 characters.                                       ** }

Type
   strtype = String[12];
Var
   spec,fname : strtype;

{ ************************************************************************** }
{ ** List of Procedures/Functions needed for DIRSELECT                    ** }
{ ** Procedure CURSOR     - turns cursor on or off                        ** }
{ ** Procedure FRAME      - draws single or double frame                  ** }
{ ** Function ISCOLOR     - returns the current video mode                ** }
{ ** Procedure SAVESCR    - saves current video screen                    ** }
{ ** Procedure RESTORESCR - restores old video screen                     ** }
{ ** Procedure SCRGET     - get character/attribute                       ** }
{ ** Procedure SCRPUT     - put character/attribute                       ** }
{ ** Procedure FNAMEPOS   - finds proper screen position                  ** }
{ ** Procedure HILITE     - highlights proper name                        ** }
{ ** Function DIRSELECT   - directory selector                            ** }
{ ************************************************************************** }

Procedure CURSOR( attrib : Boolean );
Var
   regs : Registers;
Begin
   If NOT attrib Then { turn cursor off }
   Begin
      regs.ah := 1;
      regs.cl := 7;
      regs.ch := 32;
      Intr($10,regs)
   End
   Else { turn cursor on }
   Begin
      Intr($11,regs);
      regs.cx := $0607;
      If regs.al AND $10 <> 0 Then regs.cx := $0B0C;
      regs.ah := 1;
      Intr($10,regs)
   End
End;

Procedure FRAME(t,l,b,r,ftype : Integer);
Var
   i : Integer;
Begin
   GoToXY(l,t);
   If ftype = 2 Then
      Write(Chr(201))
   Else
      Write(Chr(218));
   GoToXY(r,t);
   If ftype = 2 Then
      Write(Chr(187))
   Else
      Write(Chr(191));
   GoToXY(l+1,t);
   For i := 1 To (r - (l + 1)) Do
      If ftype = 2 Then
         Write(Chr(205))
      Else
         Write(Chr(196));
   GoToXY(l+1,b);
   For i := 1 To (r - (l + 1)) Do
      If ftype = 2 Then
         Write(Chr(205))
      Else
         Write(Chr(196));
   GoToXY(l,b);
   If ftype = 2 Then
      Write(Chr(200))
   Else
      Write(Chr(192));
   GoToXY(r,b);
   If ftype = 2 Then
      Write(Chr(188))
   Else
      Write(Chr(217));
   For i := (t+1) To (b-1) Do
   Begin
      GoToXY(l,i);
      If ftype = 2 Then
         Write(Chr(186))
      Else
         Write(Chr(179))
   End;
   For i := (t+1) To (b-1) Do
   Begin
      GoToXY(r,i);
      If ftype = 2 Then
         Write(Chr(186))
      Else
         Write(Chr(179))
   End
End;

Function ISCOLOR : Boolean;  { returns FALSE for MONO or TRUE for COLOR }
Var
   regs       : Registers;
   video_mode : Integer;
   equ_lo     : Byte;
Begin
   Intr($11,regs);
   video_mode := regs.al and $30;
   video_mode := video_mode shr 4;
   Case video_mode of
      1 : ISCOLOR := FALSE;  { Monochrome }
      2 : ISCOLOR := TRUE    { Color }
   End
End;

Procedure SAVESCR( Var screen );
Var
   vidc : Byte Absolute $B800:0000;
   vidm : Byte Absolute $B000:0000;
Begin
   If NOT ISCOLOR Then  { if MONO }
      Move(vidm,screen,4000)
   Else                 { else COLOR }
      Move(vidc,screen,4000)
End;

Procedure RESTORESCR( Var screen );
Var
   vidc : Byte Absolute $B800:0000;
   vidm : Byte Absolute $B000:0000;
Begin
   If NOT ISCOLOR Then  { if MONO }
      Move(screen,vidm,4000)
   Else                 { else COLOR }
      Move(screen,vidc,4000)
End;

Procedure SCRGET( Var ch,attr : Byte );
Var
   regs : Registers;
Begin
   regs.bh := 0;
   regs.ah := 8;
   Intr($10,regs);
   ch := regs.al;
   attr := regs.ah
End;

Procedure SCRPUT( ch,attr : Byte );
Var
   regs : Registers;
Begin
   regs.al := ch;
   regs.bl := attr;
   regs.ch := 0;
   regs.cl := 1;
   regs.bh := 0;
   regs.ah := 9;
   Intr($10,regs);
End;

Procedure FNAMEPOS(Var arypos,x,y : Integer);
{ determine position on screen of filename }
Const
   FPOS1 =  2;
   FPOS2 = 15;
   FPOS3 = 28;
   FPOS4 = 41;
   FPOS5 = 54;
   FPOS6 = 67;
Begin
   Case arypos of
        1: Begin x := FPOS1; y :=  2 End;
        2: Begin x := FPOS2; y :=  2 End;
        3: Begin x := FPOS3; y :=  2 End;
        4: Begin x := FPOS4; y :=  2 End;
        5: Begin x := FPOS5; y :=  2 End;
        6: Begin x := FPOS6; y :=  2 End;
        7: Begin x := FPOS1; y :=  3 End;
        8: Begin x := FPOS2; y :=  3 End;
        9: Begin x := FPOS3; y :=  3 End;
       10: Begin x := FPOS4; y :=  3 End;
       11: Begin x := FPOS5; y :=  3 End;
       12: Begin x := FPOS6; y :=  3 End;
       13: Begin x := FPOS1; y :=  4 End;
       14: Begin x := FPOS2; y :=  4 End;
       15: Begin x := FPOS3; y :=  4 End;
       16: Begin x := FPOS4; y :=  4 End;
       17: Begin x := FPOS5; y :=  4 End;
       18: Begin x := FPOS6; y :=  4 End;
       19: Begin x := FPOS1; y :=  5 End;
       20: Begin x := FPOS2; y :=  5 End;
       21: Begin x := FPOS3; y :=  5 End;
       22: Begin x := FPOS4; y :=  5 End;
       23: Begin x := FPOS5; y :=  5 End;
       24: Begin x := FPOS6; y :=  5 End;
       25: Begin x := FPOS1; y :=  6 End;
       26: Begin x := FPOS2; y :=  6 End;
       27: Begin x := FPOS3; y :=  6 End;
       28: Begin x := FPOS4; y :=  6 End;
       29: Begin x := FPOS5; y :=  6 End;
       30: Begin x := FPOS6; y :=  6 End;
       31: Begin x := FPOS1; y :=  7 End;
       32: Begin x := FPOS2; y :=  7 End;
       33: Begin x := FPOS3; y :=  7 End;
       34: Begin x := FPOS4; y :=  7 End;
       35: Begin x := FPOS5; y :=  7 End;
       36: Begin x := FPOS6; y :=  7 End;
       37: Begin x := FPOS1; y :=  8 End;
       38: Begin x := FPOS2; y :=  8 End;
       39: Begin x := FPOS3; y :=  8 End;
       40: Begin x := FPOS4; y :=  8 End;
       41: Begin x := FPOS5; y :=  8 End;
       42: Begin x := FPOS6; y :=  8 End;
       43: Begin x := FPOS1; y :=  9 End;
       44: Begin x := FPOS2; y :=  9 End;
       45: Begin x := FPOS3; y :=  9 End;
       46: Begin x := FPOS4; y :=  9 End;
       47: Begin x := FPOS5; y :=  9 End;
       48: Begin x := FPOS6; y :=  9 End;
       49: Begin x := FPOS1; y := 10 End;
       50: Begin x := FPOS2; y := 10 End;
       51: Begin x := FPOS3; y := 10 End;
       52: Begin x := FPOS4; y := 10 End;
       53: Begin x := FPOS5; y := 10 End;
       54: Begin x := FPOS6; y := 10 End;
       55: Begin x := FPOS1; y := 11 End;
       56: Begin x := FPOS2; y := 11 End;
       57: Begin x := FPOS3; y := 11 End;
       58: Begin x := FPOS4; y := 11 End;
       59: Begin x := FPOS5; y := 11 End;
       60: Begin x := FPOS6; y := 11 End;
       61: Begin x := FPOS1; y := 12 End;
       62: Begin x := FPOS2; y := 12 End;
       63: Begin x := FPOS3; y := 12 End;
       64: Begin x := FPOS4; y := 12 End;
       65: Begin x := FPOS5; y := 12 End;
       66: Begin x := FPOS6; y := 12 End;
       67: Begin x := FPOS1; y := 13 End;
       68: Begin x := FPOS2; y := 13 End;
       69: Begin x := FPOS3; y := 13 End;
       70: Begin x := FPOS4; y := 13 End;
       71: Begin x := FPOS5; y := 13 End;
       72: Begin x := FPOS6; y := 13 End;
       73: Begin x := FPOS1; y := 14 End;
       74: Begin x := FPOS2; y := 14 End;
       75: Begin x := FPOS3; y := 14 End;
       76: Begin x := FPOS4; y := 14 End;
       77: Begin x := FPOS5; y := 14 End;
       78: Begin x := FPOS6; y := 14 End;
       79: Begin x := FPOS1; y := 15 End;
       80: Begin x := FPOS2; y := 15 End;
       81: Begin x := FPOS3; y := 15 End;
       82: Begin x := FPOS4; y := 15 End;
       83: Begin x := FPOS5; y := 15 End;
       84: Begin x := FPOS6; y := 15 End;
       85: Begin x := FPOS1; y := 16 End;
       86: Begin x := FPOS2; y := 16 End;
       87: Begin x := FPOS3; y := 16 End;
       88: Begin x := FPOS4; y := 16 End;
       89: Begin x := FPOS5; y := 16 End;
       90: Begin x := FPOS6; y := 16 End;
       91: Begin x := FPOS1; y := 17 End;
       92: Begin x := FPOS2; y := 17 End;
       93: Begin x := FPOS3; y := 17 End;
       94: Begin x := FPOS4; y := 17 End;
       95: Begin x := FPOS5; y := 17 End;
       96: Begin x := FPOS6; y := 17 End;
       97: Begin x := FPOS1; y := 18 End;
       98: Begin x := FPOS2; y := 18 End;
       99: Begin x := FPOS3; y := 18 End;
      100: Begin x := FPOS4; y := 18 End;
      101: Begin x := FPOS5; y := 18 End;
      102: Begin x := FPOS6; y := 18 End;
      103: Begin x := FPOS1; y := 19 End;
      104: Begin x := FPOS2; y := 19 End;
      105: Begin x := FPOS3; y := 19 End;
      106: Begin x := FPOS4; y := 19 End;
      107: Begin x := FPOS5; y := 19 End;
      108: Begin x := FPOS6; y := 19 End;
      109: Begin x := FPOS1; y := 20 End;
      110: Begin x := FPOS2; y := 20 End;
      111: Begin x := FPOS3; y := 20 End;
      112: Begin x := FPOS4; y := 20 End;
      113: Begin x := FPOS5; y := 20 End;
      114: Begin x := FPOS6; y := 20 End;
      115: Begin x := FPOS1; y := 21 End;
      116: Begin x := FPOS2; y := 21 End;
      117: Begin x := FPOS3; y := 21 End;
      118: Begin x := FPOS4; y := 21 End;
      119: Begin x := FPOS5; y := 21 End;
      120: Begin x := FPOS6; y := 21 End
      Else
      Begin
         x := 0;
         y := 0;
      End
   End
End;

Procedure HILITE(old,new : Integer);  { highlight a filename on the screen }
Var
   i,oldx,oldy,newx,newy : Integer;
   ccolor,locolor,hicolor,cchar : Byte;
Begin
   FNAMEPOS(old,oldx,oldy); { get position in the array of the filename }
   FNAMEPOS(new,newx,newy); { get position in the array of the filename }
   For i := 0 To 11 Do
   Begin
      If old < 121 Then  { if valid position, reverse video, old selection }
      Begin
         GoToXY((oldx + i),oldy);
         SCRGET(cchar,ccolor);
         locolor := ccolor AND $0F;
         locolor := locolor shl 4;
         hicolor := ccolor AND $F0;
         hicolor := hicolor shr 4;
         ccolor  := locolor + hicolor;
         SCRPUT(cchar,ccolor)
      End;
      GoToXY((newx + i),newy);         { reverse video, new selection }
      SCRGET(cchar,ccolor);
      locolor := ccolor AND $0F;
      locolor := locolor shl 4;
      hicolor := ccolor AND $F0;
      hicolor := hicolor shr 4;
      ccolor  := locolor + hicolor;
      SCRPUT(cchar,ccolor)
   End
End;

Function DIRSELECT(mask : strtype; attr : Integer) : strtype;
Const
   OFF   = FALSE;
   ON    = TRUE;
Var
   i,oldcurx,oldcury,
   newcurx,newcury,
   oldpos,newpos,
   scrrows,fncnt        : Integer;
   ch                   : Char;
   dos_dir              : Array[1..120] of String[12];
   fileinfo             : SearchRec;
   screen               : Array[1..4000] of Byte;
Begin
   fncnt := 0;
   FindFirst(mask,attr,fileinfo);
   If DosError <> 0 Then   { if not found, return NULL }
   Begin
      DIRSELECT := '';
      Exit
   End;
   While (DosError = 0) AND (fncnt <> 120) Do   { else, collect filenames }
   Begin
      Inc(fncnt);
      dos_dir[fncnt] := fileinfo.Name;
      FindNext(fileinfo)
   End;
   oldcurx := WhereX;     { store old CURSOR position }
   oldcury := WhereY;
   SAVESCR(screen);
   CURSOR(OFF);
   scrrows := (fncnt DIV 6) + 3;
   Window(1,1,80,scrrows + 1);
   ClrScr;
   GoToXY(1,1);
   i := 1;
   While (i <= fncnt) AND (i <= 120) Do     { display all filenames }
   Begin
      FNAMEPOS(i,newcurx,newcury);
      GoToXY(newcurx,newcury);
      Write(dos_dir[i]);
      Inc(i)
   End;
   FRAME(1,1,scrrows,80,1);  { draw the frame }
   HILITE(255,1);            { highlight the first filename }
   oldpos := 1;
   newpos := 1;
   While TRUE Do             { get keypress and do appropriate action }
   Begin
      ch := ReadKey;
      Case ch of
         #27:  { Esc  }
         Begin
            Window(1,1,80,25);
            RESTORESCR(screen);
            GoToXY(oldcurx,oldcury);
            CURSOR(ON);
            DIRSELECT := '';
            Exit                       { return NULL }
         End;
         #71:  { Home }                { goto first filename }
         Begin
            oldpos := newpos;
            newpos := 1;
            HILITE(oldpos,newpos)
         End;
         #79:  { End  }                { goto last filename }
         Begin
            oldpos := newpos;
            newpos := fncnt;
            HILITE(oldpos,newpos)
         End;
         #72:  { Up   }                { move up one filename }
         Begin
            i := newpos;
            i := i - 6;
            If i >= 1 Then
            Begin
               oldpos := newpos;
               newpos := i;
               HILITE(oldpos,newpos)
            End
         End;
         #80:  { Down }                { move down one filename }
         Begin
            i := newpos;
            i := i + 6;
            If i <= fncnt Then
            Begin
               oldpos := newpos;
               newpos := i;
               HILITE(oldpos,newpos)
            End
         End;
         #75:  { Left }                { move left one filename }
         Begin
            i := newpos;
            Dec(i);
            If i >= 1 Then
            Begin
               oldpos := newpos;
               newpos := i;
               HILITE(oldpos,newpos)
            End
         End;
         #77:  { Right }               { move right one filename }
         Begin
            i := newpos;
            Inc(i);
            If i <= fncnt Then
            Begin
               oldpos := newpos;
               newpos := i;
               HILITE(oldpos,newpos)
            End
         End;
         #13:  { CR }
         Begin
            Window(1,1,80,25);
            RESTORESCR(screen);
            GoToXY(oldcurx,oldcury);    { return old CURSOR position }
            CURSOR(ON);
            DIRSELECT := dos_dir[newpos];
            Exit                        { return with filename }
         End
      End
   End
End;

{ ************************************************************************** }
{ ** Main Program : NOTE that the following is a demo program only.       ** }
{ **                It is not needed to use the DIRSELECT function.       ** }
{ ************************************************************************** }

Begin
   While TRUE Do
   Begin
      Writeln;
      Write('Enter a filespec => ');
      Readln(spec);
      fname := DIRSELECT(spec,0);
      If Length(fname) = 0 Then
      Begin
         Writeln('Filespec not found.');
         Halt
      End;
      Writeln('The file you have chosen is ',fname,'.')
   End
End.

{ ** EOF( DIRSEL.PAS )  ** }

