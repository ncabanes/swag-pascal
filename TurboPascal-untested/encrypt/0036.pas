unit Crypt32;
{
*************************************************************************
* Name:					Crypt32.Pas				  																		*
* Description:	32 bits encode/decode module			  										*
*								2^96 variants it is very high to try hack								*
*	Purpose:			Good for encrypting passwors and text										*
*	Security:			avoid use StartKey less than 256												*
*								if it use only for internal use you may use default 		*
*								key, but MODIFY unit before compiling										*
* Call:					Encrypted := Encrypt(InString,StartKey,MultKey,AddKey)	*
*								Decrypted := Decrypt(InString,StartKey)		  						*
* Parameters:		InString	= long string (max 2 GB) that need to encrypt	*
*														decrypt	  																	*
*								MultKey		= MultKey key			              							*
*								AddKey		= Second key			              							*
*								StartKey	= Third key			              								*
*								(posible use defaults from interface)			  						*
* Return:				OutString	= result string			  												*
* Editor:				Besr viewed with Tab stops = 2, Courier new							*
* Started:			01.08.1996					  																	*
* Revision:			22.05.1997 - ver.2.01 converted from Delphi 1						*
*								and made all keys as parameters, before only start key	*
* Platform:			Delphi 2.0, 3.0 				  															*
* 							work in Delphi 1.0, 2^48 variants, 0..255 strings				*
* Author:				Anatoly Podgoretsky				  														*
* 							Base alghoritm from Borland				  										*
* Address:			Vahe 4-31, Johvi, Estonia, EE2045, tel. 61-142    			*
*								kvk@estpak.ee					  																*
* Status:				Freeware, but any sponsor help will be appreciated here	*
*								need to buy books, shareware products, tools etc				*
*************************************************************************
* Modified:     Supports Delphi 1.0 & 2.0                         			*
*               Overflow checking removed                         			*
* By:           Martin Djernµs                                    			*
* e-mail:       djernaes@einstein.ot.dk                           			*
* web:          einstein.ot.dk/~djernaes                          			*
*************************************************************************
}
interface

const
  StartKey	= 981;  	{Start default key}
  MultKey	  = 12674;	{Mult default key}
  AddKey	  = 35891;	{Add default key}

function Encrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;
function Decrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;

implementation

{$R-}
{$Q-}
{*******************************************************
 * Standard Encryption algorithm - Copied from Borland *
 *******************************************************}
function Encrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;
var
  I : Byte;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + CHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(Result[I]) + StartKey) * MultKey + AddKey;
  end;
end;
{*******************************************************
 * Standard Decryption algorithm - Copied from Borland *
 *******************************************************}
function Decrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;
var
  I : Byte;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + CHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(InString[I]) + StartKey) * MultKey + AddKey;
  end;
end;
{$R+}
{$Q+}

end.


