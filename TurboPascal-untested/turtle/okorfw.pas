(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Unit - turtle graphic with untypefiles     │
   └───────────────────────────────────────────────────────────┘ *)

{    Well this is very usefull unit. This unit can write all turtle
  work and then can read it. If you want to save your work, you have
  3 possibilitis :
  1: write your file system
  2: write dates to file with screensaver metod
  3: use this unit
  4: write unit working with binary type file (okorfwb.pas)

    Well, first possibility is for profesional programers, because it is
  not easy to define structures for turtle commands.
    Secend passibility is good if you want then convert it to image
  format for example gif, pcx, bmp, jpg ... . If you want then to step
  the drawing then it is unpassible.
   Third passibility is good for all who want to use turtle commands and
  want sometimes step it. If you want to have fast picture then use
  passibility 2.
  Fourth passibility is good for good programers. This unit can work with
   penetrate cycles. (realisated with rekusion outside) This is very usefull
   end effektive unit if you have some commands repeated. This effekt can
   be realizated only with binary type files!

    Here is a table for prepare a file for work :

   ┌──────┬─────────────────────────────────┐
   │ Code │ File type work                  │
   ├──────┼─────────────────────────────────┤
   │  0   │ Rewrite(f,Flenght);             │
   │  1   │ Append file with Flenght        │
   │  2   │ Reset file if exist with Flengt │
   └──────┴─────────────────────────────────┘

     This code table is a table for update the files for ower work :
    (All codes are value for CX register. (this is for all who know
     assembler))

   ┌──────┬────────────────┐
   │ Code │ File type      │
   ├──────┼────────────────┤
   │  0   │ Normal    file │
   │  1   │ ReadOnly  file │
   │  2   │ Hide      file │
   │  4   │ System    file │
   └──────┴────────────────┘

     Good is if you have some commands for work with files. I am giveing
  you this :

   ┌──────┬─────────────┐
   │ Code │ File type   │
   ├──────┼─────────────┤
   │  0   │ Exist  file │
   │  1   │ Copy   file │
   │  2   │ Rename file │
   │  3   │ Delete file │
   └──────┴─────────────┘

    How to use this commands ? In my programing life unpraktic to know a lot
  of commands. A lot of programers want to know a good parameter then names.
  My system is : Know which parameter what do. This is usefull, because
  you can to print tables (here are three) and work with tables.
    If you have this system in all file commands then it is perfekt. If
  you want to update it then it is make your command and work item (in case)
  it general command. (command with case)

   How to work with turtle commands? It is very easy. In your program write
 uses okorf; Then work with commands how we use okor.pas. This program work
 okor.pas and write it to untype binary file. All commands in this unit
 work okor.pas and write to file. This unit can write unit commands. (cakaj
 cakajklaves and zmaz1;

   And here is dictionary :

   ┌─────────────┬─────────────┐
   │    Name     │ In English  │
   ├─────────────┼─────────────┤
   │ Zmaz1       │ ClearScreen │
   │ Cakaj       │ Wait        │
   │ CakajKlaves │ Wait key    │
   └─────────────┴─────────────┘

     Good modification is if you have source of your metod (or tpu) and
  you write to file only imput parameters and in file viewer will read
  it and make your metod. Good is if you modify unit okorfr.pas.

     Well, this unit okorfw.pas and okorfr.pas are working with statical
  metods. It will be good if you work with statical unit then all units
  in turtle are statical. Statical unit (with statical metods) is not
  so good, but for all who don't work with turtle or don't know this
  collection is it good. Well if you are skiful (expert) then you can
  work with all versions. Who want dynamical fileturtle unit here is -
  in swag. This unit can work once with one file. It is not so bed, but
  if you want to work once with lot of files then good is to realise it
  with DDS. (dynamical date structure)  See Dokorfw.pas or Dokorfr.pas.
}

unit oKorFW;

interface

uses
  graph, crt;

type
  KorFW=object
    Procedure Init(x,y,u:real);
    Procedure Koniec;
    Procedure Domov;
    Procedure Dopredu(D:real);
    Procedure Vpravo(u:real);
    Procedure Vlavo(u:real);
    Procedure ZmenSmer(u:real);
    Procedure ZmenXY(x,y:real);
    Procedure PresunXY(x,y:real);
    Procedure Ukaz;
    Procedure Skry;
    Procedure PH;
    Procedure PD;
    Procedure ZmenFP(nfp:integer);
    Procedure ZmenHP(nhp:integer);
    Procedure Pis(s:string);
    Procedure Vypln(fv:byte);
    Function  XSur:real;
    Function  YSur:real;
    Function  Smer:real;
    Function  Dole:boolean;
    Function  Ukazana:boolean;
    Function  FP:byte;
    Function  HP:byte;
    Function  Smerom(x,y:real):real;
  Private
    XSur0,YSur0,Smer0:real;
    Dole0,Ukazana0:boolean;
    FP0,HP0: byte;
    dXSur,dYSur,dSmer:real;
    Procedure ukaz0;
  End;

  Procedure Zmaz1;
  Procedure CakajKlaves;
  Procedure Cakaj(n:integer);

  Procedure Fileinit(Filename:string;code:Byte);
  Procedure FileDone(Filename:string);
  Procedure Filetype(Filename:string;code:Byte);
  Procedure Filework(Filename:string;code:Byte);

var
  Klaves:integer;
  krokuj:boolean;
  X0,Y0:integer;
  f:file;
  p:byte;
  Openfile:string;
  kod:byte;

implementation

Const Driver_Path='C:\language\Bp7\bgi';
          Flenght=1;
              rad=pi/180;

Function FileExist(filename : String) : Boolean; Assembler;
ASM
        PUSH   DS
        LDS    SI, [filename]
        XOR    AH, AH
        LODSB
        XCHG   AX, BX
        MOV    Byte Ptr [SI+BX], 0
        MOV    DX, SI
        MOV    AX, 4300h
        INT    21h
        MOV    AL, False
        JC     @1
        INC    AX
@1:     POP    DS
end;

Function HideFile(FileName : String) : Byte; Assembler;
Asm
  Push DS
  LDS DX, FileName
  Inc DX
  Mov AH, 43h
  Mov AL, 1
  Mov CX, 2
  Int 21h
  JC @Done
  Mov AL, 0
  @Done:
  Pop DS
End;

Function SystemFile(FileName : String) : Byte; Assembler;
Asm
  Push DS
  LDS DX, FileName
  Inc DX
  Mov AH, 43h
  Mov AL, 1
  Mov CX, 4
  Int 21h
  JC @Done
  Mov AL, 0
  @Done:
  Pop DS
End;

Function ReadOnlyFile(FileName : String) : Byte; Assembler;
Asm
  Push DS
  LDS DX, FileName
  Inc DX
  Mov AH, 43h
  Mov AL, 1
  Mov CX, 1
  Int 21h
  JC @Done
  Mov AL, 0
  @Done:
  Pop DS
End;

Function NormalFile(FileName : String) : Byte; Assembler;
Asm
  Push DS
  LDS DX, FileName
  Inc DX
  Mov AH, 43h
  Mov AL, 1
  Mov CX, 0
  Int 21h
  JC @Done
  Mov AL, 0
  @Done:
  Pop DS
End;

Function DeleteFile(FileName : string) : integer; assembler;
Asm
  push ds
  lds si,FileName
  inc byte ptr [si]
  mov bl,byte ptr [si]
  xor bh,bh
  mov dx,si
  inc dx
  mov byte ptr [si+bx],0
  mov ah,41h
  int 21h
  jc  @error
  xor ax,ax
@error:
  dec byte ptr [si]
  pop ds
End;

Function CopyFile(Outname:string):Integer;
Var InFile, OutFile : File;
    Buffer          : Array[1..8192] Of Char;
    NumberRead,
    NumberWritten   : Word;
begin
   Assign( InFile, OpenFile);
   Reset ( InFile, 1 );
   Assign  ( OutFile,Outname);
   ReWrite ( OutFile, 1 );
   Repeat
      BlockRead ( InFile, Buffer, Sizeof( Buffer ), NumberRead );
      BlockWrite( OutFile, Buffer, NumberRead, NumberWritten );
   Until (NumberRead = 0) or (NumberRead <> NumberWritten);
   Close( InFile );
   Close( OutFile );
   Copyfile:=ioresult;
end;

  Function RenameFile(Filename:string):integer;
  Begin
  CopyFile(Filename);
  Close(f);
  DeleteFile(Openfile);
  OpenFIle:=Filename;
  Fileinit(Filename,kod);
  Renamefile:=ioresult;
  End;

  Procedure CakajKlaves;
  begin
    P:=13;
    Blockwrite(f,p,1);
    Klaves:=ord(readkey); if Klaves=0 then Klaves:=-ord(readkey);
    if Klaves=27 then
    begin
      CloseGraph;
      halt;
    end;
  end;

  Procedure test;
  var
    b:boolean;
  begin
    b:=krokuj;
    while keypressed or b do
    begin
      CakajKlaves;
      if Klaves=19 then b:=not b else b:=false;
    end;
  end;

  Procedure Fileinit(Filename:string;code:Byte);
  Begin
  Assign(f,Filename);

  Case code of
            0: Begin Rewrite(F,1);
                     OpenFIle:=Filename;
                     End;
            1: If fileexist(Filename) Then Begin
                                           Reset(f,Flenght);
                                           OpenFIle:=Filename;
                                           Seek(f,Filesize(f));
                                           End
                                      Else Writeln('File not exist!');
            2: If fileexist(Filename) Then Begin
                                           Reset(f,Flenght);
                                           OpenFIle:=Filename;
                                           End
                                      Else Writeln('File not exist!');
  End;
  kod:=code;
  End;

  Procedure FileDone(Filename:string);
  Begin
  Close(f);
  End;

  Procedure Filetype(Filename:string;code:Byte);
  Var vb:Byte;
  Begin
  Case code of
  0: vb:=NormalFile(Filename);
  1: vb:=ReadOnlyFile(Filename);
  2: vb:=HideFile(Filename);
  4: vb:=SystemFile(Filename);
  End;
  If vb<>0 Then Writeln(#7,'Problem with files.');
  End;

  Procedure Filework(Filename:string;code:Byte);
  Var vb:Integer;
  Begin

  Case code of
  0: IF Fileexist (Filename) then vb:=0 else vb:=1;
  1: vb:=CopyFile(Filename);
  2: vb:=RenameFile(Filename);
  3: vb:=DeleteFile(Filename);
  End;
  If vb<>0 Then Writeln(#7,'Problem with files.');
  End;

  Procedure KorFW.Init(x,y,u:real);
  begin
    p:=0;
    blockwrite(f,p,1);
    blockwrite(f,x,6);
    blockwrite(f,y,6);
    blockwrite(f,u,6);
    XSur0:=x;
    YSur0:=y;
    Smer0:=u;
    FP0:=7;
    HP0:=NormWidth;
    Dole0:=true;
    Ukazana0:=false;
    dSmer:=u;
    dXSur:=x;
    dYSur:=y;
  end;

  Procedure KorFW.Koniec;
  Begin
  CloseGraph;
  Halt;
  End;

  Procedure KorFW.Domov;
  begin
    p:=1;
    blockwrite(f,p,1);
    ZmenXY(dXSur,dYSur);
    ZmenSmer(dSmer);
  end;

  Procedure KorFW.Dopredu(d:real);
  begin
    p:=2;
    blockwrite(f,p,1);
    blockwrite(f,d,6);
    ZmenXY(XSur0+sin(Smer0*rad)*d,YSur0+cos(Smer0*rad)*d);
  end;

  Procedure KorFW.Vpravo(u:real);
  begin
    p:=3;
    blockwrite(f,p,1);
    blockwrite(f,u,6);
    ZmenSmer(Smer0+u);
  end;

  Procedure KorFW.Vlavo(u:real);
  begin
    p:=4;
    blockwrite(f,p,1);
    blockwrite(f,u,6);
    ZmenSmer(Smer0-u);
  end;

  Procedure KorFW.ZmenSmer(u:real);
  begin
    P:=14;
    Blockwrite(f,p,1);
    Blockwrite(f,u,6);
    ukaz0;
    Smer0:=u;
    while Smer0<0 do Smer0:=Smer0+360;
    while Smer0>=360 do Smer0:=Smer0-360;
    ukaz0;
    test;
  end;

  Procedure KorFW.ZmenXY(x,y:real);
  begin
    P:=16;
    Blockwrite(f,p,1);
    Blockwrite(f,x,6);
    Blockwrite(f,y,6);
    if not Dole0 then Begin
    PresunXY(x,y)
    End
    else
    begin
      ukaz0;
      MoveTo(trunc(XSur0)+X0,Y0-trunc(YSur0));
      SetColor(FP0); SetLineStyle(SolidLn,0,HP0);
      XSur0:=x;
      YSur0:=y;
      LineTo(trunc(XSur0)+X0,Y0-trunc(YSur0));
      ukaz0;
      test;
    end;
  end;

  Procedure KorFW.PresunXY(x,y:real);
  begin
    P:=15;
    Blockwrite(f,p,1);
    Blockwrite(f,x,6);
    Blockwrite(f,y,6);
    ukaz0;
    XSur0:=x;
    YSur0:=y;
    MoveTo(trunc(XSur0)+X0,Y0-trunc(YSur0));
    ukaz0;
    test;
  end;

  Procedure KorFW.PH;
  begin
    p:=5;
    blockwrite(f,p,1);
    Dole0:=false;
    test;
  end;

  Procedure KorFW.PD;
  begin
    p:=6;
    blockwrite(f,p,1);
    Dole0:=true;
    test;
  end;

  Procedure KorFW.Ukaz;
  begin
    p:=7;
    blockwrite(f,p,1);
    if not Ukazana0 then
    begin
      Ukazana0:=true;
      ukaz0;
    end;
    test;
  end;

  Procedure KorFW.Skry;
  begin
    p:=8;
    blockwrite(f,p,1);
    if Ukazana0 then
    begin
      ukaz0;
      Ukazana0:=false;
    end;
    test;
  end;

  Procedure KorFW.ZmenFP(nfp:integer);
  begin
    p:=9;
    blockwrite(f,p,1);
    blockwrite(f,nfp,2);
    FP0:=abs(nfp) mod 16;
    test;
  end;

  Procedure KorFW.ZmenHP(nhp:integer);
  begin
    P:=10;
    Blockwrite(f,p,1);
    Blockwrite(f,nhp,2);
    if nhp>1 then HP0:=ThickWidth
    else HP0:=NormWidth;
    test;
  end;

  Function KorFW.XSur:real;
  begin
    XSur:=Xsur0;
  end;

  Function KorFW.YSur:real;
  begin
    YSur:=Ysur0;
  end;

  Function KorFW.Smer:real;
  begin
    Smer:=Smer0;
  end;

  Function KorFW.Dole:boolean;
  begin
    Dole:=Dole0;
  end;

  Function KorFW.Ukazana:boolean;
  begin
    Ukazana:=Ukazana0;
  end;

  Function KorFW.FP:byte;
  begin
    FP:=FP0;
  end;

  Function KorFW.HP:byte;
  begin
    HP:=HP0;
  end;

  Procedure KorFW.Vypln(fv:byte);
  begin
    P:=11;
    Blockwrite(f,p,1);
    Blockwrite(f,fv,1);
    ukaz0;
    SetFillStyle(1,abs(fv) mod 16);
    FloodFill(trunc(XSur0)+X0,Y0-trunc(YSur0),FP0);
    ukaz0;
    test;
  end;

  function KorFW.Smerom(x,y:real):real;
  var
    u:real;
  begin
    x:=x-XSur0;
    y:=y-YSur0;
    if y=0 then
      if x=0 then u:=0
      else if x<0 then u:=270 else u:=90
    else
      if y>0 then
        if x>=0 then u:=arctan(x/y)*180/pi
        else u:=360-arctan(-x/y)*180/pi
      else
       if x>=0 then u:=180-arctan(-x/y)*180/pi
       else u:=180+arctan(x/y)*180/pi;
    Smerom:=u;
  end;

  procedure KorFW.Pis(s:string);
  begin
    P:=12;
    Blockwrite(f,p,1);
    Blockwrite(f,s,Sizeof(s));
    ukaz0;
    SetColor(FP0);
    OutTextXY(trunc(XSur0)+X0,Y0-trunc(YSur0),s);
    ukaz0;
    test;
  end;

  procedure KorFW.Ukaz0;
  {const
    dt=8; ut=75; ut0=0;}
  const
    dt=10; ut=45; ut0=30;
  var
    x,y,s,d0,d1:real;

    procedure krok(u,d:real);
    begin
      s:=s+u;
      x:=x+sin(s*rad)*d; y:=y+cos(s*rad)*d;
      LineTo(trunc(x)+X0,Y0-trunc(y));
    end;

  begin
    if not Ukazana0 then exit;
    MoveTo(trunc(XSur0)+X0,Y0-trunc(YSur0));
    SetWriteMode(XORPut);
    SetColor(15); SetLineStyle(SolidLn,0,NormWidth);
    x:=XSur0;
    y:=YSur0;
    s:=Smer0;
    d0:=dt/cos(-ut0*rad);
    d1:=dt/cos((ut+ut0)*rad);
    krok(90+ut0,d0);
    krok(ut-180,d1);
    krok(-2*(ut+ut0),d1);
    krok(ut-180,d0);
    SetWriteMode(NormalPut);
  end;

  procedure Zmaz1;    {Before you use Zmaz1, then hide all turtles !!!}
  begin
    P:=17;
    Blockwrite(f,p,1);
    ClearViewPort;
    test;
  end;

procedure Cakaj(n:integer);
const
  cas=1000;
var
  i:integer;
begin
    P:=18;
    Blockwrite(f,p,1);
    Blockwrite(f,n,2);
  i:=cas;
  repeat
    test;
    dec(i);
    if i<1 then
    begin
      dec(n);
      i:=cas;
    end;
  until n<=0;
end;

var
  gd,gm:integer;

begin

  gd:=vga;
  gm:=vgahi;
  InitGraph(gd,gm,Driver_path);

  if GraphResult<>0 then
  begin
    writeln('Problem with graphic driver!');
    halt;
  end;

  X0:=GetMaxX div 2+1;
  Y0:=GetMaxY div 2+1;
  Klaves:=0;
  krokuj:=false;
end.
