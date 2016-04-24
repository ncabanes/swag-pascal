(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0014.PAS
  Description: Text Search in Files
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:48
*)

{ Turbo Pascal File Viewer Object  }

uses Dos, Crt;

const
   PrintSet: set of $20..$7E = [ $20..$7E ];
   ExtenSet: set of $80..$FE = [ $80..$FE ];
   NoPrnSet: set of $09..$0D = [ $09, $0A, $0D ];

type
   CharType = ( Unknown, Ascii, Hex );
   DataBlock = array[1..256] of byte;
   Viewer = object
               XOrg, YOrg,
               LineLen, LineCnt, BlockCount : integer;
               FileName : string;
               FileType : CharType;
               procedure FileOpen( Fn : string;
                                   X1, Y1, X2, Y2 : integer );
               function  TestBlock( FileBlock : DataBlock;
                                    Count : integer ): CharType;
               procedure ListHex( FileBlock : DataBlock;
                                  Count, Ofs : integer );
               procedure ListAscii( FileBlock : DataBlock;
                                    Count : integer );
            end;

   Finder = object( Viewer )
               procedure Search( Fn, SearchStr : string;
                                 X1, Y1, X2, Y2 : integer );
            end;

procedure Finder.Search;
   var
      VF : file;   Result1, Result2 : word;
      BlkOfs, i, j, SearchLen : integer;
      SearchArray : array[1..128] of byte;
      EndFlag, BlkDone, SearchResult : boolean;
      FileBlock1, FileBlock2, ResultArray : DataBlock;
   begin
      BlockCount := 0;
      XOrg := X1;
      YOrg := Y1;
      LineLen := X2;
      LineCnt := Y2;
      FileType := Unknown;
      SearchLen := ord( SearchStr[0] );
      for i := 1 to Searchlen do
         SearchArray[i] := ord( SearchStr[i] );
      for i := 1 to sizeof( ResultArray ) do
         ResultArray[i] := $00;

      assign( VF, Fn );
      {$I-} reset( VF, 1 ); {$I+}
      if IOresult = 0 then
      begin
         EndFlag := false;
         BlkDone := false;
         SearchResult := false;
         BlockRead( VF, FileBlock2, sizeof( FileBlock2 ), Result2 );
         EndFlag := Result2 <> sizeof( FileBlock2 );
         repeat
            FileBlock1 := FileBlock2;
            Result1 := Result2;
            FileBlock2 := ResultArray;
            if not EndFlag then
            begin
               BlockRead( VF, FileBlock2, sizeof( FileBlock2 ), Result2 );
               inc( BlockCount );
               EndFlag := Result2 <> sizeof( FileBlock2 );
            end else BlkDone := True;
            for i := 1 to Result1 do
            begin
               if SearchArray[1] = FileBlock1[i] then
               begin
                  BlkOfs := i-1;
                  SearchResult := true;
                  for j := 1 to SearchLen do
                  begin
                     if i+j-1 <= Result1 then
                     begin
                        if SearchArray[j] = FileBlock1[i+j-1] then
                           ResultArray[j] := FileBlock1[i+j-1] else
                           begin
                              SearchResult := false;
                              j := SearchLen;
                           end;
                     end else
                        if SearchArray[j] = FileBlock2[i+j-257] then
                           ResultArray[j] := FileBlock2[i+j-257] else
                           begin
                              SearchResult := false;
                              j := SearchLen;
                           end;
                  end;
                  if SearchResult then
                  begin
                     for j := SearchLen+1 to sizeof( ResultArray ) do
                        if i+j-1 <= Result1
                           then ResultArray[j] := FileBlock1[i+j-1]
                           else ResultArray[j] := FileBlock2[i+j-257];
                     i := Result1;
                  end;
               end;
            end;
         until BlkDone or SearchResult;
         if SearchResult then
         begin
            writeln( 'Search string found in file block ', BlockCount,
               ' beginning at byte offset ', BlkOfs, ' ...' );
            writeln;
            if FileType = Unknown then
               FileType := TestBlock( ResultArray,
                                      sizeof( ResultArray ) );
            case FileType of
                 Hex : ListHex( ResultArray, sizeof( ResultArray ), BlkOfs );
               Ascii : ListAscii( ResultArray, sizeof( ResultArray ) );
            end;
         end else writeln( '"', SearchStr, '" not found in ', FN );
         close( VF );
         window( 1, 1, 80, 25 );
      end else writeln( Fn, ' invalid file name!' );
   end;

