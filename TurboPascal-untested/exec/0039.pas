{
>If this cannot be done, then hhow can one include a pcx directly inside
>the compiled File???

  There's a trick to do that :
  Suppose your Program is called PROG.EXE and your PCX File IMAGE.PCX

  After each compile of PROG.EXE, do :
  COPY /B PROG.EXE+IMAGE.PCX

  Then, when you want to display the PCX, open the EXE File, read it's
  header :
}

Function GetExeSize(ExeName:String; Var TotSize,Expect:LongInt):Boolean;
{ returns True if EXE is already bind }
Type
  ExeHeaderRec = Record {Information describing EXE File}
    Signature         : Word; {EXE File signature}
    LengthRem         : Word; {Number of Bytes in last page of EXE image }
    LengthPages       : Word; {Number of 512 Byte pages in EXE image}
    NumReloc          : Word; {Number of relocation items}
    HeaderSize        : Word; {Number of paraGraphs in EXE header}
    MinHeap,MaxHeap   : Word; {ParaGraphs to keep beyond end of image}
    StackSeg,StackPtr : Word; {Initial SS:SP, StackSeg relative to image }
    CheckSum          : Word; {EXE File check sum, not used}
    IpInit, CodeSeg   : Word; {Initial CS:IP, CodeSeg relative to image}
    RelocOfs          : Word; {Bytes into EXE For first relocation item}
    OverlayNum        : Word; {Overlay number, not used here}
  end;

Var
  ExeF : File;
  ExeHeader : ExeHeaderRec;
  ExeValue : LongInt;
  count : Word;

begin
  TotSize:=0; Expect:=0;
  Assign(ExeF,ExeName); Reset(ExeF,1);
  if IoResult=0 then
  begin
    TotSize:=FileSize(ExeF);
    BlockRead(ExeF,ExeHeader,SizeOf(ExeHeaderRec),Count);
    With ExeHeader do

               IF Signature = $5A4D THEN
                  BEGIN
                     IF LengthRem = 0 THEN
                        ExeValue := LONGINT(LengthPages) SHL 9
                     ELSE
                        ExeValue := (LONGINT(PRED(LengthPages)) SHL 9);
                        {-LengthRem clears the bug}
                     Expect := ExeValue + LengthRem;
                  END;


  end;

  Close(ExeF);
  GetExeSize:=(TotSize<>Expect);
end;

{
  If GetExeSize returns True, your PCX has been placed at the end of the
  EXE (you did not forget :)) and all you have to do next is skip the
  Program itself : Seek(ExeF,Expect);

  Then starts your PCX. If you know in advance the sizes of the PCX
  File, you can place any data you want (including lots of PCX) at the
  end of your EXE.

  This example is taken from a Unit I wrote a long time ago (was called
  Caravane) and it worked very well. I accessed the end of my exe File
  like a normal Typed File. Quite funny but I do not use this anymore.
  Note that you can LzExe or Pklite the EXE part (not the PCX one). You
  can DIET both parts With the resident version.

  I hope the Function GetExeSize is not copyrighted since it is much too
  commented to be one of my work :)
