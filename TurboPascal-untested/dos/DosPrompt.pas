(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0054.PAS
  Description: Dos Prompt
  Author: GREG ESTABROOKS
  Date: 05-25-94  08:22
*)


{
 There are 2 ways that I can think of off hand. One is to execute
 COMMAND.COM with the parameter '/K PROMPT [Whatever]' OR You could
 create your own program enviroment and then add/edit as many enviroment
 variables as you have memory for. The following program demonstrates
 this. It creates its own enviroment , then copies the old info to it
 but changes the prompt to whatever you want. After the shell it
 releases the memory:
}

{***********************************************************************}
PROGRAM PromptDemo;             { Apr 18/94, Greg Estabrooks.           }
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
{***********************************************************************}

