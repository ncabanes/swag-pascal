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
