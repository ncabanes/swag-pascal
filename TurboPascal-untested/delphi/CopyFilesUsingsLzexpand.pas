(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0032.PAS
  Description: Copy files usings LZExpand
  Author: STEPHEN SILBER
  Date: 11-22-95  15:49
*)


For an installation program, I needed to be able to copy files into certain
directories.  After having come up with a file-copy solution much like Mr.
Stidolph's, I found myself needing a way to copy a file of any size, without
having to blow the stack on a large file buffer.

To this end, I explored the LZExpand unit and developed the function shown
below.  Note that this function expects to find the source file as a
standard DOS LZ-compressed file.  (These are the files you find on DOS and
Windows installation disks that look like "SETUP.EX_".)  You need to use the
DOS utility COMPRESS to first convert the source file to a COMPRESSed file.
Unfortunately, Delphi does not come with COMPRESS!  (Why not, Borland?)
You'll need to grab it from another compiler package (like BP or BC++.)

{ CopyFile returns True on a successful copy, False on failure. }
function CopyFile( src, dest: String): Boolean;
   var
      s, d: TOFStruct;
      fs, fd: Integer;
      fnSrc, fnDest: PChar;
   begin
      src:=src + #0;
      dest:=dest + #0;
      fnSrc:=@src[1];   { Trick the Strings into being ASCIIZ }
      fnDest:=@dest[1];

      fs := LZOpenFile( fnSrc, s, OF_READ );    { Get file handles }
      fd := LZOpenFile( fnDest, d, OF_CREATE );

      if LZCopy( fs, fd ) < 0 then      { Here's the magic API call }
         Result:=False
      else
         Result:=True;

      LZClose( fs );    { Make sure to close 'em! }
      LZClose( fd );
   end;


-JSRS



