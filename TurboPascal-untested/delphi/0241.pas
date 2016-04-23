

--------------------------------------------------------------------------------
In Delphi, color is often represented using the TColor object. In HTML
documents, color is usually represented using a 6 character hex string.
Following function will convert TColor type color values to hex strings:

function
  GetColorHexStr( Color : TColor )
    : string;
begin
  Result :=
    IntToHex( GetRValue( Color ), 2 ) +
    IntToHex( GetGValue( Color ), 2 ) +
    IntToHex( GetBValue( Color ), 2 );
end;


