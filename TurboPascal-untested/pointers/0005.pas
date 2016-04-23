Program Linked;

Type
  FileDescriptor =
    Object
      Fpt       : File;
      Name      : String[80];
      HeaderSize: Word;
      RecordSize: Word;
      RecordPtr : Pointer;
      SoftPut   : Boolean;
      IsOpen    : Boolean;
      CurRec    : LongInt;

      Constructor Init(Nam : String; Hdr : Word; Size : Word; Buff : Pointer;
Put : Boolean);
      Destructor  Done; Virtual;
      Procedure   OpenFile; Virtual;
      Procedure   CloseFile; Virtual;
      Procedure   GetRecord(Rec : LongInt);
      Procedure   PutRecord(Rec : LongInt);
    end;

  FileLable =
    Record
      Eof : LongInt;
      MRD : LongInt;
      Act : LongInt;
      Val : LongInt;
      Sync: LongInt;
    end;

  LabeledFile =
    Object(FileDescriptor)
      Header : FileLable;

      Constructor Init(Nam : String; Size : Word; Buff : Pointer; Put :
Boolean);
      Destructor  Done; Virtual;
      Procedure   OpenFile; Virtual;
      Procedure   CloseFile; Virtual;
      Procedure   WriteHeader;
      Procedure   ReadHeader;
      Procedure   AddRecord;
      Procedure   DelRecord(Rec : LongInt);
    end;

  DetailHeaderPtr = ^DetailHeader;
  DetailHeader =
    Record
      Master : LongInt;
      Prev   : LongInt;
      Next   : LongInt;
    end;

  MasterHeaderPtr = ^MasterHeader;
  MasterHeader =
    Record
      First  : LongInt;
      Last   : LongInt;
    end;

  DetailFileDetailPtr = ^DetailFileDetail;
  DetailFileDetail =
    Object(LabeledFile)
      Constructor Init(Nam : String; Size : Word; Buff : Pointer; Put :
Boolean);
      Procedure   LinkChain(MR, Last, Curr : LongInt);
      Procedure   DelinkChain(Rec : LongInt);
    end;

  DetailFileMaster =
    Object(LabeledFile)
      Constructor Init(Nam : String; Size : Word; Buff : Pointer; Put :
Boolean);
      Procedure   LinkDetail(DF : DetailFileDetailPtr);
      Procedure   DelinkDetail(DF : DetailFileDetailPtr; DR : LongInt);
      Procedure   GetFirst(DF : DetailFileDetailPtr);
      Procedure   GetLast(DF : DetailFileDetailPtr);
      Procedure   GetNext(DF : DetailFileDetailPtr);
      Procedure   GetPrev(DF : DetailFileDetailPtr);
    end;

{---------------------------------------------------------------------------}

Constructor FileDescriptor.Init(Nam : String; Hdr : Word; Size : Word; Buff :
                                Pointer; Put : Boolean);
  begin
    IsOpen := False;
    Name := Nam;
    HeaderSize := Hdr;
    RecordSize := Size;
    RecordPtr := Buff;
    SoftPut := Put;
    CurRec := -1;
  end;

Destructor  FileDescriptor.Done;
  begin
    if SoftPut and (CurRec <> -1) then
        PutRecord(CurRec);
    if IsOpen then
        CloseFile;
  end;

Procedure   FileDescriptor.OpenFile;
  begin
    if IsOpen then
        Exit;
    Assign(Fpt,Name);
    {$I-}
    Reset(Fpt,1);
    if IoResult <> 0 then
        ReWrite(Fpt,1);
    if IoResult = 0 then
        IsOpen := True;
    {$I+}
    CurRec := -1;
  end;

Procedure   FileDescriptor.CloseFile;
  begin
    if not IsOpen then
        Exit;
    {$I-}
    Close(Fpt);
    if IoResult = 0 then
        IsOpen := False;
    {$I+}
    CurRec := -1;
  end;

Procedure   FileDescriptor.GetRecord(Rec : LongInt);
  Var
    Result : Word;
  begin
    if not IsOpen then
        Exit;
    if CurRec = Rec then
        Exit;
    if SoftPut and (CurRec <> -1) then
        PutRecord(CurRec);
    {$I-}
    if Rec = 0 then
      begin
        Seek(Fpt,0);
        if IoResult = 0 then
          begin
            BlockRead(Fpt,RecordPtr^,HeaderSize,Result);
            if (Result <> HeaderSize) or (IoResult <> 0) then
                {Error Routine};
          end;
      end
    else
      begin
        Seek(Fpt,HeaderSize + (Rec - 1) * RecordSize);
        if IoResult = 0 then
          begin
            BlockRead(Fpt,RecordPtr^,RecordSize,Result);
            if (Result <> RecordSize) or (IoResult <> 0) then
                {Error Routine};
          end;
      end;
    {$I+}
    CurRec := Rec;
  end;

