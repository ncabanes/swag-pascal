(*
 Well i jsut read up on the ET3000 verses teh ET4000, there are a few
 port hardware design changes with the BITS that make it vary hard to
 have a multipupose unit for both..
 Example:
  The 3000 can only address 512k of ram, only 3 bits were supplyed for
 this in the GDC reg.
  when the 4000 came out an extra bit was needed, instead of using
 bits 6 or 7 they move the read bits up one there by making the
 bank select a bit wide grouped instead of a funking bit order.
   but this also makes it hard for the ET4000 to work properly, you mite
 see the read bank get altered when when selecting the write bank using
 conventional 4 bit bank selecting..
 do you need code to detect a ET3000 chip ?

  if port[$3cc] and $01 <> 0 then Base := $03D0 else Base := $03b0;

  port[base+5] := $33;
  old := port[base+5];
  port[base+5] := old or $0f;
  new_Value := port[base+5];
  port[base+5] := old; { restore it }
   if new_vlaue = <> old THen {ET4000} else { ET3000}

 There is so much difference in the bank accessing between the two i
 would suggest a book like mine..
*)
