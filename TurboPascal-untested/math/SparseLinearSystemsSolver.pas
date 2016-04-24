(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0094.PAS
  Description: Sparse Linear Systems Solver
  Author: MARK HORRIDGE
  Date: 05-26-95  23:28
*)

{
From: horridge@ITS-MENZ.cc.monash.edu.au (Mark Horridge)
Sparse Solver for Borland or Turbo Pascal
*****************************************

Several people asked for a copy of my Pascal Unit to solve sparse linear
systems.  Here it is.

Unit Solspar is designed to solve sparse linear systems.
These are equation systems of the form:

A X  = R

where A is a matrix of coefficients size NxN,
      R is a vector of constants size N,
and   X is a vector of variables.

The code has been in use for a number of years, being slightly adapted for
each new purpose.  This is the first attempt at a portable general purpose
version.

I expect that the code contains a few errors which are my fault - I would
be glad to hear of these.  Please check that you have not tried to solve a
singular matrix by mistake !


Below find 3 text files, separated by rows of asterisks:

Solspar.pas:
  See notes at the top for instructions.
Test1.pas:
  Simple example of using routines with medium size matrix
Test2.pas:
  Example of using routines with N = 4, showing some possible errors
{************************************************************************}
{$N+,E+}
unit SolSpar;
{ Unit Solspar is designed to solve sparse linear systems.
These are equation systems of the form:

A X  = R

where A is a matrix of coefficients size NxN,
      R is a vector of constants size N,
and   X is a vector of variables.
(remember, in matrix A, 'rows' are equations and 'cols' are variables)

Solspar computes the vector X which satisfies the above equation.
It is designed to save time and space where A is fairly large but contains
few non-zero elements.

It is designed to work in either the real, protected-mode DOS, or Windows
versions of Borland/Turbo Pascal.

Limitations of Solspar:
  It only allows one Right Hand Side (RHS) column.
  It only allows one sparse structure at a time.
  Not to be used with Mark and Release !
Points to watch:
  Normally, the A matrix grows in size (becomes less sparse)
  during the Solve phase. The biggest matrix you can store
 will be to big to solve.
}
interface

 {Unit consists of the following 5 Boolean Functions and 3 procedures.
  Each function returns True if operation was successfully completed -
  otherwise False.  If False is returned, call the procedure
  GetErrorMessage to find the reason.  Finally, call the procedure
  ReleaseStruc to return memory to the heap.}

function InitStruc(NumEq : Word) : Boolean;
 {creates and initializes sparse matrix structure - call this first.
  NumEq is number of equations/variables.}

function AddElement(ThisEqu, ThisVar : Word; ThisVal : Double) : Boolean;
 {add an element to sparse matrix for equation ThisEqu and variable ThisVar;
  if such an entry already exists, ThisVal will be added to existing value
 You can add elements in any order, but the routine will be a bit more
efficient if you add variables (columns) to any particular equation in
ascending order, and then set the RHS}

function SetRHS(ThisEqu : Word; ThisVal : Double) : Boolean;
 {Set RHS for equation ThisEqu; if RHS has already been set, ThisVal will be
  added to existing value}

function Solve1 : Boolean;
  {calculate solutions; sparse matrix is destroyed}

function GetAnswer(ThisVar : Word; var ThisVal : Double) : Boolean;
 {read solution for variable ThisVar - probably called for each variable in
  turn}

procedure ReleaseStruc;
 {releases remaining memory used by sparse matrix structure - call this
  last}

procedure GetErrorMsg(var S : String; var N1, N2, N3 : Word);
 {N1: error number; S: Error Description; N1, N2 : other possibly useful
  numbers}

procedure showmat;      { displays small sparse matrix - not for Windows}

var
  SparMemUsed    : LongInt; {no of bytes of heap used by routines}

(*
procedure GetErrorMsg is used to obtain information about any problem:

procedure GetErrorMsg(var S : String; var N1, N2, N3 : Word);
 {N1: error number; S: Error Description; N1, N2 : other possibly useful
  numbers}

List of possible error messages is as follows:
(remember, 'rows' are equations and 'cols' are variables)

N1        S                          N2        N3        Comment

 0                                 0          0      No error: default
 1  Empty Row                      Row        0
 2  Row without Variables          Row        0      Equation with RHS only
 3  Empty Col                      Col        0
 4  Two Singles                    Row      PivotCol Two variables (the 2nd
                                                     is pivotcol) are each
                                                     mentioned only in the
                                                     same equation
 5  No RHS                         Row      LastCol
 6  Numerically Singular         PivotRow PivotStep  Columns (or rows)
                                                     are not linearly
                                                     independent.
 7  Out of Space                   0          1      called from InitStruc
 7  Out of Space                   0          2      called from InitStruc
 7  Out of Space                   0          3      called from AddElement
 7  Out of Space                   PivotStep  4      called from Solve1
 8  Cols out of Order              Row        Col
25  Initialize without releasing   0          0
26  Too many equations             NumEq      MaxEq
27  Too few equations              NumEq      0
30  Row < 1                        ThisEqu  ThisVar  called from AddElement
31  Col < 1                        ThisEqu  ThisVar  called from AddElement
32  Row > Neq                      ThisEqu    Neq    called from AddElement
33  Col > Neq                      ThisVar    Neq    called from AddElement
41  VarNo < 1                      ThisVar    0      called from AddElement
42  VarNo > Neq                    ThisVar    Neq    called from AddElement
 *)

{  Hopefully, this is as far as you need to read in order to use the unit.
   There are a few comments in the code which you can look at for interest.
  To learn more about sparse matrices read:
    Direct Methods for Sparse Matrices
    Duff, Erisman and Reid         Cambridge University Press  }


implementation

const
  DBug           = False;
  {due to Borland's "constant folding" , Debug statements cost nothing with
Dbug false}
  Msg            = False;
  ParaSize       = 16;  {for paragraph alignment}
  MaxSize        = 65520; {largest variable size allowed by Turbo Pascal}
  MaxUsable      = MaxSize-ParaSize; {allows for paragraph alignment of data}
  MaxEq          = (MaxUsable div SizeOf(Double))-1; {-1 for 0-based arrays}
  {based on above, MaxEq = 8187}
  Uvalue         = 0.1; {number 0<U<1; if larger, time and memory usage are
                          increased at the gain, maybe, of accuracy}

type
  RealArr        = array[0..MaxEq] of Double;
  WordArr        = array[0..MaxEq] of Word;
  IntArr         = array[0..MaxEq] of Integer;
  PRealArr       = ^RealArr;
  PWordArr       = ^WordArr;
  PIntArr        = ^IntArr;

  { The ElmRec record type stores a single entry in the sparse matrix.  For
  efficiency reasons, it is 16 bytes long, and will be paragraph-aligned.
  The CheckRow field is padding to make up the 16 bytes.  The 'preload
  PrevPtr' trick, see below, requires that Next field be 4 bytes [= size of a
  pointer] after the start of the record.  Hence, order of fields is
  important.
    By converting the value field to a Single, and eliminating the Checkrow
  field, the record size could be reduced to 10 bytes.  The paragraph
  alignment feature would then have to be sacrificed, and the code altered in
  various places.
    The nodes in use are arranged in a series of linked lists, one for each
  equation (or row).  Within each list variables (columns) always appear in
  ascending order.  Each list is terminated by a RHS or constant entry; this
  is treated as though it corresponded to an extra variable, numbered (Neq+1).}

  PElmRec        = ^ElmRec;
  ElmRec         = record
                     Column         : Word; {variable no. of this node}
                     CheckRow       : Word; {equation no. of this node}
                     Next           : PElmRec; {pointer to next node in row}
                     Value          : Double; {coefficient value}
                   end;

  PtrArr         = array[0..MaxEq] of PElmRec;
  PPtrArr        = ^PtrArr;

  { Spare nodes, not currently in use, are linked together in one list,
  pointed to by FreePtr.  FreeCount is the number of spare nodes.  Because
  there may be very many nodes, all of the same size, they are not allocated
  directly on the heap by the System Heap Manager.  Instead a more efficient
  scheme is used.  When the list of free nodes needs to be expanded, a large
  block of memory is requested, sufficient for many nodes. Another linked list
  is used to store the addresses of these blocks, for later disposal to the
  system heap}

