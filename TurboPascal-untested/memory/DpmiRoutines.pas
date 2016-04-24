(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0046.PAS
  Description: DPMI Routines
  Author: GREG ESTABROOKS
  Date: 01-27-94  13:31
*)

UNIT DPMI;              { DPMI routines, Last Updated Aug 7/93          }
                        { Copyright (C) 1993, Greg Estabrooks           }
INTERFACE
{***********************************************************************}
VAR
   DPMIControl :POINTER;
   ParNeeded   :WORD;

FUNCTION DPMI_Installed :BOOLEAN;
                        { Routine to Determine whether a DPMI API is    }
                        { installed. If it is installed it loads the    }
                        { address of the API into DPMIControl for later }
                        { program use. Loads ParaNeeded with paragraphs }
                        { needed for Host data area.                    }

FUNCTION DPMIControlAdr :POINTER;
                        { This routine returns a pointer to the DPMI    }
                        { control.                                      }

FUNCTION DPMIVer :WORD;
                        { This routine returns the Version of the DPMI  }

FUNCTION Processor :BYTE;
                        { Routine to return processor type as returned  }
                        { by the DPMI API.                              }

{***********************************************************************}
IMPLEMENTATION

FUNCTION DPMI_Installed :BOOLEAN; ASSEMBLER;
                        { Routine to Determine whether a DPMI API is    }
                        { installed. If it is installed it loads the    }
                        { address of the API into DPMIControl for later }
                        { program use. Loads ParaNeeded with paragraphs }
                        { needed for Host data area.                    }
ASM
  Mov AX,$1687                  { Function to check for DPMI.           }
  Int $2F                       { Call Int 2Fh.                         }
  Cmp AX,0                      { Compare Result to 0.                  }
  Je @Installed                 { If its equal jump to Installed.       }
  Mov AL,0                      { Else return FALSE.                    }
  Jmp @Exit                     { Jump to end of routine.               }

@Installed:
  Mov DPMIControl.WORD,DI       { Load pointer ES:DI into DPMIControl.  }
  Mov DPMIControl+2.WORD,ES
  Mov ParNeeded,SI              { Load Paragraphs needed into ParNeeded.}
  Mov AL,1                      { Set true flag.                        }

@Exit:
END;{DPMI_Installed}

FUNCTION DPMIControlAdr :POINTER; ASSEMBLER;
                        { This routine returns a pointer to the DPMI    }
                        { control.                                      }
ASM
  Mov AX,$1687                  { Function to return point to API.      }
  Int $2F                       { Call Int 2Fh.                         }
  Mov DX,ES                     { Pointer info is returned in ES:DI.    }
  Mov AX,DI
END;{DPMIControlAdr}

FUNCTION DPMIVer :WORD; ASSEMBLER;
                        { This routine returns the Version of the DPMI  }
ASM
  Mov AX,$1687                  { Function to get version of DPMI API.  }
  Int $2F                       { Call int 2Fh.                         }
  Mov AX,DX                     { Version is returned in DX.            }
END;{DPMIVer}

FUNCTION Processor :BYTE; ASSEMBLER;
                        { Routine to return processor type as returned  }
                        { by the DPMI API.                              }
ASM
  Mov AX,$1687                  { Function to get info from DPMI.       }
  Int $2F                       { Call Int 2Fh.                         }
  Mov AL,CL                     { Processor type returned in CL.        }
END;{Processor}

BEGIN
END.
