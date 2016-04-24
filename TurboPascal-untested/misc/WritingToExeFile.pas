(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0036.PAS
  Description: Writing To EXE File
  Author: DAVID DOTY
  Date: 08-27-93  22:12
*)

{
> How are you saaving the CFG into the .EXE?? Mind posting some code that wil
> save the CFG to the EXE?(When you get all your bugs fixed!)

I use these routines in my self-modifying .EXE's. They work pretty good.
}

Unit WritExec;

  { ==================================================================

                               Unit: WritExec
                             Author: David Doty
                                     Skipjack Software
                                     Columbia, Maryland
               CompuServe User I.D.: 76244,1043

    This Unit is based on a previously published Program:

                            Program: AutoInst v2.0
                             Author: David Dubois
                                     Zelkop Software
                                     Halifax, Nova Scotia
               CompuServe User I.D.: 71401,747
                  Date last revised: 1988.04.24

    ==================================================================

    This source code is released to the public domain.  if further changes
    are made, please include the above credits in the distributed code.

    This Unit allows a Program to change the value of a Typed Constant in its
    own .EXE File.  When the Program is run again, the data will be initialized
    to the new value.  No external configuration Files are necessary.

    Uses

    Examples of the usefulness of this technique would be:

    o   A Program that allows the user to change default display colors.

    o   A Program that keeps track of a passWord that the user can change.

    HOW IT WORKS

    You don't have to understand all the details in order to use this
    technique, but here they are.

    The data to be changed must be stored in a TurboPascal Typed
    Constant.  In all effect, a Typed Constant is actually a pre-
    initialized Variable.  It is always stored in the Program's Data
    Segment.  The data can be of any Type.

    First, the Procedure finds the .EXE File by examining the Dos command
    line, stored With the copy of the Dos environment For the Program.  This
    allows the Program to find itself no matter where is resides on disk and
    no matter how its name is changed by the user.

    The unTyped File is opened With a Record size of 1. This allows us
    to read or Write a String of Bytes using BlockRead and BlockWrite.

    As documented in the Dos Technical Reference, the size of the .EXE
    header, in paraGraphs (a paraGraph is 16 Bytes), is stored as a
    two-Byte Word at position 8 of the File.  This is read into the
    Variable HeaderSize.

    The next step is to find the position of the Typed Constant in the
    .EXE File. This requires an understanding of the Turbo Pascal 4.0
    memory map, documented on the first and second pages of the Inside
    Turbo Pascal chapter. (That's chapter 26, pages 335 and 336 in my
    manual.)

    First, find the address in memory where the Typed Constant is
    stored. This can be done in Turbo Pascal by using the Seg and Ofs
    Functions. Next find the segment of the PSP (Program segment
    prefix). This should always be the value returned by PrefixSeg.
    That will mark the beginning of the Program in memory. The
    position of the Typed Constant in the .EXE image should be the
    number of Bytes between these two places in memory. But ...

    But, two corrections must be made. First, the PSP is not stored in
    the .EXE File. As mentioned on page 335, the PSP is always 256
    Bytes. We must subtract that out. Secondly, there is the .EXE File
    header. The size of this has already been read in and must be
    added in to our calculations.

    Once the position has been determined, the data stored in the
    Typed Constant is written in one fell swoop using a BlockWrite.
    This replaces the original data, so that the next time the Program
    is run, the new values will used.

    LIMITATIONS

    You cannot use MicroSoft's EXEPACK on the .EXE File, or any other
    packing method I know of. This may change the position, or even
    the size of the Typed Constant in the File image.

    NOTES

    Since Typed Constants are always stored in the data segment, the
    Function call to Seg( ObjectToWrite ) can be replaced With DSeg. I
    prefer using Seg since it is more descriptive.

    One might think that Cseg can used as an alternative to using
    PrefixSeg and subtracting 256. This will work only if the code
    resides in the main Program. If, on the other hand, the code is
    used in a Unit, PrefixSeg must be used as described here. You
    might as well use PrefixSeg and save yourself some headaches.

    if you have any comments or questions we would be glad to hear
    them. if you're on CompuServe, you can EasyPlex a letter to
    76244,1043 or 71401,747. Or leave a message on the Borland Programmer's A
    Forum (GO BPROGA). Or, you can Write to

                         Skipjack Software
                         P. O. Box 61
                         Simpsonville Maryland 21150

                            or

                         Zelkop Software
                         P.O. Box 5177
                         Armdale, N.S.
                         Canada
                         B3L 4M7

    ==================================================================}


