(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0007.PAS
  Description: NETINFO Unit
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:47
*)

PROGRAM NetInfo;
USES Crt, Dos;
CONST
 Redirector = $08;
 Receiver   = $80;
 Messenger  = $04;
 Server     = $40;
 AnyType    = $CC;

TYPE
 String15 = STRING[15];
 LocalDevice = ARRAY[1..16] OF Char;
 RedirDevice = ARRAY[1..128] OF Char;
 DevicePtr = ^DevInfo;
 DevInfo = RECORD
   LD : LocalDevice;
   RD : RedirDevice;
   ND : DevicePtr
 END;

VAR Done:Boolean;
    Name:String15;
    Ver:Word;
    I,Key:Integer;
    DevIn:STRING[16];
    RedIn:STRING[128];
    LDevice:LocalDevice;
    RDevice:RedirDevice;
    DeviceList,NextDevice : DevicePtr;

PROCEDURE ClrCursor;
VAR Regs : Registers;
BEGIN
 Regs.CH:=$20;
 Regs.AH:=$01;
 INTR($10,Regs);
END;

PROCEDURE SetCursor;
VAR Regs : Registers;
BEGIN
 Regs.AH:=1;
 IF LastMode <> Mono THEN
  BEGIN
   Regs.CH:=6;
   Regs.CL:=7
  END
 ELSE
  BEGIN
   Regs.CH:=12;
   Regs.CL:=13
  END;
 INTR($10,Regs);
END;

FUNCTION GetExtended : Integer;
VAR CH:Char;
BEGIN
 CH:=#0;GetExtended:=0;CH:=ReadKey;
 IF Ord(CH)=0 THEN
   BEGIN
     CH:=ReadKey;
     GetExtended:=Ord(CH)
   END
END;

FUNCTION GetFileName(S:STRING):STRING;
VAR FileName:STRING[11];
    I:Integer;
BEGIN
 FileName:='';
 I:=1;
 WHILE S[I]<>#0 DO
  BEGIN
   FileName[I]:=(S[I]);
   I:=I+1
  END;
 FileName[0]:=Chr(i-1);
 GetFileName:=FileName
END;

FUNCTION ChkNetInterface : Boolean;
VAR NetRegs:Registers;
BEGIN
 NetRegs.AH:=$00;
 INTR($2A,NetRegs);
 IF NetRegs.AH = 0 THEN ChkNetInterface:=FALSE
END;

PROCEDURE ChkPCLan;
VAR NetRegs:Registers;
    ChkType:Integer;
BEGIN
 NetRegs.AX:=$B800;
 INTR($2F,NetRegs);
 IF NetRegs.AH = 0 THEN
   WriteLn('Network Not Installed')
 ELSE
  BEGIN
   ChkType:= NetRegs.BL AND AnyType;
   IF (ChkType AND Server > 0) THEN
    WriteLn('Server')
   ELSE
   IF (ChkType AND Messenger > 0) THEN
    WriteLn('Messenger')
   ELSE
   IF (ChkType AND Receiver > 0) THEN
    WriteLn('Receiver')
   ELSE
   IF (ChkType AND Redirector > 0) THEN
    WriteLn('Redirector')
   ELSE
    WriteLn('Unknown Type')
  END
END;

FUNCTION NetName : String15;
VAR NetRegs:Registers;
    Name:ARRAY[1..15] OF Char;

BEGIN
 WITH NetRegs DO
  BEGIN
   AH:=$5E;
   AL:=$00;
   DS:=Seg(Name);
   DX:=Ofs(Name)
  END;
 MsDos(NetRegs);
 IF NetRegs.CH<>0 THEN
  NetName:=Name
 ELSE
  NetName:='NOT DEFINED'
END;

