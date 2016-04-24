(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0022.PAS
  Description: Novell IPX functions
  Author: R. GILOMEN
  Date: 05-26-94  11:03
*)

UNIT IPX;
(****************************************************************************)
(*                                                                          *)
(*  PROJEKT        : PASCAL Treiber fuer Novell-NetWare                     *)
(*  MODULE         : IPX.PAS                                                *)
(*  VERSION        : 1.10C                                                  *)
(*  COMPILER       : Turbo Pascal V 6.0                                     *)
(*  DATUM          : 13.06.91                                               *)
(*  AUTOR          : R. Gilomen                                             *)
(*  GEPRUEFT       : R. Gilomen                                             *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG   : Bibliothek mit den IPX-Grunfunktionen. Dieses Modul    *)
(*                   wurde mit IPX Version 2.12 getestet.                   *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  MODIFIKATIONEN :                                                        *)
(*                                                                          *)
(*  Version  1.00A      20.02.91  R. Gilomen    Initial Version             *)
(*  Version  1.10A      28.02.91  R. Gilomen    Neue Funktionen             *)
(*                                              IPX_To_Addr                 *)
(*                                              IPX_From_Addr               *)
(*                                              IPX_Internetwork_Address    *)
(*  Version  1.10B      07.03.91 R. Gilomen     Fehler in Funktion IPX_Done *)
(*                                              behoben. Bei SEND wurde     *)
(*                                              Source.Socket veraendert.   *)
(*  Version  1.10C      13.06.91 R. Gilomen     Defaultwert fuer Parameter  *)
(*                                              STAY_OPEN auf $FF gesetzt.  *)
(*                                                                          *)
(****************************************************************************)


