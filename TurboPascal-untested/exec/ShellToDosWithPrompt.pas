(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0020.PAS
  Description: Shell to DOS with PROMPT
  Author: GREG ESTABROOKS
  Date: 02-15-94  08:06
*)


 {change the dos prompt when Shelling to DOS without
  having to change the current or master enviroment(It makes it's own).}

{***********************************************************************}
PROGRAM PromptDemo;             { Feb 12/94, Greg Estabrooks.           }
{$M 16840,0,0}                  { Reserved some memory for the shell.   }
USES CRT,                         { IMPORT Clrscr,Writeln.              }
     DOS;                         { IMPORT Exec.                        }

PROCEDURE ShellWithPrompt( Prompt :STRING );
                         { Routine to allocate a temporary Enviroment   }
                         { with our prompt and the execute COMMAND.COM. }
                         { NOTE: This does NO error checking.           }
VAR
   NewEnv :WORD;                { Points to our newly allocated env.    }
   OldEnv :WORD;                { Holds Old Env Segment.                }
   EnvPos :WORD;                { Position inside our enviroment.       }
   EnvLp  :WORD;                { Variable to loop through ENVStrings.  }
   TempStr:STRING;              { Holds temporary EnvString info.       }
BEGIN
  ASM
   Mov AH,$48                   { Routine to allocate memory.           }
   Mov BX,1024                  { Allocate 1024(1k) of memory.          }
   Int $21                      { Call DOS to allocate memory.          }
   Mov NewEnv,AX                { Save segment address of our memory.   }
  END;

  EnvPos := 0;                  { Initiate pos within our Env.          }
  FOR EnvLp := 1 TO EnvCount DO { Loop through entire enviroment.       }
   BEGIN
    TempStr := EnvStr(EnvLp);   { Retrieve Envirment string.            }
    IF Pos('PROMPT=',TempStr) <> 0 THEN  { If its our prompt THEN ....  }
     TempStr := 'PROMPT='+Prompt+#0  { Create our new prompt.           }
    ELSE                        {  .... otherwise.........              }
     TempStr := TempStr + #0;   { Add NUL to make it ASCIIZ compatible. }
    Move(TempStr[1],Mem[NewEnv:EnvPos],Length(TempStr)); { Put in Env.  }
    INC(EnvPos,Length(TempStr)); { Point to new position in Enviroment. }
   END;{For}

  OldEnv := MemW[PrefixSeg:$2C];{ Save old enviroment segment.          }
  MemW[PrefixSeg:$2C] := NewEnv;{ Point to our new enviroment.          }
  SwapVectors;                  { Swap Int vectors in case of conflicts.}
  Exec(GetEnv('COMSPEC'),'');   { Call COMMAND.COM.                     }
  SwapVectors;                  { Swap em back.                         }
  MemW[PrefixSeg:$2C] := OldEnv;{ Point back to old enviroment.         }

  ASM
   Push ES                      { Save ES.                              }
   Mov AH,$49                   { Routine to deallocate memory.         }
   Mov ES,NewEnv                { Point ES to area to deallocate.       }
   Int $21;                     { Call DOS to free memory.              }
   Pop ES                       { Restore ES.                           }
  END;
END;{ShellWithPrompt}

BEGIN
  Clrscr;                        { Clear the screen.                    }
  Writeln('Type EXIT to return');{ Show message on how to exit shell.   }
  ShellWithPrompt('[PromptDemo] $P$G'); { shell to DOS with our prompt. }
END.{PromptDemo}

