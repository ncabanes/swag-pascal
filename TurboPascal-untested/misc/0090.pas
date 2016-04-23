{$F+,O+}
UNIT OOPX;
                     (**************************************)
                     (*         OOPX  Version 1.00         *)
                     (* Object-Oriented Interface for the  *)
                     (*    Paradox Engine Version 2.0      *)
                     (*    and Turbo Pascal Version 6.0    *)
                     (*     Copyright 1991 Brian Corll     *)
                     (**************************************)
                     (*    Portions Copyright 1990-1991    *)
                     (*        Borland International       *)
                     (**************************************)


INTERFACE

Uses PXEngine;



const
     PXError : Integer = PXSUCCESS;
     VarLong  = 1;
     VarInt   = 2;
     VarDate  = 3;
     VarDoub  = 4;
     VarAlpha = 5;
     VarShort = 6;

type
   DateRec = record
      M,D,Y : Integer;
      end;

type
   PXObject = object
      ErrCode : Integer;
      THandle : TableHandle;
      RHandle : RecordHandle;
      LHandles: Array[1..32] of LockHandle;
      SearchBuf : RecordHandle;
      LastLock: Byte;
      Name    : String;
      RecNo   : RecordNumber;
      Locked  : Boolean;
      UnLocked: Boolean;
      constructor InitName(TblName : String);
      constructor InitOpen(TblName : String;
                  IndexID : Integer;
                  SaveEveryChange : Boolean);
      constructor InitCreate(TblName : String;
                  NFields : Integer;
                  Fields,Types : NamesArrayPtr);
      destructor Done;
      procedure  ClearErrors;
      procedure  LockRecord;
      procedure  LockTable(LockType : Integer);
      procedure  UnLockRecord;
      procedure  UnLockTable(LockType : Integer);
      procedure  RenameTable(FromName,ToName : String);
      procedure  AddTable(AddTableName : String);
      procedure  CopyTable(CopyName : String);
      procedure  CreateIndex(NFlds : Integer;
                 FldHandles : FieldHandleArray;
                 Mode : Integer);
      procedure  Encrypt(Password : String);
      procedure  Decrypt(Password : String);
      procedure  DeleteIndex(IndexID : Integer);
      procedure  EmptyTable;
      procedure  EmptyRecord;
      procedure  ReadRecord;
      procedure  InsertRecord;
      procedure  AddRecord;
      procedure  UpdateRecord;
      procedure  DeleteRecord;
      procedure  NextRecord;
      procedure  PrevRecord;
      procedure  GotoRecord(R : RecordNumber);
      procedure  Flush;
      procedure  SearchField(FHandle : FieldHandle;Mode : Integer);
      procedure  SearchKey(NFlds : Integer;Mode : Integer);
      procedure  InitSearchBuf(FldName : NameString;var Variable;VarType : Byte);
      procedure  PutField(FldName : NameString;var Variable);
      procedure  PutLongField(FldName : NameString;var L : Longint);
      procedure  GetField(FldName : NameString;var Variable);
      procedure  GetLongField(FldName : NameString;var L : Longint);
      function   FieldNumber(FldName : NameString) : Integer;
      function   FieldName(FHandle : FieldHandle) : NameString;
      function   FieldType(FHandle : FieldHandle) : NameString;
      function   IsBlank(FldName : NameString) : Boolean;
      function   TableChanged : Boolean;
      procedure  Refresh;
      procedure  Top;
      procedure  Bottom;
      function   GetRecordNumber : Longint;
      end;


function PXOk : Boolean;

