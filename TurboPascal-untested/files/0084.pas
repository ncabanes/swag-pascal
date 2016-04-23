{
 GH> Here is what my Waite's group book says word for word, and I haven't
 GH> an idea on how to do this.
 GH> "23H   Filesize. Prior to invoking this function, DS:DX is set to
 GH> point to the segment: offset address of an unopened file control
 GH> block(FCB)."
 GH> Now there is my problem, I need to know how to do the DS:DX thing to
 GH> place a file name in it, so I can check that _certain_ file for its
 GH> size.
 GH> If anyone knows how to do this, could you lend a hand.

Refrain from using the old-style file access methods, i.e, those using
FCB's. Not only are they "frowned upon" by Microsoft, worse: they can
only work with files located in the current directory.
Use the file handle methods instead.
}

   PROGRAM The_Size_Of_Files;

   USES dos;

   { -- Both functions below wil return the size of a file. In case of an
     -- error, the return value is -1.
     -- Note that their parameters are of different types. }

   FUNCTION Size_of_file(CONST fn: PathStr): longint;
   VAR SR: SearchRec;
   BEGIN findfirst(fn, AnyFile - VolumeID - Directory, SR);
         IF DosError = 0
         THEN Size_of_file:=SR.Size
         ELSE Size_of_file:=-1
              { -- Or some other clearly nonsensical value. }
   END;

   FUNCTION AsmFilesize(CONST F): longint;
   { -- F MUST be a Text or File-variable. }
   ASSEMBLER;
   { --  LSEEK ── Move file read/write pointer (Func 42)

     -- INT 21 - DOS 2+
     --    AH = 42h
     --    AL = method
     --       00h offset from beginning of file
     --       01h offset from present location
     --       02h offset from end of file
     --   BX = file handle
     --   CX:DX = offset in bytes

     -- Return: CF set on error
     --       AX = error code (01h,06h) (see AH=59h)
     --         CF clear if successful
     --       DX:AX = new absolute offset from beginning of file }
   ASM mov ah, $42
       mov al, 2

       les di, F         { -- Now ES:DI holds the address of F. }
       mov bx, es:[di]   { -- BX now holds the filehandle of F; look up
                           -- types Dos.TextRec and Dos.FileRec for an
                           -- explanation. }

       xor cx, cx
       xor dx, dx        { -- CX and DX are now both zero. }

                         { -- In effect, the file pointer is to be moved
                           -- to the end of the file. }

       int $21
       jnc @@Exit        { -- Did we succeed ? }

       mov dx, $FFFF     { -- NO: so make the functionresult (a Longint is }
       mov ax, $FFFF     { --     returned in DX:AX) = -1.                 }

   @@Exit:               { -- YES: quit without further ado. }
   END;

   { -- Main: }

   VAR fn: PathStr;
       F : FILE;

   BEGIN write('PLease enter filename: '); readln(fn);
         assign(F, fn); {$I-} reset(F, 1); {$I+}
         IF IOresult <> 0
         THEN BEGIN writeln(#7'No such file ...'); halt(2) END;

         writeln('FileSize : ', FileSize(F));
         writeln('FindFirst: ', Size_of_file(fn));
         writeln('LSeek    : ', AsmFilesize(F))
   END.

Perhaps it would be interesting to see which method is fastest.

The ONLY situation in which you absolutely must use FCBs is setting the
volume label on a disk.
