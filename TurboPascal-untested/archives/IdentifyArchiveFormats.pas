(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0020.PAS
  Description: Identify Archive Formats
  Author: EDWIN GROOTHUIS
  Date: 08-24-94  13:19
*)


{$define ARJ}
{$define ZIP}
{$define ARC}
{$define LZH}
{$define ZOO}

function  IdentifyArchive(const Name:string):char;
{
  returns:
    '?': unknown archive
    'A': Arj-archive;
    'Z': Zip-archive
    'L': Lzh-archive
    'C': Arc-archive
    'O': Zoo-archive
}
var       f:PBufStream;
          a:array[0..10] of char;
          bc:word;
          s:string;
begin
  IdentifyArchive:='?';
  if Name='' then
    exit;

  f:=New(PBufStream,Init(Name,stOpenRead,1024));
  if f^.Status<>stOk then
  begin
    Dispose(f,Done);
    exit;
  end;

  f^.Read(a,sizeof(a));
  if f^.Status<>stOk then
  begin
    Dispose(f,Done);
    exit;
  end;
  Dispose(f,Done);

{$ifdef arj}
  if (a[0]=#$60) and (a[1]=#$EA) then
  begin
    IdentifyArchive:='A';  { ARJ }
    exit;
  end;
{$endif}

{$ifdef zip}
  if (a[0]='P') and (a[1]='K') then
  begin
    IdentifyArchive:='Z';  { ZIP }
    exit;
  end;
{$endif}

{$ifdef arc}
  if a[0]=#$1A then
  begin
    IdentifyArchive:='C';  { ARC }
    exit;
  end;
{$endif}

{$ifdef zoo}
  if (a[0]='Z') and (a[1]='O') and (a[2]='O') then
  begin
    IdentifyArchive:='O';  { ZOO }
    exit;
  end;
{$endif}

{$ifdef lzh}
  s:=Name;
  for bc:=1 to length(s) do
    s[bc]:=upcase(s[bc]);
  if copy(s,pos('.',s),4)='.LZH' then
  begin
    IdentifyArchive:='L';  { LZH }
    exit;
  end;
{$endif}

  IdentifyArchive:='?';
end;

