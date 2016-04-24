(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0007.PAS
  Description: Key Input Routine
  Author: JEFF FANJOY
  Date: 01-27-94  12:04
*)

> Does anyone know how to make the input line a certain number of lines
> only!...sya the user only gets to us 3 characters....

Here is the input routine that I use for all of my programs.  You may
not need it so precise, so you can cut out anything you don't feel is
necessary but here goes:
}

UNIT KeyInput;

INTERFACE

USES CRT,CURSOR;

PROCEDURE GetInput(VAR InStr;                    {String Passed}
                       WhatWas: String;          {Old value to Remember}
                       Len: Byte;                {Length of String Max=255}
                       XPosition,                {X Cursor Position}
                       YPosition,                {Y Cursor Position}
                       BackGroundColor,          {Background Color}
                       ForeGroundColor: Integer; {Foreground Color}
                       BackGroundChar: Char;     {Echoed Character on BkSp}
                       Caps: Boolean);           {CAPS?}
IMPLEMENTATION

PROCEDURE GetInput(VAR InStr;
                       WhatWas: String;
                       Len: Byte;
                       XPosition,
                       YPosition,
                       BackGroundColor,
                       ForeGroundColor: Integer;
                       BackGroundChar: Char;
                       Caps: Boolean);

CONST
   BkSp: Char = Chr($08);

VAR
   InsertKey: Byte Absolute $0040:$0017;
   Temp: String;
   Ch2,
   C: Char;
   A,
   U,
   B: Byte;
   FirstChar,
   InsertOn,
   NoAdd: Boolean;
   NewString: String Absolute InStr;

