(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0073.PAS
  Description: CD-ROM Dectection
  Author: PAUL WEST
  Date: 08-24-94  13:27
*)

{
 JM>Would you happen to have any example code to determine if a drive is a
 JM>hard disk, cd-rom, ramdrive etc. ?

Here is a unit that will at least tell you a little about the CD-ROM.   Not all
MSCDEX functions are implemented, but enough to identify the CD-ROMS.
}
unit CDROM;

{$X+}   { Extended Syntax Rules }

interface

type
  CDR_DL_ENTRY = record
    UNITNO  : byte;
    OFFSET  : word;
    SEGMENT : word;
  end;

  CDR_DL_BUFFER   = array[1..26] of CDR_DL_ENTRY;
  CDR_DRIVE_UNITS = array[0..25] of byte;
  CDR_VTOC        = array[1..2048] of byte;

{ 00h } procedure CDR_GET_DRIVE_COUNT   (var COUNT, FIRST: word);
{ 01h } procedure CDR_GET_DRIVE_LIST    (var LIST: CDR_DL_BUFFER);
{ 02h } function  CDR_GET_COPR_NAME     (DRIVE: byte): string;
{ 03h } function  CDR_GET_ABSTRACT_NAME (DRIVE: byte): string;
{ 04h } function  CDR_GET_BIBLIO_NAME   (DRIVE: byte): string;
{ 05h Read VTOC }
{ 06h Reserved }
{ 07h Reserved }
{ 08h Absolute Disk Read }
{ 09h Absolute Disk Write }
{ 0ah Reserved }
{ 0bh } function  CDR_DRIVE_CHECK       (DRIVE: byte): boolean;
{ 0ch } function  CDR_VERSION: word;
{ 0dh } procedure CDR_GET_DRIVE_UNITS   (var BUFFER: CDR_DRIVE_UNITS);
{ 0eh Get or Set VDR }
{ 0fh Get Dir Entry }
{ 10h Send Device Request }

implementation

uses dos, strings;

const
  CDROM_INTERRUPT = $2f;

var
  REG : registers;

procedure CDR_GET_DRIVE_COUNT (var COUNT, FIRST: word);
assembler;

{ Returns the total number of CD-ROM Drives in the system }
{ and the logical drive number of the first drive.        }

{ In a system that contains multiple CD-ROM Drives and is }
{ also networked, the CD-ROM drives might not be assigned }
{ as consecutive logical units.  See also MSCDEX Function }
{ 0Dh (Get CD-ROM Drive Letters)                          }

asm
  mov ax, 1500h
  xor bx, bx
  int CDROM_INTERRUPT
  les di, COUNT
  mov es:[di], bx
  les di, FIRST
  mov es:[di], cx
end;

procedure CDR_GET_DRIVE_LIST (var LIST: CDR_DL_BUFFER);
assembler;

{ Returns a driver unit identifier for each CD-ROM drive  }
{ in the system, along with the address of the header for }
{ the device driver that controls the drive.              }

{ The driver unit code returned in the buffer is not the  }
{ systemwide logical drive identifier but is the relative }
{ unit for that particular driver.  For example if three  }
{ CD-ROM drivers are installed, each supporting one phy-  }
{ sical drive, the driver unit code in each 5 byte entry  }
{ will be 0.  The systemwide drive identifiers for each   }
{ CD-ROM unit can be obtained with MSCDEX Function 0Dh    }
{ (Get CD-ROM Drive Letters).                             }

asm
  mov ax, 1501h
  les bx, LIST
  int CDROM_INTERRUPT
end;

function  CDR_GET_COPR_NAME (DRIVE: byte): string;

{ Returns the name of the copyright file from the volume  }
{ table of contents (VTOC) of the specified CD-ROM Drive. }

{ CD-ROM Specs allow for a 31 character filename followed }
{ by a semicolon (;) and a 5 digit version number.        }

