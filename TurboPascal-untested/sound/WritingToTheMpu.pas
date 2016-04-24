(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0068.PAS
  Description: Writing to the MPU
  Author: GERHARD DALENOORT
  Date: 05-26-95  23:21
*)

{
At least after a months search, I found a source to acces a MPU-401 type
interface on a SoundBlaster (compatible) card... The source was kind a
spaghetti but I managed to destill the main components...

The original procs lost some bytes on the way from the MPU thru the procs
and bufs to your var. The original though included command modes for the
MPU's UART. For the complete source of the MFC/MPU unit please mail me..

here're the basic procs to get and write a byte to MIDI...
the original was about 1300 lines so....
}

Program Just_A_Small_One_To_ShowOff_MPU_use;

Const
  DataPort   = $330;
  StatusPort = DataPort + 1;
  cmd_uart   = $3f;                      {Basic serial i/o mode}
  cmd_reset  = $ff;                      {Reset MPU}

Function MPUread : Boolean;  { MPU is ready to let READ a byte FROM MIDI }
 begin MPUread:= (Port[StatusPort] and $80) = 0; end;
{ Q: Should I make this: Repeat until Port.. and $80=0, or is this fine ??}

Function MPUwrite : Boolean;  { MPU is ready to let WRITE a byte TO MIDI }
 begin MPUwrite:= (port[StatusPort] and $40) = 0; end;

Procedure SendNoteOn( MidiChannel, Note, Velocity : Integer);
{ Sends NoteOn on MidiChannel 0..15, Velocity 0 is noteOff  }
begin
 if MPUwrite then Port[DataPort]:=$90+ MidiChannel;
 if MPUwrite then Port[DataPort]:=Note;
 if MPUwrite then Port[DataPort]:=velocity;
end;

Function KeyPressed : Boolean; Assembler;
Asm  mov ah, 01h;int 16h;mov ax, 00h;jz @1;inc ax;@1:;end; {Tnx to the SWAG}

Var
  X : Integer;

begin
 Port[StatusPort]:=Cmd_reset;  { Initialization }
 Port[StatusPort]:=Cmd_uart;   { of the MPU-type Interface }

 repeat
  {A SoftWare MIDI-THRU function }
    If MPUread then            {Ready to Read}
    begin
       X:=Port[DataPort];      {Read Byte}
       if MPUwrite then        {Ready To Write}
            Port[DataPort]:=X; {Write the byte}
       WriteLn(X);             {see what past the MPU-401 Type o' interface}
    end;
 until KeyPressed;
end.