const
  ElmSize        = SizeOf(ElmRec);
  MaxElmsPerBlock = MaxUsable div ElmSize;
  ElmsPerBlock   = MaxElmsPerBlock; {could be set to less}
type
  TBlock         = array[1..ElmsPerBlock] of ElmRec;
  PBlock         = ^TBlock;
  PHeapRec       = ^HeapRec;
  HeapRec        = record
                     BlockPtr       : PBlock; {address of block}
                     NextRec        : PHeapRec; {address of next list item}
                   end;

var                     {this list contains variables which must have unit-wide
scope}
  OldHeapError   : Pointer; {to restore previous HeapError function}
  Reason         : String; {for error messages}
  ErrNo1, ErrNo2, ErrNo3 : Word; {for error messages}
  Answer         : PRealArr; {holds solution}
  FreePtr        : PElmRec; {points to list of free nodes}
  BlockList      : PHeapRec; {points to list of allocated node blocks}
  FreeCount      : Word; {number of free nodes}
  Neq            : Word; {number of equations}
  FirstElm       : PPtrArr; {array of pointers to first node in each equation}
  LastElm        : PPtrArr; {array of pointers to last node in each equation}
  OrigFirstElm   : PPtrArr;
  OrigLastElm    : PPtrArr;
  OrigAnswer     : PRealArr;
  OrigNextActiveRow : PIntArr;
  OrigColCount   : PIntArr;
  OrigRowCount   : PWordArr;
  OrigPivRow     : PWordArr;
