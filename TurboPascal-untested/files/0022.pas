{
MARCO MILTENBURG

> Currently I'm writing a Program which must be able to handle multitask
> evironments. But as I'm trying to Write a Record which is open in another
> Window (of DesqView for instance) than a runtime error 5 appears. Seems
> logical. But how do I 'lock' the Record, what are the attibutes, and what
> must the Program do if it can't open a Record???

      Locking isn't that difficult... First of all, do you have to keep the
File available For anybody else (in another task) or not. if not, use the
Filesharing bits when you're opening the File. They are :

bit 0-2   = 000 - read permission For your own appliction
            001 - Write permission For you own application
            010 - both read and Write permission For you own application

bit 3     = 0   - Always zero!

bit 4-6   = 000 - compatibilty mode. Share the File whenever possible.
            001 - reading and writing not allowed For other applications
            010 - writing not allowed For other applications (usefull when
                  you're gonna read the File, so others can not update it)
            011 - reading not allowed For other applications (usefull when
                  you're gonna update the File and others may not read it).
            100 - Full access For other applications (dangerous in my point of
                  view!).

bit 7     = 0   - Lower process owns File
            1   - File only For current process.

Set the bits to your needs and assign the value to FileMode before opening the
File. For example, I want to read a File which must be locked completly. Is
must use the value 00010000b which is $10. So use FileMode = $10 before opening
the File. Please note that FileMode only take affect on Files which are
declared as ': File' or ': File of ....'. It's not supported on ': Text' Files.
if you want to lock these Files, use the next method.

if you only want to lock a single Record of a File (or an entier File) you can
use the following Function :


Ooh BTW: This will only work With Dos 3.0+ (of course ;-) With SHARE loaded.
}

Function FileLocking(Action     : Byte;
                     Handle     : Word;
                     Start, end : LongInt) : Boolean;
Var
  Regs : Registers;
begin
  Regs.AH := $5C;
  Regs.AL := Action;
  Regs.BX := Handle;
  Regs.CX := Hi(Start);
  Regs.DX := Lo(Start);
  Regs.DI := Lo(end);
  Regs.SI := Hi(end);
  Intr($21, Regs);
  FileLocking := ((Regs.FLAGS and $01) = 0);
end;

{
Use For Action '0' to lock or '1' to unlock the File. The funtion returns True
when succesfull. The Handle Variable must contain the Filehandle, assigned by
Dos. For TextFiles you can obtain this handle With :

  TextRec(T).Handle

where T is the TextFile (declared With T : Text). I don't know how to obtain
the Filehandle of another FileType at the moment. I will have to look For it.
Start and end contain the starting and ending position (in Bytes) from what you
want to lock (for Typed Files, they can easaly be calculated using FilePos and
SizeOf(....Record) etc..). if you want to lock the entire File, use 0 For start
and $FFFFFFFF For end. Locking beyond the end of the File doesn't result in an
error!
}
