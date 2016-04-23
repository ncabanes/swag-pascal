{
From: Michael Slack <mgslack@rsoc.rockwell.com>

> I need a way to enter strings while in graphics mode.
>
> Right now, I am just using ReadLn...  for the first time I input a
> string, it gets shown, just as it would in DOS, in the upper-left hand
> corner of the screen.  This is just fine, as there are no important
> screen elements there, and I can just erase it after the string is
> entered.  But then, the next inputted string shows up on the next 'line'
> of the screen, just like a normal text cursor would move down a line.  I
> need a way to either select where (and preferably in which font) the text
> would be entered, or a way to reposition the 'text' cursor back at its
> original home position in the upper-left corner.  I really need this
> SOON, so PLEASE, if ya know, mail or followup.  Thanks eversomuch...

Try using this.  I wrote it some time ago.

(* INCLUDE file for inputting text in graphics mode *)
}

(************************************************************************)
{ AUTHOR: Michael G. Slack                                               }
{ ENVIRONMENT: Turbo Pascal V6.0                                         }
{ PURPOSE: This include is used to implement a graphical input routine   }
{  for text strings.  It is general enough to be used by any graphics    }
{  mode.                                                                 }
(************************************************************************)

 TYPE CHARSET = SET OF CHAR;

 CONST Null    = #0;    {constants brought from editln unit}
       Bell    = ^G;
       BS      = #8;
       LF      = #10;
       CR      = #13;
       ESC     = #27;
       Space   = #32;
       Tab     = ^I;
       BackTab = #143;

       F1  = #187;
       F2  = #188;
       F3  = #189;
       F4  = #190;
       F5  = #191;
       F6  = #192;
       F7  = #193;
       F8  = #194;
       F9  = #195;
       F10 = #196;

       UpKey    = #200;
       DownKey  = #208;
       LeftKey  = #203;
       RightKey = #205;
       PgUpKey  = #201;
       PgDnKey  = #209;
       HomeKey  = #199;
       EndKey   = #207;
       InsKey   = #210;
       DelKey   = #211;

       MouseClick = #255;

(************************************************************************)

 FUNCTION ScanKey : CHAR;
     (* Reads a key from the keyboard and converts 2 scan code escape *)
     (*  sequences into 1 character.                                  *)

    VAR Ch : CHAR;

  BEGIN (*scankey*)
   REPEAT UNTIL KeyPressed OR (Mouse.Event = $04)  {left button released}
                           OR (Mouse.Event = $10); {right button released}
   IF Mouse.Event > 0
    THEN BEGIN
          ScanKey := MouseClick; Mouse.Event := 0;
          Exit;
         END;
   Ch := ReadKey;
   IF (Ch = #0) AND KeyPressed
    THEN BEGIN
          Ch := ReadKey;
          IF Ord(Ch) < 128 THEN Ch := Chr(Ord(Ch) + 128);
         END;
   ScanKey := Ch;
  END; (*scankey*)

(************************************************************************)

 FUNCTION CursorWait(X,Y,FCol,BCol : INTEGER) : CHAR;
     (* function to wait for a keypress and return the key *)

    VAR XX : INTEGER;

  BEGIN (*cursorwait*)
   XX := X+TextWidth('M');
   Y := Y + 3 + TextHeight('M');
   REPEAT
    SetColor(FCol); Line(X,Y,XX,Y);
    Delay(55);
    SetColor(BCol); Line(X,Y,XX,Y);
    Delay(55);
   UNTIL Keypressed OR (Mouse.Event > 0);
   CursorWait := ScanKey;
   SetColor(FCol);
  END; (*cursorwait*)

(************************************************************************)

 PROCEDURE InputALineOfText(L, X, Y : INTEGER; Legal, Terms : CHARSET;
                            VAR S : STRING; VAR TC : CHAR);
     (* procedure to allow an input of a line of text at an xy loc *)
     (* in graphics mode.  Will place cursor at end of string pas- *)
     (* sed. will need to use editln.tpu (from database toolbox).  *)

    VAR P, PP : INTEGER;
        Ch    : CHAR ABSOLUTE TC;
        SStr  : STRING[1];
        CSave : BYTE;

  BEGIN (*inputalineoftext*)
   P  := Length(S);
   PP := TextWidth(S);
   OutTextXY(X,Y,S);
   REPEAT
    Ch := CursorWait(X+PP,Y,GetColor,Black);
    CASE Ch OF
     #32..#126 : IF (P < L) AND (Ch IN Legal)
                  THEN BEGIN
                        IF Length(S) = L THEN Delete(S,L,1);
                        Inc(P);
                        Insert(Ch,S,P);
                        SStr := Ch;
                        OutTextXY(X+PP,Y,SStr);
                        PP := PP + TextWidth(SStr)
                       END
                 ELSE Write(Bell);
     BS, #127,
     LeftKey   : IF P > 0
                  THEN BEGIN
                        SStr := S[P];
                        CSave := GetColor;
                        SetColor(GetBkColor);
                        PP := PP - TextWidth(SStr);
                        Delete(S,P,1);
                        Dec(P);
                        OutTextXY(X+PP,Y,SStr);
                        SetColor(CSave);
                       END
                 ELSE Write(Bell);
     ELSE IF NOT(Ch IN Terms) THEN Write(Bell);
    END; {case}
    ClearKB;
   UNTIL Ch IN  Terms;
  END; (*inputalineoftext*)

