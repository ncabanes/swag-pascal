unit ESBRtns;

{ Miscellaneous Routines to enhance your 32-bit Delphi
	Programming including:

	- 16-bit Bit Lists
	- Block Operations
	- various String Routines and Conversions

	(c) 1997 ESB Consultancy

	v1.00	First Public Release on 15 Aug 1997 to celebrate our WebSite's 
					First Birthday.

	These routines are used by ESB Consultancy within the
	development of their Customised Application.

	ESB Consultancy retains full copyright.

	ESB Consultancy grants users of this code royalty free rights
	to do with this code as they wish.

	We does ask that if this code helps you in you development
	that you send as an email mailto:esb@gold.net.au or even
	a local postcard. It would also be nice if you gave us a
	mention in your About Box or Help File.

	ESB Consultancy Home Page: http://www.gold.net.au/~esb

	Mail Address: PO Box 2259, Boulder, WA 6432 AUSTRALIA
}

interface

const
	MaxByte: Byte = 255;
	MaxShortInt: ShortInt = 127;
	MaxWord: Word = 65535;
	MaxReal: Real = 1.7e38;
	MaxSingle: Single = 3.4e38;
	MaxDouble: Double = 1.7e308;
	MaxExtended: Extended = 1.1e4932;
	MaxComp: Comp = 9.2e18;

	MinByte: Byte = 0;
	MinShortInt: ShortInt = -128;
	MinInt: Integer = -32768;
	MinWord: Word = 0;
	MinLongInt: LongInt = $80000000;
	MinReal: Real = 2.9e-39;
	MinSingle: Single = 1.5e-45;
	MinDouble: Double = 5.0e-324;
	MinExtended: Extended = 3.4e-4932;

const
	NumPadCh: Char = ' '; // Character to use for Left Hand Padding of Numerics
//	NumPosSign: Boolean = False; //Signals whether a '+' sign should be shown with positives

type
	TBitList = Word; // Used for a Bit List of 16 bits from 15 -> 0

type
	String16	=	string [16];


{*** Bit Manipulation ***}

procedure ClearAllBits (var Body: TBitList);

{ Sets all Bits to 0 }

procedure SetAllBits (var Body: TBitList);

{ Sets all Bits to 1 }

procedure FlipAllBits (var Body: TBitList);

{ Flips all Bits, i.e 1 -> 0 and 0 -> 1 }

procedure ClearBit (var Body: TBitList; const I: Byte);

{ Sets specified Bit to 0 }

procedure SetBit (var Body: TBitList; const I: Byte);

{ Sets specified Bit to 1 }

procedure FlipBit (var Body: TBitList; const I: Byte);

{ Flips specified Bit, i.e. 0 -> 1 and 1 -> 0 }

function BitIsSet (const Body: TBitList; const I: Byte): Boolean;

{ Returns True if Specified Bit is 1 }

procedure ReverseBits (var Body: TBitList); register;

{ Reverses the Bit List, i.e. Bit 15 <-> Bit 0, Bit 14 <-> Bit1, etc. }

function Bits2Str (const Body: TBitList): String16;

{ Converts a Bit list to a string of '1' and '0'. }

function Str2Bits (const S: String16): TBitList; register;

{ Converts a string of '1' and '0' into a BitList. }

function BitsSet (const Body: TBitList): Byte; register;

{ Returns a number from 0 -> 16 indicating the number of Bits Set }

function Booleans2BitList (const B: array of Boolean): TBitList;

{ Converts an Array of Boolean into a BitList }

{*** Block Operations ***}

procedure ESBMoveOfs (const Source; const Ofs1: Integer;
	var Dest; const Ofs2: Integer; const Size: Integer);

{ Moves Size bytes from Source starting at Ofs1 to destination
	starting at Ofs 2 using fast dword moves. BASM }

procedure ESBClear (var Dest; const Size: Integer);

{ Fills given structure with specified number of 0 values,
	effectively clearing it.	}

procedure ESBSet (var Dest; const Size: Integer);

{ Fills given structure with specified number of $FF values,
	effectively setting it. }

{*** String to Integer Types ***}

function Str2LInt (const S: String): LongInt;

{ Converts a String into a LongInt }

