{
I've written a simple device driver in TP, and it works.  From some things I've
heard, it won't work in all versions of DOS (it's an .EXE format device driver,
not a .BIN format one).  There are tons of restrictions on what you can do in
it - DOS isn't reentrant, and the TP system library isn't designed to do things
while DOS is active, so I don't even let it get initialized, etc., etc.

It's still a bit of a mess, but here it is, for your enjoyment and edification:
 a character device driver that keeps a buffer of 255 characters, called
TPDEVICE.

To try it out, compile it (you'll need OPro or TPro; sorry, but stack swapping
is essential, and I wouldn't want to try to write code to do it myself), put it
into your CONFIG.SYS (on a floppy disk, please!) as

  device=tpdev.exe

and then reboot.   Hopefully you won't crash, but if you do, you'll have to
reboot from a different disk and remove it from CONFIG.SYS.

Then you can try

  COPY TPDEVICE CON

to see the initialization message, and

  ECHO This is a line for the buffer >TPDEVICE

to replace it with a new one.
}
{ DOS character device driver written entirely in TP 6 }

{ Written by D.J. Murdoch for the public domain, May 1991 }

{$S-,F-}       { Stack checking wouldn't work here, and we assume near calls }
{$M $1000,0,0} { We can't use the heap and don't use the stack.  This
                 setting doesn't really matter though, since you normally
                 won't run TPDEV }

program tpdev;

uses
  opint;  { OPro interrupt services, needed for stack switching }

procedure strategy_routine(bp:word); interrupt; forward;
procedure interrupt_routine(bp:word); interrupt; forward;

procedure header; assembler;
{ Here's the trick:  an assembler routine in the main program, guaranteed to
  be linked first in the .EXE file!!}
asm
  dd $FFFFFFFF    { next driver }
  dw $8000        { attributes of simple character device }
  dw offset strategy_routine
  dw offset interrupt_routine
  db 'TPDEVICE'
end;

const
  stDone = $100;
  stBusy = $200;

  cmInit  = 0;
  cmInput = 4;
  cmInput_no_wait = 5;
  cmInput_status  = 6;
  cmInput_flush   = 7;
  cmOutput        = 8;
  cmOutput_Verify = 9;
  cmOutput_status = 10;
  cmOutput_flush  = 11;

type
  request_header = record
    request_length : byte;
    subunit        : byte;
    command_code   : byte;
    status         : word;
    reserved       : array[1..8] of byte;
    case byte of
      cmInit : (num_units  : byte;
                first_free : pointer;
                args       : ^char;
                drive_num  : byte;);
      cmInput :  { also used for output }
               (media_descriptor : byte;
               buffer            : pointer;
               byte_count        : word);
      cmInput_no_wait : (next_char : char);
  end;

var
  local_stack  : array[1..4000] of byte;
  end_of_stack : byte;
  request      : ^request_header;
  line         : string;

procedure handler(var regs : intregisters);
{ This routine is called by the strategy routine, and handles all requests.
  The data segment is okay, and we're running on the local_stack so we've got
 plenty of space, but remember:
   ****** The initialization code for SYSTEM and all other units hasn't
          ever been called!!  ******** }
begin
  with request^ do
  begin
    case command_code of

      cmInit :
      begin
        { Last thing in the data segment in TP6 - No heap!!}
        first_free := ptr(dseg, ofs(saveint75) + 4);
        status     := stDone;
        line       := 'TPDRIVER successfully initialized.';
      end;

      cmInput :
      begin
        if byte_count > length(line) then
          byte_count := length(line);
        move(line[1], buffer^, byte_count);
        line := copy(line, byte_count + 1, 255);
        status := stDone;
      end;

      cmInput_no_wait :
      begin
        if length(line) > 0 then
        begin
          next_char := line[1];
          status := stDone;
        end
        else
          status := stBusy;
      end;

      cmInput_Status,
      cmOutput_Status,
      cmInput_Flush,
      cmOutput_Flush : status := stDone;

      cmOutput,
      cmOutput_Verify :
      begin
        if byte_count + length(line) > 255 then
          byte_count := 255 - length(line);
        move(buffer^, line[length(line) + 1], byte_count);
        line[0] := char(byte(byte_count + length(line)));
        status := stDone;
      end;
    end;
  end;
end;

procedure RetFar; assembler;
{ Replacement for the IRET code that ends the interrupt routines below }
asm
  mov sp,bp
  pop bp
  pop es
  pop ds
  pop di
  pop si
  pop dx
  pop cx
  pop bx
  pop ax
  retf
end;

procedure strategy_routine(bp : word);
var
  regs : intregisters absolute bp;
begin
  with regs do
    request := ptr(es, bx);
  RetFar;
end;

procedure interrupt_routine(bp : word);
var
  regs : intregisters absolute bp;
begin
  SwapStackandCallNear(Ofs(handler), @end_of_stack, regs);
  RetFar;
end;

begin
  writeln('TPDEVICE - DOS device driver written *entirely* in Turbo Pascal.');
  writeln('Install using DEVICE=TPDEV.EXE in CONFIG.SYS.');
  request := @header;  { Need a reference to pull in the header. }
end.
