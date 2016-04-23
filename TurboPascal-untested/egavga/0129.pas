
UNIT video;

INTERFACE

USES DOS;

TYPE fontSize = (font8,font14,font16, unknownFontSize);
     adapterType = (none,mda,cga,egaMono,egaColor,vgaMono,
                   vgaColor,mcgaMono,mcgaColor);

VAR  textBufferOrigin  : pointer; {pointer to text buffer}
     textBufferSeg     : word;
     textBufferSize    : word;    {size in bytes of...}
     visibleX,visibleY : byte;
     fontLines         : byte;

function queryAdapterType : adapterType;
function fontCode(h : byte) : fontSize; {convert from byte to enum}
function getFontSize : fontSize; {normal 25 lines,ega 25 lines,vga 25 lines}
function fontHeight(f : fontSize) : byte;
procedure getTextBufferStats(var BX       : byte; {visible x dimentions}
                             var BY       : byte; {visible y dimentions}
                             var buffSize : word {refresh buffer size}
                            );
const maxX                : integer = 79;
      maxY                : integer = 24;

IMPLEMENTATION

(******************************************************************************
*                              queryAdapterType                              *
******************************************************************************)
function queryAdapterType : adapterType;

var         regs : Registers;
           code : byte;

begin
        regs.ah := $1a; {vga identify}
        regs.al := $0;  {clear}
        intr($10,regs);
        if regs.al = $1a then { is this a bug ???? }
        begin {ps/2 bios search for ..}
                case regs.bl of {code back in here}
                        $00 : queryAdapterType := none;
                        $01 : queryAdapterType := mda;
                        $02 : queryAdapterType := cga;
                        $04 : queryAdapterType := egaColor;
                        $05 : queryAdapterType := egaMono;
                        $07 : queryAdapterType := vgaMono;
                        $08 : queryAdapterType := vgaColor;
                        $0A,$0C : queryAdapterType := mcgaColor;
                        $0B : queryAdapterType := mcgaMono;
                        else queryAdapterType := cga;
                end; {case}
        end {ps/2 search}
        else
        begin {look for ega bios}
                regs.ah := $12;
                regs.bx := $10; {bl=$10 retrn ega info if ega}
                intr($10,regs);
                if regs.bx <> $10 then {bx unchanged mean no ega}
                begin
                        regs.ah := $12; {ega call again}
                        regs.bl := $10; {recheck}
                        intr($10,regs);
                        if (regs.bh = 0) then
                                queryAdapterType := egaColor
                        else
                                queryAdapterType := egaMono;
                end {ega identification}
        else {mda or cga}
        begin
                intr($11,regs); {get eqpt.}
                code := (regs.al and $30) shr 4;
                case code of
                        1,2 : queryAdapterType := cga;
                        3   : queryAdapterType := mda;
                        else queryAdapterType := none;
                end; {case}
        end {mda, cga}
        end;
end; {quertAdapterType}

(******************************************************************************
*                             getTextBufferStats                              *
* return bx = #of columns, by = #of rows, buffSize = #of bytes in buffer      *
******************************************************************************)
procedure getTextBufferStats;
const screenLineMatrix : array[adapterType,fontSize] of integer =
        ( (25,25,25, -1) {none adapter}, (-1,25,-1, -1) {mda},
          (25,-1,-1, -1) {cga},(43,25,-1, -1) {egaMono}, (43,25,-1, -1) {egaColor},
          (50,28,25, -1) {vgaMono}, (50,28,25, -1) {vgaColor},
          (-1,-1,25, -1) {mcgaMono}, (-1,-1,25, -1) {mcgaColor} );
{this matrix is saved in font8,font14,font16 sequence in rows of matrix}
var
        regs:registers;
begin
        regs.ah := $0f; {get current video mode}
        intr($10,regs);
        bx := regs.ah; {# of chars in a line, row}
        by := screenLineMatrix[queryAdapterType, getFontSize];
        if by > 0 then {legal height}
                buffSize := bx * 2 * by
        else
                buffSize := 0;
end; {getTextBufferStats}

(******************************************************************************
*                                 getFontSize                                 *
******************************************************************************)
function getFontSize : fontSize;
var
        regs  : registers;
   fs    : fontSize;
   at    : adapterType;
begin
   at := queryAdapterType;
        case at of
                cga                 : fs := font8;
                mda                 : fs := font14;
                mcgaMono,
                mcgaColor        : fs:= font16;
                egaMono,
                egaColor,
                vgaMono,
                vgaColor        : begin
                                        with regs do begin
               (* check this interrupt call, there might be some bug,
                  either in the call conventions, or in the 3300A
                  bios. *)
                                                ah := $11; {egavga call}
                                                al := $30;
(*                                                bl := $0;   *)
                                                bh := $0;
                                        end; {with}
                                        intr($10,regs);
                                        fs := fontCode(regs.cl);
               if (fs = unknownFontSize) then
                  fs := font16; { assume a work around in 330A screen}
                                end; {ega vga}
        end; {case}
   getFontSize := fs;
end; {getFontSize}

(******************************************************************************
*                                  fontCode                                   *
* Convert from byte size to a fontSize type                                                                                 *
******************************************************************************)
function fontCode;
begin
        case h of
                 8 : fontCode := font8;
                14 : fontCode := font14;
                16 : fontCode := font16;
      else fontCode := unknownFontSize; { unKnown, assume 8 }
        end; {case}
end; {fontCode}

(******************************************************************************
*                                 fontHeight                                 *
******************************************************************************)
function fontHeight(f : fontSize) : byte;
begin
        case f of
                font8  : fontHeight := 8;
                font14 : fontHeight := 14;
                font16 : fontHeight := 16;
        end; {case}
end; {fontHeight}

begin
   getTextBufferStats(visibleX, visibleY, textBufferSize);
   maxX := visibleX - 1;
   maxY := visibleY - 1;
   fontLines := fontHeight(getFontSize);
end.