(*//////////////////////////////////////////////////////////////////////////*)
                                   INTERFACE
(*//////////////////////////////////////////////////////////////////////////*)


(*==========================================================================*)
(*                         DEKLARATIONEN / DEFINITIONEN                     *)
(*==========================================================================*)

CONST

(* Allgemeine Deklarationen *)

         MAX_SOCKETS          = 20;    (* Maximale Anzahl konfigurierte     *)
                                       (* Kommunikationssockel.             *)
         MAX_DATA_SIZE        = 546;   (* Maximale Datenlaenge              *)
         NET_LENGTH           = 4;     (* Laenge Netzwerkadresse            *)
         NODE_LENGTH          = 6;     (* Laenge Knotenadresse              *)
   

(* Code Deklarationen *)

         SEND                  = $10;
         RECEIVE               = $20;


(* Deklaration der Rueckgabewerte *)

         SUCCESS               = $00;
         NOT_ENDED             = $10;
         PARAMETER_ERROR       = $20;
         NO_DESTINATION        = $21;
         DEVICE_SW_ERROR       = $30;
         SOCKET_TABLE_FULL     = $31;
         PACKET_BAD            = $32;
         PACKET_UNDELIVERIABLE = $33;
         PACKET_OVERFLOW       = $34;
         DEVICE_HW_ERROR       = $40;


TYPE   S4Byte          =  ARRAY [1..4]  OF BYTE; (* Datentyp fuer Network   *)
       S6Byte          =  ARRAY [1..6]  OF BYTE; (* Datentyp fuer Node      *)

                                                 (* Datentyp fuer Daten     *)
       Data_Packet     = ARRAY [1..MAX_DATA_SIZE] OF CHAR;

       SData           = RECORD                  (* Daten und Laenge        *)
                           Data   : Data_Packet;
                           Length : WORD;
                          END;

       Network_Address = RECORD                  (* Datentyp fuer NW-Adr.   *)
                           Network     : S4Byte;
                           Node        : S6Byte;
                           Socket      : WORD;
                         END;


(*==========================================================================*)
(*                         PROZEDUREN / FUNKTIONEN                          *)
(*==========================================================================*)


FUNCTION IPX_Setup : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG : Die Routine initialisiert die IPX-Software und deren     *)
(*                 Funktion.                                                *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : -                                                  *)
(*                                                                          *)
(*                  OUT: Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)



FUNCTION IPX_Open_Socket ( VAR Socket : WORD ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Routine eroeffnet einen Kommunikationssockel.       *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Nummer des Sockels, der eroeffnet  *)
(*                                       werden soll.                       *)
(*                                                                          *)
(*                  OUT: Socket        = Nummer des Sockels, der effektiv   *)
(*                                       geoeffnet wurde.                   *)
(*                                                                          *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)



FUNCTION IPX_Close_Socket ( Socket : WORD ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Routine schliesst einen Kommunikationssockel.       *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Nummer des Sockels, der geschlos-  *)
(*                                       sen werden soll.                   *)
(*                                                                          *)
(*                  OUT: Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)



FUNCTION IPX_Send ( Socket    : WORD;
                    Dest_Addr : Network_Address;
                    Buffer    : SData
                  ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Routine dient zum senden von Daten an eine oder     *)
(*                  mehrere Gegenstationen.                                 *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Sockelnummer, auf der gesendet     *)
(*                                       werden soll.                       *)
(*                       Dest_Addr     = Vollstaendige Netwerkadresse der   *)
(*                                       Gegenstation(en).                  *)
(*                       Buffer        = Daten die gesendet werden und      *)
(*                                       dessen Laenge.                     *)
(*                                                                          *)
(*                  OUT: Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)



FUNCTION IPX_Receive ( Socket : WORD ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Routine dient zum Empfangen von Daten einer Gegen-  *)
(*                  station. Die Daten koennen, wenn das Kommando beendet   *)
(*                  ist, mit der Funktion IPX_Done vom Netzwerk abgeholt    *)
(*                  werden.                                                 *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Sockelnummer, auf der empfangen    *)
(*                                       werden soll.                       *)
(*                                                                          *)
(*                  OUT: Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)



FUNCTION IPX_Done ( Socket          : WORD;
                    Code            : BYTE;
                    VAR Source_Addr : Network_Address;
                    VAR Buffer      : SData
                  ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Funktion liefert den Status einer vorher abgesetz-  *)
(*                  ten Routine. Zurueckgegeben wird, ob die Routine schon  *)
(*                  beendet ist oder nicht sowie eventuelle Daten.          *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Sockelnummer, auf der die Funktion *)
(*                                       ausgefuehrt werden soll.           *)
(*                       Code          = Routine, deren Status ueberprueft  *)
(*                                       werden soll.                       *)
(*                                                                          *)
(*                  OUT: Source_Addr   = Vollstaendige Netzwerkadresse der  *)
(*                                       Gegenstation, von der Daten einge- *)
(*                                       troffen sind.                      *)
(*                       Buffer        = Buffer, in dem eventuelle Daten    *)
(*                                       abgelegt werden koennen.           *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)



FUNCTION IPX_Internetwork_Address ( VAR Network : S4Byte;
                                    VAR Node    : S6Byte
                                  ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Funktion liefert die Internetzwerkadresse der       *)
(*                  jeweiligen Station.                                     *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  OUT: Network       = Netzwerkadresse                    *)
(*                       Node          = Knotenadresse                      *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)



FUNCTION IPX_To_Addr ( Network     : String;
                       Node        : String;
                       Socket      : String;
                       VAR Addr    : Network_Address
                     ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG : Die Routine konvertiert die Eingabestrings in die Daten- *)
(*                 struktur Network_Address.                                *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Network       = Netzwerkadresse die konvertiert    *)
(*                                       werden soll.                       *)
(*                       Node          = Knotenadresse die konvertiert      *)
(*                                       werden soll.                       *)
(*                       Socket        = Sockelnummer die konvertiert       *)
(*                                       werden soll.                       *)
(*                                                                          *)
(*                  OUT: Addr          = Konvertierte vollsaendige Netz-    *)
(*                                       werkadresse.                       *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)



FUNCTION IPX_From_Addr ( Addr            : Network_Address;
                         VAR Network     : String;
                         VAR Node        : String;
                         VAR Socket      : String
                       ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG : Die Routine konvertiert die vollstaendige Netzwerk-      *)
(*                 adresse in String's.                                     *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Addr          = Vollstaendige Netzwerkadresse      *)
(*                                                                          *)
(*                  OUT: Network       = Netzwerkadresse die konvertiert    *)
(*                                       wurde.                             *)
(*                       Node          = Knotenadresse die konvertiert      *)
(*                                       wurde.                             *)
(*                       Socket        = Sockelnummer die konvertiert       *)
(*                                       wurde.                             *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)




(*//////////////////////////////////////////////////////////////////////////*)
                                 IMPLEMENTATION
(*//////////////////////////////////////////////////////////////////////////*)


(*==========================================================================*)
(*                                UNITS IMPORT                              *)
(*==========================================================================*)

USES     Dos;

(*==========================================================================*)
(*                         DEKLARATIONEN / DEFINITIONEN                     *)
(*==========================================================================*)


CONST

(* Allgemeine Definitionen *)

         HEADER       = 30;            (* Groesse IPX-Header                *)
         PACKET_SIZE  = 576;           (* IPX-Paket groesse                 *)


(* Definitionen der IPX-Funktionen *)

         IPX_TST      = $7A00;         (* Vorbereiten fuer IPX Test         *)
         MUX_INTR     = $2F;           (* Multiplex Interrupt               *)
         OPEN_SOCKET  = $0000;         (* Oeffnet einen Sockel              *)
         CLOSE_SOCKET = $0001;         (* Schliesst einen Sockel            *)
         GET_TARGET   = $0002;         (* Pruefe Gegenstation               *)
         DO_SEND      = $0003;         (* Sendet ein Paket                  *)
         DO_RECEIVE   = $0004;         (* Empfaengt Pakete                  *)
         GET_ADDR     = $0009;         (* Bestimmt Internetzwerkadresse     *)


(* Definitionen der IPX-Parameter *)

         STAY_OPEN    = $FF;           (* $00 : Sockel bleibt geoeffnet,    *)
                                       (* bis er explizit geschlossen wird  *)
                                       (* oder das Programm terminiert.     *)
                                       (* $FF : Sockel bleibt geoeffnet,    *)
                                       (* bis er explizit geschlossen wird. *)
                                       (* Wird benoetigt fuer TSR-Programme.*)

(* Definitionen der IPX-Rueckgabewerte *)

         IPX_LOADED   = $FF;           (* IPX ist geladen                   *)
         OPENED       = $00;           (* Sockel erfolgreich geoeffnet      *)
         ALREADY_OPEN = $FF;           (* Sockel ist bereits goeffnet       *)
         TABLE_FULL   = $FE;           (* Sockel Tabelle ist voll           *)
         EXIST        = $00;           (* Weg zu Gegenstation existiert     *)
         NO_SOCKET    = $FF;           (* Sockel existiert nicht            *)
         SEND_OK      = $00;           (* Senden war erfolgreich            *)
         SOCKET_ERROR = $FC;           (* Sockel existiert nicht mehr       *)
         SIZE_ERROR   = $FD;           (* Paketgroesse nicht korrekt        *)
         UNDELIV      = $FE;           (* Paket nicht ausgeliefert          *)
         OVERFLOW     = $FD;           (* Buffer zu klein                   *)
         HW_ERROR     = $FF;           (* Hardware defekt                   *)
         REC_OK       = $00;           (* Paket erfolgreich empfangen       *)


(* Definition der ECB-Parameter *)

         FINISHED     = $00;           (* Routine beendet                   *)
         FRAG_COUNT   = 1;             (* Anzahl Fragmente                  *)
         UNKNOWN      = 0;             (* Unbekannter Paket Typ             *)

(* Deklarationen *)

TYPE     S12Byte      = ARRAY [1..12] OF BYTE;   (* Interner Datentyp       *)

         IPX_Packet   = RECORD         (* IPX-Paket Struktur                *)
                          CheckSum         : WORD;
                          Length           : WORD;
                          TransportControl : BYTE;
                          PacketType       : BYTE;
                          Destination      : Network_Address;
                          Source           : Network_Address;
                          IPX_Data         : Data_Packet;
                        END;

         ECB_Fragment = RECORD         (* Fragment der ECB Struktur         *)
                          Address : ^IPX_Packet;
                          Size    : WORD;
                        END;

         ECB = RECORD                  (* ECB Datenstruktur                 *)
                Link_Adress        : S4Byte;
                ESR_Address        : ^BYTE;
                InUseFlag          : BYTE;
                CompletionCode     : BYTE;
                SocketNumber       : WORD;
                IPX_Workspace      : S4Byte;
                DriverWorkspace    : S12Byte;
                ImmediateAddress   : S6Byte;
                FragmentCount      : WORD;
                FragDescr          : ECB_Fragment;
               END;


         Int_Addr = RECORD             (* Datenstruktur Internetzwerkadr.   *)
                      Network : S4Byte;
                      Node    : S6Byte;
                    END;


VAR      IPX_Location : ARRAY [1..2] OF WORD;    (* Adresse von IPX         *)

                                                 (* Array in dem die ECB's  *)
                                                 (* verwaltet werden.       *)
         ECB_Table    : ARRAY [1..MAX_SOCKETS] OF ^ECB;


(*==========================================================================*)
(*                         PROZEDUREN / FUNKTIONEN                          *)
(*==========================================================================*)


PROCEDURE IPX_Call ( VAR Regs : Registers );
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Diese Prozedur setzt die in Regs spezifizierten         *)
(*                  Register des Prozessors. Anschliessend wird ein IPX-    *)
(*                  Call ausgefuehrt und die Register wieder ausgelesen.    *)
(*                  Es werden nicht alle Register der Datenstruktur         *)
(*                  Regs uebernommen!                                       *)
(*                                                                          *)
(*  PARAMETER    :  IN : Regs          = Register, die gesetzt werden       *)
(*                                       sollen.                            *)
(*                                                                          *)
(*                  OUT: Regs          = Register, die vom IPX gesetzt      *)
(*                                       wurden (Return values).            *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      Temp_AX, Temp_BX, Temp_CX, Temp_DX,
         Temp_ES, Temp_SI, Temp_DI               : WORD;

BEGIN
 Temp_AX := Regs.AX;
 Temp_BX := Regs.BX;
 Temp_CX := Regs.CX;
 Temp_DX := Regs.DX;
 Temp_SI := Regs.SI;
 Temp_ES := Regs.ES;
 Temp_DI := Regs.DI;
 ASM
  PUSH BP                              (* Register sichern                  *)
  PUSH SP
  PUSH SS
  PUSH DS
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH ES
  PUSH DI
  MOV AX, Temp_AX                      (* Register setzen                   *)
  MOV BX, Temp_BX
  MOV CX, Temp_CX
  MOV DX, Temp_DX
  MOV SI, Temp_SI
  MOV ES, Temp_ES
  MOV DI, Temp_DI
  CALL DWORD PTR IPX_Location          (* IPX aufrufen                      *)
  MOV Temp_AX, AX                      (* Register auslesen                 *)
  MOV Temp_BX, BX
  MOV Temp_CX, CX
  MOV Temp_DX, DX
  MOV Temp_SI, SI
  MOV Temp_ES, ES
  MOV Temp_DI, DI
  POP DI
  POP ES                               (* Gesicherte Register wieder        *)
  POP SI                               (* zuruecksetzen.                    *)
  POP DX
  POP CX
  POP BX
  POP AX
  POP DS                               
  POP SS                               
  POP SP
  POP BP
 END;

 Regs.AX := Temp_AX;
 Regs.BX := Temp_BX;
 Regs.CX := Temp_CX;
 Regs.DX := Temp_DX;
 Regs.SI := Temp_SI;
 Regs.ES := Temp_ES;
 Regs.DI := Temp_DI;
END;



FUNCTION IPX_Setup : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG : Die Routine initialisiert die IPX-Software und deren     *)
(*                 Funktion.                                                *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : -                                                  *)
(*                                                                          *)
(*                  OUT: Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      i        : INTEGER;           (* Laufvariable                      *)
         Temp_Reg : Registers;         (* Temporaere Register fuer Int.     *)


BEGIN
  Temp_Reg.AX := IPX_TST;              (* Test ob IPX geladen.              *)
  Intr (MUX_INTR,Temp_Reg);
  IF (Temp_Reg.AL <> IPX_LOADED) THEN
  BEGIN
    IPX_Setup := DEVICE_SW_ERROR;      (* IPX nicht geladen                 *)
    EXIT;
  END;
  Temp_Reg.AX := Temp_Reg.ES;
  IPX_Location[1] := Temp_Reg.DI;      (* Adresse von IPX sichern           *)
  IPX_Location[2] := Temp_Reg.AX;

  FOR i := 1 TO MAX_SOCKETS DO         (* Array fuer ECB init.              *)
    ECB_Table[i] := NIL;

  IPX_Setup := SUCCESS;                (* Initialisierung erfolgreich       *)
END;



FUNCTION IPX_Open_Socket ( VAR Socket : WORD ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Routine eroeffnet einen Kommunikationssockel.       *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Nummer des Sockels, der eroeffnet  *)
(*                                       werden soll.                       *)
(*                                                                          *)
(*                  OUT: Socket        = Nummer des Sockels, der effektiv   *)
(*                                       geoeffnet wurde.                   *)
(*                                                                          *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      i        : INTEGER;           (* Laufvariable                      *)
         Index    : INTEGER;           (* Index auf ECB_Table               *)

         Temp_Reg : Registers;         (* Temporaere Register fuer IPX-Call *)


BEGIN
  Socket := Swap(Socket);              (* In Motorola Format konvertieren   *)

  FOR i := 1 TO MAX_SOCKETS DO         (* Pruefen, ob Sockel existiert      *)
    IF ECB_Table[i] <> NIL THEN
      IF Socket = ECB_Table[i]^.SocketNumber THEN
      BEGIN
        IPX_Open_Socket := PARAMETER_ERROR;
        EXIT;
      END;

  Index := 1;
  WHILE (ECB_Table[Index] <> NIL) DO   (* Pruefen, ob alle Sockel belegt    *)
  BEGIN                                (* falls es noch freie ECB hat,      *)
    IF Index >= MAX_SOCKETS THEN       (* steht Index auf einem solchen.    *)
    BEGIN
      IPX_Open_Socket := SOCKET_TABLE_FULL;
      EXIT;
    END;
    Index := Index + 1;
  END;

  Temp_Reg.BX := OPEN_SOCKET;          (* Register fuer Call vorbereiten    *)
  Temp_Reg.AL := STAY_OPEN;
  Temp_Reg.DX := Socket;

  IPX_Call (Temp_Reg);

  Socket := Temp_Reg.DX;               (* Register auslesen                 *)

  IF Temp_Reg.AL <> OPENED THEN        (* IPX nicht i.O.                    *)
  BEGIN
    IPX_Open_Socket := DEVICE_SW_ERROR;
    EXIT;
  END;

  NEW (ECB_Table[Index]);              (* Vollstaendiger ECB erzeugen       *)
  NEW (ECB_Table[Index]^.FragDescr.Address);
  ECB_Table[Index]^.SocketNumber := Socket;

  Socket := Swap(Socket);              (* Zurueck in INTEL Format konv.     *)
  IPX_Open_Socket := SUCCESS;

END;



FUNCTION IPX_Close_Socket ( Socket : WORD ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Routine schliesset einen Kommunikationssockel.      *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Nummer des Sockels, der geschlos-  *)
(*                                       sen werden soll.                   *)
(*                                                                          *)
(*                  OUT: Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      Index    : INTEGER;           (* Index auf ECB_Table               *)

         Temp_Reg : Registers;         (* Temporaere Register fuer IPX-Call *)


BEGIN
  Socket := Swap(Socket);              (* In Motorola Format konvertieren   *)

  Index := 1;                          (* Sockel suchen                     *)
  WHILE (ECB_Table[Index]^.SocketNumber <> Socket) DO
  BEGIN                               
    IF Index >= MAX_SOCKETS THEN
    BEGIN
      IPX_Close_Socket := PARAMETER_ERROR;       (* Sockel existiert nicht  *)
      EXIT;
    END;
    Index := Index + 1;
  END;

  Temp_Reg.BX := CLOSE_SOCKET;         (* Register fuer Call vorbereiten    *)
  Temp_Reg.DX := Socket;

  IPX_Call (Temp_Reg);

                                       (* Allozierter Speicher freigeben    *)
  DISPOSE (ECB_Table[Index]^.FragDescr.Address);
  ECB_Table[Index]^.FragDescr.Address := NIL;
  DISPOSE (ECB_Table[Index]);
  ECB_Table[Index] := NIL;
 

  IPX_Close_Socket := SUCCESS;

END;



FUNCTION IPX_Send ( Socket    : WORD;
                    Dest_Addr : Network_Address;
                    Buffer    : SData
                  ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Routine dient zum senden von Daten an eine oder     *)
(*                  mehrere Gegenstation(en).                               *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Sockelnummer, auf der gesendet     *)
(*                                       werden soll.                       *)
(*                       Dest_Addr     = Vollstaendige Netwerkadresse der   *)
(*                                       Gegenstation(en).                  *)
(*                       Buffer        = Daten die gesendet werden und      *)
(*                                       dessen Laenge.                     *)
(*                                                                          *)
(*                  OUT: Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      i         : INTEGER;          (* Laufvariable                      *)
         Index     : INTEGER;          (* Index auf ECB_Table               *)

         Temp_Reg  : Registers;        (* Temporaere Register fuer IPX-Call *)

         Temp_Imm_Addr : S6Byte;       (* Temporaere ImmdediateAddress      *)

         Temp_Addr : S12Byte;          (* Temporaere Internetworkadresse    *)


BEGIN
  Socket := Swap(Socket);              (* In Motorola Format konvertieren   *)
  Dest_Addr.Socket := Swap(Dest_Addr.Socket);

  Index := 1;                          (* Sockel suchen                     *)
  WHILE (ECB_Table[Index]^.SocketNumber <> Socket) DO
  BEGIN
    IF Index >= MAX_SOCKETS THEN
    BEGIN
      IPX_Send := PARAMETER_ERROR;     (* Sockel existiert nicht            *)
      EXIT;
    END;
    Index := Index + 1;
  END;

  IF Buffer.Length > MAX_DATA_SIZE THEN     (* Laenge der Daten pruefen     *)
  BEGIN
    IPX_Send := PARAMETER_ERROR;
    EXIT;
  END;

  WITH Dest_Addr DO                    (* Pruefe ob Gegenstation erreichbar *)
  BEGIN
    FOR i := 1 TO NET_LENGTH DO        (* Internetzwerkadresse zusammenst.  *)
      Temp_Addr[i] := Network[i];
    FOR i := 1 TO NODE_LENGTH DO
      Temp_Addr[i + NET_LENGTH] := Node[i];
    Temp_Addr[11] := Lo(Socket);       (* Low-Byte                          *)
    Temp_Addr[12] := HI(Socket);       (* High-Byte                         *)
  END;

  Temp_Reg.ES := Seg(Temp_Addr);       (* Register fuer Call vorbereiten    *)
  Temp_Reg.SI := Ofs(Temp_Addr);

  Temp_Reg.DI := Ofs(Temp_Imm_Addr);
  Temp_Reg.BX := GET_TARGET;

  IPX_Call (Temp_Reg);

  ECB_Table[Index]^.ImmediateAddress := Temp_Imm_Addr;

  IF Temp_Reg.AL <> EXIST THEN
  BEGIN
    IPX_Send := NO_DESTINATION;        (* Weg nicht verfuegbar              *)
    EXIT;
  END;

  WITH ECB_Table[Index]^ DO            (* ECB mit Parametern fuellen        *)
  BEGIN
    ESR_Address := NIL;
    SocketNumber := Socket;
    InUseFlag := FINISHED;
    FragmentCount := FRAG_COUNT;
    WITH FragDescr.Address^ DO         (* IPX-Header vorbereiten            *)
    BEGIN
      PacketType := UNKNOWN;
      WITH Destination DO
      BEGIN
        Network := Dest_Addr.Network;
        Node := Dest_Addr.Node;
        Socket := Dest_Addr.Socket;
      END;
      IPX_Data := Buffer.Data;
    END;
    FragDescr.Size := Buffer.Length + 30;
  END;

  Temp_Reg.ES := Seg(ECB_Table[Index]^);  (* Register fuer Call vorbereiten *)
  Temp_Reg.SI := Ofs(ECB_Table[Index]^);
  Temp_Reg.BX := DO_SEND;

  IPX_Call (Temp_Reg);

  IPX_Send := SUCCESS;

END;



FUNCTION IPX_Receive ( Socket : WORD ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Routine dient zum Empfangen von Daten einer Gegen-  *)
(*                  station. Die Daten koennen, wenn das Kommando beendet   *)
(*                  ist, mit der Funktion IPX_Done vom Netzwerk abgeholt    *)
(*                  werden.                                                 *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Sockelnummer, auf der empfangen    *)
(*                                       werden soll.                       *)
(*                                                                          *)
(*                  OUT: Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      Index     : INTEGER;          (* Index auf ECB                     *)
         i         : INTEGER;          (* Laufvariable                      *)

         Temp_Reg  : Registers;        (* Temporaere Register fuer IPX-Call *)


BEGIN
  Socket := Swap(Socket);              (* In Motorola Format konvertieren   *)

  Index := 1;                          (* Sockel suchen                     *)
  WHILE (ECB_Table[Index]^.SocketNumber <> Socket) DO
  BEGIN
    IF Index >= MAX_SOCKETS THEN
    BEGIN
      IPX_Receive := PARAMETER_ERROR;  (* Sockel existiert nicht            *)
      EXIT;
    END;
    Index := Index + 1;
  END;

  WITH ECB_Table[Index]^ DO            (* ECB mit Parametern fuellen        *)
  BEGIN
    ESR_Address := NIL;
    FragmentCount := FRAG_COUNT;
    FragDescr.Size := PACKET_SIZE;
    InUseFlag := FINISHED;
  END;

  Temp_Reg.ES := Seg(ECB_Table[Index]^);    (* Register vorbereiten         *)
  Temp_Reg.SI := Ofs(ECB_Table[Index]^);
  Temp_Reg.BX := DO_RECEIVE;

  IPX_Call (Temp_Reg);

  IF Temp_Reg.AL = NO_SOCKET THEN
  BEGIN
    IPX_Receive := DEVICE_SW_ERROR;
    EXIT;
  END;

  IPX_Receive := SUCCESS;

END;




FUNCTION IPX_Done ( Socket          : WORD;
                    Code            : BYTE;
                    VAR Source_Addr : Network_Address;
                    VAR Buffer      : SData
                  ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Funktion liefert den Status einer vorher abgesetz-  *)
(*                  ten Routine. Zurueckgegeben wird, ob die Routine schon  *)
(*                  beendet ist oder nicht sowie eventuelle Daten.          *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Socket        = Sockelnummer, auf der die Funktion *)
(*                                       ausgefuehrt werden soll.           *)
(*                       Code          = Routine, deren Status ueberprueft  *)
(*                                       werden soll.                       *)
(*                                                                          *)
(*                  OUT: Source_Addr   = Vollstaendige Netzwerkadresse der  *)
(*                                       Gegenstation, von der Daten einge- *)
(*                                       troffen sind.                      *)
(*                       Buffer        = Buffer, in dem eventuelle Daten    *)
(*                                       abgelegt werden koennen.           *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      i         : INTEGER;          (* Laufvariable                      *)
         Index     : INTEGER;          (* Index auf ECB_Table               *)

         Temp_Reg  : Registers;        (* Temporaere Register fuer IPX-Call *)


BEGIN
  Socket := Swap(Socket);              (* In Motorola Format konvertieren   *)

  Index := 1;                          (* Sockel suchen                     *)
  WHILE (ECB_Table[Index]^.SocketNumber <> Socket) DO
  BEGIN
    IF Index >= MAX_SOCKETS THEN
    BEGIN
      IPX_Done := PARAMETER_ERROR;     (* Sockel existiert nicht            *)
      EXIT;
    END;
    Index := Index + 1;
  END;
                                       (* Test ob Funktion beendet          *)
  IF ECB_Table[Index]^.InUseFlag <> FINISHED THEN
  BEGIN
     IPX_Done := NOT_ENDED;
     EXIT;
  END;

  CASE Code OF
    SEND :
    BEGIN                              (* Send Completion Code auswerten    *)
      CASE ECB_Table[Index]^.CompletionCode OF
        SEND_OK      : ;
        SOCKET_ERROR : BEGIN
                         IPX_Done := DEVICE_SW_ERROR;
                         EXIT;
                       END;
        SIZE_ERROR   : BEGIN
                         IPX_Done := PACKET_BAD;
                         EXIT;
                       END;
        UNDELIV      : BEGIN
                         IPX_Done := PACKET_UNDELIVERIABLE;
                         EXIT;
                       END;
        HW_ERROR     : BEGIN
                         IPX_Done := DEVICE_HW_ERROR;
                         EXIT;
                       END
        ELSE           BEGIN
                         IPX_Done := DEVICE_SW_ERROR;
                         EXIT;
                       END;
      END;
    END;
    RECEIVE :
    BEGIN                             (* Receive Completion Code auswerten  *)
      CASE ECB_Table[Index]^.CompletionCode OF
        REC_OK : BEGIN                 (* Daten in Benutzerbuffer kopieren  *)
                   WITH ECB_Table[Index]^.FragDescr DO
                   BEGIN
                     Buffer.Data := Address^.IPX_Data;
                     Buffer.Length := Swap(Address^.Length) - HEADER;
                   END;
                                       (* Netzwerkadresse umkopieren        *)
                   WITH ECB_Table[Index]^.FragDescr.Address^.Source DO
                   BEGIN
                     Source_Addr.Network := Network;
                     Source_Addr.Node := Node;
                     Source_Addr.Socket := Swap(Socket);
                   END;
                 END;
        SOCKET_ERROR : BEGIN
                         IPX_Done := DEVICE_SW_ERROR;
                         EXIT;
                       END;
        OVERFLOW     : BEGIN
                         IPX_Done := PACKET_OVERFLOW;
                         EXIT;
                       END;
        NO_SOCKET    : BEGIN
                         IPX_Done := DEVICE_SW_ERROR;
                         EXIT;
                       END
        ELSE           BEGIN
                         IPX_Done := DEVICE_SW_ERROR;
                         EXIT;
                       END;
      END;
    END
    ELSE  BEGIN
            IPX_Done := PARAMETER_ERROR;
          EXIT;
    END;

  END;

  IPX_Done := SUCCESS;

END;



FUNCTION IPX_Internetwork_Address ( VAR Network : S4Byte;
                                    VAR Node    : S6Byte
                                  ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG :  Die Funktion liefert die Internetzwerkadresse der       *)
(*                  jeweiligen Station.                                     *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  OUT: Network       = Netzwerkadresse                    *)
(*                       Node          = Knotenadresse                      *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      Temp_Reg     : Registers;     (* Temporaere Register fuer IPX-Call *)

         Reply_Buffer : Int_Addr;      (* Temporaerer Buffer fuer Adressen  *)

BEGIN

  Temp_Reg.ES := Seg(Reply_Buffer);    (* Register vorbereiten              *)
  Temp_Reg.SI := Ofs(Reply_Buffer);
  Temp_Reg.BX := GET_ADDR;

  IPX_Call (Temp_Reg);

  Network := Reply_Buffer.Network;     (* Daten umkopieren                  *)
  Node := Reply_Buffer.Node;

  IPX_Internetwork_Address := SUCCESS;

END;



FUNCTION IPX_To_Addr ( Network     : String;
                       Node        : String;
                       Socket      : String;
                       VAR Addr    : Network_Address
                     ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG : Die Routine konvertiert die Eingabestrings in die Daten- *)
(*                 struktur Network_Address.                                *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Network       = Netzwerkadresse die konvertiert    *)
(*                                       werden soll.                       *)
(*                       Node          = Knotenadresse die konvertiert      *)
(*                                       werden soll.                       *)
(*                       Socket        = Sockelnummer die konvertiert       *)
(*                                       werden soll.                       *)
(*                                                                          *)
(*                  OUT: Addr          = Konvertierte vollsaendige Netz-    *)
(*                                       werkadresse.                       *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      i,n,Code  : INTEGER;
         c         : CHAR;
         Temp      : BYTE;

BEGIN

  (* Pruefe Netzwerk und Node Laenge *)
  IF (ORD(Network[0]) <> (2 * NET_LENGTH)) OR
     (ORD(Node[0]) <> (2 * NODE_LENGTH)) THEN
  BEGIN
    IPX_To_Addr := PARAMETER_ERROR;
    EXIT;
  END;

  (* Netzwerkadresse konvertieren *)
  i := 1;
  n := 1;
  WHILE ( i <= (2 * NET_LENGTH)) DO
  BEGIN
    c := UPCASE(Network[i]);
    CASE c OF
      'A'..'F': Addr.Network[n] := ORD(c) - 55;
      '0'..'9': Addr.Network[n] := ORD(c) - 48
    ELSE        BEGIN
                  IPX_To_Addr := PARAMETER_ERROR;
                  EXIT;
                END;
    END;
    Addr.Network[n] := Addr.Network[n] SHL 4;
    c := UPCASE(Network[i + 1]);
    CASE c OF
      'A'..'F': Temp := ORD(c) - 55;
      '0'..'9': Temp := ORD(c) - 48;
    ELSE        BEGIN
                  IPX_To_Addr := PARAMETER_ERROR;
                  EXIT;
                END;
    END;
    Addr.Network[n] := Addr.Network[n] + Temp;
    i := i + 2;
    n := n + 1;
  END;


  (* Node-Adresse konvertieren *)
  i := 1;
  n := 1;
  WHILE ( i <= (2 * NODE_LENGTH)) DO
  BEGIN
    c := UPCASE(Node[i]);
    CASE c OF
      'A'..'F': Addr.Node[n] := ORD(c) - 55;
      '0'..'9': Addr.Node[n] := ORD(c) - 48;
    ELSE        BEGIN
                  IPX_To_Addr := PARAMETER_ERROR;
                  EXIT;
                END;
    END;
    Addr.Node[n] := Addr.Node[n] SHL 4;
    c := UPCASE(Node[i + 1]);
    CASE c OF
      'A'..'F': Temp := ORD(c) - 55;
      '0'..'9': Temp := ORD(c) - 48;
    ELSE        BEGIN
                  IPX_To_Addr := PARAMETER_ERROR;
                  EXIT;
                END;
    END;
    Addr.Node[n] := Addr.Node[n] + Temp;
    i := i + 2;
    n := n + 1;
  END;

  (* Sockelnummer konvertieren *)
  VAL (Socket,Addr.Socket,Code);
  IF Code <> 0 THEN
  BEGIN
    IPX_To_Addr := PARAMETER_ERROR;
    EXIT;
  END;

  IPX_To_Addr := SUCCESS;

END;



FUNCTION IPX_From_Addr ( Addr            : Network_Address;
                         VAR Network     : String;
                         VAR Node        : String;
                         VAR Socket      : String
                       ) : BYTE;
(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*  BESCHREIBUNG : Die Routine konvertiert die vollstaendige Netzwerk-      *)
(*                 adresse in String's.                                     *)
(*                                                                          *)
(*                                                                          *)
(*  PARAMETER    :  IN : Addr          = Vollstaendige Netzwerkadresse      *)
(*                                                                          *)
(*                  OUT: Network       = Netzwerkadresse die konvertiert    *)
(*                                       wurde.                             *)
(*                       Node          = Knotenadresse die konvertiert      *)
(*                                       wurde.                             *)
(*                       Socket        = Sockelnummer die konvertiert       *)
(*                                       wurde.                             *)
(*                       Rueckgabewert = Fehlercode                         *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

VAR      i,n,Code      : INTEGER;
         c             : CHAR;
         TempHi,TempLo : BYTE;

BEGIN

  (* Netzwerkadresse konvertieren *)
  i := 1;
  n := 1;
  WHILE ( i <= (2 * NET_LENGTH)) DO
  BEGIN
    TempHi := Addr.Network[n] DIV 16;  (* Hi-Nibble                         *)
    CASE TempHi OF
      10..15  : Network[i] := CHR(TempHi + 55);
      0..9    : Network[i] := CHR(TempHi + 48)
    ELSE        BEGIN
                  IPX_From_Addr := PARAMETER_ERROR;
                  EXIT;
                END;
    END;
    i := i + 1;
    TempLo := Addr.Network[n] MOD 16;  (* Lo-Nibble                         *)
    CASE TempLo OF
      10..15  : Network[i] := CHR(TempLo + 55);
      0..9    : Network[i] := CHR(TempLo + 48)
    ELSE        BEGIN
                  IPX_From_Addr := PARAMETER_ERROR;
                  EXIT;
                END;
    END;
    i := i + 1;
    n := n + 1;
  END;
  Network[0] := CHR(i);               (* Laenge Netzwerkadresse fuer String *)


  (* Node-Adresse konvertieren *)
  i := 1;
  n := 1;
  WHILE ( i <= (2 * NODE_LENGTH)) DO
  BEGIN
    TempHi := Addr.Node[n] DIV 16;     (* Hi-Nibble                         *)
    CASE TempHi OF
      10..15  : Node[i] := CHR(TempHi + 55);
      0..9    : Node[i] := CHR(TempHi + 48)
    ELSE        BEGIN
                  IPX_From_Addr := PARAMETER_ERROR;
                  EXIT;
                END;
    END;
    i := i + 1;
    TempLo := Addr.Node[n] MOD 16;     (* Lo-Nibble                         *)
    CASE TempLo OF
      10..15  : Node[i] := CHR(TempLo + 55);
      0..9    : Node[i] := CHR(TempLo + 48)
    ELSE        BEGIN
                  IPX_From_Addr := PARAMETER_ERROR;
                  EXIT;
                END;
    END;
    i := i + 1;
    n := n + 1;
  END;
  Node[0] := CHR(i - 1);              (* Laenge Knotenadr. fuer String     *)


  (* Sockelnummer konvertieren *)
  STR (Addr.Socket,Socket);

  IPX_From_Addr := SUCCESS;
END;

END.