FUNCTION ChkDrive(DriveNo:Integer):Integer;
VAR DriveRegs: Registers;
BEGIN
 WITH DriveRegs DO
  BEGIN
   AH:=$44;
   AL:=$09;
   BL:=DriveNo;
   MsDos(DriveRegs);
   IF (FLAGS AND 1) = 0 THEN
    IF (DX AND $1000) = $1000 THEN
     ChkDrive := 1
    ELSE
     ChkDrive := 0
   ELSE
    ChkDrive := AX * -1
  END
END;

FUNCTION GetDevices: DevicePtr;
VAR NetRegs: Registers;
    FstDevice, CurDevice,NewDevice : DevicePtr;
    DevName: LocalDevice;
    RedName: RedirDevice;
    NextDev: Integer;
    More : Boolean;

BEGIN
More:=TRUE;
FstDevice:=NIL;
CurDevice:=NIL;
NextDev:=0;
WHILE More DO
BEGIN
 WITH NetRegs DO
  BEGIN
   AH:=$5F;
   AL:=$02;
   BX:=NextDev;
   DS:=Seg(DevName);
   SI:=Ofs(DevName);
   ES:=Seg(RedName);
   DI:=Ofs(RedName)
  END;
 MsDos(NetRegs);
 IF (NetRegs.FLAGS AND 1) = 1 THEN
  More:=FALSE
 ELSE
 BEGIN
  NEW(NewDevice);
  NewDevice^.LD:=DevName;
  NewDevice^.RD:=RedName;
  NewDevice^.ND:=NIL;
  IF (CurDevice = NIL) AND (FstDevice=NIL) THEN
    BEGIN
     CurDevice:=NewDevice;
     FstDevice:=NewDevice
    END
  ELSE
    BEGIN
     CurDevice^.ND:=NewDevice;
     CurDevice:=NewDevice
    END;
  Inc(NextDev)
 END
END;
GetDevices:=FstDevice
END;

PROCEDURE AssignDevice(DevName:LocalDevice;
                       RedName:RedirDevice);
VAR NetRegs: Registers;
    DevType: Byte;
    Dummy  : Integer;

BEGIN
IF Pos(':',DevName)=2 THEN
  DevType:=4
 ELSE
  DevType:=3;

 WITH NetRegs DO
  BEGIN
   AH:=$5F;
   AL:=$03;
   BL:=DevType;
   CX:=0;
   DS:=Seg(DevName);
   SI:=Ofs(DevName);
   ES:=Seg(RedName);
   DI:=Ofs(RedName)
  END;
 MsDos(NetRegs);
 IF (NetRegs.FLAGS AND 1) = 1 THEN
  BEGIN
   TextColor(Red);GotoXY(WhereX+6,WhereY);
   WriteLn('An Error Occurred on Assign');
   TextColor(Red+128);GotoXY(WhereX+13,WhereY);
   Write('Press Any Key');
   Dummy:=GetExtended;
   TextColor(White);
   ClrScr
  END
END;

PROCEDURE DeleteDevice(DevName:LocalDevice);
VAR NetRegs: Registers;
    Dummy  : Integer;

BEGIN
 WITH NetRegs DO
  BEGIN
   AH:=$5F;
   AL:=$04;
   DS:=Seg(DevName);
   SI:=Ofs(DevName)
  END;
 MsDos(NetRegs);
 IF (NetRegs.FLAGS AND 1) = 1 THEN
  BEGIN
   TextColor(Red);GotoXY(WhereX+6,WhereY);
   WriteLn('An Error Occurred on Delete');
   TextColor(Red+128);GotoXY(WhereX+13,WhereY);
   Write('Press Any Key');
   Dummy:=GetExtended;
   TextColor(White);
   ClrScr
  END
END;

FUNCTION SrchDevice(Drive:LocalDevice):DevicePtr;
VAR NDevice:DevicePtr;
BEGIN
 NDevice:=GetDevices;
 WHILE (NDevice <> NIL) AND
       (Copy(NDevice^.LD,1,3) <>
        Copy(Drive,1,3)) DO
  BEGIN
   NDevice:=NDevice^.ND
  END;
