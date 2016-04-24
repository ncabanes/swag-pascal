(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0198.PAS
  Description: Number to Letters Converter
  Author: ARIEL PABLO KLEIN
  Date: 03-04-97  13:18
*)


Unit Num2Let;

INTERFACE

Uses Crt;

Function num2letra(x: longint): String;

IMPLEMENTATION

Type
    Unidades = array[1..29] of string;
    Decenas = array[3..9] of string;
    Centenas = array[1..9] of string;

Const
    UnidMap: Unidades =
('UN','DOS','TRES','CUATRO','CINCO','SEIS','SIETE',
                         'OCHO','NUEVE','DIEZ','ONCE','DOCE','TRECE',
                         'CATORCE','QUINCE','DIECISEIS','DIECISIETE',
                         'DIECIOCHO','DIECINUEVE','VEINTE','VEINTIUNA',
                        
'VEINTIDOS','VEINTITRES','VEINTICUATRO','VEINTICINCO',
'VEINTISEIS','VEINTISIETE','VEINTIOCHO',
                         'VEINTINUEVE');
    DecMap: Decenas =
('TREINTA','CUARENTA','CINCUENTA','SESENTA','SETENTA',
                       'OCHENTA','NOVENTA');
    CentMap: Centenas =
('CIENTO','DOSCIENTOS','TRESCIENTOS','CUATROCIENTOS',
                         'QUINIENTOS','SEISCIENTOS','SETECIENTOS',
                         'OCHOCIENTOS','NOVECIENTOS');
Var
   N : LongInt;

Function num2letra(x: longint): String;
Var
   NS: String;
   i,j : byte;
   restemp,temp : String;

Function decifrar(y: string) : String;
var
   temp,temp2,temp3: String;
   I,Code,j: Integer;

Begin
     Temp:='';
     temp2:=y;
     for i:=1 to 3 do
     Begin
          Case length(y) of
               1:Begin
                      val(y,j,code);
                      if j>0 Then
                      temp:=Temp+UnidMap[j];
                      y:='';
                 End;
               2:Begin
                      val(y,j,code);
                      if J>0 THen
                         If j>29 Then
                           Begin
                              val(copy(y,1,1),j,code);
                              y:=copy(y,2,1);
                              Temp:=Temp+DecMap[j];
                              val(y,j,code);
                              if j>0 Then Temp:=Temp+' Y ';
                           End
                             Else
                               Begin
                                 y:='';
                                 Temp:=Temp+UnidMap[j];
                               End;
                 End;
               3:Begin
                      val(copy(y,1,1),j,code);
                      if j>0 Then
                      Temp:=Temp+CentMap[j]+' ';
                      y:=copy(y,2,2);
                 End;
          End;
     End;
     temp3:='';
     For j:= length(temp2)+1 to length(NS) do temp3:=Temp3+NS[j];
     NS:=Temp3;
     decifrar:=temp;
End;
Begin
     ResTemp:='';
     Str(x, NS);
     For i:=1 to 3 do
     Begin
          Case i of
               1:Begin
                      If Length(NS)>6 Then
                      Begin
                         ResTemp:=decifrar(copy(NS,1,length(NS)-6));
                         if copy(NS,1,length(NS)-6) = '1' Then         
       ResTemp:=ResTemp+' MILLON'
                            else
                                ResTemp:=ResTemp+' MILLONES ';
                      End;
                  End;
               2:Begin
                      If Length(NS)>3 Then
                      Begin
                        
ResTemp:=ResTemp+decifrar(copy(NS,1,length(NS)-3));
                         ResTemp:=ResTemp+' MIL '
                      End;
                 End;
               3:Begin
                      If x > 0 then
                      Begin
                           ResTemp:=ResTemp+decifrar(NS);
                      End
                      Else
                          num2letra:='CERO';
                 End;
          End;
     End;
     num2letra:=restemp;
End;
Begin
End. === End of NUM2LET.PAS ===

