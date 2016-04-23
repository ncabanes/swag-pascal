{
Here's a neat little ditty I converted from a C++ tip I saw in a mag a few
years ago.  It tests to see if its own output has been redirected and
returns a 1 if TRUE (redirected) or a 0 if FALSE (not redirected). This
function includes a sample prog that demonstrates its use. SIDE NOTE: I
put this function in the U_FILE.pas.tpu for use with all of my home-grown
file related functions and procedures.

TEST WITH: Test_Red (enter)
   [you should see a NOT REDIRECTED msg, 10 lines and a FINISHED msg.]

TEST WITH: Test_Red > this.dat (enter)
   [you should see a REDIRECTED msg, (no lines) and a FINISHED msg
    and the output of the lines will be in the this.dat file]
}

program test_red;

{$A+,B-,D-,E-,F-,G-,I+,L-,N-,O-,P-,Q-,R-,S+,T-,V+,X-}
{$M 1024,0,655360}

{*******************************************************************!HDR**
** Function Name: fn_bRedirected()
** Description  : Determines if output has been redirected;
** Returns      : Integer to be treated as boolean;
** Calls        :
** Special considerations:
** Modification history:
** Created: 11/03/93 20:23
*********************************************************************!END}

function fn_bRedirected : Integer; Assembler; {Treated as BOOLEAN}
asm
  push  ds
  mov   ax,      prefixseg
  mov   ds,      ax
  xor   bx,      bx
  les   bx,      [bx + $34]
  mov   al,      es:[bx]
  mov   ah,      es:[bx +1]
  pop   ds
  cmp   al,      ah
  mov   ax,      1
  jne   @_exit
  xor   ax,      ax
 @_exit:
  {mov   @Result, AX}
end;

var
  Count    : Byte;
  hOutFile : text;

begin
  Assign(hOutFile, 'CON');
  ReWrite(hOutFile);
  if not (boolean(fn_bRedirected)) then
    writeln(hOutFile, 'Not Redirected')
  else
    writeln(hOutFile, 'Please wait while redirection is in progress');
  for Count := 1 to 10 do
    writeln('Line ', Count : 2);
  writeln(hOutFile, 'Finished!');
end.
