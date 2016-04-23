//------------------------------------------------------------------------------
// ODFileUnit.Pas								Copyright (C) 1997 Object Dynamics Ltd.
//
// This unit implements classes supporting file I/O using Win32 I/O functions,
// and a "C-like" I/O style. It is intended to be somewhat easier to use than
// the built-in Pascal file I/O mechanisms.
//
//
// 								*** IMPORTANT ***
//
// By using this code, you accept the following conditions:
//
//  	You may use and adapt this code freely, but it remains the
// 	copyright of Object Dynamics Ltd. Any adaptations must retain the
// 	copyright message at the head of this file.
//
//		You use this code at your own risk. Object Dynamics is not responsible
//    for any loss or damage caused by programs using this code.
//
//
// History:
//
//		Version 1.0 Created by Neil Butterworth, September 1997
//    Fixed problems with file create modes, November 1997.
//
//------------------------------------------------------------------------------

unit ODFileUnit;

interface

uses
	Windows,
   Messages,
   SysUtils,
   Classes;

type

	// Windows file handle
	FileHandle = integer;

   // All classes raise this exception
	FileError = class( Exception );

   // Raw file modes
   FileOpenMode = ( 	foRead,					// open file read-only
   						foWrite,           	// open file write-only
                     foReadWrite        	// open for both
   					);

   FileShareMode = ( fsNoShare,           // file cannot be shared
   						fsShareRead, 			// file can be shared for reading
                     fsShareWrite, 			// file can be shared for writing
                     fsShared					// file can be shared for any access
   					);

   FileCreateOption = ( fcNew, 				// always creates a new file
   							fcExisting, 		// file must already exist
                        fcAlways          // file will be created if it doesn't
                        						// exist, else it will be opened
                       );

   FileSeekFrom = ( 	sfStart, 				// seek from start
   						sfEnd, 					// seek from end
                     sfHere 					// seek from current position
                   );


	// RawFile implements simple binary file with seeking & locking abilities. It
   // is used to implement the other file classes.

   RawFile = class( TObject )
		private
      	mFile : FileHandle;              // windows file handle
			mFileName : string;            	// full name of file
         mIsOpen : boolean;               // is it open?

         procedure Error( const msg : string );

   	public
      	constructor Create;
			destructor Destroy; override;

         // Open a file, possibly creating it. See above for the various modes.
         procedure Open( const fname : string;
         							omode : FileOpenMode;
                              smode : FileShareMode;
                              copts : FileCreateOption );

         // Read nbytes from file into buffer pointed to by buf. Returns actual
         // number of bytes read, which may be less than nbytes. If the number
         // of bytes read is zero, then the end of file has been reached.
   		function Read( buf : pointer;
         					  nbytes : integer ) : integer;

         // Write nbytes to file from buffer pointed to by buf.
         procedure Write( buf : pointer;
         						nbytes : integer );

         // Seek in a file
			function Seek( moveby : integer;  from : FileSeekFrom ) : integer;

			// Return current read/write position in file
         function  FilePosition : integer;

         // Perform region locking/unlocking
			function Lock( pos, len : integer ) : boolean;
         procedure Unlock( pos, len : integer );

         // Close the file.  It is always safe to call Close, even on an
         // already closed file.
         procedure Close;

         // Accessors for file name and open state
      	property FileName : string read mFileName;
         property IsOpen : boolean read mIsOpen;

	end;


   // Text file buffer. This class is used solely to implement the TextFile class.

	TFBuffer = class( TObject )

   	private
      	mBuffer : array[ 0..1023 ] of char;
         mPtr, mBytes : integer;

      public
      	constructor Create;
         function Fill( f : RawFile ) : boolean;
         function GetLine( f : RawFile; var line : string ) : boolean;
         procedure Reset;
			function GetChar( f : RawFile; var c : char ) : boolean;
   end;


   // Text file modes
   TextFileOpenMode = ( toRead, 				// open for reading
   							toReWrite, 			// open for overwrite existing contents
                        toAppend 			// open for append to existing contents
                       );

   TextFileShareMode = ( smShare,         // open shared (for read only)
                         smNoShare        // open single user
                        );

   // The TextFile class implements access to files consisting of lines
   // of text. Text files do not support seeking, and have limited open and
   // sharing modes (see above).

   TextFile = class( TObject )

   	private
      	mFile : RawFile;						// implemented via RawFile
         mBuffer : TFBuffer;       			// text file buffer

      public
      	constructor Create;
			destructor Destroy; override;

         // Open a text file
         procedure Open( const fname : string;
                        	omode : TextFileOpenMode;
                           smode : TextFileShareMode );

         // Close file. Always safe to call, even on already closed files.
         procedure Close;

         // accessors for RawFile properties
         function FileName : string;
         function IsOpen : boolean;

         // Write a line of text to file & terminate with CR/LF pair
         procedure WriteLine( const line : string );

         // Read a line from file, stripping CR/LF pair. Returns False if
         // at end of file.
         function ReadLine( var line : string ) : boolean;

   end;

 	// This class supports random access to fixed-sized records.

   RandomAccessFile = class( TObject )

   	private
      	mFile : RawFile; 						// RawFile implementation
      	mRecSize : integer;             	// record size

      public
      	constructor Create;
         destructor Destroy; override;

         // Open or create a RandomAccessFile. The RecSize parameter indicates
         // the size of the recoord in the file. This is not stored in the
         // file itself.
         procedure Open( const fname : string;
         							recsize : integer;
         							omode : FileOpenMode;
                              smode : FileShareMode;
                              copts : FileCreateOption );

 			// Usual stuff
         procedure Close;
         function FileName : string;
         function IsOpen : boolean;

         // write a record at record number recno, which must be greater or
         // equal to zero. A record number greater than that of the last
         // record will extend the file.
         procedure WriteRecord( rec : pointer; recno : integer );

         // Read a record. If the record does not exist, the function returns false.
         function ReadRecord( rec : pointer; recno : integer ) : boolean;

         // read the next record sequentially. The first call to this method must
         // be preceded with a call to ReadRecord.
         function ReadNextRecord( rec : pointer ) : boolean;

         // Record locking
         function LockRecord( recno : integer ) : boolean;
         procedure UnlockRecord( recno : integer );

         // Extend the file by count records. The new records will contain garbage.
         procedure Extend( count : integer );

         // Return the number of recordsin the file.
         function RecordCount : integer;
	end;

