(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0210.PAS
  Description: RPG Thing for SWAG
  Author: RAMON RODRIGO
  Date: 01-02-98  07:35
*)


(* 30-8-97 : Solve 'Maze' With the Start and the End Position *)
(* By RRC2 (Ramon/Rodrigo Roman Castro) Soft, Malaga, Spain. *)
(*  - For: RPG programmers in every languages // Programadores de JDR.
    - Used in : BP 7.0.
    - Status : FreeWare, Can be Changed if You want.
    - Request : If you use it, please put our name in the credits.
    - Disclaimer : Code Full Tested. We aren't responsible of the damage
   that this code can do in your computer.
    - Sorry : We have a very bad English.
    - Comments :They're in English and Spanish. I'm Spanish, and Spanish is in
   the first five languages talken on the world, Did you know ?. Learn It!.
    - ATTENTION: I Don't Know if this Algorithm have been created before our
   discovery, but I don't see it on Anywhere. *)

(*  Imagine that you are making an RPG Game and you need a way
   enemies->objetives ( The Players ) in a maze structure.
    We have discovered an algorithm that can give a way to bad guys in
   a Rectangular map with or within Obstacles.
   This is.....

   THE MONIGOTES ALGORITHM
   =======================
   It's based in BackTracking Algorithm.
     Think that in every position of the terrain there's a byte that shows
   a direction:       1 North
                  4 West 2 East
                      3 South
     We start with the idea that my initial position in the terrain is a
   monigote (rag figure, I Think), and when it can, it expands himself wri-
   ting this directions in the terrain:
                 3                      1
               2 M 4 -> We don't write 4 2 (We must find the way Obj->BG, see:
                 1                      3   Now, What we have?)
     It Can't expand if there's an wall or another direction written in the
   square we wanted to go.
   Now we start with a loop:
   -------------------------
     The directions previously created ( in the previous loop ) transforms
   into monigotes, and they expand themselves (see above).
     This loop ends when a monigote is beside the objective.
   Example:
   --------                    3          33         33
                    3         234        2344       2344     B = Bad Guy
         B W       2M4W       2M4W       2M4W       2M4W     O = Objective
      O    ->    O  1  ->   O  1   ->  O  1   ->  O  11      M = Monigote
                                                             W = Wall
    No Loop     1ª Loop         2ª    L   o   o   p.........

   Now, What we have?
   ------------------
     We have in the terrain the way Objective->Badguy written. So, starting
   in the position of the monigote that were beside the Obj., we find this
   way, put it into a vector, change the directions and put the vector
   in a new vector with interchanging beginning and end ( We want BadGuy->
   Objetive ! ).
   What returns algorithm
   ----------------------
     A vector with the way BadGuy->Objetive. You can't take a Wrong Way.
   Tehcnical Details
   -----------------
   --Who are the directions that I need to transform into monigotes?
     They're in a Linked List, PuntActuales, So we transform them into
   monigotes and next they're cleared.
   --And the directions created?
     They're also in another Linked List, SigPunteros. It will transform into
   PuntActuales in the start of the a loop.
   Praise( Ja,Ja ;) )
   ------------------
   It's a Finstro of algorithm !. (Finstro:Word that means nothing in English,
   and nothing in Spanish ! [ Viva Chiquito de la Calzá :) ])
   Disclaimer
   ----------
     This algorithm was created in 30-8-97, 11:00->4:00(night), so if it
   isn't optimal, sorry.
*)

Program AlgoritmoMonigotes;

Uses Crt;

Const MAXMOV          = 30; (* The maximum movements I Can do *)
      MAXIMO          = 20; (* Dimensions of the Terrain *)
      INIX            = 1; (* X Coordinate of the Bad Guy *)
      INIY            = 12; (* Y Coordinate of the Bad Guy *)
      OBJX            = 15;  (* X Coordinate of the Objective *)
      OBJY            = 9; (* Y Coordinate of the Objective *)
      DISTANCIAMAXIMA = 1;  (* Reserved *)


Type  TSolucion = Array[1..MAXMOV] Of Integer; (* Vector with Solution *)
      TPantalla = Array[1..MAXIMO,1..MAXIMO] Of Byte; (* Terrain *)
      TPosicion = Record (* Position in X and Y *)
                    X,Y:Integer;
                  End;

