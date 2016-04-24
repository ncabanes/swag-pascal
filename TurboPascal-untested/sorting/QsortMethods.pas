(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0035.PAS
  Description: QSort Methods
  Author: ALEXANDER CHRISTOV
  Date: 08-27-93  21:48
*)

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


