abeldup@unison.co.za (Abel du Plessis)

"Vitor Martins" <nop47019@mail.telecom.pt wrote:


How can I set the clock system time and date in a program  with Delphi 2.0
in Win 95
This works for us:


--------------------------------------------------------------------------------

//******************************************************************************
//Public function SetPCSystemTime changes the system date and time.
//Parameter(s): tDati  The new date and time
//Returns:      True if successful
//              False if not
//******************************************************************************
function SetPCSystemTime(tDati: TDateTime): Boolean;
var
   tSetDati: TDateTime;
   vDatiBias: Variant;
   tTZI: TTimeZoneInformation;
   tST: TSystemTime;
begin
   GetTimeZoneInformation(tTZI);
   vDatiBias := tTZI.Bias / 1440;
   tSetDati := tDati + vDatiBias;
   with tST do
   begin
        wYear := StrToInt(FormatDateTime('yyyy', tSetDati));
        wMonth := StrToInt(FormatDateTime('mm', tSetDati));
        wDay := StrToInt(FormatDateTime('dd', tSetDati));
        wHour := StrToInt(FormatDateTime('hh', tSetDati));
        wMinute := StrToInt(FormatDateTime('nn', tSetDati));
        wSecond := StrToInt(FormatDateTime('ss', tSetDati));
        wMilliseconds := 0;
   end;
   SetPCSystemTime := SetSystemTime(tST);
end;