(* Maze-Type Terrain *)
Const Pantalla:TPantalla =
((1,1,1,9,1,1,1,9,1,1,1,1,9,1,9,1,1,1,1,1),
 (1,1,1,1,1,9,1,1,1,1,9,9,9,1,9,9,9,9,1,1),
 (9,1,1,1,1,1,1,1,1,1,9,9,9,1,9,1,1,9,9,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,1),
 (1,1,9,1,1,1,1,9,1,1,9,1,9,9,1,1,1,9,1,1),
 (1,1,1,1,1,9,1,9,1,1,1,1,1,1,1,1,1,9,1,1),
 (9,1,1,1,9,9,1,9,9,9,9,9,1,9,9,1,1,9,1,9),
 (1,1,1,1,1,1,1,1,1,9,1,1,1,1,1,1,1,1,1,9),
 (9,1,9,1,1,9,1,9,1,1,1,1,9,1,1,9,9,1,9,9),
 (1,1,9,1,1,9,1,1,9,1,1,1,9,1,1,1,9,1,9,1),
 (9,1,1,1,1,1,1,1,9,1,1,1,9,1,9,1,1,1,1,1),
 (1,1,1,1,9,9,9,1,1,1,9,1,9,1,9,9,9,9,1,1),
 (1,1,9,1,1,9,1,1,1,1,9,1,9,1,9,1,1,9,9,1),
 (9,1,9,1,1,9,1,9,9,1,1,1,1,1,1,1,1,1,9,9),
 (1,1,9,1,9,9,1,9,1,9,9,9,9,9,9,1,1,9,1,1),
 (9,1,9,1,1,1,1,9,1,1,1,1,1,1,1,1,1,1,1,1),
 (9,1,9,9,9,9,1,1,9,9,9,9,9,9,9,1,1,9,9,9),
 (1,1,1,1,9,1,1,1,1,9,1,1,1,1,1,1,1,1,1,9),
 (1,1,1,1,1,1,1,1,1,9,1,1,1,1,1,1,1,1,1,9),
 (9,9,9,9,9,9,9,1,9,9,9,9,9,9,9,9,9,9,9,9));

(* Terrain Within Obstacles *)
(* Const Pantalla:TPantalla =
((1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1));*)

Var   Fondo        :TPantalla;
      Mov          :Integer;
      MovTotal     :Integer;
      Exito        :Boolean;
      Ini,Obj      :TPosicion;
      i            :Integer;
      Solucion     :TSolucion;

(* This procedure create the terrain with the Const Pantalla *)
Procedure InicializarPantallas;
Var i,j:Byte;
    Pant:TPantalla;
Begin
  Fondo:=Pantalla;
End;

(* This procedure Paints the Terrain onto the screen *)
Procedure PintarPantallas;
Var i,j:Byte;
Begin
  For i:=1 to MAXIMO Do
      For j:=1 to MAXIMO Do
          Begin
            GotoXy(i,j);
            Case Fondo[i,j] Of
               1:Write('░');
               9:Begin
                   TextColor(RED);
                   Write('█');
                   TextColor(LIGHTGRAY);
                 End;
            End;
          End;
  GotoXY(OBJX,OBJY);Write(CHR(1));
  GotoXY(INIX,INIY);Write('Y');
End;

(* This procedure paints the solution given in the vector Solucion *)
Procedure PintarMovimientos(Solucion:TSolucion;MovTotal:Integer);
Var Pos:TPosicion;
    i:Integer;
Begin
  Pos:=INI;
  For i:=1 to MovTotal Do
      Begin
        Case Solucion[i] Of
             1:Dec(Pos.Y);
             2:Inc(Pos.X);
             3:Inc(Pos.Y);
             4:Dec(Pos.X);
        End;
        GotoXy(Pos.X,Pos.Y);
        TextColor(DarkGray);
        Case Fondo[Pos.X,Pos.Y] Of
             1:Write('░');
        End;
        TextColor(LightGray);
      End;
End;

