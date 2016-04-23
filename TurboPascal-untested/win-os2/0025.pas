(*
In article 767298319@stimpy.cs.iastate.edu, james@cs.iastate.edu (James N. Potts) writes:
>I know that if you place {$D string} in a program, the string will be placed
>into the executable.  Is there an easy way to find this information, or do
>you have to do a search through the file?

There are a few ways.  Screen savers use this information, so one way
to do it is to rename your file *.scr, place it in the windows directory,
and then look at it from the control panel as you are selecting a screen
saver.  Yeach!  Another way is to use a file dumper (?) such as
TDUMP by Borland or EXEHDR by Microsoft.  These programs will give you
the pertinent information.  TDUMP by the way comes with BP 7.0.

Programmaticly you can obtain the string through the new executable
file header information.  The string you are interested in is the
first entry in the nonresident-name table.  If you do not specify
{$D string} then this string will be the file name (like myfile.EXE).

A few days ago I posted how to do certain things with the new executable
file header.  You may want to look back a few days on your news reader
to get some insight.  But don't dispare.  I will give some clues here.

The first thing to do is to read the new EXE file format found
in the Borland or Micrsoft help files.  For Borland it can
be found under the "File Formats" topic.

Next you should get the EXE header types.  This can be obtained
at ftp.microsoft.com (filename: newexe12.zip).  I have
included a Pascal version at the end of this missive.

Now in your program you need to do the following:

  1.  Determine if the file is of the new EXE type.
  2.  Get the address of the non-resident name table.
  3.  Read the first string in the non-resident name table.

Later in this missive you will find a function that does step 1.
Below are the steps
*)

uses
  WinCrt,
  WinTypes,
  WinProcs;

const
  fn: PChar = 'c:\bp\myprog\myprog.exe';

type
  DosHdr           : IMAGE_DOS_HEADER;
  NewHdr           : IMAGE_NEW_HEADER;
  ModuleDescription: rsrc_string;
  Filehandle       : Integer;
  ofs              : TOFSTRUCT;

label
  Return;

begin
if not IsNewExe (fn, DosHdr, NewHdr) then goto Return;

FillChar (ofs, sizeof (TOFSTRUCT), 0);
if OpenFile (fn, ofs, OF_EXIST or OF_READ) = -1 then goto Return;

FileHandle := OpenFile (fn, ofs, OF_REOPEN or OF_READ);
if FileHandle = -1 then goto Return;

{ goto location of non-resident name table }
_llseek (FileHandle, DosHdr.e_lfanew + NewHdr.ne_nrestab, 0);

{ read length of string (in first entry of the non-resident name table) }
_lread (FileHandle, @ModuleDescription.rs_len, sizeof (Byte));

{ allocate space for string }
GetMem (ModuleDescription.rs_string, ModuleDescription.rs_len + 1);

{ read module description string }
_lread (FileHandle, @ModuleDescription.rs_string, ModuleDescription.rs_len);

{ tag null termination onto string }
ModuleDescription.rs_string[ModuleDescription.rs_len] := #0;

{ write results }
writeln (fn, ' Module Description: ', ModuleDescription.rs_string);

{ dispose of string }
FreeMem (ModuleDescription.rs_string, ModuleDescription.rs_len + 1);

Return:
{ close file }
_lclose (FileHandle);
end.


Note that the above code is only good for finding the first string
in the non-resident name table as the rest of the table also includes
index numbers as wll as the string length and the string.  This code
has also not been tested.

I hope you get some mileage from it.

-Michael Vincze
vincze@lobby.ti.com

---------- NEW EXE HEADER TYPES ----------

type
  IMAGE_DOS_HEADER = record     { DOS 1, 2, 3 .EXE header     }
    e_magic   : Word;     { Magic number                      }
    e_cblp    : Word;     { Words on last page of file        }
    e_cp      : Word;     { Pages in file                     }
    e_crlc    : Word;     { Relocations                       }
    e_cparhdr : Word;     { Size of header in paragraphs      }
    e_minalloc: Word;     { Minimum extra paragraphs needed   }
    e_maxalloc: Word;     { Maximum extra paragraphs needed   }
    e_ss      : Word;     { Initial (relative) SS value       }
    e_sp      : Word;     { Initial SP value                  }
    e_csum    : Word;     { Checksum                          }
    e_ip      : Word;     { Initial IP value                  }
    e_cs      : Word;     { Initial (relative) CS value       }
    e_lfarlc  : Word;     { File address of relocation table  }
    e_ovno    : Word;     { Overlay number                    }
    e_res     : array[0..3] of Word;  { Reserved words        }
    e_oemid   : Word;     { OEM identifier (for e_oeminfo)    }
    e_oeminfo : Word;     { OEM information; e_oemid specific }
    e_res2    : array[0..9] of Word;  { Reserved words        }
    e_lfanew  : Longint;  { File address of new exe header    }
    end;

