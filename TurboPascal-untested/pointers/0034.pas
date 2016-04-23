
1) use pointer
2) use XMS or EMS


1) Pointer
***************************************


Type                      {**}
          Data = Array[1..2000] of Real;   { Data size must not exceed 64K }
          DataPtr = ^Data;
Const
          MaxVar = 20;        { Value of MaxVar can be anything }
                              { but you must have sufficient heap memory }
                              {                   ^^^^^^^^^^^^^^^^^^^^^^ }
Var
          Variable :Array[1..MaxVar] of DataPtr;


PROCEDURE AllocateVar;
Var
          i      :Word;
Begin
  If MaxAvail >= MaxVar*6*2000 Then     { Check Heap before allocate }
    For i := 1 to MaxVar do
      New (Variable[i])
  Else Begin
    Writeln ('This progam requir memory more ',MaxVar*6*2000-MaxAvail);
    Halt (1)
  End
End;


PROCEDURE ReleaseVar;
Var
          i      :Word;
Begin
  For i := 1 to MaxVar do
    Dispose (Variable[i])
End;


Begin
  AllocateVar;
  .
  .

         Usage Variable :-

         Variable[Range1]^[Range2] := Real_Data;
                   /|\      /|\
     1-MaxVar_______|        |______ 1-2000 follow upper declaration {**}

     Ex.
             For i := 1 to MaxVar do
                For j := 1 to 2000 do
                  Variable[i]^[j] := 0;
  .
  .
  ReleaseVar;
End.

--------------------------------------------------

2) Use XMS
***********************************



( this is include file xms.inc )
		       ^^^^^^^	

Const
      ERR_NOERR          = $00;         { No error                         }
      ERR_NOTIMPLEMENTED = $80;         { SpecIfied FUNCTION not known     }
      ERR_VDISKFOUND     = $81;         { VDISK-RAMDISK detected           }
      ERR_A20            = $82;         { Error at handler A20             }
      ERR_GENERAL        = $8E;         { General driver error             }
      ERR_UNRECOVERABLE  = $8F;         { Unrecoverable error              }
      ERR_HMANOTEXIST    = $90;         { HMA does not exist               }
      ERR_HMAINUSE       = $91;         { HMA already in use               }
      ERR_HMAMINSIZE     = $92;         { Not enough space in HMA          }
      ERR_HMANOTALLOCED  = $93;         { HMA not allocated                }
      ERR_A20STILLON     = $94;         { Handler A20 still on             }
      ERR_OUTOMEMORY     = $A0;         { Out of extEnded memory           }
      ERR_OUTOHANDLES    = $A1;         { All XMS handles in use           }
      ERR_INVALIDHANDLE  = $A2;         { Invalid handle                   }
      ERR_SHINVALID      = $A3;         { Source handle invalid            }
      ERR_SOINVALID      = $A4;         { Source offset invalid            }
      ERR_DHINVALID      = $A5;         { Destination handle invalid       }
      ERR_DOINVALID      = $A6;         { Destination offset invalid       }
      ERR_LENINVALID     = $A7;         { Invalid length for move FUNCTION }
      ERR_OVERLAP        = $A8;         { Illegal overlapping              }
      ERR_PARITY         = $A9;         { Parity error                     }
      ERR_EMBUNLOCKED    = $AA;         { UMB is unlocked                  }
      ERR_EMBLOCKED      = $AB;         { UMB is still locked              }
      ERR_LOCKOVERFLOW   = $AC;         { Overflow of UMB lock counter     }
      ERR_LOCKFAIL       = $AD;         { UMB cannot be locked             }
      ERR_UMBSIZETOOBIG  = $B0;         { Smaller UMB available            }
      ERR_NOUMBS         = $B1;         { No more UMB available            }
      ERR_INVALIDUMB     = $B2;         { Invalid UMB segment address      }

Type
      XMSRegs = record                  { Information for XMS call         }
                 AX,                    { Only registers AX, BX, DX and SI }
                 BX,                    { required, depEnding on called    }
                 DX,                    { FUNCTION along With a segment    }
                 SI,                    { address                          }
                 Segment :Word
      End;

