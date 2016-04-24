(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0003.PAS
  Description: ENCRYPT.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:40
*)

{$A+,B-,D-,E+,F-,G+,I+,L-,N-,O-,R-,S-,V-,X+}
{$M 4048,0,131040}
Program encrypt;

{ Author Trevor J Carlsen - released into the public domain 1992         }
{        PO Box 568                                                      }
{        Port Hedland                                                    }
{        Western Australia 6721                                          }
{        Voice +61 91 73 2026  Data +61 91 73  2569                      }
{        FidoNet 3:690/644                                               }

{ Syntax: encrypt /p=PassWord /k=KeyFile /f=File                         }
{ Example -                                                              }
{         encrypt /p=billbloggs /k=c:\command.com /f=p:\prog\anyFile.pas }

{         PassWord can be any alpha-numeric sequence of AT LEAST four    }
{         Characters.                                                    }

{         KeyFile is the full path of any File on the system that this   }
{         Program runs on.  This File, preferably a large one, must not  }
{         be subject to changes.  This is critical as it is used as a    }
{         pseudo "one time pad" style key and the slightest change will  }
{         render decryption invalid.                                     }

{         File is the full path of the File to be encrypted or decrypted.}

{ notes:  Running Encrypt a second time With exactly the same parameters }
{         decrypts an encrypted File.  For total security the keyFile    }
{         can be stored separately on a floppy.  Without this keyFile or }
{         knowledge of its contents it is IMPOSSIBLE to decrypt the      }
{         encrypted File.                                                }

{         Parameters are Case insensitive and may be in any order and    }
{         may not contain any Dos separator Characters.                  }

Const
  BufferSize   = 65520;
  Renamed      : Boolean = False;

Type
  buffer_      = Array[0..BufferSize - 1] of Byte;
  buffptr      = ^buffer_;
  str80        = String[80];

Var
  OldExitProc  : Pointer;
  KeyFile,
  OldFile,
  NewFile      : File;
  KeyBuffer,
  Buffer       : buffptr;
  KeyFileSize,
  EncFileSize  : LongInt;
  PassWord,
  KFName,
  FFName       : str80;

Procedure Hash(p : Pointer; numb : Byte; Var result: LongInt);
  { When originally called numb must be equal to sizeof    }
  { whatever p is pointing at.  if that is a String numb   }
  { should be equal to length(the_String) and p should be  }        
  { ptr(seg(the_String),ofs(the_String)+1)                 }
  Var
    temp,
    w    : LongInt;
    x    : Byte;

  begin
    temp := LongInt(p^);  RandSeed := temp;
    For x := 0 to (numb - 4) do begin
      w := random(maxint) * random(maxint) * random(maxint);
      temp := ((temp shr random(16)) shl random(16)) +
                w + MemL[seg(p^):ofs(p^)+x];
    end;
    result := result xor temp;
  end;  { Hash }