IMPLEMENTATION

   function PXOk : Boolean;
   begin
      PXOk := (PXError = PXSUCCESS);
   end;

   constructor PXObject.InitName;
   begin
      Name := TblName;
   end;

   constructor PXObject.InitOpen;
   begin
      THandle := 0;
      Name := '';
      ErrCode := PXTblOpen(TblName,
                          THandle,
                          IndexID,
                          SaveEveryChange);
      If ErrCode = PXSUCCESS then
      begin
      Name := TblName;
      ErrCode := PXRecBufOpen(THandle,RHandle);
      ErrCode := PXRecBufOpen(THandle,SearchBuf);
      end;
      LastLock := 0;
      FillChar(LHandles,32,0);
      PXError := ErrCode;
      Locked := False;
      UnLocked := False;
   end;

   constructor PXObject.InitCreate(TblName : String;
                  NFields : Integer;
                  Fields,Types : NamesArrayPtr);
   begin
      ErrCode := PXTblCreate(TblName,NFields,Fields,Types);
      PXError := ErrCode;
   end;

   procedure  PXObject.Encrypt(Password : String);
   begin
      ErrCode := PXTblEncrypt(Name,Password);
      If ErrCode = PXERR_TABLEOPEN then
      begin
         ErrCode := PXTblClose(THandle);
         If ErrCode = PXSUCCESS then
         ErrCode := PXTblEncrypt(Name,Password);
      end;
      PXError := ErrCode;
   end;

   procedure PXObject.ClearErrors;
   begin
      ErrCode := 0;
      PXError := 0;
   end;

   procedure  PXObject.Decrypt(Password : String);
   begin
     ErrCode := PXPswAdd(Password);
     If ErrCode = PXSUCCESS then
     begin
      ErrCode := PXTblDecrypt(Name);
      If ErrCode = PXERR_TABLEOPEN then
      begin
         ErrCode := PXTblClose(THandle);
         If ErrCode = PXSUCCESS then
         ErrCode := PXTblDecrypt(Name);
      end;
     end;
     PXError := ErrCode;
   end;

   procedure PXObject.CreateIndex(NFlds : Integer;
                FldHandles : FieldHandleArray;
                Mode : Integer);
   begin
      ErrCode := PXKeyAdd(Name,NFlds,FldHandles,Mode);
      PXError := ErrCode;
   end;

   procedure PXObject.DeleteIndex;
   begin
      ErrCode := PXKeyDrop(Name,IndexID);
      PXError := ErrCode;
   end;

   procedure PXObject.Flush;
   begin
      ErrCode := PXSave;
      PXError := ErrCode;
   end;

   procedure PXObject.LockRecord;
   var LockTest : Boolean;
   begin
      Locked := False;
      Inc(LastLock);
      ErrCode := PXNetRecLock(THandle,LHandles[LastLock]);
      ErrCode := PXNetRecLocked(THandle,LockTest);
      Locked := (ErrCode = PXSUCCESS)
         and LockTest;
      If not Locked then Dec(LastLock);
      PXError := ErrCode;
   end;

   procedure PXObject.LockTable;
   begin
      Locked := False;
      ErrCode := PXNetTblLock(THandle,LockType);
      Locked := (ErrCode = PXSUCCESS);
      PXError := ErrCode;
   end;

   procedure  PXObject.UnLockRecord;
   begin
      UnLocked := False;
      ErrCode := PXNetRecUnlock(THandle,LHandles[LastLock]);
      If (ErrCode = PXSUCCESS) then
      begin
         UnLocked := True;
         LHandles[LastLock] := 0;
         Dec(LastLock);
      end;
   end;

   procedure  PXObject.UnLockTable(LockType : Integer);
   begin
      UnLocked := False;
      ErrCode := PXNetTblUnlock(THandle,LockType);
      PXError := ErrCode;
      UnLocked := (PXError = PXSUCCESS);
   end;

   procedure PXObject.RenameTable(FromName,ToName : String);
   begin
      ErrCode := PXTblRename(FromName,ToName);
      PXError := ErrCode;
   end;

   procedure PXObject.AddTable(AddTableName : String);
   begin
      ErrCode := PXTblAdd(AddTableName,Name);
      PXError := ErrCode;
   end;

   procedure PXObject.CopyTable(CopyName : String);
   begin
      ErrCode := PXTblCopy(Name,CopyName);
      PXError := ErrCode;
   end;

   procedure PXObject.EmptyTable;
   begin
      ErrCode := PXTblEmpty(Name);
      PXError := ErrCode;
   end;

   procedure PXObject.EmptyRecord;
   begin
      ErrCode := PXRecBufEmpty(RHandle);
      PXError := ErrCode;
   end;

   procedure PXObject.ReadRecord;
   begin
      ErrCode := PXRecGet(THandle,RHandle);
      PXError := ErrCode;
   end;

   procedure PXObject.InsertRecord;
   begin
      ErrCode := PXRecInsert(THandle,RHandle);
      PXError := ErrCode;
   end;

   procedure PXObject.AddRecord;
   begin
      ErrCode := PXRecAppend(THandle,RHandle);
      PXError := ErrCode;
   end;

   procedure PXObject.UpdateRecord;
   begin
      ErrCode := PXRecUpdate(THandle,RHandle);
      PXError := ErrCode;
   end;

   procedure PXObject.DeleteRecord;
   begin
      ErrCode := PXRecDelete(THandle);
      PXError := ErrCode;
   end;

   procedure PXObject.NextRecord;
   begin
      ErrCode := PXRecNext(THandle);
      PXError := ErrCode;
   end;

   procedure PXObject.PrevRecord;
   begin
      ErrCode := PXRecPrev(THandle);
      PXError:= ErrCode;
   end;

   procedure PXObject.GotoRecord(R : RecordNumber);
   begin
      ErrCode:= PXRecGoto(THandle,R);
      PXError := ErrCode;
   end;

   procedure PXObject.PutField(FldName : NameString;var Variable);
   var FType : NameString;
       FirstChar : Char;
       FHandle : FieldHandle;
   begin
      FHandle := FieldNumber(FldName);
      If (PXError <> PXSUCCESS) then Exit;
      ErrCode := PXFldType(THandle,FHandle,FType);
      FirstChar := FType[1];
      case FirstChar of
      'D' : ErrCode := PXPutDate(RHandle,FHandle,TDate(Variable));
      'A' : ErrCode := PXPutAlpha(RHandle,FHandle,String(Variable));
      '$','N'
          : ErrCode := PXPutDoub(RHandle,FHandle,Double(Variable));
      'S' : ErrCode := PXPutShort(RHandle,FHandle,Integer(Variable));
      end;
      PXError := ErrCode;
   end;

   procedure PXObject.InitSearchBuf(FldName : NameString;var Variable;VarType : Byte);
   var FHandle : FieldHandle;
   begin
      FHandle := FieldNumber(FldName);
      If (PXError <> PXSUCCESS) then Exit;
      case VarType of
      VarDate  : ErrCode := PXPutDate(SearchBuf,FHandle,TDate(Variable));
      VarAlpha : ErrCode := PXPutAlpha(SearchBuf,FHandle,String(Variable));
      VarDoub  : ErrCode := PXPutDoub(SearchBuf,FHandle,Double(Variable));
      VarShort : ErrCode := PXPutShort(SearchBuf,FHandle,Integer(Variable));
      VarLong  : ErrCode := PXPutLong(SearchBuf,FHandle,Longint(Variable));
      end;
      PXError := ErrCode;
   end;

   procedure PXObject.PutLongField(FldName : NameString;var L : Longint);
   var FHandle : FieldHandle;
   begin
      FHandle := FieldNumber(FldName);
      If (PXError <> PXSUCCESS) then Exit;
      ErrCode := PXPutLong(RHandle,FHandle,L);
      PXError := ErrCode;
   end;

   procedure PXObject.GetField(FldName : NameString;var Variable);
   var FType : NameString;
       FirstChar : Char;
       FHandle : FieldHandle;
   begin
      FHandle := FieldNumber(FldName);
      If (PXError <> PXSUCCESS) then Exit;
      ErrCode := PXFldType(THandle,FHandle,FType);
      FirstChar := FType[1];
      case FirstChar of
      'D' : ErrCode := PXGetDate(RHandle,FHandle,TDate(Variable));
      'A' : ErrCode := PXGetAlpha(RHandle,FHandle,String(Variable));
      '$','N'
          : ErrCode := PXGetDoub(RHandle,FHandle,Double(Variable));
      'S' : ErrCode := PXGetShort(RHandle,FHandle,Integer(Variable));
      end;
      PXError := ErrCode;
   end;

   procedure  PXObject.GetLongField(FldName : NameString;var L : Longint);
   var FHandle : FieldHandle;
   begin
      FHandle := FieldNumber(FldName);
      If (PXError <> PXSUCCESS) then Exit;
      ErrCode := PXGetLong(RHandle,FHandle,L);
      PXError := ErrCode;
   end;

   function PXObject.GetRecordNumber : Longint;
   begin
      ErrCode := PXRecNum(THandle,RecNo);
      If (ErrCode = PXSUCCESS) then
         GetRecordNumber := RecNo;
      PXError := ErrCode;
   end;

   function PXObject.FieldNumber(FldName : NameString) : Integer;
   var FldHandle : FieldHandle;
   begin
      ErrCode := PXFldHandle(THandle,FldName,FldHandle);
      If (ErrCode = PXSUCCESS) then FieldNumber := FldHandle
      else FieldNumber := 0;
      PXError := ErrCode;
   end;

   function PXObject.IsBlank(FldName : NameString) : Boolean;
   var Blank : Boolean;
       FHandle : FieldHandle;
   begin
      FHandle := FieldNumber(FldName);
      If (ErrCode <> PXSUCCESS) then PX(PXError);
      IsBlank := False;
      ErrCode := PXFldBlank(RHandle,FHandle,Blank);
      If ErrCode = PXSUCCESS then IsBlank := Blank;
      PXError := ErrCode;
   end;

   function PXObject.TableChanged : Boolean;
   var Changed : Boolean;
   begin
      TableChanged := False;
      ErrCode := PXNetTblChanged(THandle,Changed);
      If ErrCode = PXSUCCESS then
         TableChanged := Changed;
      PXError := ErrCode;
   end;

   procedure PXObject.Refresh;
   begin
      ErrCode := PXNetTblRefresh(THandle);
      PXError := ErrCode;
   end;

   function  PXObject.FieldName(FHandle : FieldHandle) : NameString;
   var FName : NameString;
   begin
      ErrCode := PXFldName(THandle,FHandle,FName);
      If ErrCode = PXSUCCESS then
         FieldName := FName
      else
         FIeldName := '';
      PXError := ErrCode;
   end;

   procedure PXObject.SearchField(FHandle : FieldHandle;Mode : Integer);
   begin
      ErrCode := PXSrchFld(THandle,SearchBuf,FHandle,Mode);
      PXError := ErrCode;
   end;

   procedure PXObject.SearchKey(NFlds : Integer;Mode : Integer);
   begin
      ErrCode := PXSrchKey(THandle,SearchBuf,NFlds,Mode);
      PXError := ErrCode;
   end;

   function  PXObject.FieldType(FHandle : FieldHandle) : NameString;
   var FType : NameString;
   begin
      FieldType := '';
      ErrCode := PXFldType(THandle,FHandle,FType);
      If ErrCode = PXSUCCESS then FieldType := FType;
      PXError := ErrCode;
   end;

   procedure PXObject.Top;
   begin
      ErrCode := PXRecFirst(THandle);
      PXError := ErrCode;
   end;

   procedure PXObject.Bottom;
   begin
      ErrCode := PXRecLast(THandle);
      PXError := ErrCode;
   end;


   destructor PXObject.Done;
   begin
      ErrCode := PXRecBufClose(RHandle);
      ErrCode := PXRecBufClose(SearchBuf);
      ErrCode := PXTblClose(THandle);
      PXError := ErrCode;
   end;

begin
end.


