(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0019.PAS
  Description: Self Modify EXE File
  Author: KELD R. HANSEN
  Date: 07-16-93  06:11
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 07-03-93 (11:56)             Number: 29412
From: KELD R. HANSEN               Refer#: NONE
  To: JON JASIUNAS                  Recvd: NO  
Subj: Re: Self-modifying .EXEs       Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
In a message dated 28 Jun 93, Jon Jasiunas (1:273/216.0) wrote:

 > Here's the code I use for my self-modifying .EXEs.  I've used it
 > successfully in several applications.

It works fine (I have one similar of my own), but it doesn't take care of DPMI
programs and won't work if your "customer" PKLITEs the program.

TYPE
  ExeHeaderDOS          = RECORD
                { 00 }      Signature           : ARRAY[1..2] OF CHAR;
                { 02 }      LastPageSize        : WORD;
                { 04 }      Pages               : WORD;
                { 06 }      RelocItems          : WORD;
                { 08 }      HeaderSizePara      : WORD;
                { 0A }      MinMemPara          : WORD;
                { 0C }      MaxMemPara          : WORD;
                { 0E }      EntrySS             : WORD;
                { 10 }      EntrySP             : WORD;
                { 12 }      CheckSum            : WORD;
                { 14 }      EntryIP             : WORD;
                { 16 }      EntryCS             : WORD;
                { 18 }      FirstRelocItemOfs   : WORD;
                { 1A }      OverlayNumber       : WORD;
                            Reserved            : ARRAY[$1C..$23] OF BYTE;
                { 24 }      IdentifierOEM       : WORD;
                { 26 }      InformationOEM      : WORD;
                            ReservedToo         : ARRAY[$28..$3B] OF BYTE;
                { 3C }      NewExeHeaderOfs     : LONGINT
                          END;
  ExeHeaderOS2          = RECORD
                            Signature           : ARRAY[1..2] OF CHAR;
                            LinkerMajorVers     : BYTE;
                            LinkerMinorVers     : BYTE;
                            EntryTableOfs       : WORD;
                            EntryTableSize      : WORD;
                            CRC                 : LONGINT;
                            ModuleFlags         : WORD;
                            SegmentNoDGROUP     : WORD;
                            HeapSize            : WORD;
                            StackSize           : WORD;
                            EntryIP             : WORD;
                            EntryCS             : WORD;
                            EntrySP             : WORD;
                            EntrySS             : WORD;
                            SegmentTableEntries : WORD;
                            ModuleRefEntries    : WORD;
                            NonResNameTableSize : WORD;
                            SegTableOfs         : WORD;
                            ResourceTableOfs    : WORD;
                            ResNamesTableOfs    : WORD;
                            ModuleRefTableOfs   : WORD;
                            ImpNamesTableOfs    : WORD;
                            NonResNamesTableOfs : LONGINT;
                            MovableEntryPoints  : WORD;
                            AlignmentUnitPower  : WORD;
                            ResourceTableEntries: WORD;
                            TargetOS            : BYTE;
                            WindowsFlags        : BYTE;
                            FastLoadStart       : WORD;
                            FastLoadSize        : WORD;
                            Reserved            : WORD;
                            WindowsVers         : WORD
                          END;
  SegTableRec           = RECORD
                            Start               : WORD;
                            Size                : WORD;
                            Flags               : WORD;
                            MinSize             : WORD
                          END;
  FileOffset            = LONGINT;

PROCEDURE ReadOnly;
  INLINE($C6/$06/FileMode/$A0);

PROCEDURE ReadWrite;
  INLINE($C6/$06/FileMode/$02);

{ ExeOfs returns the offset of the item V in the .EXE file of the currently   }
{ running program. Use this to get the offset of a configuration record that  }
{ is located in the .EXE file (remember that you must declare it as a typed   }
{ constant to include it in the .EXE file)                                    }

{$IFDEF DPMI }
FUNCTION ExeOfs(CONST V) : FileOffset;
  VAR
    HeaderDOS   : ExeHeaderDOS;
    HeaderOS2   : ExeHeaderOS2;
    FIL         : FILE;
    CodeSeg,Seg : WORD;
    SegTab      : SegTableRec;

  BEGIN
    ReadOnly;
    ASSIGN(FIL,ParamStr(0)); RESET(FIL,1);
    BLOCKREAD(FIL,HeaderDOS,SizeOf(ExeHeaderDOS));
    IF HeaderDOS.Signature<>'MZ' THEN
      ExeOfs:=-1
    ELSE BEGIN
      SEEK(FIL,HeaderDOS.NewExeHeaderOfs);
      BLOCKREAD(FIL,HeaderOS2,SizeOf(ExeHeaderOS2));
      IF HeaderOS2.Signature<>'NE' THEN
        ExeOfs:=-1
      ELSE BEGIN
        ASM
                MOV     BX,WORD PTR V+2
                MOV     CX,SS
                CMP     BX,CX
                JE      @STACK
                XOR     AX,AX
                VERW    BX
                JZ      @OUT
                MOV     ES,BX
                MOV     AX,ES:[0000h]
                JMP     @OUT
        @STACK: MOV     AX,HeaderOS2.EntrySS
        @OUT:   MOV     CodeSeg,AX
        END;
        IF CodeSeg<>0 THEN BEGIN
          SEEK(FIL,HeaderDOS.NewExeHeaderOfs+HeaderOS2.SegTableOfs+
            PRED(CodeSeg)*SizeOf(SegTableRec));
          BLOCKREAD(FIL,SegTab,SizeOf(SegTableRec)) END
        ELSE BEGIN
          SEEK(FIL,HeaderDOS.NewExeHeaderOfs+HeaderOS2.SegTableOfs);
          FOR Seg:=1 TO HeaderOS2.SegmentTableEntries DO BEGIN
            BLOCKREAD(FIL,SegTab,SizeOf(SegTableRec));
            IF (SegTab.Start>0) AND (SegTab.Flags AND $0001=$0001) THEN BREAK
          END
        END;
        ExeOfs:=SegTab.Start SHL HeaderOS2.AlignmentUnitPower+OFS(V)
      END
    END;
    CLOSE(FIL);
    ReadWrite
  END;
{$ELSE }
FUNCTION ExeOfs(CONST V) : FileOffset;
  VAR
    HeaderDOS   : ExeHeaderDOS;
    FIL         : FILE;

  BEGIN
    ReadOnly;
    ASSIGN(FIL,ParamStr(0)); RESET(FIL,1);
    BLOCKREAD(FIL,HeaderDOS,SizeOf(ExeHeaderDOS));
    CLOSE(FIL);
    ExeOfs:=(HeaderDOS.HeaderSizePara+(SEG(V)-(PrefixSeg+$0010)))*16+OFS(V)
  END;
{$ENDIF }

