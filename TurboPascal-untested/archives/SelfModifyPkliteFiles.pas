(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0014.PAS
  Description: Self Modify PKLITE files
  Author: ANTHONY GELAT
  Date: 11-02-93  10:31
*)

{
ANTHONY GELAT

>>Is it the size of the EXE File?  You can compress it With PKLite or
>>LZEXE - it'll load into memory With full size, though.  This just

>Nope, it has self modifying data.  PKLiting it wouldn't work.

 I have code For a self modifying EXE that claims to be PKLITEable,
 so i believe it can be done...here it is
}

Unit PCkSelfM;
{ Programmer: Jim Nicholson

Purpose: Implement a method For creating "self-modifying" .EXE Files from
TP which will survive the encoding techniques used by LZEXE and PKLite(tm).
For discussion and examples, see SelfMod.Pas
This Unit contains code placed into the public domain, With the following
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
provision:
Please do not distribute modified versions of this code Without indicating
such modification by commenting the File.
if you have questions, comments, modifications, or suggestions, please
feel free to contact us:

             PCkS Associates
             138 Frances Place
             Hillside, NJ 07205

             On CompuServe, EasyPlex to    70152,332
             On Delphi                     CHICKENJN
             On GENie                      J.NICHOLSON1

}

Interface

Var
  ExeFileName : String[128];

Function  ConfigBlockPresent(Size : Integer)          : Boolean;
Function  NewConfigBlock(Var C_B; Size : Integer)     : Boolean;
Function  ReadConfigBlock(Var C_B; Size : Integer)    : Boolean;
Function  ConfigBlockReWrite(Var C_B; Size : Integer) : Boolean;

Implementation

Uses
  Dos;

Const
  SelfModHeader : String[10] = 'PCkS SMODF';
  CtrlZ         : Char = ^Z;

Var
  ExeFile : File;
  Buffer  : String[10];

Function ConfigBlockPresent(Size : Integer) : Boolean;
begin
  assign(ExeFile, ExeFileName);
  reset(ExeFile, 1);
  seek(ExeFile, FileSize(ExeFile) - (SizeOf(SelfModHeader) + Size + 1));
  BlockRead(ExeFile, Buffer, SizeOf(SelfModHeader));
  if Buffer = SelfModHeader then
    ConfigBlockPresent := True
  else
    ConfigBlockPresent := False;
  close(ExeFile);
end;

Function NewConfigBlock(Var C_B; Size : Integer) : Boolean;
begin
  NewConfigBlock := False;
  if not ConfigBlockPresent(Size) then
  begin
    assign(ExeFile, ExeFileName);
    reset(ExeFile, 1);
    Seek(ExeFile, FileSize(ExeFile));
    BlockWrite(ExeFile, SelfModHeader, SizeOf(SelfModHeader));
    BlockWrite(ExeFile, C_B, Size);
    BlockWrite(ExeFile, CtrlZ, 1);
    close(ExeFile);
    NewConfigBlock := True;
  end;
end;

Function ReadConfigBlock(Var C_B; Size : Integer) : Boolean;
begin
  ReadConfigBlock := False;
  if ConfigBlockPresent(Size) then
  begin
    assign(ExeFile, ExeFileName);
    reset(ExeFile, 1);
    seek(ExeFile, FileSize(ExeFile) - (Size + 1));
    BlockRead(ExeFile, C_B, Size);
    close(ExeFile);
    ReadConfigBlock := True;
  end;
end;

Function ConfigBlockReWrite(Var C_B; Size : Integer) : Boolean;
Var
  Temp : String;
begin
  ConfigBlockReWrite := False;
  if ConfigBlockPresent(Size) then
  begin
    assign(ExeFile, ExeFileName);
    reset(ExeFile, 1);
    seek(ExeFile, FileSize(ExeFile) - (SizeOf(SelfModHeader) + Size + 1));
    BlockWrite(ExeFile, SelfModHeader, SizeOf(SelfModHeader));
    BlockWrite(ExeFile, C_B, Size);
    BlockWrite(ExeFile, CtrlZ, 1);
    close(ExeFile);
    ConfigBlockReWrite := True;
  end;
end;

begin
  ExeFileName := ParamStr(0);
end.


{--------------------------And SELFMOD.PAS, referenced above: }
Program SelfMod;

{
   This demonstrates a technique For creating self-modifying .EXE Files. It
   has an advantage over techniques which use Typed Constants, in that it will
   survive LZEXEC and PkLite(tm).

   Note that if the Program is run before LZEXEC is used to compress it, the
   compressed Program will not have been initialized. This is because LZEXEC
   strips off the config block (and everything else) at the end of the .EXE
   File. This problem does not occur With PKLite(tm).

   To run the demo, compile the Program and execute it twice. Whatever
   String you enter is written to the end of the .EXE File.

   To further demonstrate it's ablities, compress the File With PKLite(tm) or
   LZEXEC after compiling.

   Address all questions and comments to:

              PCkS Associates
              138 Frances Place
              Hillside, NJ 07205

              On CompuServe, EasyPlex to    70152,332
              On Delphi                     CHICKENJN
              On GENie                      J.NICHOLSON1


}



Uses
  PCkSelfM;

Type
  ConfigBlock = String[40];

Var
  MyConfig : ConfigBlock;

begin
  if ConfigBlockPresent(SizeOf(ConfigBlock)) then
    if ReadConfigBlock(MyConfig, SizeOf(ConfigBlock)) then
    begin
      Writeln('Old value of MyConfig: ',MyConfig);
      Write('Enter new value: ');
      readln(MyConfig);
      if ConfigBlockReWrite(MyConfig,SizeOf(ConfigBlock)) then
        Writeln('Rewrote the block.')
      else
        Writeln('ConfigBlockReWrite failed.');
    end
    else
      Writeln('ReadConfigBlock failed')
  else
  begin
    Write('Enter inital value For MyConfig: ');
    readln(MyConfig);
    if NewConfigBlock(MyConfig, SizeOf(ConfigBlock)) then
      Writeln('Created new config block')
    else
      Writeln('NewConfigBlock failed.');
  end;
end.


