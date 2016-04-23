Unit CD;

{----------------------------------------------------------------------------}

{  CD : An implementation of a CD-ROM driver.                                }

{****************************************************************************}

{  Author            : Menno Victor van der star                             }

{  E-Mail            : s795238@dutiwy.twi.tudelft.nl                         }

{  Developed on      : 08-06-'95                                             }

{  Last update on    : 07-09-'95                                             }

{  Status            : Finished                                              }

{  Future extensions : None                                                  }

{----------------------------------------------------------------------------}

{$R-}

Interface



Uses Dos;



Type

  CDRomParametersRecord = Record

                            Raw : Boolean;

                            SectorSize : Word;

                            NumberOfSectors : LongInt;

                          End;



  CDRomPositionInfo = Record

                        CntAdr : Byte;

                        CTrk   : Byte;

                        Cindx  : Byte;

                        CMin   : Byte;

                        CSek   : Byte;

                        CFrm   : Byte;

                        Czero  : Byte;

                        CAmin  : Byte;

                        CAsec  : Byte;

                        CAFrm  : Byte;

                      End;



  CDRom = Object



            ValidCDRoms : String;

            Error : Word;

            CDRomDevice : Text;



            Constructor Init;

            Destructor  Done; Virtual;



            Procedure   ChangeDrive (DriveLetter : Char);

            Procedure   OpenDoor;

            Procedure   CloseDoor;

            Procedure   LockDoor;

            Procedure   UnlockDoor;

            Procedure   Reset;

            Function    DriveStatus : Word;

            Procedure   GetDriveParameters (Var Parameters : CDRomParametersRecord);

            Procedure   GetPosition (Var Position : CDRomPositionInfo);



            Procedure   PlayAudio (MinuteStart, SecondStart, MinuteEnd, SecondEnd : Byte);

            Procedure   PlayTrack (TrackNr : Byte);

            Procedure   PausePlay;

            Procedure   ResumePlay;

            Function    NumberOfAudioTracks : Byte;



          Private



            Regs : Registers;

            MSCDEXVerMajor, MSCDEXVerMinor : Byte;

            NumCDRoms : Byte;

            DriverNames : Array ['A'..'Z'] Of Record

                                                SubunitNr : Byte;

                                                Name : String[8];

                                              End;

            CurrentDrive : Char;



            Function    DeviceCommand (CommandNr, DosFunction : Word; Var Data) : Word;

            Function    RedBookToHSG (Minute, Second, Frame : Byte) : LongInt;



          End;



Implementation



Type

  PCharArray = ^CharArray;

  CharArray = Array [0..0] Of Char;



Constructor CDRom.Init;



Var

  n : Word;

  c, c2 : Char;

  DeviceInfo : Array ['A'..'Z'] Of Record

                                     SubunitNr : Byte;

                                     NamePtr : PCharArray;

                                   End;

Begin

  Regs.ax:=$1100;             { MSCDEX Installed? }

  Intr ($2F,Regs);

  If Regs.al<>255 then Fail;  { MSCDEX Not installed, fail to construct }



  Regs.AX:=$150C;            { Get MSCDEX version }

  Intr ($2F,Regs);

  MSCDEXVerMajor:=Regs.BH;

  MSCDEXVerMinor:=Regs.BL;

  { Only work with versions 2.1 or higher }

  If (MSCDEXVerMajor<2) Or ((MSCDEXVerMajor=2) And (MSCDEXVerMinor < 10)) then Fail;



  Regs.AX:=$1500;             { get number of cdrom's }

  Regs.BX:=0;

  Intr ($2F,Regs);

  NumCDRoms:=Regs.BX;

  If NumCDRoms=0 then Fail;   { No cdroms present, fail to construct }



  Regs.AX:=$150D;

  Regs.ES:=Seg (ValidCDRoms[1]);

  Regs.BX:=Ofs (ValidCDRoms[1]);

  Intr ($2F,Regs);

  ValidCDRoms[0]:=Chr (NumCDRoms);

  For n:=1 to Length (ValidCDRoms) Do ValidCDRoms[n]:=Chr (Ord (ValidCDRoms[n])+65);

  For c:='A' to 'Z' Do Begin

    DriverNames[c].Name:='';

    DriverNames[c].SubunitNr:=0;

    DeviceInfo[c].SubunitNr:=0;

    DeviceInfo[c].NamePtr:=NIL;

  End;

  Regs.AX:=$1501;

  Regs.ES:=Seg (DeviceInfo);

  Regs.BX:=Ofs (DeviceInfo);

  Intr ($2f,Regs);

  c2:='A';

  For c:='A' to 'Z' Do Begin

    Regs.AX:=$150B;

    Regs.CX:=Ord (c)-65;

    Intr ($2F,Regs);

    If (Regs.AX>0) And Assigned (DeviceInfo[c2].NamePtr) then Begin

      n:=10;

      While (n<=17) And (DeviceInfo[c2].NamePtr^[n]<>' ') Do Begin

        DriverNames[c].Name:=DriverNames[c].Name+DeviceInfo[c2].NamePtr^[n];

        Inc (n);

      End;

      DriverNames[c].SubunitNr:=DeviceInfo[c2].SubunitNr;

      If c2='A' then ChangeDrive (c);

      Inc (c2);

    End

  End;

  Reset;

End;



Destructor CDRom.Done;



Begin

  Close (CDRomDevice);

End;



Procedure CDRom.ChangeDrive (DriveLetter : Char);



Begin

  If DriverNames[DriveLetter].Name='' then Exit;

  Assign (CDRomDevice,DriverNames[DriveLetter].Name);

  System.Reset (CDRomDevice);

  CurrentDrive:=DriveLetter;

End;



Procedure CDRom.OpenDoor;



Var

  Data : Byte;



Begin

  Data:=0;

  Error:=DeviceCommand (1,$4403,Data);

End;



Procedure CDRom.CloseDoor;



Var

  Data : Byte;



Begin

  Data:=5;

  Error:=DeviceCommand (1,$4403,Data);

  Reset;

End;



Procedure CDRom.LockDoor;



Var

  Data : Word;



Begin

  Data:=$0001;

  Error:=DeviceCommand (2,$4403,Data);

End;



Procedure CDRom.UnlockDoor;



Var

  Data : Word;



Begin

  Data:=$0101;

  Error:=DeviceCommand (2,$4403,Data);

  Reset;

End;



Procedure CDRom.Reset;



Var

  Data : Byte;



Begin

  Data:=2;

  Error:=DeviceCommand (1,$4403,Data);

End;



Function CDRom.DriveStatus : Word;



Var

  Data : Record Command : Byte; Status : Word; Dummy2 : Word; End;



Begin

  Data.Command:=6;

  Error:=DeviceCommand (5,$4402,Data);

  DriveStatus:=Data.Status And 2047;

{  Reset; }

End;



Procedure CDRom.GetDriveParameters (Var Parameters : CDRomParametersRecord);



Var

  Data1 : Record Command, Raw : Byte; SectorSize : Word; End;

  Data2 : Record Command : Byte; NumberOfSectors : LongInt; End;



Begin

  Data1.Command:=7;

  Error:=DeviceCommand (4,$4402,Data1);

  Data2.Command:=8;

  Error:=DeviceCommand (5,$4402,Data2);

  Parameters.Raw:=Data1.Raw=1;

  Parameters.SectorSize:=Data1.SectorSize;

  Parameters.NumberOfSectors:=Data2.NumberOfSectors;

End;



Procedure CDRom.GetPosition (Var Position : CDRomPositionInfo);



Var

  Data : Record

           Command : Byte;

           Info : CDRomPositionInfo;

         End;



Begin

  Data.Command:=12;

  Error:=DeviceCommand (129,$4402,Data);

  Position:=Data.Info;

End;



Procedure CDRom.PlayAudio (MinuteStart, SecondStart, MinuteEnd, SecondEnd : Byte);



Var

  HSGAddress1, HSGAddress2 : LongInt;

  Data : Record

           Bytes : Array [0..13] Of Byte;

           HSGAddress : LongInt;

           NumberOfFrames : LongInt;

         End;



Begin

  HSGAddress1:=RedBookToHSG (MinuteStart, SecondStart, 0);

  HSGAddress2:=RedBookToHSG (MinuteEnd, SecondEnd, 0);



  Data.Bytes[0]:=$16;

  Data.Bytes[1]:=DriverNames[CurrentDrive].SubunitNr;

  Data.Bytes[2]:=$84;

  Data.Bytes[13]:=0;

  Data.HSGAddress:=HSGAddress1;

  Data.NumberOfFrames:=HSGAddress2-HSGAddress1;



  Regs.ES:=Seg (Data);

  Regs.BX:=Ofs (Data);

  Regs.CX:=Ord (CurrentDrive)-65;

  Regs.AX:=$1510;

  Intr ($2F,Regs);

End;



Procedure CDRom.PlayTrack (TrackNr : Byte);



Var

  Track1 : Record

            Command, TrackNr : Byte;

            RedBookAdress : Record

                              Frame,

                              Second,

                              Minute,

                              Dummy : Byte;

                            End;

            TrackControl : Word;

            HSGAddress : LongInt;

          End;

  Track2 : Record

            Command, TrackNr : Byte;

            RedBookAdress : Record

                              Frame,

                              Second,

                              Minute,

                              Dummy : Byte;

                            End;

            TrackControl : Word;

            HSGAddress : LongInt;

          End;

  Data : Record

           Bytes : Array [0..13] Of Byte;

           HSGAddress : LongInt;

           NumberOfFrames : LongInt;

         End;

  NumberOfTracks : Byte;



Begin

  NumberOfTracks:=NumberOfAudioTracks;

  Track1.Command:=$0B;

  Track1.TrackNr:=TrackNr;

  Error:=DeviceCommand (8,$4402,Track1);

  Track1.HSGAddress:=RedBookToHSG (Track1.RedBookAdress.Minute,

                                   Track1.RedBookAdress.Second,

                                   Track1.RedBookAdress.Frame);

  If Track1.TrackControl And 16384<>0 then Exit;

  Track2.Command:=$0B;

  Track2.TrackNr:=TrackNr+1;

  Error:=DeviceCommand (8,$4402,Track2);

  Track2.HSGAddress:=RedBookToHSG (Track2.RedBookAdress.Minute,

                                   Track2.RedBookAdress.Second,

                                   Track2.RedBookAdress.Frame);

  Data.Bytes[0]:=$16;

  Data.Bytes[1]:=DriverNames[CurrentDrive].SubunitNr;

  Data.Bytes[2]:=$84;

  Data.Bytes[13]:=0;

  Data.HSGAddress:=Track1.HSGAddress;

  Data.NumberOfFrames:=Track2.HSGAddress-Track1.HSGAddress;



  Regs.ES:=Seg (Data);

  Regs.BX:=Ofs (Data);

  Regs.CX:=Ord (CurrentDrive)-65;

  Regs.AX:=$1510;

  Intr ($2F,Regs);

End;



Procedure CDRom.PausePlay;



Var

  Data : Array [0..12] Of Byte;



Begin

  Data[0]:=$0D;

  Data[1]:=DriverNames[CurrentDrive].SubunitNr;

  Data[2]:=$85;

  Regs.ES:=Seg (Data);

  Regs.BX:=Ofs (Data);

  Regs.CX:=Ord (CurrentDrive)-65;

  Regs.AX:=$1510;

  Intr ($2F,Regs);

End;



Procedure CDRom.ResumePlay;



Var

  Data : Array [0..12] Of Byte;



Begin

  Data[0]:=$0D;

  Data[1]:=DriverNames[CurrentDrive].SubunitNr;

  Data[2]:=$88;

  Regs.ES:=Seg (Data);

  Regs.BX:=Ofs (Data);

  Regs.CX:=Ord (CurrentDrive)-65;

  Regs.AX:=$1510;

  Intr ($2F,Regs);

End;



Function CDRom.NumberOfAudioTracks : Byte;



Var

  Data : Record Command : Byte; FirstTrack, LastTrack : Byte; Dummy : LongInt; End;



Begin

  Data.Command:=$0A;

  Error:=DeviceCommand (7,$4402,Data);

  NumberOfAudioTracks:=Data.LastTrack-Data.FirstTrack+1;

End;



Function CDRom.DeviceCommand (CommandNr, DosFunction : Word; Var Data) : Word;



Begin

  Regs.BX:=TextRec (CDRomDevice).Handle;

  Regs.DS:=Seg (Data);

  Regs.DX:=Ofs (Data);

  Regs.CX:=CommandNr;

  Regs.AX:=DosFunction;

  MsDos (Regs);

  If Regs.Flags And fCarry=0 then

    DeviceCommand:=0

  Else

    DeviceCommand:=Regs.AX;

End;



Function CDRom.RedBookToHSG (Minute, Second, Frame : Byte) : LongInt;



Begin

  RedBookToHSG:=(LongInt (Minute)*4500)+(LongInt (Second)*75)+Frame-183;

End;



End.