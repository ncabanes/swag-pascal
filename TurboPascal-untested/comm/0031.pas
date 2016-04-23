{
HELGE HELGESEN

-> Currently I am writing the USERS File to a  Temp File While im
-> reading it (or atleast I try to), but pascal  does not allow
-> me to Write a full Record to a File.

I suppose you're running a on a network, and that you have
problems accessing the USERS File directly?

First of all, do you open the File in shared mode, which is
necessary if multiple Programs to access the File simultaneous.

-> So could you  tell me an easier way Write back the
-> modifications that I have  done. A little example would be
-> Really cool..

Sure... Here's a little example. Tested With PCBoard configured
for use on network, With DESQview.

if you'd relly try this you should reWrite the proc "ModifyRecord" first ;)
}

Program AccessUsersFile;

Uses
  Dos;

Type
  bdReal = Array [0..7] of Byte; { I'm not sure of this one... }
  bsReal = Array [0..3] of Byte; { have conversion routines For this one if you need }

  TUser = Record { declare user Record }
    Name              : Array[ 1..25] of Char;
    City              : Array [1..24] of Char;
    PassWord          : Array [1..12] of Char;
    Phone             : Array [1..2] of Array [1..13] of Char;
    LastDateOn        : Array [1..6] of Char;
    LastTimeOn        : Array [1..5] of Char;
    Expert            : Char;
    Protocol          : Char;
    SomeBitFlags      : Byte;
    DateOfLastDirScan : Array [1..6] of Char;
    Level             : Byte;
    TimesOn           : Word;
    PageLen           : Byte;
    FilesUploaded,
    FilesDownloaded   : Word;
    DownloadToday     : bdReal;
    Comment           : Array [1..2] of Array [1..30] of Char;
    ElapsedOn         : Word;
    RegExpDate        : Array [1..6] of Char;
    ExpLevel          : Byte;
    OldLastConfIn     : Byte;
    ConfRegBitFlags,
    ExpRegBitFlags,
    UserSelBitFlags   : Array [0..4] of Byte;
    TotBytesDown,
    TotBytesUp        : bdReal;
    DeleteFlag        : Char;
    LRP               : Array [0..39] of bsReal; { last read Pointers }
    RecNoInUsersInf   : LongInt;
    MoreBitFlags      : Byte;
    RFU               : Array [1..8] of Char;
    LastConfIn        : Word;
  end;

  TIndex = Record { PCBNDX Files }
    RecNo : Word;
    Name  : Array [1..25] of Char;
  end;

Var
  UsersFile     : File of TUser;
  PathToIndexes : String; { path to index Files, With 'PCBNDX.' added }
  Users         : TUser; { global Record - users Record }

Procedure OpenUsersFile;
Var
  t : Text;
  s : String;
  x : Byte;
begin
  s := GetEnv('PCBDAT');
  if length(s) = 0 then
    halt; { if I can't find PCBOARD.DAT I can't find USERS File either }
  assign(t, s); {$I+}
  reset(t); { open File, will terminate if any error }
  For x := 1 to 28 do
    readln(t, s);
  PathToIndexes := s + 'PCBNDX.';
  FileMode := 66;
  readln(t, s);
  assign(UsersFile, s);
  reset(UsersFile);
  close(t);
end;

Function FindUserRec: Word;
{ Searches thru index File For name. if not found, $FFFF is returned. }
Var
  name      : String;
  IndexFile : File of TIndex;
  x         : Byte;
  Found     : Boolean;
  Index     : TIndex;
begin
  Write('Enter name of user to modify: ');
  readln(name);
  FindUserRec := $ffff;
  x := length(name);
  name[0] := #25; { make 25 Char name }
  For x := x + 1 to 25 do
    name[x] := #32;
  For x := 1 to 25 do
    name[x] := UpCase(name[x]); { make upper Case }
{ since PCBoard v15.0 supports national Chars, you should do it too. If
  you need, I have something on this too... ;) }
  assign(IndexFile, PathToIndexes + name[1]);
  reset(IndexFile);
  Repeat
    read(IndexFile, Index); { read name }
    x := 1;
    While (x <= 25) and (name[x] = Index.Name[x]) do
      inc(x);
    Found := x = 26;
  Until eof(IndexFile) or Found;
  if Found then
    FindUserRec := Index.RecNo - 1;
{ Please note that I subtract 1 here. This is becase PCBoard was written in
  Basic (when the File format was made) and that Basic threats Record 1 as
  the first Record. In Pascal, Record 0 is the first Record! This may confuse
  a bit since some Files Within PCBoard are 1-based, and some are 0-based. }
  close(IndexFile);
end;

Procedure ModifyRecord;
{ Let's modify the Record... }
Var
  x : Byte;
begin
  Write('Users name: ');
  For x := 1 to 25 do
    Write(Users.Name[x]);
  Writeln; { For verification only... }
  Users.Protocol:='Z'; { let's make him use Zmodem }
  inc(Users.PassWord[1]); { and give him some headache }
  Users.PageLen := 0; { and make the screen go non-stop, when he gets on again... }
end;

Var
  x : Word;
begin
  OpenUsersFile;
  x := FindUserRec;
  if x = $ffff then
  begin
    Writeln('Can''t locate user, sorry...');
    close(UsersFile);
    halt; { can't find user... }
  end;
  seek(UsersFile, x); { seek to the Record }
  read(UsersFile, Users); { and read the Record }
  seek(UsersFile, x); { seek back to the Record }
  ModifyRecord; { make some modificatios... }
  Write(UsersFile, Users); Writeln('Modifiations written back...');
  close(UsersFile);
end.



Var
  Cnames  : File;
  PCBConf : PCBConfType; { your declaration }

begin
  { And now we need to open it }
  assign(Cnames, 'CNAMES.@@@'); { I assume is't local }
  FileMode := 66; { open in shared mode }
  reset(Cnames, 1); { NB! Make RecSize = 1! }

  { Now, let's read the Record length. I assume X is an Word! }
  blockread(Cnames, x, sizeof(x));

  { And now it's time to seek to conference Y(also a Word). }
  seek(Cnames, 2 + y * x);

  { And read the Record. }
  blockread(Cnames, PCBConf, sizeof(PCBConf));

  { There. if you want to Write back some modifications, }
  seek(Cnames, 2 + x * y); { seek back to Record }
  blockWrite(Cnames, PCBConf, sizeof(PCBConf));