const
  Initialized    : Boolean = False;

  procedure Assert(P : Boolean; S : String);
    {used for debugging}
  begin
    if P then Exit;
    WriteLn('assertion failed: ', S);
    Halt(1);
  end;                  {Assert}

  function HeapFunc(Size : Word) : Integer; far; {allows trapping GetMem
errors}
  begin HeapFunc := 1; end;


  function GetMemParaAlign(var P, OrigP : Pointer; Size : Word) : Boolean;
  { Returns a pointer P which is paragraph aligned (a multiple of ParaSize)
  and which points to a new block of memory of which at least Size bytes can
  be used.  The 486 cache is well suited to paragraph aligned data.
    In more detail, GetMemParaAlign obtains a block of memory from the system
  heap which is ParaSize bytes larger than Size.  OrigP points to this
  original block.  P is the first address after OrigP which is a multiple of
  ParaSize.  OrigP must be saved for passing (with Size) to a later
  FreeMemParaAlign call.}
  type                  {used only for typecasting}
    PtrRec         = record OfsWord, SegWord : Word; end;
  var
    Ofset          : Word;
  begin
    if Msg then WriteLn('Entering GetMemParaAlign');
    P := nil; OrigP := nil;
    GetMemParaAlign := False;
    OldHeapError := HeapError; HeapError := @HeapFunc;
    GetMem(OrigP, Size+ParaSize);
    HeapError := OldHeapError;
    if (OrigP = nil) then Exit;
    Inc(SparMemUsed, Size+ParaSize);
    P := OrigP;         {to load segment}
    Ofset := PtrRec(P).OfsWord;
    {adjust offset to paragraph boundary}
    PtrRec(P).OfsWord := ParaSize+ParaSize*(Ofset div ParaSize);
    GetMemParaAlign := True;
  end;                  {GetMemParaAlign}

  procedure FreeMemParaAlign(var OrigP : Pointer; Size : Word);
 {If OrigP<>Nil, returns a block at OrigP of (Size+ParaSize) bytes to the
  system heap.  Failure will cause a runtime error.  If this occurs, it is
  most likely due to an error in this unit!  }
  begin
    if Msg then WriteLn('Entering FreeMemParaAlign');
    if (OrigP = nil) then Exit; {already freed or never allocated, we presume}
    FreeMem(OrigP, Size+ParaSize); {failure will cause runtime error}
    Dec(SparMemUsed, Size+ParaSize);
    OrigP := nil;       {to indicate now freed}
  end;                  {FreeMemParaAlign}

  function FrePrime : Boolean;
  type                  {used only for typecasting}
    PtrRec         = record OfsWord, SegWord : Word; end;
  var
    NewBlock, OrigBlock : PBlock;
    NewRec         : PHeapRec;
    Ofset, Count   : Word;
    P              : PElmRec;
  begin
    if Msg then WriteLn('Entering FrePrime');
    FrePrime := False;

    {add new node to list of blocks}
    OldHeapError := HeapError; HeapError := @HeapFunc;
    NewRec := nil;
    New(NewRec); Inc(SparMemUsed, SizeOf(HeapRec));
    HeapError := OldHeapError;
    if (NewRec = nil) then Exit;
    NewRec^.NextRec := BlockList;
    NewRec^.BlockPtr := nil;
    BlockList := NewRec;


    {get new block}
    if not GetMemParaAlign(Pointer(NewBlock), Pointer(OrigBlock),
SizeOf(TBlock)) then Exit;
    NewRec^.BlockPtr := OrigBlock;
    {fill new block with linked nodes}
    P := PElmRec(NewBlock);
    Ofset := PtrRec(P).OfsWord;
    for Count := 1 to ElmsPerBlock do begin
      Inc(Ofset, ElmSize);
      PtrRec(P).OfsWord := Ofset;
      NewBlock^[Count].Next := P;
    end;
    Inc(FreeCount, ElmsPerBlock);

    NewBlock^[ElmsPerBlock].Next := FreePtr; {point end of new block to
FreePtr}
    FreePtr := PElmRec(NewBlock); {point FreePtr at start of new block}

    FrePrime := True;
  end;                  {FrePrime}

  procedure SetErrorMsg(S : String; N1, N2, N3 : Word);
  begin
    Reason := S; ErrNo1 := N1; ErrNo2 := N2; ErrNo3 := N3;
  end;                  {SetErrorMsg}

  procedure GetErrorMsg(var S : String; var N1, N2, N3 : Word);
  begin
    S := Reason; N1 := ErrNo1; N2 := ErrNo2; N3 := ErrNo3;
  end;                  {GetErrorMsg}

  procedure FillStruct(var Dest; Count : Word; var Filler; FillerSize : Word);
    {-Fill memory starting at Dest with Count instances of Filler}
  inline(
    $58/$5B/$5A/$59/$5F/$07/$E3/$11/$FC/$1E/$8E/$DA/
    $89/$CA/$89/$DE/$89/$C1/$F2/$A4/$89/$D1/$E2/$F4/$1F);

  function InitStruc(NumEq : Word) : Boolean;
  var
    Col            : Word;
  label Fail;
  begin
    if Msg then WriteLn('Entering InitStruc');
    InitStruc := False;
    SetErrorMsg('', 0, 0, 0);
    SparMemUsed := 0;

    OrigAnswer := nil;
    OrigColCount := nil;
    OrigFirstElm := nil;
    OrigLastElm := nil;
    OrigNextActiveRow := nil;
    OrigPivRow := nil;
    OrigRowCount := nil;

    if Initialized then begin
      SetErrorMsg('Initialize without releasing ', 25, 0, 0);
      Exit;
    end;
    Initialized := True;
    if (NumEq > MaxEq) then begin
      SetErrorMsg('Too many equations ', 26, NumEq, MaxEq);
      Exit;
    end;
    if (NumEq < 1) then begin
      SetErrorMsg('Too few equations ', 27, NumEq, 0);
      Exit;
    end;

    Neq := NumEq;
    if not GetMemParaAlign(Pointer(FirstElm), Pointer(OrigFirstElm),
(1+NumEq)*SizeOf(PElmRec)) then begin
      SetErrorMsg('Out of Space', 7, 0, 1);
      Exit;
    end;
    if not GetMemParaAlign(Pointer(LastElm), Pointer(OrigLastElm),
(1+NumEq)*SizeOf(PElmRec)) then begin
      SetErrorMsg('Out of Space', 7, 0, 2);
      Exit;
    end;

    BlockList := nil;
    FreePtr := nil;
    Col := 0;
    FreeCount := 0;
    FillStruct(FirstElm^, 1+Neq, FreePtr, SizeOf(FreePtr));
    FillStruct(LastElm^, 1+Neq, FreePtr, SizeOf(FreePtr));
    InitStruc := True;
  end;                  {InitStruc}

  procedure ReleaseStruc;
  var
    OrigBlock      : PBlock;
    NextPtr        : PHeapRec;
  begin
    if Msg then WriteLn('Entering ReleaseStruc');
    Initialized := False;

    {some of these may have been released already}
    FreeMemParaAlign(Pointer(OrigAnswer), (1+Neq)*SizeOf(Double));
    FreeMemParaAlign(Pointer(OrigColCount), (1+Neq)*SizeOf(Integer));
    FreeMemParaAlign(Pointer(OrigFirstElm), (1+Neq)*SizeOf(PElmRec));
    FreeMemParaAlign(Pointer(OrigLastElm), (1+Neq)*SizeOf(PElmRec));
    FreeMemParaAlign(Pointer(OrigNextActiveRow), (1+Neq)*SizeOf(Integer));
    FreeMemParaAlign(Pointer(OrigPivRow), (1+Neq)*SizeOf(Word));
    FreeMemParaAlign(Pointer(OrigRowCount), (1+Neq)*SizeOf(Word));


    {get rid of user heap}
    while (BlockList <> nil) do begin
      OrigBlock := BlockList^.BlockPtr;
      if (OrigBlock <> nil) then begin
        FreeMemParaAlign(Pointer(OrigBlock), SizeOf(TBlock));
        if Msg then WriteLn('releasing a block');
      end;
      NextPtr := BlockList^.NextRec;
      Dispose(BlockList); Dec(SparMemUsed, SizeOf(HeapRec));
      BlockList := NextPtr;
    end;                {while}

    Initialized := False;
  end;                  {ReleaseStruc}

  function AddElement(ThisEqu, ThisVar : Word; ThisVal : Double) : Boolean;
  var
    PrevPtr, ElmPtr, NewPtr : PElmRec;
  begin                 {PivRow[Row] points to last element }
    AddElement := False;
    if (ThisEqu < 1) then begin SetErrorMsg('Row < 1', 30, ThisEqu, ThisVar);