const
  IMAGE_DOS_SIGNATURE    = $00005A4D; { MZ    }
  IMAGE_OS2_SIGNATURE    = $0000454E; { NE    }
  IMAGE_OS2_SIGNATURE_LE = $00005A4D; { LE    }
  IMAGE_NT_SIGNATURE     = $00004550; { PE00  }

type
  IMAGE_NEW_HEADER = record { New .EXE header                       }
    ne_magic      : Word;     { Magic number NE_MAGIC               }
    ne_ver        : Byte;     { Version number                      }
    ne_rev        : Byte;     { Revision number                     }
    ne_enttab     : Word;     { Offset of Entry Table               }
    ne_cbenttab   : Word;     { Number of bytes in Entry Table      }
    ne_crc        : Longint;  { Checksum of whole file              }
    ne_flags      : Word;     { Flag word                           }
    ne_autodata   : Word;     { Automatic data segment number       }
    ne_heap       : Word;     { Initial heap allocation             }
    ne_stack      : Word;     { Initial stack allocation            }
    ne_csip       : Longint;  { Initial CS:IP setting               }
    ne_sssp       : Longint;  { Initial SS:SP setting               }
    ne_cseg       : Word;     { Count of file segments              }
    ne_cmod       : Word;     { Entries in Module Reference Table   }
    ne_cbnrestab  : Word;     { Size of non-resident name table     }
    ne_segtab     : Word;     { Offset of Segment Table             }
    ne_rsrctab    : Word;     { Offset of Resource Table            }
    ne_restab     : Word;     { Offset of resident name table       }
    ne_modtab     : Word;     { Offset of Module Reference Table    }
    ne_imptab     : Word;     { Offset of Imported Names Table      }
    ne_nrestab    : Longint;  { Offset of Non-resident Names Table  }
    ne_cmovent    : Word;     { Count of movable ent                }
    ne_align      : Word;     { Segment alignment shift count       }
    ne_cres       : Word;     { Count of resource entries           }
    ne_exetyp     : Byte;     { Target operating system             }
    ne_flagsothers: Byte;     { Other .EXE flags                    }
    ne_res        : array [0..7] of Byte; { Pad structure to 64 bytes }
    end;

const { Format of ne_exetyp (target operating system) }
  NE_UNKNOWN = $0;  { Unknown (any "new-format" OS) }
  NE_OS2     = $1;  { Microsoft/IBM OS/2            }
  NE_WINDOWS = $2;  { Microsoft Windows             }
  NE_DOS4    = $3;  { Microsoft MS-DOS 4.x          }
  NE_DEV386  = $4;  { Microsoft Windows 386         }

const { Format of IMAGE_NEW_HEADER.ne_flags                     }
  NENOTP         = $8000; { Not a process                       }
  NEIERR         = $2000; { Errors in image                     }
  NEBOUND        = $0800; { Bound as family app                 }
  NEAPPTYP       = $0700; { Application type mask               }
  NENOTWINCOMPAT = $0100; { Not compatible with P.M. Windowing  }
  NEWINCOMPAT    = $0200; { Compatible with P.M.                }
  NEWINAPI       = $0300; { Uses P.M. Windowing API             }
  NEFLTP         = $0080; { Floating-point instructions         }
  NEI386         = $0040; { 386 instructions                    }
  NEI286         = $0020; { 286 instructions                    }
  NEI086         = $0010; { 8086 instructions                   }
  NEPROT         = $0008; { Runs in protected mode only         }
  NEPPLI         = $0004; { Per-Process Library Initialization  }
  NEINST         = $0002; { Instance data                       }
  NESOLO         = $0001; { Solo data                           }

type
  new_seg = record  { New .EXE segment table entry        }
    ns_sector  : Word;  { File sector of start of segment }
    ns_cbseg   : Word;  { Number of bytes in file         }
    ns_flags   : Word;  { Attribute flags                 }
    ns_minalloc: Word;  { Minimum allocation in bytes     }
    end;

