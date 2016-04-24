(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0022.PAS
  Description: Yet Another Volume Label
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:38
*)

{
>I am having difficulty changing a disk volume Label using Turbo Pascal.
>Does anyone know how to acComplish this?
}
Uses
  Dos;

Type fcbType = Record
                 drive   : Byte;
                 name    : Array[1..8] of Char;
                 ext     : Array[1..3] of Char;
                 fpos    : Word;
                 recsize : Word;
                 fsize   : LongInt;
                 fdate   : Word;
                 ftime   : Word;
                 reserv  : Array[1..8] of Byte;
                 currec  : Byte;
                 relrec  : LongInt;
               end;
     extfcb =  Record
                 flag    : Byte;                  { must be $ff! }
                 reserv  : Array[1..5] of Byte;
                 attrib  : Byte;
                 fcb     : fcbType;
               end;


Function GetVolLabel(drive:Char):String;
Var sr : SearchRec;
begin
  findfirst(drive+':\*.*',VolumeID,sr);
  if Doserror=0 then GetVolLabel:=sr.name
  else GetVolLabel:='';
end;


Procedure setfcbname(Var fcb:fcbType; name:String);
Var p : Byte;
begin
  p:=pos('.',name);
  if p=0 then begin
    p:=length(name)+1;
    name:=name+'.';
    end;
  fillChar(fcb.name,11,' ');
  move(name[1],fcb.name,p-1);
  move(name[p+1],fcb.ext,length(name)-p);
end;


Procedure SetVolLabel(drive:Char; vLabel:String);
Var fcb  : extfcb;
    vl   : PathStr;
    regs : Registers;
    f    : File;
begin
  vl:=GetVolLabel(drive);
  fcb.flag:=$ff;
  fcb.attrib:=VolumeID;
  if vl<>'' then begin
    setfcbname(fcb.fcb,vl);
    fcb.fcb.drive:=ord(UpCase(drive))-64;
    regs.ah:=$13;                { Delete File }
    regs.ds:=seg(fcb);
    regs.dx:=ofs(fcb);
    msDos(regs);
    end;
  if vLabel<>'' then begin
    fcb.fcb.drive:=ord(UpCase(drive))-64;
    setfcbname(fcb.fcb,vLabel);
    With regs do begin
      ah:=$16;                  { Create File }
      ds:=seg(fcb);
      dx:=ofs(fcb);
      msDos(regs);
      ah:=$10;                  { Close File }
      ds:=seg(fcb);
      dx:=ofs(fcb);
      msDos(regs);
      end;
    end;
end;

