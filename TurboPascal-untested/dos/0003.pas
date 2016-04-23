Procedure Warm_Boot;
 Begin
  Inline($BB/$00/$01/$B8/$40/$00/$8E/$D8/
         $89/$1E/$72/$00/$EA/$00/$00/$FF/$FF);
 End;

Procedure Cold_Boot;
 Begin
  Inline($BB/$38/$12/$B8/$40/$00/$8E/$D8/
         $89/$1E/$72/$00/$EA/$00/$00/$FF/$FF);
 End;

I saw that you were posting reboot procedures...I didn't catch what it was for
though, but maybe these will help.


--- XANADU (1:124/7007)
 * Origin: * XANADU * Grand Prairie, TX * (1:124/7007)
                                                                     