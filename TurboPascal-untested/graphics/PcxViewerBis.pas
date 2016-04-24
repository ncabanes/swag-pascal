(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0208.PAS
  Description: PCX Viewer
  Author: JAVIER PEREZ VIGO
  Date: 05-31-96  09:16
*)

{
Here you have the PCX source code. It works in 320x200 in 256 colors
I still haven't study the SVGA modes.

I hope it could serves you.

 JL> Thanks in advance.

(In the other message i've send you the GIF routine (in two messages cos the
extension)

==============Cut===============================Cut========================}

      PROGRAM GPCX;      {Por: Javier Perez Vigo 1994}
      USES Crt,graph,dos;
      TYPE
        PFich=^RFich;
        RFich=Record
          Size:Word;
          Octeto:Array[0..64999] of Byte;
          Sig:pFich;
        End;
      VAR
        BORRA:FILE;
        cadena:string[11];
        f: text;
       TECLA:BOOLEAN;
       largo:integer;
       muu:Longint;
       ch:char;
       Fich:File;
       i,j,k:Integer;
       a,b,c:Byte;
       X,Y:Integer;
       GD,GM,a14:Integer;
       a17:LongInt;
       s,F1:String;
       Primero,Actual,Siguiente:PFich;
       Count:Word;
       Pall:Array[0..767] of Byte;
       Reg:Registers;
       {$F+}

       Procedure Inicia;assembler;
        asm
        mov ax,$13
        int $10
        end;

      FUNCTION EXISTE_ARCH(Nombre:STRING):BOOLEAN;
         VAR
           F:FILE;
           OK:BOOLEAN;
         BEGIN            { Existe_Arch }
           Assign (f,Nombre);
           {$I-}
           Reset(f);
           {$I+}
           OK:=IOresult=0;
           If Not OK then
              Existe_Arch:=False
            else
              begin
                close(f);
                existe_Arch:=True;
              end;        { else }
         END;             { Existe_Arch }

       FUNCTION DetectVga256:integer;
        begin
        DetectVGA256:=1;
        end;
       {$F-}

   
       PROCEDURE no_tecla;
        var
          cabeza_Tampon:integer absolute $0000:$041A;{cabeza actual}
          cola_Tampon:integer absolute $0000:$041C;{cola actual}
        begin
           cola_Tampon:=cabeza_Tampon;
        end;


       BEGIN {Bloque principal}
        clrscr;
        wRITELn('   Utilidad de ficheros PCX');
        F1:=ParamStr(1);
       If Pos('.',F1)<1 THEN
       F1:=F1+'.pcx';
        Largo:=LENGTH(Paramstr(1));
        if largo=0 then
         begin
          Textcolor(red);
          writeLn('Escriba nombre de fichero');
          TextColor(white);
          textcolor(white);
          writeLN;
          halt(2)
         end;
       if not(existe_arch(f1)) then
         BEGIN
           TextColor(RED);
           WriteLn(' ¡ No existe el fichero ORIGEN ! ');
           TextColor(WHITE);
           writeLn;
           Halt(3);
         END
      else
      begin
       INICIA;
       gm:=0;
       gd:=1;
       initgraph(gd,gm,'c:\tp\bgi'); {the directory where the Unit is}
       x:=0;y:=0;
       Assign(Fich,F1);
       Reset(Fich,1);
       New(Actual);

       Primero:=Actual;
       BlockRead(Fich,Actual^.Octeto,65000,Actual^.Size);
       While not EOF(Fich) do
        Begin
         New(Siguiente);
         Actual^.sig:=Siguiente;
         Actual:=Siguiente;
         BlockRead(Fich,Actual^.Octeto,65000,Actual^.Size);
        End;
       Actual^.Sig:=Nil;
       Close(Fich);
       For i:=0 to 255 do
        Begin
         SetPalette(i,i);
         Pall[3*i]:=Actual^.Octeto[Actual^.Size-768+3*i] div 4;
        Pall[3*i+1]:=Actual^.Octeto[Actual^.Size-767+3*i] div 4;
        Pall[3*i+2]:=Actual^.Octeto[Actual^.Size-766+3*i] div 4;

        end;
       reg.ax:=$1012;
       reg.bx:=$00;
       reg.cx:=$100;
       reg.es:=seg(pall);
       reg.dx:=ofs(pall);
       Intr($10,reg);
       Count:=128;
       Actual:=Primero;
       j:=0;
      REPEAT
      a:=Actual^.Octeto[Count];
      Inc(Count);
      if Count>Actual^.Size then
       BEGIN
         Actual:=Actual^.Sig;
         Count:=0;
       END;
      If a>192 then
      BEGIN
        b:=a-192;
        a:=Actual^.Octeto[Count];
        Inc(Count);
        If Count>Actual^.Size then
        BEGIN
          Actual:=Actual^.Sig;
          Count:=0;
        End;
      END
       else
        b:=1;
       While b<>0 do
       begin
         dec(b);
         if a<>0 then
           mem[$A000:320*Y+X]:=a;
         Inc(X);
         If X>319 then
          begin
            x:=0;
            Inc(y);
          end;
        end;
     Until(Actual^.sig=NIL) and (Actual^.size<768+count);
         muu:=0;
         repeat
            NO_TECLA;
            TECLA:=KEYPRESSED;
            muu:=muu+1;
         until (muu=150000) or TECLA;

       begin
          textmode(c80);
          Halt(4);
        end;
    end;
  end.

