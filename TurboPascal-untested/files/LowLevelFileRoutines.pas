(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0049.PAS
  Description: Low Level File Routines
  Author: GREG ESTABROOKS
  Date: 02-09-94  07:25
*)

UNIT FILEIO;            { Low Level File handling routines. Jan 18/94   }
                        { Copyright (C) 1993,1994 Greg Estabrooks       }
                        { NOTE: Requires TP 6.0+ to compile.            }
INTERFACE
{***********************************************************************}
USES DOS;                       { IMPORT FSearch.                       }
CONST                           { Handles PreDefined by DOS.            }
     fStdIn     = $00;          { STD Input Device, (Keyboard).         }
     fStdOut    = $01;          { STD Output Device,(CRT).              }
     fStdErr    = $02;          { STD Error Device, (CRT).              }
     fStdCom    = $03;          { STD Comm.                             }
     fStdPrn    = $04;          { STD Printer.                          }
     oRead      = $00;          { Opens a file for read only.           }
     oWrite     = $01;          { Opens a file for writing only.        }
     oReadWrite = $02;          { Opens a file for reading and writing. }
     oDenyAll   = $10;          { Deny access to other processes.       }
     oDenyWrite = $20;          { Deny write access to other processes. }
     oDenyRead  = $30;          { Deny read access to other processes.  }
     oDenyNone  = $40;          { Allow free access to other processes. }
                                { Possible file attribs,can be combined.}
     aNormal   = $00;  aSystem = $04;  aArchive = $20;
     aReadOnly = $01;  aVolume = $08;
     aHidden   = $02;  aDir    = $10;
TYPE
    LockType = (Lock,UnLock);   { Ordinal Type for use with 'fLock'.    }
VAR
   fError  :WORD;               { Holds any error codes from routines.  }

PROCEDURE ASCIIZ( VAR fName :STRING );
                         { Routine to add a NULL to a string to make it }
                         { ASCIIZ compatible.                           }
                         { File routines automatically call this routine}
                         { usage :                                      }
                         {  ASCIIZ(fName);                              }

FUNCTION  fCreate( fName :STRING; Attr :BYTE ) :WORD;
                         { Routine to Create 'fName' with an attribute  }
                         { of 'Attr'. If the file already exists then it}
                         { will be truncated to a zero length file.     }
                         { Returns a WORD value containing the  handle. }
                         { Uses Int 21h/AH=3Ch.                         }
                         { usage :                                      }
                         {  handle := fCreate('Temp.Dat',aNormal);      }

FUNCTION  fOpen( fName :STRING; Mode :BYTE ) :WORD;
                         { Routine to open already existing file defined}
                         { in 'fName' with an opening mode of 'Mode'.   }
                         { Returns a WORD value containing the  handle. }
                         { Uses Int 21h/AH=3Dh.                         }
                         { usage :                                      }
                         {  handle := fOpen('Temp.Dat',oRead);          }

PROCEDURE fRead( fHandle :WORD; VAR Buff; NTRead:WORD; VAR ARead :WORD );
                         { Reads 'NTRead' bytes of data from 'fHandle'  }
                         { and puts it in 'Buff'. The actually amount   }
                         { of bytes read is returned in 'ARead'.        }
                         { Uses Int 21h/AH=3Fh.                         }
                         { usage :                                      }
                         {  fRead(handle,Buffer,SizeOf(Buffer),ARead);  }

PROCEDURE fWrite( fHandle :WORD; VAR Buff; NTWrite:WORD; VAR AWrite :WORD );
                         { Writes 'NTWrite' bytes of info from 'Buff'   }
                         { to 'fHandle'. The actually amount written is }
                         { returned in 'AWrite'.                        }
                         { Uses Int 21h/AH=40h.                         }
                         { usage :                                      }
                         {  fWrite(handle,Buffer,SizeOf(Buffer),AWrite);}

PROCEDURE fClose( fHandle :WORD );
                         { Routine to close file 'fHandle'. This updates}
                         { the directory time and size enteries.        }
                         { Uses Int 21h/AH=3Eh.                         }
                         { usage :                                      }
                         {  fClose(handle);                             }

