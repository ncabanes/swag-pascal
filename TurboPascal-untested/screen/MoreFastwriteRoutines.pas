(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0044.PAS
  Description: More FASTWRITE Routines
  Author: SWAG SUPPORT TEAM
  Date: 11-21-93  09:34
*)

{$R-}
UNIT FWrite;
(**) INTERFACE (**)
USES Crt;
VAR
  ScreenWidth,
  ScreenHeight : Byte;

  PROCEDURE FastWrite(S : String; co, ro, at : Byte);
  PROCEDURE FasterWrite(S:String; co, ro, at : Word);
  PROCEDURE CheckWidthHeight;
(**) IMPLEMENTATION (**)
TYPE
  WordArray = ARRAY[0..65520 DIV 2] OF Word;
VAR
  Display  : ^WordArray;
  Crt_Cols : Word ABSOLUTE $0040:$004A;
  Crt_Rows : Word ABSOLUTE $0040:$0084;

  PROCEDURE FastWrite(S : String; co, ro, at : Byte);
  VAR
    Start, WordAttr : Word;
    N : Byte;
  BEGIN
    Start:= pred(ro)*ScreenWidth + pred(co);
    WordAttr := Word(At) SHL 8;
    FOR N := 1 to length(S) DO
      Display^[start+pred(N)] := WordAttr + ord(S[N]);
  END;

  PROCEDURE FasterWrite(S:String; co,
                        ro, at : Word); Assembler;
  ASM
    MOV AX, ro               {                        }
    DEC AL                   { These calculations     }
    SHL AL, 1                { get the initial offset }
    MUL ScreenWidth          { into the AX register   }
    ADD AX, co               {                        }
    DEC AX                   {                        }
    MOV DI, Word(Display)    { DI now points to the   }
    ADD DI, AX               { starting offset.       }
    MOV AX, Word(Display+2)
    MOV ES, AX               { ES has video segment   }
    PUSH DS
    LDS SI, S                { DS:SI points to string }
    XOR CX, CX
    MOV CL, [SI]             { String length in CX    }
    INC SI
    MOV BH, Byte(At)         { Attribute in BH        }
    @Loop:
      MOVSB                  { Move a char to screen  }
      MOV ES:[DI], BH        { .. and its attribute   }
      INC DI
    Loop @Loop
    POP DS
  END;

  PROCEDURE CheckWidthHeight;
  BEGIN
    ScreenWidth := Crt_Cols;
    ScreenHeight := succ(Crt_Rows);
  END;

(** INITIALIZATION **)
BEGIN
  CheckWidthHeight;
  IF LastMode = 7 THEN
    Display := Ptr($B000, 0)
  ELSE Display := Ptr($B800, 0);
END.