Procedure NewExitProc; Far;
  { Does the "housekeeping" necessary on Program termination }
  Var code : Integer;
  begin
    ExitProc := OldExitProc;  { Reset Exit Procedure Pointer to original }
    Case ExitCode of
    0: Writeln('Successfully encrypted or decrypted ',FFName);
    1: begin
         Writeln('This Program requires 3 parameters -');
         Writeln('  /pPassWord');
         Writeln('  /kKeyFile (full path and name)');
         Write  ('  /fFile (The full path and name of the File');
         Writeln(' to be processed)');
         Writeln;
         Write  ('These parameters can be in any order, are Case,');
         Writeln(' insensitive, and may not contain any spaces.');
       end;
    2: Writeln('Could not find key File');
    3: Writeln('Could not rename and/or open original File');
    4: Writeln('Could not create encrypted File');
    5: Writeln('I/O error during processing - could not Complete');
    6: Writeln('Insufficient memory available');
    7: begin
         Writeln('Key  File is too small - aborted');
         Writeln;
         Writeln(' Key File must be at least as large as the buffer size ');
         Write  (' or the size of the File to be encrypted, whatever is the');
         Writeln(' smaller.');
       end;
    8: Writeln('PassWord must consist of at least 4 Characters');
    else { any other error }
      Writeln('Aborted With error ',ExitCode);
    end; { Case }
    if Renamed and (ExitCode <> 0) then
      Writeln(#7'WARNinG: original File''s name is now TEMP.$$$');
    {$I-}
    close(KeyFile); Code := Ioresult;
    close(NewFile); Code := Ioresult;
    close(OldFile); Code := Ioresult;
    if ExitCode = 0 then
      Erase(OldFile); Code := Ioresult;
    {$I+}
  end; { NewExitProc }


Function Str2UpCase(Var S: String): String;
  { Converts a String S to upper Case.  Valid For English. }
  Var
    x : Byte;
  begin
    Str2UpCase[0] := S[0];
    For x := 1 to length(S) do
      Str2UpCase[x] := UpCase(S[x]);
  end; { Str2UpCase }

Procedure Initialise;
  Var
    CommandLine : String;
    FPos,FLen,
    KPos,KLen,
    PPos,PLen   : Byte;

  Procedure  AllocateMemory(Var p: buffptr; size: LongInt);
    begin
      if size < BufferSize then begin
        if MaxAvail < size then halt(6);
        GetMem(p,size);
      end
      else begin
        if MaxAvail < BufferSize then halt(6);
        new(p);
      end;
    end; { AllocateMemory }

  begin
    FillChar(OldExitProc,404,0);       { Initialise all global Variables }
    FillChar(PassWord,243,32);
    ExitProc    := @NewExitProc;             { Set up new Exit Procedure }
    if ParamCount <> 3 then halt(1);
    CommandLine := String(ptr(PrefixSeg,$80)^)+' '; { Add trailing space }
    CommandLine := Str2UpCase(CommandLine);      { Convert to upper Case }
    PPos        := pos('/P=',CommandLine);     { Find passWord parameter }
    KPos        := pos('/K=',CommandLine);      { Find keyFile parameter }
    FPos        := pos('/F=',CommandLine); { Find Filename For encryption}
    if (PPos = 0) or (KPos = 0) or (FPos = 0) then Halt(1);
    FFName      := copy(CommandLine,FPos+3,80);
    FFName[0]   := chr(pos(' ',FFName)-1);       { Correct String length }
    KFName      := copy(CommandLine,KPos+3,80);
    KFName[0]   := chr(pos(' ',KFName)-1);
    PassWord    := copy(CommandLine,PPos+3,80);
    PassWord[0] := chr(pos(' ',PassWord)-1);
    if length(PassWord) < 4 then halt(8);
    { Create a random seed value based on the passWord }
    Hash(ptr(seg(PassWord),ofs(PassWord)+1),length(PassWord),RandSeed);
    assign(OldFile,FFName);
    {$I-}
    rename(OldFile,'TEMP.$$$');
    if Ioresult <> 0 then
      halt(3)
    else
      renamed := True;
    assign(OldFile,'TEMP.$$$');
    reset(OldFile,1);
    if Ioresult <> 0 then halt(3);
    assign(NewFile,FFName);
    reWrite(NewFile,1);
    if Ioresult <> 0 then halt(4);
    assign(KeyFile,KFName);
    reset(KeyFile,1);
    if Ioresult <> 0 then halt(2);
    EncFileSize := FileSize(OldFile);
    KeyFileSize := FileSize(KeyFile);
    if KeyFileSize > EncFileSize then
      KeyFileSize := EncFileSize;
    if Ioresult <> 0 then halt(5);
    {$I+}
    if (KeyFileSize < BufferSize) and (KeyFileSize < EncFileSize) then
      halt(7);
    AllocateMemory(buffer,EncFileSize);
    AllocateMemory(KeyBuffer,KeyFileSize);
  end; { Initialise }

Procedure Main;
  Var
    BytesRead : Word;
    finished  : Boolean;

  Procedure CodeBuffer(number: Word);
    { This is the actual encryption/decryption engine }
    Var x : Word;
    begin
      For x := 0 to number - 1 do
        buffer^[x] := buffer^[x] xor KeyBuffer^[x] xor Random(256);
    end; { CodeBuffer }

  begin
    {$I-}
    finished := False;
    Repeat
      BlockRead(OldFile,buffer^,BufferSize,BytesRead);
      if Ioresult <> 0 then halt(5);
      if (FilePos(KeyFile) + BytesRead) > KeyFileSize then
        seek(KeyFile,0);
      BlockRead(KeyFile,KeyBuffer^,BytesRead,BytesRead);
      if Ioresult <> 0 then halt(5);
      CodeBuffer(BytesRead);
      finished := BytesRead < BufferSize;
      BlockWrite(NewFile,buffer^,BytesRead);
    Until finished;
  end;  { Main }

begin
  Initialise;
  Main;
end.