Exit; end;
    if (ThisVar < 1) then begin SetErrorMsg('Col < 1', 31, ThisEqu, ThisVar);
Exit; end;
    if (ThisEqu > Neq) then begin SetErrorMsg('Row > Neq', 32, ThisEqu, Neq);
Exit; end;
    if (ThisVar > (1+Neq)) then begin SetErrorMsg('Col > Neq', 33, ThisVar,
Neq); Exit; end;
    if ThisVal = 0.0 then begin AddElement := True; Exit; end;
    if (FreeCount < Neq) then begin
      if not FrePrime then begin
        SetErrorMsg('Out of Space', 7, 0, 3); Exit;
      end;
    end;
    NewPtr := FreePtr; FreePtr := FreePtr^.Next; Dec(FreeCount);

    NewPtr^.Value := ThisVal;
    NewPtr^.Column := ThisVar;
    NewPtr^.Next := nil;

    if FirstElm^[ThisEqu] = nil then begin
      FirstElm^[ThisEqu] := NewPtr;
      LastElm^[ThisEqu] := NewPtr;
    end
    else if (LastElm^[ThisEqu]^.Column < ThisVar) then begin
      LastElm^[ThisEqu]^.Next := NewPtr;
      LastElm^[ThisEqu] := NewPtr;
    end
    else begin          {insertion sort}
      ElmPtr := FirstElm^[ThisEqu];
      PrevPtr := nil;
      while (ElmPtr^.Column < ThisVar) do begin
        PrevPtr := ElmPtr;
        ElmPtr := ElmPtr^.Next;
      end;
      if (ElmPtr^.Column = ThisVar) then begin
        ElmPtr^.Value := ElmPtr^.Value+ThisVal;
        {new node not needed: return to free list}
        NewPtr^.Next := FreePtr; FreePtr := NewPtr; Inc(FreeCount);
      end
      else {ElmPtr^.Column > ThisVar} begin
        if PrevPtr = nil then FirstElm^[ThisEqu] := NewPtr
        else PrevPtr^.Next := NewPtr;
        NewPtr^.Next := ElmPtr;
      end;
    end;
    AddElement := True;
  end;                  {AddElement}

  function SetRHS(ThisEqu : Word; ThisVal : Double) : Boolean;
  begin
    SetRHS := AddElement(ThisEqu, 1+Neq, ThisVal);
  end;                  {SetRHS}

  function GetAnswer(ThisVar : Word; var ThisVal : Double) : Boolean;
    {should fail if solve not called}
  begin
    if ((ThisVar > 0) and (ThisVar <= Neq)) then begin
      GetAnswer := True;
      ThisVal := Answer^[ThisVar];
    end
    else begin
      GetAnswer := False;
      if (ThisVar < 1) then SetErrorMsg('VarNo < 1', 41, ThisVar, 0);
      if (ThisVar > Neq) then SetErrorMsg('VarNo > Neq', 42, ThisVar, Neq);
    end;                {else}
  end;                  {GetAnswer}

  procedure showmat;
  var
    Row, Col, c, LastCol : Word;
    ElmPtr         : PElmRec;
  begin
    for Row := 1 to Neq do begin
      ElmPtr := FirstElm^[Row];
      LastCol := 0;
      while ElmPtr <> nil do begin
        Col := ElmPtr^.Column;
        for c := (LastCol+1) to (Col-1) do Write('nil':6);
        Write(ElmPtr^.Value:6:2);
        LastCol := Col;
        ElmPtr := ElmPtr^.Next;
      end;
      for c := (LastCol+1) to (Neq+1) do Write('nil':6);
      WriteLn;
    end;                {for row}
  end;                  {showmat}


