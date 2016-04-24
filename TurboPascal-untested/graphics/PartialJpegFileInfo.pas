(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0209.PAS
  Description: Partial JPEG File info
  Author: CAMERON CLARK
  Date: 05-31-96  09:16
*)

{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V-,X-}
{:
PREFACE:

A basic jpeg/jfif file is compossed of subsections which I will call
segments. Each segment has a header ID. Some headers have information
blocks following the header, while some don not. Basically, the
stucture can be thought of as follows:  (ID [info.], ... , ID [info.]).
So, a segment can be compossed of only a header or a header with
data following.

Unlike most structures, the segments do not have a predefined order;
therefor, it is maditory to read the ID header first then treat the
following data occurding to its header. Remember, certain headers
do not have any following data - I will label these in the code.

The only predifined structure that a jpeg/jfif has is the following:
The file starts with the SOI(start of information) header and is
followed by the app0 segment. Followed by any number of other segments,
followed by the EOI(end of information) segment.

arrangment:  SOI (start of information)
             app0
             [ ... unknown ... ]
             EOI (end of information)


The usual arrangment that I have found in most jpeg/jfif files is as
follows:
             SOI    (start of information)
             app0   (JFIF label w/ image description)
             DQT    (Define quantization table)
             sof0   (start of frame)
             DHT    (Define huffman table)
             DHT    (Define huffman table)
             DHT    (Define huffman table)
             DHT    (Define huffman table)
             SOS    (Start of scan)
       NOTE: dqt,sof0, & dht don't always appear in this order.

Description:
    SOI:  just a "dumb" header - no information follows.

    app0: for jfif files - JFIF id, version #, unit,
          x & y density, thumbnail info & thumbnail (if any)
          SEE app0_info TYPE

    DQT:  defines 8x8 table used for quantization

    sof0: image height & width & color components
          jfif support (1) Y or (3) Y Cb Cr
          a yuv_to_rbg function is in this unit.

    DHT: Set's up all the huffman tables used to decompress
         the image.

    SOS: defines AC & DC huffman tables to use for each color component

Headers:
Headers are 2 bytes, in hexidecimal "FF" followed by the ID byte.
For ease of tranlastion, I have set up a list of constants to
determine the header ID (eg. sof0,dht,sos,..., ect.)
ALL headers with infomation following have a word that tells the
length of the data following. The word is not in the intel lo-hi
format, so I included a HI_LO function for translation.
To read any segment you only need to the following:
   Read the header, identify it.
   Read the hi-lo word for length, translate HI_LO().
   Read "length" bytes of data.
   NOTE: Not all headers have a length or data block.


THIS FILE----------------------------------------------

This unit is design specifically for debuging and block testing. What
this means is that no actual file needs to be used to test and debug
each segment handling procedure. The driver file is responsible for
header identification, file reading, and so on.

To process an information block, read the header & identify it.
Read the length, subtract 2 from it and save it. Read "length" bytes
into a block (array of bytes). Now, give the appropriete procedure
the block, length, and a predefined type (Quan_tables, Huff_tables,
app0_info, frame_0, scan_info).

}

UNIT jpegsegm; { see TEST program at the bottom ! }

