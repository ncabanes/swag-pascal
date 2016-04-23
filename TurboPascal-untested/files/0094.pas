
{This way uses a File stream.}
Procedure FileCopy( Const sourcefilename, targetfilename: String );
Var
  S, T: TFileStream;
Begin
  S := TFileStream.Create( sourcefilename, fmOpenRead );
  try
    T := TFileStream.Create( targetfilename, fmOpenWrite or fmCreate );
    try
      T.CopyFrom(S, S.Size ) ;
    finally
      T.Free;
    end;
  finally
    S.Free;
  end;
End;


{Here is one that uses a TMemoryStream:}
procedure FileCopy(const FromFile, ToFile: string);
begin
  with TMemoryStream.Create do
  try
    LoadFromFile(FromFile);

    SaveToFile(ToFile);
  finally
    Free;
  end;
end;


{This way uses memory blocks for read/write.}
procedure FileCopy(const FromFile, ToFile: string);
 var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  Buf: array[1..2048] of Char;
begin
  AssignFile(FromF, FromFile);
  Reset(FromF, 1);		{ Record size = 1 }
  AssignFile(ToF, ToFile);	{ Open output file }
  Rewrite(ToF, 1);		{ Record size = 1 }
  repeat
    BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
    BlockWrite(ToF, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);

  System.CloseFile(FromF);
  System.CloseFile(ToF);
end;

{This one uses LZCopy, which USES LZExpand.}
procedure CopyFile(FromFileName, ToFileName: string);
var
  FromFile, ToFile: File;
begin
  AssignFile(FromFile, FromFileName); { Assign FromFile to FromFileName }
  AssignFile(ToFile, ToFileName);     { Assign ToFile to ToFileName }
  Reset(FromFile);                    { Open file for input }
  try
    Rewrite(ToFile);                  { Create file for output }
    try
      { copy the file an if a negative value is returned raise an exception }

      if LZCopy(TFileRec(FromFile).Handle, TFileRec(ToFile).Handle) < 0 then
        raise Exception.Create('Error using LZCopy')
    finally
      CloseFile(ToFile);  { Close ToFile }
    end;
  finally
    CloseFile(FromFile);  { Close FromFile }
  end;
end;


This one is from Dr. Bob (Swart).  The point of this one is that it contains a callback function that gives you the ability to callback.  This can be used for progress bars and the like.  Groetjes, Dr. Bob!


 {$A+,B-,D-,F-,G+,I+,K+,L-,N+,P+,Q-,R-,S+,T+,V-,W-,X+,Y-}
 unit FileCopy;

 (*
   FILECOPY 1.5 (Public Domain)
   Borland Delphi 1.0
   Copr. (c) 1995-08-27 Robert E. Swart (100434.2072@compuserve.com)
                        P.O. box 799
                        5702 NP  Helmond
                        The Netherlands
   -----------------------------------------------------------------
   This unit implements a FastFileCopy procedure that is usable from
   Borland Pascal (real mode, DPMI or Windows) and Borland Delphi. A
   callback routine (or nil) can be given as extra argument.

   Example of usage:

   {$IFDEF WINDOWS}
    uses FileCopy, WinCrt;
   {$ELSE}
    uses FileCopy, Crt;

   {$ENDIF}

      procedure CallBack(Position, Size: LongInt); far;
      var i: Integer;
      begin
        { do you stuff here... }
        GotoXY(1,1);
        for i:=1 to (80 * Position) div Size do write('X')
      end {CallBack};

    begin
      FastFileCopy('C:\AUTOEXEC.BAT', 'C:\AUTOEXEC.BAK', nil);
      FastFileCopy('C:\CONFIG.SYS', 'C:\CONFIG.BAK', CallBack)
    end.
 *)
 interface

 Type
   TCallBack = procedure (Position, Size: LongInt); { export; }

   procedure FastFileCopy(Const InFileName, OutFileName: String;
                          CallBack: TCallBack);


 implementation
 {$IFDEF VER80}
 uses SysUtils;
 {$ELSE}
   {$IFDEF WINDOWS}
   uses WinDos;
   {$ELSE}
   uses Dos;
   {$ENDIF}
 {$ENDIF}

   procedure FastFileCopy(Const InFileName, OutFileName: String;
                          CallBack: TCallBack);
   Const BufSize = 8*4096; { 32Kbytes gives me the best results }
   Type
     PBuffer = ^TBuffer;
     TBuffer = Array[1..BufSize] of Byte;
   var Size: Word;
       Buffer: PBuffer;
       infile,outfile: File;
       SizeDone,SizeFile,TimeDateFile: LongInt;
   begin
     if (InFileName <> OutFileName) then
     begin
       Buffer := nil;
       Assign(infile,InFileName);

       System.Reset(infile,1);
       {$IFDEF VER80}
       try
       {$ELSE}
       begin
       {$ENDIF}
         SizeFile := FileSize(infile);
         Assign(outfile,OutFileName);
         System.Rewrite(outfile,1);
         {$IFDEF VER80}
         try
         {$ELSE}
         begin
         {$ENDIF}
           SizeDone := 0;
           New(Buffer);
           repeat
             BlockRead(infile,Buffer^,BufSize,Size);
             Inc(SizeDone,Size);
             if (@CallBack <> nil) then
               CallBack(SizeDone,SizeFile);

             BlockWrite(outfile,Buffer^,Size)
           until Size < BufSize;
           {$IFDEF VER80}
           FileSetDate(TFileRec(outfile).Handle,
             FileGetDate(TFileRec(infile).Handle));
           {$ELSE}
           GetFTime(infile, TimeDateFile);
           SetFTime(outfile, TimeDateFile);
           {$ENDIF}
         {$IFDEF VER80}
         finally
         {$ENDIF}
           if Buffer <> nil then Dispose(Buffer);
           System.close(outfile)
         end;
       {$IFDEF VER80}
       finally
       {$ENDIF}

         System.close(infile)
       end
     end
     {$IFDEF VER80}
     else
       Raise EInOutError.Create('File cannot be copied onto itself')
     {$ENDIF}
   end {FastFileCopy};
 end.


