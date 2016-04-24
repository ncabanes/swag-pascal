(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0101.PAS
  Description: GIF Viewing
  Author: SEAN WENZEL
  Date: 05-26-94  10:58
*)

unit GifUtil;
{ GifUtl.pas - (c)Copyright 1993 Sean Wenzel
        Users are given the right to use/modify and distribute this source code as
        long as credit is given where due.  I would also ask that anyone who makes
        use of this source/program drop me a line at my CompuServe address of
        71736,1245.  Just curious...

        The unit was written using Borland Pascal v7.0 but I think it should work
        with Turbo Pascal down to 5.5 at the most (or least?).
        This unit has only been tested on my system - an Everex Tempo 386DX
        with its built in SVGA adapter.  If anyone finds/fixes any bugs please
        let me know. (Feel free to send a copy of any code too)
        I have also only tested 3 or 4 256,16, and 2 color interlaced and non-
        interlaced images. (was enough for my needs)


        Some of the code is very loosely based on DECODER.C (availble online)
        so credit should be given to Steven A. Bennett and Steve Wilhite

        The unit is set up to use BGI256.BGI (inlcuded) which is available on CIS
        in the BPASCAL forum library.  The graphics initialization tries to start
        up in 640 by 480 mode.  If an error occurs it'll go down to 320x200
        automatically (well - it should).  For higher res modes change the variable
        GraphMode in the InitGraphics procedure to 3 for 800x600 and 4 for 1024x768.

        A sample program (GIF.PAS) is provided to demostrate the use of this unit.
        Basically declare a pointer to the TGIF object then initialize it using a
        line such as TheGif := New(PGif, Init('agif'));  You can then check
        TheGif^.Status for any errors and/or view the GIF headers and ColorTables.
        To switch to Graphics mode and show the GIF image use TheGif^.Decode(True)
        True tells it to beep when done(or boop if some sort of error occured).  
        When finished use Dispose(TheGif, Done) to switch back to textmode and get 
        rid of the object.


        If anyone cares to speed up the image decoding I'd suggest writing
        TGIF.NextCode in assembler.  The routine is the most heavily called in the
        unit while decoding and on my sytem took up about 5 seconds out of 12 when
        I profiled it. (send me a copy if you can)

        I have practically commented every line so that the source should be very
        readable and easy to follow.  Great for learning about GIF's and LZW 
        decompression.


        Any problems or suggestions drop me a line

        Good luck...
                                                        -Sean

        (almost forgot)
        "The Graphics Interchange Format(c) is the Copyright property of
         CompuServe Incorporated. GIF(sm) is a Service Mark property of
         CompuServe Incorporated."

}


{$R-}   {       range checking off }  { Put them on if you like but it slows down the}
{$S-} { stack checking off }  { decoding  (almost doubles it!) }
{$I-} { i/o checking off }

interface

uses Objects;

type
        TDataSubBlock = record
                Size: byte;     { size of the block -- 0 to 255 }
                Data: array[1..255] of byte; { the data }
        end;

const
        BlockTerminator: byte = 0; { terminates stream of data blocks }

type
        THeader = record
                Signature: array[0..2] of char; { contains 'GIF' }
                Version: array[0..2] of char;   { '87a' or '89a' }
        end;

        TLogicalScreenDescriptor = record
                ScreenWidth: word;              { logical screen width }
                ScreenHeight: word;  { logical screen height }
                PackedFields: byte;     { packed fields - see below }
                BackGroundColorIndex: byte;     { index to global color table }
                AspectRatio: byte;      { actual ratio = (AspectRatio + 15) / 64 }
        end;

const
{ logical screen descriptor packed field masks }
        lsdGlobalColorTable = $80;  { set if global color table follows L.S.D. }
        lsdColorResolution = $70;               { Color resolution - 3 bits }
        lsdSort = $08;                                                  { set if global color table is sorted - 1 bit }
        lsdColorTableSize = $07;                { size of global color table - 3 bits }
                                                                                                                        { Actual size = 2^value+1    - value is 3 bits }

type
        TColorItem = record     { one item a a color table }
                Red: byte;
                Green: byte;
                Blue: byte;
        end;

        TColorTable = array[0..255] of TColorItem;      { the color table }

const
        ImageSeperator: byte = $2C;

type
        TImageDescriptor = record
                Seperator: byte;                         { fixed value of ImageSeperator }
                ImageLeftPos: word; {Column in pixels in respect to left edge of logical screen }
                ImageTopPos: word;{row in pixels in respect to top of logical screen }
                ImageWidth: word;       { width of image in pixels }
                ImageHeight: word;      { height of image in pixels }
                PackedFields: byte; { see below }
        end;
