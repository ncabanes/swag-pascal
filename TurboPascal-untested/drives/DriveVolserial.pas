(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0018.PAS
  Description: Drive VOL-Serial
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:38
*)

{
 This Turbo Pascal code will read the serial number and volume
 from disks that have been Formatted under Dos 4.0 and higher ...
}
(*-------------------------------------------------------------------*)
Program VolSN;  { reads disk serial number & volume Label (Dos 4.0+) }
Uses    Dos;
Type    MediaID = Record
                    InfoLevel   : Word;
                    SerialN     : LongInt;
                    VLabel      : Array [0..10] of Char;
                    SysName     : Array [0..7] of Char;
                  end;

Var     IDbuffer        : MediaID;
        SerialNumber    : LongInt;
        VolumeLabel     : String[12];
        Reg             : Registers;
        loopc           : Byte;
begin
        WriteLn( #10, 'VolStat 0.00 Greg Vigneault', #10 );

        Reg.AH := $30;      { Function to get Dos version number }
        MsDos( Reg );       { via MS-Dos }
        if ( Reg.AL < 4 ) or ( Reg.AL = 10 )
            then begin      { must be Dos 4.0 or above (& not OS/2?) }
                WriteLn( 'Dos version error',#7 );
                Halt(1)     { abort Program }
            end;

        Reg.AX := $6900;            { Dos Function  }
        Reg.BL := 0;                { Drive (0=current,1=A,2=B,etc)}
        Reg.DS := Seg( IDbuffer );  { place to return data }
        Reg.DX := ofs( IDbuffer );
        MsDos( Reg );               { call Dos }
        { there'll be an error if disk doesn't have a serial # ... }
        if ( Reg.FLAGS and 1 ) <> 0 { carry flag set? }
            then begin
                WriteLn( 'Dos error getting Media ID',#7 );
                Halt(2);
            end;

        SerialNumber := IDbuffer.SerialN;   { get serial number }

        WriteLn( 'Disk serial number: ', SerialNumber );

        VolumeLabel := '';
        loopc := 0;
        While ( IDbuffer.VLabel[ loopc ] <> ' ' )
            do begin
                VolumeLabel[ loopc+1 ] := IDbuffer.VLabel[ loopc ];
                inC( loopc );
            end;
        VolumeLabel[0] := CHR( loopc ); { set TP String length }
        if ( loopc <> 0 ) then
            WriteLn( 'Disk volume Label : ', VolumeLabel );
end.

