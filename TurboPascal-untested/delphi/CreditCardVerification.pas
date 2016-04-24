(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0401.PAS
  Description: Credit Card Verification
  Author: RON LOEWY
  Date: 01-02-98  07:34
*)

(******************************************************************************
*                                  CCardVer                                   *
*                                                                             *
* Credit Card Verification                                                    *
* (c) 1997, HyperAct, Inc. http://www.hyperact.com/                           *
* Written by Ron Loewy (rloewy@hyperact.com)                                  *
*                                                                             *
* To use - set the CardType, CardNumber and ExprDate properties and check the *
*          Valid property for results.                                        *
******************************************************************************)
unit CCardVer;

interface

uses
   classes
   ,sysUtils
   ;

type
   TCreditCardType = (ccAmex, ccVisa, ccMasterCard, ccDiscover, ccOther);
   TCreditCardValidity = (ccvValid, ccvInvalid, ccvExpired);
   TCreditCardVerify = class(TComponent)

   private
      FCardType : TCreditCardType;
      FExprDate : TDateTime;
      FCardNumber : String;

      function VerifyNumber : boolean;
      function VerifyDate : boolean;

   protected
      function  GetCardValidity : TCreditCardValidity;

   public
      constructor Create(AOwner : TComponent); override;
      procedure SetCardTypeByName(CardName : String);
      procedure SetCardExprMonYear(mon, year : integer);
      procedure SetExprDateFromStr(TheStr : String);

      property CardType : TCreditCardType read FCardType write FCardType;
      property ExprDate : TDateTime read FExprDate write FExprDate;
      property CardNumber : String read FCardNumber write FCardNumber;
      property Valid : TCreditCardValidity read GetCardValidity;

   end; { TCreditCardVerify class definition }

implementation

(******************************************************************************
*                          TCreditCardVerify.Create                           *
******************************************************************************)
constructor TCreditCardVerify.Create;
begin
   inherited Create(AOwner);
   CardType := ccOther;
end; { TCreditCardVerify.Create }

(******************************************************************************
*                     TCreditCardVerify.SetCardTypeByName                     *
******************************************************************************)
procedure TCreditCardVerify.SetCardTypeByName;
begin
   CardName := upperCase(CardName);
   if (CardName = 'AMEX') or (CardName = 'AMERICAN EXPRESS') or (CardName = 'OPTIMA') then
      CardType := ccAmex
   else if (CardName = 'VISA') then
      CardType := ccVisa
   else if (CardName = 'MASTERCARD') or (CardName = 'MC') or (CardName = 'EUROCARD') then
      CardType := ccMasterCard
   else if (CardName = 'DISCOVER') or (CardName = 'NOVOUS') then
      CardType := ccDiscover
   else
      CardType := ccOther;
end; { TCreditCardVerify.SetCardTypeByName }

(******************************************************************************
*                      TCreditCardVerify.GetCardValidity                      *
******************************************************************************)
function TCreditCardVerify.GetCardValidity;
begin
   result := ccvInvalid;
   if (not VerifyNumber) then
      exit;
   if (verifyDate) then
      result := ccvValid
   else
      result := ccvExpired;
end; { TCreditCardVerify.GetCardValidity }

(******************************************************************************
*                       TCreditCardVerify.VerifyNumber                        *
******************************************************************************)
function TCreditCardVerify.VerifyNumber;
var
   SubSum : integer;
   CheckSum : integer;
   i : integer;
   Number : String;
   TempChar : char;
   StartPos : integer;
   Mask : String;
begin
   result := false; // by default it is not valid 
   CheckSum := 0;
   Mask := '2121212121212121';

   Number := '';
   for i := 1 to length(CardNumber) do
      if (CardNumber[i] in ['0' .. '9']) then
         Number := Number + CardNumber[i];

   if (length(Number) < 13) then
      exit;

   while (length(Number) < 16) do
      Number := '0' + Number; 

   Number := lowerCase(trim(Number));

   tempChar := '0';
   startPos := 1;
   for i := 1 to length(Number) do begin
      if (Number[i] <> '0') then begin
         tempChar := Number[i];
         StartPos := i;
         break;
      end;
   end;

   case CardType of
      ccVisa : if (tempChar <> '4') then 
                  exit;
      ccDiscover : if (tempChar <> '6') then 
                  exit;
      ccMasterCard : if (tempChar <> '5') then 
                  exit;
      ccAmex : if (tempChar = '3') then begin
                  if (startPos < length(Number)) then begin
                     if (Number[StartPos + 1] <> '7') then
                        exit;
                  end else
                     exit;
               end else 
                  exit;
      ccOther : ;
   end; { case }

   for i := 1 to 16 do begin
      tempChar := Number[i];
      SubSum := (ord(TempChar) - 48) * (ord(Mask[i]) - 48);
      if (SubSum > 9) then
         dec(SubSum, 9);
      inc(checkSum, SubSum);
   end;

   if ((CheckSum mod 10) <> 0) then
      exit;

   result := true;

end; { TCreditCardVerify.VerifyNumber }

(******************************************************************************
*                        TCreditCardVerify.VerifyDate                         *
******************************************************************************)
function TCreditCardVerify.VerifyDate;
begin
   result := (ExprDate > now);
end; { TCreditCardVerify.VerifyDate }

(******************************************************************************
*                    TCreditCardVerify.SetCardExprMonYear                     *
******************************************************************************)
procedure TCreditCardVerify.SetCardExprMonYear;
var
   lastDate : byte;
   TheTime : TDateTime;

   (******************************************************************************
   *                                 IsLeapYear                                  *
   ******************************************************************************)
   function IsLeapYear(Year : Integer) : Boolean;
   begin
     Result := (Year mod 4 = 0) and (Year mod 4000 <> 0) and
       ((Year mod 100 <> 0) or (Year mod 400 = 0));
   end; { IsLeapYear }

begin
   if (word(year) < 100) then begin
      inc(year, 1900);
      if (year < 1900) then
         inc(year, 100);
   end;

   case mon of
    1
    ,3
    ,5
    ,7
    ,8
    ,10
    ,12 : LastDate := 31;
    4
    ,6
    ,9
    ,11 : LastDate := 30;
    2 : begin
         LastDate := 28;
         if (IsLeapYear(Year)) then
            inc(LastDate);
    end; { Feb. }
   end; { case }

   FExprDate := encodeDate(year, mon, lastDate);
   theTime := encodeTime(23, 59, 59, 0);
   FExprDate := FExprDate + TheTime; // last minute of the last date of the month
end; { TCreditCardVerify.SetCardExprMonYear }

(******************************************************************************
*                             SetExprDateFromStr                              *
* we assume the format MM/YY here                                             *
******************************************************************************)
procedure TCreditCardVerify.SetExprDateFromStr;
var
   mon, year : String;
   pSlash : integer;
begin
   pSlash := pos('/', TheStr);
   if (length(TheStr) = 4) then begin
      if (pSlash = 0) then begin
         Mon := copy(TheStr, 1, 2);
         Year := copy(TheStr, 3, 2);
      end else begin
         Mon := copy(TheStr, 1, pSlash - 1);
         Year := copy(TheStr, pSlash + 1, length(TheStr));
      end;
   end else if (length(TheStr) = 5) then begin
      mon := copy(TheStr, 1, 2);
      year := copy(TheStr, 4, 2);
   end;

   year := trim(year);
   mon := trim(mon);

   setCardExprMonYear(strToInt(Mon), strToInt(Year));
end; { SetExprDateFromStr }

(******************************************************************************
*                                    end.                                     *
******************************************************************************)
end.