const
        { image descriptor bit masks }
                idLocalColorTable = $80; { set if a local color table follows }
                idInterlaced = $40;                      { set if image is interlaced }
                idSort = $20;                                            { set if color table is sorted }
                idReserved = $0C;                                { reserved - must be set to $00 }
                idColorTableSize = $07;  { size of color table as above }

        Trailer: byte = $3B;    { indicates the end of the GIF data stream }

{ other extension blocks not currently supported by this unit
        - Graphic Control extension
        - Comment extension           I'm not sure what will happen if these blocks
        - Plain text extension        are encountered but it'll be interesting
        - application extension }

const
        ExtensionIntroducer: byte = $21;
        MAXSCREENWIDTH = 800;

type
        TExtensionBlock = record
                Introducer: byte;                               { fixed value of ExtensionIntroducer }
                ExtensionLabel: byte;
                BlockSize: byte;
        end;

        PCodeItem = ^TCodeItem;
        TCodeItem = record
                Code1, Code2: byte;
        end;

const
        MAXCODES = 4095;        { the maximum number of different codes 0 inclusive }



type
        { This is the actual gif object }
        PGif = ^TGif;
        TGif = object(TObject)
                Stream: PBufStream;                                                                     { the file stream for the gif file }
                Header: THeader;                                                                                { gif file header }
                LogicalScreen: TLogicalScreenDescriptor;  { gif screen descriptor }
                GlobalColorTable: TColorTable;            { global color table }
                LocalColorTable: TColorTable;             { local color table }
                ImageDescriptor: TImageDescriptor;        { image descriptor }
                UseLocalColors: boolean;                  { true if local colors in use }
                Interlaced: boolean;                      { true if image is interlaced }
                LZWCodeSize: byte;                       { minimum size of the LZW codes in bits }
                ImageData: TDataSubBlock;                { variable to store incoming gif data }
                TableSize: word;                                                 { number of entrys in the color table }
                BitsLeft, BytesLeft: integer;{ bits left in byte - bytes left in block }
                BadCodeCount: word;          { bad code counter }
                CurrCodeSize: integer;       { Current size of code in bits }
                ClearCode: integer;          { Clear code value }
                EndingCode: integer;         { ending code value }
                Slot: word;                                     { position that the next new code is to be added }
                TopSlot: word;      { highest slot position for the current code size }
                HighCode: word;     { highest code that does not require decoding }
                NextByte: integer;      { the index to the next byte in the datablock array }
                CurrByte: byte;                 { the current byte }
                DecodeStack: array[0..MAXCODES] of byte; { stack for the decoded codes }
                Prefix: array[0..MAXCODES] of word;                     { array for code prefixes }
                Suffix: array[0..MAXCODES] of byte;             { array for code suffixes }
                LineBuffer: array[0..MAXSCREENWIDTH] of byte; { array for buffer line output }
                CurrentX, CurrentY: integer;                                            { current screen locations }
                Status: word;                                                         { status of the decode }
                InterlacePass: byte;    { interlace pass number }
                constructor Init(AGIFName: string);
                destructor Done; virtual;
                procedure Error(What: integer);
                procedure InitCompressionStream;        { initializes info for decode }
                procedure ReadSubBlock;                          { reads a data subblock from the stream }
                function NextCode: word;                                        { returns the next available code }
                procedure Decode(Beep: boolean);        { the actual LZW decoding routine }
                procedure DrawLine;                     { writes the drawline buffer to screen }
                procedure InitGraphics;                 { Initializes Graphics mode }
        end;

const
{ error constants }
        geNoError = 0;                          { no errors found }
        geNoFile = 1;         { gif file not found }
        geNotGIF = 2;         { file is not a gif file }
        geNoGlobalColor = 3;  { no Global Color table found }
        geImagePreceded = 4;  { image descriptor preceeded by other unknown data }
        geEmptyBlock = 5;                       { Block has no data }
        geUnExpectedEOF = 6;  { unexpected EOF }
        geBadCodeSize = 7;    { bad code size }
        geBadCode = 8;                          { Bad code was found }
        geBitSizeOverflow = 9; { bit size went beyond 12 bits }

implementation

uses Graph, Crt;

function Power(A, N: real): real;       { returns A raised to the power of N }
begin
        Power := exp(N * ln(A));
end;


