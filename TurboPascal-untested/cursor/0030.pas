{
I (Fire&Ice if you use screen-names) would like to contribute something
to SWAG, if you
like it. It is a modified spinning cursor unit. I found out that the
original spinkey
code (I forgot the authors name, sorry) has an error (as follows):
        If you type:
                Welcine to the wonderful world of Oz!!!
        And then backspace over it (to change what you say), so it says:
                Welc
        And then type the following message:
                Welcome to Houston!
        The String Concatenated will be:
                Welcome to Houston!erful world of Oz!!!

So, I rewrote the stuff to account for the backspace key. I have
included two units:
Cursor.pas and Incl.Pas

**Cursor Requires Incl to compile (I guess Incl could be of MISC
classification)
***PLEEZ Lemme know what you think and whether or not u will put it on
SWAG.
(oh, I did use a little code I got off SWAG for the PCBOut Proc in
CURSOR.PAS)

-Thanx

Fire&Ice
}

Unit Cursor;
{ Created By Fire&Ice }
{ Last Modified: 11/3/96 }

(* This Unit Contains Several Useful Procedures For A Spinning Cursor
Shape.
   It Serves No Real Purpose, But It's Cooler Than The Normal Cursor.
   It Contains The Following Procedures:
     SetCursor = Turns The Cursor On/Off.
     Pause2    = A Pretty Neat Pause Procedure With Color
     Spinner   = Actual Procedure For Spinning The Cursor.
     SpinStr   = Reads A String With A Spinning Cursor.
     SpinInt   = Reads An Integer With A Spinning Cursor.
     SpinReal  = Reads A Real With A Spinning Cursor.
     SpinChr   = Reads A Char And Converts and Outputs It In Uppercase.
     PCBOut    = Reads A String And Can Use PCB Color Codes To Format
it.
*)
INTERFACE
Type
  String255=String[255];

Const
  On=True;
  Off=False;
  Yes=True;
  No=False;
{ These are all the Textcolor() Options...                          }
  Black=0;        { Black                                          }
  DkBlue=1;       { Dark Blue                                      }
  DkGreen=2;      { Dark Green                                     }
  DkTurquoise=3;  { Dark Turquoise                                 }
  DkRed=4;        { Dark Red                                       }
  DkPurple=5;     { Dark Purple                                    }
  Brown=6;        { Brown                                          }
  LtGray=7;       { Standard Text Color (Light Gray)               }
  DkGray=8;       { Dark Gray                                      }
  LtBlue=9;       { Light Blue                                     }
  LtGreen=10;     { Light Green                                    }
  LtTurquoise=11; { Light Turquoise                                }
  LtRed=12;       { Light Red (Pink)                               }
  LtPurple=13;    { Light Purple                                   }
  Yellow=14;      { Yellow                                         }
  White=15;       { White                                          }
  Flash=16;       { Text Attrib for Flashing (Add 16 to Color Num) }

  Procedure SetCursor(Flg: Boolean);
  Procedure Pause2(NormCol, CycCol, StarCol:Integer);
  Procedure Spinner;
  Procedure SpinStr(Prpt:String;VAR Inpt:String);
  Procedure SpinInt(Prpt:String;VAR Intg:Integer);
  Procedure SpinReal(Prpt:String;VAR Intg:Real);
  Procedure SpinChr(Prpt:String;VAR Cr:Char);
  Procedure PCBOut(stream:string255; ret:boolean);

IMPLEMENTATION
Uses Dos, Crt, Inc;  { cut out INC below !! }