procedure Viewer.FileOpen;
   var
      VF : file;      Ch : char;
      Result, CrtX, CrtY : word;
      EndFlag : boolean;
      FileBlock : DataBlock;
   begin
      BlockCount := 0;
      XOrg := X1;
      YOrg := Y1;
      LineLen := X2;
      LineCnt := Y2;
      FileType := Unknown;
      assign( VF, Fn );
      {$I-} reset( VF, 1 ); {$I+}
      if IOresult = 0 then
      begin
         window( X1, Y1, X1+X2-1, Y1+Y2-1 );
         writeln;
         EndFlag := false;
         repeat
            BlockRead( VF, FileBlock, sizeof( FileBlock ), Result );
            inc( BlockCount );
            EndFlag := Result <> sizeof( FileBlock );
            if FileType = Unknown then
               FileType := TestBlock( FileBlock, Result );
            case FileType of
                 Hex : ListHex( FileBlock, Result, 0 );
               Ascii : ListAscii( FileBlock, Result );
            end;
            if not EndFlag then
            begin
               CrtX := WhereX;    CrtY := WhereY;
               if WhereY = LineCnt then
               begin   writeln;
                       dec( CrtY );  end;
               gotoxy( 1, 1 );    clreol;
               write(' Viewing: ', FN );
               gotoxy( 1, LineCnt );   clreol;
               write(' Press (+) to continue, (Enter) to exit: ');
               Ch := ReadKey;     EndFlag := Ch <> '+';
               gotoxy( 1, LineCnt );   clreol;
               gotoxy( CrtX, CrtY );
            end;
         until EndFlag;
         close( VF );
         sound( 440 ); delay( 100 );
         sound( 220 ); delay( 100 ); nosound;
         window( 1, 1, 80, 25 );
      end else writeln( Fn, ' invalid file name!' );
   end;

function Viewer.TestBlock;
   var
      i : integer;
   begin
      FileType := Ascii;
      for i := 1 to Count do
         if not FileBlock[i] in NoPrnSet+PrintSet then
            FileType := Hex;
      TestBlock := FileType;
   end;

procedure Viewer.ListHex;
   const
      HexStr: string[16] = '0123456789ABCDEF';
   var
      i, j, k : integer;
   begin
      k := 1;
      repeat
         write(' ');
         j := (BlockCount-1) * sizeof( FileBlock ) + ( k - 1 ) + Ofs;
         for i := 3 downto 0 do
            write( HexStr[ j shr (i*4) AND $0F + 1 ] );
         write(': ');
         for i := 1 to 16 do
         begin
            if k <= Count then
               write( HexStr[ FileBlock[k] shr 4 + 1 ],
                      HexStr[ FileBlock[k] AND $0F + 1 ], ' ' )
               else write( '  ' );
            inc( k );
            if( i div 4 = i / 4 ) then write(' ');
         end;
         for i := k-16 to k-1 do
         if i <= Count then
            if FileBlock[i] in PrintSet+ExtenSet
               then write( chr( FileBlock[i] ) )
               else write('.');
         writeln;
      until k >= Count;
   end;

procedure Viewer.ListAscii;
   var
      i : integer;
   begin
      for i := 1 to Count do
      begin
         write( chr( FileBlock[i] ) );
         if WhereX > LineLen then writeln;
         if WhereY >= LineCnt then
         begin
            writeln;
            gotoxy( 1, LineCnt-1 );
         end;
      end;
   end;

{=============== end Viewer object ==============}

var
   FileFind : Finder;
begin
   clrscr;
   FileFind.Search( 'D:\TP\EXE\search.EXE',    { file to search }
                    'Press any key',           { search string  }
                    1, 1, 80, 25 );            { display window }
   gotoxy( 1, 25 );   clreol;
   write( 'Press any key to continue: ');
   while not KeyPressed do;
end.