//------------------------------------------------------------------------------

implementation

type

	// These declarations are necessary as there seems to be a problem with
   // the Borland-supplied declarations in Windows.Pas, at least in Delphi 2.

	LPINTEGER = ^integer;

	function Win32WriteFile( f : integer; p : pointer;
   									nb : integer; nbr : LPINTEGER;
                              junk : pointer ) : BOOL; stdcall;
                              external kernel32 name 'WriteFile';

	function Win32ReadFile( f : integer; p : pointer;
   									nb : integer; nbr : LPINTEGER;
                              junk : pointer ) : BOOL; stdcall;
                              external kernel32 name 'ReadFile';

const

	// erroor messages
	FILE_OPEN_EMSG = 			'Could not open file';
   FILE_NOT_OPEN_EMSG = 	'File is not open';
	BAD_BUFFER_SIZE_EMSG = 	'Bad buffer size for Read/Write';
   READ_FAILED_EMSG = 		'Read failed';
   WRITE_FAILED_EMSG = 		'Write failed';
	SEEK_FAILED_EMSG = 		'Seek failed';
   BAD_TFSHARE_EMSG =		'Cannot open text file for write in shared mode';
   BAD_LOCK_VALUES_EMSG =	'Bad range values for lock/unlock';
	UNLOCK_FAILED_EMSG =		'Unlock failed!';
   BAD_REC_SIZE_EMSG =		'Record size must be greater than zero';
   BAD_REC_NUMBER_EMSG = 	'Bad record number';
   NIL_POINTER_EMSG	=		'Nil pointer';

//------------------------------------------------------------------------------
// Utility stuff
//------------------------------------------------------------------------------

// replace with assert in Delphi3
procedure CheckPointer( p : pointer );
begin
	if ( p = nil ) then
      raise FileError.Create( NIL_POINTER_EMSG );
end;