{ TGif }
constructor TGif.Init(AGIFName: string);
begin
        inherited Init;
        if Pos('.',AGifName) = 0 then     { if the filename has no extension add one }
                AGifName := AGifName + '.gif';
        Stream := New(PBufStream, Init(AGifName, stOpen, 2048));
        Stream^.Read(Header, sizeof(Header));                                           { read the header }
        if Header.Signature <> 'GIF' then Error(geNotGIF);                              { is vaild signature }
        Stream^.Read(LogicalScreen, sizeof(LogicalScreen));
        if LogicalScreen.PackedFields and lsdGlobalColorTable = lsdGlobalColorTable then
        begin
                TableSize := trunc(Power(2,(LogicalScreen.PackedFields and lsdColorTableSize)+1));
                Stream^.Read(GlobalColorTable, TableSize*sizeof(TColorItem)); { read Global Color Table }
        end
        else
                Error(geNoGlobalColor);
        Stream^.Read(ImageDescriptor, sizeof(ImageDescriptor)); { read image descriptor }
        if ImageDescriptor.Seperator <> ImageSeperator then                     { verify that it is the descriptor }
                Error(geImagePreceded);
        if ImageDescriptor.PackedFields and idLocalColorTable = idLocalColorTable then
        begin                                                               { if local color table }
                TableSize := trunc(Power(2,(ImageDescriptor.PackedFields and idColorTableSize)+1));
                Stream^.Read(LocalColorTable, TableSize*sizeof(TColorItem)); { read Local Color Table }
                UseLocalColors := True;
        end
        else
                UseLocalColors := false;
        if ImageDescriptor.PackedFields and idInterlaced = idInterlaced then
        begin
                Interlaced := true;
                InterlacePass := 0;
        end;
        if (Stream = nil) or (Stream^.Status <> stOk) then{ check for stream error }
                Error(geNoFile);
        Status := 0;
end;

destructor TGif.Done;
begin
        CloseGraph;
        TextMode(LastMode);
        if Stream <> nil then
                Dispose(Stream, Done);
        inherited Done;
end;

procedure TGif.Error(What: integer);
begin
        Status := What;
end;

procedure TGif.InitCompressionStream;
var
        I: integer;
begin
        InitGraphics;                           { Initialize the graphics display }
        Stream^.Read(LZWCodeSize, sizeof(byte));{ get minimum code size }
        if not (LZWCodeSize in [2..9]) then     { valid code sizes 2-9 bits }
                Error(geBadCodeSize);

        CurrCodeSize := succ(LZWCodeSize); { set the initial code size }
        ClearCode := 1 shl LZWCodeSize;    { set the clear code }
        EndingCode := succ(ClearCode);     { set the ending code }
        HighCode := pred(ClearCode);                     { set the highest code not needing decoding }
        BytesLeft := 0;                    { clear other variables }
        BitsLeft := 0;
        CurrentX := 0;
        CurrentY := 0;
end;

procedure TGif.ReadSubBlock;
begin
        Stream^.Read(ImageData.Size, sizeof(ImageData.Size)); { get the data block size }
        if ImageData.Size = 0 then Error(geEmptyBlock); { check for empty block }
        Stream^.Read(ImageData.Data, ImageData.Size);   { read in the block }
        NextByte := 1;                                  { reset next byte }
        BytesLeft := ImageData.Size;                                                                            { reset bytes left }
end;

const
        CodeMask: array[0..12] of longint = (  { bit masks for use with Next code }
                0,
                $0001, $0003,
                $0007, $000F,
                $001F, $003F,
                $007F, $00FF,
                $01FF, $03FF,
                $07FF, $0FFF);

function TGif.NextCode: word; { returns a code of the proper bit size }
var
        Ret: longint;                          { temporary return value }
begin
        if BitsLeft = 0 then                                                                            { any bits left in byte ? }
        begin                                   { any bytes left }
                if BytesLeft <= 0 then                                                          { if not get another block }
                        ReadSubBlock;
                        CurrByte := ImageData.Data[NextByte]; { get a byte }
                inc(NextByte);                        { set the next byte index }
                BitsLeft := 8;                        { set bits left in the byte }
                dec(BytesLeft);                       { decrement the bytes left counter }
        end;
        ret := CurrByte shr (8 - BitsLeft);                     { shift off any previosly used bits}
        while CurrCodeSize > BitsLeft do        { need more bits ? }
        begin
                if BytesLeft <= 0 then                                                          { any bytes left in block ? }
                        ReadSubBlock;                       { if not read in another block }
                CurrByte := ImageData.Data[NextByte]; { get another byte }
                inc(NextByte);                        { increment NextByte counter }
                ret := ret or (CurrByte shl BitsLeft);{ add the remaining bits to the return value }
                BitsLeft := BitsLeft + 8;                                               { set bit counter }
                dec(BytesLeft);                     { decrement bytesleft counter }
        end;
        BitsLeft := BitsLeft - CurrCodeSize;  { subtract the code size from bitsleft }
        ret := ret and CodeMask[CurrCodeSize];{ mask off the right number of bits }
        NextCode := ret;
