{***********************************************************************}
PROGRAM Win3XInf;       {  Simple Detection routines for Windows 3.X    }
                        {  Last Updated April 28/93, Greg Estabrooks    }

FUNCTION Win3X :BOOLEAN;  ASSEMBLER;
                {  Routine to determine if Windows is currently running }
ASM
  Mov AX,$4680                          {  Win 3.x Standard check       }
  Int $2F                               {  Call Int 2F                  }
  Cmp AX,0                              {  IF AX = 0 Win in real mode   }
  JNE @EnhancedCheck                    {  If not check for enhanced mode}
  Mov AL,1                              {  Set Result to true           }
  Jmp @Exit                             {  Go to end of routine         }
@EnhancedCheck:                         {  Else check for enhanced mode }
  Mov AX,$1600                          {  Win 3.x Enhanced check       }
  Int $2F                               {  Call Int 2F                  }
  Cmp AL,0                              {  Check returned value         }
  Je @False                             {  If not one of the below it   }
  Cmp AL,$80                            {  is NOT installed             }
  Je @False
  Mov AL,1                              {  Nope it must BE INSTALLED    }
  Jmp @Exit
@False:
  Mov AL,0                              {  Set Result to False          }
@Exit:
END;{Win3X}

FUNCTION WinVer :WORD;  ASSEMBLER;
                {  Returns a word containing the version of Win Running }
                {  Should only be used after checking for Win installed }
                {  Or value returned will be meaning less               }
ASM
  Mov AX,$1600                     {    Enhanced mode check             }
  Int $2F                          {    Call Int 2F                     }
END;{WinVer}

BEGIN
  IF Win3X THEN                         {  If it is running say so      }
   BEGIN
    Writeln('Windows is Running! ');    {  Now display version running  }
    Writeln('Version Running is : ',Lo(WinVer),'.',Hi(WinVer));
   END
  ELSE                                  {  If not 'Just say NO!'        }
    Writeln('Windows is not Running!');
END.
{***********************************************************************}
