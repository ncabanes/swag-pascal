
{ A good line editor object }

UNIT EditObj; {  Object_Line_Editor  }

INTERFACE

USES Crt, KeyBd;

TYPE
  LineEdit = OBJECT
    Pos, XPos, YPos : Integer;
    EdLine : String;
    PROCEDURE InitEdit( X, Y: Integer; LineIn: String );
    FUNCTION  GetLine: String;
  END;

VAR
   Kbd: KeyBoard;   {<<<========== Global definition of OBJECT}

{***************************************************************}
                        IMPLEMENTATION
{***************************************************************}

{-------------------------------------------------
- Name   : InitEdit                              -
- Purpose: Set up editor, display line onscreen  -
-------------------------------------------------}

PROCEDURE LineEdit.InitEdit;
  BEGIN
    EdLine := LineIn;
    Pos  := Ord( LineIn[0] ) + 1;
    XPos := X;
    YPos := Y;
    GotoXY( X, Y );
    Write( LineIn );
  END;

{-------------------------------------------------
- Name   : GetLine                               -
- Purpose: Process keying from user              -
-          Maximum 80 characters accepted        -
-------------------------------------------------}

FUNCTION  LineEdit.GetLine;
  VAR
    KeyFlags : Byte;
    Ch: Char;
    FunctKey, Finish: Boolean;
  BEGIN
    Finish := FALSE;
    REPEAT
      IF Kbd.GetKey( KeyFlags, FunctKey, Ch ) THEN BEGIN
        IF FunctKey THEN
          CASE Ch OF
{ HOME   }  #$47: Pos := 1;
{ END    }  #$4F: Pos := Ord( EdLine[0] ) + 1;
{ RIGHT  }  #$4D: BEGIN
                    IF Pos < 80 THEN Inc( Pos );
                    IF Pos > Ord( EdLine[0] ) THEN
                      Insert( ' ', EdLine, Pos );
                    END;
{ LEFT   }  #$4B: IF Pos > 1  THEN Dec( Pos );
{ DELETE }  #$53: IF Pos <= Ord( EdLine[0] ) THEN
                     Delete( EdLine, Pos, 1 );
            END {CASE Ch}
          ELSE {IF}
            CASE Ch OF
{ BS }        #$08: IF Pos > 1 THEN BEGIN
                      Delete( EdLine, Pos-1, 1 );
                      Dec( Pos );
                      END;
{ ENTER }     #$0D: Finish := TRUE;
              ELSE BEGIN
                IF( ( KeyFlags AND $80 ) <> $80 )
                   THEN Insert( Ch, EdLine, Pos )
                   ELSE EdLine[Pos] := Ch;
                IF Pos > Ord( EdLine[0] ) THEN
                   EdLine[0] := Chr( Pos );
                IF Pos < 80 THEN Inc( Pos );
                END     {CASE CH ELSE}
              END;    {CASE Ch}
        GotoXY( XPos, YPos );
        Write( EdLine, ' ' );
        GotoXY( XPos+Pos-1, YPos );
        END;  {IF Kbd.GetKey}
      UNTIL Finish;
      GetLine := EdLine;
    END;

END.


{  KEYBOARD UNIT }
UNIT Keybd;  { Keybd.PAS / Keybd.TPU }

INTERFACE

USES Crt, Dos;

TYPE
  CType = ( UBAR, BLOCK );
  Keyboard = OBJECT
    ThisCursor: CType;
    PROCEDURE InitKeyBd;
    PROCEDURE SetCursor( Cursor: CType );
    FUNCTION  GetCursor: CType;
    FUNCTION  GetKbdFlags: Byte;
    FUNCTION  GetKey( VAR KeyFlags: Byte; VAR FunctKey: Boolean;
                                        VAR Ch: Char ): Boolean;
  END;

{***************************************************************}
                      IMPLEMENTATION
{***************************************************************}


{Keyboard}

{-------------------------------------------------
- Name   : InitKeyBd                             -
- Purpose: Set the cursor to underline style     -
-          and empty keyboard buffer             -
-------------------------------------------------}

PROCEDURE Keyboard.InitKeyBd;
  VAR
    Ch : Char;
  BEGIN
    SetCursor( UBAR );
    WHILE( KeyPressed ) DO Ch := ReadKey;
  END;

{-------------------------------------------------
- Name   : SetCursor                             -
- Purpose: Modify number of lines for cursor     -
-------------------------------------------------}

PROCEDURE Keyboard.SetCursor;
  VAR
    Regs: Registers;
  BEGIN
    CASE Cursor OF
      UBAR:  Regs.Ch := 6;
      BLOCK: Regs.Ch := 1;
    END;
    Regs.CL := 7;
    Regs.AH := 1;
    Intr( $10, Regs );
  END;

{-------------------------------------------------
- Name   : GetKbdFlags                           -
- Purpose: Monitor the Insert key                -
- Output : Shift key status flag byte            -
-------------------------------------------------}

FUNCTION  Keyboard.GetKbdFlags: Byte;
  VAR
    Regs: Registers;
  BEGIN
    (* FOR enhanced keyboards: AH := $12 *)
    (* FOR normal keyboards:   AH := $02 *)
    Regs.AH := $12;
    Intr( $16, Regs );
    IF( Regs.AX AND $80 = $80 ) THEN SetCursor( BLOCK )
                                ELSE SetCursor( UBAR );
    GetKbdFlags := Regs.AX;
  END;

{-------------------------------------------------
- Name   : GetCursor                             -
- Purpose: Query current cursor state            -
-------------------------------------------------}

FUNCTION  Keyboard.GetCursor;
  BEGIN
    GetCursor := ThisCursor;
  END;

{-------------------------------------------------
- Name   : GetKey                                -
- Purpose: Get a keypress contents if any        -
-          Updates a function keypressed flag    -
-------------------------------------------------}

FUNCTION  Keyboard.GetKey;
  VAR
    Result : Boolean;
  BEGIN
    Result := KeyPressed;
    FunctKey := FALSE;
    Ch := #$00;       {Use this to check for Function key press}
    IF Result THEN BEGIN
      Ch := ReadKey;
      IF( KeyPressed AND ( Ch = #$00 ) ) THEN BEGIN
        Ch := ReadKey;
        FunctKey := TRUE;
        END;
      END;
    KeyFlags := GetKbdFlags;
    GetKey := Result;
    END;

END.

{   DEMO PROGRAM  }

PROGRAM EditDemo;

{-------------------------------------------------
-  Show off example of global object use         -
-------------------------------------------------}

USES Crt, EditObj;

VAR
   Editor: LineEdit;           {Instantiation of LineEdit OBJECT}
   ResultStr: String;
BEGIN
   ClrScr;
   WITH Editor DO
   BEGIN
      InitEdit( 1, 10, 'Edit this sample line');
      ResultStr := GetLine;
      GotoXY( 1, 15 );
      WriteLn( ResultStr );
   END;
   ReadLn;
END.
