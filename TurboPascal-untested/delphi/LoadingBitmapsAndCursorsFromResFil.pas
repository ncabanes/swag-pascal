(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0115.PAS
  Description: Loading Bitmaps and Cursors from RES Fil
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)


         Loading Bitmaps and Cursors from RES files

Bitmaps and cursors can be stored in a resource (RES) files and
linked into your application's EXE file.  RES files can be created
with Delphi's Image Editor or Borland's Resource Workshop that comes
with the Delphi RAD Pack.  Bitmaps and cursors stored in RES files
(after being bound into an EXE or DLL) can be retrieved by using the
API functions LoadBitmap and LoadCursor, respectively.


Loading Bitmaps
---------------
The LoadBitmap API call is defined as follows:

function LoadBitmap(Instance: THandle;
                    BitmapName: PChar): HBitmap;

The first parameter is the instance handle of the module (EXE or DLL)
that contains the RES file you wish to get a resource from.  Delphi
provides the instance handle of the EXE running in the global variable
called Hinstance.  For this example it is assumed that the module that
you are trying to load the bitmap from is your application.  However,
the module could be another EXE or DLL file.  The following example
loads a bitmap called BITMAP_1 from a RES file linked into the
application's EXE:

procedure TForm1.Button1Click(Sender: TObject);
var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  Bmp.Handle := LoadBitmap(HInstance,'BITMAP_1');
  Canvas.Draw(0, 0, Bmp);
  Bmp.Free;
end;

There is one drawback to using the LoadBitmap API call though LoadBitmap
is a Windows 3.0 API call and loads in bitmaps only as DDBs (Device
Dependent Bitmaps).  This can cause color palette problems when retrieving
DIBs (Device Independent Bitmaps) from RES files.  The code listed below
can be used to retrieve DIBs from RES files.  This code loads the bitmap
as a generic resource, puts it into a stream, and then does a
LoadFromStream call which causes Delphi to realize the color palette
automatically.

procedure TForm1.Button1Click(Sender: TObject);
const
  BM = $4D42;  {Bitmap type identifier}
var
  Bmp: TBitmap;
  BMF: TBitmapFileHeader;
  HResInfo: THandle;
  MemHandle: THandle;
  Stream: TMemoryStream;
  ResPtr: PByte;
  ResSize: Longint;
begin
  BMF.bfType := BM; 
  {Find, Load, and Lock the Resource containing BITMAP_1}
  HResInfo := FindResource(HInstance, 'BITMAP_1', RT_Bitmap);
  MemHandle := LoadResource(HInstance, HResInfo);
  ResPtr := LockResource(MemHandle);

  {Create a Memory stream, set its size, write out the bitmap
   header, and finally write out the Bitmap                  }
  Stream := TMemoryStream.Create;
  ResSize := SizeofResource(HInstance, HResInfo);
  Stream.SetSize(ResSize + SizeOf(BMF));
  Stream.Write(BMF, SizeOf(BMF));
  Stream.Write(ResPtr^, ResSize);

  {Free the resource and reset the stream to offset 0}
  FreeResource(MemHandle);
  Stream.Seek(0, 0);
  {Create the TBitmap and load the image from the MemoryStream}
  Bmp := TBitmap.Create;
  Bmp.LoadFromStream(Stream);
  Canvas.Draw(0, 0, Bmp);
  Bmp.Free;
  Stream.Free;
end;


Loading Cursors
-------------
The LoadCursor API call is defined as follows:

function LoadCursor(Instance: THandle;
                    CursorName: PChar): HCursor;

The first parameter is the Instance variable of the module that
contains the RES file.  As above, this example assumes that the
module that you are trying to load the cursor from is your
application.  The second parameter is the name of the cursor.

Under the interface section declare:

const
  crMyCursor = 5; {Other units can use this constant}

Next, add the following two lines of code to the form's OnCreate
event as follows:

procedure TForm1.FormCreate(Sender: TObject);
begin
  Screen.Cursors[crMyCursor] := LoadCursor(HInstance, 'CURSOR_1');
  Cursor := crMyCursor;
end;

or you may want to change one of the standard Delphi cursors as
follows (the Cursor constants can be found in the On-line Help
under Cursors Property):


procedure TForm1.FormCreate(Sender: TObject);
begin
  {This example changes the SQL Hourglass cursor}
  Screen.Cursors[crSQLWait] := LoadCursor(HInstance, 'CURSOR_1');
end;

Note:  Normally it is necessary to delete any cursor resources with the
DeleteCursor, however, in Delphi this is not necessary because Delphi
will delete the all cursors in the Cursors array.

