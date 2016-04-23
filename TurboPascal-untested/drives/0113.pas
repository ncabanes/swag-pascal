{==========================================================================}
{ CDDrive - an interface to the CD-ROM device driver.                      }
{--------------------------------------------------------------------------}
{ Copyright (c) 1996 C.J.Rankin   CJRankin@VossNet.Co.UK                   }
{                                                                          }
{ This unit provides an elementary interface for controlling a CD-ROM      }
{ in TP6+. It has been left open-ended so that, if you wish, it can be     }
{ extended to provide a more comprehensive range of CD-ROM functions.      }
{                                                                          }
{ Note that in its current form, it will *only* recognise the first CD-ROM }
{ in the system- not a problem for most of us.                             }
{                                                                          }
{--------------------------------------------------------------------------}
{                                                                          }
{ Note: Windows 95 uses a protected mode CD-ROM driver and interface       }
{       (MSCDEX v2.95). As a result, the standard way of requesting IOCTL  }
{       functions of opening a file handle to the driver using Assign()    }
{       and Reset() and then calling DOS services AX=$4402/$4403 DOES NOT  }
{       WORK: DOS cannot open the CD-ROM driver in the DOS driver-list and }
{       so opens a new file on the hard disc instead.                      }
{                                                                          }
{==========================================================================}
{$A-,B-,D+,F-,G+,I-,L+,O+,R-,S-,V-,X+}
unit CDDrive;

interface

const
  ex_CDROMUnknownUnit       =  1;
  ex_CDROMUnready           =  2;
  ex_CDROMUnknownCommand    =  3;
  ex_CDROMCRCError          =  4;
  ex_CDROMBadReqStrucLen    =  5;
  ex_CDROMBadSeek           =  6;
  ex_CDROMUnknownMedia      =  7;
  ex_CDROMUnknownSector     =  8;
  ex_CDROMReadError         = 11;
  ex_CDROMGeneralFailure    = 12;
  ex_CDROMMediaUnavailable  = 14;
  ex_CDROMInvalidDiscChange = 15;

const
  MaxCDROM = 26;
type
  TCDROMIndex  = 1..MaxCDROM;
  TCDROMLetter = 0..MaxCDROM-1;
  TCDROMNumber = 0..MaxCDROM;

{                                                             }
{ These are the explicit CD-ROM services provided by the unit }
{                                                             }
procedure Eject;      (* Eject CD-ROM                                      *)
procedure Close;      (* Close CD-ROM tray                                 *)
procedure Lock;       (* Lock CD-ROM drive                                 *)
procedure Unlock;     (* Unlock CD-ROM drive                               *)
procedure Reset;      (* Reinitialise CD-ROM: i.e. as if disc was changed. *)
function GetNumberOfCDROMDrives: TCDROMNumber;
function GetCDROMVersion: word;

{                                                                       }
{ Templates for CD-ROM service requests. To implement another device    }
{ or IOCTL request, create a descendant object with the requisite extra }
{ fields and pass it to the appropriate requestor function.             }
{                                                                       }
type
  PDeviceRequest = ^TDeviceRequest;
  TDeviceRequest = object
                     HeaderLength: byte;
                     SubUnit:      byte;
                     CommandCode:  byte;
                     Status:       word;
                     Reserved:     array[1..8] of byte;
                   end;

  PIOCTLRequest = ^TIOCTLRequest;
  TIOCTLRequest = object
                    SubFn: byte;
                  end;

  TRequestFunc = function(var Request: TDeviceRequest): word;

