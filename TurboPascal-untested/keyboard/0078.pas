UNIT KeyInput;

INTERFACE

USES CRT,           {Import Sound function}
     CURSOR;        {Import ChangeCursor}

CONST
   StandardInput = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
                  +'WXYZ1234567890~!@#$%^&*()-+\[]{};:`''".,/<> =_?|';
   HighBitInput  = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
                  +'WXYZ1234567890~!@#$%^&*()-+\[]{};:`''".,/<> =_?|'
                  +'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜ¢£¥₧ƒáíóúñÑªº¿⌐¬½¼¡«'
                  +'»░▒▓│┤╡╢║╕╣║╗╝╜╛┐└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐'
                  +'▀αßΓ
ΣσµτΦΘΩδ∞φε∩≡±≥≤⌠⌡÷≈°∙·√ⁿ²■';
   FilenameInput = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
                  +'WXYZ1234567890~!@#$%^&()-_{}.';
   FilespecInput = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
                  +'WXYZ1234567890~!@#$%^&()-_{}.?*';
   FilepathInput = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
                  +'WXYZ1234567890~!@#$%^&()-_{}.?*:\';
   NumberInput   = '123456790.-+';

   BackSpace = #8;
   Space = ' ';


TYPE
   TInput = (Standard,HighBit,Filename,Filespec,Filepath,Number);


VAR
   MaskCh: Char; {must be set before using}


PROCEDURE GetInput(VAR InStr;           (* Variable being edited *)
                   WhatWas: String;     (* "Old" Value -- being edited *)
                   InputType: TInput;   (* Input type -- from TInput *)
                   Len,                 (* Maximum Characters *)
                   XPos,                (* X Start Position *)
                   YPos,                (* Y Start Position *)
                   Attr,                (* Text Attribute while editing *)
                   HighLightAttr: Byte; (* Attribute of Highlighted Text *)
                   BackCh: Char;        (* Background Character *)
                   MaskInput,           (* Masked Input? -- Set "MaskCh" *)
                   Caps: Boolean);      (* Force CAPS? *)


IMPLEMENTATION


