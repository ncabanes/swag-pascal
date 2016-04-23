{
I found a source * COPY.PAS * (don't know where anymore or who posted it) and
tried to Write my own move_Files Program based on it.

The simple idea is to move the Files specified in paramstr(1) to a destination
directory specified in paramstr(2) and create the directories that do not yet
exist.

On a first look it seems just to work out ok. But yet it does not.

to help me find the failure set paramstr(1) to any path you want (For example
D:\test\*.txt or whatever) and set paramstr(2) to a non existing path which is
C:\A\B\C\D\E\F\G\H\..\Z\A\B\C\D\E\F\

The directories C:\A through C:\A\B\C\D\F\..\Q\R\S will be created and than the
Program hangs.

Who can help me find what the mistake is?

I Really will be grateful For any kind of help.

The code is:
}

{$A+,B-,D+,E+,F-,G-,I-,L+,N-,O-,R+,S-,V+,X-}
Program aMOVE;

Uses
  Crt, Dos;
Const
  BufSize = 32768;
Var
  ioCode               : Byte;
  SrcFile, DstFile     : File;
  FileNameA,
  FileNameB            : String;
  Buffer               : Array[1..BufSize] of Byte;
  RecsRead             : Integer;
  DiskFull             : Boolean;
  CurrDir              : DirStr;        {Aktuelles Verzeichnis speichern}
  HelpList             : Boolean;       {Hilfe uber mogliche Parameter?}
  i,
  n                    : Integer;
  str                  : String[1];

  SDStr                : DirStr;        {Quellverzeichnis}
  SNStr                : NameStr;       {Quelldateiname}
  SEStr                : ExtStr;        {Quelldateierweiterung}

  DDStr                : DirStr;        {Zielverzeichnis}
  DNStr                : NameStr;       {Zieldateiname}
  DEStr                : ExtStr;        {Zieldateierweiterung}

  SrcInfo              : SearchRec;     {Liste der Quelldateien}
  SubDirStr            : Array [0..32] of DirStr;
  key                  : Char;


  Procedure SrcFileError(ioCode : Byte);
  begin
    Write(#7, 'I/O result of ', ioCode, ' (decimal) ', #26);
    Case ioCode of
      $01 : WriteLn(' Source File not found.');
      $F3 : WriteLn(' too many Files open.');
    else WriteLn(' "Reset" unknown I/O error.');
    end;
  end;

  Procedure DstFileError(ioCode : Byte);
  begin
    Write(#7, 'I/O result of ', ioCode, ' (decimal) ', #26);
    Case ioCode of
      $F0 : WriteLn(' Disk data area full.');
      $F1 : WriteLn(' Disk directory full.');
      $F3 : WriteLn(' too many Files open.');
    else WriteLn(' "ReWrite" unknown I/O error.');
    end;
  end;



Procedure EXPAR;                      {externe Parameter abfragen} begin
  GetDir(0,CurrDir);                  {Aktuelles Verzeichnis speichern}
  if DDStr='' then DDStr:= CurrDir;   {Wenn keine Zialangabe, dann ins
                                       aktuelle Verzeichnis verschieben}
  FSplit(paramstr(1), SDStr, SNStr, SEStr);
end;

Procedure Copy2Dest;
begin
  if FileNameB <> FileNameA then
    begin
      Assign(SrcFile, FileNameA);
      Assign(DstFile, FileNameB);
      {* note second parameter in "reset" and "reWrite" of UNTyped Files. *}
      {$I-} Reset(SrcFile, 1); {$I+}
      ioCode := Ioresult;
      if (ioCode <> 0) then SrcFileError(ioCode)
      else
        begin
          {$I-} ReWrite(DstFile, 1); {$I+}
          ioCode := Ioresult;
          if (ioCode <> 0) then DstFileError(ioCode)
          else
            begin
              DiskFull := False;
              While (not EoF(SrcFile)) and (not DiskFull) do
                begin
                  {* note fourth parameter in "blockread". *}
                  {$I-}
                  BlockRead(SrcFile, Buffer, BufSize, RecsRead);
                  {$I+}
                  ioCode := Ioresult;
                  if ioCode <> 0 then
                    begin
                      SrcFileError(ioCode);
                      DiskFull := True
                    end
                  else
                    begin
                      {$I-}
                      BlockWrite(DstFile, Buffer, RecsRead);
                      {$I+}
                      ioCode := Ioresult;
                      if ioCode <> 0 then
                        begin
                          DstFileError(ioCode);
                          DiskFull := True
                        end
                    end
                end;
              if not DiskFull then WriteLn(FileNameB)
            end;
          Close(DstFile)
        end;
      Close(SrcFile)
    end
  else WriteLn(#7, 'File can not be copied onto itself.')
end;

Procedure ProofDest;
begin
  if length(paramstr(2)) > 67 then begin
    Writeln;
    Writeln(#7,'Invalid destination directory specified.');
    Writeln('Program aborted.');
    Halt(1);
  end;
  FSplit(paramstr(2), DDStr, DNStr, DEStr);
  if copy(DNStr,length(DNStr),1)<>'.' then begin
    insert(DNStr,DDStr,length(DDStr)+1);
    DNStr:='';
  end;
  if copy(DDStr,length(DDStr),1)<>'\' then
    insert('\',DDSTR,length(DDStr)+1);
  SubDirStr[0]:= DDStr;
  For i:= 1 to 20 do begin
    SubDirStr[i]:=copy(DDStr,1,pos('\',DDStr));
    Delete(DDStr,1,pos('\',DDStr));
  end;
  For i:= 32 doWNto 1 do begin
    if SubDirStr[i]= '' then n:= i-1;
  end;

  DDStr:= SubDirStr[0];
  SubDirStr[0]:='';

  For i:= 1 to n do begin
    SubDirStr[0]:= SubDirStr[0]+SubDirStr[i];

    if copy(SubDirStr[0],length(SubDirStr[0]),1)='\' then
      delete(SubDirStr[0],length(SubDirStr[0]),1);

 begin
      {$I-}
      MkDir(SubDirStr[0]);
      {$I+}
      if Ioresult = 0 then
      WriteLn('New directory created: ', SubDirStr[0]);
    end;

    if copy(SubDirStr[0],length(SubDirStr[0]),1)<>'\' then
      insert('\',SubDirStr[0],length(SubDirStr[0])+1);
  end;
end;

Procedure HandleMove;
begin
  FileNameA:= SDStr+SrcInfo.Name;
  FileNameB:= DDStr+SrcInfo.Name;
  Copy2Dest;
  Erase(SrcFile);
end;

Procedure ExeMove;
begin
  ProofDest;
  FindFirst(paramstr(1), AnyFile, SrcInfo);
  While DosError = 0 do begin
    HandleMove;
    FindNext(SrcInfo);
  end;
end;



begin
  SDStr:= '';
  SNStr:= '';
  SEStr:= '';
  DDStr:= '';
  DNStr:= '';
  DEStr:= '';
  For i:=0 to 32 do SubDirStr[i]:='';
  ExPar;
  ExeMove;
end.
