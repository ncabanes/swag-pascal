(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0078.PAS
  Description: Complete File Handling
  Author: RICK HAINES
  Date: 09-04-95  10:49
*)

{
Here's a unit I wrote to handle files and directories.  It has procedures
similare to SetFAttr and GetFAttr, plus two others dealing with file
attributes.  It also has a procedure to return a linked list of all the
files in the current directory, three procedure to work with that (I may
write one to sort it later), and one to dispose of the linked list.

At the end of the unit will be a program called attribs that uses it.  It's
basically the same as DOS's attrib with some added features, such as:  It
now works on directories too (i.e. you can now hide directorys), you can
list only the files and directories with certain attributes set, you can
list only directorys, etc...

As always, comments, flames, criticism (constructive or otherwise), and
even "this sucks!" or "cool!" are welcome.

                                                -Rick
rick.haines@cde.com
}

{$A+,B-,D-,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y+}
{$M 16384,0,655360}
{ ********************************************************** }
{ *********************** Files Unit *********************** }
{ ********************************************************** }
{ **************** Written by: Rick Haines ***************** }
{ **************************** rick.haines@cde.com ********* }
{ ********************************************************** }
{ ***************** Last Revised 03/29/95 ****************** }
{ ********************************************************** }

Unit Files;

Interface

Const
 NormalF   = $0;          { Normal File   }
 ReadOnlyF = $1;          { ReadOnly File }
 HiddenF   = $2;          { Hidden File   }
 SystemF   = $4;          { System File   }
 VolLabel  = $8;          { Volume Label  }
 SubDir    = $10;         { Sub Directory }
 ArchiveF  = $20;         { Archive File  }
 AllFiles  = $3F;         { All Files     }
{Reserved  = $40;}
{Reserved  = $80;}
 fOK       = $0;          { No Error       }
 fFileNF   = $2;          { File Not Found }
 fPathNF   = $3;          { Path Not Found }
 fAccessD  = $5;          { Access Denied  }
 fgError   = $120;        { Other Error    }

