(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0032.PAS
  Description: Another XMS Unit
  Author: WILLIAM CONROY
  Date: 11-02-93  07:36
*)

{
JD3GTRCW.TRANSCOM@transcom.safb.af.mil (CONROY WILLIAM F)

I have seen numerous requests for XMS routines.  Here are some I have
written for a programming effort I headed.
Feel free to use in any way fit.
}

{$O+,F+}
UNIT XMSUnit;
{    Programmer:  Major William F. Conroy III                             }
{    Last Mod:    3/12/93                                                 }
{    Touched:     File date set to coorespond to baseline date            }
{                 for Computer Aided Aircrew Scheduling System            }
{                                                                         }
{ This unit is written to give access to the XMS memory Specification for }
{ the IBM PC.  Do not alter this unit without an excellent understanding  }
{ of the PC internal architecture, the Extended Memory Specification(XMS) }
{ and the Borland Inline Assembler.  For a much more in depth discussion  }
{ of the XMS memory standard and how to implement it on a PC class
  computer }
{ Refer to "Extending Dos" by Ray Duncan, Published by Addison Wesley     }

INTERFACE

TYPE
  PHandlePtrArray = ^THandlePtrArray;
  THandlePtrArray = ARRAY [1..10]OF WORD;
  {  This type definition is used by the graphics system as a way   }
  {  to dynamically allocate space to hold the handles required to  }
  {  access the extended memory.                                    }

  PXMSParamBlock  = ^TXMSParamBlock;
  TXMSParamBlock  = RECORD
    LengthOfBlock   : LONGINT;   { Size of block to move }
    SourceEMBHandle : WORD;
    { 0 if source is in conventional memory,       }
    { handle returned by AllocateEMB otherwise     }
    SourceOffset    : LONGINT;
    { if SourceEMBHandle= 0 SourceOffset contains  }
    { a far pointer in Intel standard format else  }
    { SourceOffset indicates offset from the base  }
    { of the block.                                }
    DestEMBHandle   : WORD;
    { 0 if source is in conventional memory,       }
    { handle returned by AllocateEMB otherwise     }
    DestOffset      : LONGINT;
    { if DestEMBHandle= 0 DestOffset contains      }
    { a far pointer in Intel standard format else  }
    { DestOffset indicates offset from the base    }
    { of the block.                                }
  END;
  { This type definition is used by the XMM memory manager for      }
  { block memory moves. As required by the xms specification.       }

VAR
  XMSExists : BOOLEAN;

  { Function AllocateEMB allocates an Extended Memory Block in Extended }
  { memory.  It requests the block via the Extended Memory Manager(XMM) }
  { It returns True if it was successful False otherwise.  If true, if  }
  { EMB_Handle will contain the Extended Memory Block Handle.  If       }
  {returning false, the errorcode is in the ErrorCode parameter.        }
FUNCTION AllocateEMB(VAR EMB_Handle, ParRequested, ErrorCode : WORD) : BOOLEAN;

  { Function FreeEMB releases an Extended Memory Block in Extended Memory }
  { allocated by the AllocateEMB function call.  It requests the XMM      }
  { remove the block.  It returns True if it was successful False         }
  { otherwise.  If true, if block was released correctly.  If returning   }
  { false, the errorcode is in the ErrorCode parameter.                   }
FUNCTION FreeEMB(VAR EMB_Handle, ErrorCode : WORD) : BOOLEAN;

  { Function MoveEMB allows memory tranfers between conventional and XMS  }
  { Memory.  This function requires a filled in TXMSParamBlock record.    }
  { It returns True if it was successful False otherwise.  If true, the   }
  { memory block was successfully moved.  If returning false, the         }
  { errorcode is in the ErrorCode parameter.                   }
FUNCTION MoveEMB(PParamBlock : PXMSParamBlock; VAR ErrorCode : WORD) : BOOLEAN;



IMPLEMENTATION

VAR
  XMMAddress        : POINTER;
  XMS_Version       : WORD;
  XMM_DriverVersion : WORD;
  HMA_Exists        : BOOLEAN;
  LastErrorCode     : WORD;


{---------------------------------------------------------------------------}
{                                                                         }
{                             Local Procedure                             }
{                            function XMSPresent                          }
{                                                                         }
{  This function return true if there is an Extended memory manager present }
{  in the system capable of supporting our XMS requests.  It uses a DOS   }
{  multiplexing interrupt request to determine if the driver signiture is }
{  present in the system.  This is the Microsoft recomended method of     }
{  determining the presence of this driver.                               }
{                                                                         }
{---------------------------------------------------------------------------}