{                                                                          }
{ This constitutes the interface to the driver, enabling further functions }
{ to be added if desired. The return value is the driver's Status word:    }
{ Status Word:   Bit 15: Error flag. If set then Bits 0-7 are error code   }
{                Bit  8: Request done flag.                                }
{                Bit  9: Device busy flag.                                 }
{                                                                          }
function DriverRequest_v210(var Request: TDeviceRequest): word;
function DriverBasicRequest(var Request: TDeviceRequest): word;
function IOCTLInput(var Request: TIOCTLRequest; ReqLen: word): word;
function IOCTLOutput(var Request: TIOCTLRequest; ReqLen: word): word;

{                                                                          }
{ Errors are returned in this variable: the values are explained above ... }
{                                                                          }
var CDROMError: byte;

{                                                                          }
{ DriverRequest_v210 enables CD-ROM driver requests for MSCDEX v2.10+. For }
{ earlier versions of MSCDEX, DriverBasicRequest is used instead. The      }
{ appropriate function is assigned to the following procedural variable.   }
{                                                                          }
var DriverRequest: TRequestFunc;

implementation
uses DOS;

type
  TDrvName = array[1..8] of char;

  PCDROMDriver = ^TCDROMDriver;
  TCDROMDriver = record
                   NextDriver:         PCDROMDriver;
                   DeviceAttr:         word;
                   StrategyEntryPoint: word;
                   INTEntryPoint:      word;
                   DeviceName:         TDrvName;
                   Reserved:           word;
                   DriveLetter:        TCDROMNumber;
                   Units:              byte
                 end;

  TCDROMDriveEntry = record
                       SubUnit:     byte;
                       CDROMDriver: PCDROMDriver
                     end;

type
  PDeviceIOCTLRequest = ^TDeviceIOCTLRequest;
  TDeviceIOCTLRequest = object(TDeviceRequest)
                          Media:  byte;
                          BufPtr: pointer;
                          BufLen: byte;
                        end;

type
  TCDROMLock = (CDROM_Unlocked, CDROM_Locked);

  PCDROMLockRequest = ^TCDROMLockRequest;
  TCDROMLockRequest = object(TIOCTLRequest)
                        LockStatus: TCDROMLock;
                      end;

var Regs:                Registers;
var NumberOfCDROMDrives: TCDROMNumber;
var CDROMDriveLetter:    array[TCDROMIndex] of TCDROMLetter;

var CDROMDriverStrategyEntryPoint: procedure;
var CDROMDriverINTEntryPoint:      procedure;

{                                                                         }
{ This is the interface to the CD-ROM driver. The assumption here is that }
{ we are only dealing with the first CD-ROM drive in the system- not a    }
{ problem to us mere mortals who only HAVE one CD-ROM...                  }
{                                                                         }
function DriverRequest_v210(var Request: TDeviceRequest): word;
begin
  with Regs do
    begin
      ax := $1510;
      es := Seg(Request);
      bx := Ofs(Request);
      cx := CDROMDriveLetter[1]; (* Letter of CD-ROM drive: A=0,B=1,C=2... *)
      Intr($2f,Regs)
    end;
  with Request do
    begin
      if Status and (1 shl 15) <> 0 then (* Check the error flag...*)
        CDROMError := lo(Status)         (* ... return the error   *)
      else
        CDROMError := 0;                 (* ... return `no error'  *)
      DriverRequest_v210 := Status
    end
end;

{                                                                     }
{ This method of calling CD-ROM driver functions should work for all  }
{ versions of MSCDEX. Again, assume that there is only 1 CD-ROM ...   }
{                                                                     }
function DriverBasicRequest(var Request: TDeviceRequest): word;
begin
  with Request do
    begin
      SubUnit := 0; (* Only 1 CD-ROM, so it must be driver sub-unit 0 *)
      asm
        LES BX, [BP+OFFSET Request]
      end;
      CDROMDriverStrategyEntryPoint;
      CDROMDriverINTEntryPoint;
      if Status and (1 shl 15) <> 0 then (* Check the error flag...*)
        CDROMError := lo(Status)         (* ... return the error   *)
      else
        CDROMError := 0;                 (* ... return `no error'  *)
      DriverBasicRequest := Status
    end
end;

{                                                                        }
{ The CDROM driver can be asked to do LOTS of things; the IOCTL requests }
{ are only a very small part. In theory you could descend other buffers  }
{ from TDeviceRequest, fill in the HeaderLength, CommandCode and any new }
{ fields and send them off to DriverRequest for execution...             }
{                                                                        }
function IOCTLOutput(var Request: TIOCTLRequest; ReqLen: word): word;
var
  DeviceRequestHeader: TDeviceIOCTLRequest;
begin                               (* Descendant of TDeviceRequest *)
  with DeviceRequestHeader do
    begin
      HeaderLength := SizeOf(DeviceRequestHeader);
      CommandCode := $0C;
      BufPtr := @Request.SubFn;  (* These fields added to TDeviceRequest *)
      BufLen := ReqLen           (* for IOCTL commands...                *)
    end;
  IOCTLOutput := DriverRequest(DeviceRequestHeader)
end;

function IOCTLInput(var Request: TIOCTLRequest; ReqLen: word): word;
var
  DeviceRequestHeader: TDeviceIOCTLRequest;
begin                               (* Descendant of TDeviceRequest *)
  with DeviceRequestHeader do
    begin
      HeaderLength := SizeOf(DeviceRequestHeader);
      CommandCode := $03;
      BufPtr := @Request.SubFn;  (* These fields added to TDeviceRequest *)
      BufLen := ReqLen           (* for IOCTL commands...                *)
    end;
  IOCTLInput := DriverRequest(DeviceRequestHeader)
end;

{                                                                          }
{ Yes, I COULD have just put NumberOfCDROMDrives in the interface section, }
{ except that this number is important and I don't want users `fiddling'   }
{ with it. :-)                                                             }
{                                                                          }
function GetNumberOfCDROMDrives: TCDROMNumber;
begin
  GetNumberOfCDROMDrives := NumberOfCDROMDrives
end;

{                                                                     }
{ The mechanism used to perform device driver requests depends on the }
{ version of MSCDEX, so we need a method of finding this out.         }
{                                                                     }
function GetCDROMVersion: word;
begin
  with Regs do
    begin
      bx := 0;
      ax := $150c;
      Intr($2f,Regs);
      GetCDROMVersion := bx  (* Hi byte = Major version number *)
    end                      (* Lo byte = Minor version number *)
end;

procedure Eject;
var
  Request: TIOCTLRequest;
begin
  if NumberOfCDROMDrives > 0 then
    with Request do
      begin
        SubFn := 00;   (* IOCTL command code for Eject... *)
        IOCTLOutput(Request,SizeOf(Request))
      end
end;

procedure Reset;
var
  Request: TIOCTLRequest;
begin
  if NumberOfCDROMDrives > 0 then
    with Request do
      begin
        SubFn := 02;   (* IOCTL command code to reset the CD-ROM drive *)
        IOCTLOutput(Request,SizeOf(Request))
      end
end;

procedure Close;
var
  Request: TIOCTLRequest;
begin
  if NumberOfCDROMDrives > 0 then
    with Request do
      begin
        SubFn := 05;   (* IOCTL command code to close the CD-ROM drive *)
        IOCTLOutput(Request,SizeOf(Request))
      end
end;

{
{ This routine seems to require a CD in the drive. Otherwise it returns  }
{ CDROMError = 2 (on my machine anyway...)                               }
{                                                                        }
procedure Lock;
var
  Request: TCDROMLockRequest;
begin
  if NumberOfCDROMDrives > 0 then
    with Request do
      begin
        SubFn := 01;   (* ... locking the CDROM... *)
        LockStatus := CDROM_Locked;
        IOCTLOutput(Request,SizeOf(Request))
      end
end;

procedure Unlock;
var
  Request: TCDROMLockRequest;
begin
  if NumberOfCDROMDrives > 0 then
    with Request do
      begin
        SubFn := 01;   (* ... and unlocking ... *)
        LockStatus := CDROM_Unlocked;
        IOCTLOutput(Request,SizeOf(Request))
      end
end;

{                                                                       }
{ Store the Strategy and Interrupt Entry Points for the CD-ROM device   }
{ driver... Again, assume that there is only 1 CD-ROM drive, and so     }
{ SubUnit will always = 0                                               }
{                                                                       }
procedure SetUpEntryPoints;
var
  CDDriveList: array[TCDROMIndex] of TCDROMDriveEntry;
begin
  with Regs do
    begin
      ax := $1501;
      es := Seg(CDDriveList);
      bx := Ofs(CDDriveList);
      Intr($2f,Regs)
    end;
  with CDDriveList[1] do
    begin
      @CDROMDriverStrategyEntryPoint :=
                  Ptr(Seg(CDROMDriver^),CDROMDriver^.StrategyEntryPoint);
      @CDROMDriverINTEntryPoint :=
                  Ptr(Seg(CDROMDriver^),CDROMDriver^.INTEntryPoint)

    end
end;

{                                                                          }
{ Initialisation code: neither the number of CD-ROM drives nor their drive }
{ letters will change during execution, so we shall identify the drives    }
{ NOW and not do it again.                                                 }
{                                                                          }
begin
{                                         }
{ Get number of CD-ROMs in the system ... }
{                                         }
  with Regs do
    begin
      ax := $1500;
      bx := 0;
      Intr($2f,Regs);
      NumberOfCDROMDrives := bl;
{                                                                         }
{ Get the drive-letters for CD-ROMSs... There is an MSCDEX function to do }
{ this for v2.00+, viz AX=$150D INT $2F. However we are assuming only one }
{ CD-ROM and so the drive letter has already been determined.             }
{                                                                         }
      if NumberOfCDROMDrives > 0 then
        begin
          CDROMDriveLetter[1] := cl;
{                                                                 }
{ Determine the entry points for direct device-driver requests... }
{                                                                 }
          SetUpEntryPoints;
{                                                                 }
{ Determine which mechanism to use for CD-ROM driver requests ... }
{                                                                 }
          if GetCDROMVersion < 2*256 + 10 then
            DriverRequest := DriverBasicRequest
          else
            DriverRequest := DriverRequest_v210
        end
    end
end.

{ ----------------------   DEMO PROGRAM ----------------------- }

{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,R-,S-,V-,X+}
{$M 16384,0,655360}
program CDDemo;
uses CDDrive;

var
  Version: word;
begin
  if GetNumberOfCDROMDrives = 0 then
    writeln( 'This machine has no CD-ROM drive.' )
  else
    begin
      Version := GetCDROMVersion;
      writeln( 'MSCDEX v', hi(Version), '.', lo(Version) );
      Lock;
      writeln( 'Lock: Error = ', CDROMError );
      Unlock;
      writeln( 'Unlock: Error = ', CDROMError );
      Eject;
      writeln( 'Eject: Error = ', CDROMError );
      Close;
      writeln( 'Close: Error = ', CDROMError );
      Reset;
      writeln( 'Reset: Error = ', CDROMError )
    end
end.