var
  SumTerm        : Extended;
  Factor         : Extended;
  RHS            : Extended;
  Biggest        : Extended;
  Coeff          : Extended;
  PivotValue     : Extended;
  BestPtr        : PElmRec;
  PrevPtr        : PElmRec;
  Next_Pivot     : PElmRec;
  Next_Tar       : PElmRec;
  NewPtr         : PElmRec;
  ElmPtr         : PElmRec;
  MinRowCount    : Word;
  Best_Addelm    : Word;
  NextTarCol     : Word;
  NumToFind      : Word;
  AddElm         : Word;
  Col, LastCol   : Word;
  SingleCount    : Word;
  PivotStep      : Word;
  PivotCol       : Word;
  NextPivotCol   : Word;
  LastRow        : Word;
  PrevRow, NextRow : Word;
  PivotRow       : Word;
  Row            : Word;
  NextActiveRow  : PIntArr;
  ColCount       : PIntArr;
  RowCount       : PWordArr;
  PivRow         : PWordArr;
  function Solve1 : Boolean;

  label Go_on, AsBigAs, NextOne;
  label TwoSingles, NumericallySingular, NoVars, EmptyRow, EmptyCol,
OutOfSpace, ColsOutofOrder, NoRHS;
  label InsertElm, AdjustElm, OutCase;
  begin                 {solve1}
    if Msg then WriteLn('Entering Solve1');
    PivotStep := 0;
    FreeMemParaAlign(Pointer(OrigLastElm), (1+Neq)*SizeOf(PElmRec));


    if not GetMemParaAlign(Pointer(NextActiveRow), Pointer(OrigNextActiveRow),
(1+Neq)*SizeOf(Integer)) then goto OutOfSpace;
    if not GetMemParaAlign(Pointer(ColCount), Pointer(OrigColCount),
(1+Neq)*SizeOf(Integer)) then goto OutOfSpace;
    if not GetMemParaAlign(Pointer(RowCount), Pointer(OrigRowCount),
(1+Neq)*SizeOf(Word)) then goto OutOfSpace;
    if not GetMemParaAlign(Pointer(PivRow), Pointer(OrigPivRow),
(1+Neq)*SizeOf(Word)) then goto OutOfSpace;


    Col := 0;           {set vectors to zero}
    FillStruct(RowCount^, 1+Neq, Col, SizeOf(Word));
    FillStruct(PivRow^, 1+Neq, Col, SizeOf(Word));
    FillStruct(ColCount^, 1+Neq, Col, SizeOf(Word));

    Solve1 := False;
    if Msg then WriteLn('about to set up row and column counts');
    for Row := 1 to Neq do begin
      ElmPtr := FirstElm^[Row];
      if (ElmPtr = nil) then goto EmptyRow;
      LastCol := 0;
      while ElmPtr <> nil do begin
        Col := ElmPtr^.Column;
        if DBug then ElmPtr^.CheckRow := Row;
        if (Col <= LastCol) then goto ColsOutofOrder
        else LastCol := Col;
        Inc(RowCount^[Row]);
        if DBug then Assert(Col > 0, '#2133');
        if DBug then Assert(Col <= (1+Neq), '#2134');
        if (Col <= Neq) then Inc(ColCount^[Col]);
        ElmPtr := ElmPtr^.Next;
      end;
      if (LastCol <> (1+Neq)) then goto NoRHS;
    end;                {for row}

    if Msg then WriteLn('about to complete setup');
    Row := 0;
    while (Row < Neq) do begin
      NextActiveRow^[Row] := Row+1;
      Inc(Row);
      if ColCount^[Row] = 0 then goto EmptyCol;
      if RowCount^[Row] = 1 then goto NoVars;
    end;                {for Row:=1 to neq}
    NextActiveRow^[Neq] := 0;
    {end setup}

    repeat              {pivot on variables which are mentioned only once}
      PivotCol := 0;
      PrevRow := 0;
      Row := NextActiveRow^[0];
      while Row <> 0 do begin
        NextRow := NextActiveRow^[Row];
        if DBug then Assert(Row > 0, '#8033');
        if DBug then Assert(Row <= Neq, '#9033');
        SingleCount := 0;
        ElmPtr := FirstElm^[Row]; if DBug then Assert(ElmPtr <> nil, '#34');
        if DBug then Assert(ElmPtr^.Column <= Neq, '#77');
        Col := ElmPtr^.Column;
        while (Col <= Neq) do begin
          if (ColCount^[Col] = 1) then begin
            PivotCol := Col;
            Inc(SingleCount);
          end;
          ElmPtr := ElmPtr^.Next; if DBug then Assert(ElmPtr <> nil, '#35');
          Col := ElmPtr^.Column;
        end;
        if (SingleCount > 1) then goto TwoSingles
        else if (SingleCount = 1) then begin
          Inc(PivotStep);
          PivotRow := Row;
          ElmPtr := FirstElm^[PivotRow]; if DBug then Assert(ElmPtr <> nil,
'#34');
          if DBug then Assert(ElmPtr^.Column <= Neq, '#77');
          Col := ElmPtr^.Column;
          while (Col <= Neq) do begin
            if DBug then Assert(ColCount^[Col] > 0, '#4177');
            Dec(ColCount^[Col]);
            ElmPtr := ElmPtr^.Next; if DBug then Assert(ElmPtr <> nil, '#35');
            Col := ElmPtr^.Column;
          end;
          PivRow^[PivotStep] := PivotRow;
          NextActiveRow^[PrevRow] := NextActiveRow^[PivotRow];
          NextActiveRow^[PivotRow] := -1; {useful ?}
          RowCount^[PivotRow] := PivotCol; {change of meaning}
          ColCount^[PivotCol] := -1; {mark as done}
        end             {if (SingleCount=1) }
        else {no Singles} PrevRow := Row;
        Row := NextRow;
      end;

    until (PivotCol = 0);


    {*************main loop}
    while PivotStep < Neq do begin
      Inc(PivotStep);
      if Msg then WriteLn('starting step ', PivotStep);

      { Find shortest row (PivotRow) and the preceding active row (LastRow)  }
      MinRowCount := MaxInt;
      PrevRow := 0; LastRow := 0;
      Row := NextActiveRow^[0];
      if DBug then Assert(Row <> 0, '#33');
      while Row <> 0 do begin
        if RowCount^[Row] < MinRowCount then begin
          MinRowCount := RowCount^[Row];
          PivotRow := Row;

          LastRow := PrevRow;
        end;
        PrevRow := Row;
        Row := NextActiveRow^[Row];
      end;

      if Msg then WriteLn('Pivotrow: ', PivotRow, ' Rowcount ', MinRowCount);

      Biggest := -1;
      ElmPtr := FirstElm^[PivotRow]; if DBug then Assert(ElmPtr <> nil, '#34');
      if DBug then Assert(ElmPtr^.Column <= Neq, '#77');
      while (ElmPtr^.Column <= Neq) do begin
        if (Abs(ElmPtr^.Value) > Biggest) then Biggest := Abs(ElmPtr^.Value);
        ElmPtr := ElmPtr^.Next; if DBug then Assert(ElmPtr <> nil, '#35');
      end;
      if DBug then Assert(Biggest >= 0, '#45');
      if Biggest = 0 then goto NumericallySingular;

      if Msg then WriteLn('Biggest was :', Biggest);

      Biggest := Biggest*Uvalue;
      BestPtr := nil;
      Best_Addelm := MaxInt;
      ElmPtr := FirstElm^[PivotRow]; if DBug then Assert(ElmPtr <> nil, '#36');
      while (ElmPtr^.Column <= Neq) do begin
        Col := ElmPtr^.Column;
        Dec(ColCount^[Col]);
        if (Abs(ElmPtr^.Value) >= Biggest) then begin
          AddElm := ColCount^[Col];
          {addelm is the number of additional nonzeros which would be added}
          {if this Pivot were chosen}
          if AddElm < Best_Addelm then begin
            BestPtr := ElmPtr;
            Best_Addelm := AddElm;
          end;
        end;            {if (....>=UValue)}
        ElmPtr := ElmPtr^.Next;
        if DBug then Assert(ElmPtr <> nil, '#37');
      end;
      if DBug then Assert(BestPtr <> nil, '#38');

      PivotCol := BestPtr^.Column;
      PivotValue := BestPtr^.Value;
      {Mark Pivot Row as inactive}
      NextActiveRow^[LastRow] := NextActiveRow^[PivotRow];

      {Answer Values for use by backsub}
      PivRow^[PivotStep] := PivotRow;
      {note change of meaning}
      NextActiveRow^[PivotRow] := -1; {useful ?}
      RowCount^[PivotRow] := PivotCol; {change of meaning}
      NumToFind := ColCount^[PivotCol];
      ColCount^[PivotCol] := -1; {mark as done}


      if Msg then Write('Start Pivot, ');
      if Msg then Write(' Pivotrow: ', PivotRow, ' Rowcount ', MinRowCount);
      if Msg then WriteLn(' PivotCol: ', PivotCol, ' ColCount ', NumToFind);

      Row := NextActiveRow^[0];
      while ((Row <> 0) and (NumToFind > 0)) do begin
        if (FreeCount < Neq) then if not FrePrime then goto OutOfSpace;

        {preload PrevPtr so that: PrevPtr^.Next :=  FirstElm^[Row]}
        PrevPtr := Addr(FirstElm^[Row-1]);
        ElmPtr := FirstElm^[Row];

        {the goto's in this section are intended to ease transition to assembly
language}

