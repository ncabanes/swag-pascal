(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0006.PAS
  Description: Copy File #6
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{$A+,B-,D-,E+,F-,I+,L-,N-,O-,R+,S+,V-}
{$M 16384,65536,655360}

Program scopy;

Uses
  Dos,
  tpDos,
  sundry,
  Strings;

Type
  buffer_Type = Array[0..65519] of Byte;
  buffptr     = ^buffer_Type;

Var
  f1,f2       : File;
  fname1,
  fname2,
  NewFName,
  OldDir      : PathStr;
  SRec        : SearchRec;
  errorcode   : Integer;
  buffer      : buffptr;
Const
  MakeNewName : Boolean = False;
  FilesCopied : Word = 0;
  MaxHeapSize = 65520;

Function IOCheck(stop : Boolean; msg : String): Boolean;
  Var
    error : Integer;
  begin
    error := Ioresult;
    IOCheck := (error = 0);
    if error <> 0 then begin
      Writeln(msg);
      if stop then begin
        ChDir(OldDir);
        halt(error);
      end;
    end;
  end;

Procedure Initialise;
  Var
    temp  : String;
    dir   : DirStr;
    name  : NameStr;
    ext   : ExtStr;
  begin
    if MaxAvail < MaxHeapSize then begin
      Writeln('Insufficient memory');
      halt;
    end
    else
      new(buffer);
    {I-} GetDir(0,OldDir); {$I+} if IOCheck(True,'') then;
    Case ParamCount of
      0: begin
           Writeln('No parameters provided');
           halt;
         end;
      1: begin
           TempStr := ParamStr(1);
           if not ParsePath(TempStr,fname1,fname2) then begin
             Writeln('Invalid parameter');
             halt;
           end;
           {$I-} ChDir(fname2); {$I+} if IOCheck(True,'') then;
         end;
      2: begin
           TempStr := ParamStr(1);
           if not ParsePath(TempStr,fname1,fname2) then begin
             Writeln('Invalid parameter');
             halt;
           end
           else
             {$I-} ChDir(fname2); {$I+} if IOCheck(True,'') then;

           TempStr := ParamStr(2);
           if not ParsePath(TempStr,fname2,temp) then begin
             Writeln('Invalid parameter');
             halt;
           end;
           FSplit(fname2,dir,name,ext);
           if length(name) <> 0 then
             MakeNewName := True;
         end;
    else begin
           Writeln('too many parameters');
           halt;
         end;
    end; { Case }
  end; { Initialise }

Procedure CopyFiles;
  Var
    result : Word;

  Function MakeNewFileName(fn : String): String;
    Var
      temp  : String;
      dir   : DirStr;
      name  : NameStr;
      ext   : ExtStr;
      numb  : Word;
    begin
      numb := 0;
      FSplit(fn,dir,name,ext);
      Repeat
        inc(numb);
        if numb > 255 then begin
          Writeln('Invalid File name');
          halt(255);
        end;
        ext := copy(Numb2Hex(numb),2,3);
        temp := dir + name + ext;
        Writeln(temp);
      Until not ExistFile(temp);
      MakeNewFileName := temp;
    end; { MakeNewFileName }


  begin
    FindFirst(fname1,AnyFile,Srec);
    While Doserror = 0 do begin
      if (SRec.attr and $19) = 0 then begin
        if MakeNewName then
          NewFName := fname2
        else
          NewFName := SRec.name;
        if ExistFile(NewFName) then
          NewFName := MakeNewFileName(NewFName);
        {$I-}
        Writeln('Copying ',SRec.name,' > ',NewFName);
        assign(f1,SRec.name);
        reset(f1,1);
        if { =1= } IOCheck(False,'1. Cannot copy '+fname1) then begin
          assign(f2,fname2);
          reWrite(f2,1);
          if IOCheck(False,'2. Cannot copy '+SRec.name) then
            Repeat
              BlockRead(f1,buffer^,MaxHeapSize);
              if IOCheck(False,'3. Cannot copy '+SRec.name) then
                result := 0
              else begin
                BlockWrite(f2,buffer^,result);
                if IOCheck(False,'4. Cannot copy '+NewFName) then
                  result := 0;
              end;
            Until result < MaxHeapSize;
          close(f1); close(f2);
          if IOCheck(False,'Error While copying '+SRec.name) then;
        end; { =1= }
      end;  { if SRec.attr }
      FindNext(Srec);
    end; { While Doserror = 0 }
  end; { CopyFiles }

begin
  Initialise;
  CopyFiles;
  ChDir(OldDir);
end.


