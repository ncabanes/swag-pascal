(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0023.PAS
  Description: Netware Encrypted Login
  Author: OLAF BARTELT
  Date: 08-24-94  13:48
*)


{$R+,V-}

{ This program will prompt for a server, login id and password.  All }
{ input will be echoed to the screen!                                }

PROGRAM LOGON;

USES
  Dos,
  Crt;

CONST
  NET_USER         = 1;
  USER_GROUP       = 2;
  FILE_SERVER      = 4;

  MaxServers       = 8;
  DriveHandleTable = 0;
  DriveFlagTable   = 1;
  DriveServerTable = 2;
  ServerMapTable   = 3;
  ServerNameTable  = 4;

TYPE
  Buf32 = ARRAY [0..31] OF BYTE;
  Buf16 = ARRAY [0..15] OF BYTE;
  Buf8  = ARRAY [0..7]  OF BYTE;
  Buf4  = ARRAY [0..3]  OF BYTE;

CONST
  EncryptTable : ARRAY [BYTE] OF BYTE =
($7,$8,$0,$8,$6,$4,$E,$4,$5,$C,$1,$7,$B,$F,$A,$8,
 $F,$8,$C,$C,$9,$4,$1,$E,$4,$6,$2,$4,$0,$A,$B,$9,
 $2,$F,$B,$1,$D,$2,$1,$9,$5,$E,$7,$0,$0,$2,$6,$6,
 $0,$7,$3,$8,$2,$9,$3,$F,$7,$F,$C,$F,$6,$4,$A,$0,
 $2,$3,$A,$B,$D,$8,$3,$A,$1,$7,$C,$F,$1,$8,$9,$D,
 $9,$1,$9,$4,$E,$4,$C,$5,$5,$C,$8,$B,$2,$3,$9,$E,
 $7,$7,$6,$9,$E,$F,$C,$8,$D,$1,$A,$6,$E,$D,$0,$7,
 $7,$A,$0,$1,$F,$5,$4,$B,$7,$B,$E,$C,$9,$5,$D,$1,
 $B,$D,$1,$3,$5,$D,$E,$6,$3,$0,$B,$B,$F,$3,$6,$4,
 $9,$D,$A,$3,$1,$4,$9,$4,$8,$3,$B,$E,$5,$0,$5,$2,
 $C,$B,$D,$5,$D,$5,$D,$2,$D,$9,$A,$C,$A,$0,$B,$3,
 $5,$3,$6,$9,$5,$1,$E,$E,$0,$E,$8,$2,$D,$2,$2,$0,
 $4,$F,$8,$5,$9,$6,$8,$6,$B,$A,$B,$F,$0,$7,$2,$8,
 $C,$7,$3,$A,$1,$4,$2,$5,$F,$7,$A,$C,$E,$5,$9,$3,
 $E,$7,$1,$2,$E,$1,$F,$4,$A,$6,$C,$6,$F,$4,$3,$0,
 $C,$0,$3,$6,$F,$8,$7,$B,$2,$D,$C,$6,$A,$A,$8,$D);

  EncryptKeys : Buf32 =
($48,$93,$46,$67,$98,$3D,$E6,$8D,$B7,$10,$7A,$26,$5A,$B9,$B1,$35,
 $6B,$0F,$D5,$70,$AE,$FB,$AD,$11,$F4,$47,$DC,$A7,$EC,$CF,$50,$C0);


TYPE
  WORD   = INTEGER;

  NetStr = STRING[47];
  GenStr = STRING[128];
  FourBytes = ARRAY [1..4] of BYTE;
  MemBlock = ARRAY [1..128] OF CHAR;

{  RegsType = RECORD case integer of
    1: (AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags : INTEGER);
    2: (AL, AH, BL, BH, CL, CH, DL, DH            : BYTE);
    END; }

  ServerItem = ARRAY [1..48] OF CHAR;
  ServerName = ARRAY[1..MaxServers] OF ServerItem;
  ServerNamePtr = ^ServerName;

  ServerMappingEntry = RECORD
    SlotInUse      : BYTE;
    OrderNumber    : BYTE;
    ServerNet      : ARRAY [1..10] OF CHAR;
    ServerSocket   : WORD;
    RouterNet      : ARRAY [1..10] OF CHAR;
    RouterSocket   : WORD;
    ShellInternal  : ARRAY [1..6] OF CHAR;
  END;

  ServerMappingTable = ARRAY [1..MaxServers] OF ServerMappingEntry;
  ServerMappingPtr   = ^ServerMappingTable;

