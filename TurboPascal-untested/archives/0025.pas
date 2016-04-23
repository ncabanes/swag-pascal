{
> Does anyone know where I can obtain source for reading a ZIP
> file.  I know I could just shell and execute PKUNZIP, but the
> looks horrible. 8-) I would like to do it as transparently as
> possible (and without shelling :)  TIA!
}
Type      ZFHeader=Record
                     Signature                         :longint;
                     Version,GPBFlag,Compress,Date,Time:word;
                     CRC32,CSize,USize                 :longint;
                     FNameLen,ExtraField               :word;
                   end;


type      PZipArchive=^TZipArchive;
          TZipArchive=object(TGeneralArchive)
                        constructor Init;
                        procedure FindFirst(var sr:SearchRec);virtual;
                        procedure FindNext(var sr:SearchRec);virtual;
                      private
                        Hdr:ZFHeader;
                        function  GetHeader(var sr:SearchRec):string;
                      end;

implementation

uses      Objects,OOAVUtil;

Const     SIG = $04034B50;                  { Signature }


constructor TZipArchive.Init;
begin
  FillChar(Hdr,sizeof(Hdr),0);
end;


function  TZipArchive.GetHeader(var sr:SearchRec):string;
var       b:byte;
          FName:string;
begin
  fillchar(sr,sizeof(sr),0);
  if _FArchive^.GetPos=_FArchive^.GetSize then
    exit;
  _Farchive^.Read(Hdr,SizeOf(Hdr));
  if _FArchive^.Status<>stOk then
    exit;
{ Why checking for Hdr.FNamelen=0?
  Because the comments inserted in a ZIP-file are at the last field }
  if Hdr.FNameLen=0 then
    exit;
  FName:='';
  Repeat
    _FArchive^.Read(b,1);
    If b<>0 Then
      FName:=FName+Chr(b);
  Until (length(FName)=Hdr.FNameLen) or (b=0);
  if b=0 then
  begin
    GetHeader:='';
    exit;
  end;
  _FArchive^.Seek(_FArchive^.GetPos+Hdr.CSize+Hdr.ExtraField);
  sr.Size:=Hdr.USize;
  sr.Time:=Hdr.Date+Hdr.Time*longint(256*256);
  GetHeader:=FName;
end;


procedure TZipArchive.FindFirst(var sr:SearchRec);
var       FName:string;
          found:boolean;
begin
  found:=false;
  repeat
    FName:=GetHeader(sr);
    if FName='' then
    begin
      found:=true;
      sr.Name:='';
    end;
    while pos('/',FName)<>0 do
      FName[pos('/',FName)]:='\';
    if Fits(FName,_SearchDir+_SearchFile) then
    begin
      sr.Name:=copy(FName,length(_SearchDir)+1,12);
      found:=true;
    end;
  until found;
end;


procedure TZipArchive.FindNext(var sr:SearchRec);
var       FName:string;
          found:boolean;
begin
  found:=false;
  repeat
    FName:=GetHeader(sr);
    if FName='' then
    begin
      found:=true;
      sr.Name:='';
    end;
    while pos('/',FName)<>0 do
      FName[pos('/',FName)]:='\';
    if Fits(FName,_SearchDir+_SearchFile) then
    begin
      sr.Name:=copy(FName,length(_SearchDir)+1,12);
      found:=true;
    end;
  until found;
end;
