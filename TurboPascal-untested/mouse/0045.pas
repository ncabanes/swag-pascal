Unit mouse;

Interface

Procedure RESET_MOUSE (var errore : boolean;
                       var num : word);
Procedure OPEN_MOUSE;
Procedure CLOSE_MOUSE;
Function LEFT_BUTTON : boolean;
Function RIGHT_BUTTON : boolean;
Function MIDDLE_BUTTON : boolean;
Function X_MOUSE (w : boolean) : word; (* w=True se in Graphic Mode *)
Function Y_MOUSE (w : boolean) : word;
Procedure POS_MOUSE (x,y : word);
Procedure WINDOW_MOUSE (x,y,x1,y1 : word);
Procedure GRAPHIC_CURSOR (nome : string;
                          var errore : boolean;
                          hotx,hoty : word);
Procedure TEXT_CURSOR1 (inizio, fine : word);
Procedure TEXT_CURSOR2 (sfondo, colore : byte);
Function X_REL : word;
Function Y_REL : word;
Procedure RAPPORTO_MOUSE (oriz,vert : word);
Procedure NOWINDOW_MOUSE (x,y,x1,y1 : word);

Implementation

 Uses dos;
 Var r : registers;

 Procedure GEST_MOUSE (inf : word);
 begin
   r.ax:=inf;
   Intr ($33,r)
 end;

 Procedure RESET_MOUSE (var errore : boolean;
                        var num : word);
 begin
   GEST_MOUSE (0);
   errore:=r.ax = -1;
   num:=r.bx
 end;

 Procedure OPEN_MOUSE;
 begin
   GEST_MOUSE (1)
 end;

 Procedure CLOSE_MOUSE;
 begin
   GEST_MOUSE (2)
 end;

 Function LEFT_BUTTON : boolean;
 begin
    GEST_MOUSE (3);
    left_button:= (r.bx = 1) or (r.bx = 3) or (r.bx = 5)
                  or (r.bx = 7)
 end;

 Function RIGHT_BUTTON : boolean;
 begin
    GEST_MOUSE (3);
    right_button:= (r.bx = 2) or (r.bx = 3) or (r.bx = 6)
                   or (r.bx = 7)
 end;

 Function MIDDLE_BUTTON : boolean;
 begin
    GEST_MOUSE (3);
    middle_button:= (r.bx = 4) or (r.bx = 5) or (r.bx = 6)
                    or (r.bx = 7)
 end;

 Function X_MOUSE (w : boolean) : word;
 begin
    GEST_MOUSE (3);
    If w
     then
      x_mouse:=r.cx
     else
      x_mouse:=r.cx div 8
 end;

 Function Y_MOUSE (w : boolean) : word;
 begin
    GEST_MOUSE (3);
    If w
     then
      y_mouse:=r.dx
     else
      y_mouse:=r.dx div 8
 end;

 Procedure POS_MOUSE (x,y : word);
 begin
    r.cx:=x;
    r.dx:=y;
    GEST_MOUSE (4)
 end;

 Procedure WINDOW_MOUSE (x,y,x1,y1 : word);
 begin
    r.cx:=x;
    r.dx:=x1;
    GEST_MOUSE (7);
    r.cx:=y;
    r.dx:=y1;
    GEST_MOUSE (8)
 end;

 Procedure GRAPHIC_CURSOR (nome : string;
                           var errore : boolean;
                           hotx,hoty : word);
  Const n = 16;
  Type vettore  = array[1..n]of word;
       vettore2 = array[1..n*2]of word;
  Var cursore : file of vettore;
      buffer  : vettore;
      mappa   : vettore2;
      i       : byte;
 begin
    Assign (cursore,nome);
    {$I-}
    Reset (cursore);
    {$I+}
    errore:=Ioresult<>0;
    If not(errore)
     then
      begin
        Read (cursore,buffer);
        Close (cursore);
        For i:=1 to 16 do
         mappa[i]:=not(buffer[i]);
        For i:=17 to 32 do
         mappa[i]:=buffer[i-16];
        r.bx:=hotx;
        r.cx:=hoty;
        r.es:=Seg(mappa);
        r.dx:=Ofs(mappa);
        GEST_MOUSE (9)
      end
 end;

 Procedure TEXT_CURSOR1 (inizio, fine : word);
 begin
    r.bx:=1;
    r.cx:=inizio;
    r.dx:=fine;
    GEST_MOUSE(10)
 end;

 Procedure TEXT_CURSOR2 (sfondo, colore : byte);
 begin
    if (sfondo<16)and(colore<16)
     then
      begin
       r.bx:=0;
       r.cx:=$00ff;
       r.dx:=(colore*256)+(sfondo*4096);
       GEST_MOUSE(10)
      end
 end;

 Function X_REL : word;
 begin
    GEST_MOUSE (11);
    X_REL:=r.cx
 end;

 Function Y_REL : word;
 begin
    GEST_MOUSE (11);
    Y_REL:=r.dx
 end;

 Procedure RAPPORTO_MOUSE (oriz,vert : word);
 begin
    r.cx:=oriz;
    r.dx:=vert;
    GEST_MOUSE (15)
 end;

 Procedure NOWINDOW_MOUSE (x,y,x1,y1 : word);
 begin
    r.cx:=x;
    r.dx:=y;
    r.si:=x1;
    r.di:=y1;
    GEST_MOUSE (16)
 end;

 end.

(*---------------------------------------------------*)
(* PUT THE FOLLOWING CODE IN THE FILE TEST.PAS *)
program Test;
uses CRT, Mouse;
var e: Boolean;
    n: Word;
begin
  ClrScr;
  Reset_Mouse (e, n);
  if e then
    WriteLn ('Mouse Initialization Failed!')
  else begin
    Open_Mouse;
    repeat
      GotoXY (20, 25);
      Write ('Mouse: X = ', X_Mouse(False),
        '  Y = ', Y_Mouse(False), '  ');
      if Left_Button or Right_Button then begin
        Close_Mouse;    (* YOU MUST HIDE THE MOUSE BEFORE WRITING
                           SOMETHING TO VIDEO *)
        GotoXY (X_Mouse(False), Y_Mouse(False));
        if Left_Button then Write (#178) else Write (' ');
        Open_Mouse;     (* AND THEN MAKE IT VISIBLE AGAIN *)
      end;
    until Middle_Button or KeyPressed;
    Close_Mouse;
  end;
end.
