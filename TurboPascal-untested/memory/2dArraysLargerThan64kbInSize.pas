(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0076.PAS
  Description: 2D Arrays larger than 64kb in size
  Author: WITOLD WALDMAN
  Date: 05-26-95  23:19
*)

{
witold@aed.dsto.gov.au

{--------------------------------------------------------------------------}

Program TestMat(Input,Output);

{ Description: Allocating/deallocating 2D arrays larger than 64kB in size  }
{ Date       : 12 December 1994                                            }
{ Author     : Witold Waldman                                              }
{                                                                          }
{ This is a sample program showing how to go about using the matrix memory }
{ allocation/deallocation functions contained in the unit MATMEM.          }
{                                                                          }
{ In this example, a two-dimensional array of double precision numbers is  }
{ allocated. The total size of the array is chosen to be greater than the  }
{ maximum size of a 64kB data segment to illustrate how the techniques     }
{ that are implemented here can be used to work with large matrices.       }
{                                                                          }
{ After the array storage has been created, each element of the array is   }
{ filled with a unique number, and the last element in each row is then    }
{ displayed on the screen.                                                 }
{                                                                          }
{ Finally, the array is deallocated and the heap is checked to see if any  }
{ memory leaks have occurred.                                              }
{                                                                          }
{ Because all memory allocation occurs on the heap at run-time, the use    }
{ of extended memory is automatic if the Borland Pascal program is         }
{ compiled as a protected mode application.                                }
{                                                                          }
{ The basic idea for the approach used here was taken from a short article }
{ by William F. Polik (PC Tech Journal, December 1986, p. 49).             }
{                                                                          }
{ Feel free to use this code as you see fit, and I hope that it provides   }
{ a useful example of how large arrays can be allocated and accessed from  }
{ Turbo Pascal without suffering too greatly from the 64kB segment limit   }
{ imposed by the medium memory model used by the compiler.                 }
{                                                                          }
{ NOTE: The source code to the MATMEM unit is located at the bottom of     }
{       this program. Just cut and paste it into a separate file.          }

{$N+}
{$E+}

{$M 65520,250000,655360 }

Uses CRT,MATMEM;

var
  AD        : pArrayDD;    { Pointer to a two-dimensional array of doubles }
  NR        : word;        { Maximum row dimension of array                }
  NC        : word;        { Maximum column dimension of array             }
  i         : word;        { Index variable used for traversing rows       }
  j         : word;        { Index variable used for traversing columns    }
  MemBefore : longint;     { Memory available before array allocation      }
  MemAlloc  : longint;     { Memory available after array allocation       }

begin

  ClrScr;

  { Configure the size of the 2D matrix we wish to allocate }

  NR := 2;
  NC := MaxSizeArrayD;

  { Allocate dynamic memory for the 2D array }

  MemBefore := MaxAvail;

  AD := NewArrayDD(NR,NC);

  MemAlloc := MaxAvail;

  { Check to see whether the pointer is nil. If it is, then }
  { the allocation of the array failed.                     }

  If AD = nil then
    begin
    Writeln('Not enough dynamic memory available for array.');
    Halt;
    end;

  { Write some info about what was just allocated on the heap }

  Writeln('Dynamic memory allocated for array = ',MemBefore-MaxAvail,' bytes');
  Writeln;
  Writeln('Number of array elements = ',(NR+1)*(NC+1));
  Writeln;

  { Proceed to access each element in the array and store a unique number   }
  { in each and every array location. Display the value of the last element }
  { in each row of the array for checking purposes.                         }

  For i := 0 to NR do
    begin
    For j := 0 to NC do
      begin
      AD^[i]^[j] := j*1.0E0 + i*100000.0E0;
      end;
    Writeln('Selected array contents: AD^[',i,']^[',NC,'] = ',
            AD^[i]^[NC]:10:1);
    end;

  { Deallocate dynamic memory for the 2D array }

  AD := DisposeArrayDD(AD,NR,NC);

  Writeln;
  Writeln('Dynamic memory deallocated = ',MaxAvail-MemAlloc,' bytes');

  If MaxAvail = MemBefore then
    begin
    Writeln;
    Writeln('No memory leaks detected.');
    end
  else
    begin
    Writeln;
    Writeln('A memory leak has been detected.');
    end;

end.

{---------------------------------------------------------------------------}

{$N+}
{$E+}

UNIT MATMEM;

INTERFACE

const
  PtrSize         = SizeOf(Pointer);
  MaxSegmentSize  = 65535;
  MaxSizeArrayP   = MaxSegmentSize div PtrSize         - 1;
  MaxSizeArrayR   = MaxSegmentSize div SizeOf(Real)    - 1;
  MaxSizeArrayS   = MaxSegmentSize div SizeOf(Single)  - 1;
  MaxSizeArrayD   = MaxSegmentSize div SizeOf(Double)  - 1;
  MaxSizeArrayI   = MaxSegmentSize div SizeOf(Integer) - 1;

type
  ArrayPtr = array [0..MaxSizeArrayP] of Pointer;
  ArrayR   = array [0..MaxSizeArrayR] of Real;
  ArrayS   = array [0..MaxSizeArrayS] of Single;
  ArrayD   = array [0..MaxSizeArrayD] of Double;
  ArrayI   = array [0..MaxSizeArrayI] of Integer;

  ArrayRR  = array [0..MaxSizeArrayP-1] of ^ArrayR;
  ArraySS  = array [0..MaxSizeArrayP-1] of ^ArrayS;
  ArrayDD  = array [0..MaxSizeArrayP-1] of ^ArrayD;
  ArrayII  = array [0..MaxSizeArrayP-1] of ^ArrayI;

  pArrayR  = ^ArrayR;
  pArrayS  = ^ArrayS;
  pArrayD  = ^ArrayD;
  pArrayI  = ^ArrayI;

  pArrayRR = ^ArrayRR;
  pArraySS = ^ArraySS;
  pArrayDD = ^ArrayDD;
  pArrayII = ^ArrayII;

{ Functions for allocating/deallocating single dimensional arrays. }
{                                                               }
{ NRmax = maximum number of rows allocated/deallocated.         }
{ NCmax = maximum number of columns allocated/deallocated.      }

function NewArrayS(Nmax:Word):Pointer;

function DisposeArrayS(A:Pointer; Nmax:Word):Pointer;

function NewArrayD(Nmax:Word):Pointer;

function DisposeArrayD(A:Pointer; Nmax:Word):Pointer;

function NewArrayI(Nmax:Word):Pointer;

function DisposeArrayI(A:Pointer; Nmax:Word):Pointer;

function NewArrayR(Nmax:Word):Pointer;

function DisposeArrayR(A:Pointer; Nmax:Word):Pointer;

{ Functions for allocating/deallocating two dimensional arrays. }
{                                                               }
{ NRmax = maximum number of rows allocated/deallocated.         }
{ NCmax = maximum number of columns allocated/deallocated.      }

function NewArraySS(NRmax,NCmax:Word):Pointer;

function DisposeArraySS(A:Pointer; NRmax,NCmax:Word):Pointer;

function NewArrayDD(NRmax,NCmax:Word):Pointer;

function DisposeArrayDD(A:Pointer; NRmax,NCmax:Word):Pointer;

function NewArrayII(NRmax,NCmax:Word):Pointer;

function DisposeArrayII(A:Pointer; NRmax,NCmax:Word):Pointer;

function NewArrayRR(NRmax,NCmax:Word):Pointer;

function DisposeArrayRR(A:Pointer; NRmax,NCmax:Word):Pointer;

IMPLEMENTATION

{==========================================================================}


function NewArray1D(Nmax:Word; DataSize:Integer):Pointer;

var
  MemP : Word;
  P    : Pointer;

begin
  MemP := (Nmax+1)*DataSize;
  If MaxAvail >= MemP then
    GetMem(P,MemP)
  else
    P := nil;
  NewArray1D := P;
end;

{==========================================================================}


function DisposeArray1D(A:Pointer; Nmax:Word; DataSize:Integer):Pointer;

begin
  If A <> nil then
    begin
    FreeMem(A,(Nmax+1)*DataSize);
    DisposeArray1D := nil;
    end;
end;

{==========================================================================}


function DisposeArray2D(A:Pointer; NRmax,NCmax:Word; DataSize:Integer):Pointer;

var
  I : Word;
  Q : ^ArrayPtr;

begin
  If A <> nil then
    begin
    Q := A;
    For I := 0 to NRmax do
      begin
      If Q^[I] <> nil then
        FreeMem(Q^[I],(NCmax+1)*DataSize);
      end;
    FreeMem(A,(NRmax+1)*PtrSize);
    DisposeArray2D := nil;
    end;
end;

{==========================================================================}


function NewArray2D(NRmax,NCmax:Word; DataSize:Integer):Pointer;

var
  Error : Boolean;
  I     : Word;
  MemP  : Word;        { Memory for pointers to each row of data }
  MemR  : Word;        { Memory for row of data                  }
  P     : ^ArrayPtr;

begin
  MemP := (NRmax+1)*PtrSize;
  If MaxAvail >= MemP then
    GetMem(P,MemP)
  else
    P := nil;
  If P <> nil then
    begin
    Error := false;
    MemR  := (NCmax+1)*DataSize;
    For I := 0 to NRmax do
      begin
      If MaxAvail >= MemR then
        GetMem(P^[I],MemR)
      else
        begin
        Error := true;
        P^[I] := nil;
        end;
      end;
    If Error then
      begin
      P := DisposeArray2D(P,NRmax,NCmax,DataSize);
      end;
    end;
  NewArray2D := P;
end;

{==========================================================================}


function NewArrayS(Nmax:Word):Pointer;

begin
  NewArrayS := NewArray1D(Nmax,SizeOf(Single));
end;

{==========================================================================}


function DisposeArrayS(A:Pointer; Nmax:Word):Pointer;

begin
  DisposeArrayS := DisposeArray1D(A,Nmax,SizeOf(Single));
end;

{==========================================================================}


function NewArrayD(Nmax:Word):Pointer;

begin
  NewArrayD := NewArray1D(Nmax,SizeOf(Double));
end;

{==========================================================================}


function DisposeArrayD(A:Pointer; Nmax:Word):Pointer;

begin
  DisposeArrayD := DisposeArray1D(A,Nmax,SizeOf(Double));
end;

{==========================================================================}


function NewArrayI(Nmax:Word):Pointer;

begin
  NewArrayI := NewArray1D(Nmax,SizeOf(Integer));
end;

{==========================================================================}


function DisposeArrayI(A:Pointer; Nmax:Word):Pointer;

begin
  DisposeArrayI := DisposeArray1D(A,Nmax,SizeOf(Integer));
end;

{==========================================================================}


function NewArrayR(Nmax:Word):Pointer;

begin
  NewArrayR := NewArray1D(Nmax,SizeOf(Real));
end;

{==========================================================================}


function DisposeArrayR(A:Pointer; Nmax:Word):Pointer;

begin
  DisposeArrayR := DisposeArray1D(A,Nmax,SizeOf(Real));
end;

{==========================================================================}


function NewArraySS(NRmax,NCmax:Word):Pointer;

begin
  NewArraySS := NewArray2D(NRmax,NCmax,SizeOf(Single));
end;

{==========================================================================}


function DisposeArraySS(A:Pointer; NRmax,NCmax:Word):Pointer;

begin
  DisposeArraySS := DisposeArray2D(A,NRmax,NCmax,SizeOf(Single));
end;

{==========================================================================}


function NewArrayDD(NRmax,NCmax:Word):Pointer;

begin
  NewArrayDD := NewArray2D(NRmax,NCmax,SizeOf(Double));
end;

{==========================================================================}


function DisposeArrayDD(A:Pointer; NRmax,NCmax:Word):Pointer;

begin
  DisposeArrayDD := DisposeArray2D(A,NRmax,NCmax,SizeOf(Double));
end;

{==========================================================================}


function NewArrayII(NRmax,NCmax:Word):Pointer;

begin
  NewArrayII := NewArray2D(NRmax,NCmax,SizeOf(Integer));
end;

{==========================================================================}


function DisposeArrayII(A:Pointer; NRmax,NCmax:Word):Pointer;

begin
  DisposeArrayII := DisposeArray2D(A,NRmax,NCmax,SizeOf(Integer));
end;

{==========================================================================}


function NewArrayRR(NRmax,NCmax:Word):Pointer;

begin
  NewArrayRR := NewArray2D(NRmax,NCmax,SizeOf(Real));
end;

{==========================================================================}


function DisposeArrayRR(A:Pointer; NRmax,NCmax:Word):Pointer;

begin
  DisposeArrayRR := DisposeArray2D(A,NRmax,NCmax,SizeOf(Real));
end;

END.

{$N+}
{$E+}

UNIT MATMEM;

INTERFACE

const
  PtrSize         = SizeOf(Pointer);
  MaxSegmentSize  = 65535;
  MaxSizeArrayP   = MaxSegmentSize div PtrSize         - 1;
  MaxSizeArrayR   = MaxSegmentSize div SizeOf(Real)    - 1;
  MaxSizeArrayS   = MaxSegmentSize div SizeOf(Single)  - 1;
  MaxSizeArrayD   = MaxSegmentSize div SizeOf(Double)  - 1;
  MaxSizeArrayI   = MaxSegmentSize div SizeOf(Integer) - 1;

type
  ArrayPtr = array [0..MaxSizeArrayP] of Pointer;
  ArrayR   = array [0..MaxSizeArrayR] of Real;
  ArrayS   = array [0..MaxSizeArrayS] of Single;
  ArrayD   = array [0..MaxSizeArrayD] of Double;
  ArrayI   = array [0..MaxSizeArrayI] of Integer;

  ArrayRR  = array [0..MaxSizeArrayP] of ^ArrayR;
  ArraySS  = array [0..MaxSizeArrayP] of ^ArrayS;
  ArrayDD  = array [0..MaxSizeArrayP] of ^ArrayD;
  ArrayII  = array [0..MaxSizeArrayP] of ^ArrayI;

  pArrayR  = ^ArrayR;
  pArrayS  = ^ArrayS;
  pArrayD  = ^ArrayD;
  pArrayI  = ^ArrayI;

  pArrayRR = ^ArrayRR;
  pArraySS = ^ArraySS;
  pArrayDD = ^ArrayDD;
  pArrayII = ^ArrayII;

{ Functions for allocating/deallocating single dimensional arrays. }
{                                                                  }
{ NRmax = maximum number of rows allocated/deallocated.            }
{ NCmax = maximum number of columns allocated/deallocated.         }

function NewArrayS(Nmax:Word):Pointer;

function DisposeArrayS(A:Pointer; Nmax:Word):Pointer;

function NewArrayD(Nmax:Word):Pointer;

function DisposeArrayD(A:Pointer; Nmax:Word):Pointer;

function NewArrayI(Nmax:Word):Pointer;

function DisposeArrayI(A:Pointer; Nmax:Word):Pointer;

function NewArrayR(Nmax:Word):Pointer;

function DisposeArrayR(A:Pointer; Nmax:Word):Pointer;

{ Functions for allocating/deallocating two dimensional arrays. }
{                                                               }
{ NRmax = maximum number of rows allocated/deallocated.         }
{ NCmax = maximum number of columns allocated/deallocated.      }

function NewArraySS(NRmax,NCmax:Word):Pointer;

function DisposeArraySS(A:Pointer; NRmax,NCmax:Word):Pointer;

function NewArrayDD(NRmax,NCmax:Word):Pointer;

function DisposeArrayDD(A:Pointer; NRmax,NCmax:Word):Pointer;

function NewArrayII(NRmax,NCmax:Word):Pointer;

function DisposeArrayII(A:Pointer; NRmax,NCmax:Word):Pointer;

function NewArrayRR(NRmax,NCmax:Word):Pointer;

function DisposeArrayRR(A:Pointer; NRmax,NCmax:Word):Pointer;

IMPLEMENTATION

{==============================================================================


function NewArray1D(Nmax:Word; DataSize:Integer):Pointer;

var
  MemP : Word;
  P    : Pointer;

begin
  MemP := (Nmax+1)*DataSize;
  If MaxAvail >= MemP then
    GetMem(P,MemP)
  else
    P := nil;
  NewArray1D := P;
end;

{==============================================================================


function DisposeArray1D(A:Pointer; Nmax:Word; DataSize:Integer):Pointer;

begin
  If A <> nil then
    begin
    FreeMem(A,(Nmax+1)*DataSize);
    DisposeArray1D := nil;
    end;
end;

{==============================================================================


function DisposeArray2D(A:Pointer; NRmax,NCmax:Word; DataSize:Integer):Pointer;

var
  I : Word;
  Q : ^ArrayPtr;

begin
  If A <> nil then
    begin
    Q := A;
    For I := 0 to NRmax do
      begin
      If Q^[I] <> nil then
        FreeMem(Q^[I],(NCmax+1)*DataSize);
      end;
    FreeMem(A,(NRmax+1)*PtrSize);
    DisposeArray2D := nil;
    end;
end;

{==========================================================================}


function NewArray2D(NRmax,NCmax:Word; DataSize:Integer):Pointer;

var
  Error : Boolean;
  I     : Word;
  MemP  : Word;        { Memory for pointers to each row of data }
  MemR  : Word;        { Memory for row of data                  }
  P     : ^ArrayPtr;

begin
  MemP := (NRmax+1)*PtrSize;
  If MaxAvail >= MemP then
    GetMem(P,MemP)
  else
    P := nil;
  If P <> nil then
    begin
    Error := false;
    MemR  := (NCmax+1)*DataSize;
    For I := 0 to NRmax do
      begin
      If MaxAvail >= MemR then
        GetMem(P^[I],MemR)
      else
        begin
        Error := true;
        P^[I] := nil;
        end;
      end;
    If Error then
      begin
      P := DisposeArray2D(P,NRmax,NCmax,DataSize);
      end;
    end;
  NewArray2D := P;
end;

{==========================================================================}


function NewArrayS(Nmax:Word):Pointer;

begin
  NewArrayS := NewArray1D(Nmax,SizeOf(Single));
end;

{==============================================================================


function DisposeArrayS(A:Pointer; Nmax:Word):Pointer;

begin
  DisposeArrayS := DisposeArray1D(A,Nmax,SizeOf(Single));
end;

{==============================================================================


function NewArrayD(Nmax:Word):Pointer;

begin
  NewArrayD := NewArray1D(Nmax,SizeOf(Double));
end;

{==============================================================================


function DisposeArrayD(A:Pointer; Nmax:Word):Pointer;

begin
  DisposeArrayD := DisposeArray1D(A,Nmax,SizeOf(Double));
end;

{==============================================================================


function NewArrayI(Nmax:Word):Pointer;

begin
  NewArrayI := NewArray1D(Nmax,SizeOf(Integer));
end;

{==============================================================================


function DisposeArrayI(A:Pointer; Nmax:Word):Pointer;

begin
  DisposeArrayI := DisposeArray1D(A,Nmax,SizeOf(Integer));
end;

{==============================================================================


function NewArrayR(Nmax:Word):Pointer;

begin
  NewArrayR := NewArray1D(Nmax,SizeOf(Real));
end;

{==============================================================================


function DisposeArrayR(A:Pointer; Nmax:Word):Pointer;

begin
  DisposeArrayR := DisposeArray1D(A,Nmax,SizeOf(Real));
end;

{==============================================================================


function NewArraySS(NRmax,NCmax:Word):Pointer;

begin
  NewArraySS := NewArray2D(NRmax,NCmax,SizeOf(Single));
end;

{==============================================================================


function DisposeArraySS(A:Pointer; NRmax,NCmax:Word):Pointer;

begin
  DisposeArraySS := DisposeArray2D(A,NRmax,NCmax,SizeOf(Single));
end;

{==============================================================================


function NewArrayDD(NRmax,NCmax:Word):Pointer;

begin
  NewArrayDD := NewArray2D(NRmax,NCmax,SizeOf(Double));
end;

{==============================================================================


function DisposeArrayDD(A:Pointer; NRmax,NCmax:Word):Pointer;

begin
  DisposeArrayDD := DisposeArray2D(A,NRmax,NCmax,SizeOf(Double));
end;

{==============================================================================


function NewArrayII(NRmax,NCmax:Word):Pointer;

begin
  NewArrayII := NewArray2D(NRmax,NCmax,SizeOf(Integer));
end;

{==============================================================================


function DisposeArrayII(A:Pointer; NRmax,NCmax:Word):Pointer;

begin
  DisposeArrayII := DisposeArray2D(A,NRmax,NCmax,SizeOf(Integer));
end;

{==============================================================================


function NewArrayRR(NRmax,NCmax:Word):Pointer;

begin
  NewArrayRR := NewArray2D(NRmax,NCmax,SizeOf(Real));
end;

{==============================================================================


function DisposeArrayRR(A:Pointer; NRmax,NCmax:Word):Pointer;

begin
  DisposeArrayRR := DisposeArray2D(A,NRmax,NCmax,SizeOf(Real));
end;

END.


