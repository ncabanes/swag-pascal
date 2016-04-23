{
From: nrivers@silver.ucs.indiana.edu (n paul rivers)

   I did manage to find part of the code that was once used to write
a preliminary version of a Huffman compression program.  Oddly, some of
the procedures were missing, and worse, there were no comments.  I
apologize for all this, but hopefully it will be some use in spite of
the inadequacies.  Also, your post makes mention of wanting the "optimum"
way to do this -- well, this isn't it!  But it will work, and perhaps it
will give you some ideas.
}

Type
  TNodePtr = ^TNode;
  TNode = Record
    Count : Longint;
    Parent, Left, Right : TNodePtr;
    end;
  TNodePtrArray = Array[0..255] of TNodePtr;
  TFreqArray = Array[0..255] of Longint;
  TFileName = String[12];
  TBitTable = Array[0..255] of Byte;

Var
  Source, Dest : TFileName;
  LeafNodes : TNodePtrArray;
  Freq : TFreqArray;
  BitTable : TBitTable;
  TotalBytes : Longint;
  P : Pointer;
  C : Char;

Procedure GetFileNames(var Source, Dest : TFileName);
  Begin
    If ParamCount<>2 then begin
       writeln('Specify the file to compress & its destination name.');
       writeln; halt; end;
    Source := ParamStr(1);
    Dest := ParamStr(2);
  End;

Procedure InitializeArrays(var Leaf : TNodePtrArray; 
          var Freq : TFreqArray; var BitTable : TBitTable);
  Var
    B : Byte;
  Begin
    For B := 0 to 255 do begin
      Leaf[B] := nil;
      Freq[B] := 0;
      BitTable[B] := '';
    End;
  End;

Procedure GetByteInfo(Source : TFileName; var Freq : TFreqArray; 
                      var TotalBytes : Longint);
  Var
    S : File of Byte;
    inputByte : Byte;
  Begin
    Assign(S, Source);
    Reset(S);
    TotalBytes := 0;
    While not(eof(s)) do begin
      read(s,inputByte);
      Inc(Freq[inputByte]);
      Inc(TotalBytes);
    end;
    Close(S);
  End;

Procedure LoadNodeArray(var LeafNodes : TNodePtrArray; 
                        var Freq : TFreqArray);
  Var
    B : Byte;
    Node : TNodePtr;
  Begin
    Node := Nil;
    For B := 0 to 255 do if Freq[B]>0 then begin
      New(Node);
      Node^.Parent := nil;
      Node^.Left := nil;
      Node^.Right := nil;
      Node^.Count := Freq[B];
      LeafNodes[B] := Node;
      Node := Nil;
    End;
  End;

Procedure GetMinInFreeArray(var min1, min2 : byte; var CFA : TNodePtrArray);
  Var b : byte;
      minCount1, minCount2 : Longint;
  Begin
    minCount1 := 1000000000; minCount2 := minCount1;
    min1 := 0; min2 := 0;
    for b := 0 to 255 do if CFA[b]<>nil then begin
      if minCount1>CFA[b]^.Count then begin
         min2 := min1; min1 := b;
         minCount2 := minCount1; minCount1 := CFA[b]^.Count;
         end
      else if ((minCount2>=CFA[b]^.Count) and (b<>min1)) then begin
         minCount2 := CFA[b]^.Count; min2 := b;
         end;
    end;
  End;


Procedure BuildTree(var LeafNodes : TNodePtrArray);
  Var
     CFA, NFA : TNodePtrArray;  Node : TNodePtr;
     {CFA = current free array,  NFA = next free array
      once two nodes in the current free array have been combined to
      form one node at one level 'up' the tree, then this new node must
      be placed in the NFA for the upcoming round of combining nodes}
     FreeThisLvl, NoCombs : Word;
     {FreeThisLvl = continue combining nodes at each level until after one
      round of combining, there is only one node left.  "there can be only
      one!"  NoCombs = number of combinations to be made at the given level"}
     Cnt, min1, min2 : Byte;
  Begin
     FreeThisLvl := 0; Node := nil;
     for cnt := 0 to 255 do begin
         NFA[cnt] := nil;
         CFA[cnt] := LeafNodes[cnt];
         if CFA[cnt]<>nil then Inc(FreeThisLvl);
     end;

     While FreeThisLvl>1 do begin
       NoCombs := (FreeThisLvl div 2);
       For cnt := 1 to NoCombs do begin
           GetMinInFreeArray(min1,min2,CFA);
           New(Node);
           Node^.Parent := nil;
           Node^.Right := CFA[min1]; Node^.Left := CFA[min2];
           Node^.Count := CFA[min1]^.Count + CFA[min2]^.Count;
           Node^.Left^.Parent := Node;
           Node^.Right^.Parent := Node;
           NFA[cnt] := Node; Node := Nil;
           CFA[min1] := nil; CFA[min2] := nil;
       end;

       For cnt := 0 to 255 do if CFA[cnt]<>nil then NFA[0] := CFA[cnt];

       For cnt := 0 to 255 do begin
         CFA[cnt] := NFA[cnt];
         NFA[cnt] := nil;
       end;

       FreeThisLvl := 0;
       For cnt := 0 to 255 do if CFA[cnt]<>nil then Inc(FreeThisLvl);

     end;
  End;

Procedure BuildBitTable(var LeafNodes : TNodePtrArray; 
                        var BitTable : TBitTable)
  Begin
    {
    To build the bit table for a given value, set, e.g. ptr1 and ptr2, to
    point to the given leafnode.  then set ptr1 to point at the parent.
    then if ptr1^.left = ptr2 then the first bit for the given node is 0,
    else it is 1.  continue this process until you reach the top of the 
    tree.
    }
  End;

Procedure CompressFile(Source, Dest : TFileName; var BitTable : TBitTable; 
                       TotalBytes : Longint);
  Begin
    {
    remember to write the necessary tree information for decompression in
    the compressed file.  also, since the last byte of the file might 
    contain bits not relevant to decoding, i've decided to just keep track
    of the total # of bytes in the original file.  so don't forget to
    write this number to the file as well.
    }
  End;

BEGIN

  GetFileNames(Source,Dest);
  InitializeArrays(LeafNodes,Freq,BitTable);
  writeln('Gathering info...'); writeln;
  GetByteInfo(Source,Freq,TotalBytes);
  Mark(P);
  LoadNodeArray(LeafNodes,Freq);
  BuildTree(LeafNodes);
  BuildBitTable(LeafNodes,BitTable);
  Release(P);
  writeln('Compressing file...'); writeln;
  CompressFile(Source,Dest,BitTable,TotalBytes);
  writeln; writeln;

END.

