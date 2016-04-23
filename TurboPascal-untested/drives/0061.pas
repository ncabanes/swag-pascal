{
 A few days ago, Bryan Ellis (gt6918b@prism.gatech.edu) mentioned
 that he had trouble with the DiskFree function of TP.
 I did'nt see any answer on this subject posted to the list.
 Since I also feel that this function yields misleading
 results to the unaware, and available clusters on the disk
 are also a requisite for full information, I post below a
 small program to document another way to implement the
 Diskfree function.

That part of the following code referring to the identification
of ramdisks has already been posted on info-pascal@brl.mil; I have
added the procedure DiskEval to display info about the drive, because
I have found that many users are not aware of the notion of 'slack'
which is the consequence of the use of clusters.
}

{$N+,E+}

program diskall;

{
displays all drives (except network drives :-() actually in use by
the system, mentions when one is mapped to another one (such as B: to
A: in systems with only one floppy drive), tries to identify RAM
disks but fails to do so with 'Stacked' disks and possibly also with
'Doublespaced' drives: I refrained from trying the latter on _MY_
stacked HD! The program further shows the available space on the disk
chosen by the user among available drives.
From what I have gathered in books and on the net, there is no fail-
safe way of identifying RAM disks. If somebody among the readers of
this should know otherwise, I would be grateful if he could email me
the solution at:
 desclinj@ulb.ac.be  (internet; Dr Jean Desclin)
                     (Lab. of Histology, Fac. of Medicine)
                     (Brussels Free University (U.L.B.) Belgium)
}
uses Dos,CRT;

Type String25 = String[25];

var
    ver               : byte;
    DrvStr            : String;
    DrvLet            : char;
    Count             : shortint;
    car               : char;

Procedure Pinsert(var chain: string25);
{Eases reading long numbers by inserting decimal points(commas)}
Const pdec : string[1] = ',';
var nv     :    string25;
    loc    :    integer;
begin
  nv := chain;
  if length(chain) > 3 then
    begin
       loc := length(chain) - 2;
       Move(Nv[loc],Nv[succ(loc)],succ(Length(Nv))-loc);
       Move(Pdec[1],Nv[loc],1);
       inc(Nv[0]);
       while (pos(pdec[1],Nv) > 4) do
           begin
              chain := Nv;
              loc := pos(pdec[1],Nv) - 3;
              Move(Nv[loc],Nv[succ(loc)],succ(length(Nv)) - loc);
              Move(pdec[1],Nv[loc],1);
              inc(Nv[0])
           end;
    end;
  chain := nv
end;

procedure GetDrives1(var DS: string);{for DOS >= 3.x but <4.0       }
{Adapted from Michael Tischer's Turbo Pascal 6 System Programming,  }
{Abacus 1991, ISBN 1-55755-124-3                                    }
type DPBPTR    = ^DPB;           { pointer to a DOS Parameter Block }
     DPBPTRPTR = ^DPBPTR;           { pointer to a pointer to a DPB }
     DPB       = record       { recreation of a DOS Parameter Block }
                    Code  : byte;       { drive code (0=A, 1=B etc. }
                    dummy1: array [1..$07] of byte;{irrelevant bytes}
                    FatNb : byte; {Number of File Allocation Tables }
                    dummy2: array [9..$17] of byte;{irrelevant bytes}
                    Next  : DPBPTR;           { pointer to next DPB }
                 end;                    { xxxx:FFFF marks last DPB }

var Regs    : Registers;              { register for interrupt call }
    CurrDpbP : DPBPTR;                  { pointer to DPBs in memory }

begin
   {-- get pointer to first DPB ------------------------------------}

  Regs.AH := $52;{ function $52 returns ptr to 'List of Lists'      }
  MsDos( Regs );{ that's an UNDOCUMENTED DOS function !             }
  CurrDpbP := DPBPTRPTR( ptr( Regs.ES, Regs.BX ) )^;
  {-- follow the chain of DPBs--------------------------------------}
  repeat
    begin
     write(chr(ord('A')+CurrDpbP^.Code ),{ display device code  }
              ': ' );
     DS := DS + chr(ord('A')+CurrDpbP^.Code);
     if CurrDpbP^.Code > 0 then
       begin
         Regs.AX := $440E;
         Regs.BL := CurrDpbP^.Code;
         MsDos(Regs);
         if Regs.AL <> 0 then
           writeln(' is actually mapped to ',
                    chr(ord('A')+pred(CurrDpbP^.Code)))
       end;

     if ((CurrDpbP^.FatNb > 0) AND (CurrDpbP^.FatNb < 2)) then
        writeln(' (RAMDISK)');
    end;
     CurrDpbP := CurrDpbP^.Next;   { set pointer to next DPB        }
  until ( Ofs( CurrDpbP^ ) = $FFFF );  { until last DPB is reached }
 writeln
 end;

procedure GetDrives2(var DS: string);{for DOS versions>=4.0         }
{almost the same as GetDrives1, but for dummy2 which is one byte    }
{longer in DOS 4+                                                   }
type DPBPTR    = ^DPB;           { pointer to a DOS Parameter Block }
     DPBPTRPTR = ^DPBPTR;           { pointer to a pointer to a DPB }
     DPB       = record       { recreation of a DOS Parameter Block }
                  Code   : byte;      { drive code ( 0=A, 1=B etc.  }
                  dummy1 : array [1..$07] of byte;{ irrelevant bytes}
                  FatNb  : byte;{ Number of File Allocation Tables  }
                  dummy2 : array [9..$18] of byte;{ irrelevant bytes}
                  Next   : DPBPTR;          { pointer to next DPB   }
                 end;                    { xxxx:FFFF marks last DPB }

var Regs    : Registers;              { register for interrupt call }
    CurrDpbP : DPBPTR;                  { pointer to DPBs in memory }

begin
   {-- get pointer to first DPB-------------------------------------}

  Regs.AH := $52;{ function $52 returns ptr to Dos 'List of lists'  }
   MsDos( Regs );{ that's an UNDOCUMENTED DOS function !            }
 CurrDpbP := DPBPTRPTR( ptr( Regs.ES, Regs.BX ) )^;

  {-- follow the chain of DPBs -------------------------------------}

  repeat
    begin
     write( chr( ord('A') + CurrDpbP^.Code ),{ display device code  }
              ': ');
     DS := DS + chr(ord('A')+CurrDpbP^.Code);
     if CurrDpbP^.Code > 0 then
       begin
         Regs.AX := $440E;
         Regs.BL := CurrDpbP^.Code;
         MsDos(Regs);
         if Regs.AL <> 0 then
           writeln(' is actually mapped to ',
                    chr(ord('A')+pred(CurrDpbP^.Code)))
       end;
     if ((CurrDpbP^.FatNb > 0) AND (CurrDpbP^.FatNb < 2)) then
        writeln(' (RAMDISK)');
    end;
     CurrDpbP := CurrDpbP^.Next;   { set pointer to next DPB        }
   until ( Ofs( CurrDpbP^ ) = $FFFF );  { until last DPB is reached }
   writeln
 end;

Procedure DiskEval;
{computes statistics of disk chosen by user}

var Reg : registers;
    Drive             : char;
    column,row        : shortint;
    SectorsPerCluster : Word;
    AvailClusters     : Word;
    BytesPerSector    : Word;
    TotalClusters     : Word;
    BytesAvail,Clut   : longint;
    Kilos             : extended;
    ByAl              : string25;
    TotClut           : string25;
    OneClut           : string25;
    AvailClut         : string25;
begin
    write('');
    column  := whereX;
    row     := whereY;
    repeat
       gotoXY(column,row);
       write('Which drive to read from? ',' ',chr(8));
       read(Drive);
       Drive := UpCase(Drive);
    until (pos(Drive,DrvStr) <> 0);
    writeln;
    with Reg do begin
         DL := ord(Drive) - 64;
         AH := $36;
         Intr($21,Reg);
         SectorsPerCluster  := AX;
         AvailClusters      := BX;
         BytesPerSector     := CX;
         TotalClusters      := DX
    end;
    BytesAvail := longint(BytesPerSector) * longint(SectorsPerCluster)
                  * longint(AvailClusters);
    Kilos := BytesAvail/1024;
    clut := longint(SectorsPerCluster)*longint(BytesPerSector);
    Str(BytesAvail,Byal);
    Pinsert(Byal);
    Str(AvailClusters,AvailClut);
    Pinsert(AvailClut);
    Str(Clut,OneClut);
    Pinsert(OneClut);
    Str(TotalClusters,TotClut);
    Pinsert(Totclut);
    clrscr;
    if SectorsPerCluster <> 65535 then
      begin
        write('For drive ');
        HighVideo;
        write(Drive);
        LowVideo;
        writeln(':');
        writeln('Sectors per cluster: ',SectorsPerCluster);
        writeln('Bytes per sector: ',BytesPerSector);
        writeln('Total clusters: ',TotClut);
        writeln('Available clusters: ',AvailClut);
        write('(One cluster = ',oneclut,' bytes: the smallest');
        writeln(' allocatable space!)');
        write('A TOTAL of ',ByAl,' BYTES are AVAILABLE (',Kilos:6:3);
        writeln(' K)') {previous line split for display: length <73 }
      end
    else writeln('There is no diskette in drive ',Drive,': !')
end;

begin
   car := #0;
   repeat
      DrvStr := '';
      DrvLet := #0;
      clrscr;
      ver := Lo(DosVersion);
      writeln('Installed logical drives are : '#13#10);
      if ver < 4 then
        GetDrives1(DrvStr)
      else
        GetDrives2(DrvStr);
      DiskEval;
      writeln;
      write('type ''Y'' to continue, any other key to exit.');
      car := upcase(readkey);
   until (car <> 'Y')
end.
