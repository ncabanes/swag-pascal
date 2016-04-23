
(* Author: Salvatore Meschini - http://www.ermes.it/pws/mesk -
smeschini@ermes.it*)
(* This procedure can replace crt.gotoxy so your executables will be 1648
bytes    smaller !!!*)
(* Note: my gotoxy is fast AS crt.gotoxy -> your benefit is in size not in
speed*)

Procedure GOtoXY(X,Y:byte);Assembler;

  var currentpage,rows,cols:byte;

 ASM
   MOV SI,40h
   MOV ES,SI
   MOV AL,ES:[0084h]   {Get Rows}
   INC AL
   MOV ROWS,AL
   MOV AL,ES:[004Ah]   {Get Columns}
   MOV COLS,AL
   MOV AL,ES:[0062h]
   MOV CURRENTPAGE,AL  (* Get current page *)
   MOV DL,X
   DEC DL
   CMP DL,0            (* Safety checks *)
   JB @OUTLIMITS       
   CMP DL,COLS
   JA @OUTLIMITS
   MOV DH,Y
   DEC DH
   CMP DH,0
   JB @OUTLIMITS
   CMP DH,ROWS
   JA @OUTLIMITS
   MOV AH,02h
   MOV BH,CURRENTPAGE
   INT 10h            (* Call BIOS to change position *)  
  @OUTLIMITS:
 END;