FUNCTION XMSPresent : BOOLEAN; ASSEMBLER;

ASM
  MOV AX, 4300h                  { MultiPlexing interrupt request number  }
  INT 2fh                       { Dos Multiplexing Interrupt             }
  CMP AL, 80h                    { was the signature byte returned in AL  }
  JZ  @1                         { yes?, jump to @1                       }
  MOV AX, 00h                    { set false for return                   }
  JMP @2                        { unconditional jump to end of function  }
 @1:
  MOV AX, 01h                    { set True for return then fall thru to  }
                                { exit.                                  }
 @2:
END;

{------------------------------------------------------------------------- --}
{                                                                          }
{                            Local Procedure                               }
{                      function ReturnDriverAddress                        }
{                                                                          }
{  This function return true if it could determine the device driver entry  }
{  point.  This information is required to call any XMS functions. It uses  }
{  a DOS multiplexing interrupt request to get this address. This is the }
{  Microsoft recomended method of getting the base address of this driver.  }
{  This address is required to setup an indirect call to the driver by the  }
{  XMS functions.                                                           }
{                                                                           }
{---------------------------------------------------------------------------}
FUNCTION ReturnDriverAddress : POINTER; ASSEMBLER;
  {  This function returns the address for the XMM memory manager  }
  {  This value is required to later call the driver for XMS calls }

ASM
  MOV AX, 4310h                  { MultiPlexing interrupt request number }
  INT 2fh                       { Dos Multiplexing Interrupt            }
                                { Set Registers up for Return of Pointer }
  MOV AX, BX                     { Set Offset Value                      }
  MOV DX, ES                     { Set Segment Value                     }
END;

{-------------------------------------------------------------------------}
{                                                                         }
{                               Local Procedure                           }
{                            function GetXMSVersion                       }
{                                                                         }
{-------------------------------------------------------------------------}
FUNCTION GetXMSVersion(VAR XMS_Version, XMM_DriverVersion : WORD;
                       VAR HMA_Exists : BOOLEAN;
                       VAR ErrorCode : WORD) : BOOLEAN; ASSEMBLER;

  { This function loads the version numbers into the unit global }
  { variables. The information is coded in binary Coded Decimal. }

ASM
  XOR  AX, AX                     { set ax to zero                        }
  CALL XMMAddress               { indirect call to XMM driver           }
  CMP  AX, 00h                    { error set ?                           }
  JZ   @1                         { Jump error finish                     }

  LES  DI, XMS_Version            { Load XMS_Version Address into es:di   }
  MOV  ES:[DI],AX                { Load variable indirect                }

  LES  DI, XMM_DriverVersion      { Load XMM_DriverVrsn Address in es:di  }
  MOV  ES:[DI],BX                { Load variable Indirect                }

  LES  DI, HMA_Exists             { Load HMA_Exists Address in es:di      }
  MOV  ES:[DI],DX                { Load variable Indirect                }

  LES  DI,ErrorCode              { Load ErrorCode Address into es:di     }
  MOV  WORD PTR ES:[DI],00h      { Clear Error Code                      }
  MOV  AX, 01h                    { set function return to true           }
  JMP  @2                        { Jump to finish                        }

 @1:
  LES DI, ErrorCode              { Load error code address in es:di      }
  MOV WORD PTR ES:[DI],00h      { copy 0  into ErrorCode                }
 @2:
END;

{-------------------------------------------------------------------------}
{                                                                         }
{                             Exported Procedure                          }
{                            function AllocateEMB                         }
{                                                                         }
{                                                                         }
{    Function AllocateEMB allocates an Extended Memory Block in Extended  }
{    memory.  It requests the block via the Extended Memory Manager(XMM)  }
{    It returns True if it was successful False otherwise.  If true, if   }
{    EMB_Handle will contain the Extended Memory Block Handle.  If        }
{    returning false, the errorcode is in the ErrorCode parameter.        }
{                                                                         }
{-------------------------------------------------------------------------}
FUNCTION AllocateEMB(VAR EMB_Handle, ParRequested,
                         ErrorCode : WORD) : BOOLEAN; ASSEMBLER;

