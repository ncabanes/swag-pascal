(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0099.PAS
  Description: Boot Sectors and MBR's
  Author: CAREY W. STARZINGER
  Date: 05-26-95  23:24
*)

{
> Has anyone any ideas how to interrogate an IDE drive to get
> its setup parameters, ie. number of cylinders, heads and
> sectors, as  some of the more recent BIOS's seem to be able to do?

Read cylinder 0, head 0, sector 1 which is the first sector on the
hard drive.  This sector contains the partition table.  The partition table
contains this information.  This could be done faster in ASM code but for the
interests of the purists in this echo, I will use the registers and set it up
in Pascal.  This example was used in a large program that did many other
things and that is why there is no parameter passing to the procedure and the
device is global. Sample Code to read the partition table:
}

Uses CRT, DOS;

var

   buffermbr : array[ 0 .. 512 ] of byte;  { Buffer for Master Boot Record }
   regs      : registers;   { Predefined data type }
   device    : word;
   s         : string;


Procedure readpart;

begin
     with regs do
     begin
          ah := $02;  { Read sector service request }
          al := $01;  { Number of sectors to read }
          ch := $00;  { Cylinder number or track number for floppies }
          cl := $01;  { Sector Number, bits 6,7 -two high bits of 10 bit
                        cylinder number }
          dh := $00;  { Head Number }
          dl := device; { Specifies which drive C=80h, D=81H, etc }
          es := seg( buffermbr );
          bx := ofs( buffermbr );
     end;
             intr( $13, regs )
end;

{ The below main body has been stripped of the code to verify the number of
parameters that were entered as well as the validity of the parameter string
entered ( 'c', 'd', etc. ).  }
begin
   clrscr;
   s := paramstr( 1 );
   s[ 1 ] := upcase( s[ 1 ] );
   if s[ 1 ] = 'C' then
     begin
        device := $80;
     end
   else
     begin
        device := Ord( s[ 1 ] )  - Ord( 'A' );
        if device > 1 then
           device := $80 + ( device - 2 );
     end;
     readpart;
end.
{
Partition Table Information and location:

Format of hard disk master boot record:
. Offset  Size    Description
. 000h 446 BYTEs  Master bootstrap loader code
. 1BEh 16 BYTEs   partition record for partition 1 ( Byte definition below )
. 1CEh 16 BYTEs   partition record for partition 2
. 1DEh 16 BYTEs   partition record for partition 3
. 1EEh 16 BYTEs   partition record for partition 4
. 1FEh    WORD    signature, AA55h indicates valid BIOS extension block
.
Format of partition record:
Offset  Size    Description
 00h    BYTE    boot indicator (80h = active, 00H = inactive )
 01h    BYTE    partition start head
 02h    BYTE    partition start sector (bits 0-5)
 03h    BYTE    partition start track (bits 8,9 in bits 6,7 of sector)
 04h    BYTE    operating system indicator (see below)
 05h    BYTE    partition end head
 06h    BYTE    partition end sector (bits 0-5)
 07h    BYTE    partition end track (bits 8,9 in bits 6,7 of sector)
 08h    DWORD   sectors preceding partition
 0Ch    DWORD   length of partition in sectors

        Robert, you can use whatever information you need from this table.  I
also use a routine to read the CMOS setup data but there is varience between
manufacturers and it is a lot more difficult to decode the information you are
looking for.  I just stripped this code out and have not run it as a
stand-alone program.  Let me know how it worked for you and if you need any
more assistance with it, just drop me a message.
}