SrchDevice:=NDevice
END;

PROCEDURE DisplayDrives;
VAR I:Integer;
    LDevice:LocalDevice;
    NextDevice : DevicePtr;
BEGIN
 FOR I:=1 TO 26 DO
  BEGIN
   CASE ChkDrive(I) OF
    0 : BEGIN
         Write(#32,#32,Chr(64+I),':');
         GotoXY(WhereX+3,WhereY);
         WriteLn('Local')
        END;
    1 : BEGIN
         Write(#32,#32,Chr(64+I),':');
         GotoXY(WhereX+3,WhereY);
         Write('Remote');
         LDevice[1]:=Chr(64+I);
         LDevice[2]:=':';
         LDevice[3]:=#0;
         NextDevice:=SrchDevice(LDevice);
         GotoXY(WhereX+7,WhereY);
         WITH NextDevice^ DO
          WriteLn(Copy(RD,1,Pos(#0,RD)))
        END
   END
  END
END;

PROCEDURE ScrnSetup;
BEGIN
 ClrCursor;
 TextBackground(Blue);
 TextColor(White);
 ClrScr;
 GotoXY(30,2);Write('Network Status');
 TextColor(LightGray);
 GotoXY(2,5);Write('Dos Version:');
 GotoXY(21,5);Write('Network Name:');
 GotoXY(51,5);Write('Node Type:');
 TextColor(White);
 GotoXY(31,7);Write('Drive Status');
 TextColor(LightGray);
 GotoXY(20,9);Write('Drive');
 GotoXY(27,9);Write('Location');
 GotoXY(40,9);Write('Connection');
 GotoXY(15,25);Write('F1 - Assign Device');
 GotoXY(35,25);Write('F2 - Delete Device');
 GotoXY(55,25);Write('F10 - Exit');
 TextBackground(Black);
 Ver:=DosVersion;
 GotoXY(15,5);
 WriteLn(Lo(Ver),'.',Hi(Ver))
END;

PROCEDURE SetScreen(W,X,Y,Z,Back,Txt:Integer);
BEGIN
 Window(W,X,Y,Z);
 TextColor(Txt);
 TextBackground(Back);
 ClrScr
END;

BEGIN
 ScrnSetup;
 IF ChkNetInterface THEN
  BEGIN
    GotoXY(35,5); WriteLn(NetName);GotoXY(62,5);
    ChkPCLan;
    Window(20,10,60,20);ClrScr;
    DisplayDrives;
    REPEAT
     SetScreen(20,21,60,24,Blue,White);
     Key:=GetExtended;
     CASE Key OF
       59:BEGIN
           SetCursor;
           Write('Drive to Redirect  ');
           ReadLn(DevIn);
           Write('Remote Definition  ');
           ReadLn(RedIn);
           ClrCursor;
           FOR I:= 1 TO Ord(DevIn[0]) DO
            LDevice[I]:=DevIn[I];
           LDevice[Ord(DevIn[0])+1]:=#0;
           FOR I:= 1 TO Ord(RedIn[0]) DO
            RDevice[I]:=RedIn[I];
           RDevice[Ord(RedIn[0])+1]:=#0;
           AssignDevice(LDevice,RDevice)
          END;
       60:BEGIN
           Write('Drive to Delete    ');
           SetCursor;
           ReadLn(DevIn);
           ClrCursor;
           FOR I:= 1 TO Ord(DevIn[0]) DO
            LDevice[I]:=DevIn[I];
           LDevice[Ord(DevIn[0])+1]:=#0;
           DeleteDevice(LDevice)
          END
     END;
     SetScreen(20,10,60,20,Black,LightGray);
     DisplayDrives;
    UNTIL Key = 68;

  END
 ELSE
    WriteLn('NetBIOS Interface Not Available')
END.


