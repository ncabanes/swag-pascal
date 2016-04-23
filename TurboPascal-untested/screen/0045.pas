{
From: GREG ESTABROOKS

I was wondering if anybody knew how to capture a character in Turbo
Pascal 6.0 at any x,y location like QuickBasic's SCREEN(x,y).
}

FUNCTION GetChar( X,Y :WORD; VAR Attrib:BYTE ) :CHAR;
VAR
   Ofs :WORD;
BEGIN
                        { NOTE: Change the Segment from $B800 }
                        {       to $B000 for MonoChrome.      }
  Ofs := ((Y-1) * 160) + ((X SHL 1) - 1);
  Attrib := MEM[$B800:Ofs];
  GetChar := CHR( MEM[$B800:Ofs-1] );
END;

{
From: LOU DUCHEZ
------------------------------------------------------------------------------}

function getvideodata(x, y: byte): char;

{ "Reads" a character off the video screen. }

type  videolocation = record                  { video memory locations }
        videodata: char;                      { character displayed }
        videoattribute: byte;                 { attributes }
        end;

var vidptr: ^videolocation;
    monosystem: boolean;
    videosegment: word;
    scrncols:  byte absolute $0040:$004a;
    videomode: byte absolute $0040:$0049;

begin
  monosystem := (videomode = 7);
  if monosystem then videosegment := $b000 else videosegment := $b800;
  vidptr := ptr(videosegment, 2*(scrncols*(y - 1) + (x - 1)));
  getvideodata := vidptr^.videodata;
  end;