ASM
  MOV  AH, 09h                    { set ax for Allocate EMB call       }
  LES  DI, ParRequested           { load ParRequested address in es:di }
  MOV  DX, ES:[DI]                { copy parRequested value in DX      }
  CALL XMMAddress               { indirect call to XMM driver        }
  CMP  AX, 00h                    { error set ?                        }
  JZ   @1                         { Jump error finish                  }
  LES  DI, EMB_Handle             { load EMB_Handle in es:di           }
  MOV  ES:[DI],DX                { copy DX into EMB_Handle            }
  MOV  AX, 01h                    { Return True                        }
  LES  DI, ErrorCode              { Load error code address in es:di   }
  MOV  WORD PTR ES:[DI],00h      { copy 0  into ErrorCode             }
  JMP  @2                        { unconditional jump to finish       }
  { Error Finish                       }
 @1:
  LES  DI, ErrorCode              { load ErrorCode in es:di            }
  MOV  BYTE PTR ES:[DI],BL       { copy BL into ErrorCode             }
 @2:
END;

{-------------------------------------------------------------------------}
{                                                                         }
{                           Exported Procedure                            }
{                            function FreeEMB                             }
{                                                                         }
{  Function FreeEMB releases an Extended Memory Block in Extended Memory  }
{  allocated by the AllocateEMB function call.  It requests the XMM       }
{  remove the block.  It returns True if it was successful False          }
{  otherwise.  If true, if block was released correctly.  If returning    }
{  false, the errorcode is in the ErrorCode parameter.                    }
{                                                                         }
{-------------------------------------------------------------------------}
FUNCTION FreeEMB(VAR EMB_Handle, ErrorCode : WORD) : BOOLEAN; ASSEMBLER;

ASM
  XOR  AX, AX                     { clear AX to zero                 }
  MOV  AH, 0Ah                    { set ax for Free EMB call         }
  LES  DI, EMB_Handle             { load EMB_Handle address in es:di }
  MOV  DX, ES:[DI]                { load EMB_Handle value in DX      }
  CALL XMMAddress               { indirect call to XMM driver      }
  CMP  AX, 00h                    { error set ?                      }
  JZ   @1                         { Jump error finish                }
  MOV  AX, 01H                    { Set True                         }
  LES  DI, ErrorCode              { Load error code address in es:di }
  MOV  WORD PTR ES:[DI],00h      { copy 0  into ErrorCode           }
  JMP  @2                        { unconditional jump to finish     }
                                { Error Finish                     }
 @1:
  LES  DI, ErrorCode              { load ErrorCode in es:di          }
  MOV  BYTE PTR ES:[DI],BL       { copy BL into ErrorCode           }
 @2:
END;

{-------------------------------------------------------------------------}
{                                                                         }
{                           Exported Procedure                            }
{                            function MoveEMB                             }
{                                                                         }
{  Function MoveEMB allows memory tranfers between conventional and XMS   }
{  Memory.  This function requires a filled in TXMSParamBlock record.     }
{  It returns True if it was successful False otherwise.  If true, the    }
{  memory block was successfully moved.  If returning false, the          }
{  errorcode is in the ErrorCode parameter.                               }
{                                                                         }
{-------------------------------------------------------------------------}
FUNCTION MoveEMB(PParamBlock : PXMSParamBlock;
                 VAR ErrorCode : WORD) : BOOLEAN; ASSEMBLER;

ASM
  MOV  AX, DS                     { move DS to AX register                }
  MOV  ES, AX                     { move AX to ES register                }
  MOV  AH, 0Bh                    { set ax for Move EMB call              }
  PUSH DS                       { push DS to Stack                      }
  LDS  SI, PParamBlock            { load PParamBlock Address to ds:si     }
  MOV  DI, OFFSET XMMAddress      { move XMMAddress offset to di          }
  CALL DWORD PTR ES:[DI]        { indirect call to XMMdriver via es:di  }
  POP  DS                        { save TP's data segment                }
  CMP  AX, 00h                    { error set ?                           }
  JZ   @1                         { Jump error finish                     }
  MOV  AX, 01H                    { Set True                              }
  LES  DI, ErrorCode              { Load error code address in es:di      }
  MOV  WORD PTR ES:[DI],00h      { copy 0  into ErrorCode                }
  JMP  @2                        { unconditional jump to finish          }
                                { Error Finish                          }
 @1:
  LES  DI, ErrorCode              { load ErrorCode in es:di               }
  MOV  WORD PTR ES:[DI],AX       { Clear ErrorCode prior to load         }
  MOV  BYTE PTR ES:[DI],BL       { copy BL into ErrorCode                }
  MOV  AX, 01h                    { Return False                          }
 @2:
END;

BEGIN
  XMSExists := XMSPresent;
  IF XMSExists THEN
  BEGIN
    XMMAddress := ReturnDriverAddress;
    GetXMSVersion(XMS_Version, XMM_DriverVersion, HMA_Exists, LastErrorCode);
  END;
END.

