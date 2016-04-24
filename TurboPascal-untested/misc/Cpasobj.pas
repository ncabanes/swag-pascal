(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0002.PAS
  Description: CPAS-OBJ.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

REYNIR STEFANSSON

> Does anyone know of any way to convert a .TPU to a .BIN File to
> use BIN2OBJ.EXE and then load it as an external? Any help
> appreciated...

It's a bit round-the-block, but you might get some exercise out of it,
assuming you have the source code:

1) Smash the source into C With a code converter.

2) Declare the Procedures as `void far PASCAL' and the Functions as
   `appropriate_Type far PASCAL'.

3) Compile it With Turbo C or similar.