Go_on:  if (ElmPtr^.Column >= PivotCol) then goto AsBigAs;
        PrevPtr := ElmPtr;
        ElmPtr := ElmPtr^.Next; {not got to it yet}
        if DBug then Assert(ElmPtr <> nil, '#55');
        if (ElmPtr^.Column >= PivotCol) then goto AsBigAs;
        PrevPtr := ElmPtr;
        ElmPtr := ElmPtr^.Next; {not got to it yet}
        if DBug then Assert(ElmPtr <> nil, '#55');

        goto Go_on;
AsBigAs: if (ElmPtr^.Column <> PivotCol) then goto NextOne;

        {current row contains pivot col}
        if Msg then WriteLn('Altering Row ', Row);
        Factor := ElmPtr^.Value/PivotValue;
        Dec(NumToFind);


        { DELETE pivot col in current row}
        Dec(RowCount^[Row]);
        PrevPtr^.Next := ElmPtr^.Next;
        ElmPtr^.Next := FreePtr; FreePtr := ElmPtr; Inc(FreeCount);

        Next_Pivot := FirstElm^[PivotRow];
        if DBug then Assert(Next_Pivot <> nil, '#333');
        PrevPtr := Addr(FirstElm^[Row-1]); {PrevPtr^.Next :=  FirstElm^[Row]}
        Next_Tar := FirstElm^[Row];
        if DBug then Assert(Next_Tar <> nil, '#334');
        NextTarCol := Next_Tar^.Column;
        while Next_Pivot <> nil do begin
          NextPivotCol := Next_Pivot^.Column;
          if (NextPivotCol = PivotCol) then goto OutCase;

          while NextTarCol < NextPivotCol do begin
            PrevPtr := Next_Tar;
            Next_Tar := Next_Tar^.Next; if DBug then Assert(Next_Tar <> nil,
'#99');
            NextTarCol := Next_Tar^.Column
          end;
          if NextTarCol = NextPivotCol then goto AdjustElm;