end;

{ this procedure initializes the graphics mode and actually decodes the
        GIF image }
procedure TGif.Decode(Beep: boolean);
var
        SP: integer; { index to the decode stack }

{ local procedure that decodes a code and puts it on the decode stack }
procedure DecodeCode(var Code: word);
begin
        while Code > HighCode do { rip thru the prefix list placing suffixes }
        begin                    { onto the decode stack }
                DecodeStack[SP] := Suffix[Code]; { put the suffix on the decode stack }
                inc(SP);                         { increment decode stack index }
                Code := Prefix[Code];            { get the new prefix }
        end;
        DecodeStack[SP] := Code;        { put the last code onto the decode stack }
        inc(SP);                                                                        { increment the decode stack index }
end;

var
        TempOldCode, OldCode: word;
        BufCnt: word;           { line buffer counter }
        Code, C: word;
        CurrBuf: word;  { line buffer index }
begin
        InitGraphics;                                                   { Initialize the graphics mode and RGB palette }
        InitCompressionStream;    { Initialize decoding paramaters }
        OldCode := 0;
        SP := 0;
        BufCnt := ImageDescriptor.ImageWidth; { set the Image Width }
        CurrBuf := 0;

        C := NextCode;                                          { get the initial code - should be a clear code }
        while C <> EndingCode do  { main loop until ending code is found }
        begin
                if C = ClearCode then   { code is a clear code - so clear }
                begin
                        CurrCodeSize := LZWCodeSize + 1;{ reset the code size }
                        Slot := EndingCode + 1;                                 { set slot for next new code }
                        TopSlot := 1 shl CurrCodeSize;  { set max slot number }
                        while C = ClearCode do
                                C := NextCode;                  { read until all clear codes gone - shouldn't happen }
                        if C = EndingCode then
                        begin
                                Error(geBadCode);   { ending code after a clear code }
                                break;                                                  { this also should never happen }
                        end;
                        if C >= Slot { if the code is beyond preset codes then set to zero }
                                then c := 0;
                        OldCode := C;
                        DecodeStack[sp] := C;                                   { output code to decoded stack }
                        inc(SP);                                                { increment decode stack index }
                end
                else   { the code is not a clear code or an ending code so it must }
                begin  { be a code code - so decode the code }
                        Code := C;
                        if Code < Slot then     { is the code in the table? }
                        begin
                                DecodeCode(Code);                               { decode the code }
                                if Slot <= TopSlot then
                                begin                                           { add the new code to the table }
                                        Suffix[Slot] := Code;                   { make the suffix }
                                        PreFix[slot] := OldCode;        { the previous code - a link to the data }
                                        inc(Slot);                                                              { increment slot number }
                                        OldCode := C;                                                   { set oldcode }
                                end;
                                if Slot >= TopSlot then { have reached the top slot for bit size }
                                begin                   { increment code bit size }
                                        if CurrCodeSize < 12 then { new bit size not too big? }
                                        begin
                                                TopSlot := TopSlot shl 1;       { new top slot }
                                                inc(CurrCodeSize)                                       { new code size }
                                        end
                                        else
                                                Error(geBitSizeOverflow); { encoder made a boo boo }
                                end;
                        end
                        else
                        begin           { the code is not in the table }
                                if Code <> Slot then                    { code is not the next available slot }
                                        Error(geBadCode);  { so error out }

                                { the code does not exist so make a new entry in the code table
                                 and then translate the new code }
                                TempOldCode := OldCode;  { make a copy of the old code }
                                while OldCode > HighCode do { translate the old code and place it }
                                begin                                   { on the decode stack }
                                        DecodeStack[SP] := Suffix[OldCode]; { do the suffix }
                                        OldCode := Prefix[OldCode];         { get next prefix }
                                end;
                                DecodeStack[SP] := OldCode;     { put the code onto the decode stack }
                                                                                                                                                { but DO NOT increment stack index }
                                { the decode stack is not incremented because because we are only
                                        translating the oldcode to get the first character }
                                if Slot <= TopSlot then
                                begin                 { make new code entry }
                                        Suffix[Slot] := OldCode;                 { first char of old code }
                                        Prefix[Slot] := TempOldCode; { link to the old code prefix }
                                        inc(Slot);                   { increment slot }
                                end;
                                if Slot >= TopSlot then { slot is too big }
                                begin                   { increment code size }
                                        if CurrCodeSize < 12 then
                                        begin
                                                TopSlot := TopSlot shl 1;       { new top slot }
                                                inc(CurrCodeSize)                                       { new code size }
                                        end
                                        else
                                                Error(geBitSizeOverFlow);
                                end;
                                DecodeCode(Code); { now that the table entry exists decode it }
                                OldCode := C;     { set the new old code }
                        end;
                end;
                { the decoded string is on the decode stack so pop it off and put it
                 into the line buffer }
                while SP > 0 do
                begin
                        dec(SP);
                        LineBuffer[CurrBuf] := DecodeStack[SP];
                        inc(CurrBuf);
                        dec(BufCnt);
                        if BufCnt = 0 then  { is the line full ? }
                        begin
                                DrawLine;
                                CurrBuf := 0;
                                BufCnt := ImageDescriptor.ImageWidth;
                        end;
                end;
        C := NextCode;  { get the next code and go at is some more }
        end;            { now that wasn't all that bad was it? }
        if Beep then
                if Status = 0 then
                begin
                        Sound(660);     { Beep if status is ok }
                        Delay(50);
                        NoSound;
                end
                else
                begin
                        Sound(110); { Boop if status is not ok }
                        Delay(200);
                        NoSound;
                end;
end;

procedure TGif.DrawLine;
var
        I: integer;
begin
        for I := 0 to ImageDescriptor.ImageWidth do
                PutPixel(I, CurrentY, LineBuffer[I]);
        inc(CurrentY);

        if InterLaced then     { Interlace support }
        begin
                case InterlacePass of
                        0: CurrentY := CurrentY + 7;
                        1: CurrentY := CurrentY + 7;
                        2: CurrentY := CurrentY + 3;
                        3: CurrentY := CurrentY + 1;
                end;
                if CurrentY >= ImageDescriptor.ImageHeight then
                begin
                        inc(InterLacePass);
                        case InterLacePass of
                                1: CurrentY := 4;
                                2: CurrentY := 2;
                                3: CurrentY := 1;
                        end;
                end;
        end;
end;

procedure TGif.InitGraphics;
var
        GraphDriver: integer;
        GraphMode: integer;
        ErrorCode: integer;
        I: integer;
begin
        GraphDriver := InstallUserDriver('bgi256', nil);
        GraphMode := 2;
        InitGraph(GraphDriver, GraphMode, '\dealer\bin');
        ErrorCode := GraphResult;
        if ErrorCode <> grOk then
        begin
                Writeln('Graphics Error: ', GraphErrorMsg(ErrorCode));
                Halt(99);
        end;

        { the following loop sets up the RGB palette }
        if not UseLocalColors then
                for I := 0 to TableSize - 1 do
                        SetRGBPalette(I, GlobalColorTable[I].Red div 4, GlobalColorTable[i].Green
                                div 4, GlobalColorTable[I].Blue div 4)
        else
                for I := 0 to TableSize - 1 do
                        SetRGBPalette(I, LocalColorTable[I].Red div 4, LocalColorTable[i].Green
                                div 4, LocalColorTable[I].Blue div 4);
end;


end.

{ --------------------------   DEMO PROGRAM  ------------------ }

program Gif;
{ GifUtil sample program
        (c)Copyright 1993 Sean Wenzel
        Users are given the right to freely use and distibute the source code at
        will as long a credit is given where due }

uses GifUtil, CRT, Dos;

var
        A: string;
        TheGif: PGif;
        Hours, Minutes, Seconds, Sec100: word;
        H, M, S, S100: word;
begin
        Writeln('Sample program for using GIFUTIL.PAS unit');
        Writeln('(c) Copyright 1993 Sean Wenzel');
        Writeln('');

        if ParamCount <> 1 then
        begin
                Writeln('use: C:>gif <gifname>[.gif] to run...');
                Exit;
        end;
        TheGif := New(PGif, Init(paramstr(1)));

        GetTime(Hours, Minutes, Seconds, Sec100);
        TheGif^.Decode(True);
        GetTime(H, M, S, S100);
        Readln(A);
        Dispose(TheGif, Done);

        Writeln('Start: ',Hours,':',Minutes,':',Seconds,':',Sec100);
        Writeln(' Stop: ',H,':',M,':',S,':',S100);
        while not(KeyPressed) do;

        writeln('"The Graphics Interchange Format(c) is the Copyright property of');
        writeln('CompuServe Incorporated. GIF(sm) is a Service Mark property of ');
        writeln('CompuServe Incorporated."');
end.
