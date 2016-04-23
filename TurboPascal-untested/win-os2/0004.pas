{
 I am writing a Dos based Program in Turbo Pascal 6.0 that Uses a
 GUI Interface. My problem is that I would like to be able to import
 Windows or OS/2 icons to use instead of making my own. Does anyone
 know the File Format For either of these Files or better yet have
 source code For displaying them. Any help would be greatly appreciated.

The following code is a Unit I wrote to handle Windows icon Files. I
don't have the code yet For OS/2 icon Files, although I believe they are
quite similar. As Far as displaying the icons, just pass a Pointer
to the icon to your Graphics routines and let them decode and display
the structures. You should also be able to use a subset of the
structures to decode icons embedded in Windows .EXE Files.

At offset $24 in the "new executable" header For Windows and OS/2 .EXE
Files is a Word Variable that specifies an additional offset to the
resource table.
}

Unit WinIcons;

(********************************)Interface(*********************************)

Type
  tBMPInfoHdr = Record
    vHdrSize,                 (* Always 40 For Windows icons *)
    vPixelWidth,
    vPixelHeight   : LongInt;
    vColorPlanes,             (* Should always be 1 *)
    vBitCount      : Word;
    vCompression,
    vImageSize,
    vXPelsPerMeter,
    vYPelsPerMeter,
    vClrUsed,
    vClrImportant  : LongInt;
  end;

  tWinIconColor = Record
    vBlue,
    vGreen,
    vRed,
    vUnused : Byte;
  end;

  tRGBTable = Array[0..15] of tWinIconColor;

  txorMask = Array[0..511] of Byte;

  tandMask = Array[0..127] of Byte;

  tWinIcon = Record                (* The icon itself *)
    vBMPInfoHdr : tBMPInfoHdr;
    vRGBTable   : tRGBTable;
    vxorMask    : txorMask;
    vandMask    : tandMask;
  end;

  tWinIconDirEntry = Record        (* Icon File directory entry.  *)
    vIconWidth,                    (* 1 For each icon in the File *)
    vIconHeight,
    vColorCount,
    vReserved    : Byte;
    vPlanes,
    vBitCount    : Word;
    vBytesInRes,
    vImageoffset : LongInt;
  end;

  (* The following two Arrays have to be sized at run-time as they can  *)
  (* hold up to 65,535 entries. The actual number of entries is set by  *)
  (* vIdCount. When reading an icon File, read in the vIdCount Variable *)
  (* and then use GetMem to allocate the correct amount of heap.        *)

  tDirListPtr = ^tDirList;
  tDirList    = Array[1..1] of tWinIconDirEntry;

  tIconListPtr = ^tIconList;
  tIconList    = Array[1..1] of tWinIcon;

  tWinIconFileRec = Record
    vIdReserved,
    vIdType,
    vIdCount     : Word;
    vDirList     : tDirListPtr;
    vIconList    : tIconListPtr;
  end;


  tWinIconFile = File of tWinIconFileRec;

Var
  vWinIconFile : tWinIconFile; (* Hook to access icon Files *)

(******************************)Implementation(******************************)

end.