PROCEDURE fReset(  fHandle :WORD );
                         { Routine to reset file position pointer to the}
                         { beginning of 'fHandle'.                      }
                         { Uses Int 21h/AH=42h.                         }
                         { usage :                                      }
                         {  fReset(handle);                             }

PROCEDURE fAppend( fHandle :WORD );
                         { Routine to move the File position pointer of }
                         { 'fHandle' to the end of the file. Any further}
                         { writing is added to the end of the file.     }
                         { Uses Int 21h/AH=42h.                         }
                         { usage :                                      }
                         {  fAppend(handle);                            }

PROCEDURE fSeek( fHandle :WORD; fOfs :LONGINT );
                         { Routine to move the file position pointer for}
                         { 'fHandle' to 'fOfs'. 'fOfs' is the actual    }
                         { byte position in the file to move to.        }
                         { Uses Int 21h/AH=42h.                         }
                         { usage :                                      }
                         {  fSeek(handle,1023);                         }

PROCEDURE fErase( fName :STRING );
                         { Routine to erase 'fName'.                    }
                         { Uses Int 21h/AH=41h.                         }
                         { usage :                                      }
                         {  fErase('Temp.Dat');                         }

FUNCTION  fPos( fHandle :WORD ) :LONGINT;
                         { Routine to return the current position within}
                         { 'fHandle'.                                   }
                         { Uses Int 21h/AH=42.                          }
                         { usage :                                      }
                         {  CurPos := fPos(handle);                     }

