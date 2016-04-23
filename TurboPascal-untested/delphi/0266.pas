--------------------------------------------------------------------------------

uses
  Registry, WinProcs, SysUtils;

const
  // WallPaperStyles
  WPS_Tile      = 0;
  WPS_Center    = 1;
  WPS_SizeToFit = 2;
  WPS_XY        = 3;

//
// sWallpaperBMPPath
//   - path to a BMP file
//
// nStyle
//   - any of the above WallPaperStyles
//
// nX, nY
//   - if the nStyle is set to WPS_XY,
//     nX and nY can be used to set the
//     exact position of the wall paper
//
procedure SetWallpaperExt(
  sWallpaperBMPPath : string;
  nStyle,
  nX, nY : integer );
var
  reg    : TRegIniFile;
  s1     : string;
  X, Y   : integer;
begin
  //
  // change registry
  //
  // HKEY_CURRENT_USER\
  //   Control Panel\Desktop
  //     TileWallpaper (REG_SZ)
  //     Wallpaper (REG_SZ)
  //     WallpaperStyle (REG_SZ)
  //     WallpaperOriginX (REG_SZ)
  //     WallpaperOriginY (REG_SZ)
  //
  reg := TRegIniFile.Create(
           'Control Panel\Desktop' );

  with reg do
  begin
    s1 := '0';
    X  := 0;
    Y  := 0;

    case nStyle of
      WPS_Tile  : s1 := '1';
      WPS_Center: nStyle := WPS_Tile;
      WPS_XY    :
      begin
        nStyle := WPS_Tile;
        X := nX;
        Y := nY;
      end;
    end;

    WriteString( '',
      'Wallpaper',
      sWallpaperBMPPath );

    WriteString( '',
      'TileWallpaper',
      s1 );

    WriteString( '',
      'WallpaperStyle',
      IntToStr( nStyle ) );

    WriteString( '',
      'WallpaperOriginX',
      IntToStr( X ) );

    WriteString( '',
      'WallpaperOriginY',
      IntToStr( Y ) );
  end;
  reg.Free;

  //
  // let everyone know that we
  // changed a system parameter
  //
  SystemParametersInfo(
    SPI_SETDESKWALLPAPER,
    0,
    Nil,
    SPIF_SENDWININICHANGE );
end;


Here are two examples on how to call the above SetWallpaperExt() function.

  // set wallpaper to winnt.bmp and
  // stretch it to fit the screen
  SetWallpaperExt(
    'c:\winnt\winnt.bmp',
    WPS_SizeToFit, 0, 0 );

  // set the wallpaper origin
  // to (10, 200)
  SetWallpaperExt(
    'c:\winnt\winnt.bmp',
    WPS_XY, 10, 200 );


