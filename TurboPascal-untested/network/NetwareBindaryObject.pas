(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0009.PAS
  Description: Netware Bindary Object
  Author: ROBERT KOHLBUS
  Date: 08-27-93  21:42
*)

{
Robert C. Kohlbus

        I'm trying to compile and run a program that I wrote, with BP70
'real' mode, in 'Protected Mode'.  This program uses Interrupt 21h
functions B80Xh and E3h, the Novell Netware ones.  The program worked fine
in 'real' mode, but gives incorrect information in 'Protected Mode'.  After
calling Borland, they said it was because the DPMI overlay file didn't know
how to handle the interrupts I was trying to access.  They suggested that I
look at a file from their BBS called READWRTE.PAS that shows how to handle
interrupts in a 'Protected Mode' program.  Basically this example file, just
interrupt 31h (Simulate Real Mode Interrupt).  My problem is that my program
continues to hang up, even after following their example.  Below is a sample
part of my program.  If anyone can lend a hand, I would be in their debt.
}

Program Getid;      { Get unique Id for Novell Netware Bindery Object }

uses
  Dos, Crt, WinApi;

type
  TDPMIRegs = record
    edi, esi, ebp, reserved, ebx, edx, ecx, eax: LongInt;
    flags, es, ds, fs, gs, ip, cs, sp, ss : Word;
  end;

var
  Hexid : string;
  R: TDPMIRegs;

  RequestBuffer : record
      PacketLength  : integer;
      functionval   : byte;
      ObjectType    : packed array [1..2] of byte;
      NameLength    : byte;
      ObjectName    : packed array [1..47] of char;
  end;

  ReplyBuffer  : record
      ReturnLength  : integer;
      UniqueID1  : packed array [1..2] of byte;
      UniqueID2  : packed array [1..2] of byte;
      ObjectType : packed array [1..2] of byte;
      ObjectName : packed array [1..48] of byte;
  end;


function DPMIRealInt(IntNo, CopyWords: Word; var R: TDPMIRegs): Boolean; assembler;
asm
  mov ax, 0300h
  mov bx, IntNo
  mov cx, CopyWords
  les di, R
  int 31h
  jc  @error
  mov ax, 1
  jmp @done
@error:
  xor ax, ax
  @Done:
end;

function LongFromBytes(HighByte, LowByte: Byte): LongInt; assembler;
asm
  mov dx, 0
  mov ah, HighByte
  mov al, LowByte
end;

function LongFromWord(LoWord: Word): LongInt; assembler;
asm
  mov dx, 0
  mov ax, LoWord;
end;

function RealToProt(P: Pointer; Size: Word; var Sel: Word): Pointer;
begin
  SetSelectorBase(Sel, LongInt(HiWord(LongInt(P))) Shl 4 + LoWord(LongInt(P)));
  SetSelectorLimit(Sel, Size);
  RealToProt := Ptr(Sel, 0);
end;


procedure GetObjectID(Name : string; ObjType : Word);
const
    HEXDIGITS : Array [0..15] of char = '0123456789ABCDEF';

var Reg : Registers;
    i : integer;
    Hex_ID, S : string;
    ErrorCode : word;
    ObjectId  : array[1..8] of byte;


begin
  with RequestBuffer do
  begin
     PacketLength  := 52;
     FunctionVal   := $35;
     ObjectType[1] := $0;
     ObjectType[2] := ObjType;
     NameLength    := length(Name);
     for i := 1 to length(Name) do
       ObjectName[i] := Name[i];
  end;
  ReplyBuffer.ReturnLength := 55;

  { Original Code that worked in Real Mode }
{
  Reg.ah := $E3;
  Reg.ds := seg(RequestBuffer);
  Reg.si := ofs(RequestBuffer);
  Reg.es := seg(ReplyBuffer);
  Reg.di := ofs(ReplyBuffer);

  MsDos(Reg);
}

  { New Code From Borland Example }
  FillChar(R, SizeOf(TDPMIRegs), #0);
  R.Eax := $E3;
  R.ds  := seg(RequestBuffer);
  R.Esi := LongFromWord(ord(RequestBuffer));
  R.es  := seg(ReplyBuffer);
  R.Edi := LongFromWord(ord(ReplyBuffer));
  DPMIRealInt($21, 0, R);

{
  S := 'None';
  Errorcode := Reg.al;
  if Errorcode = $96 then S := 'Server out of memory';
  if Errorcode = $EF then S := 'Invalid name';
  if Errorcode = $F0 then S := 'Wildcard not allowed';
  if Errorcode = $FC then S := 'No such object *'+QueueName+'*';
  if Errorcode = $FE then S := 'Server bindery locked';
  if Errorcode = $FF then S := 'Bindery failure';
  S := 'Error : '+ S;
  Writeln(S);
}
  Hex_ID := '';

  Hex_ID := hexdigits[ReplyBuffer.UniqueID1[1] shr 4];
  Hex_ID := Hex_ID + hexdigits[ReplyBuffer.UniqueID1[1] and $0F];
  Hex_ID := Hex_ID + hexdigits[ReplyBuffer.UniqueID1[2] shr 4];
  Hex_ID := Hex_ID + hexdigits[ReplyBuffer.UniqueID1[2] and $0F];
  Hex_ID := Hex_ID + hexdigits[ReplyBuffer.UniqueID2[1] shr 4];
  Hex_ID := Hex_ID + hexdigits[ReplyBuffer.UniqueID2[1] and $0F];
  Hex_ID := Hex_ID + hexdigits[ReplyBuffer.UniqueID2[2] shr 4];
  Hex_ID := Hex_ID + hexdigits[ReplyBuffer.UniqueID2[2] and $0F];
  while Hex_ID[1] = '0' do
      Hex_ID := copy(Hex_ID,2,length(Hex_ID));

  Hexid := Hex_ID;

end;

begin
   Hexid := '';
   ClrScr;

   { Get An Objects Id
     Parameters (2)  Object Name, Object Type
     Object Name = String[8];
     Object Type = Word;
          1  User
          2  User Group
          3  Print Queue
          4  File Server
          5  Job Server
          6  Gateway
          7  Print Server
   }
   GetObjectID('BUSINESS', 3);     { Get Print Queue's ID }
   Writeln('Hexid for BUSINESS is ',hexid);

end.

