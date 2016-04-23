UNIT XMS;               {  XMS Routines, Last Updated Dec 11/93        }
                        {  Copyright (C) 1993, Greg Estabrooks         }
                        {  NOTE: Requires TP 6.0+ To compile.          }
INTERFACE
{**********************************************************************}
TYPE
    _32Bit = LONGINT;
    XMSMovStruct = RECORD
                    Amount      :_32Bit;  { 32 bit number of bytes to move}
                    SourceHandle:WORD;    { Handle of Source Block.     }
                    SourceOffset:_32Bit;  { 32 bit offset to source.    }
                    DestHandle  :WORD;    { Handle of destination.      }
                    DestOffset  :_32Bit;  { 32 bit offset to destination}
                   END;
                                { If SourceHandle is 0 then SourceOffset}
                                { Is Interpereted as a SEGMENT:OFFSET   }
                                { into conventional memory.             }
                                { The Same applies to DestHandle.       }
{ Potential XMS Error Codes:                                            }
{   BL=80h if the function is not implemented                           }
{      81h if a VDISK device is detected                                }
{      82h if an A20 error occurs                                       }
{      8Eh if a general driver error occurs                             }
{      8Fh if an unrecoverable driver error occurs                      }
{      90h if the HMA does not exist                                    }
{      91h if the HMA is already in use                                 }
{      92h if DX is less than the /HMAMIN= parameter                    }
{      93h if the HMA is not allocated                                  }
{      94h if the A20 line is still enabled                             }
{      A0h if all extended memory is allocated                          }
{      A1h if all available extended memory handles are in use          }
{      A2h if the handle is invalid                                     }
{      A3h if the SourceHandle is invalid                               }
{      A4h if the SourceOffset is invalid                               }
{      A5h if the DestHandle is invalid                                 }
{      A6h if the DestOffset is invalid                                 }
{      A7h if the Length is invalid                                     }
{      A8h if the move has an invalid overlap                           }
{      A9h if a parity error occurs                                     }
{      AAh if the block is not locked                                   }
{      ABh if the block is locked                                       }
{      ACh if the block's lock count overflows                          }
{      ADh if the lock fails                                            }
{      B0h if a smaller UMB is available                                }
{      B1h if no UMBs are available                                     }
{      B2h if the UMB segment number is invalid                         }

VAR
        XMSControl :POINTER;    { Holds the address of the XMS API.     }
        XMSError   :BYTE;       { Holds any XMS error codes.            }

FUNCTION XMSDriver :BOOLEAN;
                {  Routine to determine if an XMS driver is installed.  }
                {  If it is installed it loads XMSControl with the      }
                {  location of the XMS API for the other routines.      }

FUNCTION XMSControlAdr :POINTER;
                {  This Routine returns a pointer to the XMS Controller.}

FUNCTION XMSVer :WORD;
                {  This routine returns the version of the XMS driver   }
                {  that is currently installed.                         }

FUNCTION XMSRev :WORD;
                { Returns XMS Revision Number. Usually used with XMSVer.}

FUNCTION XMSGetFreeMem :WORD;
                   {  Routine to Determine how much total XMS memory is }
                   {  free.                                             }

FUNCTION XMSGetLargeBlock :WORD;
                   {  Routine to Determine the size of the largest free }
                   {  XMS is block.                                     }

FUNCTION XMSGetMem( Blocks:WORD ) :WORD;
                    {  Routine to allocate XMS for program use.         }
                    {  Blocks = k's being requested, XMSErr = ErrorCode.}
                    {  Returns 16 bit handle to mem allocated.          }

PROCEDURE XMSFreeMem( Handle:WORD );
                    {  Routine to free previously allocated XMS Memory. }
PROCEDURE XMSMoveblock( VAR Movstruct :XMSMovStruct );
                    {  Routine to move memory blocks around in XMS memory.}

PROCEDURE XMSLockBlock( Handle :WORD );
                        { Routine to lock and XMS block. Locked blocks  }
                        { are guarnteed not to move.                    }
                        { Locked Blocks should be unlocked as soon as   }
                        { possible.                                     }

PROCEDURE XMSUnLockBlock( Handle :WORD );
                        { Routine to unlock a previously lock XMS block.}

PROCEDURE XMSReallocate( Handle ,NewSize :WORD );
                        { Routine to reallocate and XMS Block so that it}
                        { becomes equal to NewSize.                     }

FUNCTION HMAExists :BOOLEAN;
                {  This routine returns Whether or not HMA Exists.      }

PROCEDURE HMARequest( RequestType :WORD );
                   { Attempt to reserve the 64k HMA area for the caller.}
                   { NOTE: RequestType must be either FFFF = Application}
                   { OR If caller is a TSR the RequestType = Amount of  }
                   { Space wanted.                                      }

PROCEDURE HMARelease;
                      { Routine to release previously allocated HMA.    }
                      { NOTE: Any Code/Data store in that HMA Memory    }
                      { Will become invalid and inaccessible.           }

PROCEDURE GlobaleEnableA20;
                     { Routine to Enable the A20 Line. Should only be   }
                     { used by programs that have control of the HMA.   }
                     { NOTE: Remeber to disable the Line before         }
                     {       releaseing control of the system.          }

PROCEDURE GlobaleDisableA20;
                      { Routine to Disable the A20 Line. On some systems}
                      { the Toggling of the A20 Line can take a long    }
                      { time.                                           }

PROCEDURE LocalEnableA20;
                     { Routine to Enable the A20 Line for current Program}
                     { NOTE: Rember to so a LocalDisableA20 before      }
                     {       releasing system control.                  }

PROCEDURE LocalDisableA20;
                      { Routine to Locally Disable the A20 Line.        }

FUNCTION QueryA20 :BOOLEAN;
                     { Routine to test whether the A20 is Physically    }
                     { enabled or not.                                  }

FUNCTION PtrToLong( P:POINTER ) :LONGINT;
                     { Routine to convert a pointer to a 32 bit number. }

IMPLEMENTATION
{**********************************************************************}

FUNCTION XMSDriver :BOOLEAN; ASSEMBLER;
                {  Routine to determine if an XMS driver is installed.  }
                {  If it is installed it loads XMSControl with the      }
                {  location of the XMS API for the other routines.      }
ASM
  Mov AX,$4300                  {  Function to check for Driver.        }
  Int $2F                       {  Call Dos Int 2Fh.                    }
  Cmp AL,$80                    {  Check Result, if its 80h driver.     }
  Je @Installed                 {  If It is return TRUE.                }
  Mov AL,0                      {  Else Return FALSE.                   }
  Jmp @Exit
@Installed:
  Mov AX,$4310                  {  Function to return pointer to Driver.}
  Int $2F                       {  Call Interrupt.                      }
  Mov XMSControl.WORD,BX        {  Pointer info returned in ES:BX.      }
  Mov XMSControl+2.WORD,ES
  Mov AL,1                      {  Set True Flag.                       }
@Exit:
END;{XMSDriver}

FUNCTION XMSControlAdr :POINTER; ASSEMBLER;
                {  This Routine returns a pointer to the XMS Controller.}
ASM
  Push ES                       {  Push ES onto the stack.              }
  Push BX                       {  Push BX onto the stack.              }
  Mov AX,$4310                  {  Function to return pointer to Driver.}
  Int $2F                       {  Call Interrupt.                      }
  Mov DX,ES                     {  Pointer info returned in ES:BX so    }
  Mov AX,BX                     {  move it into DX:AX.                  }
  Pop BX                        {  Pop BX Off the Stack.                }
  Pop ES                        {  Pop ES Off the Stack.                }
END;{XMSControlAdr}

FUNCTION XMSVer :WORD; ASSEMBLER;
                {  This routine returns the version of the xms driver   }
                {  that is currently installed.Version is returned as a }
                {  16 bit BCD number.                                   }
ASM
  Mov AH,0                      {  Function to return XMS version.      }
  Call [XMSControl]             {  Call XMS Api.                        }
                   {  Possible returns are :                            }
                   {  AX = XMS version , BX = driver revision number    }
                   {  DX = 1 if HMA exists, 0 if not.                   }
END;{XMSVer}

FUNCTION XMSRev :WORD; ASSEMBLER;
                { Returns XMS Revision Number. Usually used with XMSVer.}
ASM
  Push BX                       {  Save BX.                             }
  Mov AH,0                      {  Function to return XMS revision.     }
  Call [XMSControl]             {  Call XMS Api.                        }
  Mov AX,BX                     {  Move result into proper register.    }
  Pop BX                        {  Restore BX.                          }
END;{XMSRev}

FUNCTION XMSGetFreeMem :WORD; ASSEMBLER;
                   {  Routine to Determine how much total XMS memory is }
                   {  free.                                             }
ASM
  Push DX                       {  Save DX and BX.                      }
  Push BX
  Mov XMSError,0                {  Clear error flag.                    }
  Mov AH,$08                    {  Function to get free XMS mem         }
  Call [XMSControl]             {  Call XMS Api                         }
  Mov XMSError,BL               {  Return any error code to user.       }
  Mov AX,DX                     {  Load AX with Total Free k'S          }
  Pop BX                        {  Restore BX and DX.                   }
  Pop DX
                   {  DX = Total Free in k's                            }
                   {  AX = Largest free block in k's                    }
                   {  BL = Err Code.                                    }
END;{XMSGetFreeMem}

FUNCTION XMSGetLargeBlock :WORD; ASSEMBLER;
                   {  Routine to Determine the size of the largest free }
                   {  XMS is block.                                     }
ASM
  Push BX                       {  Save BX.                             }
  Mov XMSError,0                {  Clear error flag.                    }
  Mov AH,$08                    {  Function to get free XMS mem         }
  Call [XMSControl]             {  Call XMS Api                         }
  Mov XMSError,BL               {  Return any error code to user.       }
  Pop BX                        {  Restore BX.                          }
                   {  DX = Total Free in k's                            }
                   {  AX = Largest free block in k's                    }
END;{XMSGetLargeBlock}

FUNCTION XMSGetMem( Blocks:WORD ) :WORD; ASSEMBLER;
                    {  Routine to allocate XMS for programs use         }
                    {  Blocks = k's being requested, XMSErr = ErrorCode }
                    {  Returns 16 bit handle to mem allocated           }
ASM
  Push DX                       {  Save DX and BX.                      }
  Push BX
  Mov XMSError,0                {  Clear error flag.                    }
  Mov AH,9                      {  Function Allocate Extended Memory    }
  Mov DX,Blocks                 {  Load k Blocks to be allocated        }
  Call [XMSControl]             {  Call XMS API                         }
  Mov XMSError,BL               {  Return any error code to user.       }
  Mov AX,DX                     {  Load 16 Bit Handle to allocated Mem  }
  Pop BX                        {  Restore BX and DX.                   }
  Pop DX
         {NOTE: If there was an Error then the handle is invalid. }
END;{XMSGetMem}

PROCEDURE XMSFreeMem( Handle:WORD ); ASSEMBLER;
                    {  Routine to free previously allocated XMS Memory  }
ASM
  Push DX                       {  Save DX and BX.                      }
  Push BX
  Mov XMSError,0                {  Clear error flag.                    }
  Mov AH,$0A                    {  Function Free Allocated Memory       }
  Mov DX,Handle                 {  Load Handle of Memory to free        }
  Call [XMSControl]             {  Call API                             }
  Mov XMSError,BL               {  Return any error code to user.       }
  Pop BX                        {  Restore BX and DX.                   }
  Pop DX
END;{XMSFreeMem}

PROCEDURE XMSMoveblock( VAR Movstruct :XMSMovStruct ); ASSEMBLER;
         {  Routine to move memory blocks around in XMS memory.         }
         {  Length must be even.                                        }
ASM
  Push DS                       {  Save DS and SI                       }
  Push SI
  Push BX
  Mov XMSError,0                {  Clear error flag.                    }
  LDS SI,MovStruct              {  Point DS:SI to move Structure        }
  Mov AH,$0B                    {  Function to Move Extended memory block}
  Call [XMSControl]             {  Call XMS API                         }
  Mov XMSError,BL               {  Save any error code for user.        }
  Pop BX
  Pop SI                        {  Restore DS and SI                    }
  Pop DS
END;{XMSMoveBlock}

PROCEDURE XMSLockBlock( Handle :WORD ); ASSEMBLER;
                        { Routine to lock and XMS block. Locked blocks  }
                        { are guarnteed not to move.                    }
                        { Locked Blocks should be unlocked as soon as   }
                        { possible.                                     }
ASM
  Push DX                       {  Save DX and BX.                      }
  Push BX
  Mov XMSError,0                {  Clear Error Flag.                    }
  Mov AH,$0C                    {  Function to lock XMS Block.          }
  Mov DX,Handle                 {  Handle of block to lock.             }
  Call [XMSControl]             {  Call XMS Api.                        }
  Mov XMSError,BL               {  Save any error codes.                }
  Pop BX                        {  Restore BX and DX.                   }
  Pop DX
END;{XMSLockBlock}

PROCEDURE XMSUnLockBlock( Handle :WORD ); ASSEMBLER;
                        { Routine to unlock a previously lock XMS block.}
ASM
  Push DX                       {  Save DX and BX.                      }
  Push BX
  Mov XMSError,0                {  Clear Error Flag.                    }
  Mov AH,$0D                    {  Function to unlock XMS Block.        }
  Mov DX,Handle                 {  Handle of block to unlock.           }
  Call [XMSControl]             {  Call XMS Api.                        }
  Mov XMSError,BL               {  Save any error codes.                }
  Pop BX                        {  Restore BX and DX.                   }
  Pop DX
END;{XMSUnLockBlock}

PROCEDURE XMSReallocate( Handle ,NewSize :WORD ); ASSEMBLER;
                        { Routine to reallocate and XMS Block so that it}
                        { becomes equal to NewSize.                     }
ASM
  Push DX                       {  Save DX and BX.                      }
  Push BX
  Mov XMSError,0                {  Clear Error Flag.                    }
  Mov BX,NewSize                {  Load New size of XMS Block.          }
  Mov DX,Handle                 {  Handle of an unlocked XMS Block.     }
  Mov AH,$0F                    {  Function to Reallocate XMS Block.    }
  Mov DX,Handle                 {  Handle of block to lock.             }
  Call [XMSControl]             {  Call XMS Api.                        }
  Mov XMSError,BL               {  Save any error codes.                }
  Pop BX                        {  Restore BX and DX.                   }
  Pop DX
END;{XMSReallocate}

FUNCTION HMAExists :BOOLEAN; ASSEMBLER;
                {  This routine returns Whether or not HMA Exists       }
ASM
  Push DX                       {  Save DX.                             }
  Mov AH,0                      {  Function to return HMA Status        }
  Call [XMSControl]             {  Call XMS Api                         }
  Mov AL,DL                     {  Mov Status into proper register      }
  Pop DX                        {  Restore DX.                          }
                   {  Possible returns are :                            }
                   {  AX = XMS version , BX = driver revision number    }
                   {  DX = 1 if HMA exists, 0 if not                    }
END;{HMAExists}

PROCEDURE HMARequest( RequestType :WORD ); ASSEMBLER;
                   { Attempt to reserve the 64k HMA area for the caller.}
                   { NOTE: RequestType must be either FFFF = Application}
                   { OR If caller is a TSR the RequestType = Amount of  }
                   { Space wanted.                                      }
ASM
  Push DX                       {  Save DX.                             }
  Push BX
  Mov AH,1                      {  Function to request HMA.             }
  Mov XMSError,0                {  Clear error flag.                    }
  Mov DX,RequestType            {  Load whether area is for an App or TSR.}
  Call [XMSControl]             {  Call XMS API                         }
  Mov XMSError,BL               {  Return any error code to user.       }
  Pop Bx
  Pop DX                        {  Restore DX.                          }
END;{HMARequest}

PROCEDURE HMARelease; ASSEMBLER;
                      { Routine to release previously allocated HMA.    }
                      { NOTE: Any Code/Data store in that HMA Memory    }
                      { Will become invalid and inaccessible.           }
ASM
  Push DX                       {  Save DX.                             }
  Mov AH,2                      {  Function to release HMA.             }
  Mov XMSError,0                {  Clear error flag.                    }
  Call [XMSControl]             {  Call XMS API                         }
  Mov XMSError,BL               {  Return any error code to user.       }
  Pop DX                        {  Restore DX.                          }
END;{HMARelease}

PROCEDURE GlobaleEnableA20; ASSEMBLER;
                     { Routine to Enable the A20 Line. Should only be   }
                     { used by programs that have control of the HMA.   }
                     { NOTE: Remeber to disable the Line before         }
                     {       releaseing control of the system.          }
ASM
  Push BX                       { Push BX onto the Stack.               }
  Mov XMSError,0                { Clear Error flag.                     }
  Mov AH,3                      { Function to Enable A20 line.          }
  Call [XMSControl]             { Call XMS Api.                         }
  Mov XMSError,BL               { Save any errors.                      }
  Pop BX                        { Pop BX Off the Stack.                 }
END;{GlobalEnableA20}

PROCEDURE GlobaleDisableA20; ASSEMBLER;
                      { Routine to Disable the A20 Line. On some systems}
                      { the Toggling of the A20 Line can take a long    }
                      { time.                                           }
ASM
  Push BX                       { Push BX onto the Stack.               }
  Mov XMSError,0                { Clear Error flag.                     }
  Mov AH,4                      { Function to Disable A20 line.         }
  Call [XMSControl]             { Call XMS Api.                         }
  Mov XMSError,BL               { Save any errors.                      }
  Pop BX                        { Pop BX Off the Stack.                 }
END;{GlobalDisableA20}

PROCEDURE LocalEnableA20; ASSEMBLER;
                     { Routine to Enable the A20 Line for current Program}
                     { NOTE: Rember to so a LocalDisableA20 before      }
                     {       releasing system control.                  }
ASM
  Push BX                       { Push BX onto the Stack.               }
  Mov XMSError,0                { Clear Error flag.                     }
  Mov AH,5                      { Function to Enable A20 line.          }
  Call [XMSControl]             { Call XMS Api.                         }
  Mov XMSError,BL               { Save any errors.                      }
  Pop BX                        { Pop BX Off the Stack.                 }
END;{LocalEnableA20}

PROCEDURE LocalDisableA20; ASSEMBLER;
                      { Routine to Locally Disable the A20 Line.        }
ASM
  Push BX                       { Push BX onto the Stack.               }
  Mov XMSError,0                { Clear Error flag.                     }
  Mov AH,6                      { Function to Disable A20 line.         }
  Call [XMSControl]             { Call XMS Api.                         }
  Mov XMSError,BL               { Save any errors.                      }
  Pop BX                        { Pop BX Off the Stack.                 }
END;{LocalDisableA20}

FUNCTION QueryA20 :BOOLEAN; ASSEMBLER;
                     { Routine to test whether the A20 is Physically    }
                     { enabled or not.                                  }
ASM
  Push BX                       { Push BX onto the Stack.               }
  Mov XMSError,0                { Clear Error flag.                     }
  Mov AH,7                      { Function to test the A20 line.        }
  Call [XMSControl]             { Call XMS Api.                         }
  Mov XMSError,BL               { Save any errors.                      }
  Pop BX                        { Pop BX Off the Stack.                 }
END;{QueryA20}

FUNCTION PtrToLong( P:POINTER ) :LONGINT; ASSEMBLER;
                     { Routine to convert a pointer to a 32 bit number. }
ASM
  Mov AX,P.WORD[0]                 { Load low WORD into AX.             }
  Mov DX,P.WORD[2]                 { Load high WORD into DX.            }
END;{PtrToLong}

BEGIN
END.

{---------------------------- CUT HERE FOR DEMO -------------------}
{***********************************************************************}
PROGRAM XMSDemo1;            { Demonstration of the XMS Unit.           }
                             { Last Updated Dec 10/93, Greg Estabrooks. }
USES CRT,                    { IMPORT Clrscr,Writeln.                   }
     XMS;                    { IMPORT XMSDriver,XMSVer,XMSGetFreeMem,   }
                             { XMSGetLargeBlock,XMSGetMem,XMSMove,      }
                             { XMSError,XMSMovStruct,XMSFreeMem.        }
VAR
   XMSHandle  :WORD;            { Holds the handle of our XMS Area.     }
   MovInf     :XMSMovStruct;    { Move Structure for Moving XMS Blocks. }
BEGIN
  Clrscr;                       { Clear away any screen clutter.        }
  IF XMSDriver THEN             { If XMS Driver installed do demo.      }
  BEGIN
    Write('XMS Driver Version ');   { Show Version Installed.           }
    Writeln(HI(XMSVer),'.',LO(XMSVer),'.',XMSRev,' Installed');
    Writeln('Total Free XMS Memory : ',XMSGetFreeMem,'k');
    Writeln('Largest Free XMS Block: ',XMSGetLargeBlock,'k');
    Writeln;

    Writeln('Attempting to Allocate 16k of XMS');
    XMSHandle := XMSGetMem(16); { Attempt to allocate 16k of XMS.       }
    Writeln('ErrorCode Returned : ',XMSError);
    Writeln('Current free XMS Memory : ',XMSGetFreeMem);
    Writeln;

    Writeln('Saving Screen to XMS.');
    WITH MovInf DO
      BEGIN
        Amount := 4000;         { Length of the Video Screen.           }
        SourceHandle := 0;      { If SourceHandle is 0 then SourceOffset}
                                { Is Interpereted as a SEGMENT:OFFSET   }
                                { into conventional memory.             }
        SourceOffset := PtrToLong(Ptr($B800,0));
        DestHandle := XMSHandle;{ Destination is our XMS block.         }
        DestOffset := 0;
      END;
    XMSMoveBlock(MovInf);
    Writeln('Press <ENTER> to continue.');
    Readln;

    Clrscr;
    Writeln('Press <ENTER> to Restore Screen.');
    Readln;

    WITH MovInf DO
      BEGIN
        Amount := 4000;         { Length of the Video Screen.           }
        SourceHandle := XMSHandle;
        SourceOffset := 0;
        DestHandle := 0;
        DestOffset := PtrToLong(Ptr($B800,0));;
      END;
    XMSMoveBlock(MovInf);
    GotoXY(1,11);
    XMSFreeMem(XMSHandle);      { Free allocate XMS.                    }
    Writeln('Ending Free XMS Memory : ',XMSGetFreeMem,'k');
  END
  ELSE
    Writeln('XMS Driver not Installed!',^G);
  Readln;
END.{XMSDemo1}
{***********************************************************************}