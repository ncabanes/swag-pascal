
Unit bTree; { Zak's Binary Tree Object / routines.. }

{$O+,F+} { allow overlays }

Interface
Type KeyType = String[35]; {This can be changed if needed .., int, word, etc}

Type StatusType = (Used,Free);
Type ShowAllFuncType = Function (k:keytype;var Data):boolean;

 LeafType = record    { A "living" leaf }
      Status: StatusType;        { Status of node .. unused but useful } 
      Mother,Left,Right:longint; { pointers to Parent, Left, and Right nodes }
      Key: KeyType;              { the keyed data }
     end;
 GenericProcedure = procedure;   { used to dispay balancing status }

 FileHeaderType = record      
      DataRecSize,               { size of data records }
      Root,                      { pointer to root node }
      NextFree: longint;         { next free, unused node }
     end;

 DirectionType = (Right,Left);   { the directions, duh }

 DeletedLeaf = record            { a "dead" leaf -- overlaps old LeafType }
      Status  : StatusType;      { node status, hopefully Free}
      NextFree: longint;         { pointer to next unused, free node }
      Filler  : array[1..2]
                  of longint;    { pad LeafType.Left and Right }
      Filler2 : KeyType;         { pad LeafType.Key }
      end;

 pbTreeObj = ^bTreeObj;
 bTreeObj = Object

  Constructor Init       ( filename:string ; DataRecSize_:longint );

     { Initialize the object.. DataRecSize_ is ignored if the file is not
       new (has been Init'd before)}

  Destructor Done;

     { unused the memory and close the file }

  Function  Add          (Key: keytype; Var Data):boolean;

     { Add Data by Key -- returns FALSE if key exists, otherwise TRUE }

  Function  Find         (key: keytype):boolean;

     { returns TRUE if key could be found, FALSE otherwise }

  Function  FindData     (key: keytype; var data):boolean;

     { if key is found, then returns TRUE and correct data, FALSE otherwise }

  Function  Delete       (key: keytype):boolean;

     { returns TRUE if successful, FALSE if key not found }

  Function  BalanceHeapReq:longint;

     { returns bytes of heap required for a Balance }

  Procedure Balance      (Reading,Sorting,Updating:GenericProcedure);

     { Makes the AVERAGE number of links needed to find a key the least
       possible }

  Procedure ShowAll (func:ShowAllFuncType);

     { cycles through all the nodes, calling func until it returns FALSE 
       or no more nodes.. }

  function Update(key:keytype; Var Data):boolean;

     { if key found, writes new Data to it, otherwise returns FALSE }

  private { INTERNAL to the object }
   f:file;                  { the file we're playing with }
   dataRecSize:longint;     { current data record size }
   Function RecOfs        (n:longint):longint;
      { returns offset of given record }
   Procedure ReadRecLeaf  (n:longint;var RecHdr:LeafType);
      { reads only the LeafType of record n }
   Procedure ReadRecBoth  (n:longint;var RecHdr:LeafType;var data);
      { reads both the LeafType and the data }
   Procedure WriteRecLeaf (n:longint;RecHdr:LeafType);
      { writes only the LeafType}
   Procedure WriteRecBoth (n:longint;RecHdr:LeafType;var data);
      { write both the LeafType and Data }
   Procedure WriteRecData (n:longint;var data);
      { just write the data for record n }
   Function  NumRecords   (filehdr:fileheadertype):longint;
      { returns number of total records in file }
   Function  GetNewRecNum (filehdr:fileheadertype):longint;
      { returns next free record number }
   Procedure ReadFileHdr  (var filehdr:fileheadertype);
      { reads the file header .. cryptic, eh? }
   Procedure WriteFileHdr (filehdr:fileheadertype);
      { writes the file's header }
   Procedure FindNewMother(r:longint;filehdr:fileheadertype);
      { reassign this node a new, more suitable, parent when orphaned :-) }
   Function  FindKeyRec   (key: keytype):longint;
      { returns record number with this key, 0 otherwise }
  end;

Implementation
uses Dos;

Constructor bTreeObj.Init( filename:string; datarecsize_:longint );
 var fileheader:fileheadertype;
  t:word;
 begin
 {$I-}
 assign(f,filename);
 reset(f,1);
 {$I+}
 t:=ioresult;
 Case t of
  0: begin { file exists.. ok so far }
     ReadFileHdr(fileheader);
     datarecsize:=fileheader.datarecsize;  { init. prv. datarecsize }
     end;
  2: begin { new file, let's initialize it, ok? }
     ReWrite(f,1);
     FileHeader.DataRecSize:=DataRecSize_; { setup header data }
     datarecsize:=datarecsize_;
     FileHeader.Root:=0;
     FileHeader.NextFree:=0;
     BlockWrite(f,FileHeader,Sizeof(FileHeader)) { write header data }
     end
  else RunError(t); { some other error .. }
  end
 end;

Procedure bTreeObj.ShowAll (func:ShowAllFuncType);
 var fileheader:fileheadertype;
     rh     :leaftype;
     data   :pointer;
     cont   :boolean;
 procedure climb(r:longint);
      var right:longint;
      begin
      ReadRecboth(r,rh,Data^);
      right:=rh.right;
      if not(rh.left=0) then
         begin
         Climb(rh.left);
         ReadRecBoth(r,rh,data^) { read back current data if needed }
         end;
      if not cont then exit; { "just checking" }
      cont := func(rh.key,data^);
      if not cont then exit;
      if not(right=0) then Climb(right);
      end;
 begin
 cont := true;
 ReadFileHdr(fileheader);
 GetMem(data,fileheader.datarecsize);
 if fileheader.root<>0 then Climb(fileheader.root);
 FreeMem(data,fileheader.datarecsize);
 end;


Destructor bTreeObj.Done;
  begin
  close(f) { just close the file.. no big deal }
  end;

Function  bTreeObj.Add(Key: keytype; var data):boolean;
  var FileHdr: FileHeaderType;
      RecHdr  : LeafType;
  Procedure AddNewRec;
    Function FindMother(var direction:directiontype):longint;
      var RecHdr  :leaftype;
          LastNode:longint;
      procedure Search_Tree(n:longint);
        begin
        ReadRecLeaf(n,RecHdr);
        if Key>RecHdr.Key then
             if not(RecHdr.Right=0) then Search_Tree(RecHdr.Right) else
                 begin
                 LastNode:=n;
                 Direction:=Right;
                 end
        else if Key<RecHdr.Key then
             if not(RecHdr.Left=0) then Search_Tree(RecHdr.Left) else
                 begin
                 LastNode:=n;
                 Direction:=left;
                 end;
        end;
      begin
      Search_Tree(filehdr.root);
      FindMother:=LastNode;
      end;
    var MotherRec      :longint;
        MotherRecHdr   :Leaftype;
        MotherDirection:directiontype;
        NewRecNum      :longint;
        NewRecHdr      :leaftype;
    begin
    MotherRec:=FindMother(MotherDirection); { find available mother node }
    ReadRecLeaf(MotherRec,MotherRecHdr);    { "read her data" }
    NewRecNum := GetNewRecNum(filehdr);     { get next free record number }
    if not(NewRecNum>NumRecords(filehdr)) then
      begin
      ReadRecLeaf(NewRecNum,NewRecHdr);
      FileHdr.NextFree:=DeletedLeaf(NewRecHdr).NextFree;
      end;
    Case MotherDirection of
       Right: MotherRecHdr.Right:=NewRecNum;
       Left : MotherRecHdr.Left :=NewRecNum;
       end;
    With NewRecHdr do { initialize record.. }
      begin
      Status := used;
      Right  := 0;
      Left   := 0;
      Mother := MotherRec;
      end;
    NewRecHdr.Key:=Key;
    WriteFileHdr(FileHdr);                  { update file header }
    WriteRecLeaf(MotherRec,MotherRecHdr);   { write mother }
    WriteRecBoth(newrecnum,NewRecHdr,Data); { write daughter }
    end;
  procedure AddFirstRec;
    begin { we're adding the first record in the file.. scary eh? }
    With RecHdr do { init. it }
      begin
      Status := Used;
      Right  := 0;
      Left   := 0;
      Mother := 0;
      end;
    RecHdr.key:=key;
    FileHdr.Root := 1;
    FileHdr.NextFree := 0;
    Seek(f,0);
    BlockWrite(f,Filehdr,sizeof(filehdr));
    BlockWrite(f,RecHdr,Sizeof(RecHdr));
    BlockWrite(f,data,filehdr.datarecsize);
    end;
  begin
  if not Find(key) then { if not found, then .. }
    begin
    ReadFileHdr(filehdr);
    if FileHdr.Root=0 then
       AddFirstRec
    else
       AddNewRec;
    add := true;
    end
  else Add := false;
  end;

Function  bTreeObj.Find     (key: keytype):boolean;
 begin
 Find:=FindKeyRec(key)>0; { or BOOLEAN(FindKey(key)) would work too }
 end;

Function bTreeObj.Update(key:keytype; Var Data):boolean;
 var i:longint;
 begin
 i:=FindKeyRec(key);
 if i=0 then
   begin
   Update:=False;
   end
 else
   begin
   WriteRecData(i,data);
   update:=true;
   end
 end;

Function  bTreeObj.FindData    (key: keytype; var data):boolean;
 var filehdr:fileheadertype;
     rechdr :leaftype;
     r      :longint;
 begin
 r:=FindKeyRec(key);
 if r>0 then
   begin
   ReadRecBoth(r,rechdr,data);
   FindData:=true;
   end
 else
   finddata:=false
 end;

Function bTreeObj.Delete(key: keytype):boolean;
 var filehdr:fileheadertype;
 procedure Unlink(r:longint;var delhdr:leaftype);
  Function GetDirection(sonhdr:leaftype):directiontype;
   var sonrighthdr,sonlefthdr,motherhdr:leaftype;
       sre,sle:boolean;
   begin
   ReadRecLeaf(sonhdr.mother,motherhdr);
   if not(motherhdr.left=0) then
     begin
     ReadRecLeaf(motherhdr.left,sonlefthdr);
     sle:=true
     end
     else sle:=false;
   if not(motherhdr.right=0) then
     begin
     ReadRecLeaf(motherhdr.right,sonrighthdr);
     sre:=true;
     end
     else sre:=false;
   {$B-}
   if      sle and not sre then GetDirection:=Left
   else if sre and not sle then GetDirection:=Right
   else if (sle and sre) and (sonrighthdr.key=sonhdr.key) then GetDirection:=Right
   else if (sle and sre) and (sonlefthdr.key=sonhdr.key) then GetDirection:=left;
   {$B+}
   end;

   var MotherHdr:leaftype;
       direction:directiontype;
   begin
   if not(DelHdr.Mother=0) then
     begin
     ReadRecLeaf(DelHdr.Mother,MotherHdr);
     Direction:=GetDirection(DelHdr);
     case Direction Of
       Left : MotherHdr.Left:=0;
       Right: MotherHdr.Right:=0;
       end;
     WriteRecLeaf(delhdr.mother,motherhdr);
     end
   end;

 Procedure UpdateFreeList(r:longint);
   function LastFree:longint;
    var rechdr:leaftype;n,ths:longint;
     begin
     n:=filehdr.nextfree;
     ths:=n;
     repeat
       begin
       ReadRecLeaf(n,rechdr);
       ths:=n;
       n:=deletedleaf(rechdr).nextfree;
       end
     until DeletedLeaf(RecHdr).nextfree=0;
     LastFree:=ths;
     end;

   Var updatedptrhdr:leaftype;lf:longint;
   begin
   if filehdr.nextfree=0 then
     begin
     filehdr.nextfree:=r;
     writefilehdr(filehdr);
     end
   else
     begin
     lf:=lastfree;
     ReadRecLeaf(Lf,updatedptrhdr);
     DeletedLeaf(updatedptrhdr).nextfree:=r;
     WriteRecLeaf(lf,updatedptrhdr);
     end;
   end;

 Procedure AddChildren(var dhdr:leaftype);
   begin
   if not(dhdr.left=0) then FindNewMother(dhdr.left,filehdr);
   if not(dhdr.right=0) then FindNewMother(dhdr.right,filehdr);
   end;

 Procedure ChangeMother(r,tor:longint);
  var rechdr:leaftype;
  begin
  ReadRecLeaf(r,rechdr);
  rechdr.mother:=tor;
  WriteRecLeaf(r,rechdr);
  end;

 { this is huge }

 var DelRecNum:longint;
     delhdr   :leaftype;
 begin
 ReadFileHdr(filehdr);
 DelRecNum:=FindKeyRec(key); { find the record we're refering to }
 DelHdr.Status:=Free; { change its status }
 if not(DelRecNum>0) then Delete:=False else
  begin
  ReadRecLeaf(delrecnum,delhdr); { read the dead-to-be's header }
  if delhdr.Mother=0 then
    { we're dealing with the ROOT node ! }
    begin
    Delete:=true;
    UpdateFreeList(delrecnum); { add to free list }
    if not(delhdr.Right=0) then
      begin
      FileHdr.Root := delhdr.Right;
      ChangeMother(delhdr.Right,0);
      if not(delhdr.left=0) then FindNewMother(delhdr.left,filehdr);
      end;
    if not(delhdr.left=0) and (delhdr.right=0) then
      begin
      FileHdr.Root := delhdr.Left;
      ChangeMother(delhdr.Left,0);
      end;
    if (delhdr.right=0) and (delhdr.left=0) then
      begin
      FileHdr.Root:=0;
      end;
    DelHdr.Status:=Free;
    WriteFileHdr(filehdr);
    DeletedLeaf(DelHdr).NextFree:=0;
    WriteRecLeaf(delrecnum,delhdr);
    end
  else
    { the easy part }
    begin
    Delete:=true;
    Unlink(DelRecNum,delhdr);         { unlink it from its parent }
    UpdateFreeList(delrecnum);        { add to free list }
    DeletedLeaf(DelHdr).NextFree:=0;  { this is the last in the chain .. }
    WriteRecLeaf(delrecnum,delhdr);
    AddChildren(delhdr);              { re-classify its offspring }
    end;
  end;
 end;

Function  bTreeObj.BalanceHeapReq:longint;
  var rechdr    :leaftype;
      filehdr   :fileheadertype;
      numnodes  :longint;
   procedure Climb(r:longint);
      begin
      ReadRecLeaf(r,rechdr);
      if not(rechdr.left=0) then Climb(rechdr.left);
      ReadRecLeaf(r,rechdr);
      inc(numnodes);
      if not(rechdr.right=0) then Climb(rechdr.right);
      end;
   begin
   numnodes:=0;
   readfilehdr(filehdr);
   if not(FileHdr.Root=0) then Climb(FileHdr.Root);
   balanceheapreq:=numnodes*20; { sizeof(ListRecType) }
   end;

Procedure bTreeObj.Balance(Reading,Sorting,Updating:GenericProcedure );
 type ToListRecType = ^ListRecType;
      ListRecType   = Record
         node,mother,left,right:longint;
         Next:ToListRecType;
         end;
 var filehdr     : fileheadertype;
     ListRecRoot : ToListRecType;
     NumNodes    : longint;
     MarkMem     : pointer;
 Procedure ReadFileToLL;
  var rechdr    :leaftype;
      curlistrec:tolistrectype;
   Procedure Add(r:longint);
     begin
     inc(NumNodes);
     if CurListRec=Nil then
       begin
       new(CurListRec);
       CurListRec^.Next := Nil;
       ListRecRoot := CurListRec;
       end
     else
       begin
       New(CurListRec^.next);
       CurListRec:=CurListRec^.Next;
       CurListRec^.Next := Nil;
       end;
     CurListRec^.Node:=r;
     CurListRec^.Mother:=0;
     CurListRec^.Left:=0;
     CurListRec^.Right:=0;
     end;
   procedure Climb(r:longint);
      begin
      ReadRecLeaf(r,rechdr);
      if not(rechdr.left=0) then Climb(rechdr.left);
      ReadRecLeaf(r,rechdr);
      Add(r);
      if not(rechdr.right=0) then Climb(rechdr.right);
      end;
   begin
   CurListRec:=ListRecRoot;
   if not(FileHdr.Root=0) then Climb(FileHdr.Root);
   end;
 Procedure GetRecNumInfo(n:longint; var mother,left,right:longint);
   var c:tolistrectype;
   begin
   c:=listrecroot;
   while c^.node<>n do c:=c^.next;
   mother:=c^.mother;
   left:=c^.left;
   right:=c^.right;
   end;
 Procedure PutRecNumInfo(n,mother,left,right:longint);
  var c:tolistrectype;
   begin
   c:=listrecroot;
   while c^.node<>n do c:=c^.next;
   c^.mother:=mother;
   c^.left:=left;
   c^.right:=right;
   end;
 Function Power(b,e:longint):longint;
   var t,c:longint;
   begin
   t:=b;
   if e=0 then begin power:=1 ; exit end;
   for c:=1 to e-1 do t:=t*b;
   power:=t;
   end;
 Procedure ProcessLL;
  var MaxNumNodes: longint;
      NumSubLevels  : longint;
      TempMother,TempRight,TempLeft:longint;
      Modifier   : longint;
  Function FindNumSubLevels(n:longint):longint;
    var i:longint;
    begin
    i:=1;
    repeat inc(i,1) until (power(2,i)>=n+1);
    FindNumSubLevels:=i-1;
    end;
  Function RightMod(root,modi:longint):longint;
    begin
    repeat
      begin
      modi := modi div 2;
      end
    until root+modi<=numnodes;
    RightMod := modi;
    end;
  Procedure FixSubTree(root:longint;mthr:longint);
     var sr:longint;
     begin
     if not(abs(mthr-root)=1) then
       begin
       modifier:=abs(mthr-root) div 2;
       templeft:=root-modifier;
       if (root+modifier<=NumNodes) then
          tempright:=root+modifier
       else
          begin
          modifier:=Rightmod(root,modifier);
          if not(modifier=0) then TempRight:=root+modifier else tempright:=0;
          end;
       tempmother:=mthr;
       PutRecNumInfo(root,tempmother,templeft,tempright);
       sr:=tempright;
       if not(templeft=0) then FixSubTree(templeft,root);
       if not(sr=0) then FixSubTree(sr,root);
       end
     else { lowest leaves }
       begin
       PutRecNumInfo(root,mthr,0,0);
       end;
     end;
   Function MaxNodes:longint;
    var i:longint;
    begin
    i:=0;
    repeat inc(i,1) until (power(2,i+1)-1)>=NumNodes;
    MaxNodes:= Power(2,i+1)-1;
    end;
  Var NewRoot:longint;
  begin
  MaxNumNodes := MaxNodes;
  NumSubLevels := FindNumSubLevels(MaxNumNodes); { number of "shelves" }
  if NumNodes<2 then NewRoot:=FileHdr.Root else NewRoot:=Power(2,NumSubLevels);
  FileHdr.Root := NewRoot;
  FixSubTree(NewRoot,0);
  end;
 Procedure WriteLLtoFile;
   var CurListRec: tolistrectype;
       l:leaftype;
   begin
   curlistrec:=listrecroot;
   while curlistrec<>nil do
      begin
      ReadRecLeaf(curlistrec^.node,l);
      l.left:=curlistrec^.left;
      l.right:=curlistrec^.right;
      l.mother:=curlistrec^.mother;
      WriteRecLeaf(curlistrec^.node,l);
      curlistrec:=curlistrec^.next;
      end;
   end;
 begin
 NumNodes := 0;
 ListRecRoot:=nil;
 Mark(MarkMem);
 ReadFileHdr(filehdr);
 reading; { status }
 if not(filehdr.root=0) then ReadFileToLL; { if there are >0 records then }
 sorting; { status }                       { read data into the linked list}
 if not(filehdr.root=0) then ProcessLL;    { change data in LL }
 updating; { status }
 if not(filehdr.root=0) then WriteLLtoFile; { updated disk with LL data }
 WriteFileHdr(filehdr);
 Release(MarkMem);
 end;

{privates}

Function bTreeObj.RecOfs(n:longint):longint;
 begin
 RecOfs:=Sizeof(FileHeaderType)+((n-1)*(DataRecSize+Sizeof(LeafType)));
 end;

Procedure bTreeObj.ReadRecLeaf(n:longint;var RecHdr:LeafType);
 begin
 seek(f,recofs(n));
 blockread(f,rechdr,sizeof(leaftype));
 end;

Procedure bTreeObj.ReadRecBoth(n:longint;var RecHdr:LeafType;var data);
 begin
 seek(f,recofs(n));
 blockread(f,rechdr,sizeof(rechdr));
 blockread(f,data,datarecsize);
 end;

Procedure bTreeObj.WriteRecLeaf(n:longint;RecHdr:LeafType);
 begin
 seek(f,recofs(n));
 blockwrite(f,rechdr,sizeof(rechdr));
 end;

Procedure bTreeObj.WriteRecBoth(n:longint;RecHdr:LeafType;var data);
 begin
 seek(f,recofs(n));
 blockwrite(f,rechdr,sizeof(rechdr));
 blockwrite(f,data,datarecsize);
 end;

Procedure bTreeObj.WriteRecData (n:longint;var data);
 begin
 Seek(f,recofs(n)+Sizeof(LeafType));
 blockwrite(f,data,datarecsize);
 end;

Function bTreeObj.NumRecords(filehdr:fileheadertype):longint;
 var tv:longint;
 begin
 NumRecords := (FileSize(f)-Sizeof(FileHdr)) div (Sizeof(LeafType)+FileHdr.DataRecSize);
 end;

Function bTreeObj.GetNewRecNum(filehdr:fileheadertype):longint;
 begin
 if filehdr.nextfree=0 then
  begin
  GetNewRecNum := NumRecords(filehdr)+1;
  exit
  end
 else
  GetNewRecNum := FileHdr.NextFree;
 end;

Procedure bTreeObj.ReadFileHdr(var filehdr:fileheadertype);
 begin
 seek(f,0);
 blockread(f,FileHdr, sizeof(filehdr));
 end;

Procedure bTreeObj.WriteFileHdr( filehdr:fileheadertype);
 begin
 seek(f,0);
 blockwrite(f,FileHdr, sizeof(filehdr));
 end;

Procedure bTreeObj.FindNewMother ( r:longint;filehdr:fileheadertype);
    var rechdr:leaftype;
    Function FindMother(var direction:directiontype):longint;
      var Hdr  :leaftype;
          LastNode:longint;
      procedure Search_Tree(n:longint);
        begin
        ReadRecLeaf(n,Hdr);
          if RecHdr.Key>Hdr.Key then
             if not(Hdr.Right=0) then Search_Tree(Hdr.Right) else
                 begin
                 LastNode:=n;
                 Direction:=Right;
                 end
          else if RecHdr.Key<Hdr.Key then
             if not(Hdr.Left=0) then Search_Tree(Hdr.Left) else
                 begin
                 LastNode:=n;
                 Direction:=left;
                 end;
        end;
      begin
      Search_Tree(filehdr.root);
      FindMother:=LastNode;
      end;

    var mhdr:leaftype;
        mrec:longint;
        motherdirection:directiontype;
    begin
    ReadRecLeaf(r,RecHdr);
    mrec:=FindMother(motherdirection);
    ReadRecLeaf(mrec,MHdr);
    RecHdr.Mother := mrec;
    Case MotherDirection of
       Right: MHdr.Right:=r;
       Left : MHdr.Left :=r;
       end;
    WriteRecLeaf(mrec,MHdr);
    WriteRecLeaf(r,RecHdr);
    end;

Function bTreeObj.FindKeyRec    (key: keytype):longint;
 var filehdr:fileheadertype;
     rechdr :leaftype;
   procedure FindKey(r:longint);
     begin
     ReadRecLeaf(r,RecHdr);
     if Key>RecHdr.Key then
        if not(RecHdr.Right=0) then FindKey(RecHdr.Right) else
               begin
               FindKeyRec:=0;
               end
        else if Key<RecHdr.Key then
             if not(RecHdr.Left=0) then FindKey(RecHdr.Left) else
               begin
               FindKeyRec:=0;
               end
        else if Key=RecHdr.Key then FindKeyRec:=r;
     end;
 begin
 ReadFileHdr(filehdr);
 if filehdr.root=0 then FindKeyRec:=0 else FindKey(filehdr.root)
 end;

end.
