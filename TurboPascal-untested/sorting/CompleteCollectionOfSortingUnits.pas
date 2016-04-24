(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0066.PAS
  Description: Complete Collection of Sorting units
  Author: C.A.R. HOARE
  Date: 05-30-97  18:17
*)


{
> Can you show me any version of thew quick sort that you may have? I've
> never seen it and never used it before. I always used an insertion sort
> For anything that I was doing.

Here is one (long) non-recursive version, quite fast.
}

Type
  _Compare  = Function(Var A, B) : Boolean;{ QuickSort Calls This }

{ --------------------------------------------------------------- }
{ QuickSort Algorithm by C.A.R. Hoare.  Non-Recursive adaptation  }
{ from "ALGORITHMS + DATA STRUCTURES = ProgramS" by Niklaus Wirth }
{ Prentice-Hall, 1976. Generalized For unTyped arguments.   }
{ --------------------------------------------------------------- }

Procedure QuickSort(V      : Pointer;   { To Array of Records }
                    Cnt    : Word;      { Record Count        }
                    Len    : Word;      { Record Length       }
                    ALessB : _Compare); { Compare Function    }

Type
  SortRec = Record
    Lt, Rt : Integer
  end;

  SortStak = Array [0..1] of SortRec;

Var
  StkT,
  StkM,
  Ki, Kj,
  M       : Word;
  Rt, Lt,
  I, J    : Integer;
  Ps      : ^SortStak;
  Pw, Px  : Pointer;

  Procedure Push(Left, Right : Integer);
  begin
    Ps^[StkT].Lt := Left;
    Ps^[StkT].Rt := Right;
    Inc(StkT);
  end;

  Procedure Pop(Var Left, Right : Integer);
  begin
    Dec(StkT);
    Left  := Ps^[StkT].Lt;
    Right := Ps^[StkT].Rt;
  end;

begin {QSort}
  if (Cnt > 1) and (V <> Nil) Then
  begin
    StkT := Cnt - 1;    { Record Count - 1 }
    Lt   := 1;          { Safety Valve    }

    { We need a stack of Log2(n-1) entries plus 1 spare For safety }

    Repeat
      StkT := StkT SHR 1;
      Inc(Lt);
    Until StkT = 0; { 1+Log2(n-1) }

    StkM := Lt * SizeOf(SortRec) + Len + Len; { Stack Size + 2 Records }

    GetMem(Ps, StkM);   { Allocate Memory    }

    if Ps = Nil Then
      RunError(215); { Catastrophic Error }

    Pw := @Ps^[Lt];   { Swap Area Pointer  }
    Px := Ptr(Seg(Pw^), Ofs(Pw^) + Len); { Hold Area Pointer  }

    Lt := 0;
    Rt := Cnt - 1;  { Initial Partition  }

    Push(Lt, Rt);   { Push Entire Table  }

    While StkT > 0 Do
    begin  { QuickSort Main Loop }
      Pop(Lt, Rt);   { Get Next Partition  }
      Repeat
        I := Lt; J := Rt;  { Set Work Pointers }

        { Save Record at Partition Mid-Point in Hold Area }
        M := (LongInt(Lt) + Rt) div 2;
        Move(Ptr(Seg(V^), Ofs(V^) + M * Len)^, Px^, Len);

        { Get Useful Offsets to speed loops }
        Ki := I * Len + Ofs(V^);
        Kj := J * Len + Ofs(V^);

        Repeat
          { Find Left-Most Entry >= Mid-Point Entry }
          While ALessB(Ptr(Seg(V^), Ki)^, Px^) Do
          begin
            Inc(Ki, Len);
            Inc(I)
          end;

          { Find Right-Most Entry <= Mid-Point Entry }
          While ALessB(Px^, Ptr(Seg(V^), Kj)^) Do
          begin
            Dec(Kj, Len);
            Dec(J)
          end;

          { if I > J, the partition has been exhausted }
          if I <= J Then
          begin
            if I < J Then  { we have two Records to exchange }
            begin
              Move(Ptr(Seg(V^), Ki)^, Pw^, Len);
              Move(Ptr(Seg(V^), Kj)^, Ptr(Seg(V^), Ki)^, Len);
              Move(Pw^, Ptr(Seg(V^), Kj)^, Len);
            end;

            Inc(I);
            Dec(J);
            Inc(Ki, Len);
            Dec(Kj, Len);
          end; { if I <= J }
        Until I > J;  { Until All Swaps Done }

        { We now have two partitions.  At left are all Records }
        { < X, and at right are all Records > X.  The larger   }
        { partition is stacked and we re-partition the residue }
        { Until time to pop a deferred partition.              }

        if (J - Lt) < (Rt - I) Then { Right-Most Partition is Larger }
        begin
          if I < Rt Then
            Push(I, Rt); { Stack Right Side }
          Rt := J;    { Resume With Left }
        end
        else  {  Left-Most Partition is Larger }
        begin
          if Lt < J Then
            Push(Lt, J); { Stack Left Side   }
          Lt := I;    { Resume With Right }
        end;

      Until Lt >= Rt;  { QuickSort is now Complete }
    end;
    FreeMem(Ps, StkM);   { Free Stack and Work Areas }
  end;
