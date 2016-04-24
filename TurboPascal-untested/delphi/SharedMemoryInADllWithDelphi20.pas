(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0432.PAS
  Description: Shared memory in a DLL with Delphi 2.0
  Author: JOHN CRANE
  Date: 01-02-98  07:34
*)


From: johnnysc@ix.netcom.com (John Crane)

Sharing Memory Mapped Files... Check out the following code:


--------------------------------------------------------------------------------

var
  HMapping: THandle;
  PMapData: Pointer;

const
  MAPFILESIZE = 1000;

procedure OpenMap;
var
  llInit: Boolean;
  lInt: Integer;
begin
  HMapping := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, MAPFILESIZE, pchar('MY MAP NAME GOES HERE'));
  // Check if already exists
  llInit := (GetLastError() <> ERROR_ALREADY_EXISTS);
  if (hMapping = 0) then begin
    ShowMessage('Can''t Create Memory Map');
    Application.Terminate;
    exit;
  end;
  PMapData := MapViewOfFile(HMapping, FILE_MAP_ALL_ACCESS, 0, 0, 0);
  if PMapData = nil then begin
    CloseHandle(HMapping);
    ShowMessage('Can''t View Memory Map');
    Application.Terminate;
    exit;
  end;
  if (llInit) then begin
    // Init block to #0 if newly created
    memset(PMapData, #0, MAPFILESIZE);
  end;
end;

procedure CloseMap;
begin
  if PMapData <> nil then begin
    UnMapViewOfFile(PMapData);
  end;
  if HMapping <> 0 then begin
    CloseHandle(HMapping);
  end;
end;

--------------------------------------------------------------------------------

Any two or more applications or DLLs may obtain pointers to the same physical block of memory this way. PMapData will point to a 1000 byte buffer in this example, this buffer being initialized to #0's the first time in. One potential problem is synchronizing access to the memory. You may accomplish this through the use of mutexes. Here's an example of that:


--------------------------------------------------------------------------------

{ Call LockMap before writing (and reading?) to the memory mapped file.  Be sure to call UnlockMap immediately when done updating. }

var
  HMapMutex: THandle;

const
  REQUEST_TIMEOUT = 1000;

function LockMap:Boolean;
begin
  Result := true;
  HMapMutex := CreateMutex(nil, false, pchar('MY MUTEX NAME GOES HERE'));
  if HMixMutex = 0 then begin
    ShowMessage('Can''t create map mutex');
    Result := false;
  end else begin
    if WaitForSingleObject(HMapMutex,REQUEST_TIMEOUT) = WAIT_FAILED then begin
      // timeout
      ShowMessage('Can''t lock memory mapped file');
      Result := false;
    end;
  end;
end;

procedure UnlockMap;
begin
  ReleaseMutex(HMixMutex);
  CloseHandle(HMixMutex);
end;

--------------------------------------------------------------------------------

Please excuse my unnecessary begin..end's. I come from a Clipper background, and I prefer to see my logic blocks capped off with end's - easier to follow.