Const
  SpinChar:Array[1..4] of Char = ('─','\','│','/');

Var
  Key:Char;
  InfoLen:Integer;

{**************************************************************************}
Procedure SetCursor(Flg: Boolean);
        Var
          reg : Registers;

        Begin
          If Flg=True Then              { Turn cursor on }
         If Mem[$0040:$0049] = 7 Then
              reg.cx := $B0C            { If monochrome monitor }
         Else
           reg.cx := $607               { If color monitor }
          Else                          { Turn cursor off }
            reg.cx := $2020;
          reg.bx := 0;
          reg.ax := $0100;              { Set the interrupt function }
          Intr($10,reg);                { Call the interrupt }
        End;  { of PROCEDURE SetCursor }
{*************************************************************************}
Procedure Pause2(NormCol, CycCol, StarCol:Integer);
Const
  D=115;
  X=38;
  PD:Array[1..6] of Char = ('P', 'A', 'U', 'S', 'E', 'D');

Var
  Loop, CurHi:Integer;
  Y:Byte;
  Back:Boolean;
  K:Char;

Begin
  SetCursor(False);Writeln;
  CurHi:=1;Y:=WhereY;Back:=False;
  GotoXY(37, Y);CC(StarCol+Flash);Write('*');
  GotoXY(44, Y);Write('*');CC(NormCol);GotoXY(X, Y);
  Repeat
    GotoXY(X, Y);
    For Loop:=1 to 6 Do
      Begin
        For Loop:=1 to 6 Do
          Begin
            If Loop=CurHi Then
              Begin
                CC(CycCol);
                Write(PD[Loop]);
              End
              Else
              Begin
                CC(NormCol);
                Write(PD[Loop]);
              End;
          End;
    End;
    If CurHi=6 Then
      Begin
        CurHi:=5;
        Back:=True
      End
      Else
      If (Back=True) And (CurHi > 1) Then
        CurHi:=CurHi-1
      Else
      If (Back=True) And (CurHi = 1) Then
        Begin
          CurHi:=2;
          Back:=False
        End
      Else
        CurHi:=CurHi+1;
    Delay(D);
  Until KeyPressed;
  K:=Readkey;GotoXY(43, Y);CC(LtGray);Writeln;
  SetCursor(True);
  End; { of PROCEDURE Pause2 }
{**************************************************************************}
Procedure Spinner;
  Var
    X, Y:Byte;
    Q:Integer;

  Begin
    X:=WhereX; Y:=WhereY;
    Q:=1;
    Repeat
      Write(SpinChar[Q]);
      Delay(40);
      GotoXY(X, Y);
      Write(' ');
      GotoXY(X, Y);
      Q:=Q+1;
      If Q = 5 Then
        Q:=1;
    Until KeyPressed;
      Key:=Readkey;
      Write(Key);
      If (Key=Chr(8)) And (InfoLen > 0) Then
        InfoLen:=InfoLen - 1
      Else
        InfoLen:=InfoLen + 1;
  End; { of PROCEDURE Spinner }
{**************************************************************************}
Procedure SpinStr(Prpt:String;VAR Inpt:String);

  Label Top;

  Var
    Cycler, Cycl2:Integer;
    Tstr, Tstr2:String;
    L:Integer;


  Begin
    SetCursor(Off);
    Top:
    Write(Prpt);
    Inpt:='';
    InfoLen:=0;
    Tstr:='';
    L:=0;
    Repeat
      Spinner;
      If Key<>Chr(8) Then
        Begin
          L:=L+1;
          Inpt:=Inpt+Key;
        End
        Else
        Begin
          Tstr2:='';
          For Cycl2:= 1 to (L-1) DO
            Begin
              Tstr2:=Tstr2+Inpt[Cycl2];
            End; { of FOR Cycl2 }
          L:=L-1;
          Inpt:=Tstr2;
        End; { of IF Key... }

    Until Key=Chr(13);
    Writeln;
    If (InfoLen > 0) Then
      InfoLen:=InfoLen - 1;

    If InfoLen > 0 Then
    Begin
      For Cycler:= 1 to InfoLen DO
        Begin
          Tstr:=Tstr+Inpt[Cycler]
        End; { of FOR Cycler }
      Inpt:=Tstr;
    End
    Else
      Begin
        Writeln('ERR: Invalid Entry!');
        goto Top
      End;
   SetCursor(On);
  End; { of PROCEDURE SpinStr }
{**************************************************************************}
Procedure SpinInt(Prpt:String;VAR Intg:Integer);

  Var
    Cd:Integer;
    Inpt:String;

  Begin
    SpinStr(Prpt, Inpt);
    Val(Inpt,Intg,Cd);
  End; { of PROCEDURE SpinInt }
{**************************************************************************}
Procedure SpinReal(Prpt:String;VAR Intg:Real);

  Var
    Cd:Integer;
    Inpt:String;

  Begin
    SpinStr(Prpt, Inpt);
    Val(Inpt,Intg,Cd);
  End; { of PROCEDURE SpinReal }
{**************************************************************************}
Procedure SpinChr(Prpt:String;VAR Cr:Char);
  Var
    X, Y:Byte;

  Begin
    SetCursor(Off);
    Write(Prpt);
    Spinner;
    X:=WhereX; Y:=WhereY; X:=X-1;
    GotoXY(X, Y);
    Cr:=UpCase(Key);
    Writeln(Cr);
    SetCursor(On);
  End; { of PROCEDURE SpinChr }
{**************************************************************************}
Procedure PCBOut(stream:string255; ret:boolean);
  Var
    _retval:integer;
    out,out1:string[5];

  Begin
    For _retval:=1 To length(stream) Do
      Begin
        out:=copy(stream,_retval,1);
        Case out[1] Of
          '@':Begin
                out1:=copy(stream,_retval+2,1);
                Case out1[1] Of
                  '0':TextBackground(0);
                  '1':TextBackground(1);
                  '2':TextBackground(2);
                  '3':TextBackground(3);
                  '4':TextBackground(4);
                  '5':TextBackground(5);
                  '6':TextBackground(6);
                  '7':TextBackground(7);
                  '8':TextBackground(8);
                  '9':TextBackground(9);
                  'A':TextBackground(10);
                  'B':TextBackground(11);
                  'C':TextBackground(12);
                  'D':TextBackground(13);
                  'E':TextBackground(14);
                  'F':TextBackground(15);
                End;
                out1:=Copy(stream,_retval+3,1);
                Case out1[1] Of
                  '0':TextColor(0);
                  '1':TextColor(1);
                  '2':TextColor(2);
                  '3':TextColor(3);
                  '4':TextColor(4);
                  '5':TextColor(5);
                  '6':TextColor(6);
                  '7':TextColor(7);
                  '8':TextColor(8);
                  '9':TextColor(9);
                  'A':TextColor(10);
                  'B':TextColor(11);
                  'C':TextColor(12);
                  'D':TextColor(13);
                  'E':TextColor(14);
                  'F':TextColor(15);
                End;
                _retval:=_retval+3;
              End;
          Else Write(out[1]);
        End;
      End;
    If ret=Yes Then writeln;
 End; { of PROCEDURE PCBOut }
{**************************************************************************}
End. { of Unit Cursor }

{ --------------   CUT -------------- }

Unit Inc;

{ Created By: Fire&Ice }
{ Last Modified: 10/11/96 }
INTERFACE

Function Right(Strng:string;numbr:byte):string;
Function Left(Strng:string;numbr:byte):string;
Procedure Pause;
Procedure CC(col:integer);
Procedure BC(col:integer);
Procedure Cnt_Txt (txt:string);

Const
{ These are all the Textcolor() Options...                          }
  Black=0;        { Black                                          }
  DkBlue=1;       { Dark Blue                                      }
  DkGreen=2;      { Dark Green                                     }
  DkTurquoise=3;  { Dark Turquoise                                 }
  DkRed=4;        { Dark Red                                       }
  DkPurple=5;     { Dark Purple                                    }
  Brown=6;        { Brown                                          }
  LtGray=7;       { Standard Text Color (Light Gray)               }
  DkGray=8;       { Dark Gray                                      }
  LtBlue=9;       { Light Blue                                     }
  LtGreen=10;     { Light Green                                    }
  LtTurquoise=11; { Light Turquoise                                }
  LtRed=12;       { Light Red (Pink)                               }
  LtPurple=13;    { Light Purple                                   }
  Yellow=14;      { Yellow                                         }
  White=15;       { White                                          }
  Flash=16;       { Text Attrib for Flashing (Add 16 to Color Num) }
{ Number of Columns in the Screen (For Procedure Cnt_Txt) }
  NumCols=80;

IMPLEMENTATION
uses Crt;

{***************************************************************************}
FUNCTION Right(Strng:string;numbr:byte):string;
Var
 loc:byte;                                        { Like The MSBasic }
                                                  { Right Procedure }
Begin
  If numbr >= LENGTH(Strng) then
    Right:=strng
  Else
    Begin
      loc:=length(strng)-numbr+1;
      Right:=copy(strng,loc,numbr);
    End;
End;
{***************************************************************************}
FUNCTION Left(Strng:string;numbr:byte):string;       { Like The MSBasic
}
  Begin                                              { Left Procedure }
    Left:=COPY(Strng,1,numbr);
  End;
{***************************************************************************}
Procedure Pause;                      { This Procedure pauses the
program }
Var
  Wtt:Char;

  Begin
    writeln;write('Press Any Key To Continue...');Wtt:=readkey;writeln;
  End;
{***************************************************************************}
Procedure CC(col:integer);      { Easier than typing Textcolor() }
  Begin
    Textcolor(col);           { ** CC stands for 'Color Change' ** }
  End;
{***************************************************************************}
Procedure BC(col:integer);    { Easier than typing Textbackground() }
  Begin
    Textbackground(col);    { ** BC stands for 'Background Change' ** }
  End;
{***************************************************************************}
Procedure Cnt_Txt (txt:string);         { This Procedure does the }
Var
  shft:integer;                     { task of centering a line of text }

  Begin
    Shft:=(NumCols - Length(txt)) DIV 2;
    Shft:=Shft+Length(txt);
    Writeln(txt:shft);
  End;
{***************************************************************************}
End.