Var
      XMSPtr :Pointer;      { Pointer to the extEnded memory manager (XMM) }
      XMSErr :Byte;         { Error code of the last operation             }

{**********************************************************************
* XMSInitOk : Initializes the routines for calling the XMS FUNCTIONs  *
**-------------------------------------------------------------------**
* Input   : None                                                      *
* Output  : TRUE, If an XMS driver was discovered, otherwise FALSE    *
* Info    : - The call of this FUNCTION must precede calls of all     *
*             all other PROCEDUREs and FUNCTIONs from this program.   *
**********************************************************************}

FUNCTION XMSInitOk :Boolean;
Var
        Regs :Registers;
        XR   :XMSRegs;

Begin
  Regs.AX := $4300;               { Determine availability of XMS manager }
  Intr ($2F,Regs);
  If (Regs.AL = $80) Then         { XMS manager found?                    }
    Begin                         { Yes                                   }
      Regs.AX := $4310;           { Determine entry point of XMM          }
      Intr ($2F,Regs);
      XMSPtr := ptr (Regs.ES,Regs.BX);      { Store address in glob. Var. }
      XMSErr := ERR_NOERR;                  { Still no error found        }
      XMSInitOk := true;              { Handler found, module initialized }
    End
  Else                                { No XMS handler installed }
   XMSInitOk := false
End;

{**********************************************************************
* XMSCall : General routine for calling an XMS FUNCTION               *
**-------------------------------------------------------------------**
* Input   : FctNo = Number of XMS FUNCTION to be called               *
*           XRegs = Structure With registers for FUNCTION call        *
* Info    : - Before calling this PROCEDURE, only those registers     *
*             can be loaded that are actually required for calling    *
*             the specIfied FUNCTION.                                 *
*           - After the XMS FUNCTION call, the contents of the        *
*             Various processor registers are copied to the           *
*             corresponding components of the passed structure.       *
*           - Before calling this PROCEDURE for the first time, the   *
*             XMSInit must be called successfully.                    *
**********************************************************************}

PROCEDURE XMSCall (FctNr :Byte; Var XRegs :XMSRegs);
Begin
  inline ( $8C / $D9 /                              { mov    cx,ds        }
           $51 /                                    { push   cx           }
           $C5 / $BE / $04 / $00 /                  { lds    di,[bp+0004] }
           $8A / $66 / $08 /                        { mov    ah,[bp+0008] }
           $8B / $9D / $02 / $00 /                  { mov    bx,[di+0002] }
           $8B / $95 / $04 / $00 /                  { mov    dx,[di+0004] }
           $8B / $B5 / $06 / $00 /                  { mov    si,[di+0006] }
           $8E / $5D / $08 /                        { mov    ds,[di+08]   }
           $8E / $C1 /                              { mov    es,cx        }
           $26 / $FF / $1E / XMSPtr /               { call   es:[XMSPTr]  }
           $8C / $D9 /                              { mov    cx,ds        }
           $C5 / $7E / $04 /                        { lds    di,[bp+04]   }
           $89 / $05 /                              { mov    [di],ax      }
           $89 / $5D / $02 /                        { mov    [di+02],bx   }
           $89 / $55 / $04 /                        { mov    [di+04],dx   }
           $89 / $75 / $06 /                        { mov    [di+06],si   }
           $89 / $4D / $08 /                        { mov    [di+08],cx   }
           $1F                                      { pop    ds           }
        );

  {-- Test for error code --------------------------------------------}

  If (XRegs.AX = 0) and (XRegs.BX >= 128) Then
    Begin
      XMSErr := Lo(XRegs.BX)                    { Error, store error code }
      {
       .
       .
       .
         Another error handling routine could follow here
       .
       .
       .
      }
    End
  Else
    XMSErr := ERR_NOERR                                { No error, all ok }
End;

