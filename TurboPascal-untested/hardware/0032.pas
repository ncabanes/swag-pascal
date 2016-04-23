
VAR
  Model : BYTE ABSOLUTE $F000:$FFFE; 

BEGIN 
  CASE Model OF 
    $9A : WriteLn( 'COMPAQ Plus' ); 
    $FF : WriteLn( 'IBM PC' ); 
    $FE : WriteLn( 'PC XT, Portable PC' ); 
    $FD : WriteLn( 'PCjr' );

    $FC : WriteLn( 'Personal Computer AT, PS/2 Models 50 and 60' ); 
    $FB : WriteLn( 'PC XT (after 1/10/86)' ); 
    $FA : WriteLn( 'PS/2 Model 30' ); 
    $F9 : WriteLn( 'Convertible PC' ); 
    $F8 : WriteLn( 'PS/2 Model 80' ); 
  End; 
END.
