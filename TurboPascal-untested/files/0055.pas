
{ The following procedure physically removes record(s) from any file,
  then truncate the file. I use it to shrink log files and to remove
  index entries from Squish .SQI files, but many other uses may be found.  }

{ Donated to the public domain by Raphaël Vanney.                          }

Uses DOS ;

Function  DeleteRecs(    Var AFile ;
                         From      : LongInt ;
                         Count     : LongInt ;
                         BufSize   : Word) : Integer ;

{ AFile   : any typed or untyped file (not Text), must be opened           }
{ From    : number of 1st record to delete, 0-based                        }
{ Count   : number of record(s) to delete                                  }
{ BufSize : size of the buffer to allocate. Must be > record size          }

Var  Buffer    : Pointer ;              { pointer to buffer                }
     Src       : LongInt ;              { source record pointer            }
     Cnt       : LongInt ;              { scratch                          }
     Last      : LongInt ;              { last record to move              }
     f         : File Absolute AFile ;  { file we're going to work on      }
     Err       : Integer ;              { error code                       }

Label
     Sortie ;

Begin
     Last:=FileSize(f) ;
     Src:=From+Count ;
     If Count>(Last-From) Then Count:=Last-From ;

     { check BufSize against FileRec(f).RecSize }
     If (BufSize<FileRec(f).RecSize) Or
        (MaxAvail<BufSize) Then
     Begin
          DeleteRecs:=1 ; { error }
          Exit ;
     End ;

     GetMem(Buffer, BufSize) ;

     While Src<Last Do
     Begin
          Cnt:=BufSize Div FileRec(f).RecSize ;
          If (Src+Cnt)>Last Then Cnt:=Last-Src ;
          Seek(f, Src) ;
          BlockRead(f, Buffer^, Cnt) ;
          { error check }
          Err:=IOResult ;
          If Err<>0 Then GoTo Sortie ;
          Seek(f, From) ;
          BlockWrite(f, Buffer^, Cnt) ;
          { error check }
          Err:=IOResult ;
          If Err<>0 Then GoTo Sortie ;
          Inc(Src, Cnt) ;
          Inc(From, Cnt) ;
     End ;

     Seek(f, Last-Count) ;
     Truncate(f) ;
Sortie:
     DeleteRecs:=Err ;
     FreeMem(Buffer, BufSize) ;
End;

BEGIN
END.