BEGIN
   InsertKey := InsertKey OR $80; {changes to insert mode}
   IF (InsertKey AND $80 > 0) THEN
    BEGIN
       InsertOn := TRUE;
       ShowCursor;
    END
   ELSE
    BEGIN
       InsertOn := FALSE;
       BigCursor;
    END;
   FirstChar := TRUE;
   NewString := '';
   Temp := '';
   GotoXY(XPosition,YPosition);
   TextBackGround(BackGroundColor);
   TextColor(ForeGroundColor);
   FOR U := 1 TO Len DO
    BEGIN
       Write(BackGroundChar); {shows how many characters are available}
    END;
   GotoXY(XPosition,YPosition);
   C := Chr($00); {null character input}
   TextBackGround(ForeGroundColor);
   TextColor(BackGroundColor);
   NewString := WhatWas; {starts with previous value in memory}
   Write(NewString); {writes previous value to screen for editing}
   B := Length(WhatWas);
   A := B;
   TextBackGround(BackGroundColor);
   TextColor(ForeGroundColor);
   WHILE (C <> Chr($0D)) AND (C <> Chr($1B)) DO {not CR or ESC}
    BEGIN
       NoAdd := FALSE;
       IF Caps THEN C := UpCase(ReadKey) {if Caps read uppercase else...}
       ELSE C := ReadKey;
       CASE C OF
          Chr($08): IF B >= 1 THEN {backspace}
                     BEGIN
                        IF FirstChar THEN
                         BEGIN
                            FirstChar := FALSE;
                            GotoXY(XPosition,YPosition);
                            Write(NewString);
                         END;
                        Delete(NewString,B,1);
                        Write(BkSp,BackGroundChar,BkSp);
                        Dec(B);
                        GotoXY(XPosition+B,WhereY);
                        FOR U := B TO Length(NewString) DO
                         BEGIN
                            IF B <> U THEN Temp := Temp + NewString[U]
                            ELSE Temp := '';
                         END;
                        Write(Temp);
                        FOR U := Length(NewString)+1 TO Len DO
                         BEGIN
                            Write(BackGroundChar);
                         END;
                        GotoXY(XPosition+B,WhereY);
                        NoAdd := TRUE;
                        Dec(A);
                     END;
          Chr($1B): BEGIN {Escape}
                       NoAdd := TRUE;
                       NewString := WhatWas;
                    END;
          Chr($19): BEGIN {^Y = clear the editing line}
                       NoAdd := TRUE;
                       NewString := '';
                       GotoXY(XPosition,YPosition);
                       FOR U := 1 TO Len DO
                        BEGIN
                           Write(BackGroundChar);
                        END;
                       FirstChar := FALSE;
                       GotoXY(XPosition,YPosition);
                       B := 0;
                       A := 0;
                    END;
          Chr($0D): NoAdd := TRUE; {enter <CR>}
          Chr($00): BEGIN {extended keys always start with null character}
                       NoAdd := TRUE;
                       IF FirstChar THEN
                        BEGIN
                           FirstChar := FALSE;
                           GotoXY(XPosition,YPosition);
                           Write(NewString);
                        END;
                       C := UpCase(ReadKey);
                       CASE C OF
                          Chr(77): BEGIN {right arrow}
                                    IF B <= Length(NewString)-1 THEN
                                     BEGIN
                                        GotoXY(XPosition+B+1,WhereY);
                                        Inc(B);
                                     END;
                                 END;
                          Chr(75): BEGIN {left arrow}
                                      IF B >= 1 THEN
                                       BEGIN
                                          GotoXY(XPosition+B-1,WhereY);
                                          Dec(B);
                                       END;
                                   END;
                          Chr(71): BEGIN {home}
                                      GotoXY(XPosition,YPosition);
                                      B := 0;
                                   END;
                          Chr(79): BEGIN {end}
                                      GotoXY(XPosition+Length(NewString),YPosition);
                                      B := Length(NewString);
                                   END;
                          Chr(82): BEGIN {insert}
                                      IF InsertOn THEN
                                       BEGIN
                                          InsertOn := FALSE;
                                          BigCursor;
                                       END
                                      ELSE
                                       BEGIN
                                          InsertOn := TRUE;
                                          ShowCursor;
                                       END;
                                   END;
                          Chr(83): BEGIN {del}
                                      IF (B < Length(NewString)) AND (B >= 0) THEN
                                       BEGIN
                                          Delete(NewString,B+1,1);
                                          FOR U := B TO Length(NewString) DO
                                           BEGIN
                                              IF U <> B THEN Temp := Temp + NewString[U]
                                              ELSE Temp := '';
                                           END;
                                          GotoXY(XPosition+B,WhereY);
                                          Write(Temp);
                                          Write(BackGroundChar);
                                          GotoXY(XPosition+B,WhereY);
                                          Dec(A);
                                       END;
                                   END;
                       END;
                       WHILE Keypressed DO C := ReadKey;
                    END;
       END;
       IF ((A < Len) AND (NoAdd = FALSE) AND (C <> Chr($08))) OR ((FirstChar) AND
          (NOT(NoAdd)) AND (C <> Chr($08))) THEN
        BEGIN
           IF FirstChar THEN {if first character typed is a real character,then
                             string is removed to start new one else...}
            BEGIN
               Delete(NewString,1,Length(NewString));
               GotoXY(XPosition,YPosition);
               B := 0;
               A := 0;
               FOR U := 1 TO Len DO
                BEGIN
                   Write(BackGroundChar);
                END;
               GotoXY(XPosition,YPosition);
               FirstChar := FALSE;
            END;
           Inc(B);
           Inc(A);
           IF InsertOn THEN
            BEGIN
               Insert(C,NewString,B);
               FOR U := B TO Length(NewString) DO
                BEGIN
                   IF B <> U THEN Temp := Temp + NewString[U]
                   ELSE Temp := '';
                END;
               GotoXY(XPosition+B-1,WhereY);
               Write(C);
               Write(Temp);
               GotoXY(XPosition+B,WhereY);
            END
           ELSE
            BEGIN
               Insert(C,NewString,B);
               Delete(NewString,B+1,1);
               Write(C)
            END;
        END;
    END;
    TextBackGround(0);
END;


BEGIN
END.


