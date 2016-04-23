
UNIT U123;  {Soure PC MAG. DECEMBER 13 1988... and others}
            { YES !  I did it in TP seven years Ago !!!}

INTERFACE

{
This routines ARE simple to use as 123.. :-)
1)  Open the file
2)  Add what you want.. where you want
3)  Close the File
}

PROCEDURE Open123(n:string);
PROCEDURE Close123;
PROCEDURE ColW123(c:integer; a:byte);
PROCEDURE Add123Int(c,f:integer; v:integer);
PROCEDURE Add123Rea(c,f:integer; v:double);
PROCEDURE Add123TXC(c,f:integer; v:string);
PROCEDURE Add123TXL(c,f:integer; v:string);

PROCEDURE Add123TXR(c,f:integer; v:string);
PROCEDURE Add123FML(c,f:integer; s:string);

{
  Open123(n:string);
  n = File Name WITHOUT EXTENSION it ALways add WK1
  It didn't check for a valid File Name or Existing, is
  YOUR responsability to do that


  Close123;
  Close the Open File .. Always DO THIS !

  In the rest of PROCEDURES c=Column and f=Row
  c and F begins with 0 (cero)
  if you want to Add in cell A1, use c=0 f=0
  if you want to Add in cell B2, use c=1 f=1
  etc.


  Add123Int(c,f:integer; v:integer);

  Add a Integer value (v) in Col=c  Row=f

  Add123Rea(c,f:integer; v:double);
  Add a Double value (v) in Col=c  Row=f

  Add123TXC(c,f:integer; v:string);
  Add a Label (v) in Col=C  Row=f
  - Label CENTER -

  Add123TXR(c,f:integer; v:string);
  Add a Label (v) in Col=C  Row=f
  - Label at RIGHT -

  Add123TXL(c,f:integer; v:string);
  Add a Label (v) in Col=C  Row=f
  - Label at LEFT -

  ColW123(c:integer; a:byte);
  Change width of Col=c to size=a

  Add123FML(c,f:integer; s:string);
  Add Formula (s) at Col=c  Row=f

  Examples:
           Add123FML(0,0,'A5+B2+A3*C5');
           Add123FML(0,1,'@Sum(B1..B8)');


  ==========================================
  THE ONLY VALID @ function is SUM   !!!!
  Sorry :-(
  ==========================================

}


{ The rest of Comments are in SPANISH ... Sorry again }


IMPLEMENTATION
CONST
     C00 = $00;
     CFF = $FF;

VAR
   ALotus : File;

PROCEDURE Open123(n:string);

Type
    Abre = record
                   Cod  : integer;
                   Lon  : integer;
                   Vlr  : integer;
             end;

Var
   Formato  : array[1..6] of byte;
   Registro : Abre absolute Formato;


Begin
     Assign(ALotus,n+'.WK1');

     Rewrite(ALotus,1);
     with Registro do
     begin
          Cod:=0;
          Lon:=2;
          Vlr:=1030;
     end;
     BlockWrite(ALotus,Formato[1],6);
End;

PROCEDURE Close123;

Type
    Cierra = record
                   Cod  : integer;
                   Lon  : integer;
             end;

Var
   Formato  : array[1..4] of byte;
   Registro : Cierra absolute Formato;


Begin
     with Registro do
     begin
          Cod:=1;
          Lon:=0;
     end;
     BlockWrite(ALotus,Formato[1],4);
     Close(ALotus);

End;

PROCEDURE ColW123(c:integer; a:byte);

Type
    Ancho = record
                   Cod  : integer;
                   Lon  : integer;
                   Col  : integer;
                   Anc  : byte;
             end;

Var
   Formato  : array[1..7] of byte;
   Registro : Ancho absolute Formato;


Begin
     with Registro do
     begin
          Cod:=8;
          Lon:=3;
          Col:=c;
          Anc:=a;
     end;
     BlockWrite(ALotus,Formato[1],7);
End;


PROCEDURE Add123Int(c,f,v:integer);

Type
    Entero = record

                   Cod  : integer;
                   Lon  : integer;
                   Frm  : byte;
                   Col  : integer;
                   Fil  : integer;
                   Vlr  : integer;
             end;

Var
   Formato  : array[1..11] of byte;
   Registro : Entero absolute Formato;

Begin
     with Registro do
     begin
          Cod:=13;
          Lon:=7;
          Frm:=255;
          Fil:=f;
          Col:=c;
          Vlr:=v;
     end;

     Blockwrite(ALotus,Formato[1],11);
End;

PROCEDURE Add123Rea(c,f:integer; v:double);
Type

    Entero = record
                   Cod  : integer;
                   Lon  : integer;
                   Frm  : byte;
                   Col  : integer;
                   Fil  : integer;
                   Vlr  : double;
             end;
Var
   Formato  : array[1..17] of byte;
   Registro : Entero absolute Formato;
Begin
     with Registro do
     begin
          Cod:=14;
          Lon:=13;
          Frm:=2 or 128;
          Fil:=f;
          Col:=c;
          Vlr:=v;
     end;

     Blockwrite(ALotus,Formato[1],17);
End;


PROCEDURE GrabaTXT(c,f:integer; v:string; t:char);

Type
    Entero = record
                   Cod  : integer;
                   Lon  : integer;
                   Frm  : byte;
                   Col  : integer;
                   Fil  : integer;
                   Vlr  : array[1..100] of char;
             end;
Var
   Formato  : array[1..109] of byte;
   Registro : Entero absolute Formato;
   i        : word;
Begin
     with Registro do
     begin
          Cod:=15;
          Lon:=length(v)+7;
          Frm:=255;
          Fil:=f;
          Col:=c;
          Vlr[1]:=t;
          for i:=1 to Length(v) do Vlr[i+1]:=v[i];

          Vlr[i+2]:=chr(0);
     end;
     Blockwrite(ALotus,Formato[1],length(v)+11);
End;

PROCEDURE Add123TXL(c,f:integer; v:string);
begin
     GrabaTXT(c,f,v,'''');
end;
PROCEDURE Add123TXC(c,f:integer; v:string);
begin
     GrabaTXT(c,f,v,'^');
end;
PROCEDURE Add123TXR(c,f:integer; v:string);
begin
     GrabaTXT(c,f,v,'"');
end;






PROCEDURE Add123FML(c,f:integer; s:string);

Type
    Formula = record
                    Cod : integer;                {codigo}
                    Lon : integer;                {longitud}

                    Frm : byte;                   {formato}
                    Col : integer;                {columna}
                    Fil : integer;                {fila}
                    Res : Double;                {resultado de formula}
                    Tma : integer;                {tamanio de formula en bytes}
                    Fml : array[1..2048] of byte; {formula}
              end;
    symbol = (cel,num,arr,mas,men,por,dvs,pot,pa1,pa2);
    consym = set of symbol;

Var
   Formato   : array[1..2067] of byte;

   Registro  : Formula absolute Formato;
   fabs      : boolean;                {flag que indica si ffml es absoluta}
   v,                                  {v    = string 's' sin blancos}
   nro       : string;                 {nro  = numero de ffml}
   cfml,                               {cfml = valor de columna en formula}
   ffml      : word;                   {ffml =   "    " fila     "    "   }
   nfml,                               {nfml =   "    " constante "   "   }
   i,                                  {i    = indice de 'v' (formula) }

   ii,                                 {ii   =    "    " 's'     "     }
   index,                              {index=    "    " Fml}
   j,ret,                              {usados para convertir a numeros}
   len,                                {len  = longitud de 'v'}
   lens      : integer;                {lens =     "     " 's'}
   sym       : symbol;                 {sym  = ultimo simbolo leido}
   symsig,                             {usados para analizar formula para }
   syminifac : consym;                 {grabarla con notacion posfija     }

   z         : byte;                   {indice para inicializar array}


   Procedure CalculaDir(var Reg : Formula);

   var
      veces : integer;

      (*   Primero, se decide si cfml es absoluta o relativa. Si es absoluta
           calcula el valor real. Si es relativa primero chequea si cfml<col.
           Si cfml<col le resta cfml a 49152 (C000); este numero es usado por
           Lotus para calcular la direccion de una celda a la izquierda de
           donde esta parado. Si col<=cfml le suma cfml a 32768 para encender

           el MSB que indica que es relativa (la C tambien lo prende).

           Segundo, se procede de la misma manera con ffml para determinar si
           es absoluta o relativa, y despues se calcula la direccion en base
           a eso y a la relacion de ffml con fil.
      *)

   begin
        with Reg do
        begin
             if v[i]='$' then             {calcula la columna (cfml)}
             begin
                  inc(i);
                  cfml:=ord(v[i])-ord('A');

                  inc(i);
                  while (v[i] in ['A'..'Z']) and (len>=i) do
                  begin
                       cfml:=(cfml+1)*26+ord(v[i])-ord('A');
                       inc(i);
                  end;
             end
             else
             begin
                  if (ord(v[i])-ord('A') < col) then
                  begin
                       cfml:=49152-col+(ord(v[i])-ord('A'));
                       inc(i);
                       veces:=1;
                       while (v[i] in ['A'..'Z']) and (len>=i) do
                       begin

                            cfml:=49152-col+(26*veces)+(ord(v[i])-ord('A'));
                            cfml:=cfml+((ord(v[i-1])-ord('A'))*26);
                            inc(i);
                            inc(veces);
                       end;
                  end
                  else
                  begin
                       cfml:=ord(v[i])-ord('A');
                       inc(i);
                       while (v[i] in ['A'..'Z']) and  (len>=i) do
                       begin

                            cfml:=(cfml+1)*26+ord(v[i])-ord('A');
                            inc(i);
                       end;
                       cfml:=cfml+32768-col;
                  end;
             end;

             Fml[index]:=Lo(cfml);        {graba cfml}
             inc(index);                  {que posee }
             Fml[index]:=Hi(cfml);        {dos bytes }
             inc(index);

             if v[i]='$' then             {calcula la fila (ffml)}
             begin
                  inc(i);
                  fabs:=true;

             end
             else
                 fabs:=false;
             j:=i;
             while (v[i] in ['0'..'9']) and (len>=i) do
             begin
                  inc(i);
             end;
             nro:=copy(v,j,i-j);
             val(nro,ffml,ret);

             if fabs then                 {siempre se resta 1 por estar en base 0}
             begin
                  if ffml>0 then ffml:=ffml-1;
             end
             else
             begin
                  if fil<ffml then

                  begin
                       ffml:=32768+abs(ffml-fil)-1;
                  end
                  else
                  begin
                       ffml:=49152-abs(ffml-fil)-1;
                  end;
             end;

             Fml[index]:=Lo(ffml);        {graba ffml}
             inc(index);                  {que posee }
             Fml[index]:=Hi(ffml);        {dos bytes }
             inc(index);
        end;
   end;

   Procedure CalculaNum(var Reg : Formula);

   var
      VDoble  : array[1..8] of byte;

      dfml    : Double absolute VDoble;
      d       : real;
      esreal  : boolean;
      k       : byte;
      numero  : longint;
      codigo  : integer;

   begin
        with Reg do
        begin
             esreal:=false;
             j:=i;
             while (v[i] in ['0'..'9','.']) and (len>=i) do
             begin
                  if v[i]='.' then esreal:=true;
                  inc(i);
             end;
             nro:=copy(v,j,i-j);
             {R-}
                 val(nro,numero,codigo);
             {R+}

                 if (codigo=0) and (numero>=-32768) and (numero<=32767) then
                    esreal:=false
                 else
                     esreal:=true;

             if esreal then
             begin
                  val(nro,d,ret);             {convierte en real doble}
                  dfml:=d;
                  {ConvRD(d,dfml);}

                  Fml[index]:=0;              {0 = indica que sigue una constante}
                  inc(index);                 {    real doble precision (8 bytes)}
                  for k:=1 to 8 do

                  begin
                       Fml[index]:=VDoble[k];   {graba dfml}
                       inc(index);            {son ocho bytes}
                  end;
             end
             else
             begin
                  val(nro,nfml,ret);          {convierte en entero}

                  Fml[index]:=5;              {5 = indica que sigue una constante }
                  inc(index);                 {    entera con signo (2 bytes)     }
                  Fml[index]:=Lo(nfml);       {graba nfml}
                  inc(index);                 {son dos bytes}

                  Fml[index]:=Hi(nfml);
                  inc(index);
             end;
             dec(i);
        end;
   end;

   Procedure CalculaRan(var Reg : Formula);

   begin
        with Reg do
        begin
             Fml[index]:=2;               {2 = codigo de rango; le sigue 8 bytes}
             inc(index);                  {    que son (col1fil1..col2fil2)     }

             CalculaDir(Reg);             {calcula col1fil1}
             i:=i+2;                      {salta los 2 ..  }
             CalculaDir(Reg);             {calcula col2fil2}

        end;
   end;

   Procedure CalculaArr(var Reg : Formula);

   {** SOLO CODIFICA @TRUE,@FALSE,@SUM(COL1FIL1..COL2FIIL2) **}

   var
      func,dir : string;                  {func  = string del @}
                                          {dir   = del rango}
      N_arg,nc : byte;                    {N_arg = cantidad de argumentos}
                                          {nc    = numero de codigo (T,F,S)}

   begin
        with Reg do
        begin
             inc(i);
             case v[i] of

                         'F' : nc:=51;
                         'T' : nc:=52;
                         'S' : nc:=80;
             end;

             while (v[i] in ['A'..'Z']) and (len>=i) do inc(i);
             inc(i);
             if nc=80 then
             begin
                  CalculaRan(Reg);        {calcula el rango (col1fil1..col2fil2}
                  N_arg:=1;               {hay un solo argumento}
             end;

             Fml[index]:=nc;
             inc(index);
             if nc=80 then
             begin
                  Fml[index]:=N_arg;      {graba numero de argumentos}

                  inc(index);
             end;
        end;
   end;

   Procedure TraerChar;

   begin
        inc(i);                           {carga el simbolo para }
        if len>=i then                    {la recursividad       }
        begin
             case v[i] of
                         'A'..'Z','$' : sym:=cel;
                         '0'..'9','.' : sym:=num;
                         '@'          : sym:=arr;
                         '+'          : sym:=mas;
                         '-'          : sym:=men;

                         '*'          : sym:=por;
                         '/'          : sym:=dvs;
                         '^'          : sym:=pot;
                         '('          : sym:=pa1;
                         ')'          : sym:=pa2;
             end;
        end;
   end;


   Procedure Expresion(symsig : consym; var Reg : Formula);
   var
      opsuma:symbol;

   Procedure Termino(symsig : consym; var Reg : Formula);
   var
      opmul:symbol;

   Procedure Factor(symsig : consym; var Reg : Formula);

   var
      opexp:symbol;

   Procedure Exponente(symsig : consym; var Reg : Formula);

   begin{Exponente}
        while (sym in syminifac) and (len>=i) do
        begin
             case sym of
                        num : begin
                                   CalculaNum(Registro);
                                   TraerChar;
                              end;
                        cel : begin
                                   Reg.Fml[index]:=1;
                                   inc(index);
                                   CalculaDir(Registro);

                                   dec(i);
                                   TraerChar;
                              end;
                        arr : begin
                                   CalculaArr(Registro);
                                   TraerChar;
                              end;
             else
                 begin
                      if sym=pa1 then
                      begin
                           TraerChar;
                           Expresion([pa2]+symsig,Registro);
                           if sym=pa2 then

                           begin
                                Reg.Fml[index]:=4;       {4 = simbolo '(' }
                                inc(index);
                                TraerChar;
                           end;
                      end;
                 end;
             end;
        end;
   end;{Exponente}

   begin{Factor}
        Exponente(symsig+[pot],Registro);
        while (sym=pot) and (len>=i) do
        begin
             opexp:=sym;
             TraerChar;
             Exponente(symsig+[pot],Registro);

             if opexp=pot then
             begin
                  Reg.Fml[index]:=13;                    {13 = simbolo '^' }
                  inc(index);
             end;
        end;
   end;{Factor}

   begin{Termino}
        Factor(symsig+[por,dvs],Registro);
        while (sym in [por,dvs]) and (len>=i) do
        begin
             opmul:=sym;
             TraerChar;
             Factor(symsig+[por,dvs],Registro);
             if (opmul=por) or (opmul=dvs) then
             begin
                  if opmul=por then Reg.Fml[index]:=11   {11 = simbolo '*' }

                  else
                      Reg.Fml[index]:=12;                {12 = simbolo '/' }
                  inc(index);
             end;
        end;
   end;{Termino}

   begin{Expresion}

      (*   Este es el primero de cuatro procedimientos recursivos (Expresion,
           Termino, Factor y Exponente) que se usan para transformar la formula
           en una expresion en notacion posfija, tal como se debe grabar. La
           tecnica consiste en retrasar la transmision del operador aritmetico.

           Ejemplo:  a+(b*c)^d  ==>  abc*(d^+  .

           Expresion analiza si es suma o resta. Luego llama a Termino. Al
           volver trae el proximo dato y llama otra vez a Termino. Al volver
           genera el codigo de suma o resta si hubo.

           Termino llama a Factor. Al volver trae el proximo dato y llama otra
           vez a Factor. Al volver genera el codigo de multiplicacion o division
           si hubo.

           Factor llama a Exponente. Al volver trae el proximo dato y llama

           otra vez a Exponente. Cuando vuele genera el codigo de exponenciacion
           si hubo.

           Exponente analiza si el valor es un numero, una celda, un arroba o
           un parentesis. Si es un parentesis, vuelve a llamar a Expresion para
           calcular el contenido este; sino genera el codigo correspondiente.

      *)

        if sym in [mas,men] then
        begin
             opsuma:=sym;
             TraerChar;
             Termino(symsig+[mas,men],Registro);
             if opsuma=men then

             begin
                  Reg.Fml[index]:=8;                     {8 = simbolo '-' unario}
                  inc(index);
             end;
        end
        else
            Termino(symsig+[mas,men],Registro);
        while (sym in [mas,men]) and (len>=i) do
        begin
             opsuma:=sym;
             TraerChar;
             Termino(symsig+[mas,men],Registro);
             if (opsuma=mas) or (opsuma=men) then
             begin
                  if opsuma=mas then Reg.Fml[index]:=9   { 9 = simbolo '+' }
                  else
                      Reg.Fml[index]:=10;                {10 = simbolo '-' }

                  inc(index);
             end;
        end;
   end;{Expresion}


Begin
     with Registro do
     begin
          Cod:=16;                     {16= formula}
          Col:=c;
          Fil:=f;

          Frm:=0;                      {Comienzo con 0}
(*
          if p=true then Frm:=Frm+128; {Si se protege se prende el MSB}

          ch:=UpCase(ch);              {Veo que formato se quiere y prendo }
                                       {los bits respectivos               }

          case ch of
                   'F' : Frm:=Frm+  0; {'F' ==> decimales fijos    }
                   'S' : Frm:=Frm+ 16; {'S' ==> notacion cientifica}
                   'C' : Frm:=Frm+ 32; {'C' ==> moneda corriente   }
                   'P' : Frm:=Frm+ 48; {'P' ==> porcentaje         }
                   'M' : Frm:=Frm+ 64; {',' ==> miles con comas    }
                   'O' : Frm:=Frm+112; {'O' ==> otros              }
          end;

          Frm:=Frm+d;                  {Si ch<>'O' ==> d= cant. de decimales}

                                       {Si ch= 'O' ==> d= 1 --> general     }
                                       {                  2 --> DD/MMM/AA   }
                                       {                  3 --> DD/MMM      }
                                       {                  4 --> MM/AA       }
                                       {                  5 --> texto       }
                                       {                  6 --> hidden      }
                                       {                  7 --> date; HH-MM-SS}
                                       {                  8 --> date; HH-MM }

                                       {                  9 --> date; int'l 1 }
                                       {                 10 --> date; int'l 2 }
                                       {                 11 --> time; int'l 1 }
                                       {                 12 --> time; int'l 2 }
                                       {              13-14 --> no utilizado}
                                       {                 15 --> default     }

  *)
           Res:=C00;
{          for z:=1 to 8 do Res[z]:=C00;} {se modifica automaticamente cuando se recalcula y regraba}


          lens:=length(s);             {convierto todo a mayusculas}
          for ii:=1 to lens do s[ii]:=UpCase(s[ii]);
          i:=1;
          v:='';
          for ii:=1 to lens do         {paso el string 's' al string 'v' }
          begin                        {eliminando los espacios en blanco}
               if s[ii]<>' ' then
               begin
                    v:=v+s[ii];
                    inc(i);
               end;
          end;

          len:=i-1;
          i:=0;
          index:=1;


          syminifac:=[cel,num,arr,pa1];
          symsig:=syminifac;

          TraerChar;                   {toma el primer caracter de formula}
          Expresion(symsig,Registro);  {analiza y graba toda la formula}

          Fml[index]:=3;               {3 = fin de formula}
          Tma:=index;                  {tamanio de Fml}
          Lon:=15+Tma;                 {longitud de dato}
          BlockWrite(ALotus,Formato[1],19+index);
     end;
End;


END.

