(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0016.PAS
  Description: Screen Saver TSR
  Author: ANDREW KEY
  Date: 11-02-93  17:03
*)

{
From: ANDREW KEY
Subj: Screen Save
}

unit Scrnsavr;
{$F+}
(*************************************************************************)
(*                        Screen Saver                                   *)
(*                                                                       *)
(*  Written by Jay A. Key -- Oct 1993                                    *)
(*  Code may be modified and used freely.  Please mention my name        *)
(*  somewhere in your docs or in the program itself.                     *)
(*                                                                       *)
(*  Self contained unit to install a text-mode screen saver in Turbo     *)
(*  Pascal programs.  Simply include the following line in your code.    *)
(*    uses ScrnSavr;                                                     *)
(*                                                                       *)
(*  It will initialize itself automatically, and will remove itself      *)
(*  upon exit from your program, graceful exit or not.  Functions        *)
(*  SetTimeOut and SetDelay are included if you wish to modify the       *)
(*  default values.                                                      *)
(*                                                                       *)
(*  Warning: will not properly save and restore screens while running    *)
(*  under the Turbo Pascal IDE.  Runs great from DOS.                    *)
(*************************************************************************)

interface

uses Dos,Crt;

function NumRows: byte;          {Returns number of rows in current screen}
function ColorAdaptor: boolean;  {TRUE if color video card installed}
procedure SetTimeOut(T: integer); {Delay(seconds) before activation}
procedure SetDelay(T: integer);  {Interval between iterations}

(************************************)

implementation

type
  VideoArray = array[1..2000] of word;  {buffer to save video screen}

var
  Timer: word;
  Waiting: boolean;
  OldInt15,                  {Keyboard interrupt}
  OldInt1C,                  {Timer interrupt}
  OldInt23,                  {Cntl-C/Cntl-Break handler}
  ExitSave: pointer;
  Position, Cursor: integer; {save and restore cursor positions}
  VideoSave: VideoArray;
  VideoMem: ^VideoArray;
  TimeOut, Delay: integer;

procedure JumpToPriorIsr(p: pointer);
{Originally written by Brook Monroe, "An ISR Clock", pg. 64,
 PC Techniques Aug/Sep 1992}
  inline($5b/$58/$87/$5e/$0e/$87/$46/$10/$89/$ec/$5d/$07/$1f/
         $5f/$5e/$5a/$59/$cb);

function ColorAdaptor: boolean; assembler;
  asm
    int 11                   {BIOS call - get equipment list}
    and al,$0010             {mask off all but bit 4}
    xor al,$0010             {flip bit 4 - return val is in al}
  end;

function NumRows: byte; assembler;  {returns number of displayable rows}
  asm
    mov ax,$40
    mov es,ax
    mov ax,$84
    mov di,ax
    mov al,[es:di]           {byte at [$40:$84] is number of rows in display}
  end;

procedure HideCursor; assembler;
  asm
    mov ah,$03
    xor bh,bh
    int $10               {video interrupt}
    mov Position,dx       {save cursor position}
    mov Cursor,cx         {and type}
    mov ah,$01
    mov ch,$20
    int $10               {video interrupt - hide cursor}
  end;

procedure RestoreCursor; assembler;
  asm
    mov ah,$02
    xor bh,bh
    mov dx,Position       {get old position}
    int $10               {video interrupt - restore cursor position}
    mov cx,Cursor         {get old cursor type}
    mov ah,$01
    int $10               {video interrupt - restore cursor type}
  end;

procedure RestoreScreen;
  begin
    VideoMem^ := VideoSave;  {Copy saved image back onto video memory}
    RestoreCursor;
  end;

procedure SaveScreen;
  begin
    VideoSave := VideoMem^;  {Copy video memory to array}
    HideCursor;
  end;

procedure DispMsg;  {simple stub-out for displaying YOUR message(s),
                     pictures, etc...use your imagination!!!}
  begin
    ClrScr;
    GotoXY(random(50),random(23));
    writeln('This would normally be something witty!');
  end;

procedure NewInt15(Flags,CS,IP,AX,BX,CX,DX,
                   SI,DI,DS,ES,BP:WORD); interrupt; {keyboard handler}
  begin
    Timer:=0;                     {Reset timer}
    if Waiting then               {Screen saver activated?}
      begin
        RestoreScreen;            {Restore saved screen image}
        Waiting:= FALSE;          {De-activate screen saver}
        Flags:=(Flags and $FFFE); {Tell BIOS to ignore current keystroke}
      end
    else
      JumpToPriorISR(OldInt15);   {call original int 15}
  end;

procedure NewInt1C; interrupt;    {timer interrupt}
  begin
    Inc(Timer);                   {Increment timer}
    if Timer>TimeOut then         {No key hit for TimeOut seconds?}
      begin
        Waiting := TRUE;          {Activate screen saver}
        SaveScreen;               {Save image of video memory}
        DispMsg;                  {Display your own message}
        Timer := 0;               {Reset timer}
      end;
    if waiting then               {Is saver already active?}
      begin
        if Timer>Delay then       {Time for next message?}
          begin
            Timer := 0;           {Reset timer}
            DispMsg;              {Display next message}
          end;
      end;
    JumpToPriorISR(OldInt1C);     {Chain to old timer interrupt}
  end;

procedure ResetIntVectors;        {Restores Intrrupt vectors to orig. values}
  begin
    SetIntVec($15,OldInt15);
    SetIntVec($1C,OldInt1C);
    SetIntVec($23,OldInt23);
  end;

procedure NewInt23; interrupt;    {Called to handle cntl-c/brk}
  begin
    ResetIntVectors;              {Restore old interrupt vectors}
    JumpToPriorISR(OldInt23);     {Chain to original int 23h}
  end;

procedure MyExit; far;            {exit code for unit}
  begin
    ResetIntVectors;              {Restore old interrupt vectors}
    ExitProc:=ExitSave;           {Restore old exit code}
  end;

procedure SetVideoAddress;        {Returns pointer to text video memory}
  begin
    if ColorAdaptor then
      VideoMem := ptr($B000,$0000)
    else
      VideoMem := ptr($B800,$0000);
  end;

procedure SetTimeOut(T: integer); {Set delay(seconds) before activation}
  begin
    TimeOut:=Round(T*18.2);
  end;

procedure SetDelay(T: integer);  {Set interval between iterations}
  begin
    Delay:=Round(T*18.2);
  end;

{Initialize unit}
begin
  SetVideoAddress;             {Set up address for video memory}
  Waiting := FALSE;            {Screen saver initially OFF}
  Timer := 0;                  {Reset timer}
  ExitSave := ExitProc;        {Save old exit routine}
  ExitProc := @MyExit;         {Install own exit routine}
{Install user defined int vectors}
  GetIntVec($15,OldInt15);     {Keyboard handler}
  SetIntVec($15,@NewInt15);
  GetIntVec($1c,OldInt1C);     {Timer int}
  SetIntVec($1c,@NewInt1C);
  GetIntVec($23,OldInt23);     {Cntl-C/Brk handler}
  SetIntVec($23,@NewInt23);
  SetTimeOut(120);
  SetDelay(15);
end.