FUNCTION  fEof( fHandle :WORD ) :BOOLEAN;
                         { Routine to determine whether or not we're    }
                         { currently at the end of file 'fHandle'.      }
                         { usage :                                      }
                         {  IsEnd := fEof(handle);                      }

FUNCTION  fExist( fName :STRING ) :BOOLEAN;
                         { Routine to determine whether or not 'fName'  }
                         { exists.                                      }
                         { usage :                                      }
                         {  Exist := fExist('Temp.Dat');                }

FUNCTION  fGetAttr( fName :STRING ) :BYTE;
                         { Routine to return the current file attribute }
                         { of 'fName'.                                  }
                         { Uses Int 21h/AH=43h,AL=00h.                  }
                         { usage :                                      }
                         {  CurAttr := fGetAttr('Temp.Dat');            }

PROCEDURE fSetAttr( fName :STRING; NAttr :BYTE );
                         { Routine to set file attribute of 'fName' to  }
                         { 'NAttr'.                                     }
                         { Uses Int 21h/AH=43h,AL=01h.                  }
                         { usage :                                      }
                         {  fSetAttr('Temp.Dat',aArchive OR aReadOnly); }

PROCEDURE fSetVerify( On_Off :BOOLEAN );
                         { Routine to set the DOS verify flag ON or OFF.}
                         { depending on 'On_Off'.                       }
                         { TRUE = ON, FALSE = OFF.                      }
                         { Uses Int 21h/AH=2Eh.                         }
                         { usage :                                      }
                         {  fSetVerify( TRUE );                         }

FUNCTION  fGetVerify :BOOLEAN;
                         { Routine to return the current state of the   }
                         { DOS verify flag.                             }
                         { Uses Int 21h/AH=54h.                         }
                         { usage :                                      }
                         {  IsVerify := fGetVerify;                     }

FUNCTION  fSize( fHandle :WORD ) :LONGINT;
                         { Routine to determine the size in bytes of    }
                         { 'fHandle'.                                   }
                         { usage :                                      }
                         {  CurSize := fSize(handle);                   }

PROCEDURE fFlush( fHandle :WORD );
                         { Flushes any File buffers for 'fHandle'       }
                         { immediately and updates the directory entry. }
                         { Uses Int 21h/AH=68h.                         }
                         { usage :                                      }
                         {  fFlush(handle);                             }

PROCEDURE fLock( fHandle :WORD; LockInf :LockType; StartOfs,Len :LONGINT );
                         { Routine to lock/unlock parts of a open file.  }
                         { Locking or unlock is determined by 'LockInf'. }
                         { Uses Int 21h/AH=5Ch.                          }
                         { usage :                                       }
                         {  fLock(handle,Lock,1000,500);                 }
{***********************************************************************}
IMPLEMENTATION


PROCEDURE ASCIIZ( VAR fName :STRING ); ASSEMBLER;
                         { Routine to add a NULL to a string to make it }
                         { ASCIIZ compatible.                           }
                         { File routines automatically call this routine}
ASM
  Push DS                       { Push DS onto the stack.               }
  LDS DI,fname                  { Point DS:DI ---> fName.               }
  Xor BX,BX                     { Clear BX.                             }
  Mov BL,BYTE PTR DS:[DI]       { Load length of string into BL.        }
  Inc BL                        { Point to char after last one in name. }
  Mov BYTE PTR DS:[DI+BX],0     { Now make it a ASCIIZ string.          }
  Pop DS                        { Pop DS off the stack.                 }
END;{ASCIIZ}

FUNCTION  fCreate( fName :STRING; Attr :BYTE ) :WORD;
                         { Routine to Create 'fName' with an attribute  }
                         { of 'Attr'. If the file already exists then it}
                         { will be truncated to a zero length file.     }
                         { Returns a WORD value containing the  handle. }
                         { Uses Int 21h/AH=3Ch.                         }
BEGIN
  ASCIIZ(fName);                { Convert fName to an ASCIIZ string.    }
  ASM
    Push DS                     { Push DS Onto stack.                   }
    Mov fError,0                { Clear Error Flag.                     }
    Mov AX,SS                   { Load AX with SS.                      }
    Mov DS,AX                   { Now load that value into DS.          }
    Lea DX,fName                { Now load DX with the offset of DX.    }
    Inc DX                      { Move past length byte.                }
    Xor CH,CH                   { Clear High byte of CX.                }
    Mov CL,Attr                 { Load attribute to give new file.      }
    Mov AH,$3C                  { Function to create a file.            }
    Int $21                     { Call dos to create file.              }
    Jnc @Exit                   { If no error exit.                     }
    Mov fError,AX               { If there was an  error save it.       }
  @Exit:
    Mov @Result,AX              { Return proper result to user.         }
    Pop DS                      { Pop DS Off the Stack.                 }
  END;
END;{fCreate}

FUNCTION  fOpen( fName :STRING; Mode :BYTE ) :WORD;
                         { Routine to open already existing file defined}
                         { in 'fName' with an opening mode of 'Mode'.   }
                         { Returns a WORD value containing the  handle. }
                         { Uses Int 21h/AH=3Dh.                         }
BEGIN
  ASCIIZ(fName);                { Convert fName to an ASCIIZ string.    }
  ASM
    Push DS                     { Push DS onto stack.                   }
    Mov fError,0                { Clear Error Flag.                     }
    Mov AX,SS                   { Load AX with SS.                      }
    Mov DS,AX                   { Now load that value into DS.          }
    Lea DX,fName                { Now load DX with the offset of DX.    }
    Inc DX                      { Move past length byte.                }
    Mov AL,Mode                 { File Opening mode.                    }
    Mov AH,$3D                  { Function to open a file.              }
    Int $21                     { Call dos to open file.                }
    Jnc @Exit                   { If no error exit.                     }
    Mov fError,AX               { If there was an  error save it.       }
  @Exit:
    Mov @Result,AX              { Return proper result to user.         }
    Pop DS                      { Restore DS from stack.                }
  END;
END;{fOpen}

PROCEDURE fRead( fHandle :WORD; VAR Buff; NTRead:WORD; VAR ARead :WORD );
ASSEMBLER;               { Reads 'NTRead' bytes of data from 'fHandle'  }
                         { and puts it in 'Buff'. The actually amount   }
                         { of bytes read is returned in 'ARead'.        }
                         { Uses Int 21h/AH=3Fh.                         }
ASM
  Push DS                       { Push DS onto the stack.               }
  Mov fError,0                  { Clear Error flag.                     }
  Mov AH,$3F                    { Function to read from a file.         }
  Mov BX,fHandle                { load handle of file to read.          }
  Mov CX,NTRead                 { # of bytes to read.                   }
  LDS DX,Buff                   { Point DS:DX to buffer.                }
  Int $21                       { Call Dos to read file.                }
  LDS DI,ARead                  { Point to amount read.                 }
  Mov WORD PTR DS:[DI],AX       { Save amount actually read.            }
  Jnc @Exit                     { if there was no error exit.           }
  Mov fError,AX                 { If there was Save error code.         }
@Exit:
  Pop DS                        { Pop DS off the stack.                 }
END;{fRead}

PROCEDURE fWrite( fHandle :WORD; VAR Buff; NTWrite:WORD; VAR AWrite :WORD );
ASSEMBLER;               { Writes 'NTWrite' bytes of info from 'Buff'   }
                         { to 'fHandle'. The actually amount written is }
                         { returned in 'AWrite'.                        }
                         { Uses Int 21h/AH=40h.                         }
ASM
  Push DS                       { Push DS onto the stack.               }
  Mov fError,0                  { Clear Error flag.                     }
  Mov AH,$40                    { Function to write to file.            }
  Mov BX,fHandle                { Handle of file to write to.           }
  Mov CX,NTWrite                { # of bytes to read.                   }
  LDS DX,Buff                   { Point DS:DX -> Buffer.                }
  Int $21                       { Call Dos to write to file.            }
  LDS DI,AWrite                 { Point to amount write.                }
  Mov WORD PTR DS:[DI],AX       { Save amount actually written.         }
  Jnc @Exit                     { If there was no error exit.           }
  Mov fError,AX                 { if there was save error code.         }
@Exit:
  Pop DS                        { Pop DS off the stack.                 }
END;{fWrite}

PROCEDURE fClose( fHandle :WORD ); ASSEMBLER;
                         { Routine to close file 'fHandle'. This updates}
                         { the directory time and size enteries.        }
                         { Uses Int 21h/AH=3Eh.                         }
ASM
  Mov fError,0                  { Clear Error flag                      }
  Mov AH,$3E                    { Function to close file                }
  Mov BX,fHandle                { load handle of file to close          }
  Int $21                       { call Dos to close file                }
  Jnc @Exit                     { If there was no error exit            }
  Mov fError,AX                 { if there was save error code          }
@Exit:
END;{fClose}

PROCEDURE fReset( fHandle :WORD ); ASSEMBLER;
                         { Routine to reset file position pointer to the}
                         { beginning of 'fHandle'.                      }
                         { Uses Int 21h/AH=42h.                         }
ASM
  Mov fError,0                  { Clear error flag.                     }
  Mov AH,$42                    { Function to move file pointer.        }
  Mov BX,fHandle                { Handle of file.                       }
  Mov AL,0                      { Offset relative to begining.          }
  Mov CX,0                      { CX:DX = offset from begining of file  }
  Mov DX,0                      { to move to.                           }
  Int $21                       { Call dos to change file pointer.      }
  Jnc @Exit                     { If there was no error exit.           }
  Mov fError,AX                 { If there was save error code.         }
@Exit:
END;{fReset}

PROCEDURE fAppend( fHandle :WORD); ASSEMBLER;
                         { Routine to move the File position pointer of }
                         { 'fHandle' to the end of the file. Any further}
                         { writing is added to the end of the file.     }
                         { Uses Int 21h/AH=42h.                         }
ASM
  Mov fError,0                  { Clear error flag.                     }
  Mov AH,$42                    { Function to change file ptr position. }
  Mov BX,fHandle                { handle of file to change.             }
  Mov AL,$02                    { Change relative to end of file.       }
  Mov CX,0                      { CX:DX = offset from end of file       }
  Mov DX,0                      { to move to.                           }
  Int $21                       { Call dos to move file ptr.            }
  Jnc @Exit                     { If there was no error exit.           }
  Mov fError,AX                 { If there was save error code.         }
@Exit:
END;{fAppend}

PROCEDURE fSeek( fHandle :WORD; fOfs :LONGINT ); ASSEMBLER;
                         { Routine to move the file position pointer for}
                         { 'fHandle' to 'fOfs'. 'fOfs' is the actual    }
                         { byte position in the file to move to.        }
                         { Uses Int 21h/AH=42h.                         }
ASM
  Mov fError,0                  { Clear error flag.                     }
  Mov AH,$42                    { Function to change file ptr position. }
  Mov BX,fHandle                { handle of file to change.             }
  Mov AL,$00                    { Change relative to start of file.     }
  Mov CX,fOfs[2].WORD           { CX:DX = offset from start of file     }
  Mov DX,fOfs.WORD              { to move to.                           }
  Int $21                       { Call dos to move file ptr.            }
  Jnc @Exit                     { If there was no error exit.           }
  Mov fError,AX                 { If there was save error code.         }
@Exit:
END;{fSeek}

PROCEDURE fErase( fName :STRING );
                         { Routine to erase 'fName'.                    }
                         { Uses Int 21h/AH=41h.                         }
BEGIN
  ASCIIZ(fName);                { Convert fName to an ASCIIZ string.    }
  ASM
    Push DS                     { Push DS onto the stack.               }
    Mov fError,0                { Clear error flag.                     }
    Mov AX,SS                   { Load AX with SS.                      }
    Mov DS,AX                   { Now load that value into DS.          }
    Lea DX,fName                { Now load DX with the offset of DX.    }
    Inc DX
    Mov AH,$41                  { Function to erase a file.             }
    Int $21                     { Call dos to erase file.               }
    Jnc @Exit                   { If no error exit.                     }
    Mov fError,AX               { if there was error save error code.   }
  @Exit:
    Pop DS                      { Pop DS off the stack.                 }
  END;
END;{fErase}

FUNCTION  fPos( fHandle :WORD ) :LONGINT; ASSEMBLER;
                         { Routine to return the current position within}
                         { 'fHandle'.                                   }
                         { Uses Int 21h/AH=42.                          }
ASM
  Mov fError,0                  { Clear error flag.                     }
  Mov AH,$42                    { Function to move file pointer.        }
  Mov BX,fHandle                { Handle of file.                       }
  Mov AL,1                      { Offset relative to current pos.       }
  Mov CX,0                      { CX:DX = offset from current position  }
  Mov DX,0                      { to move to.                           }
  Int $21                       { Call dos to change file pointer.      }
  Jnc @Exit                     { If there was no error return result.  }
  Mov fError,AX                 { If there was save error code.         }
@Exit:                          { Int already returns DX:AX as file pos.}
END;{fPos}

FUNCTION  fEof( fHandle :WORD ) :BOOLEAN;
                         { Routine to determine whether or not we're    }
                         { currently at the end of file 'fHandle'.      }
VAR
   CurOfs :LONGINT;             { current file offset.                  }
BEGIN
  CurOfs := fPos(fHandle);      { Save Current Pos.                     }
  fAppend(fHandle);             { Move to the end of the file.          }
  fEof := (CurOfs = fPos(fHandle)); { was current pos = end pos?.       }
  fSeek(fHandle,CurOfs);        { Restore to original file position.    }
END;{fEof}

FUNCTION  fExist( fName :STRING ) :BOOLEAN;
                         { Routine to determine whether or not 'fName'  }
                         { exists.                                      }
BEGIN
  fExist := ( FSearch(fName,'') <> '');
END;{fExist}

FUNCTION  fGetAttr( fName :STRING ) :BYTE;
                         { Routine to return the current file attribute }
                         { of 'fName'.                                  }
                         { Uses Int 21h/AH=43h,AL=00h.                  }
BEGIN
  ASCIIZ(fName);                { Convert fName to an ASCIIZ string.    }
  ASM
    Push DS                     { Push DS onto the stack.               }
    Mov fError,0                { Clear error flag.                     }
    Mov AX,SS                   { Load AX with SS.                      }
    Mov DS,AX                   { Now load that value into DS.          }
    Lea DX,fName                { Now load DX with the offset of DX.    }
    Inc DX
    Mov AX,$4300                { Function to Get file Attrib.          }
    Int $21                     { Call dos to get attr.                 }
    Jnc @Success                { If no error return proper info.       }
    Mov fError,AX               { if there was error save error code.   }
  @Success:
    Mov AX,CX
    Mov @Result,AL              { Return proper result to user.         }
    Pop DS                      { Pop DS off the stack.                 }
  END;
END;{fGetAttr}

PROCEDURE fSetAttr( fName :STRING; NAttr :BYTE );
                         { Routine to set file attribute of 'fName' to  }
                         { 'NAttr'.                                     }
                         { Uses Int 21h/AH=43h,AL=01h.                  }
BEGIN
  ASCIIZ(fName);                { Convert fName to an ASCIIZ string.    }
  ASM
    Push DS                     { Push DS onto the stack.               }
    Mov fError,0                { Clear error flag.                     }
    Mov AX,SS                   { Load AX with SS.                      }
    Mov DS,AX                   { Now load that value into DS.          }
    Lea DX,fName                { Now load DX with the offset of DX.    }
    Inc DX                      { Point to first char after length byte.}
    Xor CX,CX                   { Clear CX.                             }
    Mov CL,NAttr                { Load New attribute byte.              }
    Mov AX,$4301                { Function to Set file Attrib.          }
    Int $21                     { Call dos to set attrib.               }
    Jnc @Exit                   { If no error exit.                     }
    Mov fError,AX               { if there was error save error code.   }
  @Exit:
    Pop DS                      { Pop DS off the stack.                 }
  END;
END;{fSetAttr}

PROCEDURE fSetVerify( On_Off :BOOLEAN ); ASSEMBLER;
                         { Routine to set the DOS verify flag ON or OFF.}
                         { depending on 'On_Off'.                       }
                         { TRUE = ON, FALSE = OFF.                      }
                         { Uses Int 21h/AH=2Eh.                         }
ASM
  Mov AH,$2E                        {  Interrupt Subfunction.               }
  Mov DL,0                      {  Clear DL.                            }
  Mov AL,On_Off                        {  0(FALSE) = off, 1(TRUE) = on.        }
  Int $21                        {  Call Dos.                            }
END;{fSetVerify}

FUNCTION  fGetVerify :BOOLEAN; ASSEMBLER;
                         { Routine to return the current state of the   }
                         { DOS verify flag.                             }
                         { Uses Int 21h/AH=54h.                         }
ASM
  Mov AH,$54                        {  Interrupt Subfunction                }
  Int $21                        {  Call Dos                             }
END;{fGetVerify}

FUNCTION  fSize( fHandle :WORD ) :LONGINT;
                         { Routine to determine the size in bytes of    }
                         { 'fHandle'.                                   }
VAR
   CurOfs :LONGINT;             { Holds original file pointer.          }
BEGIN
  CurOfs := fPos(fHandle);      { Save current file pointer.            }
  fAppend(fHandle);             { Move to end of file.                  }
  fSize := fPos(fHandle);       { Save current pos which equals size.   }
  fSeek(fHandle,CurOfs);        { Restore original file pos.            }
END;{fSize}

PROCEDURE fFlush( fHandle :WORD ); ASSEMBLER;
                         { Flushes any File buffers for 'fHandle'       }
                         { immediately and updates the directory entry. }
                         { Uses Int 21h/AH=68h.                         }
ASM
  Mov fError,0                  { Clear error flag.                     }
  Mov AH,$68                    { Function to Commit file to disk.      }
  Mov BX,fHandle                { Load handle of file to Commit.        }
  Int $21                       { Call dos to flush file.               }
  Jnc @Exit                     { If no error exit.                     }
  Mov fError,AX                 { if there was error save error code.   }
@Exit:
END;{fSetAttr}

PROCEDURE fLock( fHandle :WORD; LockInf :LockType; StartOfs,Len :LONGINT );
                         { Routine to lock/unlock parts of a open file.  }
ASSEMBLER;               { Locking or unlock is determined by 'LockInf'. }
                         { Uses Int 21h/AH=5Ch.                          }

ASM
  Mov fError,0                  { Clear Error Flag.                     }
  Mov AH,$5C                    { Function to lock/unlock part of a file.}
  Mov AL,LockInf                { Load whether to lock/unlock file area.}
  Mov BX,fHandle                { Handle of file to lock.               }
  Mov CX,StartOfs.WORD[0]       { Load StartOfs Into  CX:DX.            }
  Mov DX,StartOfs.WORD[2]
  Mov SI,Len.WORD[0]            { Load Len Into SI:DI.                  }
  Mov DI,Len.WORD[2]
  Int $21                       { Call dos to lock area.                }
  Jnc @Exit                     { If no error exit.                     }
  Mov fError,AX                 { If there was an  error save it.       }
@Exit:
END;{fLock}

BEGIN
END.{FileIO}

