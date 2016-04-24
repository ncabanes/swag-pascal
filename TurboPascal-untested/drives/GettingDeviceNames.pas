(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0085.PAS
  Description: Getting Device Names
  Author: JOSEPH METCALF
  Date: 11-26-94  04:56
*)

{
From: regis@alpha2.csd.uwm.edu (Joseph William Metcalf)

There are been a couple posts looking for a way to read the device name for
CD audio play functions, so here it is (tested under TP7):
}

type DRIVELIST=Record
               unitcode:byte;
               doffset,dsegment:word;
               end;

var
  CDDL:DriveList;

function GetDriverName:string;
var
  CDNTemp:array[1..18] of byte;
  where:pointer;
  count:byte;
  CDSTemp:string[8];
begin
  asm
    mov ax,1501h
    mov bx,OFFSET CDDL
    mov dx,SEG CDDL
    mov es,dx
    int 2fh
  end;
  where:=ptr(CDDL.dsegment,CDDL.doffset);
  move(where^,CDNTEMP,18);
  count:=1;
  repeat
    CDStemp[count]:=chr(cdntemp[10+count]);
    inc(count);
  until (count>8) or (cdntemp[10+count]=32);
  cdstemp[0]:=chr(count-1);
 getdrivername:=cdstemp;
end;
{
This uses the MSCDEX function 1501h (Int 2fh) to read the drivelist and
segment/offset of the device driver header. Device name is 10 bytes into the
header, max 8 characters, padded with spaces if the name is less than 8
characters.
}
begin
  Writeln(GetDriverName);
end.