end; {QSort}

{ ---------------------------   CUT  ----------------------------}
{
ALEXANDER CHRISTOV

 I don't know if code like this has been posted on this echo, but anyway here
it goes. It implements three different versions of Qsort which so far if the
fastest sorting algorithm known. However, it is not adequate For sorting File
Records. I've tested the routines and have worked With them For quite a While,
but don't trust me 8-) Murphy never sleeps 8-)
}

Unit SORT;
{─────────────────────────────────────────────────────────────────────────}
{ Purpose  : Unit that implements a generic QSort(), similar to           }
{            the one in the standard C library.                           }
{ Author   : Alexander Christov                                           }
{ Notes    : Very instructive on the use of Pointers in TP.               }
{                                                                         }
{  Use freely.                                                            }
{                                                                         }
{─────────────────────────────────────────────────────────────────────────}
Interface

Type CmpFunc=Function(El1,El2:Pointer):Boolean;

Procedure QSort(Base:Pointer;Elements,Size:Word;GT:CmpFunc);

{ Base      - Pointer to the first element
  Elements  - Number of elements
  Size      - Size of an element in Bytes. Use SizeOf() if in doubt
  GT        - A Function of Type CmpFunc that compares the elements pointed
              to by the first and the second arguments and returns True
              if the first is greater than the second. GT = Greater Than
              8-)
}

{ Some commonly used CmpFunc }

Function bGT(El1,El2:Pointer):Boolean;      { Compares ^Byte }
Function wGT(El1,El2:Pointer):Boolean;      { Compares ^Word }
Function lGT(El1,El2:Pointer):Boolean;      { Compares ^LongInt }
Function rGT(El1,El2:Pointer):Boolean;      { Compares ^Real }

Implementation
{$F+}

Type Dummy=Array[0..0] of Byte;
     pDummy=^Dummy;


{ Recursive Implementation }

Procedure _Sort(Base:Pointer;L,R,Size:Word;GT:CmpFunc);
Var I,J:Integer;
Var X:Pointer;
 Procedure SwapElements(El1,El2:Word);
 Var Tmp:Pointer;
 begin
  GetMem(Tmp,Size);
  Move(pDummy(Base)^[El1*Size],Tmp^,Size);
  Move(pDummy(Base)^[El2*Size],pDummy(Base)^[El1*Size],Size);
  Move(Tmp^,pDummy(Base)^[El2*Size],Size);
  FreeMem(Tmp,Size);
 end;
begin
 I:=L;
 J:=R;
 GetMem(X,Size);
 Move(pDummy(Base)^[((L+R) div 2)*Size],X^,Size);
 Repeat
  While GT(X,@pDummy(Base)^[I*Size]) do INC(I);
  While GT(@pDummy(Base)^[J*Size],X) do DEC(J);
  if I<=J then begin
   if I<>J then SwapElements(I,J);
   INC(I);
   DEC(J);
  end;
 Until I>J;
 FreeMem(X,Size);
 if L<J then _Sort(Base,L,J,Size,GT);
 if I<R then _Sort(Base,I,R,Size,GT);
end;

Procedure QSort(Base:Pointer;Elements,Size:Word;GT:CmpFunc);
begin
 _Sort(Base,0,Elements-1,Size,GT);
