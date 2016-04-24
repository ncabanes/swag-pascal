(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0303.PAS
  Description: Records
  Author: NFI EXPERIMENTAL PROGRAMMING
  Date: 08-30-97  10:08
*)

{-----------------------------------------------------------------------------}
{ A dynamic variable length record and array class for Delphi 2.0             }
{ Copyright 1996,97 NFI Experimental Programming. All Rights Reserved.        }
{ This component can be freely used and distributed in commercial and private }
{ environments, provided this notice is not modified in any way and there is  }
{ no charge for it other than nomial handling fees.  Contact NFI directly for }
{ modifications to this agreement.                                            }
{-----------------------------------------------------------------------------}
{ All correspondance concerning this file should be directed to               }
{ NFI Experimental Programming, E-Mail                                        }
{     nfi@post1.com                                                           }
{-----------------------------------------------------------------------------}
{ Date last modified:  March 4, 1997                                          }
{-----------------------------------------------------------------------------}


{-----------------------------------------------------------------------------}
{ SORRY FOR THE LACK OF COMMENTING, but as this file was initially designed   }
{ and documented "in-house" minimal commenting was deemed necessary. It was   }
{ only after this file was requested by several individuals that we decided   }
{ on releasing in to the general public. Thus commenting has escaped the      }
{ grasp of this source.                                                       }
{-----------------------------------------------------------------------------}


{ ----------------------------------------------------------------------------}
{ TNFIRecordList v2.1                                                         }
{ ----------------------------------------------------------------------------}
{ Description:                                                                }
{   The TNFIRecordList class operates similarly to the traditional Pascal     }
{   TCollection object. It creates a list consisting of TNFIRecordItem        }
{   objects capable of storing whatever information you require.              }
{-----------------------------------------------------------------------------}