VAR
  rc   : BYTE;
  Regs : Registers;
  { Regs : RegsType; }

{ -------------------------------------------------------------- }

FUNCTION GetString(VAR NameEntry: ServerItem): GenStr;
VAR   tmp: GenStr;
      i:   INTEGER;
      ct:  BYTE;
BEGIN
  i  := 1;
  ct := 0;

  WHILE NameEntry[i] <> CHR(0) DO
     BEGIN
       tmp[i] := NameEntry[i];
       i  := i  + 1;
       ct := ct + 1;
       END;

  tmp[0] := CHAR(ct);
  GetString := tmp;
  END;

PROCEDURE Str2Az(st: GenStr; VAR az; size: INTEGER);
VAR  p: ^BYTE;
BEGIN
  Fillchar(az, size+1, 0);
  p := ADDR(st[1]);
  Move(p^, az, size);
  END;

PROCEDURE DefaultRegs(VAR r: Registers);
BEGIN
  r.DS := DSeg;
  r.ES := DSeg;
{ r.AX := 0;
  r.BX := 0;
  r.CX := 0;
  r.DX := 0;
  r.BP := 0;
  r.SI := 0;
  r.DI := 0; }
  END;

FUNCTION FileServiceRequest( func:            BYTE;
                             VAR q; qlen:     WORD;
                             VAR reply; rlen: WORD): BYTE;
BEGIN
  DefaultRegs(Regs);
  Regs.DS := Seg(q);
  Regs.SI := Ofs(q);
  Regs.CX := qlen;
  Regs.ES := Seg(reply);
  Regs.DI := Ofs(reply);
  Regs.DX := rlen;
  Regs.AH := $F2;
  Regs.AL := func;
  MSDOS(Regs);
  FileServiceRequest := Regs.AL;
END;

FUNCTION CallNetware(RegAH : BYTE; VAR request, reply): BYTE;
BEGIN
  DefaultRegs(Regs);
  Regs.AH := RegAH;
  Regs.DS := Seg(request);
  Regs.SI := Ofs(request);
  Regs.ES := Seg(reply);
  Regs.DI := Ofs(reply);
  MSDOS(Regs);
  CallNetware := Regs.AL;
  END;

PROCEDURE UpcaseStr(VAR s: GenStr);
VAR  i : INTEGER;
BEGIN
  for i := 1 to Length(s) do
    Begin
    s[i] := UpCase(s[i]);
    End;
  END;

FUNCTION GetServerMappingPtr : ServerMappingPtr;
VAR TmpPtr: ServerMappingPtr;
BEGIN
  DefaultRegs(Regs);
  Regs.AX := $EF03;
  MSDOS(Regs);
  TmpPtr  := Ptr(Regs.ES, Regs.SI);
  GetServerMappingPtr := TmpPtr;
  END;

FUNCTION GetServerNamePtr : ServerNamePtr;
VAR TmpPtr: ServerNamePtr;
BEGIN
  DefaultRegs(Regs);
  Regs.AX := $EF04;
  MSDOS(Regs);
  TmpPtr  := Ptr(Regs.ES, Regs.SI);
  GetServerNamePtr := TmpPtr;
  END;

FUNCTION GetServerNumber(s: NetStr): BYTE;
VAR
  t : ServerNamePtr;
  m : ServerMappingPtr;
  i : INTEGER;
BEGIN
  m := GetServerMappingPtr;
  t := GetServerNamePtr;
  UpCaseStr(s);

  FOR i:=1 TO MaxServers DO BEGIN
    IF (m^[i].SlotInUse = $FF) AND (GetString(t^[i]) = s) THEN BEGIN
      GetServerNumber := i;
      Exit;
    END;
  END;
  GetServerNumber := 0;
END;

FUNCTION ReadPropertyValue(ObjectType : WORD; ObjectName : NetStr;
                        Segnr : BYTE; Property : NetStr;
                        VAR item): BYTE;
