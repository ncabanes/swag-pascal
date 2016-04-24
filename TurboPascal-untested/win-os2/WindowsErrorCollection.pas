(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0028.PAS
  Description: WINDOWS Error Collection
  Author: MICHELE MOTTINI
  Date: 08-24-94  12:54
*)

program RunTime213;

{
   Written by:    Michele Mottini
                  TERA S.r.l.
                  CIS 100040,615

}
uses
  WinCrt,
  WinTypes,
  WinProcs,
  Objects;

{-------------------- Class TErrCollection : collection with error management }

{
  You can freely descend your own collection from TErrCollection getting
  automatically enhanced run time error management.
}

type
  PErrCollection = ^TErrCollection;
  TErrCollection = object(TCollection)
    procedure Error(Code,Info : integer); virtual;
  end;

procedure TErrCollection.Error(Code,Info : integer);
var
  ErrDesc : record
    ErrCode : integer;
    ErrPosHi : word;
    ErrPosLo : word;
    ErrIndex : integer;
    ErrCount : integer;
  end;
  Buffer : array[0..80] of char;
begin
  asm
    mov   cx,[BP+20]
    mov   bx,[BP+22]
    verr  bx
    je    @1
    mov   bx,$FFFF
    mov   cx,bx
    jmp   @2
@1:
    mov   es,bx
    mov   bx,word ptr es:0
@2:
    mov   ErrDesc.ErrPosLo,cx
    mov   ErrDesc.ErrPosHi,bx
  end;
  ErrDesc.ErrCode := 212-Code;
  ErrDesc.ErrIndex := Info;
  ErrDesc.ErrCount := Count;
  WVSPrintF(Buffer,'Runtime error %d at %04X:%04X with index %d; Count=%d',ErrDesc);
  MessageBox(0,Buffer,nil,mb_Ok or mb_SystemModal);
  halt(0);
end; { Error }

{----------------------------------------------------------------------- Main }

var
  TestColl : TErrCollection;

begin
  TestColl.Init(16,8);
  writeln('Now the program call the At() function with an invalid index');
  writeln('causing a R/Time error 213');
  writeln;
  writeln('If you try to find the error position from the address you will');
  writeln('go to the correct line!');
  TestColl.At(1);          { Wrong index: we will get a 213 R/Time error }
  TestColl.Done;
end.