{ On disks that comply with the High Sierra standard,     }
{ the filename has an MS-DOS compatable (8/3) format.     }

var
  BUFFER : array[0..38] of char;

begin
  REG.AX := $1502;
  REG.CX := DRIVE;
  REG.ES := seg(BUFFER);
  REG.BX := ofs(BUFFER);
  intr(CDROM_INTERRUPT, REG);
  CDR_GET_COPR_NAME := strpas(BUFFER);
end;

function  CDR_GET_ABSTRACT_NAME (DRIVE: byte): string;

{ Returns the name of the abstract file from the volume   }
{ table of contents (VTOC) for the specified CD-ROM drive.}

{ CD-ROM Specs allow for a 31 character filename followed }
{ by a semicolon (;) and a 5 digit version number.        }

{ On disks that comply with the High Sierra standard,     }
{ the filename has an MS-DOS compatable (8/3) format.     }

var
  BUFFER : array[0..38] of char;

begin
  REG.AX := $1503;
  REG.CX := DRIVE;
  REG.ES := seg(BUFFER);
  REG.BX := ofs(BUFFER);
  intr(CDROM_INTERRUPT, REG);
  CDR_GET_ABSTRACT_NAME := strpas(BUFFER);
end;

function  CDR_GET_BIBLIO_NAME (DRIVE: byte): string;

{ Returns the name if the bibliographic file from the     }
{ volume table of contents (VTOC) for the specified drive.}

{ CD-ROM Specs allow for a 31 character filename followed }
{ by a semicolon (;) and a 5 digit version number.        }

{ This function is provided for compatability with the    }
{ ISO-9660 standard.  A null string is returned for disks }
{ complying with the High Sierra standard.                }

var
  BUFFER : array[0..38] of char;

begin
  REG.AX := $1504;
  REG.CX := DRIVE;
  REG.ES := seg(BUFFER);
  REG.BX := ofs(BUFFER);
  intr(CDROM_INTERRUPT, REG);
  CDR_GET_BIBLIO_NAME := strpas(BUFFER);
end;

function CDR_DRIVE_CHECK (DRIVE: byte): boolean;

{ Returns a code indicating whether a particular logical  }
{ unit is supported by the Microsoft CD-ROM Extensions    }
{ module (MSCDEX).                                        }

begin
  REG.AX := $150b;
  REG.BX := $0000;
  REG.CX := DRIVE;
  intr(CDROM_INTERRUPT, REG);
  CDR_DRIVE_CHECK := (REG.AX <> $0000) and (REG.BX = $adad);
end;

function  CDR_VERSION: word;

{ Returns the version number of the Microsoft CD-ROM Extensions }

{ The Major Version number is returned in the High Order byte   }
{ and the Minor Version Number is returned in the Lo order      }
{ byte.  IE if the MSCDEX Version is 2.10, this routine will    }
{ return $0210.                                                 }

begin
  REG.AX := $150c;
  REG.BX := $0000;
  intr(CDROM_INTERRUPT, REG);

  { Version 1.0 Returns 0 instead of actual Version Number }
  { So we will fix it so that this routine returns 1.0     }

  if REG.BX = 0 then begin
    CDR_VERSION := $0100;
  end else begin
    CDR_VERSION := REG.BX;
  end;
end;

procedure CDR_GET_DRIVE_UNITS(var BUFFER: CDR_DRIVE_UNITS);
assembler;

{ Returns a list of the systemwide logical drive identifers     }
{ that are assigned to CD-ROM drives.                           }

{ Upon return the buffer contains a series of 1 byte entries.   }
{ Each entry is a logical unit code assigned to a CD-ROM drive  }
{ (0 = A, 1 = B, etc); the units might not be consecutive.      }

{ The number of valid entries can be determined by MSCDEX       }
{ function 00h.                                                 }

asm
  mov ax, 150dh
  les bx, BUFFER
  int CDROM_INTERRUPT
end;

end.