InsertElm: {NextTarCol > NextPivotCol}
          {element in pivot row but not in current row: add in new element}
          if DBug then Assert(NextTarCol > NextPivotCol, '#69');
          if DBug then Assert(FreePtr <> nil, '#89');
          NewPtr := FreePtr;
          NewPtr^.Value := -Factor*Next_Pivot^.Value; {up for copro}
          FreePtr := FreePtr^.Next; Dec(FreeCount);
          PrevPtr^.Next := NewPtr;
          PrevPtr := NewPtr;
          NewPtr^.Column := NextPivotCol;
          if DBug then NewPtr^.CheckRow := Row;
          NewPtr^.Next := Next_Tar;
          Inc(ColCount^[NextPivotCol]);
          Inc(RowCount^[Row]);
          goto OutCase;

AdjustElm: if DBug then Assert(NextTarCol = NextPivotCol, '#67');
          Next_Tar^.Value := Next_Tar^.Value-Factor*Next_Pivot^.Value;
          PrevPtr := Next_Tar;
          Next_Tar := Next_Tar^.Next;
          if (Next_Tar <> nil) then
            NextTarCol := Next_Tar^.Column
          else NextTarCol := 2+Neq; {sentinel value}

OutCase:
          Next_Pivot := Next_Pivot^.Next; {move along pivot row}
        end;            {while Next_Pivot <>  Nil}

NextOne:
        Row := NextActiveRow^[Row];
      end;              {while row}
      if DBug then Assert(NumToFind = 0, '#66');
    end;                {main loop}

    {release un-needed vectors}
    FreeMemParaAlign(Pointer(OrigColCount), (1+Neq)*SizeOf(Integer));
    FreeMemParaAlign(Pointer(OrigNextActiveRow), (1+Neq)*SizeOf(Integer));


    {create Answer vector}
    if not GetMemParaAlign(Pointer(Answer), Pointer(OrigAnswer),
(1+Neq)*SizeOf(Double))
    then goto OutOfSpace;
    if DBug then for Row := 1 to Neq do Answer^[Row] := -99;


    PivotStep := 1+Neq;
    while (PivotStep > 1) do begin
      Dec(PivotStep);
      Row := PivRow^[PivotStep];
      PivotCol := RowCount^[Row]; {note change of meaning}
      SumTerm := 0.0;
      Coeff := 0.0;
      ElmPtr := FirstElm^[Row];
      if DBug then Assert(ElmPtr <> nil, '#188');
      while ElmPtr <> nil do begin
        Col := ElmPtr^.Column;
        if (Col = PivotCol) then
          Coeff := ElmPtr^.Value
        else if (Col <= Neq) then begin
          if DBug then Assert(Answer^[Col] <> -99, '#177');
          SumTerm := SumTerm+Answer^[Col]*ElmPtr^.Value;
        end
        else
          RHS := ElmPtr^.Value;

        ElmPtr := ElmPtr^.Next;
      end;              {until (elmptr=Nil)}
      if DBug then Assert(Answer^[PivotCol] = -99, '#77');
      Answer^[PivotCol] := (RHS-SumTerm)/Coeff;
    end;                {for PivotRow:=neq downto 1}


    FreeMemParaAlign(Pointer(OrigRowCount), (1+Neq)*SizeOf(Word));
    FreeMemParaAlign(Pointer(OrigPivRow), (1+Neq)*SizeOf(Word));


    Solve1 := True; Exit; {normal}


EmptyRow: SetErrorMsg('Empty Row', 1, Row, 0); Exit;
NoVars: SetErrorMsg('Row without Variables', 2, Row, 0); Exit;
EmptyCol: SetErrorMsg('Empty Col', 3, Col, 0); Exit;
TwoSingles: SetErrorMsg('Two Singles', 4, Row, PivotCol); Exit;
NoRHS: SetErrorMsg('No RHS', 5, Row, LastCol); Exit;
NumericallySingular: SetErrorMsg('Numerically Singular', 6, PivotRow,
PivotStep); Exit;
OutOfSpace: SetErrorMsg('Out of Space', 7, PivotStep, 4); Exit;
ColsOutofOrder: SetErrorMsg('Cols out of Order', 8, Row, Col); Exit;

  end;                  {Solve1}

end.
{************************************************************************}
{$N+,E+}
uses SolSpar;
var
  Reason         : String;
  ErrNo1, ErrNo2, ErrNo3 : Word;
  Col, Row, N    : Integer;
  Total, Value   : Double;
label Fail;
begin
  WriteLn('Initial Heap Size ', MemAvail);
  N := 1500;            {size of matrix}
  if not InitStruc(N) then goto Fail;