function Str2Byte (const S: String): Byte;

{ Converts a String into a Byte }

function Str2SInt (const S: String): ShortInt;

{ Converts a String into a ShortInt }

function Str2Int (const S: String): Integer;

{ Converts a String into an Integer }

function Str2Word (const S: String): Word;

{ Converts a String into a Word }

{*** Integer Types to Strings ***}

function LInt2Str (const L: LongInt; const Len: Byte): String;

{ Converts a LongInt into a String of length N with
	NumPadCh Padding to the Left }

function Byte2Str (const L: LongInt; const Len: Byte): String;

{ Converts a LongInt into a String of length N with
	NumPadCh Padding to the Left }

function LInt2ZStr (const L: LongInt; const Len: Byte): String;

{ Converts a LongInt into a String of length N with
	NumPadCh Padding to the Left }

function LInt2ZBStr (const L: LongInt; const Len: Byte): String;

{ Converts a LongInt into a String of length N with
	NumPadCh Padding to the Left, with blanks returned
	if Value is 0 }

function LInt2CStr (const L : LongInt; const Len : Byte): string;

{ Convert a LongInt into a Comma'ed String of length Len,
	with NumPadCh Padding to the Left }

function LInt2EStr (const L: LongInt): String;

{ Convert a LongInt into an exact String, No Padding }

function LInt2ZBEStr (const L: LongInt): String;

{ Convert a LongInt into an exact String, No Padding,
	with null returned if Value is 0 }

function LInt2CEStr (const L : LongInt): string;

