{===========================================================================
Date: 10-02-93 (06:28)
From: RANDALL WOODMAN
Subj: Input

{->>>>GetString<<<<--------------------------------------------}
{                                                              }
{ Filename : GETSTRIN.SRC -- Last Modified 7/14/88             }
{                                                              }
{ This is a generalized string-input procedure.  It shows a    }
{ field between vertical bar characters at X,Y, with any       }
{ string value passed initially in XString left-justified in   }
{ the field.  The current state of XString when the user       }
{ presses Return is returned in XString.  The user can press   }
{ ESC and leave the passed value of XString undisturbed, even  }
{ if XString was altered prior to his pressing ESC.            }
{                                                              }
{     From: COMPLETE TURBO PASCAL 5.0  by Jeff Duntemann       }
{    Scott, Foresman & Co., Inc. 1988   ISBN 0-673-38355-5     }
{--------------------------------------------------------------}

PROCEDURE GetString(    X,Y      : Integer;
                    VAR XString  : String80;
                        MaxLen   : Integer;
                        Capslock : Boolean;
                        Numeric  : Boolean;
                        GetReal  : Boolean;
                    VAR RValue   : Real;
                    VAR IValue   : Integer;
                    VAR Error    : Integer;
                    VAR Escape   : Boolean);

VAR I,J        : Integer;
    Ch         : Char;
    Cursor     : Char;
    Dot        : Char;
    BLength    : Byte;
    ClearIt    : String80;
    Worker     : String80;
    Printables : SET OF Char;
    Lowercase  : SET OF Char;
    Numerics   : SET OF Char;
    CR         : Boolean;


BEGIN
  Printables := [' '..'}'];               { Init sets }
  Lowercase  := ['a'..'z'];
  IF GetReal THEN Numerics := ['-','.','0'..'9','E','e']
    ELSE Numerics := ['-','0'..'9'];
  Cursor := '_'; Dot := '.';
  CR := False; Escape := False;
  FillChar(ClearIt,SizeOf(ClearIt),'.');  { Fill the clear string  }
  ClearIt[0] := Chr(MaxLen);              { Set clear string to MaxLen }

                                { Convert numbers to string if required:  }
  IF Numeric THEN               { Convert zero values to null string: }
    IF (GetReal AND (RValue = 0.0)) OR
       (NOT GetReal AND (IValue = 0)) THEN XString := ''
    ELSE                        { Convert nonzero values to string equiv: }
      IF GetReal THEN Str(RValue:MaxLen,XString)
        ELSE Str(IValue:MaxLen,XString);

                                          { Truncate string value to MaxLen }
  IF Length(XString) > MaxLen THEN XString[0] := Chr(MaxLen);
  GotoXY(X,Y); Write('|',ClearIt,'|');    { Draw the field  }
  GotoXY(X+1,Y); Write(XString);
  IF Length(XString)<MaxLen THEN
    BEGIN
      GotoXY(X + Length(XString) + 1,Y);
      Write(Cursor)                       { Draw the Cursor }
    END;
  Worker := XString;      { Fill work string with input string     }

  REPEAT                  { Until ESC or (CR) entered }
                          { Wait here for keypress:   }
    WHILE NOT KeyPressed DO BEGIN {NULL} END;
    Ch := ReadKey;

    IF Ch IN Printables THEN              { If Ch is printable... }
      IF Length(Worker) >= MaxLen THEN UhUh ELSE
        IF Numeric AND (NOT (Ch IN Numerics)) THEN UhUh ELSE
          BEGIN
            IF Ch IN Lowercase THEN IF Capslock THEN Ch := Chr(Ord(Ch)-32);
            Worker := CONCAT(Worker,Ch);
            GotoXY(X+1,Y); Write(Worker);
            IF Length(Worker) < MaxLen THEN Write(Cursor)
          END
    ELSE   { If Ch is NOT printable... }
      CASE Ord(Ch) OF
       8,127 : IF Length(Worker) <= 0 THEN UhUh ELSE
                  BEGIN
                    Delete(Worker,Length(Worker),1);
                    GotoXY(X+1,Y); Write(Worker,Cursor);
                    IF Length(Worker) < MaxLen-1 THEN Write(Dot);
                  END;

       13 : CR := True;          { Carriage return }

       24 : BEGIN                { CTRL-X : Blank the field }
              GotoXY(X+1,Y); Write(ClearIt);
              Worker := '';      { Blank out work string }
            END;

       27 : Escape := True;      { ESC }
       ELSE UhUh                 { CASE ELSE }
    END; { CASE }

  UNTIL CR OR Escape;            { Get keypresses until (CR) or }
                                 { ESC pressed }
  GotoXY(X + 1,Y); Write(ClearIt);
  GotoXY(X + 1,Y); Write(Worker);
  IF CR THEN                     { Don't update XString if ESC hit }
    BEGIN
      XString := Worker;
      IF Numeric THEN            { Convert string to Numeric values }
        CASE GetReal OF
          True  : Val(Worker,RValue,Error);
          False : Val(Worker,IValue,Error)
        END { CASE }
      ELSE
        BEGIN
          RValue := 0.0;
          IValue := 0
        END
    END
END;  { GETString }