(* This function says if I can Step On a Square *)
Function SiPisar(ActualX,ActualY:ShortInt):Boolean; (* ¿ Puedo Pisar ? *)
Begin
  SiPisar:= (ActualX>0) And (ActualX<=MAXIMO) And
            (ActualY>0) And (ActualY<=MAXIMO) And
            (Fondo[ActualX,ActualY] <> 9); (* 9-> Wall // Muro *)
End;


(*-----------------------------------------------------------------------*)
(*------------------ALGORITHM//ALGORITMO---------------------------------*)
(*-----------------------------------------------------------------------*)
(*   BusqMonigote: The Algorithm. Returns TRUE if there's a way
       \-----> Devuelve si hay un camino
   Inicio: is the position of the Bad Guy, // Pos. Malo
   Objetivo: is the objective position, // Posicion objetivo
   PMov: is the squares you can move, // Casillas que puedo mover
   VAR Solucion: is the vector with the solution, // Array con la solucion
   VAR Movtotal: is the movements you have Done, // Movimientos realizados
   Fondo: is the Terrain // El terreno donde nos movemos
*)
Function BusqMonigote(Inicio,Objetivo:TPosicion;PMov:Integer;
                      Var Solucion:TSolucion;Var MovTotal:Integer;
                      Fondo:TPantalla):Boolean;

Const MAYOR = (MAXIMO*MAXIMO)+1;
Type PRegistro     = ^TRegistro;
     TLista        = PRegistro;
     TElemento     = TPosicion;
     TRegistro     = Record
                      Zona:TElemento;
                      Sig:TLista;
                     End;
     TAlgMonigote  = Array[1..MAXIMO,1..MAXIMO] Of Byte;

     TRejSolucion  = Array[1..MAYOR] Of Integer; (* Guardo Solucion Total *)
     (* Saves the entire Way *)
   (* Asi encuentra hasta el camino mas raro *)
   (* With this vector it can find even the strangest Way *)

Var PuntActuales:TLista;
    SigPunteros:TLista;
    Actual:TPosicion;
    Indice:TLista;
    AlgMonigote:TAlgMonigote;
    PosVictoria:TPosicion;
    SolucionTmp:TRejSolucion;
    Contador:Integer;
    CBucle:Integer;
    Contador2:Integer;

(* Distancia measure the distance | Mide distancia entre blanco y objetivo *)
    Function Distancia(ActualX,ActualY:ShortInt;Objetivo:TPosicion):Byte;
    Begin
      Distancia:=Abs(ActualX-Objetivo.X)+Abs(ActualY-Objetivo.Y);
    End;

    (* Initiate vars and pointers *)
    Procedure InicializoListasYVariables;
    Var x,y:Integer;
    Begin
     PuntActuales:=NIL;
     SigPunteros:=NIL;
     Indice:=NIL;
     Actual:=Inicio;
     PosVictoria.X:=MAXIMO+1;
     PosVictoria.Y:=MAXIMO+1;
     For x:=1 To MAXIMO Do
         Solucion[x]:=0;
     For x:=1 To MAYOR Do
         SolucionTmp[x]:=0;
     For x:=1 To MAXIMO Do
         For y:=1 To MAXIMO Do
          Begin
            AlgMonigote[x,y]:=0;
          End;
    End;

(* Here stars Procedures of Pointers and Linked Lists *)
    (* Insert_Begin // Inserta en el frente de una lista enlazada *)
    Procedure MeterFrente(Var Lista:TLista;Ele:TElemento);
    Var Tmp:TLista;
    Begin
      New(Tmp);
      Tmp^.Zona:=Ele;
      Tmp^.Sig:=Lista;
      Lista:=Tmp;
    End;

    (* Pop_Begin // Saca un elemento del inicio de la lista enlazada *)
    Procedure SacarFrente(Var Lista:TLista;Var Ele:TElemento);
    Var Tmp:TLista;
    Begin
      If Lista<>NIL Then
         Begin
          Tmp:=Lista;
          Lista:=Tmp^.Sig;
          Ele:=Tmp^.Zona;
          Dispose(Tmp);
         End;
    End;

    (* Eliminate List // Elimina la lista enlazada *)
    Procedure EliminoLista(Var Lista:TLista);
    Var Tmp:TLista;
    Begin
      While Lista<>NIL Do
        Begin
            Tmp:=Lista;
            Lista:=Tmp^.Sig;
            Dispose(Tmp);
        End;
    End;
(* End of Linked List Procedures and Functions *)


    (* Procedure that writes the directions when monigotes are expanding *)
    Procedure ComprobarBordes(Pos:TPosicion;Var AlgMonigote:TAlgMonigote;
                              Var PosVictoria:TPosicion);
    Var EleTmp:TPosicion;
    Begin
         (* Check Distance // Chequea la distancia al objetivo *)
         If (Distancia(Pos.X,Pos.Y,Objetivo) <= DISTANCIAMAXIMA) And
            (Distancia(Pos.X,Pos.Y,Objetivo) <> 0) Then
            PosVictoria:=Pos
         Else
         Begin
      (*1*)If SiPisar(Pos.X,Pos.Y-1) And
              (AlgMonigote[Pos.X,Pos.Y-1]=0) Then
            Begin
              AlgMonigote[Pos.X,Pos.Y-1]:=3;
              EleTmp.X:=Pos.X;
              EleTmp.Y:=Pos.Y-1;
              MeterFrente(SigPunteros,EleTmp);
            End;
      (*2*)If SiPisar(Pos.X+1,Pos.Y) And
              (AlgMonigote[Pos.X+1,Pos.Y]=0) Then
            Begin
              AlgMonigote[Pos.X+1,Pos.Y]:=4;
              EleTmp.X:=Pos.X+1;
              EleTmp.Y:=Pos.Y;
              MeterFrente(SigPunteros,EleTmp);
            End;
      (*3*)If SiPisar(Pos.X,Pos.Y+1) And
              (AlgMonigote[Pos.X,Pos.Y+1]=0) Then
            Begin
              AlgMonigote[Pos.X,Pos.Y+1]:=1;
              EleTmp.X:=Pos.X;
              EleTmp.Y:=Pos.Y+1;
              MeterFrente(SigPunteros,EleTmp);
            End;
      (*4*)If SiPisar(Pos.X-1,Pos.Y) And
              (AlgMonigote[Pos.X-1,Pos.Y]=0) Then
            Begin
              AlgMonigote[Pos.X-1,Pos.Y]:=2;
              EleTmp.X:=Pos.X-1;
              EleTmp.Y:=Pos.Y;
              MeterFrente(SigPunteros,EleTmp);
            End;
         End;
    End;

Begin
  InicializoListasYVariables;
  (* Pongo las primeras direciones // Puts the First Directions *)
  ComprobarBordes(Inicio,AlgMonigote,PosVictoria);

(* INICIO ALGORITMO // ALGORITHM STARTS *)
  (* Chequeo PosVictoria o fin del chequeo *)
  While ((PosVictoria.X=MAXIMO+1) And (PosVictoria.Y=MAXIMO+1)) And
        (SigPunteros<>NIL) Do
    Begin
      EliminoLista(PuntActuales);
      PuntActuales:=SigPunteros;
      SigPunteros:=NIL;
      (* Salgo al encontrar el 1º o ninguno *)
      While (PuntActuales<>NIL) And
            ((PosVictoria.X=MAXIMO+1) And (PosVictoria.Y=MAXIMO+1)) Do
        Begin
          SacarFrente(PuntActuales,Actual);
          ComprobarBordes(Actual,AlgMonigote,PosVictoria);
        End;
    End; (* Fin del Algoritmo en Si *)
  EliminoLista(PuntActuales);
  EliminoLista(SigPunteros);
(* FIN DEL ALGORITMO // ALGORITHM ENDS *)

(*   Ahora paso la solucion al Array Solucion. Escribo el camino completo en
   SolucionTmp ( Invirtiendo las direcciones, ya que busco de principio a
   fin ) y luego escribo en Solucion "Invirtiendo el vector" *)
(*   Now I pass the Solution ( It's in the AlgMonigote Vector ) to Solucion,
   using SolucionTmp (-> It Have the entire Way ) like a bridge *)

  If (PosVictoria.X=MAXIMO+1) And (PosVictoria.Y=MAXIMO+1) Then
     BusqMonigote:=False (* No encontre camino // There's no way *)
  Else Begin (* Encontre camino // There's a way *)
         Actual:=PosVictoria;
         Contador:=1;
         While (Actual.X<>Inicio.X) OR (Actual.Y<>Inicio.Y) Do
         (* Busco el camino del final al principio, transformando *)
           Begin
             Case AlgMonigote[Actual.X,Actual.Y] Of (* Cambio direcciones *)
                  1:SolucionTmp[Contador]:=3;
                  2:SolucionTmp[Contador]:=4;
                  3:SolucionTmp[Contador]:=1;
                  4:SolucionTmp[Contador]:=2;
             End;
             Inc(Contador);
             Case AlgMonigote[Actual.X,Actual.Y] Of
                  1:Dec(Actual.Y);
                  2:Inc(Actual.X);
                  3:Inc(Actual.Y);
                  4:Dec(Actual.X);
             End;
           End;(* Del While *)(* Saco Contador con el Num. de Movs Total+1 *)

         Contador2:=1;
         For CBucle:=Contador-1 DownTo 1 Do
         (* Ahora cambio direccion del camino de Fin-inicio a Inicio-Fin *)
         (* Meto solo el movimiento que tengo *)
           Begin
             If (Contador2 <= PMov) And (SolucionTmp[CBucle]<>0) Then
               Begin
                 Solucion[Contador2]:=SolucionTmp[CBucle];
                 Inc(Contador2);
               End;
           End; (* Del For *)
         MovTotal:=Contador2-1; (* Mov Realizados *)
         BusqMonigote:=TRUE;
       End;
End;

Begin
  TextColor(LightGray);
  Ini.X:=INIX;
  Ini.Y:=INIY;
  Obj.X:=OBJX;
  Obj.Y:=OBJY;
  ClrScr;
  InicializarPantallas;
  PintarPantallas;
  Exito:=BusqMonigote(INI,OBJ,MAXMOV,Solucion,MovTotal,Fondo);
  GotoXy(1,22);
  For i:=1 to Movtotal Do
      Write(Solucion[i]);
  GotoXy(1,23);
  Write('Way finded//Hay camino: ',Exito,'. Movements//Movimientos -> ',MovTotal);
  ReadKey;
  PintarMovimientos(Solucion,MAXMOV);
  ReadKey;
End.
(* There's no RPG programmers there?. Contact SWAG, leshe. *)

