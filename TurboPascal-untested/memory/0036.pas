{
Here a small piece of code to determine the DOS memory (that
would be available at the DOS prompt) from within a TP program. It
doesn't account for UMB and heap limited programs (the $M directive).
It returns (almost) the value chkdsk and mem return for largest
available block of dos memory.
}

FUNCTION Dosmem : LONGINT;

{----Returns Largest Free DOS memory as seen on the dos prompt by          }
{    CHKDSK and MEM.                                                       }

{----Records from The Programmer's PC Sourcebook by Thom Hogan, 1st Edition}

{    Only relevant field commented. Tuned by be equal to DR-DOS's 6.0}
{    MEM command. Works only if programs allocates all memory available}
{    so no max heaplimits to enable TP's Exec.}

Type
  MCBrec = RECORD
             location   : Char; {----'M' is normal block, 'Z' is last block }
             ProcessID,
             allocation : WORD; {----Number of 16 Bytes paragraphs allocated}
             reserved   : ARRAY[1..11] OF Byte;
           END;

  PSPrec = RECORD
             int20h,
             EndofMem        : WORD;
             Reserved1       : BYTE;
             Dosdispatcher   : ARRAY[1..5] OF BYTE;
             Int22h,
             Int23h,
             INT24h          : POINTER;
             ParentPSP       : WORD;
             HandleTable     : ARRAY[1..20] OF BYTE;
             EnvSeg          : WORD; {----Segment of Environment}
             Reserved2       : LONGINT;
             HandleTableSize : WORD;
             HandleTableAddr : POINTER;
             Reserved3       : ARRAY[1..23] OF BYTE;
             Int21           : WORD;
             RetFar          : BYTE;
             Reserved4       : ARRAY[1..9] OF BYTE;
             DefFCB1         : ARRAY[1..36] OF BYTE;
             DefFCB2         : ARRAY[1..20] OF BYTE;
             Cmdlength       : BYTE;
             Cmdline         : ARRAY[1..127] OF BYTE;
           END;

Var
  pmcb   : ^MCBrec;
  emcb   : ^MCBrec;
  psp    : ^PSPrec;
  dmem   : LONGINT;

Begin
   psp:=PTR(PrefixSeg,0);      {----PSP given by TP var                }
  pmcb:=Ptr(PrefixSeg-1,0);    {----Programs MCB 1 paragraph before PSP}
  emcb:=Ptr(psp^.envseg-1,0);  {----Environment MCB 1 paragraph before
                                    envseg                             }
  dosmem:=LONGINT(pmcb^.allocation+emcb^.allocation+1)*16;
End; {of DOSmem}

Begin
  Writeln(Dosmem,' Bytes available.');
End.
