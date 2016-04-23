{
    This is my unit for fast PCX 320x200 show, as its almost in ASM its really
fast. It has only a handicap: as you must load the entire file in memory
before you show it, the file size could not be greater than 64K:

    Sorry if I left some spanish comment.

=== Cut === }

UNIT FASTPCX;

{$G+}
{$s-}
{$r-}
{$i-}
{$x+}
{$O+}

(* Requires 286+ *)

INTERFACE
(*

PROCEDURE UNPACKPCX(Setpal:Boolean; True if you want the palette to be set
                     VAR FTE,DST;  FTE -> where the file is loaded
                                   DST -> whre to put it, usually Mem[$a000:0]
                      VAR Paleta   You got the palette here,allways  );
   Restricctions:

   - The file must be 320x200 exactly, no bigger, no smaller.
   - It must be a 256 colors PCX.
   - No more than 64K.

 Example:

             .....

  VAR P:Pointer;
      F:FILE;
      Paleta:ARRAY[0..767] OF Byte;
  BEGIN
   Assign(F,'PRUEBA.PCX');
   GetMem(P,65000);
   Reset(F,1);
   BlockRead(F,P^,FileSize(F);
   Close(F);
   ASM          { Cambio modo de video }
    MOV AX,$13
    INT $10
   END;
   UNPACKPCX(TRUE,P^,Mem[$a000:0],Paleta);
   { Desempaqueto PCX en P^ a RAM de video y cambio su paleta }
   REPEAT UNTIL Keypressed;
   FreeMem(P,65535);
                      ....

  *)

IMPLEMENTATION


PROCEDURE UNPACKPCX(PonerPaleta:Boolean;VAR FTE,DST;VAR Paleta);  (*Debe ser
un 320x200x256*) assembler;ASM
 PUSH DS        (* preservo Data Segment *)
 CLD            (* borro indicador de dirección *)
 XOR CX,CX      (* CX=0, para que en toda la rutina CH esté siempre a 0, tal
*)                (* que CX sea siempre igual a CL *)
 LDS SI,[FTE]   (* DS:SI --> FTE *)
 ADD SI,128     (* Salto cabecera *)
 LES DI,[DST]   (* ES:DI -- DST *)
 MOV DX,64000   (* Tengo que leer 64000 bytes *)
@BUCLE:
 MOV CL,DS:[SI] (* Tomo valor *)
 AND CL,0C0h
 CMP CL,0C0h    (* >=192 *)
 JZ @COMPRESSED (* si es así valor comprimido *)
 MOVSB          (* en caso contrario copio fuente en destino *)
 DEC DX         (* decremento DX pues falta uno menos *)
 JMP @NEXT      (* salto a siguiente *)
@COMPRESSED:
 MOV CL,DS:[SI] (* Recupero valor (el AND lo machacó)  *)
 AND CL,03Fh    (* resto 192 *)
 SUB DX,CX      (* quito tantos puntos como contiene CL *)
 INC SI         (* paso a siguiente valor *)
 LODSB          (* lo cargo *)
 REP STOSB      (* y lo vuelco CX veces *)
@NEXT:
 OR DX,DX       (* comparo DX con cero *)
 JNZ @BUCLE     (* y si no lo es paso a bucle *)


@PALET:
 INC SI         (* SALTO valor 12, que precede a paleta *)


 MOV CX,768        (* 768= 256*3 *)
 LES DI,[Paleta]   (* ES:DI --> Paleta *)
 REP MOVSB         (* copio paleta en "Paleta" *)

 MOV CX,768
 LDS SI,[Paleta]
@LOOP:
 MOV AL,DS:[SI]
 SHR AL,2
 MOV DS:[SI],AL
 INC SI
 LOOP @LOOP;          (* La divido por 4 , en el fichero PCX los valores de
                         paleta están multiplicados por 4 *)


 MOV AL,PonerPaleta  (* Compruebo si he de mostrarla *)
 OR AL,AL            (* 0=FALSE, otro valor =TRUE    *)
 JZ @FIN             (* En caso contario salto a FIN *)

 MOV   DX,3DAh   (* Espero retrazado *)
@Espera1:
 IN    AL,DX
 AND   AL,08h
 JNZ   @Espera1
@Espera2:
 IN    AL,DX
 AND   AL,08h
 JZ    @Espera2

 MOV DX,3C8h    (* Y la muestro *)
 XOR AL,AL
 OUT DX,AL
 INC DX
 MOV CX,768
 SUB SI,CX
 REP OUTSB

 (* Si se quiere evitar la niebla en modelos lentos como
    286 o 386sx 16Mhz conviene que la paleta en lugar de
    ponerse de golpe se ponga por partes, esperando un
    retrazado cada parte *)

@FIN:
 POP DS  (* recupero DS *)
END;

END.