Interface

Function GetExecutableName : String;
{  This Function returns the full drive, path, and File name of the application
   Program that is running.  This Function is of more general interest than
   just For writing into the EXE File.

   NOTE: THIS Function WILL ONLY WORK UNDER Dos 3.X + !!! }

Function WriteToExecutable(Var ObjectToWrite; ObjectSize : Word) : Integer;
{  This Procedure modifies the EXE File on disk to contain changes to Typed
   Constants.  NOTE - the Object MUST be a Typed Constant.  It may be found
   in any part of the Program (i.e., main Program or any Unit).  The call is
   made by unTyped address, to allow any kind of Object to be written.  The
   Function returns the Dos error code from the I/O operation that failed
   (if any did); if all operations were successful, the Function returns 0. }

Implementation

Function GetExecutableName : String;
Type
  Environment = Array[0..32766] of Char;
Const
  NullChar : Char = #0;
  SearchFailed = $FFFF;
Var
  MyEnviron   : ^Environment;
  Loop        : Word;
  TempWord    : Word;
  EnvironPos  : Word;
  FilenamePos : Word;
  TempString  : String;
begin { Function GetExecutableName }
  { Get Pointer to Dos environment }
  MyEnviron := Ptr(MemW[PrefixSeg : $2C], 0);

  { Look For end of environment }
  EnvironPos := SearchFailed;
  Loop := 0;

  While Loop <= 32767 DO
  begin
    if MyEnviron^[ Loop ] = NullChar then
      if MyEnviron^[ Loop + 1 ] = NullChar then
      begin { found two nulls - this is end of environment }
        EnvironPos := Loop;
        Loop := 32767
      end; { found two nulls }
    Inc(Loop);
  end; { While Loop }

  if EnvironPos = SearchFailed then
    GetExecutableName := ''
  else
  begin { found end of environment - now look For path/File of exec }
    EnvironPos  := EnvironPos + 4;
    FilenamePos := SearchFailed;
    TempWord    := EnvironPos;
    Loop := 0;

    While Loop <= 127 DO
    begin
      if MyEnviron^[TempWord] = NullChar then
      begin { found a null - this is end of path/File of exec }
        FilenamePos := Loop;
        Loop := 127
      end; { found a null }
      Inc(Loop);
      Inc(TempWord);
    end; { While Loop }

    if FilenamePos = SearchFailed then
      GetExecutableName := ''
    else
    begin { found executable name - move into return String }
      TempString[0] := Chr(FilenamePos);
      Move(MyEnviron^[EnvironPos], TempString[1], FilenamePos);
      GetExecutableName := TempString;
    end; { found executable name }
  end; { found environment end }
end; { Function GetExecutableName }


Function WriteToExecutable(Var ObjectToWrite; ObjectSize : Word ) : Integer;
Const
  PrefixSize = 256; { number of Bytes in the Program Segment Prefix }
Var
  Executable : File;
  HeaderSize : Word;
  ErrorCode  : Integer;
begin
  Assign(Executable, GetExecutableName);
  {$I-}
  Reset(Executable, 1);
  ErrorCode := IOResult;

  if ErrorCode = 0 then
  begin { seek position of header size in EXE File }
    Seek(Executable, 8);
    ErrorCode := IOResult;
  end; { seek header }

  if ErrorCode = 0 then
  begin { read header size in EXE File }
    BlockRead(Executable, HeaderSize, SizeOf(HeaderSize));
    ErrorCode := IOResult;
  end; { read header }

  if ErrorCode = 0 then
  begin { seek position of Object in EXE File }
    Seek(Executable,
         LongInt(16) * (HeaderSize + Seg(ObjectToWrite) - PrefixSeg) +
         Ofs(ObjectToWrite) - PrefixSize);
    ErrorCode := IOResult;
  end; { Seek Object position in File }

  if ErrorCode = 0 then
  begin { Write new passWord in EXE File }
    BlockWrite(Executable, ObjectToWrite, ObjectSize);
    ErrorCode := IOResult;
  end; { Write new passWord }

  Close(Executable);
  WriteToExecutable := ErrorCode;

end; { Function WriteToExecutable }

end. { Unit WritExec }

