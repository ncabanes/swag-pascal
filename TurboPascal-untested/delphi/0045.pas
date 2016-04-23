
The definitive Assert.  Better than the line numbers supplied w/ the
C/C++ Assert, this assert gives you the "find|error" logical address
of the calling module that called assert.  It returns the ssss:oooo
seg offset pair so you can find where the assert was called.  Again,
you can use the ifopt D+ if you wish but I prefer a define _NDEBUG
instead.  Hopefully this is the end-all assert. Use freely, just drop
me an e-mail at vandewb@wku.wkuvx1.edu if you find it useful.

Here it is...Jay Cole

{ Call if you need to verify implied conditions }
procedure Assert(assertedCond : boolean; const msgStr : string);

implementation
{$ifdef WINDOWS}
   uses WinProcs, SysUtils, WinTypes;
{$else}
   uses sysUtils;
{$endif}

{ Error when the assumption made is not correct. }
procedure Assert(assertedCond : boolean; const msgStr : string);
var 
   msgOut : array[0..300] of char;
   hexStr : array[0..30] of char;
   progSeg, progOfs : word;
   tmpStr : string;
begin
   { Get the logical segment used by the Find|Error menu option of
delphi }
   asm
      mov ax, [bp+04]            { Load physical segm of the calling
proc on call stack }
      mov es, ax
      mov ax, word ptr es:0      { Logical segm stored in 0th position
of physical seg }
      mov progSeg, ax            { Logical, not physical segm used in
Find|Error menu item }
      mov ax, [bp+02]
      mov progOfs, ax            { Physical ofs is used by find|error,
no translation needed }
   end;

   {$ifndef _NDEBUG} { Are we allowed to assert? }
   if (not assertedCond) then begin
      { construct msg\nat location ssss:oooo using the logical address
}
      StrPCopy(msgOut, msgStr);
      tmpStr := chr(10)+'at location
'+IntToHex(progSeg,4)+':'+IntToHex(progOfs,4);
      StrPCopy(hexStr, tmpStr);
      StrCat(msgOut, hexStr);
      {$ifdef WINDOWS}
         MessageBox(0, msgOut, 'Assert Failed',
MB_ICONSTOP+MB_SYSTEMMODAL+MB_OK);
      {$else}
         WriteLn('Assert Failed', msgOut);
      {$endif}
      { Now, terminate the program because of assertion problem }
      halt; 
   end;
   {$endif}
end;