//------------------------------------------------------------------------------
// RawFile methods
//------------------------------------------------------------------------------

// Create new RawFile
constructor RawFile.Create;
begin
	mFile := 0;
   mIsOpen := false;
   mFileName := '';
end;

// Destroy RawFile, closing disk image first.
destructor RawFile.Destroy;
begin
	Close;
   inherited Destroy;
end;

// RawFile error messaging
procedure RawFile.Error( const msg : string );
begin
	raise Fileerror.CreateFmt( '%s: %s', [mFileNAme, msg ] );
end;

// Close RawFile
procedure RawFile.Close;
begin
	if ( mIsOpen ) then
		CloseHandle( mFile );
   mIsOpen := false;
end;


// Open RawFile. Most of this is mapping my modes onto Windows modes. Calling
// this on an already open file will Close & then re-open it.
procedure RawFile.Open( const fname : string;
         							omode : FileOpenMode;
                              smode : FileShareMode;
                              copts : FileCreateOption );
var
	oflags, sflags, cflags : integer;
begin
	Close;
   mFileName := fname;

   oflags := 0;
   sflags := 0;
   cflags := 0;

   if ( omode = foRead ) then
   	oflags := GENERIC_READ
   else if ( omode = foWrite ) then
		oflags := GENERIC_WRITE
   else
   	oflags := GENERIC_READ + GENERIC_WRITE;

   if ( smode = fsShareRead ) then
   	sflags := FILE_SHARE_READ
   else if ( smode = fsShareWrite ) then
   	sflags := FILE_SHARE_WRITE
   else if ( smode = fsShared ) then
   	sflags := FILE_SHARE_WRITE + FILE_SHARE_READ;

   if ( copts = fcNew ) then
   	cflags := CREATE_ALWAYS
   else if ( copts = fcExisting ) then
    	cflags := OPEN_EXISTING
   else if ( copts = fcAlways ) then
    	cflags := OPEN_ALWAYS;

      mFile := Windows.CreateFile( PChar( fname ), oflags, sflags, nil, cflags,
                                 FILE_ATTRIBUTE_NORMAL, 0 );

 	if ( mFile = INVALID_HANDLE_VALUE ) then begin
   	mIsOpen := false;
      Error( FILE_OPEN_EMSG );
   end;

   mIsOpen := true;
end;

// Read bytes from file
function RawFile.Read( buf : pointer; nbytes : integer ) : integer;
var
	bread : integer;
begin

	CheckPointer( buf );

	if ( not IsOpen ) then  					// must be open
   	Error( FILE_NOT_OPEN_EMSG );

   if ( nbytes <= 0 ) then             	// byte number must be sensible
   	Error( BAD_BUFFER_SIZE_EMSG );

   if ( 	Win32ReadFile( mFile, buf, nbytes, @bread, nil ) ) then
   	result := bread
   else
   	result := 0;
end;

// Write bytes to file
procedure RawFile.Write( buf : pointer;
         						nbytes : integer );
var
	bwrite : integer;
begin

	CheckPointer( buf );

	if ( not IsOpen ) then
   	Error( FILE_NOT_OPEN_EMSG );

   if ( nbytes <= 0 ) then
   	Error( BAD_BUFFER_SIZE_EMSG );

	if ( not Win32WriteFile( mFile, buf, nbytes, @bwrite, nil ) ) then
   	Error( WRITE_FAILED_EMSG );
end;

// Get current position. This involves seeking to end of file & then back
// again and could therefore be slow.
function  RawFile.FilePosition : integer;
var
	pos : integer;
begin
	if ( not IsOpen ) then
   	Error( FILE_NOT_OPEN_EMSG );
   pos := SetFilePointer( mFile, 0, nil, FILE_CURRENT );
   if ( pos = -1 ) then
   	Error( SEEK_FAILED_EMSG );
   result := pos;
end;

// Seek in file, returning new position. Raises exception if seek fails.
function RawFile.Seek( moveby : integer;  from : FileSeekFrom ) : integer;
var
	mflags : integer;
