(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0027.PAS
  Description: Loading a file on HEAP
  Author: GUY MCLOUGHLIN
  Date: 08-27-93  21:32
*)

{
GUY MCLOUGHLIN

>How would I load a file straight into memory, and access it directly
>using pointers?

Load file data onto the HEAP memory-pool.
}

program LoadFileOnHEAP;

type
  { Array type used to define the data buffer. }
  arby_60K   = array[1..61440] of byte;
  { Pointer type used to allocate the data buffer on the HEAP memory pool. }
  po_60KBuff = ^arby_60K;

const
  { Buffer size in bytes constant. }
  co_BuffSize = sizeof(arby_60K);

{ Check for IO errors, close data file if necessary. }
procedure CheckForErrors(var fi_Temp : file; bo_CloseFile : boolean);
var
  by_Temp : byte;
begin
  by_Temp := ioresult;
  if (by_Temp <> 0) then
  begin
    writeln('FILE ERROR = ', by_Temp);
    if bo_CloseFile then
      close(fi_Temp);
    halt(1)
  end
end;

var
  wo_BuffIndex,
  wo_BytesRead : word;
  po_Buffer    : po_60KBuff;
  fi_Temp      : file;

BEGIN
  assign(fi_Temp, 'EE.PAS');
  {$I-}
  reset(fi_Temp, 1);
  {$I+}
  CheckForErrors(fi_Temp, false);

  { Check if there is enough free memory on the HEAP. }
  { If there is, then allocate buffer on the HEAP. }
  if (maxavail > co_BuffSize) then
    new(po_Buffer)
  else
  begin
    close(fi_Temp);
    writeln('ERROR: Insufficient HEAP memory!')
  end;

  { Load file-data into buffer. }
  blockread(fi_Temp, po_Buffer^, co_BuffSize, wo_BytesRead);
  CheckForErrors(fi_Temp, true);

  { Display each byte that was read-in. }
  for wo_BuffIndex := 1 to wo_BytesRead do
    write(chr(po_Buffer^[wo_BuffIndex]));

  close(fi_Temp)
END.

