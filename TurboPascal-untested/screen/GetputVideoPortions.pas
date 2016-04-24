(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0075.PAS
  Description: GetPut Video portions
  Author: CALABRO DAVIDE
  Date: 11-26-94  05:06
*)

(*

  Name: GETPUT
  Version: 1.0
  Date of release: 02/Ago/1994
  Language: it can be used with Turbo Pascal 6.0  or
                                Borland Pascal 7.0


  Donated to the public domain by:  Calabro' Davide
                                    P.O.Box 65
                                    21019 Somma Lombardo (VA)
                                    Italy

                            E-mail: calabro@dsi.unimi.it

  Send comments,modifications or conversions in any other
  language to me thanks!


  This unit implements a useful Backup/Restore text video-portions feature.
  No static buffers are used to retain the saved video memory. Be sure
  to have enough heap space when call the GetVideo function or you'll get
  an "Heap overflow error" at runtime!

  This is an easy example of use of the GetPut unit:

  +--- START EXAMPLE ----------------------------------------------------+
  | Uses GETPUT;                                                         |
  |                                                                      |
  | Var A:PGetPut;  {<---- Each saved portion has its own pointer}       |
  |                                                                      |
  | Begin                                                                |
  |   A:=GetVideo(10,10,30,5);                                           |
  |              { +--|--|-|---- Start X position }                      |
  |              {    +--|-|---- Start Y position }                      |
  |              {       +-|---- Length on X axis }                      |
  |              {         +---- Length on Y axis }                      |
  |                                                                      |
  |   PutVideo(A); {<---- Restore the previously saved portion       }   |
  |                {      Warning: Dinamic buffer is disposed, don't }   |
  |                {               call with same buffer twice!      }   |
  |                                                                      |
  | End.                                                                 |
  +--- END EXAMPLE ------------------------------------------------------+

*)

Unit GETPUT;

INTERFACE

Type PGetPut=^TGetPut;
     TGetPut=Record
               Item:Byte;
               Next:PGetPut;
             End;

Function  GetVideo(X,Y,LX,LY:Byte):PGetPut;
Procedure PutVideo(BufPunt:PGetPut);

IMPLEMENTATION

Var GenPunt1,
    GenPunt2:PGetPut;
    Loop1:Byte;
    Loop:Word;
    StartAddr:Word;

Function GetVideo;
Begin
  New(GenPunt1);
  GetVideo:=GenPunt1;
  For Loop:=1 To 4 Do
    Begin
      Case Loop Of
        1: GenPunt1^.Item:=X;
        2: GenPunt1^.Item:=Y;
        3: GenPunt1^.Item:=LX;
        4: GenPunt1^.Item:=LY;
      End;
      New(GenPunt2);
      GenPunt1^.Next:=GenPunt2;
      GenPunt1:=GenPunt2;
    End;
  StartAddr:=160*(Y-1)+2*(X-1);
  For Loop1:=1 To LY Do
    Begin
      For Loop:=StartAddr To StartAddr+2*LX-1 Do
        Begin
          GenPunt1^.Item:=Mem[$B800:Loop];
          New(GenPunt2);
          GenPunt1^.Next:=GenPunt2;
          GenPunt1:=GenPunt2;
        End;
      Inc(StartAddr,160);
    End;
  GenPunt1^.Next:=Nil;
End;

Procedure PutVideo;
Var X,Y,LX,LY:Byte;
Begin
  GenPunt1:=BufPunt;
  For Loop:=1 To 4 Do
    Begin
      Case Loop Of
        1: X:=GenPunt1^.Item;
        2: Y:=GenPunt1^.Item;
        3: LX:=GenPunt1^.Item;
        4: LY:=GenPunt1^.Item;
      End;
      GenPunt2:=GenPunt1^.Next;
      Dispose(GenPunt1);
      GenPunt1:=GenPunt2;
    End;
  StartAddr:=160*(Y-1)+2*(X-1);
  For Loop1:=1 To LY Do
    Begin
      For Loop:=StartAddr To StartAddr+2*LX-1 Do
        Begin
          Mem[$B800:Loop]:=GenPunt1^.Item;
          GenPunt2:=GenPunt1^.Next;
          Dispose(GenPunt1);
          GenPunt1:=GenPunt2;
        End;
      Inc(StartAddr,160);
    End;
End;

Begin
End.
