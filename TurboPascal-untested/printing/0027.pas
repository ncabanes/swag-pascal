{
From: PHIL NICKELL
Subj: Basic PrintUsing in PAS
Does anyone know of any shareware or freeware routines in Turbo Pascal
5.5, that will allow me to format numbers or strings like the PRINTUSING
statement in BASIC???
}

 PROCEDURE printusing (mask: string; value:real);
   { Calling syntax =     PRINTUSING(mask, number)
     mask can be a string label or a literal
     Example  printusing('#,###,###',45.63);
              printusing('######.###,value);   }
  const
    comma     : char = ',';
    point     : char = '.';
    minussign : char = '-';
  var
    fieldwidth, integerlength, i, j, places, pointposition: integer;
    usingcommas, decimal, negative : boolean;
    outstring, integerstring : string;

  begin
       negative := ( value < 0 );
       value := abs( value );
       places := 0;
       fieldwidth := length( mask );
       usingcommas := ( pos ( comma, mask ) > 0 );
       decimal := ( pos (point,mask) > 0 );
       if decimal then
          begin
               pointposition := pos(point, mask);
               places := fieldwidth - pointposition;
          END;
       str ( value:0:places, outstring );
       if usingcommas then
          begin
               J := 0;
               integerstring :=
                     copy (outstring, 1, length(outstring)-places);
               integerlength := length(integerstring);
               if decimal then
                  integerlength := pred(integerlength);
               for i := integerlength downto 2 do
                   begin
                        inc(j);
                        if j mod 3 = 0 then
                           insert (comma,outstring,i);
                   end;
          end;
       if negative then
               outstring := minussign + outstring;
       write( outstring:fieldwidth);
  END; {PRINTUSING}

BEGIN
PrintUsing('##,###,###.##',123456.78);
END.