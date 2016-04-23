{please use only on floppy.
 It reads sector 0 which is the boot sector for a floppy and
 the partition table for a hard disk.
 It never writes to disk anyways....
}
program readboot;
uses dos, crt;
type
 boot_structure = record
  jmp_instruction : array[1..3] of byte;
  oem_name : array[1..8] of char;
  bytes_per_sector : word;
  sectors_per_cluster : byte;
  reserved_sectors : word;
  fat_copies : byte;
  root_entries : word;
  total_sectors : word;
  media_descriptor : byte;
  sectors_per_fat : word;
  sectors_per_track : word;
  number_of_heads : word;
  hidden_sectors : word;
  total_sector_fixed : array[1..2] of word;
  drive_number : byte;
  reserved : byte;
  ext_boot_sig : byte;
  serial_number : array[1..2] of word;
  volume_name : array[1..11] of char;
  file_system_id : array[1..8] of char;
  boot_program_code : array[1..450] of char;
  signature_bytes : array[1..2] of byte;
 end;

var
 bootbuf : boot_structure;
 ch : char;
 arg : string;
 drive : byte;
 result : word;

{ for this procedure..  its in ASM ( doesn't make it any faster.. :)  )
  VAR BUF can either be an array, pointer or record
  DRIVE is the drive number ( A=0, B=1 etc )
  NUMBER is the number of sectors to read
  LOGICAL is the sector to which to start reading
}
procedure absread( var buf; drive : byte;
     number, logical : word ); assembler;
asm
 push bp
 push ds
 xor ax,ax
 mov result,ax
 mov al,drive
 mov cx,number
 mov dx,logical
 lds bx,buf
 int 25h       { you can change to 26h to write to disk }
 pop bx
 pop ds
 pop bp
 jnb @1
 mov result,ax
     @1:
end;


procedure commandline_help;
begin
 writeln('Usage: Readboot < drive > ');
 halt;
end;

procedure commandline;
var     regs : registers;
begin
 case paramcount of
 1 : begin
  arg := paramstr( 1 );
  ch := arg[ 1 ];
  ch := upcase( ch );
  if ch in [ #65..#90 ] then drive := ord( ch ) - 65;
  regs.AH := $36;
  regs.DL := drive + 1;
  msdos( regs );
  if regs.AX = $FFFF then
   begin
    writeln('Drive ', ch, ':\ does not exist!');
    halt;
   end;
     end;
 else    commandline_help;
 end;
end;

procedure display_boot;
begin
 with bootbuf do
 begin
  write('OEM Name......... : ':30 );
  highvideo; writeln( oem_name ); normvideo;
  write('Bytes Per Sector. : ':30 );
  highvideo; writeln( bytes_per_sector ); normvideo;
  { etc, etc.... }
 end;
end;

begin
 commandline;
 absread( bootbuf, drive, 1, 0 );
 display_boot;
end.

Here's the structure of the boot sector

{ DOS Volume Boot Sector Format [DVB]
  Offset        Size            Description
   00h          3 BYTEs         jump instruction to boot program code
   03h          8 BYTEs         OEM name and DOS version ("IBM 4.0")
   0Bh          1 WORD          bytes per sector( usually 512 )
   0Dh          1 BYTE          sectors per cluster( must be power of 2 )
   0Eh          1 WORD          reserved sectors( boot sectors - usually 1 )
   10h          1 BYTE          FAT copies ( usually 2 )
   11h          1 WORD          maximum root diretory entries ( usually 512 )
   13h          1 WORD          total sectors( if partition <= 32M, else 0 )
   15h          1 BYTE          media descriptor byte ( F8h for hard disks )
   16h          1 WORD          sectors per FAT
   18h          1 WORD          sectors per track
   1Ah          1 WORD          number of heads
   1Ch          1 DWORD         hidden sectors(if partition <= 32M,
      1 word only)

The following information is for DOS 4.0 and later version else 00h:
   20h          1 DWORD         total sectos( if partition > 32M, else 0 )
   24h          1 BYTE          physical drive number (00h=floppy, 80h=fixed)
   25h          1 BYTE          reserved( 00h )
   26h          1 BYTE          extended boot record signature( 29h )

   27h          1 DWORD         volume serial number
   2Bh          11 BYTEs        volume label("NO NAME  " stored if no label)
   36h          8 BYTEs         file system ID ("FAT12  " or "FAT16  ")

The following information applies to all DOS versions:
   3Eh          450 BYTEs       Boot program code
   1FEh         2 BYTEs         signature bytes ( 55AAh )
}

please use only on floppy.
It reads sector 0 which is the boot sector for a floppy and
the partition table for a hard disk.
It never writes to disk anyways....
It will read the boot sector from a floppy and display it.

___------------------< Cut here >-----------------------------------------
program readboot;
uses dos, crt;
type
 boot_structure = record
  jmp_instruction : array[1..3] of byte;
  oem_name : array[1..8] of char;
  bytes_per_sector : word;
  sectors_per_cluster : byte;
  reserved_sectors : word;
  fat_copies : byte;
  root_entries : word;
  total_sectors : word;
  media_descriptor : byte;
  sectors_per_fat : word;
  sectors_per_track : word;
  number_of_heads : word;
  hidden_sectors : word;
  total_sector_fixed : array[1..2] of word;
  drive_number : byte;
  reserved : byte;
  ext_boot_sig : byte;
  serial_number : array[1..2] of word;
  volume_name : array[1..11] of char;
  file_system_id : array[1..8] of char;
  boot_program_code : array[1..450] of char;
  signature_bytes : array[1..2] of byte;
 end;

var
 bootbuf : boot_structure;
 ch : char;
 arg : string;
 drive : byte;
 result : word;

{ for this procedure..  its in ASM ( doesn't make it any faster.. :)  )
  VAR BUF can either be an array, pointer or record
  DRIVE is the drive number ( A=0, B=1 etc )
  NUMBER is the number of sectors to read
  LOGICAL is the sector to which to start reading
}
procedure absread( var buf; drive : byte;
     number, logical : word ); assembler;
asm
 push bp
 push ds
 xor ax,ax
 mov result,ax
 mov al,drive
 mov cx,number
 mov dx,logical
 lds bx,buf
 int 25h       { you can change to 26h to write to disk }
 pop bx
 pop ds
 pop bp
 jnb @1
 mov result,ax
     @1:
end;


procedure commandline_help;
begin
 writeln('Usage: Readboot < drive > ');
 halt;
end;

procedure commandline;
var     regs : registers;
begin
 case paramcount of
 1 : begin
  arg := paramstr( 1 );
  ch := arg[ 1 ];
  ch := upcase( ch );
  if ch in [ #65..#90 ] then drive := ord( ch ) - 65;
  regs.AH := $36;
  regs.DL := drive + 1;
  msdos( regs );
  if regs.AX = $FFFF then
   begin
    writeln('Drive ', ch, ':\ does not exist!');
    halt;
   end;
     end;
 else    commandline_help;
 end;
end;

procedure display_boot;
begin
 with bootbuf do
 begin
  write('OEM Name......... : ':30 );
  highvideo; writeln( oem_name ); normvideo;
  write('Bytes Per Sector. : ':30 );
  highvideo; writeln( bytes_per_sector ); normvideo;
  { etc, etc.... }
 end;
end;

begin
 commandline;
 absread( bootbuf, drive, 1, 0 );
 display_boot;
end.
