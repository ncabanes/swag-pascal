(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0043.PAS
  Description: Uninstalling TSR's
  Author: HOVIK A. MELIKIAN
  Date: 08-30-96  09:35
*)

{
>
> Using TP 7.0 for DOS, I can use the Keep() function to
> make a TSR.
>
> But... How do I get it to Un-TSR, ie. T & DSR?
>

Try this code:

----------------------------------------------------------------------
}

procedure Uninstall;
var
  PrevInstance: Word;
begin

{ This part must get the DSeg value from the resident instance of }
{ your program. If you don't know how to do this, contact me... }

  PrevInstance := GetPrevInstance;
  if PrevInstance = 0 then
    ErrorExit('Can't uninstall: program not found in memory.');

  asm
  mov	ds,PrevInstance	{ we completely switch to resident instance! }
  end;

  ShutDownProgram; 	{ do all necessary cleanup jobs. }
  RestoreVectors;	{ restore all vectors you hooked. }
			{ dangerous, if somebody hooked same vectors }
			{ after you... }

  asm
  mov   es,PrefixSeg
  mov   ah,49h
  int   21h		{ free DOS memory allocated for program }
  mov   es,PrefixSeg
  mov   es,es:[2Ch] 	
  mov   ah,49h
  int   21h		{ free DOS memory allocated for environment }
  mov	ax,seg @Data	{ switch back to this instance }
  mov	ds,ax
  end;
  WriteLn('Program uninstalled.');
  Halt(0);		{ yahoo! }
end;