{**********************************************************************
* XMSQueryVer: Returns the XMS version number and other status        *
*              information                                            *
**-------------------------------------------------------------------**
* Input   : VerNr = Gets the version number after the FUNCTION call   *
*                   (Format: 235 = 2.35)                              *
*           RevNr = Gets the revision number after the FUNCTION call  *
* Output  : TRUE, If HMA is available, otherwise FALSE                *
**********************************************************************}

PROCEDURE XMSQueryVerHMA (Var VerNr,RevNr :Integer; Var HMA :Boolean);
Var
        XR :XMSRegs;               { Registers for communication With XMS }

Begin
  XmsCall (0,XR);
  VerNr := Hi(XR.AX)*100 + (Lo(XR.AX) shr 4) * 10 + (Lo(XR.AX) and 15);
  RevNr := Hi(XR.BX)*100 + (Lo(XR.BX) shr 4) * 10 + (Lo(XR.BX) and 15);
  HMA := (XR.DX = 1)
End;

{**********************************************************************
* XMSGetHMA : Returns right to access the HMA to the caller.          *
**-------------------------------------------------------------------**
* Input   : LenB = Number of bytes to be allocated                    *
* Info    : TSR programs should only request the memory size that     *
*           they actually require, while applications should specIfy  *
*           the value $FFFF.                                          *
* Output  : TRUE, If the HMA could be made available,                 *
*           otherwise FALSE;                                          *
**********************************************************************}

FUNCTION XMSGetHMA (LenB :Word) :Boolean;
Var
         XR :XMSRegs;