begin
	if ( not IsOpen ) then
   	Error( FILE_NOT_OPEN_EMSG );

	if ( from = sfStart ) then
   	mflags := FILE_BEGIN
   else 	if ( from = sfEnd ) then
   	mflags := FILE_END
	else
   	mflags := FILE_CURRENT;

   result := SetFilePointer( mFile, moveby, nil, mflags );
   if ( result = -1 ) then
   	Error( SEEK_FAILED_EMSG );
end;

// Lock a range of bytes
function RawFile.Lock( pos, len : integer ) : boolean;
begin
	if ( not IsOpen ) then
   	Error( FILE_NOT_OPEN_EMSG );

	if ( (pos < 0) or (len <= 0 ) ) then
   	Error( BAD_LOCK_VALUES_EMSG );

   result := LockFile( mFile, pos, 0, len, 0 );
end;

// Unlock a range of bytesa
procedure RawFile.UnLock( pos, len : integer );
begin
	if ( not IsOpen ) then
   	Error( FILE_NOT_OPEN_EMSG );

	if ( (pos < 0) or (len <= 0 ) ) then
   	Error( BAD_LOCK_VALUES_EMSG );

   if ( not UnLockFile( mFile, pos, 0, len, 0 ) ) then
   	Error( UNLOCK_FAILED_EMSG );

end;

//------------------------------------------------------------------------------
// TFBuffer methods.
//------------------------------------------------------------------------------

constructor TFBuffer.Create;
begin
 	Reset;
end;

// Fill a buffer by reading raw bytes
function TFBuffer.Fill( f : RawFile ) : boolean;
begin
 	mBytes := f.Read( @mBuffer, sizeof( mBuffer )) ;
   mPtr := 0;
   result := mBytes <> 0;
end;

// Get single character from the buffer, which will refill itself as
// necessary. Returns false on EOF.
function TFBuffer.GetChar( f : RawFile; var c : char ) : boolean;
var
	t : char;