{ ----------------------------------------------------------------------------}
{ TNFIVarRec v2.1                                                             }
{ ----------------------------------------------------------------------------}
{ Description:                                                                }
{   NOT TO BE CONFUSED WITH BORLANDS TVARREC type for variants!!! TNFIVarRec  }
{   is a variable record class that allows easy data access. It does not      }
{   store the internal makeup of information you have stored, so if you store }
{   an integer and two strings then you must remember that!                   }
{                                                                             }
{   Storing and retrieving this information from TNFIVarRec is relatively     }
{   easy, take for example:                                                   }
{                                                                             }
{   I want to store an integer and two strings. How do I do this?             }
{   STORING:                                                                  }
{      NFIVarRec.vInteger := AnInteger;                                       }
{      NFIVarRec.vString  := AString1;                                        }
{      NFIVarRec.vString  := AString2;                                        }
{   RETRIEVAL:
{      NFIVarRec.ResetPointer;  // Point to the start of the record. Do NOT   }
{                               // call "Reset" as this will remove all data  }
{                               // contained within TNFIVarRec!               }
{      AnInteger := NFIVarRec.vInteger;                                       }
{      AString1  := NFIVarRec.vString;                                        }
{      AString2  := NFIVarRec.vString;                                        }
{                                                                             }
{   Note that you must read this information in exactly the same order as you }
{   stored it!                                                                }
{-----------------------------------------------------------------------------}

{ ----------------------------------------------------------------------------}
{ TLongArray 2.1                                                              }
{ ----------------------------------------------------------------------------}
{ Description:                                                                }
{   TLongArray is a dynamic LongInt array object. Information can be accessed }
{   in the same manner as an array, for example LongArray[x] but supports     }
{   item-index removal. If you remove the first item then all other items are }
{   brought down one index automatically.                                     }
{                                                                             }
{   The biggest problem associated with this object is the fact that it       }
{   ONE based, not Zero as is traditional with C/C++ or Delphi. This is       }
{   because all in-house work using TLongArray is one based. If someone would }
{   like to post a fix, feel free to contact us and let us know!              }
{ ----------------------------------------------------------------------------}



unit NFILists;
interface
uses SysUtils, Classes, Windows;

      {=======================================================================}
      {                          RECORD OBJECT TYPES                          }
      {=======================================================================}


      { TNFIRecordList                                                        }
      {   This object is the generic record storage object.  It maintains a   }
      {   maximum list of "MaxInt" records of type TNFIRecordItem.            }
type
      TNFIVarRec = class;

      TNFIRecordItem = class(TObject)
      private
        Buffer: Pointer;
        RecordSize: Integer;
      public
        constructor Create(ARecord: Pointer; ASize: Integer);
        destructor  Destroy; override;
      published
        property Data: Pointer read Buffer;
        property Size: Integer read RecordSize;
      end;

      TNFIRecordList = class(TObject)
      private
        FItems: TList;
        RecordCount: Integer;
      public
        constructor Create;
        destructor  Destroy; override;
        procedure   AddRecord(ARecord: Pointer; Size: Integer);
        procedure   AddTNFIVarRec(ARecord: TNFIVarRec);
        procedure   InsertRecord(ARecord: Pointer; AtPos, Size: Integer);
        procedure   RemoveRecord(ARecNum: Integer);
        function    GetRecord(ARecNum: Integer): Pointer;
        function    GetTNFIVarRec(ARecNum: Integer; var ARecord: TNFIVarRec): Boolean;
        function    GetRecordSize(ARecNum: Integer): Integer;
        procedure   Clear;

      published
        property    Items: TList read FItems;
        {property    Size: Integer read RecordSize;}
        property    Count: Integer read RecordCount;
      end;


      TNFIVarRec = class(TObject)
      private
        Memory: TMemoryStream;
        MemorySize: LongInt;
        Ident: Integer;
        { Ident is used as a "Contents Information" identifier             }
        { -- As in "What in the heck did I store in this record ?"         }

        procedure SetMemorySize(ASize: LongInt);
        function  GetMemory: Pointer;
        function  GetSize: LongInt;

        procedure SetByte(AByte: Byte);
        procedure SetShortInt(AShortInt: ShortInt);
        procedure SetInteger(AInteger: Integer);
        procedure SetWord(AWord: Word);
        procedure SetLongInt(ALongInt: LongInt);
        procedure SetString(AString: String);
        procedure SetTimeStamp(ATime: TDateTime);

        function  GetByte: Byte;
        function  GetShortInt: ShortInt;
        function  GetInteger: Integer;
        function  GetWord: Word;
        function  GetLongInt: LongInt;
        function  GetString: String;
        function  GetTimeStamp: TDateTime;
      public
        constructor Create;
        destructor  Destroy; override;
        procedure   ResetPointer;
        procedure   Reset;
        procedure   Move(Source: Pointer; ASize: LongInt);
                    { MOVE: Move converts the buffer to SOURCE, and over-writes existing information }
        procedure   MoveItem(AnItem: TNFIRecordItem);
                    { As with the move above, but uses a TNFIRecordItem object as the source. }
        function    Append(Source: Pointer; ASize: LongInt): Boolean;
                    { APPEND: Appends SOURCE to the end of the current information }
        { THESE BLOBS ARE NOT TRADITIONAL DELPHI DATABASE BLOB OBJECTS. BLOB REFERS TO ANY GENERIC }
        { BINARY OBJECT THAT CAN ONLY BE READ AND WRITTEN FROM MEMORY! IF YOU NEED TO STORE A      }
        { BITMAP (FOR INSTANCE), YOU CAN READ AND WRITE IT USING APPENDBLOB AND READBLOBEX! NOTE   }
        { THAT TNFIVARREC AUTOMATICALLY STORES THE BLOB SIZE SO WHEN READ THE EQUIVALENT AMOUNT    }
        { OF MEMORY IS ALLOCATED. MAXIMUM BLOB SIZE IS 2 GB.                                       }
        function    AppendBlob(Source: Pointer; ASize: LongInt): Boolean;
                    { APPENDBLOB: Appends SOURCE to the end of the current information storing the size of the BLOB}
        function    ReadBlob(var Buffer: Pointer): LongInt;
                    { READBLOB: Reads a BLOB record from the current position within the file.          }
                    {           Buffer SHOULD NOT be assigned as ReadBlob will change it's location !!! }
                    {           Buffer is in fact set to point to the internal storage area, so prior   }
                    {           to making any changes make sure that you have copied this information   }
                    {           out!                                                                    }
        function    ReadBlobEx(var Buffer: Pointer): LongInt;
                    { READBLOBEX: Creates a new memory buffer of the appropriate size and copies the       }
                    {             contents of the BLOB into this new buffer. This allows the programmer    }
                    {             to directly perform read/write operations on the buffer, unlike READBLOB }
        function    AppendPChar(Source: PChar): Boolean;
        procedure   ReadPChar(Buffer: PChar);
        function    LoadFromFile(AFileName: String): Boolean;
                    { Clears out all information prior to loading and points to START! }
        procedure   LoadFromStream(AStream: TStream);
        procedure   SaveToFile(AFileName: String);
        procedure   SaveToStream(var AStream: TStream);

        property vByte: Byte read GetByte write SetByte;
        property vShortInt: ShortInt read GetShortInt write SetShortInt;
        property vInteger: Integer read GetInteger write SetInteger;
        property vWord: Word read GetWord write SetWord;
        property vLongInt: LongInt read GetLongInt write SetLongInt;
        property vLong: LongInt read GetLongInt write SetLongInt;
        property vString: String read GetString write SetString;
        property vTime: TDateTime read GetTimeStamp write SetTimeStamp;

        property Data: Pointer read GetMemory;
        property Size: LongInt read GetSize;
        property Capacity: LongInt read MemorySize write SetMemorySize;
        property ID: Integer read Ident write Ident default 0; // Set to zero anyway,
      end;                                                     // but hey...


      // TLongArray is one based!
      TLongArray = class
      private
        Buffer: Pointer;
        BufferSize, DataSize: LongInt;

        procedure Grow;      // Conducts a 4k increment
        procedure Truncate;  // Truncates the buffer at datasize
        function  GetCount: LongInt;
        function  GetAtPos(Index: Integer): LongInt;
        procedure ReplacePos(Index: Integer; AValue: LongInt);
      public
        constructor Create;
        destructor  Destroy; override;

        procedure   Reset;
        procedure   Add(ALongInt: LongInt);
        procedure   Remove(AtPos: LongInt);
        procedure   Insert(AtPos: LongInt; ALongInt: LongInt);
        procedure   Replace(AtPos: LongInt; ALongInt: LongInt);
        procedure   Inc(AtPos, ANum: LongInt);
        procedure   Dec(AtPos, ANum: LongInt);

        property    At[Index: Integer]: LongInt read GetAtPos write ReplacePos; default;
        property    Size: LongInt read DataSize;
        property    Data: Pointer read Buffer;
        property    Count: LongInt read GetCount;
      end;


implementation

      {=======================================================================}
      {  ** TNFIRECORDITEM CODE                                               }
      {=======================================================================}


constructor TNFIRecordItem.Create(ARecord: Pointer; ASize: Integer);
begin
  RecordSize := ASize;
  GetMem(Buffer, ASize);
  Move(ARecord^, Buffer^, RecordSize);
end;

destructor TNFIRecordItem.Destroy;
begin
  FreeMem(Buffer, RecordSize);
end;



      {=======================================================================}
      {  ** TNFIRECORDLIST CODE                                               }
      {=======================================================================}


constructor TNFIRecordList.Create;
begin
  RecordCount := 0;
  FItems      := TList.Create;
end;

destructor TNFIRecordList.Destroy;
begin
  if FItems <> nil then Clear;
  FItems.Free;
end;

procedure TNFIRecordList.AddRecord(ARecord: Pointer; Size: Integer);
var NewRecord: TNFIRecordItem;
    P: Pointer;
begin
  NewRecord := TNFIRecordItem.Create(ARecord, Size);
  FItems.Add(NewRecord);
  Inc(RecordCount);
end;

procedure TNFIRecordList.AddTNFIVarRec(ARecord: TNFIVarRec);
begin
  If Assigned(ARecord) Then
    AddRecord(ARecord.Data, ARecord.Size);
end;

// Returns a pointer to the data held by a TNFIRecordItem, not a pointer to the
// object itself.
   { The procedure itself uses "ARecord" because without it, the compiler gave }
   { me an error it informs me I shouldn't have. Anyway, it works now so...    }
function TNFIRecordList.GetRecord(ARecNum: Integer): Pointer;
var ARecord: TNFIRecordItem;
begin
  If (RecordCount = 0) or (ARecNum < 1) or (ARecNum > RecordCount) Then ARecord := nil
  Else ARecord := FItems[ARecNum - 1];
  If ARecord <> nil Then GetRecord := ARecord.Data Else GetRecord := nil;
end;

function TNFIRecordList.GetTNFIVarRec(ARecNum: Integer; var ARecord: TNFIVarRec): Boolean;
var P: Pointer;
begin
  GetTNFIVarRec := False;
  If Assigned(ARecord) Then
  begin
    P := GetRecord(ARecNum);
    ARecord.Move(P, GetRecordSize(ARecNum));
    GetTNFIVarRec := True;
  end;
end;

function TNFIRecordList.GetRecordSize(ARecNum: Integer): Integer;
begin
  If (RecordCount = 0) or (ARecNum < 1) or (ARecNum > RecordCount) Then GetRecordSize := -1
  Else GetRecordSize := TNFIRecordItem(FItems[ARecNum - 1]).Size;
end;

procedure TNFIRecordList.InsertRecord(ARecord: Pointer; AtPos, Size: Integer);
var NewRecord: TNFIRecordItem;
begin
  NewRecord := TNFIRecordItem.Create(ARecord, Size);
  FItems.Insert(AtPos - 1, NewRecord);  // As this is a 1 based array, subtract
  Inc(RecordCount);                     // one from it as TList is zero-based.
end;

procedure TNFIRecordList.RemoveRecord(ARecNum: Integer);
var ARecord: TNFIRecordItem;
begin
  If (RecordCount > 0) and (ARecNum > 0) and (ARecNum <= RecordCount) Then
  begin
    ARecord := FItems[ARecNum - 1];
    FItems.Delete(ARecNum - 1);
    ARecord.Free;
    Dec(RecordCount);
  end;
end;

procedure TNFIRecordList.Clear;
var i: Integer;
begin
  If RecordCount > 0 Then
    For i := RecordCount downto 1 Do
      RemoveRecord(i);
end;


      {=======================================================================}
      {  ** TNFIVarRec CODE                                                      }
      {=======================================================================}


constructor TNFIVarRec.Create;
begin
  MemorySize := 8192;
  try
    Memory := TMemoryStream.Create;
  except
    Abort;
  end;
end;

destructor TNFIVarRec.Destroy;
begin
  If Assigned(Memory) Then Memory.Free;
end;

procedure TNFIVarRec.ResetPointer;
begin
  Memory.Position := 0;
end;

procedure TNFIVarRec.Reset;
begin
  ResetPointer;
  Memory.Clear;
end;

procedure TNFIVarRec.SetMemorySize(ASize: LongInt);
begin
  If Assigned(Memory) Then Memory.SetSize(ASize);
end;

procedure TNFIVarRec.Move(Source: Pointer; ASize: LongInt);
begin
  Reset;
  Memory.WriteBuffer(Source^, ASize);
end;

procedure TNFIVarRec.MoveItem(AnItem: TNFIRecordItem);
begin
  If Assigned(AnItem) Then
    Move(AnItem.Data, AnItem.Size);
end;

function TNFIVarRec.Append(Source: Pointer; ASize: LongInt): Boolean;
begin
  try
    Memory.WriteBuffer(Source^, ASize);
    Append := True;
  except
    Append := False;
  end;
end;

{ THESE BLOBS ARE NOT TRADITIONAL DELPHI DATABASE BLOB OBJECTS. BLOB REFERS TO ANY GENERIC }
{ BINARY OBJECT THAT CAN ONLY BE READ AND WRITTEN FROM MEMORY! IF YOU NEED TO STORE A      }
{ BITMAP (FOR INSTANCE), YOU CAN READ AND WRITE IT USING APPENDBLOB AND READBLOB! NOTE     }
{ THAT TNFIVARREC AUTOMATICALLY STORES THE BLOB SIZE SO WHEN READ THE EQUIVALENT AMOUNT    }
{ OF MEMORY IS ALLOCATED. MAXIMUM BLOB SIZE IS 2 GB.                                       }
function TNFIVarRec.AppendBlob(Source: Pointer; ASize: LongInt): Boolean;
begin
  try
    Memory.WriteBuffer(ASize, 4);
    Memory.WriteBuffer(Source^, ASize);
    AppendBlob := True;
  except
    AppendBlob := False;
  end;
end;

{ Please read the associated notes located at the class definition }
function TNFIVarRec.ReadBlob(var Buffer: Pointer): LongInt;
var BlobSize: LongInt;
begin
  try
    Memory.ReadBuffer(BlobSize, 4);
    Buffer := Pointer(LongInt(Memory.Memory) + Memory.Position);
    Memory.Position := Memory.Position + BlobSize;
    ReadBlob := BlobSize;
  except
    Buffer := nil;
    ReadBlob := -1;
  end;
end;

{ Please read the associated notes located at the class definition }
function TNFIVarRec.ReadBlobEx(var Buffer: Pointer): LongInt;
var BlobSize: LongInt;
    P: Pointer;
begin
  try
    Memory.ReadBuffer(BlobSize, 4);
    P := Pointer(LongInt(Memory.Memory) + Memory.Position);
    Buffer := AllocMem(BlobSize);
    System.Move(P^, Buffer^, BlobSize);
    Memory.Position := Memory.Position + BlobSize;
    ReadBlobEx := BlobSize;
  except
    Buffer := nil;
    ReadBlobEx := -1;
  end;
end;

function TNFIVarRec.LoadFromFile(AFileName: String): Boolean;
var FileStream: TFileStream;
begin
  LoadFromFile := False;
  try
    FileStream := TFileStream.Create(AFilename, fmOpenRead);
    Reset;
    Memory.CopyFrom(FileStream, FileStream.Size);
    Memory.Position := 0;
    LoadFromFile := True;
  finally
    If Assigned(FileStream) Then FileStream.Free;
  end;
end;

procedure TNFIVarRec.LoadFromStream(AStream: TStream);
begin
  Reset;
  Memory.CopyFrom(AStream, AStream.Size);
  Memory.Position := 0;
end;

procedure TNFIVarRec.SaveToFile(AFileName: String);
var FileStream: TFileStream;
begin
  try
    FileStream := TFileStream.Create(AFilename, fmCreate);
    ResetPointer;  // NOT RESET! We want to keep all information!
    FileStream.CopyFrom(Memory, Memory.Size);
  finally
    If Assigned(FileStream) Then FileStream.Free;
  end;
end;

procedure TNFIVarRec.SaveToStream(var AStream: TStream);
begin
  ResetPointer;
  AStream.CopyFrom(Memory, Memory.Size);
end;

function TNFIVarRec.GetMemory: Pointer;
begin
  GetMemory := Memory.Memory;
end;

function TNFIVarRec.GetSize: LongInt;
begin
  GetSize := Memory.Size;
end;

procedure TNFIVarRec.SetByte(AByte: Byte);
begin
  Memory.WriteBuffer(AByte, 1);
end;

function TNFIVarRec.GetByte: Byte;
var AResult: Byte;
begin
  Memory.ReadBuffer(AResult, 1);
  GetByte := AResult;
end;

procedure TNFIVarRec.SetShortInt(AShortInt: ShortInt);
begin
  SetByte(AShortInt);
end;

function TNFIVarRec.GetShortInt: ShortInt;
begin
  GetShortInt := GetByte;
end;

procedure TNFIVarRec.SetWord(AWord: Word);
begin
  Memory.WriteBuffer(AWord, 2);
end;

procedure TNFIVarRec.SetInteger(AInteger: Integer);
begin
  SetWord(AInteger);
end;

function TNFIVarRec.GetInteger: Integer;
var AResult: Integer;
begin
  Memory.ReadBuffer(AResult, 2);
  GetInteger := AResult;
end;

function TNFIVarRec.GetWord: Word;
begin
  GetWord := GetInteger;
end;

procedure TNFIVarRec.SetLongInt(ALongInt: LongInt);
begin
  Memory.WriteBuffer(ALongInt, 4);
end;

function TNFIVarRec.GetLongInt: LongInt;
var AResult: LongInt;
begin
  Memory.ReadBuffer(AResult, 4);
  GetLongInt := AResult;
end;

procedure TNFIVarRec.SetString(AString: String);
var P: Pointer;
begin
  GetMem(P, Length(AString) + 1);
  StrPCopy(P, AString);
  Memory.WriteBuffer(P^, Length(AString) + 1);
  FreeMem(P);
end;


function TNFIVarRec.GetString: String;
var S: String;
    C: Char;
begin
  S := '';
  Repeat
    Memory.ReadBuffer(C, 1);
    If C <> #0 Then S := S + C;
  Until C = #0;
  GetString := S;
end;

procedure TNFIVarRec.SetTimeStamp(ATime: TDateTime);
begin
  Memory.WriteBuffer(ATime, SizeOf(TDateTime));
end;

function TNFIVarRec.GetTimeStamp: TDateTime;
var AResult: TDateTime;
begin
  Memory.ReadBuffer(AResult, SizeOf(TDateTime));
  GetTimeStamp := AResult;
end;

function TNFIVarRec.AppendPChar(Source: PChar): Boolean;
begin
  try
    Memory.WriteBuffer(Source^, StrLen(Source) + 1);  { Include the terminating #0 }
    AppendPChar := True;
  except
    AppendPChar := False;
  end;
end;

procedure TNFIVarRec.ReadPChar(Buffer: PChar);
begin
  try
    StrCopy(Buffer, Pointer(LongInt(Memory.Memory) + Memory.Position));
  except
    Buffer := nil;
  end;
end;



      {=======================================================================}
      {  ** TLONGARRAY CODE                                                   }
      {=======================================================================}


constructor TLongArray.Create;
begin
  Reset;
end;

destructor TLongArray.Destroy;
begin
  If Assigned(Buffer) Then FreeMem(Buffer);
end;

procedure TLongArray.Reset;
begin
  If Assigned(Buffer) Then FreeMem(Buffer);
  BufferSize := 8192;
  Buffer     := AllocMem(BufferSize);
  DataSize   := 0;
end;

procedure TLongArray.Grow;  { Add 4 extra kb to the end of the buffer }
begin
  System.Inc(BufferSize, 4096);
  ReAllocMem(Buffer, BufferSize);
end;

procedure TLongArray.Truncate;
begin
  ReAllocMem(Buffer, DataSize);
  BufferSize := DataSize;
end;

procedure TLongArray.Add(ALongInt: LongInt);
var P: ^LongInt;
begin
  If DataSize = BufferSize Then Grow;
  P := Buffer;
  System.Inc(LongInt(P), DataSize);
  P^ := ALongInt;
  System.Inc(DataSize, 4);
end;

procedure TLongArray.Remove(AtPos: LongInt);
var P, Q: Pointer;
    CopyAmount: LongInt;
begin
  If (DataSize > 0) and (AtPos <= (DataSize div 4)) Then
  begin
    P := Buffer;
    System.Inc(LongInt(P), AtPos * 4);        // Point it past the record we are deleting
    Q := Buffer;
    System.Inc(Longint(Q), (AtPos - 1) * 4);  // Point it to the one we are deleting
    CopyAmount := DataSize - (AtPos * 4);
    If CopyAmount > 0 Then
      System.Move(P^, Q^, CopyAmount);
    System.Dec(DataSize, 4);
    If DataSize > 8192 Then Truncate;
  end;
end;

procedure TLongArray.Insert(AtPos: LongInt; ALongInt: LongInt);
var P, TempBuffer: Pointer;
    Q: ^LongInt;
    CopyAmount: LongInt;
begin
  If (AtPos > 0) and ((AtPos - 1 ) * 4 <= DataSize) Then
  begin
    If BufferSize = DataSize Then Grow;
    P := Buffer;
    System.Inc(LongInt(P), (AtPos - 1) * 4);
    Q := P;
    CopyAmount := DataSize - ((AtPos - 1) * 4);
    If CopyAmount > 0 Then
    begin
      GetMem(TempBuffer, CopyAmount);
      System.Move(P^, TempBuffer^, CopyAmount);
      System.Inc(LongInt(P), 4);
      System.Move(TempBuffer^, P^, CopyAmount);
      FreeMem(TempBuffer);
    end;
    Q^ := ALongInt;
    System.Inc(DataSize, 4);
  end;
end;

function TLongArray.GetAtPos(Index: Integer): LongInt;
var P: ^LongInt;
begin
  GetAtPos := 0;
  If (Index > 0) and ((Index - 1) * 4 <= DataSize) Then
  begin
    P := Buffer;
    System.Inc(LongInt(P), (Index - 1) * 4);
    GetAtPos := P^;
  end;
end;

function TLongArray.GetCount: LongInt;
begin
  If DataSize = 0 Then GetCount := 0
  Else GetCount := DataSize div 4;
end;

procedure TLongArray.Replace(AtPos: LongInt; ALongInt: LongInt);
var P: ^LongInt;
begin
  If (AtPos > 0) and ((AtPos - 1) * 4 <= DataSize) Then
  begin
    P := Buffer;
    System.Inc(LongInt(P), (AtPos - 1) * 4);
    P^ := ALongInt;
  end;
end;

// Used for setting the "write" property of "At"
procedure TLongArray.ReplacePos(Index: Integer; AValue: LongInt);
begin
  Replace(Index, AValue);
end;

procedure TLongArray.Inc(AtPos, ANum: LongInt);
var i: LongInt;
begin
  i := At[AtPos] + ANum;
  Replace(AtPos, i);
end;

procedure TLongArray.Dec(AtPos, ANum: LongInt);
var i: LongInt;
begin
  i := At[AtPos] - ANum;
  Replace(AtPos, i);
end;


end.