VAR
  req : RECORD
    plen : WORD;
    func : BYTE;
    otype : WORD;
    Filler : GenStr;
  END;
  rep : RECORD
    plen : WORD;
    Data : ARRAY [1..128] OF BYTE;
    More : BYTE;
    PropFlags : BYTE;
  END;

BEGIN
  req.func := 61;
  req.otype := Swap(ObjectType);
  req.plen := Length(ObjectName) +
              Length(Property) + 6;
  req.filler := ObjectName + Char(Segnr) +
                Char(Length(Property)) +
                Property;
  req.filler[0] := Char(Length(ObjectName));
  rep.plen := SizeOf(rep) - 2;
  ReadPropertyValue := CallNetware($E3,req,rep);
  Move(rep.data, item, SizeOf(rep.data) + 2);
END;

FUNCTION InsertServer(Name : NetStr):BYTE;
VAR
  MapPtr  : ServerMappingPtr;
  NamePtr : ServerNamePtr;
  res     : BYTE;
  free,i  : INTEGER;
  data    : ARRAY [1..130] OF BYTE;

  FUNCTION LowerAddr(VAR a, b): BOOLEAN;
  TYPE
    Net_Address = ARRAY [1..10] OF CHAR;
  VAR
    a_addr : Net_Address ABSOLUTE a;
    b_addr : Net_Address ABSOLUTE b;
  BEGIN
    LowerAddr := a_addr < b_addr;
  END;

BEGIN
  UpCaseStr(Name);
  IF GetServerNumber(Name) <> 0 THEN BEGIN
    InsertServer := 0;
    Exit;
  END;

  res := ReadPropertyValue(FILE_SERVER, name, 1, 'NET_ADDRESS', data);
  IF res <> 0 THEN BEGIN
    InsertServer := $7D;
    Exit;
  END;

  MapPtr := GetServerMappingPtr;
  free := 1;
  WHILE (MapPtr^[free].SlotInUse = $FF) DO BEGIN
    free := free + 1;
    IF free > MaxServers THEN BEGIN
      InsertServer := $7C;
      Exit;
    END;
  END;

  NamePtr := GetServerNamePtr;
  WITH MapPtr^[free] DO BEGIN
    Move(data, ServerNet, 12);
    Str2Az(name, NamePtr^[free], SizeOf(NamePtr^[free]));
    OrderNumber := 1;
    FOR i := 1 TO MaxServers DO BEGIN
      IF MapPtr^[i].SlotInUse = $FF THEN BEGIN
        IF LowerAddr(MapPtr^[i].ServerNet, ServerNet) THEN
          OrderNumber := OrderNumber + 1
        ELSE
          MapPtr^[i].OrderNumber := MapPtr^[i].OrderNumber + 1;
      END;
    END;
    SlotInUse := $FF;
  END;
  InsertServer := 0;
END;

FUNCTION AttachServerNumber(func : BYTE; sn : BYTE) : BYTE;
BEGIN
  DefaultRegs(Regs);
  Regs.ah := $F1;
  Regs.al := func;
  Regs.dl := sn;
  MSDOS(Regs);
  AttachServerNumber := Regs.al;
END;

FUNCTION AttachServer(func : BYTE; name : NetStr) : BYTE;
VAR
  sn : BYTE;
BEGIN
  sn := GetServerNumber(name);
  IF sn = 0 THEN BEGIN
    AttachServer := $7B;
    Exit;
  END;
  AttachServer := AttachServerNumber(func,sn);
END;


FUNCTION GetEffectiveServer:BYTE;
BEGIN
  DefaultRegs(Regs);
  Regs.ax := $F002;
  MSDOS(Regs);
  GetEffectiveServer := Regs.al;
END;

PROCEDURE SetPrimaryServer(sno:BYTE);
BEGIN
  DefaultRegs(Regs);
  Regs.ax := $F004;
  Regs.dl := sno;
  MSDOS(Regs);
END;

FUNCTION GetPrimaryServer:BYTE;
BEGIN
  DefaultRegs(Regs);
  Regs.ax := $F005;
  MSDOS(Regs);
  GetPrimaryServer := Regs.al;
END;

FUNCTION SetPreferredServer(sno: BYTE): BYTE;
BEGIN
  DefaultRegs(Regs);
  Regs.ax := $F000;
  Regs.dl := sno;
  MSDOS(Regs);
  Regs.ax := $F001;
  MSDOS(Regs);
  SetPreferredServer := Regs.AL;