Type
 FileListP = ^FileListT;
 FileListT = Record
   Name : String[12];
   Attr : Byte;
   Size : LongInt;
   Next : FileListP;
  End;

 Function SetNewFileAttr(FileName : String; Attr : Byte) : Integer;
  { Sets Attr, Clears what is already set }
 Function SetFileAttr(FileName : String; Attr : Byte) : Integer;
  { Sets Attr, leaves the rest }
 Function ClearFileAttr(FileName : String; Attr : Byte) : Integer;
  { Clears Attr, leaves the rest }
 Function  GetFileAttr(FileName : String) : Byte;
  { Returns Attr }
 Function GetFileList : FileListP;
  { Returns a Linked List of all files in current directory }
 Procedure FilterAttr(Var List : FileListP; Attr : Byte);
  { Filter out all files without Attr }
 Procedure FilterName(Var List : FileListP; Name : String);
  { Filter out all files that don't match Name }
 Procedure FilterNameAttr(Var List : FileListP; Name : String; Attr : Byte);
  { Last two Procedures Combined }
 Procedure DisposeFileList(Var List : FileListP);
  { Disposes of the Linked List }

Implementation
 Uses Dos;

 Procedure NullString; Assembler;
{ DS:DX = Pascal String }
{ Return : DS:DX = Null String }
{          AX = fOK, Success     }
  Asm
   Mov bx, dx
   Mov cl, Byte Ptr ds:[bx] { Get Length      }
   Mov ax, fFileNF          { Set Error       }
   Cmp cl, 254              { Is it too long? }
   JA @Done                 { Yes, then exit  }
   Xor ch, ch
   Add bx, cx               { Offset + Length        }
   Inc bx                   { Next Byte              }
   Mov Byte Ptr ds:[bx], 0  { Null Term. String      }
   Inc dx                   { Get rid of length Byte }
   Mov ax, fOK              { Return No Error        }
  @Done:
  End;

 Function SetNewFileAttr(FileName : String; Attr : Byte) : Integer; Assembler;
  Asm
   Push ds
   Lds dx, FileName         { Pascal String of FileName          }
   Call NullString          { Change to a Null String            }
   Cmp ax, fOK              { Change OK?                         }
   JA @Done                 { If not then Exit                   }
   Mov ah, 43h              { Dos Function 43h, File Change Mode }
   Mov al, 1                { Change Attributes                  }
   Mov cl, Attr             { Set Whatever Attributes            }
   Int 21h                  { Call Dos                           }
   JC @Done                 { See if there was an error          }
   Mov ax, fOK              { If Not, Then No Error              }
  @Done:
   Pop ds
  End;

 Function SetFileAttr(FileName : String; Attr : Byte) : Integer; Assembler;
  Asm
   Push ds
   Lds dx, FileName         { Pascal String of FileName          }
   Call NullString          { Change to a Null String            }
   Cmp ax, fOK              { Change OK?                         }
   JA @Done                 { If not then Exit                   }
   Mov ah, 43h              { Dos Function 43h, File Change Mode }
   Mov al, 0                { Return Attributes                  }
   Int 21h                  { Call Dos                           }
   JC @Done                 { See if there was an error          }
   Mov ah, 43h              { Dos Function 43h, File Change Mode }
   Mov al, 1                { Set File Attributes                }
   Or  cl, Attr             { Set Whatever Attributes            }
   Int 21h                  { Call Dos                           }
   JC @Done                 { See if there was an error          }
   Mov ax, fOK              { If Not, Then No Error              }
  @Done:
   Pop ds
  End;

 Function ClearFileAttr(FileName : String; Attr : Byte) : Integer; Assembler;
  Asm
   Push ds
   Lds dx, FileName         { Pascal String of FileName          }
   Call NullString          { Change to a Null String            }
   Cmp ax, fOK              { Change OK?                         }
   JA @Done                 { If not then Exit                   }
   Mov ah, 43h              { Dos Function 43h, File Change Mode }
   Mov al, 0                { Return Attributes                  }
   Int 21h                  { Call Dos                           }
   JC @Done                 { See if there was an error          }
   Mov ah, 43h
   Mov al, 1                { Set File Attributes                }
   Mov bl, Attr             { bl := Attr                         }
   Not bl                   { Not bl (Attr)                      }
   And cl, bl               { Clear Whatever Attributes          }
   Int 21h                  { Call Dos                           }
   JC @Done                 { See if there was an error          }
   Mov ax, fOK              { If Not, Then No Error              }
  @Done:
   Pop ds
  End;

 Function  GetFileAttr(FileName : String) : Byte; Assembler;
  Asm
   Push ds                  { Push Data Segment                  }
   Lds dx, FileName         { Pascal String of FileName          }
   Call NullString          { Change to a Null String            }
   Cmp ax, fOK              { Change OK?                         }
   JA @Done                 { If not then Exit                   }
   Mov ah, 43h              { Dos Function 43h, File Change Mode }
   Mov al, 0                { Return Attributes                  }
   Int 21h                  { Call Dos                           }
   JC @Error                { See if there was an error          }
   Mov ax, cx               { Return Attributes                  }
   Jmp @Done
  @Error:
   Mov ax, fgError          { Return Error }
  @Done:
   Pop ds                   { Pop Data Segment }
  End;

 Function GetFileList : FileListP;
  Var
   Dir  : SearchRec;
   Temp,
   Last : FileListP;
   I    : Word;
  Begin
   FindFirst('????????.???', AllFiles, Dir);
   New(Temp);
   GetFileList := Temp;
    Repeat
     Temp^.Name := Dir.Name;
     Temp^.Attr := Dir.Attr;
     Temp^.Size := Dir.Size;
     Last := Temp;
     New(Temp^.Next);
     Temp := Temp^.Next;
     FindNext(Dir);
    Until DosError <> 0;
   Dispose(Temp);
   Last^.Next := Nil;
  End;

 Procedure RemoveLink(List : FileListP);
  Var
   Next : FileListP;
  Begin
   If List^.Next = Nil Then Exit;
   Next := List^.Next^.Next;
   Dispose(List^.Next);
   List^.Next := Next;
  End;

 Procedure FilterAttr(Var List : FileListP; Attr : Byte);
  Var
   Temp,
   Last : FileListP;
  Begin
   If List = Nil Then Exit;
   Last := List;
   Temp := Last^.Next;
   While Temp <> Nil Do
    Begin
     If Temp^.Attr And Attr <> Attr Then RemoveLink(Last)
      Else Last := Last^.Next;
     Temp := Last^.Next;
    End;
   Temp := List;
   If Temp^.Attr And Attr <> Attr Then
    Begin
     New(Last);
     Last := Temp^.Next;
     Dispose(Temp);
     Temp := Last;
     List := Temp;
    End;
  End;

 Function EqualNames(S1, S2 : String) : Boolean; { Borrowed from SWAG }
  Var
   STmp1 : String[8];
   STmp2 : String[3];
   SS1, SS2 : String[12];
   I : Integer;
  Begin
   STmp1 := Copy(S1, 1, Pos('.', S1+'.'))+'????????';
   If (Pos('.', S1) > 1) Then STmp2 := Copy(S1, Pos('.', S1)+1, 3)+'???'
    Else STmp2 := '???';
   For I := 1 To 8 Do If STmp1[I] = '*' Then For I := I To 8 Do
    STmp1[I] := '?';
   For I := 1 To 3 Do If STmp2[I] = '*' Then For I := I To 3 Do
    STmp2[I] := '?';
   SS1 := STmp1+'.'+STmp2;
   STmp1 := Copy(S2, 1, Pos('.', S2+'.'))+'????????';
   If (Pos('.', S2) > 1) Then STmp2 := Copy(S2, Pos('.', S2)+1, 3)+'???'
    Else STmp2 := '???';
   For I := 1 To 8 Do If STmp1[I] = '*' Then For I := I To 8 Do
    STmp1[I] := '?';
   For I := 1 To 3 Do If STmp2[I] = '*' Then For I := I To 3 Do
    STmp2[I] := '?';
   SS2 := STmp1+'.'+STmp2;
   EqualNames := False;
   For I := 1 To 12 Do If (UpCase(SS1[I]) <> UpCase(SS2[I])) And
    (SS2[I] <> '?') Then Exit;
   EqualNames := True;
  End;

 Procedure FilterName(Var List : FileListP; Name : String);
  Var
   Temp,
   Last : FileListP;
  Begin
   If List = Nil Then Exit;
   Last := List;
   Temp := Last^.Next;
   While Temp <> Nil Do
    Begin
     If Not EqualNames(Temp^.Name, Name) Then RemoveLink(Last)
      Else Last := Last^.Next;
     Temp := Last^.Next;
    End;
   Temp := List;
   If Not EqualNames(Temp^.Name, Name) Then

    Begin
     New(Last);
     Last := Temp^.Next;
     Dispose(Temp);
     Temp := Last;
     List := Temp;
    End;
  End;

 Procedure FilterNameAttr(Var List : FileListP; Name : String; Attr : Byte);
  Begin
   FilterName(List, Name);
   FilterAttr(List, Attr);
  End;

 Procedure DisposeFileList(Var List : FileListP);
  Var
   Temp,
   Next : FileListP;
  Begin
   Temp := List;
    While Temp <> Nil Do
     Begin
      Next := Temp^.Next;
      Dispose(Temp);
      Temp := Next;
     End;
   List := Nil;
  End;

End.

{ ---------------------------    TEST PROGRAM ------------------- }

{$A+,B-,D-,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y+}
{$M 16384,0,655360}
{ ********************************************************** }
{ ************************* Attribs ************************ }
{ ********************************************************** }
{ **************** Written by: Rick Haines ***************** }
{ **************************** rick.haines@cde.com ********* }
{ ********************************************************** }
{ ***************** Last Revised 03/29/95 ****************** }
{ ********************************************************** }
Program Attribs;
 Uses Files;

Var
 Path      : String;
 Lines,
 SetAttr,
 ClearAttr : Byte;
 ListIt    : Boolean;
 Directory,
 TempDir   : FileListP;

Procedure HelpMe;
 Begin
  Writeln;
  Writeln('Attribs v1.0a -- Written by Rick Haines.');
  Writeln;
  Writeln('Format is:');
  Writeln(' Attribs [/L] [/D] [FileName] [R+|R-] [H+|H-] [S+|S-] [A+|A-] [D+]');
  Writeln;
  Writeln('WARNING:');
  Writeln(' Without the /L switch, Attribs will change the attributes');
  Writeln(' of files instead of listing them!');
  Writeln;
  Writeln('[/L] - List files & their attributes (If no params, it is assumed)');
  Writeln('[/D] - Use with /L to list only directories and their attributes');
  Writeln;
  Writeln('[FileName] - File(s) to Change/List (WildCards Accepted)');
  Writeln('             If not included it is assumed to be *.*    ');
  Writeln;
  Writeln('               Without /L              With /L       ');
  Writeln('               ~~~~~~~~~~              ~~~~~~~       ');
  Writeln('[R+|R-] - Make File(s) ReadOnly | View ReadOnly Files');
  Writeln('[H+|H-] - Make File(s) Hidden   | View Hidden Files  ');
  Writeln('[S+|S-] - Make File(s) System   | View System Files  ');
  Writeln('[A+|A-] - Make File(s) Archive  | View Archive Files ');
  Writeln('[D+]    - Change Dir Attribs    | Do Not Use With /L ');
  Halt;
 End;

Procedure ParseCommandLine;
 Var
  I   : Byte;
  Par : String;
 Begin
  Path := '*.*';
  If ParamCount < 1 Then
   Begin
    ListIt := True;
    Exit;
   End;
  For I := 1 To ParamCount Do
   Begin
    Par := ParamStr(I);
     Case UpCase(Par[1]) Of
      'D' : Case Par[2] Of
             '+' : ClearAttr := ClearAttr Or SubDir;
             '-' : SetAttr := SetAttr Or SubDir;
             Else Path := Par;
            End;
      'H' : Case Par[2] Of
             '+' : SetAttr := SetAttr Or HiddenF;
             '-' : ClearAttr := ClearAttr Or HiddenF;
             Else Path := Par;
            End;
      'S' : Case Par[2] Of
             '+' : SetAttr := SetAttr Or SystemF;
             '-' : ClearAttr := ClearAttr Or SystemF;
             Else Path := Par;
            End;
      'R' : Case Par[2] Of
             '+' : SetAttr := SetAttr Or ReadOnlyF;
             '-' : ClearAttr := SetAttr Or ReadOnlyF;
             Else Path := Par;
            End;
      'A' : Case Par[2] Of
             '+' : SetAttr := SetAttr Or ArchiveF;
             '-' : ClearAttr := ClearAttr Or ArchiveF;
             Else Path := Par;
            End;
      '/' : Case UpCase(Par[2]) Of
             'L' : ListIt := True;
             'D' : SetAttr := SetAttr Or SubDir;
             '?' : HelpMe;
             Else Path := Par;
            End;
      Else Path := Par;
     End;
   End;
 End;

Function GetBit(Byte, Bit : Word) : Boolean;
 Begin
  Byte := Byte And (1 ShL Bit);
  GetBit := (Byte = (1 ShL Bit));
 End;

Procedure WriteAttr(Attr : Byte);
 Begin
  If GetBit(Attr, 0) Then Write('R') Else Write(' ');
  If GetBit(Attr, 1) Then Write(' H') Else Write('  ');
  If GetBit(Attr, 2) Then Write(' S') Else Write('  ');
  If GetBit(Attr, 5) Then Write(' A') Else Write('  ');
  If GetBit(Attr, 3) Then Write(' V') Else Write('  ');
  If GetBit(Attr, 4) Then Write(' Dir') Else Write('    ');
  Write('  ');
 End;

Function ReadKey : Char; Assembler;
 Asm
  Mov ax, 0
  Int 16h
 End;

Begin
 SetAttr := NormalF;
 ClearAttr := NormalF;
 ParseCommandLine;
 Directory := GetFileList;
 FilterName(Directory, Path);
 Writeln;
 If ListIt Then
  Begin
   Lines := 0;
   FilterAttr(Directory, SetAttr);
   TempDir := Directory;
   If TempDir = Nil Then Writeln('No Files Found');
   While TempDir <> Nil Do
    Begin
     WriteAttr(TempDir^.Attr);
     Writeln(TempDir^.Name);
     TempDir := TempDir^.Next;
     Inc(Lines);
     If Lines >= 24 Then
      Begin
       Write('--Press any key to continue--');
       ReadKey;
       Writeln;
       Lines := 0;
      End;
    End;
  End;
 If Not ListIt Then
  Begin
   TempDir := Directory;
   While TempDir <> Nil Do
    Begin
     TempDir^.Attr := (TempDir^.Attr And Not ClearAttr) Or SetAttr;
     SetNewFileAttr(TempDir^.Name, TempDir^.Attr);
     TempDir := TempDir^.Next;
    End;
   If Directory = Nil Then Writeln('No Files Found') Else Writeln('Success!');
  End;
 DisposeFileList(Directory);
End.

