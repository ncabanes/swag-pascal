(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0066.PAS
  Description: Direct access to a Stream
  Author: DAVID STIDOLPH
  Date: 11-24-95  10:16
*)

(*
If you have the VCL source look at TMemoryStream - it is pretty efficient
for 286 code.  If you are willing to only run on 386 machines you can use
386 32-bit addressing in assembly code to access the data.  Following the
includion I have placed some assembly code I have written to do this.  It
compiles under MASM and is linked with the {$L} directive.  The reason I
wrote this code was for a WinG module I am still working on.  Anyone is
welcome to use this code, but I would like to see work done using it.

>The TMemoryStream has a property TMemoryStream.Memory, which returns a
>pointer to the actual location of the data in memory. To access the 
>first byte I could just use TMemoryStream.Memory^
>
>The problem is: If I want to for example get bytes 15 to 21 out of the
>stream, is there a way to point to the location of this data?
>I do not want to use the Seek/Read function, as this is a lot slower
>than using direct memory access.
*)

{$L move.obj}

procedure Move32(pSrc: Pointer; srcOffset: Longint; pDest: Pointer;
destOffset: Longint; len: Longint); external;

Assembly code (move.asm)
	.MODEL large, PASCAL
	.386
	OPTION SCOPED

LPBYTE TYPEDEF FAR PTR BYTE

Move32 PROTO FAR PASCAL,
		 pSrc:LPBYTE, srcOffset:DWORD,
		 pDest: LPBYTE, destOffset:DWORD,
		 len:DWORD

	.Code

Move32	PROC FAR PASCAL USES ds es esi edi,
		pSrc: LPBYTE, srcOffset:DWORD,
		pDest: LPBYTE, destOffset:DWORD,
		len:DWORD
	cld			;move forward through memory
	mov	esi,0		;clear index registers - noteably the top of
	mov	edi,0		;the 32 bit (upper 16 bits) registers.

	lds	si,pSrc		;load ds/si with pointer to base source
	les	di,pDest	;load es/di with pointer to base destination
	add	esi,srcOffset	;add in offset to desired point
	add	edi,destOffset	;add in offset to desired point
	mov	ecx,len		;get the length of the move
	shr	ecx,2		;divide by 4 for DWORD moves
	rep	movsd		;if ecx is zero no move is done
	mov	ecx,len		;pick up length to do remainder
	and	ecx,3		;only move 0-3 bytes
	rep	movsb		;if ecx is zero no move is done
	retf			;far return
Move32	ENDP

END