Procedure   FileDescriptor.PutRecord(Rec : LongInt);
  Var
    Result : Word;
  begin
    if not IsOpen then
        Exit;
    {$I-}
    if Rec = 0 then
      begin
        Seek(Fpt,0);
        if IoResult = 0 then
          begin
            BlockWrite(Fpt,RecordPtr^,HeaderSize,Result);
            if (Result <> HeaderSize) or (IoResult <> 0) then
                {Error Routine};
          end;
      end
    else
      begin
        Seek(Fpt,HeaderSize + (Rec - 1) * RecordSize);
        if IoResult = 0 then
          begin
            BlockWrite(Fpt,RecordPtr^,RecordSize,Result);
            if (Result <> RecordSize) or (IoResult <> 0) then
                {Error Routine};
          end;
      end;
    CurRec := Rec;
    {$I+}
  end;

{---------------------------------------------------------------------------}

Constructor LabeledFile.Init(Nam : String; Size : Word; Buff : Pointer; Put :
Boolean);
  begin
    if Size < 4 then
      begin
        WriteLN('Record size must be 4 or larger');
        Fail;
      end;
    FileDescriptor.Init(Nam,Sizeof(Header),Size,Buff,Put);
    Header.Eof := 0;
    Header.MRD := 0;
    Header.Act := 0;
    Header.Val := 0;
    Header.Sync:= 0;
  end;

Destructor LabeledFile.Done;
  begin
    CloseFile;
    FileDescriptor.Done;
  end;

Procedure LabeledFile.OpenFile;
  begin
    FileDescriptor.OpenFile;
    if IsOpen then
        ReadHeader;
  end;

Procedure LabeledFile.CloseFile;
  begin
    {$I-}
    if IsOpen then
      begin
        if SoftPut and (CurRec <> -1) then
            PutRecord(CurRec);
        Header.Val := 0;
        WriteHeader;
        CurRec := -1;
      end;
    FileDescriptor.CloseFile;
    {$I+}
  end;

Procedure LabeledFile.ReadHeader;
  Var
    Result : Word;
  begin
    {$I-}
    Seek(Fpt,0);
    if IoResult = 0 then
      begin
        BlockRead(Fpt,Header,HeaderSize,Result);
        if (Result <> HeaderSize) or (IoResult <> 0) then
            {Error Routine};
      end;
    {$I+}
  end;

Procedure LabeledFile.WriteHeader;
  Var
    Result : Word;
  begin
    {$I-}
    Seek(Fpt,0);
    if IoResult = 0 then
      begin
        BlockWrite(Fpt,Header,HeaderSize,Result);
        if (Result <> HeaderSize) or (IoResult <> 0) then
            {Error Routine};
      end;
    {$I+}
  end;

Procedure LabeledFile.AddRecord;
  Var
    TmpRec : Pointer;
    Result : Word;
    Next   : LongInt;
  begin
    {$I-}
    if Header.MRD <> 0 then
      begin
        GetMem(TmpRec,RecordSize);
        Seek(Fpt,HeaderSize + (Header.MRD - 1) * RecordSize);
        if IoResult = 0 then
          begin
            BlockRead(Fpt,TmpRec^,RecordSize,Result);
            if (Result <> RecordSize) or (IoResult <> 0) then
                {Error Routine};
            Next := LongInt(TmpRec^);
            PutRecord(Header.MRD);
            Header.MRD := Next;
            Header.Act := Header.Act + 1;
          end;
        FreeMem(TmpRec,RecordSize);
      end
    else
      begin
        PutRecord(Header.Eof);
        Header.Eof := Header.Eof + 1;
        Header.Act := Header.Act + 1;
      end;
    WriteHeader;
    {$I+}
  end;

Procedure LabeledFile.DelRecord(Rec : LongInt);
  Var
    TmpRec : Pointer;
    Result : Word;
  begin
    {$I-}
    GetMem(TmpRec,RecordSize);
    Seek(Fpt,HeaderSize + (Rec - 1) * RecordSize);
    if IoResult = 0 then
      begin
        BlockRead(Fpt,TmpRec^,RecordSize,Result);
        LongInt(TmpRec^) := Header.MRD;
        BlockWrite(Fpt,TmpRec^,RecordSize,Result);
        if (Result <> RecordSize) or (IoResult <> 0) then
           {Error Routine};
        Header.MRD := Rec;
        Header.Act := Header.Act - 1;
        WriteHeader;
      end;
    {$I+}
  end;

{---------------------------------------------------------------------------}

Constructor DetailFileDetail.Init(Nam : String; Size : Word; Buff : Pointer;
Put : Boolean);
  begin
    if Size < 12 then
      begin
        WriteLn('Detail File Records must be 12 Bytes or more');
        Fail;
      end;
    LabeledFile.Init(Nam,Size,Buff,Put);
  end;

