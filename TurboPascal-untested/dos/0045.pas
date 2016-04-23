{
 RL> I would like to open 20-50 silumtaneous files (in TP 6.0 or 7.0).

 RL> Does anyone know how to accomplish this?

I use the unit below for BP7 (protected mode or real mode).
}

Unit        Extend;

{-----------------------------------------------------------------------}
{  Author  : Michael John Phillips                                      }
{  Address : 5/5 Waddell Place                                          }
{            Curtin ACT 2605                                            }
{  Tel     : (06) 2811980h                                              }
{  FidoNet : 3:620/243.70                                               }
{-----------------------------------------------------------------------}
{
$lgb$
v1.0   22 Apr 93 -   Initial version works in REAL-MODE or DPMI mode BP7
$lge$
$nokeywords$
}
{-----------------------------------------------------------------------}
{    This unit contains routines to extend the number of files that     }
{  can simultaneously be open by a program under DOS.                   }
{                                                                       }
{    The NON-DPMI routine was downloaded from the Borland BBS and then  }
{  modified to work with TP7 and BP7.                                   }
{                                                                       }
{    The DPMI routine was captured in the Z3_PASCAL FidoNet echo.       }
{                                                                       }
{    To use these routines, make sure that your CONFIG.SYS files        }
{  contains the lines FILES=255.  If you use the DOS SHARE command      }
{  then make sure that you have enough memory allocated for SHARE       }
{  (eg SHARE /F:7168), having SHARE too low can result in a "hardware   }
{  failure" (IOResult=162) when trying to open a file.                  }
{-----------------------------------------------------------------------}
{    These routines extend the max. number of files that can be OPEN    }
{  simultaneously from 20 to 255.  Files in DOS 2.0 or later are        }
{  controlled by FILE handles.  The number of FILE handles available    }
{  to application programs is controlled by the FILES environment       }
{  variable stored in a CONFIG.SYS FILE.  If no FILES variable is       }
{  established in a CONFIG.SYS FILE, then only 8 FILE handles are       }
{  available.  However, DOS requires 5 FILE handles for its own use     }
{  (controlling  devices  such  as  CON, AUX, PRN, etc).  This leaves   }
{  only 3 handles for use by application programs.                      }
{                                                                       }
{    By specifying a value for the FILES environment variable, you can  }
{  increase the number of possible FILE handles from 8 up to 20.        }
{  Since DOS still requires 5, 15 are left for application programs.    }
{  But you cannot normally increase the number of handles beyond 20.    }
{                                                                       }
{    With DOS version 3.0, a new DOS function was added to increase     }
{  the number of FILE handles available.  However, the function must    }
{  be called from application programs that have previously reserved    }
{  space for the new FILE handles.                                      }
{-----------------------------------------------------------------------}
{$IFNDEF VER70 }
  Should be compiled using Turbo Pascal v7.0 or Borland Pascal v7.0
{$ENDIF }

Interface

Const
  MAX_FILE_HANDLES = 255;

  Function ExtendHandles(Handles : Byte) : Word;

Implementation

{$IFDEF MSDOS }
Uses
  Dos;                                         { Dos routines - BORLAND }
{$ENDIF }

{$IFDEF DPMI }
Uses
  Dos,                                         { Dos routines - BORLAND }
  WinAPI;                              { Windows API routines - BORLAND }
{$ENDIF }

Const
  NO_ERROR                = $00;
  ERROR_NOT_ENOUGH_MEMORY = $08;
  ERROR_HARDWARE_FAILURE  = $A2;

Var
  Result : Word;
  Regs : Registers;

{$IFDEF MSDOS }
  Function    ExtendHandles(Handles : Byte) : Word;
  {---------------------------------------------------------------------}
  {    This routine resizes the amount of allocated memory for a Turbo  }
  {  Pascal program to allow space for new FILE handles.  In doing so,  }
  {  it also resizes the heap by  adjusting the value of FreePtr, the   }
  {  pointer used in FreeList management.  Since the FreeList is being  }
  {  manipulated, the heap must be empty when the extend unit is        }
  {  initialized.  This can be guaranteed by including extend as one    }
  {  of the first units in your program's USES statement.  If any heap  }
  {  has been allocated when extend initializes, the program will halt  }
  {  with an error message.                                             }
  {---------------------------------------------------------------------}
  begin  { of ExtendHandles }
    ExtendHandles := NO_ERROR;

    {-------------------------------------------------------------------}
    {    Check that the number of file handles to extend to is greater  }
    {  than the default number of file handles (20).                    }
    {-------------------------------------------------------------------}
    if Handles <= 20 then
      Exit;

    {-------------------------------------------------------------------}
    {    Check that the heap used by Turbo Pascal is currently empty.   }
    {-------------------------------------------------------------------}
    if (HeapOrg <> HeapPtr) then
      begin
        Writeln('Heap must be empty before Extend unit initializes');
        Halt(1);
      end;

    {-------------------------------------------------------------------}
    {    Reduce the heap space used by Turbo Pascal.                    }
    {-------------------------------------------------------------------}
    HeapEnd:=ptr(Seg(HeapEnd^)-(Handles div 8 +1), Ofs(HeapEnd^));

    {-------------------------------------------------------------------}
    {    Determine how much memory is allocated to the program.  BX     }
    {  returns the number of paragraphs (16 bytes) used.                }
    {-------------------------------------------------------------------}
    with Regs do
      begin
        AH := $4A;
        ES := PrefixSeg;
        BX := $FFFF;
        MsDos(Regs);
      end;   { of with Regs }

    {-------------------------------------------------------------------}
    {    Set the program size to the allow for new handles.             }
    {-------------------------------------------------------------------}
    with Regs do
      begin
        AH := $4A;
        ES := PrefixSeg;
        BX := BX - (Handles div 8 + 1);
        MsDos(Regs);
      end;   { of with Regs }

END;
{$ENDIF}
END.