begin
	result := false;

	if ( (mPtr >= mBytes) and (not Fill( f ) ) ) then  		// eof
		exit;

   t := mBuffer[mPtr];
   inc( mPtr );
   result := true;
   if ( t = #13 ) then begin
      GetChar( f, t );
      c := #0;
   end
   else
   	c := t;
end;

// Read line from buffer, stripping CR/LF. The buffer re-fills as necessary.
function TFBuffer.GetLine( f : RawFile; var line : string ) : boolean;
var
	c : char;
begin
	line := '';
   while( GetChar( f, c ) ) do begin
   	if ( c = #0 ) then begin
      	result := true;
      	exit;
      end;
      line := line + c;
   end;

   result := Line <> '';
end;

// empty the buffer
procedure TFBuffer.Reset;
begin
 	mPtr := 0;
   mBytes := 0;
end;

//------------------------------------------------------------------------------
// TextFile methods. Most work is done by the RawFile and TFBuffer classes.
//------------------------------------------------------------------------------

// Constructor creates the rawfile & buffer object
constructor TextFile.Create;
begin
	mFile := RawFile.Create;
   mBuffer := TFBuffer.Create;
end;


// destroy rawfile & buffer
destructor TextFile.Destroy;
begin
	mBuffer.Free;
   mFile.Free;
   inherited destroy;
end;


// Once again, open is mostly about mapping modes
procedure TextFile.Open( const fname : string;
								omode : TextFileOpenMode;
                        smode : TextFileShareMode );
var
	romode : FileOpenMode;
   rsmode : FileShareMode;
   rcmode : FileCreateOption;
begin
	if ( omode = toRead ) then
   	romode := foRead
   else
   	romode := foWrite;

   if ( smode = smNoShare ) then
   	rsmode := fsNoShare
   else if ( romode = foRead ) then
   	rsmode := fsShareRead
   else
   	raise FileError.CreateFmt( '%s: %s', [fname, BAD_TFSHARE_EMSG] );

   if ( omode = toRead ) then
   	rcmode := fcExisting
   else if ( omode = toReWrite ) then
   	rcmode := fcNew
   else if ( omode = toAppend ) then
   	rcmode := fcExisting;

   mFile.Open( fname, romode, rsmode, rcmode );

   if ( omode = toAppend ) then
   	mFile.Seek( 0, sfEnd );
end;

// Close file
procedure TextFile.Close;
begin
	mFile.Close;
end;

// Get file name (may be empty)
function TextFile.FileName : string;
begin
	result := mFile.FileName;
end;

// Get open state
function TextFile.IsOpen : boolean;
begin
	result := mFile.IsOpen;
end;

// write line to text file, terminating with CR/LF pair
procedure TextFile.WriteLine( const line : string );
const
	crlf : array[0..2] of char = #13#10#0;
var
	p : pchar;
begin
	p := pchar( line );
   if ( length( line ) > 0 ) then
   	mFile.Write( p, length( line ) );
	mFile.Write( @crlf, 2 );
end;

// Read line, trimming CR/LF.
function TextFile.ReadLine( var line : string ) : boolean;
begin
	result := mBuffer.GetLine( mFile, line );
end;

//------------------------------------------------------------------------------
// RandomAccessFile methods.  RawFile class does most of the work.
//------------------------------------------------------------------------------

// constructor creates rawfile
constructor RandomAccessFile.Create;
begin
	mfile := RawFile.Create;
end;

destructor RandomAccessFile.Destroy;
begin
	mFile.Free;
   inherited Destroy;
end;

// Mode mapping not necessary, as we pass things thru to RawFile
procedure RandomAccessFile.Open( const fname : string;
         							recsize : integer;
         							omode : FileOpenMode;
                              smode : FileShareMode;
                              copts : FileCreateOption );
begin
	mFile.Open( fname, omode, smode, copts );
   if ( recsize <= 0 ) then begin
   	mFile.Close;
      mFile.Error( BAD_REC_SIZE_EMSG );
   end;
   mRecSize := recsize;
end;

// usual stuff
procedure RandomAccessFile.Close;
begin
	mFile.close;
end;

function RandomAccessFile.FileName : string;
begin
	result := mFile.FileName;
end;

function RandomAccessFile.IsOpen : boolean;
begin
	result := mFile.IsOpen;
end;

// write record. If record number  higher than current highest, the call
// to Seek will extend the file
procedure RandomAccessFile.WriteRecord( rec : pointer; recno : integer );
begin
	if ( recno < 0 ) then
   	mFile.Error( BAD_REC_NUMBER_EMSG );
	mFile.Seek( recno * mRecSize, sfStart );
   mFile.Write( rec, mRecSize );
end;

// read a record
function RandomAccessFile.ReadRecord( rec : pointer; recno : integer ) : boolean;
begin
	if ( recno < 0 ) then
   	mFile.Error( BAD_REC_NUMBER_EMSG );
	if ( RecordCount <= recno ) then
		result := false
   else begin
   	mFile.Seek( recno * mRecSize, sfStart );
   	result := mFile.Read( rec, mRecSize ) = mRecSize;
   end;
end;

// read next record. Should have made som positioning call (like REadRecord)
// before calling this
function RandomAccessFile.ReadNextRecord( rec : pointer ) : boolean;
begin
	mFile.Seek( 0, sfHere );
   result := mFile.Read( rec, mRecSize ) = mRecSize;
end;

// Record locking
function RandomAccessFile.LockRecord( recno : integer ) : boolean;
begin
	result := mFile.Lock( recno * mRecSize, mRecSize );
end;

// and unlocking
procedure RandomAccessFile.UnlockRecord( recno : integer );
begin
	mFile.Unlock( recno * mRecSize, mRecSize );
end;

// extend file by count records
procedure RandomAccessFile.Extend( count : integer );
var
	c : char;
begin
	if ( count > 0 ) then
		mFile.Seek( (count - 1 ) * mRecSize, sfEnd );

   // for the last record we write a byte at its very end
   if ( mRecSize > 1 ) then
   	mFile.Seek( mRecSize - 1, sfHere );
 	mFile.Write( @c, 1 );                // must write in order to extend
end;

// Return number of records. This causes several seeks, so may be slow
function RandomAccessFile.RecordCount : integer;
var
	now : integer;
begin
	now := mFile.FilePosition;
   result := mFile.Seek( 0, sfEnd ) div mRecSize;
   mFile.Seek( now, sfStart );
end;

//------------------------------------------------------------------------------

end.