PROCEDURE MY_Delay(MS: Word); Assembler;
   (* My Delay procedure, used instead of TP6.0's Delay procedure *)

ASM
   MOV Ax, 1000;
   MUL MS;
   MOV Cx, Dx;
   MOV Dx, Ax;
   MOV Ah, $86;
   INT $15;
END;


PROCEDURE GetInput(VAR InStr;
                   WhatWas: String;
                   InputType: TInput;
                   Len,
                   XPos,
                   YPos,
                   Attr,
                   HighLightAttr: Byte;
                   BackCh: Char;
                   MaskInput,
                   Caps: Boolean);

TYPE
   TInsert = (On,Off); (* Insert On/Off Type *)

VAR
   Temp: String;                      (* Temporary String Holder *)
   Ch: Char;                          (* Reads Characters *)
   A, B, U: Byte;                     (* Counters *)
   ValidKey,                          (* Whether is valid key *)
   FirstChar,                         (* Whether is first char entered *)
   InsertOn,                          (* Insert or overstrike mode *)
   NoAdd: Boolean;                    (* Whether to add key to string *)
   NewString: String ABSOLUTE InStr;  (* String being edited *)


   PROCEDURE Ding;
      (* Makes sound to tell user invalid key was pressed *)

   BEGIN
      Sound(300);
      MY_Delay(30);
      NoSound;
   END;


   PROCEDURE ToggleInsert(Ins: TInsert);
      (* Toggles Insert/Overstrike Mode via TInsert type *)

   BEGIN
      IF Ins = On THEN
       BEGIN
          InsertOn := TRUE;
          ChangeCursor(NormCursor);
       END
      ELSE
       BEGIN
          InsertOn := FALSE;
          ChangeCursor(BlockCursor);
       END;
   END;


   PROCEDURE FlushKBuff;
      (* Flush keyboard buffer *)
   VAR Flush: Char;

   BEGIN
      WHILE KeyPressed DO Flush := Readkey;
   END;


BEGIN
   ChangeCursor(NormCursor); (* Default to normal cursor *)
   InsertOn := TRUE;         (* Default to Insert Mode *)
   FirstChar := TRUE;        (* Set to first character being entered *)
   NewString := '';          (* Null NewString *)
   Temp := '';               (* Null Temporary String *)
   GotoXY(XPos,YPos);
   TextAttr := Attr;
   FOR U := 1 TO Len DO Write(BackCh);
   GotoXY(XPos,YPos);
   FlushKBuff;
   Ch := #0;
   TextAttr := HighLightAttr;
   NewString := WhatWas;
   IF MaskInput THEN FOR U := 1 TO Length(NewString) DO Write(MaskCh)
   ELSE Write(NewString);
   B := Length(WhatWas);
   A := B;
      (* "A" Counter = How many characters are in string *)
      (* "B" Counter = Current cursor placement in string *)
   TextAttr := Attr;
   WHILE (Ch <> #13) AND (Ch <> #27) DO
    BEGIN
       NoAdd := FALSE;    (* Default to add key to string *)
       ValidKey := FALSE; (* Default to invalid key unless proven valid *)
       IF Caps THEN Ch := UpCase(ReadKey)
       ELSE Ch := ReadKey;
       CASE InputType OF (* Check if Ch is in the input list *)
          Standard: IF (POS(Ch,StandardInput) > 0) OR
                       (Ch IN [#13,#27,#0,#8,#25]) THEN ValidKey := TRUE;
          HighBit : IF (POS(Ch,HighBitInput) > 0) OR
                       (Ch IN [#13,#27,#0,#8,#25]) THEN ValidKey := TRUE;
          Filename: IF (POS(Ch,FilenameInput) > 0) OR
                       (Ch IN [#13,#27,#0,#8,#25]) THEN ValidKey := TRUE;
          Filespec: IF (POS(Ch,FilespecInput) > 0) OR
                       (Ch IN [#13,#27,#0,#8,#25]) THEN ValidKey := TRUE;
          Filepath: IF (POS(Ch,FilepathInput) > 0) OR
                       (Ch IN [#13,#27,#0,#8,#25]) THEN ValidKey := TRUE;
          Number  : IF (POS(Ch,NumberInput) > 0) OR
                       (Ch IN [#13,#27,#0,#8,#25]) THEN ValidKey := TRUE;
       END;
       IF ValidKey THEN
        BEGIN
           CASE Ch OF
              #0 : BEGIN
                      NoAdd := TRUE;
                      IF FirstChar THEN
                       BEGIN
                          FirstChar := FALSE;
                          GotoXY(XPos,YPos);
                          IF MaskInput THEN FOR U := 1 TO Length(NewString) DO Write(MaskCh)
                          ELSE Write(NewString);
                       END;
                      Ch := UpCase(ReadKey);
                      CASE Ch OF
                         #77: IF B <= Length(NewString)-1 THEN {Right Arrow}
                               BEGIN
                                  GotoXY(XPos+B+1,YPos);
                                  Inc(B);
                               END
                              ELSE Ding;
                         #75: IF B >= 1 THEN {Left Arrow}
                               BEGIN
                                  GotoXY(XPos+B-1,YPos);
                                  Dec(B);
                               END
                              ELSE Ding;
                         #71: BEGIN {Home}
                                 GotoXY(XPos,YPos);
                                 B := 0;
                              END;
                         #79: BEGIN {End}
                                 GotoXY(XPos+Length(NewString),YPos);
                                 B := Length(NewString);
                              END;
                         #82: IF InsertOn THEN ToggleInsert(Off) {Ins}
                              ELSE ToggleInsert(On);
                         #83: BEGIN {Del}
                                 IF (B < Length(NewString)) AND (B >= 0) THEN
                                  BEGIN
                                     Delete(NewString,B+1,1);
                                     FOR U := B TO Length(NewString) DO
                                      IF MaskInput THEN
                                       BEGIN
                                          IF U <> B THEN Temp := Temp + MaskCh
                                          ELSE Temp := '';
                                       END
                                      ELSE
                                       BEGIN
                                          IF U <> B THEN Temp := Temp + NewString[U]
                                          ELSE Temp := '';
                                       END;
                                     GotoXY(XPos+B,YPos);
                                     Write(Temp);
                                     Write(BackCh);
                                     GotoXY(XPos+B,YPos);
                                     Dec(A);
                                  END;
                              END;
                         ELSE Ding;
                      END;
                      FlushKBuff;
                   END;
              #8 : IF B >= 1 THEN {Backspace}
                    BEGIN
                       IF FirstChar THEN
                        BEGIN
                           FirstChar := FALSE;
                           GotoXY(XPos,YPos);
                           IF MaskInput THEN FOR U := 1 TO Length(NewString) DO Write(MaskCh)
                           ELSE Write(NewString);
                        END;
                       Delete(NewString,B,1);
                       Write(Backspace,BackCh,Backspace);
                       Dec(B);
                       Dec(A);
                       GotoXY(XPos+B,YPos);
                       FOR U := B TO Length(NewString) DO
                        IF MaskInput THEN
                         BEGIN
                            IF B <> U THEN Temp := Temp + MaskCh
                            ELSE Temp := '';
                         END
                        ELSE
                         BEGIN
                            IF B <> U THEN Temp := Temp + NewString[U]
                            ELSE Temp := '';
                         END;
                       Write(Temp);
                       FOR U := Length(NewString)+1 TO Len DO Write(BackCh);
                       GotoXY(XPos+B,YPos);
                       NoAdd := TRUE;
                    END
                   ELSE Ding;
              #27: BEGIN {Esc}
                      NoAdd := TRUE;
                      NewString := WhatWas;
                   END;
              #25: BEGIN {CTRL+Y}
                      NoAdd := TRUE;
                      NewString := '';
                      GotoXY(XPos,YPos);
                      FOR U := 1 TO Len DO Write(BackCh);
                      FirstChar := FALSE;
                      GotoXY(XPos,YPos);
                      B := 0;
                      A := 0;
                   END;
              #13: NoAdd := TRUE;
           END;
           IF (((A < Len) OR ((A < Len+1) AND NOT(InsertOn))) AND (NoAdd = FALSE)
              AND (Ch <> #8)) OR ((FirstChar) AND (NOT(NoAdd)) AND (Ch <> #8)) THEN
            BEGIN
               IF FirstChar THEN
                BEGIN
                   NewString := '';
                   GotoXY(XPos,YPos);
                   B := 0;
                   A := 0;
                   FOR U := 1 TO Len Do Write(BackCh);
                   GotoXY(XPos,YPos);
                   FirstChar := FALSE;
                END;
               IF InsertOn THEN
                BEGIN
                   Inc(B);
                   Inc(A);
                   Insert(Ch,NewString,B);
                   FOR U := B TO Length(NewString) DO
                    IF MaskInput THEN
                     BEGIN
                        IF B <> U THEN Temp := Temp + MaskCh
                        ELSE Temp := '';
                     END
                    ELSE
                     BEGIN
                        IF B <> U THEN Temp := Temp + NewString[U]
                        ELSE Temp := '';
                     END;
                   GotoXY(XPos+B-1,YPos);
                   IF MaskInput THEN Write(MaskCh)
                   ELSE Write(Ch);
                   Write(Temp);
                   GotoXY(XPos+B,YPos);
                END
               ELSE
                BEGIN
                   IF Length(NewString) < Len THEN
                    BEGIN
                       IF B >= Length(NewString) THEN Inc(A);
                       Inc(B);
                       Delete(NewString,B,1);
                       Insert(Ch,NewString,B);
                       IF MaskInput THEN Write(MaskCh)
                       ELSE Write(Ch);
                    END
                   ELSE IF (A = Len) AND (B < Len) THEN
                    BEGIN
                       Inc(B);
                       Delete(NewString,B,1);
                       Insert(Ch,NewString,B);
                       IF MaskInput THEN Write(MaskCh)
                       ELSE Write(Ch);
                    END;
                END;
            END;
        END
       ELSE Ding;
    END;
   FlushKBuff;
   ChangeCursor(NormCursor);
END;


END.