end;

Function bGT(El1,El2:Pointer):Boolean;
Type pByte=^Byte;
begin
 bGt:=(pByte(El1)^>pByte(El2)^);
end;

Function wGT(El1,El2:Pointer):Boolean;
Type pWord=^Word;
begin
 wGt:=(pWord(El1)^>pWord(El2)^);
end;

Function lGT(El1,El2:Pointer):Boolean;
Type pLongInt=^LongInt;
begin
 lGt:=(pLongInt(El1)^>pLongInt(El2)^);
end;

Function rGT(El1,El2:Pointer):Boolean;
Type pReal=^Real;
begin
 rGt:=(pReal(El1)^>pReal(El2)^);
end;

end.



{$A-,B-,D+,E-,F+,G+,I-,L+,N-,O+,P+,Q-,R-,S-,T-,V-,X+,Y+}
{ I don't know which settings are Really necessary For this Unit, but since
  I always work With the above, I'm including them to make sure the Unit
  compiles in your computer. The only critical ones (I Think) are R- and F+
}
Unit SORT;
{─────────────────────────────────────────────────────────────────────────}
{ Purpose:   Unit that implements a generic QSort, similar to the         }
{            one in the standard C library, but a lot more general        }
{            This new version allows ordering of almost anything,         }
{            even structures whose elements are not contiguous in memory  }
{            or have strange mutual dependancies that don't allow "happy  }
{            swapping". Obviously, this version is slower than the        }
{            previous one. if you won't be sorting Linked Lists or        }
{            Collections, use the previous one.                           }
{ Author   : Alexander Christov                                           }
{ Notes    : Very instructive on the use of Pointers in TP.               }
{            This version does not limit the number of elements to        }
{            65535 since the need not be contiguous.                      }
{                                                                         }
{    Use freely.                                                          }
{                                                                         }
{─────────────────────────────────────────────────────────────────────────}
Interface

Type CmpFunc=Function(El1,El2:Pointer):Boolean;
     AddrFunc=Function(Base:Pointer;Size,N:LongInt):Pointer;
     SwapProc=Procedure(El1,El2:Pointer;Size:LongInt);

Procedure QSort(Base:Pointer;      { Pointer to the first element.
                                     if the user Writes his own GT, Addr and
                                     Swap, this isn't Really necessary.
                                   }
                Elements:LongInt;  { Total number of elements }
                Size:Word;         { Size of an element in Bytes }
                GT:CmpFunc;        { Comparing Function  }
                Addr:AddrFunc;     { Addressing Function }
                Swap:SwapProc);    { Swapping Function }

{
  GT        - A funcion of Type CmpFunc that compares the elements pointed
              to by its first and second arguments, and returns True if the
              first element is Greater Than the second one. This Unit defines
              some commonly used CmpFuncs:
                    bGT - Compares Bytes
                    wGT - Compares Words
                    lGT - Compares LongInts
                    rGT - Compares Reals

  Addr      - A Function that receives the index of an element and must
              return a Pointer to it.
              This Unit defines the Function
                   LinearAddr
              which can be used whenever the elements are located
              contiguously in memory.

  Swap      - A Procedure that swaps the elements pointed by its arguments.
                    DirectSwap
              is defined in the Unit, which can be used whenever the elements
              are mutually independent or no external processes are needed
              when swapping two elements
}

{ Commonly used CmpFuncs }

Function bGT(El1,El2:Pointer):Boolean;      { Compares ^Byte }
Function wGT(El1,El2:Pointer):Boolean;      { Compares ^Word }
Function lGT(El1,El2:Pointer):Boolean;      { Compares ^LongInt }
Function rGT(El1,El2:Pointer):Boolean;      { Compares ^Real }

Function LinearAddr(Base:Pointer;Size,N:LongInt):Pointer;
Procedure DirectSwap(El1,El2:Pointer;Size:LongInt);

Implementation
{$F+}

Type Dummy=Array[0..0] of Byte;
     pDummy=^Dummy;


Var X,Middle:Pointer;

Procedure
_Sort(Base:Pointer;L,R:LongInt;Size:Word;GT:CmpFunc;Addr:AddrFunc;Swap:SwapProc
);
Var I,J:LongInt;
begin
 I:=L;
 J:=R;
 Move(Addr(Base,Size,(L+R) div 2)^,Middle^,Size);
 Repeat
  While GT(Middle,Addr(Base,Size,I)) do INC(I);
  While GT(Addr(Base,Size,J),Middle) do DEC(J);
  if I<=J then begin
   if I<>J then Swap(Addr(Base,Size,I),Addr(Base,Size,J),Size);
   INC(I);
   DEC(J);
  end;
 Until I>J;
 if L<J then _Sort(Base,L,J,Size,GT,Addr,Swap);
 if I<R then _Sort(Base,I,R,Size,GT,Addr,Swap);
end;

Procedure QSort;
begin
 GetMem(X,Size);  { <- Made in Arturo Ramirez 8-) }
 GetMem(Middle,Size);
 _Sort(Base,0,Elements-1,Size,GT,Addr,Swap);
 FreeMem(X,Size);
 FreeMem(Middle,Size);
end;

Function bGT(El1,El2:Pointer):Boolean;
Type pByte=^Byte;
begin
 bGt:=(pByte(El1)^>pByte(El2)^);
end;

Function wGT(El1,El2:Pointer):Boolean;
Type pWord=^Word;
begin
 wGt:=(pWord(El1)^>pWord(El2)^);
end;

Function lGT(El1,El2:Pointer):Boolean;
Type pLongInt=^LongInt;
begin
 lGt:=(pLongInt(El1)^>pLongInt(El2)^);
end;

Function rGT(El1,El2:Pointer):Boolean;
Type pReal=^Real;
begin
 rGt:=(pReal(El1)^>pReal(El2)^);
end;

{ Linear Addressing }

Function LinearAddr;
begin
 LinearAddr:=@pdummy(Base)^[N*Size];
end;

{ Direct swapping of elements. With the use of Addr() it is quite more
 legible 8-) }

Procedure DirectSwap;
Var Tmp:Pointer;
begin
 GetMem(Tmp,Size);
 Move(El1^,Tmp^,Size);
 Move(El2^,El1^,Size);
 Move(Tmp^,El2^,Size);
 FreeMem(Tmp,Size);
end;

end.


{ And finally a specific version of QSort() written in Assembler. It is
 non recursive and sorts Arrays of Words of up to 16383 elements (since
 it Uses the addresses of the elements rather than their indexes, and since
 SizeOf(Word)=2 -> 16384*2=32768 "=" -32768, and the routine Uses signed
 comparisons between adresses.
  On my 386/33 it sorts 10 times an Array of 10000 Words in 3.6 sec, While
 the first QSort() does the same in 46 sec.

  Must be called With

 Qsort(Pointer to the first element, 0, elements-1)

  Use freely. if you include the source directly in your Program, credit
  must be given.
}

Procedure QSort(Base:Pointer;L,R:Word);Assembler;
Var TmpL,TmpR,TmpDI:Word;
Asm
 xor AX,AX
 PUSH AX
 PUSH AX     { 0 0 will act as a flag on the stack indicating that no more }
 PUSH R      { (L,R) pairs need to be sorted }
 PUSH L
@MainLoop:
 LES DI,Base
 MOV TmpDI,DI
 xor SI,SI
 MOV BX,DI
 POP AX    { AX<-L }
 MOV TmpL,AX
 MOV SI,AX
 SHL AX,1
 ADD DI,AX
 POP AX    { AX<-R }
 MOV TmpR,AX
 and AX,AX     { R can be never 0 except if this is the (0,0) flag }
 JZ @end
 ADD SI,AX
 SHL AX,1
 ADD BX,AX
 and SI,$FFFE
 ADD SI,TmpDI

 { ES:DI -> Element[I] (L)
   ES:BX -> Element[J] (R)
   ES:SI -> Element[(L+R) div 2]
 }

 MOV AX,ES:[SI]
@Loop1:
 MOV CX,ES:[DI]
 CMP AX,CX
 JNA @Loop2
 ADD DI,2
 JMP @Loop1
@Loop2:
 MOV CX,ES:[BX]
 CMP CX,AX
 JNA @Check
 SUB BX,2
 JMP @Loop2
@Check:
 CMP DI,BX
 JG @Cont1
 MOV CX,ES:[DI]
 MOV DX,ES:[BX]
 MOV ES:[DI],DX
 MOV ES:[BX],CX
 ADD DI,2
 SUB BX,2
 CMP DI,BX
 JNG @Loop1

@Cont1:
 SUB DI,TmpDI
 SAR DI,1       { DI - I }
 SUB BX,TmpDI
 SAR BX,1       { BX - J }
 CMP DI,TmpR
 JGE @Cont2
 PUSH TmpR      { I<R }
 PUSH DI
@Cont2:
 CMP TmpL,BX
 JGE @MainLoop
 PUSH BX        { L<J }
 PUSH TmpL
 JMP @MainLoop

@end:
end;

{ ---------------------------   CUT  ----------------------------}
(*
From: ROLAND WODITSCH
Subj: QUICK SORT
*)

UNIT QSort5;

INTERFACE
TYPE OrdFunction = FUNCTION(VAR a,b):BOOLEAN;

PROCEDURE Sortiere(VAR SortArray; Elementgroesse,LoIndex,HiIndex: word;
                   SortKleiner: OrdFunction; von,bis:word);

{       SortArray  field to sort                                          }
{       LoIndex    the lowest,                                            }
{       HiIndex    the highest fieldindex like in the fielddeklarartion   }
{       OrdAdr     the funktion from typ OrdFunction (s.o.)               }
{       von, bis   the sortarea                                           }

{     befor calling (not befor bind!) your have to define a               }
{     asymmetric  order funktion :                                        }
{     function IrgendEinName(VAR x,y : TypDerFeldElemente):boolean        }
{     example: (*$F+*) function kleiner(VAR x,y: integer):boolean;        }
{                        begin kleiner:=x<y end;  (*$F-*)                 }
{               not:  kleiner:=x<=y  (not asymmetric!)                    }
{     attention: x and y must be VAR-parameters !!!                       }



IMPLEMENTATION

procedure Sortiere(VAR SortArray; ElementGroesse,LoIndex,HiIndex: word;
                       SortKleiner:OrdFunction; von,bis:word);
  type ArrayPtr = ^Byte;
  var Mitte, i0, j0, m0 : ArrayPtr;

  procedure Swap(VAR x,y; size : word);
    begin
     INLINE ($1E/$C4/$B6/X/$C5/$BE/Y/$8B/$8E/SIZE/$E3/$0C/$26/$8A/$04/
             $86/$05/$26/$88/$04/$46/$47/$E2/$F4/$1F)
    end;

  function Element(i : word) : ArrayPtr;
    begin
      Element:=ptr(seg(SortArray),ofs(SortArray)+i*ElementGroesse)
    end;

  procedure inc(var index : word; var pointer : ArrayPtr);
    begin
      index:=succ(index);
      pointer:=ptr(seg(pointer^),ofs(pointer^)+ElementGroesse)
    end;

  procedure dec(var index : word; var pointer : ArrayPtr);
    begin
      index:=pred(index);
      pointer:=ptr(seg(pointer^),ofs(pointer^)-ElementGroesse)
    end;

  procedure E_Sort(von, bis : word);
    label EXIT;
    var i, j : word;
    begin
      if bis<=von then goto EXIT;
      i:=von; i0:=Element(i);
      while i<bis do begin
        m0:=i0; j:=i; j0:=i0; inc(j,j0);
        while j<=bis do begin
          if SortKleiner(j0^,m0^) then m0:=j0;
          inc(j,j0)
        end; (* WHILE j *)
        if m0<>i0 then Swap(i0^,m0^,ElementGroesse);
        inc(i,i0)
      end; (* WHILE i *)
      EXIT:
    end; (* E_Sort *)

  procedure Sort(von, bis : word);  (* Rekursive Quicksort *)
    label EXIT;
    var i, j : word;
    begin
      if bis-von<6 then begin E_Sort(von,bis); goto EXIT end;
      i:=von; j:=bis; m0:=Element((i+j) SHR 1);
      move(m0^,Mitte^,ElementGroesse); i0:=Element(i); j0:=Element(j);
      while i<=j do begin
        while SortKleiner(i0^,Mitte^) do inc(i,i0);
        while SortKleiner(Mitte^,j0^) do dec(j,j0);
        if i<=j then begin
          if i<>j then Swap(i0^,j0^,ElementGroesse);
          inc(i,i0); dec(j,j0)
        end (* if i<=j *)
      end; (* while i<=j *)
      if bis-i<j-von then begin
                       if i<bis then Sort(i,bis);
                       if von<j then Sort(von,j)
                       end
                     else begin
                       if von<j then Sort(von,j);
                       if i<bis then Sort(i,bis)
                       end;
      EXIT:
    end; (* Sort *)

  begin
    getmem(Mitte,ElementGroesse);
    Sort(von-LoIndex,bis-LoIndex);
    freemem(Mitte,ElementGroesse)
  end; (* Sort *)

END. (* IMPLEMENTATION OF UNIT QSORT *)

{ ---------------------------   CUT  ----------------------------}
unit Qsort;

{TQSort by Mike Junkin 10/19/95.
 DoQSort routine adapted from Peter Szymiczek's QSort procedure which
 was presented in issue#8 of The Unofficial Delphi Newsletter.}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TSwapEvent = procedure (Sender : TObject; e1,e2 : word) of Object;
  TCompareEvent = procedure (Sender: TObject; e1,e2 : word; var Action : integer) of Object;

  TQSort = class(TComponent)
  private
    FCompare : TCompareEvent;
    FSwap : TSwapEvent;
  public
    procedure DoQSort(Sender: TObject; uNElem: word);
  published
    property Compare : TCompareEvent read FCompare write FCompare;

    property Swap : TSwapEvent read FSwap write FSwap;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Mikes', [TQSort]);
end;

procedure TQSort.DoQSort(Sender: TObject; uNElem: word);
{ uNElem - number of elements to sort }

  procedure qSortHelp(pivotP: word; nElem: word);
  label
    TailRecursion,
    qBreak;
  var
    leftP, rightP, pivotEnd, pivotTemp, leftTemp: word;
    lNum: word;
    retval: integer;
  begin
    retval := 0;
    TailRecursion:
      if (nElem <= 2) then

        begin
          if (nElem = 2) then
            begin
              rightP := pivotP +1;
              FCompare(Sender,pivotP,rightP,retval);
              if (retval > 0) then Fswap(Sender,pivotP,rightP);
            end;
          exit;
        end;
      rightP := (nElem -1) + pivotP;
      leftP :=  (nElem shr 1) + pivotP;
      { sort pivot, left, and right elements for "median of 3" }
      FCompare(Sender,leftP,rightP,retval);
      if (retval > 0) then Fswap(Sender,leftP, rightP);
      FCompare(Sender,leftP,pivotP,retval);

      if (retval > 0) then Fswap(Sender,leftP, pivotP)
      else 
        begin
          FCompare(Sender,pivotP,rightP,retval);
          if retval > 0 then Fswap(Sender,pivotP, rightP);
        end;
      if (nElem = 3) then
        begin
          Fswap(Sender,pivotP, leftP);
          exit;
        end;
      { now for the classic Horae algorithm }
      pivotEnd := pivotP + 1;
      leftP := pivotEnd;
      repeat
        FCompare(Sender,leftP, pivotP,retval);
        while (retval <= 0) do
          begin

            if (retval = 0) then
              begin
                Fswap(Sender,leftP, pivotEnd);
                Inc(pivotEnd);
              end;
            if (leftP < rightP) then
              Inc(leftP)
            else
              goto qBreak;
            FCompare(Sender,leftP, pivotP,retval);
          end; {while}
        while (leftP < rightP) do
          begin
            FCompare(Sender,pivotP, rightP,retval);
            if (retval < 0) then
              Dec(rightP)

            else
              begin
                FSwap(Sender,leftP, rightP);
                if (retval <> 0) then
                  begin
                    Inc(leftP);
                    Dec(rightP);
                  end;
                break;
              end;
          end; {while}

      until (leftP >= rightP);
    qBreak:
      FCompare(Sender,leftP,pivotP,retval);
      if (retval <= 0) then Inc(leftP);

      leftTemp := leftP -1;
      pivotTemp := pivotP;
      while ((pivotTemp < pivotEnd) and (leftTemp >= pivotEnd)) do
        begin
          Fswap(Sender,pivotTemp, leftTemp);
          Inc(pivotTemp);
          Dec(leftTemp);
        end; {while}
      lNum := (leftP - pivotEnd);
      nElem := ((nElem + pivotP) -leftP);

      if (nElem < lNum) then
        begin
          qSortHelp(leftP, nElem);
          nElem := lNum;
        end
      else
        begin

          qSortHelp(pivotP, lNum);
          pivotP := leftP;
        end;
      goto TailRecursion;
    end; {qSortHelp }

begin
  if Assigned(FCompare) and Assigned(FSwap) then
  begin
    if (uNElem < 2) then  exit; { nothing to sort }
    qSortHelp(1, uNElem);
  end;
end; { QSort }

end. 

{ demo }

unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Qsort, StdCtrls;

type
  TForm1 = class(TForm)
    QSort1: TQSort;
    StringGrid1: TStringGrid;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure QSort1Compare(Sender: TObject; e1, e2: Word; var Action: Integer);
    procedure QSort1Swap(Sender: TObject; e1, e2: Word);
    procedure Button1Click(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin

     with StringGrid1 do
     begin
          Cells[1,1] := 'the';
          Cells[1,2] := 'brown';
          Cells[1,3] := 'dog';
          Cells[1,4] := 'bit';
          Cells[1,5] := 'me';
     end;
end;

procedure TForm1.QSort1Compare(Sender: TObject; e1, e2: Word;
  var Action: Integer);
begin
     with Sender as TStringGrid do
    begin
      if (Cells[1, e1] < Cells[1, e2]) then
        Action := -1
      else if (Cells[1, e1] > Cells[1, e2]) then

        Action := 1
      else
        Action := 0;
    end; {with}

end;

procedure TForm1.QSort1Swap(Sender: TObject; e1, e2: Word);
var
  s: string[63];  { must be large enough to contain the longest string in the grid }
  i: integer;
begin
  with Sender as TStringGrid do
    for i := 0 to ColCount -1 do
    begin
      s := Cells[i, e1];
      Cells[i, e1] := Cells[i, e2];
      Cells[i, e2] := s;
    end; {for}

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  QSort1.DoQSort(StringGrid1,STringGrid1.RowCount-1);
end;

end.

{ ---------------------------   CUT  ----------------------------}
{
> Could someone please post some code on using a quick
> sort to sort an array of strings?

   I can do even better than that. I can give you some code on a general qsort
routine that works like in C (if you're familiar with that). I. e. you can sort
any type of arrays, if only you supply the correct compare function. Here
goes...
}

unit QSort;
{*********************************************************
 *                     QSORT.PAS                         *
 *           C-like QuickSort implementation             *
 *     Written 931118 by Björn Felten @ 2:203/208        *
 *           After an idea by Pontus Rydin               *
 *********************************************************}
interface
type CompFunc = function(Item1, Item2 : word) : integer;

procedure QuickSort(
    var Data;
{An array. Must be [0..Count-1] and not [1..Count] or anything else! }
    Count,
{Number of elements in the array}
    Size    : word;
{Size in bytes of a single element -- e.g. 2 for integers or words,
4 for longints, 256 for strings and so on }
    Compare : CompFunc);
{The function that decides which element is "greater" or "less". Must
return an integer that's < 0 if the first element is less, 0 if they're
equal and > 0 if the first element is greater. A simple Compare for
words can look like this:

 function WordCompare(Item1, Item2: word): integer;
 begin
     WordCompare := MyArray[Item1] - MyArray[Item2]
 end;

NB. It's not the =indices= that shall be compared, it's the elements that
the supplied indices points to! Very important to remember!
Also note that the array may be sorted in descending order just by
means of a simple swap of Item1 and Item2 in the example.}

implementation
procedure QuickSort;

  procedure Swap(Item1, Item2 : word);
  var  P1, P2 : ^byte; I : word;
  begin
     if Item1 <> Item2 then
     begin
          I  := Size;
          P1 := @Data; inc(P1, Item1 * Size);
          P2 := @Data; inc(P2, Item2 * Size);
          asm
            mov  cx,I      { Size }
            les  di,P1
            push ds
            lds  si,P2
          @L:
            mov  ah,es:[di]
            lodsb
            mov  [si-1],ah
            stosb
            loop @L
            pop  ds
          end
      end
  end;

  procedure Sort(Left, Right: integer);
  var  i, j, x, y : integer;
  begin
     i := Left; j := Right; x := (Left+Right) div 2;
     repeat
        while compare(i, x) < 0 do inc(i);
        while compare(x, j) < 0 do dec(j);
        if i <= j then
        begin
           swap(i, j); inc(i); dec(j)
        end
     until i > j;
     if Left < j then Sort(Left, j);
     if i < Right then Sort(i, Right)
  end;

begin Sort(0, Count) end;

end. { of unit }

{ A simple testprogram can look like this: }

program QS_Test; {Test QuickSort á la C}
uses qsort;
var v: array[0..9999] of word;
    i: word;

{$F+} {Must be compiled as FAR calls!}
function cmpr(a, b: word): integer;
begin cmpr := v[a] - v[b] end;

function cmpr2(a, b: word): integer;
begin cmpr2 := v[b] - v[a] end;
{$F-}

begin
 randomize;
 for i := 0 to 9999 do v[i] := random(20000);
 quicksort(v, 10000, 2, cmpr);  {in order lo to hi}
 quicksort(v, 10000, 2, cmpr2); {we now have a sorted list, sort it in
                                {reverse -- nasty for qsort!}
 quicksort(v, 10000, 2, cmpr);  {and reverse again}
 quicksort(v, 10000, 2, cmpr);  {sort a sorted list -- also not very popular}
end.

{ ---------------------------   CUT  ----------------------------}

{************************************************}
{                                                }
{ QuickSort Demo                                 }
{ Copyright (c) 1985,90 by Borland International } { und: Robert Beicht ;-) }
{                                                }
{************************************************}

program QSort;
{$R-,S-}
uses Crt;

{ This program demonstrates the quicksort algorithm, which      }
{ provides an extremely efficient method of sorting arrays in   }
{ memory. The program generates a list of 1000 random numbers   }
{ between 0 and 29999, and then sorts them using the QUICKSORT  }
{ procedure. Finally, the sorted list is output on the screen.  }
{ Note that stack and range checks are turned off (through the  }
{ compiler directive above) to optimize execution speed.        }

const
  Max = 100;

type                                                                  { ***** }
  PData = ^TData;                                                     { ***** }
  TData = record                                                      { ***** }
    NachName: String[25];                                             { ***** }
    VorName:  String[25];                                             { ***** }
    {..}                                                              { ***** }
  end;                                                                { ***** }
  
  List = array[1..Max] of TData;

var
  Data: List;
  I: Integer;

function Less(var d1,d2:TData): Boolean;                              { ***** }
begin                                                                 { ***** }
  if d1.NachName < d2.NachName then Less := True  else                { ***** }
  if d1.NachName > d2.NachName then Less := False else                { ***** }
    if d1.VorName < d2.VorName then Less := True  else                { ***** }
    if d1.VorName > d2.VorName then Less := False else Less := False; { ***** }
end;                                                                  { ***** }

{ QUICKSORT sorts elements in the array A with indices between  }
{ LO and HI (both inclusive). Note that the QUICKSORT proce-    }
{ dure provides only an "interface" to the program. The actual  }
{ processing takes place in the SORT procedure, which executes  }
{ itself recursively.                                           }

procedure QuickSort(var A: List; Lo, Hi: Integer);

procedure Sort(l, r: Integer);
var
  i, j, x: integer;                                                   { ***** }
  y: TData;                                                           { ***** }
begin
  i := l; j := r; x := (l+r) DIV 2;
  repeat
    while Less(a[i], a[x]) do i := i + 1;                             { ***** }
    while Less(a[x], a[j]) do j := j - 1;                             { ***** }
    if i <= j then
    begin
      y := a[i]; a[i] := a[j]; a[j] := y;
      i := i + 1; j := j - 1;
    end;
  until i > j;
  if l < j then Sort(l, j);
  if i < r then Sort(i, r);
end;

begin {QuickSort};
  Sort(Lo,Hi);
end;

begin {QSort}

  (*Initialisiere List*)
  Sort(List, 1, Count);

end.

