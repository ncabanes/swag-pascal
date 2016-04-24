(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0177.PAS
  Description: Another Percentage bar
  Author: NIKOLAJ PAGH
  Date: 05-31-96  09:16
*)

{
Someone asked for a percentagebar routine. Well, here's a little one I put
together. (Put it in SWAG if you like...)
There's a testprogram at the end...
}

UNIT PERC_BAR;
INTERFACE

PROCEDURE InitBar(Xpos,Ypos,Size,ForCol,BackCol:BYTE);
PROCEDURE UpdateBar(Curr:BYTE);

IMPLEMENTATION
CONST
  SCSEG          = $B800;               (* Segment for screen *)
  SCWIDTH        = 80*2;                (* Width of screen *)

VAR (* Local variables *)
  BarOffs        : WORD;
  BarSize        : BYTE;
  BarCol         : BYTE;

(*************************************************************************
(* Name    : InitBar(Xpos,Ypos,Size,ForCol,BackCol:BYTE)
(* Purpose : Initializes the percentage bar. Xpos,Ypos is absolute posi-
(*           tion on screen, Size is how wide the bar is and ForCol and
(*           BackCol are the colors to use
(* Returns : None
(*************************************************************************)
PROCEDURE InitBar(Xpos,Ypos,Size,ForCol,BackCol:BYTE);
VAR
  ix             : BYTE;
  wValue         : WORD;
BEGIN
  BarOffs:=(Xpos-1)*2+(Ypos-1)*SCWIDTH;
  BarSize:=Size;
  BarCol:=BackCol*16+ForCol;
  wValue:=ORD('▓')+BarCol*256;
  FOR ix:=0 TO BarSize-1 DO
    MEMW[SCSEG:BarOffs+ix*2]:=wValue;
END; (* InitBar(Xpos,Ypos,Size,ForCol,BackCol:BYTE) *)

(***************************************************************************
(* Name    : UpdateBar(Curr:BYTE)
(* Purpose : Updates the bar with the current percentage. Curr is a percen-
(*           tage value between 0 and 100.
(* Returns : None
(***************************************************************************)
PROCEDURE UpdateBar(Curr:BYTE);
VAR
  ix             : INTEGER;
  pSize          : INTEGER;
  wValue         : WORD;
BEGIN
  pSize:=TRUNC((Curr/100)*BarSize);
  wValue:=ORD('█')+BarCol*256;
  FOR ix:=0 TO pSize-1 DO
    MEMW[SCSEG:BarOffs+ix*2]:=wValue;
END; (* UpdateBar(Curr:BYTE) *)

END.

(* Here is a little test program *)
PROGRAM PercTest;
USES Perc_Bar;

VAR
  count          : WORD;
BEGIN
  InitBar(30,10,20,14,1);
  FOR count:=1 TO 10000 DO
    UpdateBar(TRUNC((count/10000)*100));
END.