{constructs a 'band' matrix with column border and solves it}

{for testing purposes, the RHS is set up so that variable(n)
has value n. The 'Total' variable is part of this. In normal use
the RHS would be set to some other value}

  for Row := 1 to N do begin
    Total := 0.0;

    Value := 0.1+Random;
    Col := Row;
    if not AddElement(Row, Col, Value) then goto Fail;
    Total := Total+Col*Value;

    Col := Row-1;
    if (Col > 0) then begin
      Value := 0.1+Random;
      if not AddElement(Row, Col, Value) then goto Fail;
      Total := Total+Col*Value;
    end;

    Col := Row+1;
    if (Col <= N) then begin
      Value := 0.1+Random;
      if not AddElement(Row, Col, Value) then goto Fail;
      Total := Total+Col*Value;
    end;


    Col := N;
    Value := 0.1+Random;
    if not AddElement(Row, Col, Value) then goto Fail;
    Total := Total+Col*Value;

    if not SetRHS(Row, Total) then goto Fail;
  end;                  {for Row:= 1 TO N}
  WriteLn(' Memory Used To Store Matrix ', SparMemUsed);

  if not Solve1 then goto Fail;
  for Row := 1 to N do if ((Row mod 100) = 0) then begin
    if not GetAnswer(Row, Value) then goto Fail;
    WriteLn(Row:3, Value:15:5);
  end;
  WriteLn(' Max Memory Used To Solve Matrix ', SparMemUsed);
  ReleaseStruc;
  WriteLn(' Memory Used after ReleaseStruc ', SparMemUsed);
  WriteLn('  Final Heap Size ', MemAvail);

  Halt;

Fail:
  GetErrorMsg(Reason, ErrNo1, ErrNo2, ErrNo3);
  WriteLn('Failed:  Error ', ErrNo1:0, ' ', Reason, ' ', ' ', ErrNo2:3, ' ',
ErrNo3:3);
  ReleaseStruc;
  WriteLn(' Memory Used after ReleaseStruc ', SparMemUsed);
  WriteLn('  Final Heap Size ', MemAvail);
end.
{************************************************************************}
{$N+,E+}
uses SolSpar;
var
  Reason         : String;
  ErrNo1, ErrNo2, ErrNo3 : Word;
  Example, Col, Row, N : Integer;
  Total, Value   : Double;
label Fail, EndProg;
begin
  N := 4;               {size of matrix}

{Shows how error messages work. Compile and run
   test2 >tem
 off DOS command line.  Then compare file 'tem' with code below}

{for testing purposes, the RHS is set up so that variable(n)
has value n. The 'Total' variable is part of this. In normal use
the RHS would be set to some other value}

  for Example := 1 to 8 do begin
    WriteLn('Example ', Example);
    if not InitStruc(N) then goto Fail;

    if not AddElement(1, 1, 0.50) then goto Fail;
    if not AddElement(1, 3, 2.00) then goto Fail;
    if not SetRHS(1, 6.50) then goto Fail;

    if (Example <> 7) then
      if not AddElement(2, 2, 0.20) then goto Fail;
    if not AddElement(2, 4, 5.00) then goto Fail;
    if not SetRHS(2, 20.40) then goto Fail;

    if not AddElement(3, 3, 1.00) then goto Fail;
    if not AddElement(3, 1, 0.75) then goto Fail;
    if not SetRHS(3, 3.75) then goto Fail;

    if (Example = 1) or (Example = 7) then begin
      if not AddElement(4, 4, 6.00) then goto Fail;
      if not AddElement(4, 1, 2.00) then goto Fail;
      if not SetRHS(4, 26.00) then goto Fail;
    end
    else if (Example = 2) then begin {4th row is multiple of second}
      if not AddElement(4, 2, 0.40) then goto Fail;
      if not AddElement(4, 4, 10.0) then goto Fail;
      if not SetRHS(4, 26.00) then goto Fail;
    end
    else if (Example = 3) then begin {variables 2 and 4 each appear only in row
2}
      if not AddElement(4, 3, 1.00) then goto Fail;
      if not AddElement(4, 1, 0.75) then goto Fail;
      if not SetRHS(4, 26.00) then goto Fail;
    end
    else if (Example = 4) then begin {no vars in row 4}
      if not SetRHS(4, 26.00) then goto Fail;
    end
    else if (Example = 5) then begin    {no rhs}
      if not AddElement(4, 3, 1.00) then goto Fail;
      if not AddElement(4, 1, 0.75) then goto Fail;
    end
    else if (Example = 6) then begin   {no row 4}
    end;
    showmat;
    if not Solve1 then begin
      GetErrorMsg(Reason, ErrNo1, ErrNo2, ErrNo3);
      WriteLn('Failed:  Error ', ErrNo1:0, ' ', Reason, ' ', ' ', ErrNo2:3, '
', ErrNo3:3);
    end
    else begin
      Write('Solved: ');
      for Row := 1 to N do if GetAnswer(Row, Value)
        then Write('  X(', Row, ')=', Value:0:3)
        else goto Fail;
    end;
    WriteLn;

    if (Example < 7) then ReleaseStruc;
  end;                  {for example}

  Halt;

Fail:
  GetErrorMsg(Reason, ErrNo1, ErrNo2, ErrNo3);
  WriteLn('Failed:  Error ', ErrNo1:0, ' ', Reason, ' ', ' ', ErrNo2:3, ' ',
ErrNo3:3);
end.

