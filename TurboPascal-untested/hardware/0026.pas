{
  This is a complete map of PC, XT, AT, PS/2 and EGA-installed data
  areas between 0400h and 0500h in the low memory segment put into the
  form of a Turbo Pascal 4/5/5.5 compatible unit.

  I found myself needing one or two of these absolute addresses from time
  to time and got tired of looking them up. Using a record structure
  declared as absolute variable relieves you of specifying the
  individual addresses for each variable, providing that all the Resrved
  areas are included too.

  I hope this saves all those Turbo Pascal programmers out there some time
  and lets them get on with the creative side of the business. Enjoy!

  David Gwillim
  159 Woodbury Road
  Hicksville, NY 11801-3030
  (516) 942-8697

  6 August 1989

  CREDITS:

  The absolute addresses for this unit came from "The Programmer's PC
  Sourcebook" by Thom Hogan, published by Microsoft Press.
  ISBN 1-55615-118-7. List price $24.95 USA.

  This book is very helpful (apart from a few inevitable) typos). I
  consider it an essential purchase for any programmer who has to deal
  with a PC at the hardware level.

}

unit Bios;

interface

var
   BiosSeg : record
      ComBase : array[1..4] of word;
      LptBase : array[1..4] of word;
      InstalledHardware : array[1..2] of byte;
      POST_Status : byte;      { Convertible only }
      MemorySize : word;
      _RESERVED1 : word;
      KeyboardControl : array[1..2] of byte;
      AlternateKeypadEntry : byte;
      KeyboardBufferHeadPtr : word; { points to first char in type-ahead buffer }
      KeyboardBufferTailPtr : word; { points to last char in type-ahead buffer }
      KeyboardBuffer : array[1..16] of word;
      FloppyRecalStatus : byte;
      FloppyMotorStatus : byte;
      FloppyMotorOffCounter : byte;
      FloppyPrevOpStatus : byte;
      FloppyControllerStatus : array[1..7] of byte;
      DisplayMode : byte;
      NumberOfColumns : word;
      RegenBufferLength : word;
      RegenBufferAddress : word;
      CursorPosition : array[1..8] of word;
      CursorType : word;
      CurrentDisplayPage : byte;
      VideoControllerBaseAddress : word;
      Current3x8Register : byte;
      Current3x9Register : byte;
      PointerToResetCode : pointer;  { PS/2 only - except model 30 }
      _RESERVED2 : byte;
      TimerCounter : longint;
      TimerOverflowFlag : byte;  { non-zero means timer passed 24 hours }
      BreakKeyState : byte;
      ResetFlag : word;  { $1234=bypass mem test; $4321=preserve mem (PS/2) }
                         { $5678=system supended (Convertible) }
                         { $9ABC=manufacturing test (Convertible) }
                         { $ABCD=system POST loop (Convertible only) }
      FixedDiskPrevOpStatus : byte;
      NumberOfFixedDrives : byte;
      FixedDiskDriveControl : byte;   {XT only}
      FixedDiskControllerPort : byte; {XT only}
      LptTimeOut : array[1..4] of byte;  { [4] valid for PC, XT and AT only }
      ComTimeOut : array[1..4] of byte;
      KeyboardBufferStartOffsetPtr :word;
      KeyboardBufferEndOffsetPtr :word;
      VideoRows : byte;
      CharacterHeight : word;  { bytes per character }
      VideoControlStates : array[1..2] of byte;

      _RESERVED3 : word;
      MediaControl : byte;
      FixedDiskControllerStatus : byte; { AT, XT after 1/10/85, PS/2 only }
      FixedDiskControllerErrorStatus : byte; { AT, XT after 1/10/85, PS/2 only }
      FixedDiskInterruptControl : byte; { AT, XT after 1/10/85, PS/2 only }
      _RESERVED4 : byte;
      DriveMediaState : array[0..1] of byte;
      _RESERVED5 : word;
      DriveCurrentCylinder : array[0..1] of byte;
      KeyboardModeState : byte;
      KeyboardLEDflags : byte;
      UserWaitCompleteFlagAddress : pointer;
      UserWaitCount : longint;   { micro-seconds }
      WaitActiveFlag : byte;
      _RESERVED6 : array[1..7] of byte;
      VideoParameterTable : pointer;          { EGA and PS/2 only }
      DynamicSaveArea : pointer;              { EGA and PS/2 only }
      AlphaModeAuxCharGenerator : pointer;    { EGA and PS/2 only }
      GraphicsModeAuxCharGenerator : pointer; { EGA and PS/2 only }
      SecondarySaveArea : pointer;            { PS/2 only (not Model 30) }
      _RESERVED7 : array[1..4] of byte;
      _RESERVED8 : array[1..64] of byte;
      PrintScreenStatus : byte;
   end absolute $0040:$0000;

implementation

end.



