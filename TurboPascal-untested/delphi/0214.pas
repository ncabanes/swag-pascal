{
>
> Has anyone an algorithm to determine moveable feasts - such as Easter -
> which is calculated by the year? by any other method? 
  
Popular question this past 2 days. Here is our kcEaster function from our KingCalendar product. Just pass it the year and it will
return a TDateTime for Easter. Enjoy the code, it was a fun to write<G> 
  
function kcEaster( nYear: Integer ): TDateTime;
var
   nMonth, nDay, nMoon, nEpact, nSunday, nGold, nCent, nCorx, nCorz: Integer;
 begin
 
    { The Golden Number of the year in the 19 year Metonic Cycle }
    nGold := ( ( nYear mod 19 ) + 1  );
 
    { Calculate the Century }
    nCent := ( ( nYear div 100 ) + 1 );
 
    { No. of Years in which leap year was dropped in order to keep in step
      with the sun }
    nCorx := ( ( 3 * nCent ) div 4 - 12 );

    { Special Correction to Syncronize Easter with the moon's orbit }
    nCorz := ( ( 8 * nCent + 5 ) div 25 - 5 );
 
    { Find Sunday }
    nSunday := ( ( 5 * nYear ) div 4 - nCorx - 10 );
 
    { Set Epact (specifies occurance of full moon }
    nEpact := ( ( 11 * nGold + 20 + nCorz - nCorx ) mod 30 );
 
    if ( nEpact < 0 ) then
       nEpact := nEpact + 30;
 
    if ( ( nEpact = 25 ) and ( nGold > 11 ) ) or ( nEpact = 24 ) then
       nEpact := nEpact + 1;
 
    { Find Full Moon }
    nMoon := 44 - nEpact;
 
    if ( nMoon < 21 ) then
       nMoon := nMoon + 30;
 
    { Advance to Sunday }
    nMoon := ( nMoon + 7 - ( ( nSunday + nMoon ) mod 7 ) );
 
    if ( nMoon > 31 ) then
       begin
         nMonth := 4;
         nDay   := ( nMoon - 31 );
       end
    else
       begin
         nMonth := 3;
         nDay   := nMoon;
       end;

    Result := EncodeDate( nYear, nMonth, nDay );

 end;
