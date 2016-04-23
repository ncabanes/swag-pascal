{$X+}
Unit selfmod;

 { Author Trevor J Carlsen - released into the public domain 1991            }
 {        PO Box 568                                                         }
 {        Port Hedland                                                       } 
 {        Western Australia 6721                                             }
 {        Voice +61 91 73 2026  Data +61 91 73  2569                         }
 {        FidoNet 3:690/644                                                  }
 { Allows a Program to self modify a Typed Constant in the .exe File.  It    }
 { also perForms an automatic checksum Type .exe File integrity check.       }
 { A LongInt value is added to the end of the exe File.  This can be read by }
 { a separate configuration Program to enable it to determine the start of   }
 { the Programs configuration data area.  to use this the configuration      }
 { Typed Constant should be added immediately following the declaration of   }
 { ExeData.                                                                  }
 
 { Where this Unit is used, it should always be the FIRST Unit listed in the }
 { Uses declaration area of the main Program.                                }
 
 { Requires Dos 3.3 or later.  Program must not be used With PKLite or LZExe }
 { or any similar exe File Compression Programs. It may also cause           }
 { difficulties on a network or virus detection Programs.                    }
 
 { The stack size needed is at least 9,000 Bytes.                            }
 
Interface

Uses
  globals;

Type
  ExeDataType    = Record
                     IDStr      : str7;
                     UserName   : str35;
                     FirstTime  : Boolean;
                     NumbExecs  : shortint;
                     Hsize      : Word;
                     ExeSize    : LongInt;
                     CheckSum   : LongInt;
                     StartConst : LongInt;
                     RegCode    : LongInt;
                   end;
Const
  ExeData : ExeDataType = (IDStr     : 'ID-AREA';
                           UserName  : '';
                           FirstTime : True;
                           NumbExecs : -1;
                           Hsize     : 0;
                           ExeSize   : 0;
                           CheckSum  : 0;
                           StartConst: 0;
                           RegCode   : 0);


{$I p:\prog\freeload.inc} { Creates CodeStr that MUST match RegStr }

{$I p:\prog\registed.inc} { Creates CodeChkStr that MUST hash to RegCode}

Const
  mark  : Byte = 0;

Var
  first : Boolean;

Procedure Hash(p : Pointer; numb : Byte; Var result: LongInt);

Function Write2Exec(Var data; size: Word): Boolean;

Implementation


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


Procedure InitConstants;
  Var
    f           : File;
    tbuff       : Array[0..1] of Word;
  
  Function GetCheckSum : LongInt;  
    { PerForms a checksum calculation on the exe File }
    Var
      finished  : Boolean;
      x,
      CSum      : LongInt;
      BytesRead : Word;
      buffer    : Array[0..4095] of Word;
    begin
      {$I-}
      seek(f,0);
      finished := False;  CSum := 0;  x := 0;
      BlockRead(f,buffer,sizeof(buffer),BytesRead);
      While not finished do begin             { do the checksum calculations }
        Repeat         { Until File has been read up to start of config area }
          inc(CSum,buffer[x mod 4096]);
          inc(x);
          finished := ((x shl 1) >= ExeData.StartConst); 
        Until ((x mod 4096) = 0) or finished;
        if not finished then                { data area has not been reached }
          BlockRead(f,buffer,sizeof(buffer),BytesRead);          
      end;
      GetCheckSum := CSum;
    end; { GetCheckSum }
    
      
  begin
    assign(f, ParamStr(0));
    {$I-} Reset(f,1);
    With ExeData do begin
      first := FirstTime;
      if FirstTime and (Ioresult = 0) then begin
        Seek(f,2);                   { this location has the executable size }
        BlockRead(f,tbuff,4);
        ExeSize := tbuff[0]+(pred(tbuff[1]) shl 9);
        seek(f,8);                                    {  get the header size }
        BlockRead(f,hsize,2);
        FirstTime := False;
        StartConst := LongInt(hsize+Seg(ExeData)-PrefixSeg) shl 4 + 
                      ofs(ExeData) - 256;
        CheckSum := GetCheckSum;
        Seek(f,StartConst);
        BlockWrite(f,ExeData,sizeof(ExeData));
        seek(f,FileSize(f));
        BlockWrite(f,StartConst,4);
      end
      else
        if GetCheckSum <> CheckSum then begin
          Writeln('File has been tampered with.  Checksum incorrect');
          halt;
        end;
    end;  { With }    
    Close(f); {$I+}
    if Ioresult <> 0 then begin
      Writeln('Unable to initialise Program');
      halt;
    end;  
  end; { InitConstants }


Function Write2Exec(Var data; size: Word): Boolean;
 { Writes a new Typed Constant into the executable File after first checking }
 { that it is safe to do so.  It does this by ensuring that the IDString is  }
 { at the File offset expected.                                              }
  Const
    FName : str40 = '';
  Var
     f          : File;
     st         : str8;
     BytesRead  : Word;
  begin
    if UseCfg then begin
      if length(FName) = 0 then begin
        TempStr    := ParamStr(0);
        TempStrLen := pos('.',TempStr) - 2;
        FName      := TempStr + ' .   ';
        {                        │ │││                                       }
        {                        │ ││└────»» #255                            }
        {                        │ │└─────»» #32                             }
        {                        │ └──────»» #255                            }
        {                        └────────»» #255                            }
        { Using the above File name For the configuration File makes the     }
        { deletion of the File difficult For the average user.               }
      end; { if length }
      assign(f, FName);
      if exist(FName) then begin
        {$I-}
        reset(f,1);
        if first then begin
          first := False;
          BlockRead(f, ExeData, ofs(mark)-ofs(ExeData),BytesRead)
        end else
          BlockWrite(f,data,size);
      end else begin
        reWrite(f,1);
        BlockWrite(f,Data,size);
      end;
      close(f);
      {$I+}
      Write2Exec := Ioresult = 0;
    end else begin
      assign(f, ParamStr(0));
      {$I-} Reset(f,1);
      Seek(f,LongInt(ExeData.Hsize+Seg(ExeData)-PrefixSeg) shl 4
                     + ofs(ExeData)- 256);
      BlockRead(f,st,9);
      if st = ExeData.IDStr then { all Ok to proceed } begin
        Seek(f,LongInt(ExeData.Hsize+Seg(data)-PrefixSeg) shl 4
                       + ofs(data)- 256);
        BlockWrite(f,data,size);
        Close(f); {$I+}
        Write2Exec := Ioresult = 0;
      end else
        Write2Exec := False;
    end;
  end; { Write2Exec }
  
begin
  first :=  True;
  if not UseCfg then
    InitConstants
  else
    Write2Exec(ExeData,ofs(mark)-ofs(ExeData));
end.