Begin
  XR.DX := LenB;                             { Pass length in DX register }
  XmsCall (1,XR);                            { Call XMS FUNCTION #1       }
  XMSGetHMA := (XMSErr = ERR_NOERR)
End;

{**********************************************************************
* XMSReleaseHMA : Releases the HMA, making it possible to pass        *
*                 to other programs.                                  *
**-------------------------------------------------------------------**
* Input   : None                                                      *
* Info    : - Call this PROCEDURE before Ending a program If the      *
*             HMA was allocated beforehand through a call for         *
*             XMSGetHMA, because otherwise the HMA cannot be passed   *
*             to any programs called afterwards.                      *
*           - Calling this PROCEDURE causes the data stored in HAM    *
*             to be lost.                                             *
**********************************************************************}

PROCEDURE XMSReleaseHMA;
Var
          XR :XMSRegs;        { Call registers for communication With XMS }

Begin
  XmsCall (2,XR)              { Call XMS FUNCTION #2 }
End;

{**********************************************************************
* XMSA20OnGlobal: Switches on the A20 handler, making direct access   *
*                 to the HMA possible.                                *
**-------------------------------------------------------------------**
* None    : None                                                      *
* Info    : - For many computers, switching on the A20 handler is a   *
*             relatively time-consuming process. Only call this       *
*             PROCEDURE when it is absolutely necessary.              *
**********************************************************************}

PROCEDURE XMSA20OnGlobal;
Var
          XR :XMSRegs;             { Registers for communication With XMS }

Begin
  XmsCall (3,XR)                   { Call XMS FUNCTION #3 }
End;

{**********************************************************************
* XMSA20OffGlobal: A counterpart to the XMSA20OnGlobal PROCEDURE,     *
*                  this PROCEDURE switches the A20 handler back off,  *
*                  so that direct access to the HMA is no longer      *
*                  possible.                                          *
**-------------------------------------------------------------------**
* Input   : None                                                      *
* Info    : - Always call this PROCEDURE before Ending a program,     *
*             in case the A20 handler was switched on before via a    *
*             a call for XMSA20OnGlobal.                              *
**********************************************************************}

PROCEDURE XMSA20OffGlobal;
Var
          XR :XMSRegs;             { Registers for communication With XMS }

Begin
  XmsCall (4,XR)                   { Call XMS FUNCTION #4 }
End;

{**********************************************************************
* XMSA20OnLocal: See XMSA20OnGlobal                                   *
**-------------------------------------------------------------------**
* Input   : None                                                      *
* Info    : - This local PROCEDURE dIffers from the global PROCEDURE  *
*             in that it only switches on the A20 handler If it       *
*             hasn't already been called.                             *
**********************************************************************}

PROCEDURE XMSA20OnLocal;
Var
          XR :XMSRegs;             { Registers for communication With XMS }

Begin
  XmsCall (5,XR )                  { Call XMS FUNCTION #5 }
End;

{**********************************************************************
* XMSA20OffLocal : See XMSA29OffGlobal                                *
**-------------------------------------------------------------------**
* Input   : None                                                      *
* Info    : - This local PROCEDURE only dIffers from the global       *
*             PROCEDURE in that the A20 handler is only switched      *
*             off If hasn't already happened through a previous       *
*             call.                                                   *
**********************************************************************}

PROCEDURE XMSA20OffLocal;
Var
          XR :XMSRegs;             { Registers for communication With XMS }

Begin
  XmsCall (6,XR)                   { Call XMS FUNCTION #6 }
End;

{**********************************************************************
* XMSIsA20On : Returns the status of the A20 handler                  *
**-------------------------------------------------------------------**
* Input   : None                                                      *
* Output  : TRUE, If A20 handler is on, otherwise FALSE.              *
*           FALSE.                                                    *
**********************************************************************}

FUNCTION XMSIsA20On :Boolean;
Var
         XR :XMSRegs;              { Registers for communication With XMS }

Begin
  XmsCall (7,XR);                  { Call XMS FUNCTION #7        }
  XMSIsA20On := (XR.AX = 1)        { AX = 1 ---> Handler is free }
End;

{**********************************************************************
* XMSQueryFree : Returns the size of free extended memory and the     *
*                largest free block                                   *
**-------------------------------------------------------------------**
* Input   : TotFree: Gets the total size of free extended memory.     *
*           MaxBl  : Gets the size of the largest free block.         *
* Info    : - Both specIfications in kilobytes.                       *
*           - The size of the HMA is not included in the count,       *
*             even If it hasn't yet been assigned to a program.       *
**********************************************************************}

PROCEDURE XMSQueryFree (Var TotFree, MaxBl :Integer);
Var
          XR :XMSRegs;             { Registers for communication With XMS }

Begin
  XmsCall (8,XR);                  { Call XMS FUNCTION #8 }
  TotFree := XR.AX;                { Total size in AX     }
  MaxBl   := XR.DX                 { Free memory in DX    }
End;

{**********************************************************************
* XMSGetMem : Allocates an extended memory block (EMB)                *
**-------------------------------------------------------------------**
* Input   : LenKB : Size of requested block in kilobytes              *
* Output  : Handle for further access to block or 0, If no block      *
*           can be allocated. The appropriate error code would        *
*           also be in the global Variable, XMSErr.                   *
**********************************************************************}

PROCEDURE XMSGetMem (LenKb :Integer; Var Handle :Integer);
Var
         XR :XMSRegs;              { Registers for communication With XMS }

Begin
  XR.DX := LenKB;                  { Length passed in DX register }
  XmsCall (9,XR);                  { Call XMS FUNCTION #9         }
  Handle := XR.DX                  { Return handle                }
End;

{**********************************************************************
* XMSFreeMem : Releases previously allocated extEnded memory block    *
*              (EMB).                                                 *
**-------------------------------------------------------------------**
* Input   : Handle : Handle for access to the block returned when     *
*                    XMSGetMem was called.                            *
* Info    : - The contents of the EMB are irretrievably lost and      *
*             the handle becomes invalid when you call this PROCEDURE.*
*           - Before Ending a program, use this PROCEDURE to release  *
*             all allocated memory areas, so that they can be         *
*             allocated for the next program to be called.            *
**********************************************************************}

PROCEDURE XMSFreeMem (Handle :Integer);
Var
          XR :XMSRegs;             { Registers for communication With XMS }

Begin
  XR.DX := Handle;                 { Handle passed in DX register }
  XmsCall (10,XR)                  { Call XMS FUNCTION #10        }
End;

{**********************************************************************
* XMSCopy : Copies memory areas between extEnded memory and           *
*           conventional memory or Within the two memory groups.      *
**-------------------------------------------------------------------**
* Input   : FrmHandle  : Handle of memory area to be copied.          *
*           FrmOffset  : Offset in block being copied.                *
*           ToHandle   : Handle of memory area to which memory is     *
*                        being copied.                                *
*           ToOffset   : Offset in the target block.                  *
*           LenW       : Number of words to be copied.                *
* Info    : - To include normal memory in the operation, 0 must be    *
*             specIfied as the handle and the segment and offset      *
*             address must be specIfied as the offset in the usual    *
*             form (offset before segment).                           *
**********************************************************************}

PROCEDURE XMSCopy (FrmHandle :Integer; FrmOffset :LongInt;
                   ToHandle :Integer; ToOffset :LongInt; LenW :LongInt);
Type
          EMMS = record               { An extEnded memory move structure }
            LenB    :LongInt;         { Number of bytes to be moved       }
            SHandle :Integer;         { Source handle                     }
            SOffset :LongInt;         { Source offset                     }
            DHandle :Integer;         { Destination handle                }
            DOffset :LongInt;         { Destination offset                }
          End;

Var
          XR :XMSRegs;             { Registers for communication With XMS }
          Mi :EMMS;                { Gets EEMS                            }

Begin
  With Mi do                       { Prepare EMMS first }
    Begin
      LenB := 2 * LenW;
      SHandle := FrmHandle;
      SOffset := FrmOffset;
      DHandle := ToHandle;
      DOffset := ToOffset
    End;
  XR.Si := Ofs(Mi);               { Offset address of EMMS  }
  XR.Segment := Seg(Mi);          { Segment address of EMMS }
  XmsCall (11,XR)                 { Call XMS FUNCTION #11   }
End;

{**********************************************************************
* XMSLock : Locks an extEnded memory block from being moved by the    *
*           XMM, returning its absolute address at the same time.     *
**-------------------------------------------------------------------**
* Input   : Handle : Handle of memory area returned during a prev-    *
*                    ious call by XMSGetMem.                          *
* Output  : The linear address of the block of memory.                *
**********************************************************************}

FUNCTION XMSLock (Handle :Integer) :LongInt;
Var
         XR :XMSRegs;              { Registers for communication With XMS }

Begin
  XR.DX := Handle;                            { Handle of EMB          }
  XmsCall (12,XR);                            { Call XMS FUNCTION #12  }
  XMSLock := longint (XR.DX) shl 16 + XR.BX   { Compute 32 bit address }
End;

{**********************************************************************
* XMSUnlock : Releases a locked extEnded memory block again.          *
**-------------------------------------------------------------------**
* Input   : Handle : Handle of memory area returned during a prev-    *
*                    ious call by XMSGetMem.                          *
**********************************************************************}

PROCEDURE XMSUnLock (Handle :Integer);

Var
          XR :XMSRegs;             { Registers for communication With XMS }

Begin
  XR.DX := Handle;                 { Handle of EMB         }
  XmsCall (13,XR);                 { Call XMS FUNCTION #13 }
End;

{**********************************************************************
* XMSQueryInfo : Gets Various information about an extEnded memory    *
*                block that has been allocated.                       *
**-------------------------------------------------------------------**
* Input   : Handle : Handle of memory area                            *
*           Lock   : Variable, in which the lock counter is entered   *
*           LenKB  : Variable, in which the length of the block is    *
*                    entered in kilobytes                             *
*           FreeH  : Number of free handles                           *
* Info    : You cannot use this PROCEDURE to find out the start       *
*           address of a memory block, use the XMSLock FUNCTION       *
*           instead.                                                  *
**********************************************************************}

PROCEDURE XMSQueryInfo (Handle :Integer; Var Lock, LenKB :Integer;
                        Var FreeH :Integer);
Var
          XR :XMSRegs;             { Registers for communication With XMS }

Begin
  XR.DX := Handle;                 { Handle of EMB         }
  XmsCall( 14, XR );               { Call XMS FUNCTION #14 }
  Lock  := Hi( XR.BX );            { Evaluate register     }
  FreeH := Lo( XR.BX );
  LenKB := XR.DX
End;

{**********************************************************************
* XMSRealloc : Enlarges or shrinks an extEnded memory block prev-     *
*              iously allocated by XMSGetMem                          *
**-------------------------------------------------------------------**
* Input   : Handle   : Handle of memory area                          *
*           NewLenKB : New length of memory area in kilobytes         *
* Output  : TRUE, If the block was resized, otherwise FALSE           *
* Info    : The specIfied block cannot be locked!                     *
**********************************************************************}

FUNCTION XMSRealloc (Handle, NewLenKB :Integer) :Boolean;
Var
         XR :XMSRegs;              { Registers for communication With XMS }

Begin
  XR.DX := Handle;                        { Handle of EMB                 }
  XR.BX := NewLenKB;                      { New length in the BX register }
  XmsCall (15,XR);                        { Call XMS FUNCTION #15         }
  XMSRealloc := (XMSErr = ERR_NOERR)
End;

{**********************************************************************
* XMSGetUMB : Allocates an upper memory block (UMB).                  *
**-------------------------------------------------------------------**
* Input   : LenPara : Size of area to be allocated in paragraphs      *
*                     of 16 bytes each                                *
*           Seg     : Variable that gets the segment address of       *
*                     the allocated UMB in successful cases           *
*           MaxPara : Variable that specIfies the length of the       *
*                     largest available UMB in unsuccessful cases     *
* Output  : TRUE, If a UMB could be allocated, otherwise FALSE        *
* Info    : Warning! This FUNCTION is not supported by all XMS        *
*                    drivers and is extremely hardware-depEndent.     *
**********************************************************************}

FUNCTION XMSGetUMB (LenPara :Integer; Var Seg, MaxPara :Word) :Boolean;
Var
         XR :XMSRegs;              { Registers for communication With XMS }

Begin
  XR.DX := LenPara;                          { Desired length to      }
  XmsCall (16,XR);                           { Call XMS FUNCTION #16  }
  Seg := XR.BX;                              { Return segment address }
  MaxPara := XR.DX;                          { Length of largest UMB  }
  XMSGetUMB := (XMSErr = ERR_NOERR)
End;

{**********************************************************************
* XMSFreeUMB : Releases UMB previously allocated by XMSGetUMB.        *
**-------------------------------------------------------------------**
* Input   : Seg : Segment address of UMB being released               *
* Info    : Warning! This FUNCTION is not supported by all XMS        *
*                    drivers and is extremely hardware-depEndent.     *
**********************************************************************}

PROCEDURE XMSFreeUMB (Var Seg :Word);
Var
          XR :XMSRegs;              { Registers for communication wit XMS }

Begin
  XR.DX := Seg;                     { Segment address of UMB to DX }
  XmsCall (17,XR)                   { Call XMS FUNCTION #17        }
End;

FUNCTION XMSErrMsg (n :Byte) :String;
Begin
  Case n of
    $00 : XMSErrMsg := 'No error';
    $80 : XMSErrMsg := 'SpecIfied FUNCTION not known';
    $81 : XMSErrMsg := 'VDISK-RAMDISK detected';
    $82 : XMSErrMsg := 'Error at handler A20';
    $8E : XMSErrMsg := 'General driver error';
    $8F : XMSErrMsg := 'Unrecoverable error';
    $90 : XMSErrMsg := 'HMA does not exist';
    $91 : XMSErrMsg := 'HMA already in use';
    $92 : XMSErrMsg := 'Not enough space in HMA';
    $93 : XMSErrMsg := 'HMA not allocated';
    $94 : XMSErrMsg := 'Handler A20 still on';
    $A0 : XMSErrMsg := 'Out of extEnded memory';
    $A1 : XMSErrMsg := 'All XMS handles in use';
    $A2 : XMSErrMsg := 'Invalid handle';
    $A3 : XMSErrMsg := 'Source handle invalid';
    $A4 : XMSErrMsg := 'Source offset invalid';
    $A5 : XMSErrMsg := 'Destination handle invalid';
    $A6 : XMSErrMsg := 'Destination offset invalid';
    $A7 : XMSErrMsg := 'Invalid length for move FUNCTION';
    $A8 : XMSErrMsg := 'Illegal overlapping';
    $A9 : XMSErrMsg := 'Parity error';
    $AA : XMSErrMsg := 'UMB is unlocked';
    $AB : XMSErrMsg := 'UMB is still locked';
    $AC : XMSErrMsg := 'Overflow of UMB lock counter';
    $AD : XMSErrMsg := 'UMB cannot be locked';
    $B0 : XMSErrMsg := 'Smaller UMB available';
    $B1 : XMSErrMsg := 'No more UMB available';
    $B2 : XMSErrMsg := 'Invalid UMB segment address'
  End
End;


............................................................
This program below is example for upper include file.


Uses Dos,Crt,VKeys;

{$I VXMS.INC}

Type
        SampleData      = Array [1..64000] of Byte;
        ScreenType      = Array [0..200,0..319] of Byte;
        DataPtr         = ^SampleData;
        ScreenPtr       = ^ScreenType;
Const
        XMS_Require     = 1000;
Var
        XMS_Version,XMS_Revision              :Integer;
        HMA_Available                         :Boolean;
        Total_XMS_Free,XMS_Free_Max_Blk       :Integer;
        XMS_Handle                            :Integer;
        XMS_Start_Addr                        :LongInt;
        Data,Blank                            :DataPtr;
        Screen,DataTest                       :ScreenPtr;
        Ch                                    :Char;
        i,j                                   :Word;

Begin
  If XMSInitOk Then Begin
    Writeln ('XMS Driver detected');
    XMSQueryVerHMA (XMS_Version,XMS_Revision,HMA_Available);
    Writeln ('XMS Driver Version ',XMS_Version div 100,
             '.',XMS_Version mod 100);
    Writeln ('XMS Revision ',XMS_Revision div 100,'.',XMS_Revision mod 100);
    If HMA_Available Then Writeln ('HMA Available');
    XMSQueryFree (Total_XMS_Free,XMS_Free_Max_Blk);
    Dec (Total_XMS_Free,64);
    If XMS_Free_Max_Blk >= Total_XMS_Free Then Dec (XMS_Free_Max_Blk,64);
    Writeln ('XMS Largest free block ',XMS_Free_Max_Blk,' KByte(s)');
    If XMS_Free_Max_Blk < XMS_Require Then  Begin
      Writeln (#7,#13,#10,XMS_Require-XMS_Free_Max_Blk,' KByte(s) XMS memory ',
               'need more.');
      Halt (0)
    End
    Else Begin
      XMSGetMem (XMS_Require,XMS_Handle);
      Writeln ('XMS Allocated');
      XMS_Start_Addr := XMSLock (XMS_Handle);
      XMSUnLock (XMS_Handle);
      New (Data);
      New (Blank);
      For i := 1 to 64000 do Begin
        Data^[i] := (i-1) mod 255;
        Blank^[i] := 0;
      End;
      For i := 1 to Round(XMS_Require/(32000*2/1024)) do
        XMSCopy (0,Longint(Data),XMS_Handle,LongInt(i-1)*1024*50,32000);
      Screen := Ptr ($A000,0);
      New (DataTest);
      XMSCopy (0,LongInt(Data),0,LongInt(DataTest),32000);
      ASM MOV AX,13h; INT 10h End;
      Repeat
        XMSCopy (XMS_Handle,0,0,LongInt(Screen),32000);
        XMSCopy (0,LongInt(Blank),0,LongInt(Screen),32000);
      Until KeyPressed;
      ASM MOV AX,3; INT 10h End;
{      For i := 0 to 199 do
        For j := 0 to 319 do
          Write (DataTest^[i][j]:8);
      Ch := ReadKey;}
      XMSFreeMem (XMS_Handle)
    End
  End
  Else Begin
    Writeln (#7,#13,#10,'XMS Driver not load.')
  End
End.
