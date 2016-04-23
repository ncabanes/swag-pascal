
 {Fast FillChar and Move}
 {Posted By: Wesley Burns}
 {Email    : microcon@iafirca.com}
Unit MEM;

Interface
Procedure FillCharFast(Var X; Count: Word; Value:Byte); 
Procedure MoveFast(var source, dest; count: word); 

Implementation
Procedure MoveFast(var source, dest; count: word); Assembler;
asm
  push ds
  lds  si,source      {ds,si = source}
  les  di,dest        {es,di = dest}
  mov  cx,count       {cx = count}
  mov  ax,cx          {ax = count}
  cld
  shr  cx,2           {cx = count / 4}
  db   66h
  rep  movsw          {copy double words}
  mov  cl,al          {get rest bytes}
  and  cl,3
  rep  movsb          {copy rest}
  pop  ds
end;

Procedure FillCharFast(Var X; Count: Word; Value:Byte); Assembler;
Asm
  les di,x
  mov cx,Count
  shr cx,1
  mov al,value
  mov ah,al
  rep StoSW
  test count,1
  jz @end
  StoSB
@end:
end;

end.

 {Email: me if you have ANY questions about                                   }
 { : 64k DMA Sound Blaster Programming using XMS                              }
 { : Fast Memory Management                                                   }
 { : PCX using XMS                                                            }
 { : XMS Units                                                                }
 { : Pascal in general                                                        }
 { : Or if you have some fast procedures that you don't mind parting with.    }