INTERFACE
  CONST TEM  = $01;            {unknown}
      SOF0 = $c0;            {start of FRAME}
      SOF1 = $c1;            {""""""""""""""}
      SOF2 = $c2;            {following SOF usually unsupported}
      SOF3 = $c3;
      SOF5 = $c2;
      SOF6 = $c6;
      SOF7 = $c7;
      SOF9 = $c9;            {sof9 : for arithmetic coding - taboo!}
      SOF10= $ca;
      SOF11= $cb;
      SOF13= $cd;
      SOF14= $ce;
      SOF15= $cf;
      DHT  = $c4;            {Define huffman Table}
      JPG  = $c8;            {undefined/ reserved =Error?}
      DAC  = $cc;            {define arithmetic table UNSUPORTED }
      RST0 = $d0;            {Used for resync [?] ignored}
      rst1 = $d1;
      rst2 = $d2;
      rst3 = $d3;
      rst4 = $d4;
      rst5 = $d5;
      rst6 = $d6;
      rst7 = $d7;
      SOI  = $d8;            {start of image}
      EOI  = $d9;            {end   of image}
      SOS  = $da;            {start of scan }
      DQT  = $db;            {Define Quantization Table}
      DNL  = $dc;            {unknown -usually unsupported}
      DRI  = $dd;            {Define Restart Interval}
      DHP  = $de;            {ignore }
      EXP  = $df;
      APP0 = $e0;            {JFIF app0 segment marker}
      APP15= $ef;            {ignore}
      JPG0 = $f0;
      JPG13= $fd;
      COM  = $fe;            {Comment}

  {: Do App0 :}

  TYPE app0_info = record
                   revision   : record
                                  major,         {>= 1}
                                  minor : byte;
                                end;
                   XY_density : byte;
                   X,Y        : word;
                   thumb_X,
                   thumb_y    : byte;
                 end;

  {: Define Quantization Table :}

  TYPE Q_byte      = array[0..7,0..7] of byte;
       Q_word      = array[0..7,0..7] of word;
       Q_type_type = (bit_8,bit_16);
       Quan_range = 0..3;
       Quan_tables = array[Quan_range] of
                     record
                      Valid  : Boolean;
                      Q_TYPE : Q_type_type;
                      Q      : record
                                 case integer of
                                  1 : (Q_byte : array[0..7,0..7] of byte);
                                  2 : (Q_word : array[0..7,0..7] of word);
                                 end;
                     end;
       One_quan_table = record
                        case integer of
                         1 : (Q_int  : array[0..7,0..7] of Integer);
                         2 : (Q_long : array[0..7,0..7] of Longint);
                        end;

  {: Define Huffman Table :}

  TYPE huff_type   = (AC, DC);
       Huff_range  = 0..3;
       Huff_tables = array[huff_type] of
                     record
                       Table : array[Huff_range] of
                       record
                         valid     : boolean;
                         H_type    : huff_type;
                         Max_code  : array[1..16] of byte;
                         H         : array[1..257] of
                                     record
                                       len  : byte;
                                       code : word;
                                       sym  : byte;
                                     end;
                       end;
                     end;

  {: Start of Frame :}

  type  id_type   = (no_id, Y_, CB_, CR_, I_, Q_);
        comp_type = (grey, no_comp, color);
        frame_0 = record
                   precision    : byte;
                   image_height : word;
                   image_width  : word;
                   comp_num     : comp_type;
                   factor : array[1..3] of
                            record
                              id    : id_type;
                              horz_factor   : byte;
                              vert_factor   : byte;
                              Q_num : byte;
                            end;
                  end;

  {: Start of Scan :}

  type comp_range = 1..4;
       scan_info = record
                     comp_num : comp_range;
                     Each : array[comp_range] of
                            record
                              valid   : boolean;
                              id      : id_type;
                              huff_ac : huff_range;
                              huff_dc : huff_range;
                            end;
                   end;


  PROCEDURE DO_sof0(VAR block : array of byte; Len : word;
                    VAR Frame : frame_0);
  Function  DO_app0(VAR block : array of byte; Len : word;
                   VAR info : app0_info ) : boolean;
  PROCEDURE DO_DQT(VAR block : array of byte; Len : word;
                 VAR All_DQT : Quan_tables);
  PROCEDURE DO_sos(VAR block : array of byte; Len : word;
                   Var Scan : Scan_info);
  PROCEDURE DO_DHT(VAR block : array of byte; Len : word;
                 VAR all_dht : huff_tables);

  PROCEDURE DO_DRI; {unknown}

  procedure DeQuantize( VAR Q : Quan_tables; Num : byte;
                        VAR in_q : one_quan_table);
  procedure IDCT(VAR one : one_quan_table);

  FUNCTION  HI_LO(inw : word) : word;

