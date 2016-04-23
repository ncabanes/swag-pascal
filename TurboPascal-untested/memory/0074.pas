{
    Here is the UMB_Heap unit i found in a copy of PC Magazine a while back..
This code works on my 486DX/2 66mhz with 4meg ram...    so it should (i hope)
run on yourz too....    All you need to do to use this is just call
Extend_Heap in your program someplace to get the extra heap memory, and
GetBlockSizes if you wish to know how large the UMB blocks are that were
allocated...


}

Unit
  UMB_Heap;

Interface

Const
  Max_Blocks      = 4;

Type
  UMBDataType = Array[1..Max_Blocks] Of Word;

Procedure Extend_Heap;
Procedure GetBlockSizes(Var US : UMBDataType);

Implementation

Type
  PFreeRec        = ^TFreeRec;
  TFreeRec        = Record
    Next          : PFreeRec;
    Size          : Pointer;
  End;

Var
  Block_Segments  : UMBDataType;
  Block_Sizes     : UMBDataType;
  SaveExitProc    : Pointer;

Function UMB_Driver_Present : Boolean;

Var
  Flag            : Boolean;

Begin
  Flag := False;
  Asm
    Mov   AX, $4300
    Int   $2F
    CMP   AL, $80
    JNE   @Done
    Inc   [Flag]
  @Done:
  End;
  UMB_Driver_Present := Flag;
End;

Procedure Allocate_UMB;

Var
  I,
  Save_Strategy,
  Block_Segment,
  Block_Size      : Word;

Begin
  For I := 1 To Max_Blocks Do
    Begin
      Block_Segments[I] := 0;
      Block_Sizes[I] := 0;
    End;
  Asm
    Mov   AX, $5801
    Mov   BX, $0FFFF
    Int   $21
    Mov   AX, $5803
    Mov   BX, $0001
    Int   $21
  End;
  For I := 1 To Max_Blocks Do
    Begin
      Block_Segment := 0;
      Block_Size := 0;
      Asm
        Mov   AX, $4800
        Mov   BX, $0FFFF
        Int   $21
        CMP   BX, 0
        JE    @Fail
        Mov   AX, $4800
        Int   $21
        JC    @Fail
        Mov   [Block_Segment], AX
        Mov   [Block_Size], BX
      @Fail:
      End;
      Block_Segments[I] := Block_Segment;
      Block_Sizes[I] := Block_Size;
    End;
End;

Procedure Release_UMB; Far;

Var
  I,
  Segment : Word;

Begin
  ExitProc := SaveExitProc;
  Asm
    Mov   AX, $5803
    Mov   BX, $0000
    Int   $21
  End;
  For I := 1 To Max_Blocks Do
    Begin
      Segment := Block_Segments[I];
      If (Segment > 0) Then
        Asm
          Mov   AX, $4901
          Mov   BX, [Segment]
          Mov   ES, BX
          Int   $21
        End;
    End;
End;

Function Pointer_To_LongInt(p : Pointer) : LongInt;

Type
  PtrRec          = Record
    Lo, Hi        : Word;
  End;

Begin
  Pointer_To_LongInt := LongInt(PtrRec(P).Hi * 16 + PtrRec(P).Lo);
End;

Procedure Extend_Heap;

Var
  I               : Word;
  Temp            : PFreeRec;

Begin
  If UMB_Driver_Present then
    Begin
      Allocate_UMB;
      Temp := HeapPtr;
      I := 1;
      While ((Block_Sizes[I] > 0) And
             (I <= Max_Blocks)) Do
        Begin
          Temp^.Next := Ptr(Block_Segments[I], 0);
          Temp       := Temp^.Next;
          Temp^.Next := HeapPtr;
          Move(Block_Sizes[I], Temp^.Size, SizeOf(Word));
          Temp^.Size := Pointer(LongInt(Temp^.Size) SHL 16);
          Inc(I);
        End;
      If (Block_Sizes[1] > 0) then
        FreeList := Ptr(Block_Segments[1], 0);
    End;
End;

Procedure GetBlockSizes(Var US : UMBDataType);

Begin
  US := Block_Sizes;
End;

Begin
  FillChar(Block_Sizes, SizeOf(Block_Sizes), 0);
  SaveExitProc := ExitProc;
  ExitProc := @Release_UMB;
End.