const { Format of new_seg.nsflags                                                 }
  NSCODE    = $0000;  { Code segment                                              }
  NSDATA    = $0001;  { Data segment                                              }
  NSLOADED  = $0004;  { ns_sector field contains memory addr                      }
  NSTYPE    = $0007;  { Segment type mask                                         }
  NSITER    = $0008;  { Iterated segment flag                                     }
  NSMOVE    = $0010;  { Movable segment flag                                      }
  NSSHARED  = $0020;  { Shared segment flag                                       }
  NSPRELOAD = $0040;  { Preload segment flag                                      }
  NSEXRD    = $0080;  { Execute-only (code segment), or  read-only (data segment) }
  NSRELOC   = $0100;  { Segment has relocations                                   }
  NSCONFORM = $0200;  { Conforming segment                                        }
  NSDISCARD = $1000;  { Segment is discardable                                    }
  NS32BIT   = $2000;  { 32-bit code segment                                       }
  HSHUGE    = $4000;  { Huge memory segment                                       }
  NSEXPDOWN = $0200;  { Data segment is expand down                               }

(*
#define NSDPL   0x0C00    /* I/O privilege level (286 DPL bits) */
#define SHIFTDPL  10    /* Left shift count for */
#define NSPURE    NSSHARED  /* For compatibility */
#define NSALIGN 9 /* Segment data aligned on 512 byte boundaries */
*)

type
  new_rlcinfo = record  { Relocation info                       }
    nr_nreloc: Word;  { number of relocation items that follow  }
    end;

type
  new_rlc = record  { Relocation item }
    nr_stype: Byte; { Source type     }
    nr_flags: Byte; { Flag byte       }
    nr_soff : Word; { Source offset   }
    case Integer of
      0: (nr_segno : Byte;  { Target segment number             } { internal reference      }
          nr_res   : Byte;  { Reserved                          }
          nr_entry : Word); { Target Entry Table offset         }
      1: (nr_mod   : Word;  { Index into Module Reference Table } { import                  }
          nr_proc  : Word); { Procedure ordinal or name offset  }
      2: (nr_ostype: Word;  { OSFIXUP type                      } { operating system fixup  }
          nr_osres : Word); { Reserved                          }
    end;

{ Resource type or name string
}
type
  rsrc_string = record
    rs_len   : Byte;  { number of bytes in string }
    rs_string: PChar; { text of string            }
    end;


---------- IsNewExe() function ----------

Below is the code to determine if the file is of the new EXE type.
Note how DosHdr and NewHdr are passed by reference and not by value.
This is so values for DosHdr and NewHdr can be used by other
functions called by the main program.  Also note the extensive use
of the OpenFile(), _lread(), _llseek(), and _lclose() functions.

  function IsNewExe (fn: PChar;
                     var DosHdr: IMAGE_DOS_HEADER;
                     var NewHdr: IMAGE_NEW_HEADER): Boolean;
  label
    Return;
  var
    Filehandle: Integer;
    BytesRead : Integer;
    ofs       : TOFSTRUCT;
  begin
  IsNewExe := False;

  FillChar (ofs, sizeof (TOFSTRUCT), 0);
  if OpenFile (fn, ofs, OF_EXIST or OF_READ) = -1 then goto Return;

  FileHandle := OpenFile (fn, ofs, OF_REOPEN or OF_READ);
  if FileHandle = -1 then goto Return;

  FillChar (DosHdr, sizeof (IMAGE_DOS_HEADER), 0);
  FillChar (NewHdr, sizeof (IMAGE_NEW_HEADER), 0);

  { read MS-DOS header }
  BytesRead := _lread (FileHandle, @DosHdr, sizeof (IMAGE_DOS_HEADER));

  { test for bytes read }
  if BytesRead <> sizeof (IMAGE_DOS_HEADER) then goto Return;

  { test for magic number MZ }
  if DosHdr.e_magic <> IMAGE_DOS_SIGNATURE then goto Return;

  { test for address of new exe header }
  if DosHdr.e_lfanew <= 0 then goto Return;

  { fast forward to Windows header }
  if _llseek (FileHandle, DosHdr.e_lfanew, 0) = -1 then goto Return;

  { read new exe header }
  BytesRead := _lread (FileHandle, @NewHdr, sizeof (IMAGE_NEW_HEADER));

  { test for bytes read }
  if BytesRead <> sizeof (IMAGE_NEW_HEADER) then goto Return;

  { test for signature NE }
  if NewHdr.ne_magic <> IMAGE_OS2_SIGNATURE then goto Return;

  { passed the test }
  IsNewExe := True;

  Return:
  { close file }
  _lclose (FileHandle);
  end;