END;

FUNCTION MapNameToNumber(ObjectType : WORD;ObjectName : NetStr;
                         VAR ObjectID : FourBytes): BYTE;
VAR
  req : RECORD
    plen : WORD;
    func : BYTE;
    otype : WORD;
    name : NetStr;
  END;
  rep : RECORD
    plen : WORD;
    objID : FourBytes;
    otype : WORD;
    name : ARRAY [1..48] OF CHAR;
  END;
BEGIN
  req.func := 53;      {Get an object's number}
  req.otype := Swap(ObjectType);
  req.name := ObjectName;
  req.plen := Length(ObjectName) + 4;
  rep.plen := SizeOf(rep) - 2;
  MapNameToNumber := CallNetware($E3, req, rep);
  ObjectID := rep.objID;
END;

FUNCTION MapNumberToName(ID : FourBytes; VAR Name; VAR Otype : WORD):BYTE;
VAR
  req : RECORD
    plen : WORD;
    func : BYTE;
    OID  : FourBytes;
  END;
  rep : RECORD
    plen  : WORD;
    OID   : FourBytes;
    otyp  : WORD;
    Oname : ServerItem;
  END;
  nam : NetStr ABSOLUTE Name;
BEGIN
  req.func := 54;      {Get an object's name}
  req.OID := ID;
  req.plen := SizeOf(req) - 2;
  rep.plen := SizeOf(rep) - 2;
  MapNumberToName := CallNetware($E3,req,rep);
  Nam := GetString(rep.OName);
  Otype:= Swap(rep.Otyp);
END;

FUNCTION LoginAnObject( Name:NetStr; Otype:WORD; Passw: NetStr):BYTE;
VAR
  req : RECORD
    plen : WORD;
    func : BYTE;
    otype : WORD;
    NamePass : STRING[96];
  END;
  rep : RECORD
    plen : WORD;
  END;
BEGIN
  req.plen := 5 + Length(Name) + Length(Passw);
  req.func := 20;
  UpCaseStr(Passw);
  UpCaseStr(Name);
  req.otype := Swap(otype);
  req.NamePass:=Name;
  Move(Passw, req.NamePass[Length(Name)+1], Length(Passw) + 1);
  rep.plen := 0;
  LoginAnObject := CallNetware($E3, req, rep);
END;

FUNCTION LoginUser(Name, Password: NetStr): BYTE;
VAR
  req : RECORD
    plen : INTEGER;
    func : BYTE;
    NamePass : STRING[96];
  END;
  rep : RECORD
    plen : INTEGER;
  END;

BEGIN
  req.plen := 3 + Length(Name) + Length(Password);
  req.func := 0;
  UpcaseStr(Password);
  UpcaseStr(Name);
  req.NamePass := Name;
  Move(Password, req.NamePass[Length(Name)+1], Length(Password)+1);
  rep.plen := 0;
  LoginUser := CallNetware($E3, req, rep);
END;

FUNCTION GetEncryptionKey(VAR key : Buf8): BYTE;
VAR
  q : RECORD
    plen : WORD;
    func : BYTE;
  END;
BEGIN
  q.plen := 1;
  q.func := $17;
  GetEncryptionKey := FileServiceRequest($17, q, SizeOf(q), key, SizeOf(key));
END;

FUNCTION LoginEncrypted(name : NetStr; otype : WORD; VAR key : Buf8): BYTE;
VAR
  a : RECORD
    plen : WORD;
    func : BYTE;
    key  : Buf8;
    otyp : WORD;
    name : NetStr;
  END;
BEGIN
  a.plen := Length(name) + 12;
  a.func := $18;
  a.key  := key;
  a.otyp := Swap(otype);
  a.name := name;
  LoginEncrypted := FileServiceRequest($17, a, Length(name)+14, Mem[0:0], 0);
END;

PROCEDURE Shuffle1(VAR temp : Buf32; VAR target);
VAR
  t  :  Buf16 ABSOLUTE target;
  b4 :  WORD;
  b3 :  BYTE;
  s, d, b2, i : WORD;
BEGIN
  b4 := 0;
  FOR b2 := 0 TO 1 DO BEGIN
    FOR s := 0 TO 31 DO BEGIN
      b3 := Lo(Lo(temp[s] + b4)
            XOR Lo(temp[(s + b4) AND 31]
          - EncryptKeys[s]));
      b4 := b4 + b3;
      temp[s] := b3;
    END;
  END;

  FOR i := 0 TO 15 DO
    t[i] := EncryptTable[temp[i Shl 1]]
        OR (EncryptTable[temp[i Shl 1 +1]] Shl 4);
END;

PROCEDURE Shuffle(VAR lon, buf; buflen : WORD; VAR target);
VAR
  l : Buf4 ABSOLUTE lon;
  b : ARRAY [0..127] OF BYTE ABSOLUTE buf;
  b2 : WORD;
  temp : Buf32;
  s, d : WORD;
BEGIN
  IF buflen > 0 THEN
     WHILE (buflen > 0) AND (b[buflen-1] = 0) DO
       buflen := buflen - 1;

  FillChar(temp, SizeOf(temp), #0);

  d := 0;
  WHILE buflen >= 32 DO BEGIN
    FOR s := 0 TO 31 DO BEGIN
      temp[s] := temp[s] XOR b[d];
      d := d + 1;
    END;
    buflen := buflen - 32;
  END;
  b2 := d;

  IF buflen > 0 THEN BEGIN
    FOR s := 0 TO 31 DO BEGIN
      IF d + buflen = b2 THEN BEGIN
        b2 := d;
        temp[s] := temp[s] XOR EncryptKeys[s];
      END
      ELSE BEGIN
        temp[s] := temp[s] XOR b[b2];
        b2 := b2 + 1;
      END;
    END;
  END;
  FOR s := 0 TO 31 DO
    temp[s] := temp[s] XOR l[s AND 3];

  Shuffle1(temp, target);
END;

PROCEDURE Encrypt(VAR fra, buf, til);
VAR
  f : Buf8  ABSOLUTE fra;
  t : Buf8  ABSOLUTE til;
  k : Buf32;
  s : WORD;
BEGIN
  Shuffle(f[0], buf, 16, k[0]);
  Shuffle(f[4], buf, 16, k[16]);
  FOR s := 0 TO 15 DO
    k[s] := k[s] XOR k[31-s];
  FOR s := 0 TO 7 DO
    t[s] := k[s] XOR k[15-s];
END;

FUNCTION LoginToFileServer(name: NetStr; otype: WORD; passw: GenStr): BYTE;
VAR
  key : Buf8;
  id  : FourBytes;
  buf : Buf32;
  res : BYTE;

BEGIN
  UpCaseStr(passw);
  res := GetEncryptionKey(key);
  IF res = 0 THEN BEGIN
    res := MapNameToNumber(otype, name, id);
    IF res = 0 THEN BEGIN
      Shuffle(id, passw[1], Length(passw), buf);
      Encrypt(key, buf, key);
      res := LoginEncrypted(name, otype, key);
    END;
  END
  ELSE BEGIN
    res := LoginAnObject(name, otype, passw);
    END;

  LoginToFileServer := res;
END;

FUNCTION Login(Sname, OName : NetStr; OType : WORD; Passw : NetStr) : BYTE;
VAR
  sn, res, rc : BYTE;
  Curr_Server : BYTE;
BEGIN
  UpCaseStr(SName);
  sn := GetServerNumber(Sname);

  IF sn = 0 THEN BEGIN
    res := InsertServer(SName);
    IF res <> 0 THEN BEGIN
      Login := res;
      Exit;
    END;
    sn := GetServerNumber(SName);
  END;

  res := AttachServerNumber(0, sn);
  IF res <> 0 THEN BEGIN
    Login := res;
    Exit;
  END;

  Curr_Server := GetEffectiveServer;
  IF SetPreferredServer(sn) = sn THEN
    rc := LoginToFileServer(OName, Otype, Passw)
  ELSE
    rc := $7A;

  res := SetPreferredServer(Curr_Server);
  Login := rc;
END;

BEGIN
  IF ParamCount <> 3 THEN BEGIN
     Writeln('Please supply server name, your user id, and a password.');
     Exit;
     END;

  rc := Login(ParamStr(1), ParamStr(2), NET_USER, ParamStr(3));

  IF rc <> 0 THEN BEGIN
     Writeln('Login failed.');
     Exit;
     END;

  END.