IMPLEMENTATION

{::::::::::::::::::::::::::::::::::}
{: Change a HI-LO word to LO-HIGH :}
{::::::::::::::::::::::::::::::::::}

  FUNCTION  HI_LO(inw : word) : word;
  var dwd : word;
  begin
    dwd := 0;
    dwd := inw SHR 8;
    dwd := dwd OR (inw SHL 8);
    Hi_lo := dwd;
  end;


  procedure yuv_to_RGB( Y,CB,Cr : integer; VAR R,G,B : byte);
  begin
    r := trunc(y + 1.402 *(Cr-128));
    g := trunc(y - 0.34414 * (cb-128) - 0.71414*(cr-128));
    b := trunc(y + 1.772*(Cb-128));
  end;

{::::::::::::::}
{: Dequantize :}
{::::::::::::::}
{: component wise multiplication of 2 8x8 matricies :}
{: where b[x,y] = q[x,y] * a[x,y]                   :}
{check}

  procedure DeQuantize( VAR Q : Quan_tables; Num : byte;
                        VAR in_q : one_quan_table);
  var i,j : byte;
  begin
    with Q[num] do begin
         case q_type of
          bit_8  : begin
                    for I := 0 to 7 do
                        for j := 0 to 7 do
                        in_q.q_int[i,j] := in_q.q_int[i,j] * Q.Q_byte[i,j];
                   end;
          bit_16 : begin
                    for I := 0 to 7 do
                        for j := 0 to 7 do
                        in_q.q_long[i,j] := in_q.q_long[i,j] * Q.Q_word[i,j];
                   end;
         end;
    end;
  end;