{ Convert a LongInt into a Comma'ed String without Padding }

{*** Extended Reals to Strings ***}

function Ext2EStr (const E: Extended; const Decimals: Byte): String;

{ Converts an Extended Real into an exact String, No padding,
	with given number of Decimal Places }

function Ext2EStr2 (const E: Extended; const Decimals: Byte): String;

{ Converts an Extended Real into an exact String, No padding,
	with at most given number of Decimal Places }

function Ext2CEStr (const E: Extended; const Decimals: Byte): String;

{ Converts an Extended Real into an exact String, No padding,
	with given number of Decimal Places, with Commas separating
	thousands }

function Double2EStr (const D: Double; const Decimals: Byte): String;

{ Converts a Double Real into an exact String, No padding,
	with given number of Decimal Places }

function Single2EStr (const S: Single; const Decimals: Byte): String;

{ Converts a Single Real into an exact String, No padding,
	with given number of Decimal Places }

function Comp2EStr (const C: Comp): String;

{ Converts a Comp (Integral) Real into an exact String, No padding }

function Comp2CStr (const C : Comp; const Len : Byte): string;

{ Converts a Comp (Integral) Real into a Comma'ed String of
	specified Length, Len, NumPadCh used for Left padding }

function Comp2CEStr (const C : Comp): string;

{ Converts a Comp (Integral) Real into a Comma'ed String
	without Padding }

function Ext2Str (const E: Extended; const Len, Decimals: Byte): String;

{ Converts an Extended Real into a String of specified Length, using
	NumPadCh for Left Padding, and with Specified number of Decimals }

function Double2Str (const D: Double; const Len, Decimals: Byte): String;

{ Converts a Double Real into a String of specified Length, using
	NumPadCh for Left Padding, and with Specified number of Decimals }

function Single2Str (const S: Single; const Len, Decimals: Byte): String;

{ Converts an Single Real into a String of specified Length, using
	NumPadCh for Left Padding, and with Specified number of Decimals }

function Comp2Str (const C: Comp; const Len : Byte): String;

{ Converts a Comp (Integral) Real into a String of specified Length, using
	NumPadCh for Left Padding }

{*** Strings to Extended Reals ***}

function Str2Ext (const S: String): Extended;

{ Converts a String into an Extended Real }

{*** Extra String Operations ***}

function LeftStr (const S : string; const N : Integer): string;

{ Returns the substring consisting of the first N characters of S.
	If N > Length (S) then the substring = S. }

function RightStr (const S : string; const N : Integer): string;

{ Returns the substring consisting of the last N characters of S.
	If N > Length (S) then the substring = S. }

function LeftTillStr (const S : string; const Ch : Char): string;

{ Returns the substring consisting of the characters from S
	up to but not including the specified one.  If the specified
	character is not found then a null string is returned. }

function RightAfterStr (const S : String; const N : Integer): String;

	{ Returns the sub-string to the right AFTER the first
		N Characters. if N >= Length (S) then a Null string
		is returned. }

function RightAfterChStr (const S : String; const Ch : Char): String;

	{ Returns the sub-string to the right AFTER the first
		ocurrence of specifiec character.  If Ch not found then
		a Null String is returned. }

function StripTChStr (const S : string; const Ch : Char): string;

{ Returns the String with all specified trailing characters	removed. }

function StripLChStr (const S : string; const Ch : Char): string;

{ Returns the String with all specified leading characters removed. }

function StripChStr (const S : string; const Ch : Char): string;

{ Returns the String with all specified leading and trailing
	characters removed. }

function ReplaceChStr (const S : string; const OldCh, NewCh : Char): string;

{ Returns the String with all occurrences of OldCh character
	replaced with NewCh character. }

function FillStr (const Ch : Char; const N : Integer): string;

{ Returns a string composed of N occurrences of Ch. }

function BlankStr (const N : Integer): string;

{ Returns a string composed of N blank spaces (i.e. #32) }

function DashStr (const N : Integer): String;

{ Returns a string composed of N occurrences of '-'. }

function DDashStr (const N : Integer): string;

{ Returns a string composed of N occurrences of '='. }

function LineStr (const N : Integer): string;

{ Returns a string composed of N occurrences of '─' (196). }

function DLineStr (const N : Integer): string;

{ Returns a string composed of N occurrences of '═' (205). }

function StarStr (const N : Integer): string;

{ Returns a string composed of N occurrences of '*'. }

function HashStr (const N : Integer): string;

{ Returns a string composed of N occurrences of '#'. }

function PadRightStr (const S : string; const Len : Integer): string;

{ Returns a string with blank spaces added to the end of the
	string until the string is of the given length.
	If Length (S) >= Len then NO padding occurs, and S is returned. }

function PadLeftStr (const S : string; const Len : Integer): string;

{ Returns a string with blank spaces added to the beginning of the
	string until the string is of the given length.
	If Length (S) >= Len then NO padding occurs, and S is returned. }

function CentreStr (const S : String; const Len : Integer): String;

{ Returns a string with blank spaces added to the beginning and
	end of the string to in effect centre the string within the
	given length.
	If Length (S) >= Len then NO padding occurs, and S is returned. }

function PadChRightStr (const S : string; const Ch : Char;
	const Len : Integer): string;

{ Returns a string with specified characters added to the end of the
	string until the string is of the given length.
	If Length (S) >= Len then NO padding occurs, and S is returned. }

function PadChLeftStr (const S : string; const Ch : Char;
	const Len : Integer): string;

{ Returns a string with specified characters added to the beginning of the
	string until the string is of the given length.
	If Length (S) >= Len then NO padding occurs, and S is returned. }

function CentreChStr (const S : String; const Ch : Char;
	const Len : Integer): String;

{ Returns a string with specified characters added to the beginning and
	end of the string to in effect centre the string within the
	given length.
	If Length (S) >= Len then NO padding occurs, and S is returned. }

function LeftAlignStr (const S : string; const N : Integer): string;

function RightAlignStr (const S : string; const N : Integer): string;

function Boolean2TF (const B : Boolean): Char;

{ Converts a Boolean Value into the corresponding Character:
		True 	-> 'T'
		False 	-> 'F'
}

function Boolean2YN (const B : Boolean): Char;

{ Converts a Boolean Value into the corresponding Character:
		True 	-> 'Y'
		False 	-> 'N'
 }

function Boolean2Char (const B : Boolean;
	TrueChar, FalseChar: Char): Char;

{ Converts a Boolean Value into the corresponding Character:
		True 	->  TrueChar
		False 	->  FalseChar
 }

function TF2Boolean (const Ch : Char): Boolean;

 { Converts a Character Value into its corresponding Boolean value:

			'T', 't'	-> True
			Otherwise -> False
 }

function YN2Boolean (const Ch : Char): Boolean;

 { Converts a Character Value into its corresponding Boolean value:

			'Y', 'y'	-> True
			Otherwise -> False
 }

implementation

uses
	SysUtils;

{**** Bit Manipulation ****}

procedure ClearAllBits (var Body: TBitList);

begin
	Body:= $0000
end;

procedure SetAllBits (var Body: TBitList);

begin
	Body:= $FFFF
end;

procedure FlipAllBits (var Body: TBitList);

begin
	Body:= Body xor $FFFF
end;

procedure ClearBit (var Body: TBitList; const I: Byte);

begin
	Body:= Body and (not ($0001 shl I))
end;

procedure SetBit (var Body: TBitList; const I: Byte);

begin
	Body:= Body or ($0001 shl I)
end;

procedure FlipBit (var Body: TBitList; const I: Byte);

begin
	Body:= Body xor ($0001 shl I)
end;

function BitIsSet (const Body: TBitList; const I: Byte): Boolean;

begin
	Result := (Body and ($0001 shl I)) <> 0
end;

function Bits2Str (const Body: TBitList): String16;
var
	I: Integer;
begin
	SetLength (Result, 16);
	for I := 0 to 15 do
		if BitIsSet (Body, I) then
			Result [I + 1] := '1'
		else
			Result [I + 1] := '0';
end;

procedure ReverseBits (var Body: TBitList); assembler;
asm
		push esi
		push ebx

		mov  esi, eax
		mov  bx, Word Ptr [esi]
		sub	ax, ax		// clear ax for out going bit list
		mov	cx, 16		// 16 iterations needed for a word
		sub	dx, dx		// clear dx for additions

	@1:
		shl	ax, 1		// move all of ax right
		shr	bx, 1		// move lsb into CF
		adc	ax, dx		// add in the carry bit
		loop @1

		mov Word Ptr [esi], ax

		pop 	ebx
		pop 	esi
end;

function Str2Bits (const S: String16): TBitList; assembler;
asm
		push esi
		push ebx
		mov	esi, eax

		lodsb			// Read Length
		sub	ah, ah
		mov	cx, ax		// & store in CX
		sub	bx, bx		// clear BX for bit list construction
		mov	dl, '0'		// for comparisons

	@1:	lodsb
		shl	bx, 1		// mov bx along
		cmp	al, dl
		je	@2
		add	bx, 1		// otherwise add 1
	@2:	loop @1;
		mov	ax, bx		// result must be in ax

		pop 	ebx
		pop 	esi
end;

function BitsSet (const Body: TBitList): Byte; assembler;
asm
		mov  dx, ax		// Place BitList into BX
		xor	ax, ax		// Clear AX
		mov  cx, 16		// Move 16 into CX
	@2:	shl  dx, 1		// Shift Left
		jnc	@1			// if no carry then no increment
		inc	ax
	@1:	loop @2
end;

function Booleans2BitList (const B: array of Boolean): TBitList;
var
	I: Integer;
begin
	Result := 0;
	for I := 0 to High (B) do
		if B [I] then
			SetBit (Result, 0);
end;

procedure ESBMoveOfs (const Source; const Ofs1: Integer;
	var Dest; const Ofs2: Integer; const Size: Integer);
asm
	   push    esi
	   push    edi

	   mov     esi, Source
	   add	 esi, Ofs1
	   mov     edi, Dest
	   add	 edi, Ofs2

	   mov     eax, Size
	   mov     ecx, eax

	   cmp     edi,esi
	   jg      @@DOWN
	   je      @@EXIT

	   sar     ecx,2           //copy count DIV 4 dwords
	   js      @@EXIT

	   rep     movsd

	   mov     ecx,eax
	   and     ecx,03h
	   rep     movsb           //copy count MOD 4 bytes
	   jmp     @@EXIT

@@DOWN:
	   lea     esi,[esi+ecx-4] // point ESI to last dword of source
	   lea     edi,[edi+ecx-4] // point EDI to last dword of dest

	   sar     ecx,2        	  // copy count DIV 4 dwords
	   js      @@EXIT
	   std
	   rep     movsd

	   mov     ecx,eax
	   and     ecx,03h         // Copy count MOD 4 bytes
	   add     esi,4-1         // point to last byte of rest
	   add     edi,4-1
	   rep     movsb
	   cld
@@EXIT:
	   pop     edi
	   pop     esi
end;

procedure ESBClear (var Dest; const Size: Integer);
begin
	FillChar (Dest, Size, $00);
end;

procedure ESBSet (var Dest; const Size: Integer);
begin
	FillChar (Dest, Size, $FF);
end;

function Str2LInt (const S: String): LongInt;
begin
	try
		Result := StrToInt (S);
	except
		Result := 0;
	end;
end;

function Str2Byte (const S: String): Byte;
var
	L: LongInt;
begin
	L := Str2LInt (S);
	if L > MaxByte then
		Result := MaxByte
	else if L < MinByte then
		Result := MinByte
	else
		Result := L;
end;

function Str2SInt (const S: String): ShortInt;
var
	L: LongInt;
begin
	L := Str2LInt (S);
	if L > MaxShortInt then
		Result := MaxShortInt
	else if L < MinShortInt then
		Result := MinShortInt
	else
		Result := L;
end;

function Str2Int (const S: String): Integer;
var
	L: LongInt;
begin
	L := Str2LInt (S);
	if L > MaxInt then
		Result := MaxInt
	else if L < MinInt then
		Result := MinInt
	else
		Result := L;
end;

function Str2Word (const S: String): Word;
var
	L: LongInt;
begin
	L := Str2LInt (S);
	if L > MaxWord then
		Result := MaxWord
	else if L < MinWord then
		Result := MinWord
	else
		Result := L;
end;

function LInt2EStr (const L: LongInt): String;
begin
	try
		Result := IntToStr (L);
	except
		Result := '';
	end;
end;

function LInt2ZBEStr (const L: LongInt): String;
begin
	if L = 0 then
		Result := ''
	else
		try
			Result := IntToStr (L);
		except
			Result := '';
		end;
end;

function Ext2EStr (const E: Extended; const Decimals: Byte): String;
begin
	try
		Result := FloatToStrF (E, ffFixed, 18, Decimals)
	except
		Result := '';
	end;
end;

function Ext2EStr2 (const E: Extended; const Decimals: Byte): String;
begin
	Result := Ext2EStr (E, Decimals);
	Result := StripTChStr (Result, '0');
	if Length (Result) > 0 then
		if Result [Length (Result)] = DecimalSeparator then
			Result := LeftStr (Result, Length (Result) - 1);
end;

function Ext2CEStr (const E: Extended; const Decimals: Byte): String;
begin
	try
		Result := FloatToStrF (E, ffNumber, 18, Decimals)
	except
		Result := '';
	end;
end;

function Double2EStr (const D: Double; const Decimals: Byte): String;
begin
	try
		Result := FloatToStrF (D, ffFixed, 15, Decimals)
	except
		Result := '';
	end;
end;

function Single2EStr (const S: Single; const Decimals: Byte): String;
begin
	try
		Result := FloatToStrF (S, ffFixed, 7, Decimals)
	except
		Result := '';
	end;
end;

function Comp2EStr (const C: Comp): String;
begin
	try
		Result := FloatToStrF (C, ffFixed, 18, 0)
	except
		Result := '';
	end;
end;

function Str2Ext (const S: String): Extended;
begin
	try
		Result := StrToFloat (S);
	except
		Result := 0;
	end;
end;

function LInt2Str (const L: LongInt; const Len: Byte): String;
begin
	try
		Result := IntToStr (L);
	except
		Result := '';
	end;
	Result := PadChLeftStr (LeftStr (Result, Len), NumPadCh, Len);
end;

function Byte2Str (const L: LongInt; const Len: Byte): String;
begin
	try
		Result := IntToStr (L);
	except
		Result := '';
	end;
	Result := PadChLeftStr (LeftStr (Result, Len), NumPadCh, Len);
end;

function LInt2ZBStr (const L: LongInt; const Len: Byte): String;
begin
	Result := LInt2ZBEStr (L);
	Result := PadChLeftStr (LeftStr (Result, Len), NumPadCh, Len);
end;

function LInt2ZStr (const L: LongInt; const Len: Byte): String;
begin
	Result := LInt2EStr (L);
	Result := PadChLeftStr (LeftStr (Result, Len), '0', Len);
end;

function LInt2CStr (const L : LongInt; const Len : Byte): string;
begin
	Result := LInt2CEStr (L);
	Result := PadChLeftStr (LeftStr (Result, Len), NumPadCh, Len);
end;

function LInt2CEStr (const L : LongInt): string;
var
	LS, L2, I : Integer;
	Temp : string;
begin
	Result := LInt2EStr (L);
	LS := Length (Result);
	L2 := (LS - 1) div 3;
	Temp := '';
	for I := 1 to L2 do
		Temp :=  ThousandSeparator + Copy (Result, LS - 3 * I + 1, 3) + Temp;
	Result := Copy (Result, 1, (LS - 1) mod 3 + 1) + Temp;
end;

function Comp2CStr (const C : Comp; const Len : Byte): string;
begin
	Result := Comp2CEStr (C);
	Result := PadChLeftStr (LeftStr (Result, Len), NumPadCh, Len);
end;

function Comp2CEStr (const C : Comp): string;
var
	LS, L, I : Integer;
	Temp : string;
begin
	Result := Comp2EStr (C);
	LS := Length (Result);
	L := (LS - 1) div 3;
	Temp := '';
	for I := 1 to L do
		Temp :=  ThousandSeparator + Copy (Result, LS - 3 * I + 1, 3) + Temp;
	Result := Copy (Result, 1, (LS - 1) mod 3 + 1) + Temp;
end;

function Ext2Str (const E: Extended; const Len, Decimals: Byte): String;
begin
	try
		Result := FloatToStrF (E, ffFixed, 18, Decimals)
	except
		Result := '';
	end;
	Result := PadChLeftStr (LeftStr (Result, Len), NumPadCh, Len);
end;

function Double2Str (const D: Double; const Len, Decimals: Byte): String;
begin
	try
		Result := FloatToStrF (D, ffFixed, 15, Decimals)
	except
		Result := '';
	end;
	Result := PadChLeftStr (LeftStr (Result, Len), NumPadCh, Len);
end;

function Single2Str (const S: Single; const Len, Decimals: Byte): String;
begin
	try
		Result := FloatToStrF (S, ffFixed, 7, Decimals)
	except
		Result := '';
	end;
	Result := PadChLeftStr (LeftStr (Result, Len), NumPadCh, Len);
end;

function Comp2Str (const C: Comp; const Len: Byte): String;
begin
	try
		Result := FloatToStrF (C, ffFixed, 18, 0)
	except
		Result := '';
	end;
	Result := PadChLeftStr (LeftStr (Result, Len), NumPadCh, Len);
end;

function LeftStr (const S : string; const N : Integer): string;
begin
	Result := Copy (S, 1, N);
end;

function LeftAlignStr (const S : string; const N : Integer): string;
begin
	Result := PadRightStr (Copy (S, 1, N), N);
end;

function RightAlignStr (const S : string; const N : Integer): string;
begin
	Result := PadLeftStr (Copy (S, 1, N), N);
end;

function RightStr (const S : string; const N : Integer): string;
var
	M: Integer;
begin
	M := Length (S) - N + 1;
	if M < 1 then
		M := 1;
	Result := Copy (S, M, N);
end;

function LeftTillStr (const S : string; const Ch : Char): string;
var
	M: Integer;
begin
	M := Pos (Ch, S);
	if M < 2 then
		Result := ''
	else
		Result := Copy (S, 1, M - 1);
end;

function RightAfterStr (const S : String; const N : Integer): String;
begin
	Result := Copy (S, N + 1, Length (S) - N );
end;

function RightAfterChStr (const S : String; const Ch : Char): String;
var
	M: Integer;
begin
	M := Pos (Ch, S);
	if M = 0 then
		Result := ''
	else
		Result := Copy (S, M + 1, Length (S) - M);
end;

function StripChStr (const S : string; const Ch: Char): string;
begin
	Result := StripTChStr (StripLChStr (S, Ch), Ch);
end;

function StripTChStr (const S : string; const Ch: Char): string;
var
	Len: Integer;
begin
	Len := Length (S);
	while (Len > 0) and (S [Len] = Ch) do
		Dec (Len);
	if Len = 0 then
		Result := ''
	else
		Result := Copy (S, 1, Len);
end;

function StripLChStr (const S : string; const Ch: Char): string;
var
	I, Len: Integer;
begin
	Len := Length (S);
	I := 1;
	while (I <= Len) and (S [I] = Ch) do
		Inc (I);
	if (I > Len) then
		Result := ''
	else
		Result := Copy (S, I, Len - I + 1);
end;

function ReplaceChStr (const S : string;
	const OldCh, NewCh : Char): string;
var
	I: Integer;
begin
	Result := S;
	if OldCh = NewCh then
		Exit;
	for I := 1 to Length (S) do
		if S [I] = OldCh then
			Result [I] := NewCh;
end;

function FillStr (const Ch : Char; const N : Integer): string;
begin
	SetLength (Result, N);
	FillChar (Result [1], N, Ch);
end;

function BlankStr (const N : Integer): string;
begin
	Result := FillStr (' ', N);
end;

function DashStr (const N : Integer): string;
begin
	Result := FillStr ('-', N);
end;

function DDashStr (const N : Integer): string;
begin
	Result := FillStr ('=', N);
end;

function LineStr (const N : Integer): string;
begin
	Result := FillStr (#196, N);
end;

function DLineStr (const N : Integer): string;
begin
	Result := FillStr (#205, N);
end;

function StarStr (const N : Integer): string;
begin
	Result := FillStr ('*', N);
end;

function HashStr (const N : Integer): string;
begin
	Result := FillStr ('#', N);
end;

function PadRightStr (const S : string; const Len : Integer): string;
var
	N: Integer;
begin
	N := Length (S);
	if N < Len then
		Result := S + BlankStr (Len - N)
	else
		Result := S;
end;

function PadLeftStr (const S : string; const Len : Integer): string;
var
	N: Integer;
begin
	N := Length (S);
	if N < Len then
		Result := BlankStr (Len - N) + S
	else
		Result := S;
end;

function CentreStr (const S : String; const Len : Integer): String;
var
	N, M: Integer;
begin
	N := Length (S);
	if N < Len then
	begin
		M := Len - N;
		if Odd (M) then
			Result := BlankStr (M div 2) + S
				+ BlankStr (M div 2 + 1)
		else
			Result := BlankStr (M div 2) + S
				+ BlankStr (M div 2);
	end
	else
		Result := S;
end;

function PadChRightStr (const S : string; const Ch : Char;
	const Len : Integer): string;
var
	N: Integer;
begin
	N := Length (S);
	if N < Len then
		Result := S + FillStr (Ch, Len - N)
	else
		Result := S;
end;

function PadChLeftStr (const S : string; const Ch : Char;
	const Len : Integer): string;
var
	N: Integer;
begin
	N := Length (S);
	if N < Len then
		Result := FillStr (Ch, Len - N) + S
	else
		Result := S;
end;

function CentreChStr (const S : String; const Ch : Char;
	const Len : Integer): String;
var
	N, M: Integer;
begin
	N := Length (S);
	if N < Len then
	begin
		M := Len - N;
		if Odd (M) then
			Result := FillStr (Ch, M div 2) + S
				+ FillStr (Ch, M div 2 + 1)
		else
			Result := FillStr (Ch, M div 2) + S
				+ FillStr (Ch, M div 2);
	end
	else
		Result := S;
end;

function Boolean2TF (const B : Boolean): Char;
begin
	if B then
		Result := 'T'
	else
		Result := 'F';
end;

function Boolean2YN (const B : Boolean): Char;
begin
	if B then
		Result := 'Y'
	else
		Result := 'N';
end;

function Boolean2Char (const B : Boolean;
	TrueChar, FalseChar: Char): Char;
begin
	if B then
		Result := TrueChar
	else
		Result := FalseChar;
end;

function TF2Boolean (const Ch : Char): Boolean;
begin
	Result := Ch in ['T', 't'];
end;

function YN2Boolean (const Ch : Char): Boolean; assembler;
begin
	Result := Ch in ['Y', 'y'];
end;

end.
