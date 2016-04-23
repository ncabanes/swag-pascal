{
Here's a unit that will let you open more than the default
maximum number of files (up to about 200, FILES statement
in CONFIG.SYS permitting) :
}

{$o-,f-,r-,s-}
{$IfDef DPMI}
     {$c Moveable PreLoad Discardable}
{$EndIf}

Unit ExtHandl ;

Interface

{$IfNDef DPMI}
Procedure DOSRealloc(p : Pointer) ;
{$EndIf}

Implementation

{$IfNDef DPMI}
Procedure DOSRealloc(p : Pointer) ; Assembler ;
{ This procedures changes the size of the memory block allocated to the
  program. It proceeds the same way than the SetMemTop procedure of the
  Memory unit does. }
Asm
     Mov  BX, Word Ptr [p]                   { offset }
     Add  BX, $0f
     Mov  CL, 4
     ShR  BX, CL
     Add  BX, Word Ptr [p+2]                 { segment }
     Mov  AX, PrefixSeg
     Sub  BX, AX
     Mov  ES, AX
     { ES contains the program's PSP, BX is the new number of paragraphs
       of the memory block. }
     Mov  AH, $4a                            { Modify memory allocation }
     Int  $21
End ;
{$EndIf}

Const
     FreeParas      = 1024 Div 16 ;     { We're going to make sure DOS     }
                                        { still has some RAM               }
     Reallocating   = 1 ;
     TPLacksRAM     = 2 ;
     GettingHandles = 3 ;

Procedure PrintError(ErrNo : Word ; Location : Word) ;
Begin
     WriteLn(ParamStr(0)) ;
     WriteLn('ExtHandl : Startup error #', ErrNo, ', location=', Location) ;
     WriteLn('MaxAvail=', MaxAvail) ;
     Write('[Enter] pour continuer...') ;
     ReadLn ;
End ;

Begin
     { This initialisation code makes sure DOS is still able to assume
       memory allocation requests that are likely to occur (whether by
       Spawno or a "Set Handle Count" request).
       This allows the main program to use whatever $m statement it needs. }
     Asm
{$IfNDef DPMI}
          Mov  AH, $48                  { Allocate memory }
          Mov  BX, $ffff                { More than DOS can give us }
          Int  $21
          Cmp  BX, FreeParas            { BX contains avail paragraphs }
          JNC  @DOSHasEnough
          { Let's check that the heap contains more than needed bytes }
          Mov  AX, Word Ptr [HeapPtr+2]
          Add  AX, FreeParas
          Cmp  AX, Word Ptr [HeapEnd+2]
          JNC  @NotEnoughRAM            { Actually, TP hasn't enough }
          Sub  Word Ptr [HeapEnd+2], FreeParas
          Push Word Ptr [HeapEnd+2]
          Push Word Ptr [HeapEnd]
          Call DOSRealloc
          JNC  @DOSHasEnough
          Push AX
          Mov  AX, Reallocating
          Push AX
          Call PrintError
          Jmp  #DOSHasEnough
     @NotEnoughRAM:
          XOr  AX, AX
          Push AX
          Mov  AX, TPLacksRAM
          Push AX
          Call PrintError
     @DOSHasEnough:
{$EndIf}
          { Augmentation du nombre de handles disponibles }
          Mov  AH, $67                  { Extend handles }
          Mov  BX, 199                  { Gi'me 2 hundreds of 'em }
          Int  $21
          JNC  @PasDErreur              { Si CF=1, erreur }
          Push AX
          Mov  AX, GettingHandles
          Push AX
          Call PrintError
     @PasDErreur:
     End ;
End.