{:::::::::::::::}
{: Inverse DCT :}
{:::::::::::::::}
                  {u}   {v}
  const C : array [0..7,0..7] of real =
  ((0.5, 0.707106781188, 0.707106781188, 0.707106781188,
    0.707106781188, 0.707106781188, 0.707106781188, 0.707106781188),
   (0.707106781188, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
   (0.707106781188, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
   (0.707106781188, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
   (0.707106781188, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
   (0.707106781188, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
   (0.707106781188, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
   (0.707106781188, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0));

  procedure IDCT(VAR one : one_quan_table);
  var u,v,
      x,y  : byte;
      suma,
      sumb : real;
      temp_q : one_quan_table;
  begin
    for y := 0 to 7 do begin
        for x := 0 to 7 do begin
  
            suma := 0;
            for u := 0 to 7 do begin
                sumb := 0;
                for v := 0 to 7 do begin
                    sumb := sumb + (c[u,v] * one.q_int[u,v] *
                                    cos( ((2*x+1) * u * pi) / 16 ) *
                                    cos( ((2*y+1) * v * pi) / 16 ));
                end;
                suma := suma + sumb;
            end;
            suma := suma * 0.25;
            temp_q.q_int[x,y] := trunc(suma) + 120;
        end;
    end;
  
    for y := 0 to 7 do begin
        for x := 0 to 7 do begin
            one.q_int[x,y] :=  temp_q.q_int[x,y];
        end;
    end;

  end;

{:::::::::::::::::::::::}
{: JFIF Segment marker :}
{:::::::::::::::::::::::}

{: IF JFIF+#0 does not follow the header, then skip by LEN - 7.  :}
{: Two bytes have ben passed to read LEN, and five to read JFIF0 :}

  Function DO_app0(VAR block : array of byte; Len : word;
                   VAR info : app0_info ) : boolean;
  const string_len = 5;
  VAR Jfif_ID : STRING; {JFIF + #0}
      Cur    : word;
  BEGIN
    cur := 0;
  
    move(block[cur], Jfif_ID[1], string_len); Jfif_ID[0]:= chr(string_len);
    inc(cur, string_len);
    Len := Len - string_len;
  
    IF  (Jfif_ID<>('JFIF'+#0)) then begin
        {Bskip(F, len);}
        do_app0 := false;
    end ELSE BEGIN
  
  
        move(block[cur], Info, SizeOf(Info));
        inc(cur, SizeOf(Info));
        dec(Len, SizeOf(Info));
        if  info.revision.major < 1 then begin
            {writeln(DE,' Invalid Revision version.');}
            exit;
        end;
  
  
  
        IF  (info.thumb_x * info.thumb_Y * 3 <> 0) then begin
            {Bskip(f, info.thumb_x * info.thumb_Y * 3);}
            {the thumbnail N bytes; RGB 24bit W*H*3}
            len := len - (info.thumb_x * info.thumb_Y * 3);
        end;
        if  Len = 0 then
            do_app0 := True
        else
            do_app0 := False;
    END;

  END;

{:::::::::::::::::::::::::::::}
{: Define Quantization Table :}
{:::::::::::::::::::::::::::::}


PROCEDURE DO_DQT(VAR block : array of byte; Len : word;
                   VAR All_DQT : Quan_tables);
  {might work in all cases}
  VAR k,l  : byte;

      QT_info : byte;
      QT_prec : byte;
      QT_num  : byte;
  
      Cur     : word;
  BEGIN
    Cur := 0;
  
    repeat
      {::::::::::::::::}
      {: Read QT Info :}
      {::::::::::::::::}
  
      { Set all_dqt[ QT_num ]       }
      {                      .Valid }
      {                      .type  }
  
      Qt_info := Block[cur]; Inc(cur);  Len := Len -1;
      QT_num  := Qt_info and $0F;
      QT_prec := (Qt_info and $f0) shr 4;
  
      {:::::::::::::::::::}
      {: Read in Q table :}
      {:::::::::::::::::::}
  
      { Set all_dqt[ QT_num ]       }
      {                      .Q[]   }
  
      with all_dqt[ QT_num ] do begin
           valid := True;
           case QT_prec of
            0 : begin
                  Q_type := (bit_8);
                  move(block[cur], Q.Q_byte, Sizeof(Q_byte));
                  inc(cur, sizeof(Q_byte));
                  Len := Len -  SizeOf(Q_byte);
  
                end;
            1 : begin
                  Q_type := (bit_16);
                  move(block[cur], Q.Q_word, Sizeof(Q_word));
                  inc(cur, sizeof(Q_word));
                  Len := Len -  SizeOf(Q_word);
                end;
            ELSE BEGIN
                   {writeln(DE,'Invalid QT_precison in DO_DQT');}
                   halt(1);
                 END;
            END;
      END;
    until (len = 0);
  END;
  


  {:::::::::::::::::}
  {: Start Of Scan :}
  {:::::::::::::::::}

  PROCEDURE do_sos(VAR block : array of byte; Len : word;
                   Var Scan : Scan_info);
  var k,dw : word;   Done: boolean;
      db       : byte;
      Cur      : word;
  begin
    Cur := 0;
    with Scan do begin
         Comp_num := Block[cur]; inc(cur); dec(len);
         for K := 1 to Comp_num do begin
             Each[ K ].valid := true;

             Each[ K ].ID := id_type(block[cur]); inc(cur); dec(len);

             DB := block[cur]; inc(cur); dec(len);
             Each[ K ].huff_ac := db and $f;
             Each[ K ].huff_dc := (db and $f0) shr 4;
         end;
    end;
  end;


{::::::::::::::::::::::::}
{: Define Huffman Table :}
{::::::::::::::::::::::::}

  CONST Huff_mask : array[1..16] of
                  word =(  $01,  $03,  $07,  $0f,
                           $1f,  $3f,  $7f,  $ff,
                         $01ff,$03ff,$07ff,$0fff,
                         $1fff,$3fff,$7fff,$ffff);

  PROCEDURE DO_DHT(VAR block : array of byte; Len : word;
                   VAR all_dht : huff_tables);
  
  VAR DW : Word;
    j,k,l,
      cur     : byte;
      Sum     : word;
      Size    : byte;
      code    : word;
      lenths  : array[1..16] of byte;
  
      HT_info : byte;
      HT_num  : byte;
      HT_type : byte;
      {DW      : word;}
  BEGIN
  
    Cur := 0;
    Repeat
      {::::::::::::::::::}
      {: Read Huff Info :}
      {::::::::::::::::::}
  
      { SET ALL_DHT[HT_NUM]          }
      {                   .Valid     }
      {                   .H_type    }
  
      ht_info := block[cur]; inc(cur);
      Len := Len - 1;
      HT_num  := HT_info and $F;
      HT_type := (HT_info and $F0) shr 4;
  
      with all_dht[ huff_type(HT_TYPE) ].Table[ HT_num ] do begin
           Valid  := True;
           case HT_type of
            0 : H_type := DC;
            1 : H_type := AC;
           else begin
                  {writeln(DE,'Invalid Huffman table type.');}
                  halt(1);
                end;
           end;
      end;

      {$IFDEF DEBUG } writeln(DE,'-- HT num  : ',HT_num);
                      writeln(DE,'-- HT type : ',HT_type);
      {$ENDIF}
  
      {::::::::::::::::::}
      {: Read in lenths :}
      {::::::::::::::::::}
  
      move(block[cur], Lenths[1], 16); inc(cur,16);
      Len := Len - 16;
  
      {::::::::::::::::::::::}
      {: Read in symbols    :}
      {: partially borrowed :}
      {::::::::::::::::::::::}
  
      { SET ALL_DHT[HT_NUM]          }
      {                   .Valid     }
      {                   .H[].Len   }
      {                   .H[].Sym   }
      {                   .Max_code  }
  
  
  
      with all_dht[ huff_type(HT_TYPE) ].Table[ HT_num ] do begin
           L   := 1;
           sum := 0;
           For k := 1 to 16 do begin
  
               Sum := Sum + lenths[k];
               for j := 1 to lenths[k] do begin      {: if 0 then skipped   :}
                   H[L] .len := K;
  
                   H[L] .sym := block[cur];inc(cur); {: read in symbols     :}
                                                     {: as we go            :}
                   Len := Len - 1;
                   inc(L);
               end;
               Max_code[k] := L;
           end;
           H[L] .len := 0;                        {: Last will have Zero :}
      end;
  
  
      {::::::::::::::::::::::::}
      {: Create huffman Codes :}
      {: partially borrowed   :}
      {::::::::::::::::::::::::}

      { Set all_dht[HT_NUM]. H[].CODE }


      with all_dht[ huff_type(HT_TYPE) ].Table[ HT_num ] do begin
           L    := 1;
           Size := H[1].len;
           code := 0;
           while (H[L].len <> 0) do begin
                 while (H[L].len = Size) do begin
                       H[L].code := Huff_mask[ H[L].Len] and Code;
                       inc(L);
                       inc(Code);
                 end;
                 code := code shl 1;
                 inc(Size);
           end;
      end;
  
    until (Len = 0);
  END;
  

  PROCEDURE DO_DRI;
  VAR Len, dw2,dw: word;
  BEGIN
  END;





  PROCEDURE DO_sof0(VAR block : array of byte; Len : word;
                    VAR Frame : frame_0);
  VAR K,dw : word;
      db    : byte;

      Cur      : word;
  BEGIN
    cur := 0;

    with frame do begin
         precision    := block[cur]; inc(cur); dec(len);

         move(block[cur], image_height, 2); inc(cur,2); dec(len,2);
         image_height := hi_lo(image_height);

         move(block[cur], image_width, 2); inc(cur,2); dec(len,2);
         image_width := hi_lo(image_width);

         dw := block[cur]; inc(cur); dec(len);
         case dw of
          1 : begin
                comp_num := grey;
              end;
          3 : begin
                comp_num := color;
              end;
         else begin
                writeln('SOF0: component not supported.');
                halt(1);
              end;
         end;

         for K := 1 to DW do begin
             with frame.factor[K] do begin
                  db := block[cur]; Inc(cur); dec(len);
                  case db of
                   1 : ID := Y_;
                   2 : ID := CB_;
                   3 : ID := CR_;
                   4 : ID := I_;
                   5 : ID := Q_;
                  end;

                  db := block[cur]; Inc(cur); dec(len);
                  horz_factor := db and $f;
                  vert_factor := (db and $f0) shr 4;
                  q_num       := block[cur]; Inc(cur); dec(len);
             end; {with}
         end;
    end;
  END;
END.

{ ---------------------   TEST PROGRAM -------------------- }

{$A+,B-,D+,E+,F-,G+,I-,L+,N-,O-,P-,Q+,R+,S+,T-,V-,X-}

program tjpeg;
uses jpegsegm;


var f      : file;
    dw,
    length : word;
    db     : byte;
    darray : array[0..2047] of byte;
    ai     : app0_info;
    qts    : quan_tables;
    hts    : huff_tables;
    si     : scan_info;
    f0     : frame_0;
begin
  {:::::::::::::::::::::::::::::}
  {: Required JPEG/JFIF format :}
  {:::::::::::::::::::::::::::::}

  {: open file :}
  assign(F, paramstr(1)); filemode := 0;
  reset(f,1);
  if  (IOResult <> 0) then begin
      writeln('Syntax:  tjepg [filename]');
      writeln('Unable to open file: ', paramstr(1));
      halt(1);
  end;

  {: read soi header :}
  blockread(f, db, 1);
  blockread(f, db, 1);
  if  (db <> SOI) then begin
      writeln('File is missing required SOI header.');
      halt(1);
  end;

  {: read app0 block length :}
  blockread(f, db, 1);
  blockread(f, db, 1);
  if  (db <> app0) then begin
      writeln('File is missing reqired app0 header.');
      halt(1);
  end;

  {: read app0 block :}
  blockread(f, length, 2);
  length := hi_lo(length) - 2;

  blockread(f, darray, length);
  if  not do_app0( darray, length, ai) then begin
      writeln('Missing JFIF marked app0 segment.');
      halt(1);
  end;


  {::::::::::::::::::::::::::::::}
  {: process remaining segments :}
  {::::::::::::::::::::::::::::::}
  repeat
    blockread(f, db, 1, dw); {must be FF} if dw <> 1 then halt(2);
    blockread(f, db, 1, dw); {header ID } if dw <> 1 then halt(2);

    blockread(f, length, 2, dw);
    length := hi_lo(length) - 2;
    if  db in [dht,dqt,sof0,sos] then
        blockread(f, darray[0], length, dw);
    if dw <> length then halt(3);
    case db of
      dht  : do_dht (darray, length, hts);
      dqt  : do_dqt (darray, length, qts);
      sof0 : do_sof0(darray, length, f0);
      sos  :
      begin
        do_sos (darray, length, si);
        writeln('app0 information');
        writeln('  version : ',ai.revision.major,'.',ai.revision.minor);
        writeln('  xy_density units(0-2): ',ai.xy_density);
        writeln('  x density : ',ai.x);
        writeln('  y density : ',ai.y);
        writeln('  thumb x : ',ai.thumb_x);
        writeln('  thumb y : ',ai.thumb_y);

        writeln('sof0 information');
        writeln('  precision : ',f0.precision);
        writeln('  height : ',f0.image_height);
        writeln('  width  : ',f0.image_width);
        writeln('  number of components (1,3) :',byte(f0.comp_num));


        close(f);
        halt(1);
      end;
    end;
  until false;
end.

