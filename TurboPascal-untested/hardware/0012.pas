Unit CPU;

INTERFACE

Type
  CpuType = ( cpu8088,
              cpu8086,
              cpu80286,
              cpu80386,
              cpu80486,
              cpuPentium,
              cpuFuture
             );
  CpuStrType = String[7];

Function GetCpuType : CpuType;
  { Returns the currently executing CPU type }

Function GetCpuTypeStr : CpuStrType;
  { Returns the currently executing CPU type as a string }

IMPLEMENTATION

Const
  CpuTypeIdentified : Boolean = False;
Var
  ConfirmedCpuType : CpuType;

{$L CPU.OBJ}

{$F+}
Function WhichCPU : CpuType;
  { Determines and returns the currently executing CPU type }
EXTERNAL;
{$F-}

Procedure IdentifyCpuType;
  { Handles initialization of CPU type }
Begin
  If Not CpuTypeIdentified Then
  Begin
    ConfirmedCpuType  := WhichCPU;
    CpuTypeIdentified := True;
  End;
End;   { Procedure IdentifyCpuType }

Function GetCpuType : CpuType;
  { Returns the currently executing CPU type }
Begin
  IdentifyCpuType;
  GetCpuType := ConfirmedCpuType;
End;   { Function GetCpuType }

Function GetCpuTypeStr : CpuStrType;
  { Returns the currently executing CPU type as a string }
Begin
  IdentifyCpuType;
  Case ConfirmedCpuType Of
    cpu8088    : GetCpuTypeStr := '8088';
    cpu8086    : GetCpuTypeStr := '8086';
    cpu80286   : GetCpuTypeStr := '80286';
    cpu80386   : GetCpuTypeStr := '80386';
    cpu80486   : GetCpuTypeStr := '80486';
    cpuPentium : GetCpuTypeStr := 'Pentium';
    cpuFuture  : GetCpuTypeStr := 'Future';
  End;   { Case }
End;   { Function GetCpuTypeStr }

End.
{ eof CPU.PAS }


NOTE  :    Cut the following code to a seperate file, and then
           USE XX34 to DECODE the block which contains CPU.OBJ
           needed with this unit.

*XX3401-000399-290893--68--85-63424---------CPU.OBJ--1-OF--1
U+s+14BkRKZYMLBh9Y3HHE466++++-lIRL7WPm--QrBZPK7gNL6U63NZQbBdPqsUAmsm
aMUI+21dBaTF4UlXQ5JdN43nPGt-Iop0W+A+ECZAZU6++4W6+k-+cNGK-U+2Eox2FIKM
-k-6wk+0+E2WY+w+++26JoV7EoV1I3I+++1xW+E+E86-YO1r++2++-uAm6vMu-k+D+7x
-SUk+CgFu2Y+D+Bw0iVV+1k2T+DcV++TmtmQKs5XzkxHbNlPUSA+w1D+UTg+w5E0g+8R
kkOAm6v+zPc-+9xM+90EiEA+wufwY70EGd0EWw65ktkD+S1Fq5A3i+A+ul0s+5-EbNlM
UCFki+6+R+3+bQC9y6jQNdlab4NMNUo+++E+NZ-abKOQNZVaeE++-+-o+t0EFqORWyC9
lwBab4NMNcjMNXI++0++NZ-abKOQNZVaIqORNWI++0++Nc5X+++U+4MvkrESY7-ai+2+
+++Dch5coSXFuB5coSXFuB5coSUZ1k11i+E+kumQ-E12GJE-zMc0++-o
***** END OF XX-BLOCK *****