Procedure   DetailFileDetail.LinkChain(MR, Last, Curr : LongInt);
  Var
    Hdr : DetailHeaderPtr;
  begin
    Hdr := RecordPtr;
    if Last <> 0 then
      begin
        GetRecord(Last);
        Hdr^.Next := Curr;
        PutRecord(Last);
      end;
    GetRecord(Curr);
    Hdr^.Prev := Last;
    Hdr^.Master := MR;
    Hdr^.Next := 0;
    PutRecord(Curr);
  end;

Procedure   DetailFileDetail.DelinkChain(Rec : LongInt);  Var
    Hdr : DetailHeaderPtr;
    Tmp : LongInt;
  begin
    Hdr := RecordPtr;
    GetRecord(Rec);
    if Hdr^.Next <> 0 then
      begin
        Tmp := Hdr^.Prev;
        GetRecord(Hdr^.Next);
        Hdr^.Prev := Tmp;
        PutRecord(CurRec);
        GetRecord(Rec);
      end;
    if Hdr^.Prev <> 0 then
      begin
        Tmp := Hdr^.Next;
        GetRecord(Hdr^.Prev);
        Hdr^.Next := Tmp;
        PutRecord(CurRec);
        GetRecord(Rec);
      end;
    Hdr^.Master := 0;
    Hdr^.Next := 0;
    Hdr^.Prev := 0;
    PutRecord(Rec);
  end;

{---------------------------------------------------------------------------}

Constructor DetailFileMaster.Init(Nam : String; Size : Word; Buff : Pointer;
Put : Boolean);
  begin
    if Size < 8 then
      begin
        WriteLn('Master File Records must be 8 Bytes or more');
        Fail;
      end;
    LabeledFile.Init(Nam,Size,Buff,Put);
  end;

Procedure   DetailFileMaster.LinkDetail(DF : DetailFileDetailPtr);
  Var
    Hdr : MasterHeaderPtr;
  begin
    Hdr := RecordPtr;
    DF^.AddRecord;
    DF^.LinkChain(CurRec,Hdr^.Last,DF^.CurRec);
    Hdr^.Last := DF^.CurRec;
    if Hdr^.First = 0 then Hdr^.First := DF^.CurRec;
    PutRecord(CurRec);
  end;

Procedure   DetailFileMaster.DelinkDetail(DF : DetailFileDetailPtr; DR :
LongInt);
  Var
    Hdr : MasterHeaderPtr;
  begin
    Hdr := RecordPtr;
    DF^.GetRecord(DR);
    if Hdr^.Last = DR then
        Hdr^.Last := DetailHeader(DF^.RecordPtr^).Prev;
    if Hdr^.First = DR then
        Hdr^.First := DetailHeader(DF^.RecordPtr^).Next;
    DF^.DelinkChain(DR);
    PutRecord(CurRec);
  end;

Procedure   DetailFileMaster.GetFirst(DF : DetailFileDetailPtr);
  Var
    Hdr : MasterHeaderPtr;
  begin
    Hdr := RecordPtr;
    if Hdr^.First = 0 then
      begin
        FillChar(DF^.RecordPtr^,DF^.RecordSize,#0);
        DF^.CurRec := -1;
        Exit;
      end;
    DF^.GetRecord(Hdr^.First);
  end;

Procedure   DetailFileMaster.GetLast(DF : DetailFileDetailPtr);
  Var
    Hdr : MasterHeaderPtr;
  begin
    Hdr := RecordPtr;
    if Hdr^.Last = 0 then
      begin
        FillChar(DF^.RecordPtr^,DF^.RecordSize,#0);
        DF^.CurRec := -1;
        Exit;
      end;
    DF^.GetRecord(Hdr^.Last);
  end;

Procedure   DetailFileMaster.GetNext(DF : DetailFileDetailPtr);
  Var
    Hdr : DetailHeaderPtr;
  begin
    Hdr := DF^.RecordPtr;
    if Hdr^.Next = 0 then
      begin
        FillChar(DF^.RecordPtr^,DF^.RecordSize,#0);
        DF^.CurRec := -1;
        Exit;
      end;
    DF^.GetRecord(Hdr^.Next);
  end;

Procedure   DetailFileMaster.GetPrev(DF : DetailFileDetailPtr);
  Var
    Hdr : DetailHeaderPtr;
  begin
    Hdr := DF^.RecordPtr;
    if Hdr^.Prev = 0 then
      begin
        FillChar(DF^.RecordPtr^,DF^.RecordSize,#0);
        DF^.CurRec := -1;
        Exit;
      end;
    DF^.GetRecord(Hdr^.Prev);
  end;

{---------------------------------------------------------------------------}

begin
end.

