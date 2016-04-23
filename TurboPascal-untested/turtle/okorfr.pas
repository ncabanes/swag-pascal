(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Unit - turtle graphic untype file reader   │
   └───────────────────────────────────────────────────────────┘ *)

{   Well, this is very usefull unit. This unit can read untype file.
  (okorfw.pas) This unit read the byte from file (it is code) and
  then spracuj. (english - work , in case) This metod (spracuj) work
  once the file.  If you want to do part of file for examplr onehalf
  then you muth modify your program wich writed the file or use other
  metod - rob. (rob = do) It is a metod who make n stenps. N is from
  input.

    Well, this unit is inversion of okorfw.pas. This unit is statical.
  It is for all who want to have a program writed in one style. If you
  want to have it with polymorphism then see Dkorfr.pas. Good is if
  you work with statical metods in your programs. (in turtle graphic)
  If you want to have it in DDS with polymorphism then have all programs
  it this style. It is not a problem but if you have one program in one
  style and other in other style then you muth be very skiful. (expert)

    I want to have a programs writed in style one (statical metods for
  beginers) and Dynamical for good programers. All units are in swag.
  In Dokorfr.pas are metods to do once with lot of files. If you want
  to modify this unit then modify ROB and SPRACUJ and make your metods
  to work with your metod. In metod (for korfr) you muth read all
  input variables for your metod and call your metod. (from your object)

    This object are meny units who haven't any input or output parameter.
  If you don't use polymorphism then it is not usefull, because you just
  read variables from file and do metod from unit kor. (not korfr)
}

Unit Okorfr;

Interface

Uses Okor,Graph;

Type  KorFR=object(kor)
       p:Byte;
    Procedure Init;
    Function  Spracuj:Byte;
    Function  Rob(n:Word):Byte;
    Procedure Domov;
    Procedure Dopredu;
    Procedure Vpravo;
    Procedure Vlavo;
    Procedure ZmenSmer;
    Procedure ZmenXY;
    Procedure PresunXY;
    Procedure Ukaz;
    Procedure Skry;
    Procedure PH;
    Procedure PD;
    Procedure ZmenFP;
    Procedure ZmenHP;
    Procedure Pis;
    Procedure Vypln;
  Private
    XSur0,YSur0,Smer0:real;
    Dole0,Ukazana0:boolean;
    FP0,HP0: byte;
    dXSur,dYSur,dSmer:real;
              End;

  Var f:file;
  Openfile:string;
  kod:byte;
  Const Flenght=1;
           rad=pi/180;

  Procedure Fileinit(Filename:string;code:Byte);
  Procedure FileDone(Filename:string);

Implementation

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

Function KeyPressed : Boolean; Assembler;
Asm
  mov ah, 01h
  int 16h
  mov ax, 00h
  jz @1
  inc ax
  @1:
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

  procedure Zmaz1;    {Before you use Zmaz1, then hide all turtles !!!}
  begin
    ClearViewPort;
    test;
  end;

procedure Cakaj;
const
  cas=1000;
var
  i,n:integer;
begin
  Blockread(f,n,2);
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


   Function  KorFR.Spracuj:Byte;
   Begin
   {$I-}
   While not eof(f) do Begin
   Blockread(f,p,1);
   Case p of
   0  : Init;
   1  : Domov;
   2  : Dopredu;
   3  : Vpravo;
   4  : Vlavo;
   5  : Ph;
   6  : Pd;
   7  : Ukaz;
   8  : Skry;
   9  : ZmenFp;
   10 : ZmenHp;
   11 : Vypln;
   12 : Pis;
   13 : CakajKlaves;
   14 : ZmenSmer;
   15 : PresunXY;
   16 : ZmenXy;
   17 : Zmaz1;
   18 : Cakaj;
               End;
   End;
   {$I+}
   Spracuj:=Ioresult;
   End;

   Function  Korfr.Rob(n:Word):Byte;
   Var i:integer;
   Begin
   i:=0;
   Repeat
   Inc(i);
   {$I-}
   Blockread(f,p,1);
   Case p of
   0  : Init;
   1  : Domov;
   2  : Dopredu;
   3  : Vpravo;
   4  : Vlavo;
   5  : Ph;
   6  : Pd;
   7  : Ukaz;
   8  : Skry;
   9  : ZmenFp;
   10 : ZmenHp;
   11 : Vypln;
   12 : Pis;
   13 : CakajKlaves;
   14 : ZmenSmer;
   15 : PresunXY;
   16 : ZmenXy;
   17 : Zmaz1;
   18 : Cakaj;
               End;
   Until (i=N)or(eof(f));
   {$I+}
   If eof(f) Then Kor.Pis(#7+'The file seek error!')
             Else Rob:=Ioresult;
   End;

   Procedure KorFR.Init;
   Var x,y,u:real;
   Begin
   blockread(f,x,6);
   blockread(f,y,6);
   blockread(f,u,6);
   Kor.init(x,y,u);
   End;

   Procedure KorFR.Domov;
   Begin
   Kor.Domov;
   End;

   Procedure KorFR.Dopredu;
   Var d:real;
   Begin
   Blockread(f,d,6);
   Kor.dopredu(d);
   End;

   Procedure KorFR.Vpravo;
   Var u:real;
   Begin
   Blockread(f,u,6);
   Kor.vpravo(u);
   End;

   Procedure KorFR.Vlavo;
   Var u:real;
   Begin
   Blockread(f,u,6);
   Kor.vlavo(u);
   End;

   Procedure KorFR.ZmenSmer;
   Var u:real;
   Begin
   BlockRead(f,u,6);
   Kor.zmensmer(u);
   End;

   Procedure KorFR.ZmenXY;
   Var x,y:real;
   Begin
   BlockRead(f,x,6);
   BlockRead(f,y,6);
   Kor.Zmenxy(x,y);
   End;

   Procedure KorFR.PresunXY;
   Var x,y:real;
   Begin
   BlockRead(f,x,6);
   BlockRead(f,y,6);
   Kor.PresunXY(x,y);
   End;

   Procedure KorFR.Ukaz;
   Begin
   Kor.Ukaz;
   End;

   Procedure KorFR.Skry;
   Begin
   Kor.Skry;
   End;

   Procedure KorFR.PH;
   Begin
   Kor.Ph;
   End;

   Procedure KorFR.PD;
   Begin
   Kor.Pd;
   End;

   Procedure KorFR.ZmenFP;
   Var nfp:integer;
   Begin
   blockread(f,nfp,2);
   Kor.zmenfp(nfp);
   End;

   Procedure KorFR.ZmenHP;
   Var nhp:integer;
   Begin
   blockread(f,nhp,2);
   Kor.zmenfp(nhp);
   End;

   Procedure KorFR.Pis;
   Var ch:char;
        s:string;
   Begin
   BlockRead(f,s,sizeof(s));
   Kor.pis(s);
   End;

   Procedure KorFR.Vypln;
   Var fv:byte;
   Begin
   BlockRead(f,fv,1);
   Kor.vypln(fv);
   End;

End.
