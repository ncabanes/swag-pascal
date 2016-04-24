(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0042.PAS
  Description: ZIP Text Viewer
  Author: SAMUEL H. SMITH
  Date: 08-30-97  10:08
*)


(*
 * Copyright 1987, 1990 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * ZipTV - zipfile text view utility/door
 *
 *)

{$I prodef.inc}

{$M 5000,0,0} {minstack,minheap,maxheap}

{$D+}    {Global debug information}
{$L+}    {Local debug information}

{ $r+,s+}

program ZipTV;

Uses
   Dos, DosMem, MiniCrt, Mdosio, Tools, CInput;

const
   version = 'ZipTV:  ZIP Text Viewer v2.1 of 04-22-90;  (C) 1990 S.H.Smith';


(* ----------------------------------------------------------- *)
(*
 * ZIPfile layout declarations
 *
 *)

type
   signature_type = longint;

const
   local_file_header_signature = $04034b50;

type
   local_file_header = record
      version_needed_to_extract:    word;
      general_purpose_bit_flag:     word;
      compression_method:           word;
      last_mod_file_time:           word;
      last_mod_file_date:           word;
      crc32:                        longint;
      compressed_size:              longint;
      uncompressed_size:            longint;
      filename_length:              word;
      extra_field_length:           word;
   end;

const
   {general_purpose_bit_flag bit values}
   GP_encrypted   = 1;     {file is encrypted}
   GP_8K_dict     = 2;     {8k implode dictionary}
   GP_lit_tree    = 4;     {literal implode tree is present}


const
   central_file_header_signature = $02014b50;

type
   central_directory_file_header = record
      version_made_by:                 word;
      version_needed_to_extract:       word;
      general_purpose_bit_flag:        word;
      compression_method:              word;
      last_mod_file_time:              word;
      last_mod_file_date:              word;
      crc32:                           longint;
      compressed_size:                 longint;
      uncompressed_size:               longint;
      filename_length:                 word;
      extra_field_length:              word;
      file_comment_length:             word;
      disk_number_start:               word;
      internal_file_attributes:        word;
      external_file_attributes:        longint;
      relative_offset_local_header:    longint;
   end;

const
   end_central_dir_signature = $06054b50;

type
   end_central_dir_record = record
      number_this_disk:                         word;
      number_disk_with_start_central_directory: word;
      total_entries_central_dir_on_this_disk:   word;
      total_entries_central_dir:                word;
      size_central_directory:                   longint;
      offset_start_central_directory:           longint;
      zipfile_comment_length:                   word;
   end;

const
   compression_methods: array[0..7] of string[8] =
      (' Stored ',
       ' Shrunk ',
       'Reduce-1', 'Reduce-2', 'Reduce-3', 'Reduce-4',
       'Imploded',
       '    ?   ');


(* ----------------------------------------------------------- *)
(*
 * input file variables
 *
 *)

const
   uinbufsize = 512;    {input buffer size}

var
   zipeof:     boolean;

   csize:      longint;
   cusize:     longint;
   cmethod:    integer;
   cflags:     word;

   inbuf:      array[1..uinbufsize] of byte;
   inpos:      integer;
   incnt:      integer;
   pc:         byte;
   pcbits:     byte;
   pcbitv:     byte;
   zipfd:      dos_handle;
   zipfn:      dos_filename;



(* ----------------------------------------------------------- *)
(*
 * output stream variables
 *
 *)

const
   hsize =     8192;    {must be 8192 for 13 bit shrinking}

   max_binary = 50;     {non-printing count before binary file trigger}
   max_linelen = 200;   {line length before binary file triggered}

   maxlines: integer = 500;
                        {maximum lines per session}

var
   uoutbuf:             string[max_linelen];    {disp line buffer}
   binary_count:        integer;                {non-text chars so far}

   outbuf:              array[0..hsize] of byte; {must be >= 8192 for look-back}
   outpos:              longint;                 {absolute position in outfile}


(* ----------------------------------------------------------- *)
(*
 * other working storage
 *
 *)

var
   expand_files:        boolean;
   header_present:      boolean;
   default_pattern:     string20;
   pattern:             string20;
   action:              string20;



(* ----------------------------------------------------
 *
 *  Zipfile input/output handlers
 *
 *)

procedure skip_rest;
begin
   dos_lseek(zipfd,csize-incnt,seek_cur);
   zipeof := true;
   csize := 0;
   incnt := 0;
end;

procedure skip_csize;
begin
   incnt := 0;
   skip_rest;
end;


(* ------------------------------------------------------------- *)
procedure ReadByte(var x: byte);
begin
   if incnt = 0 then
   begin
      if csize = 0 then
      begin
         zipeof := true;
         exit;
      end;

      inpos := sizeof(inbuf);
      if inpos > csize then
         inpos := csize;
      incnt := dos_read(zipfd,inbuf,inpos);

      inpos := 1;
      dec(csize,incnt);
   end;

   x := inbuf[inpos];
   inc(inpos);
   dec(incnt);
end;


(* ------------------------------------------------------------- *)
procedure ReadBits(bits: integer; var x: integer);
   {read the specified number of bits}
var
   bit:     integer;
   bitv:    integer;

begin

(****
write('readbits n=',bits,' b=');
****)

   x := 0;
   bitv := 1;

   for bit := 0 to bits-1 do
   begin

      if pcbits > 0 then
      begin
         dec(pcbits);
         pcbitv := pcbitv shl 1;
      end
      else

      begin
         ReadByte(pc);
         pcbits := 7;
         pcbitv := 1;
      end;

      if (pc and pcbitv) <> 0 then
         x := x or bitv;

      bitv := bitv shl 1;
   end;

(****
writeln(' -> ',x,' = ',binary(x));
*****)

end;


(* ---------------------------------------------------------- *)
procedure get_string(len: integer; var s: string);
var
   n: integer;
begin
   if len <= 255 then
      n := dos_read(zipfd,s[1],len)
   else
   begin
      n := dos_read(zipfd,s[1],255);
      dos_lseek(zipfd,len-255,seek_cur);
      len := 255;
   end;

   s[0] := chr(len);
end;


(* ------------------------------------------------------------- *)
procedure OutByte (c: integer);
   (* output each character from archive to screen *)

   procedure flushbuf;
   begin
      disp(uoutbuf);
      uoutbuf := '';
   end;

   procedure addchar;
   begin
      inc(uoutbuf[0]);
      uoutbuf[length(uoutbuf)] := chr(c);
   end;

   procedure not_text;
   begin
      newline;
      displn('This is not a text file!');
      linenum := 1000;
      skip_rest;
   end;
   
begin
   outbuf[outpos mod sizeof(outbuf)] := c;
   inc(outpos);

(********
if debug then begin
if c = 13 then else
if c = 10 then begin
   if nomore then
      skip_rest
   else
      newline;
end else write(chr(c));
writeln(' [outbyte c=',c:3,' outpos=',outpos-1:5,']');
if keypressed and (readkey=#27) then halt;
exit; end;
********)

   case c of
   10:  begin
           if linenum < 1000 then
           begin
              flushbuf;
              newline;

              dec(maxlines);
              if (maxlines < 1) and (not dump_user) then
              begin
                  newline;
                  displn('You''ve seen enough.  Please download this file if you want to see more.');
                  dump_user := true;
              end;
           end;

           if nomore or dump_user then
              skip_rest;
        end;

   13:   ;

   26: begin
          flushbuf;
          skip_rest;         {jump to nomore mode on ^z}
       end;

   8,9,32..255:
       begin
          if length(uoutbuf) >= max_linelen then
          begin
             flushbuf;
             if csize > 10 then
                not_text;
          end;

          if linenum < 1000 then   {stop display on nomore}
             addchar;
       end;

   else
      begin
         if binary_count < max_binary then
            inc(binary_count)
         else
         if csize > 10 then
            not_text;
      end;
   end;

end;


(* ------------------------------------------------------------- *)
(*
 * The Reducing algorithm is actually a combination of two
 * distinct algorithms.  The first algorithm compresses repeated
 * byte sequences, and the second algorithm takes the compressed
 * stream from the first algorithm and applies a probabilistic
 * compression method.
 *
 *)

procedure unReduce;
   {expand probablisticly reduced data}

   type
      Sarray = array[0..255] of string[64];

   var
      factor:     integer;
      followers:  ^Sarray;
      ExState:    integer;
      C:          integer;
      V:          integer;
      Len:        integer;

   const
      Lmask:   array[1..4] of integer = ($7f,$3f,$1f,$0f);
      Fcase:   array[1..4] of integer = (127, 63, 31, 15);
      Dshift:  array[1..4] of integer = (7,6,5,4);
      Dand:    array[1..4] of integer = ($01,$03,$07,$0f);


   procedure Expand(c: byte);
   const
      DLE = 144;
   var
      op:   longint;
      i:    integer;

   begin

      case ExState of
           0:  if C <> DLE then
                   OutByte(C)
               else
                   ExState := 1;

           1:  if C <> 0 then
               begin
                   V := C;
                   Len := V and Lmask[factor];
                   if Len = Fcase[factor] then
                     ExState := 2
                   else
                     ExState := 3;
               end
               else
               begin
                   OutByte(DLE);
                   ExState := 0;
               end;

           2:  begin
                  inc(Len,C);
                  ExState := 3;
               end;

           3:  begin
                  op := outpos - C - 1 - ((V shr Dshift[factor]) and
                                          Dand[factor]) * 256;

                  for i := 0 to Len+2 do
                  begin
                     if op < 0 then
                        OutByte(0)
                     else
                        OutByte(outbuf[op mod sizeof(outbuf)]);
                     inc(op);
                  end;

                  ExState := 0;
               end;
      end;
   end;


   procedure LoadFollowers;
   var
      x: integer;
      i: integer;
      b: integer;
   begin
      for x := 255 downto 0 do
      begin
         ReadBits(6,b);
         followers^[x][0] := chr(b);

         for i := 1 to length(followers^[x]) do
         begin
            ReadBits(8,b);
            followers^[x][i] := chr(b);
         end;
      end;
   end;


   function B(x: byte): word;
      {number of bits needed to encode the specified number}
   begin
      case x-1 of
         0..1:    B := 1;
         2..3:    B := 2;
         4..7:    B := 3;
         8..15:   B := 4;
        16..31:   B := 5;
        32..63:   B := 6;
        64..127:  B := 7;
      else        B := 8;
      end;
   end;


(* ----------------------------------------------------------- *)
var
   lchar:   integer;
   lout:    integer;
   I:       integer;
   mem:     longint;

begin
   mem := (sizeof(followers^)+100) - dos_maxavail;
   if mem > 0 then
   begin
      displn(ltoa(mem)+' more bytes of RAM needed to UnReduce!');
      skip_csize;
      exit;
   end;

   factor := cmethod - 1;
   if (factor < 1) or (factor > 4) then
   begin
      skip_csize;
      exit;
   end;

   dos_getmem(followers,sizeof(followers^));
   ExState := 0;
   LoadFollowers;
   lchar := 0;

   while (not zipeof) and (outpos < cusize) and (not dump_user) do
   begin

      if followers^[lchar] = '' then
         ReadBits( 8,lout )
      else

      begin
         ReadBits(1,lout);
         if lout <> 0 then
            ReadBits( 8,lout )
         else
         begin
            ReadBits( B(length(followers^[lchar])), I );
            lout := ord( followers^[lchar][I+1] );
         end;
      end;

      Expand( lout );
      lchar := lout;
   end;

   dos_freemem(followers);
end;



(* ------------------------------------------------------------- *)
(*
 * UnShrinking
 * -----------
 *
 * Shrinking is a Dynamic Ziv-Lempel-Welch compression algorithm
 * with partial clearing.  The initial code size is 9 bits, and
 * the maximum code size is 13 bits.  Shrinking differs from
 * conventional Dynamic Ziv-lempel-Welch implementations in several
 * respects:
 *
 * 1)  The code size is controlled by the compressor, and is not
 *     automatically increased when codes larger than the current
 *     code size are created (but not necessarily used).  When
 *     the decompressor encounters the code sequence 256
 *     (decimal) followed by 1, it should increase the code size
 *     read from the input stream to the next bit size.  No
 *     blocking of the codes is performed, so the next code at
 *     the increased size should be read from the input stream
 *     immediately after where the previous code at the smaller
 *     bit size was read.  Again, the decompressor should not
 *     increase the code size used until the sequence 256,1 is
 *     encountered.
 *
 * 2)  When the table becomes full, total clearing is not
 *     performed.  Rather, when the compresser emits the code
 *     sequence 256,2 (decimal), the decompressor should clear
 *     all leaf nodes from the Ziv-Lempel tree, and continue to
 *     use the current code size.  The nodes that are cleared
 *     from the Ziv-Lempel tree are then re-used, with the lowest
 *     code value re-used first, and the highest code value
 *     re-used last.  The compressor can emit the sequence 256,2
 *     at any time.
 *
 *)

procedure unShrink;

const
   max_bits =  13;
   init_bits = 9;
   first_ent = 257;
   clear =     256;
   
type
   hsize_array_integer = array[0..hsize] of integer;
   hsize_array_byte    = array[0..hsize] of byte;

var
   cbits:      integer;
   maxcode:    integer;
   free_ent:   integer;
   maxcodemax: integer;
   offset:     integer;
   sizex:      integer;
   prefix_of:  ^hsize_array_integer;
   suffix_of:  ^hsize_array_byte;
   stack:      hsize_array_byte absolute outbuf;
   stackp:     integer;
   finchar:    integer;
   code:       integer;
   oldcode:    integer;
   incode:     integer;


   (* ------------------------------------------------------------- *)
   procedure partial_clear;
   var
      pr:   integer;
      cd:   integer;

   begin
      {mark all nodes as potentially unused}
      for cd := first_ent to free_ent-1 do
         word(prefix_of^[cd]) := prefix_of^[cd] or $8000;


      {unmark those that are used by other nodes}
      for cd := first_ent to free_ent-1 do
      begin
         pr := prefix_of^[cd] and $7fff;    {reference to another node?}
         if pr >= first_ent then            {flag node as referenced}
            prefix_of^[pr] := prefix_of^[pr] and $7fff;
      end;


      {clear the ones that are still marked}
      for cd := first_ent to free_ent-1 do
         if (prefix_of^[cd] and $8000) <> 0 then
            prefix_of^[cd] := -1;


      {find first cleared node as next free_ent}
      free_ent := first_ent;
      while (free_ent < maxcodemax) and (prefix_of^[free_ent] <> -1) do
         inc(free_ent);
   end;



(* ------------------------------------------------------------- *)
var
   mem:  longint;
begin
   mem := (sizeof(prefix_of^)+sizeof(suffix_of^)+ 100) - dos_maxavail;

   if mem > 0 then
   begin
      displn(ltoa(mem)+' more bytes of RAM needed to UnShrink!');
      skip_csize;
      exit;
   end;


   {allocate heap storage}
   dos_getmem(prefix_of,sizeof(prefix_of^));
   dos_getmem(suffix_of,sizeof(suffix_of^));


   {decompress the file}
   maxcodemax := 1 shl max_bits;
   cbits := init_bits;
   maxcode := (1 shl cbits)- 1;
   free_ent := first_ent;
   offset := 0;
   sizex := 0;

   fillchar(prefix_of^,sizeof(prefix_of^),$FF);
   for code := 255 downto 0 do
   begin
      prefix_of^[code] := 0;
      suffix_of^[code] := code;
   end;

   ReadBits(cbits,oldcode);
   finchar := oldcode;
   if zipeof then
      exit;

   OutByte(finchar);

   stackp := 0;

   while (not zipeof) and (not dump_user) do
   begin
      ReadBits(cbits,code);

      while code = clear do
      begin
         ReadBits(cbits,code);

         case code of
            1: begin
                  inc(cbits);
                  if cbits = max_bits then
                     maxcode := maxcodemax
                  else
                     maxcode := (1 shl cbits) - 1;
               end;

            2: partial_clear;
         end;

         ReadBits(cbits,code);
      end;


      {special case for KwKwK string}
      incode := code;
      if prefix_of^[code] = -1 then
      begin
         stack[stackp] := finchar;
         inc(stackp);
         code := oldcode;
      end;


      {generate output characters in reverse order}
      while (code >= first_ent) and (stackp < sizeof(stack)-1) do
      begin
         stack[stackp] := suffix_of^[code];
         inc(stackp);
         code := prefix_of^[code];
      end;

      finchar := suffix_of^[code];
      stack[stackp] := finchar;
      inc(stackp);


      {and put them out in forward order}
      while (stackp > 0) do
      begin
         outpos := stackp; {required to preserve shared buffer/stack}
         dec(stackp);
         OutByte(stack[stackp]);
      end;


      {generate new entry}
      code := free_ent;
      if code < maxcodemax then
      begin
         prefix_of^[code] := oldcode;  {previous code}
         suffix_of^[code] := finchar;  {final character from this code}
         while (free_ent < maxcodemax) and (prefix_of^[free_ent] <> -1) do
            inc(free_ent);
      end;


      {remember previous code}
      oldcode := incode;
   end;


   {release heap storage}
   dos_freemem(suffix_of);
   dos_freemem(prefix_of);
end;


(* ------------------------------------------------------------- *)
(*
 * Imploding
 * ---------
 *
 * The Imploding algorithm is actually a combination of two distinct
 * algorithms.  The first algorithm compresses repeated byte sequences
 * using a sliding dictionary.  The second algorithm is used to compress
 * the encoding of the sliding dictionary ouput, using multiple
 * Shannon-Fano trees.
 *
 *)

procedure unImplode;
   {expand imploded data}

   const
      maxSF = 256;

   type
      sf_entry = record
                    Code:       word;
                    Value:      byte;
                    BitLength:  byte;
                 end;

      sf_tree = record  {a shannon-fano tree}
         entry:         array[0..maxSF] of sf_entry;
         entries:       integer;
         MaxLength:     integer;
      end;

      sf_treep = ^sf_tree;

   var
      lit_tree:               sf_treep;
      length_tree:            sf_treep;
      distance_tree:          sf_treep;
      lit_tree_present:       boolean;
      eightK_dictionary:      boolean;
      minimum_match_length:   integer;
      dict_bits:              integer;


   (* ----------------------------------------------------------- *)
   procedure LoadTree(var tree: sf_treep;
                      treesize: integer);
      {allocate and load a shannon-fano tree from the compressed file}

      procedure SortLengths;
         {Sort the Bit Lengths in ascending order, while retaining the order
          of the original lengths stored in the file}
      var
         x:       integer;
         gap:     integer;
         t:       sf_entry;
         noswaps: boolean;
         a,b:     word;

      begin
         gap := treesize div 2;

         with tree^ do
         repeat
            repeat
               noswaps := true;
               for x := 0 to (treesize-1)-gap do
               begin
                  a := entry[x].BitLength;
                  b := entry[x+gap].BitLength;
                  if (a > b) or
                     ((a = b) and (entry[x].Value > entry[x+gap].Value)) then
                  begin
                     t := entry[x];
                     entry[x] := entry[x+gap];
                     entry[x+gap] := t;
                     noswaps := false;
                  end;
               end;
            until noswaps;

            gap := gap div 2;
         until gap < 1;
      end;


      procedure ReadLengths;
      var
         treeBytes:  integer;
         i:          integer;
         num,len:    integer;
      begin
         {get number of bytes in compressed tree}
         ReadBits(8,treeBytes);
         inc(treeBytes);
         i := 0;
         with tree^ do
         begin
            MaxLength := 0;

            {High 4 bits: Number of values at this bit length + 1. (1 - 16)
             Low  4 bits: Bit Length needed to represent value + 1. (1 - 16)}
            while treeBytes > 0 do
            begin
               ReadBits(4,len);  inc(len);
               ReadBits(4,num);  inc(num);

               while num > 0 do
               with entry[i] do
               begin
                  if len > MaxLength then
                     MaxLength := len;
                  BitLength := len;
                  Value := i;
                  inc(i);
                  dec(num);
               end;

               dec(treeBytes);
            end;
         end;
      end;

      procedure GenerateTrees;
         {Generate the Shannon-Fano trees}
      var
         Code:          word;
         CodeIncrement: integer;
         LastBitLength: integer;
         i:             integer;
      begin
         Code := 0;
         CodeIncrement := 0;
         LastBitLength := 0;

         i := treesize - 1;   {either 255 or 63}
         with tree^ do
         while i >= 0 do
         begin
            inc(Code,CodeIncrement);
            if entry[i].BitLength <> LastBitLength then
            begin
               LastBitLength := entry[i].BitLength;
               CodeIncrement := 1 shl (16 - LastBitLength);
            end;

            entry[i].Code := Code;
            dec(i);
         end;
      end;

      procedure ReverseBits;
         {Reverse the order of all the bits in the above ShannonCode[]
          vector, so that the most significant bit becomes the least
          significant bit. For example, the value 0x1234 (hex) would become
          0x2C48 (hex).}
      var
         i:    integer;
         mask: word;
         revb: word;
         v:    word;
         o:    word;
         b:    integer;

      begin
         for i := 0 to treesize-1 do
         begin
            {get original code}
            o := tree^.entry[i].Code;

            {reverse each bit}
            mask := $0001;
            revb := $8000;
            v := 0;
            for b := 0 to 15 do
            begin
               {if bit set in mask, then substitute reversed bit}
               if (o and mask) <> 0 then
                  v := v or revb;

               {advance to next bit}
               revb := revb shr 1;
               mask := mask shl 1;
            end;

            {store reversed bits}
            tree^.entry[i].Code := v;
         end;
      end;

   begin
      dos_getmem(tree,sizeof(tree^));
      tree^.entries := treesize;
      ReadLengths;
      SortLengths;
      GenerateTrees;
      ReverseBits;
   end;


   (* ----------------------------------------------------------- *)
   procedure LoadTrees;
   begin
      eightK_dictionary := (cflags and GP_8k_dict)  <> 0;
      lit_tree_present  := (cflags and GP_lit_tree) <> 0;

      if eightK_dictionary then
         dict_bits := 7
      else
         dict_bits := 6;

      if lit_tree_present then
      begin
         minimum_match_length := 3;
         LoadTree(lit_tree,256);
      end
      else
         minimum_match_length := 2;

      LoadTree(length_tree,64);
      LoadTree(distance_tree,64);
   end;


   (* ----------------------------------------------------------- *)
   procedure ReadTree(tree: sf_treep;
                      var dest: integer);
      {read next byte using a shannon-fano tree}
   var
      bits: integer;
      cv:   word;
      b:    integer;
      cur:  integer;

   begin
      bits := 0;
      cv := 0;
      cur := 0;
      dest := -1; {in case of error}

      with tree^ do
      while true do
      begin
         ReadBits(1,b);
         cv := cv or (b shl bits);
         inc(bits);

         while entry[cur].BitLength < bits do
         begin
            inc(cur);
            if cur >= entries then
               exit;
         end;

         while entry[cur].BitLength = bits do
         begin
            if entry[cur].Code = cv then
            begin
               dest := entry[cur].Value;
               exit;
            end;

            inc(cur);
            if cur >= entries then
               exit;
         end;
      end;

   end;


(* ----------------------------------------------------------- *)
var
   lout:       integer;
   mem:        longint;
   op:         longint;
   Length:     integer;
   Distance:   integer;
   i:          integer;

begin
   mem := (sizeof(sf_tree)*3+100) - dos_maxavail;
   if mem > 0 then
   begin
      displn(ltoa(mem)+' more bytes of RAM needed to UnImplode!');
      skip_csize;
      exit;
   end;

   LoadTrees;

   while (not zipeof) and (outpos < cusize) and (not dump_user) do
   begin
      ReadBits(1,lout);

      if lout <> 0 then    {encoded data is literal data}
      begin
         if lit_tree_present then
            ReadTree(lit_tree,lout)   {use Literal Shannon-Fano tree}
         else
            ReadBits(8,lout);

         OutByte(lout);
      end
      else

      begin          {encoded data is sliding dictionary match}
         readBits(dict_bits,lout);
         Distance := lout;

         ReadTree(distance_tree,lout);
         Distance := Distance or (lout shl dict_bits);
         {using the Distance Shannon-Fano tree, read and decode the
            upper 6 bits of the Distance value}

         ReadTree(length_tree,Length);
         {using the Length Shannon-Fano tree, read and decode the Length value}

         inc(Length,Minimum_Match_Length);
         if Length = (63 + Minimum_Match_Length) then
         begin
            ReadBits(8,lout);
            inc(Length,lout);
         end;

         {move backwards Distance+1 bytes in the output stream, and copy
          Length characters from this position to the output stream.
          (if this position is before the start of the output stream,
          then assume that all the data before the start of the output
          stream is filled with zeros)}

         op := outpos - Distance - 1;
         for i := 1 to Length do
         begin
            if op < 0 then
               OutByte(0)
            else
               OutByte(outbuf[op mod sizeof(outbuf)]);
            inc(op);
         end;
      end;
   end;

   if lit_tree_present then
      dos_freemem(lit_tree);
   dos_freemem(distance_tree);
   dos_freemem(length_tree);
end;



(* ---------------------------------------------------------- *)
(*
 * This procedure displays the text contents of a specified archive
 * file.  The filename must be fully specified and verified.
 *
 *)
procedure viewfile;
var
   b: byte;

begin
   newline;
   {default_color;}
   binary_count := 0;
   pcbits := 0;
   incnt := 0;
   outpos := 0;
   uoutbuf := '';
   zipeof := false;

   if (cflags and GP_encrypted) <> 0 then
   begin
      displn('File is encrypted.');
      skip_csize;
      exit;
   end;

   case cmethod of
      0:    {stored}
            while (not zipeof) and (not dump_user) do
            begin
               ReadByte(b);
               OutByte(b);
            end;

      1:    UnShrink;

      2..5: UnReduce;

      6:    UnImplode;

      else  begin
               displn('Unknown compression method.');
               skip_csize;
            end;
   end;

   if nomore=false then
      newline;

   linenum := 1;
end;


(* ---------------------------------------------------------- *)
procedure _itoa(i: integer; var sp);
var
   s: array[1..2] of char absolute sp;
begin
   s[1] := chr( (i div 10) + ord('0'));
   s[2] := chr( (i mod 10) + ord('0'));
end;

function format_date(date: word): string8;
const
   s:       string8 = 'mm-dd-yy';
begin
   _itoa(((date shr 9) and 127)+80, s[7]);
   _itoa( (date shr 5) and 15,  s[1]);
   _itoa( (date      ) and 31,  s[4]);
   format_date := s;
end;

function format_time(time: word): string8;
const
   s:       string8 = 'hh:mm:ss';
begin
   _itoa( (time shr 11) and 31, s[1]);
   _itoa( (time shr  5) and 63, s[4]);
   _itoa( (time shl  1) and 63, s[7]);
   format_time := s;
end;


(* ---------------------------------------------------------- *)
procedure process_local_file_header;
var
   n:             word;
   rec:           local_file_header;
   filename:      string;
   extra:         string;
   fpos:          longint;

begin
   dos_lseek(zipfd,0,seek_cur);
   fpos := dos_tell;

   while (dump_user = false) do
   begin
      set_function(fun_arcview);

      dos_lseek(zipfd,fpos,seek_start);
      n := dos_read(zipfd,rec,sizeof(rec));
      get_string(rec.filename_length,filename);
      filename := remove_path(filename);
      stoupper(filename);
      get_string(rec.extra_field_length,extra);
      csize := rec.compressed_size;
      cusize := rec.uncompressed_size;
      cmethod := rec.compression_method;
      cflags := rec.general_purpose_bit_flag;


      (* exclude the file if outside current pattern *)
      if nomore or (not wildcard_match(pattern,filename)) then
      begin
         skip_csize;
         exit;
      end;

      (* display file information headers if needed *)
      if not header_present then
      begin
         header_present := true;

         newline;
         disp(' File Name    Length   Method     Date      Time');
         if expand_files then disp('    (Enter) or (S)kip, (V)iew');
         newline;

         disp('------------  ------  --------  --------  --------');
         if expand_files then disp('  -------------------------');
         newline;
      end;


      (* display file information *)
      disp(ljust(filename,12)+' '+
           rjust(ltoa(rec.uncompressed_size),7)+'  '+
           compression_methods[rec.compression_method]+'  '+
           format_date(rec.last_mod_file_date)+'  '+
           format_time(rec.last_mod_file_time));

      if not expand_files then
      begin
         skip_csize;
         newline;
         exit;
      end;


      (* determine action to perform on this member file *)
      action := 'S';
      disp('  Action? ');
      input(action,1);
      stoupper(action);

      case action[1] of
         'S':
            begin
               displn(' [Skip]');
               skip_csize;
               exit;
            end;

         'V','R':
            begin
               displn(' [View]');
               viewfile;

               header_present := false;

            {  make_log_entry('View archive member ('+extname
                                        +') from ('+remove_path(arcname)
                                        +')',true); }
            end;

         'Q':
            begin
               displn(' [Quit]');
               dos_lseek(zipfd,0,seek_end);
               exit;
            end;

         else
            displn(' [Type S, V or Q!]');
      end;
   end;
end;


(* ---------------------------------------------------------- *)
procedure process_central_file_header;
var
   n:             word;
   rec:           central_directory_file_header;
   filename:      string;
   extra:         string;
   comment:       string;

begin
   n := dos_read(zipfd,rec,sizeof(rec));
   get_string(rec.filename_length,filename);
   get_string(rec.extra_field_length,extra);
   get_string(rec.file_comment_length,comment);
  {dos_lseek(zipfd,rec.compressed_size,seek_cur);}
end;


(* ---------------------------------------------------------- *)
procedure process_end_central_dir;
var
   n:             word;
   rec:           end_central_dir_record;
   comment:       string;

begin
   n := dos_read(zipfd,rec,sizeof(rec));
   get_string(rec.zipfile_comment_length,comment);
end;


(* ---------------------------------------------------------- *)
procedure process_headers;
var
   sig:  longint;

begin
   dos_lseek(zipfd,0,seek_start);
   header_present := false;

   while (not dump_user) do
   begin
      if nomore or (dos_read(zipfd,sig,sizeof(sig)) <> sizeof(sig)) then
         exit
      else

      if sig = local_file_header_signature then
         process_local_file_header
      else

      if sig = central_file_header_signature then
         process_central_file_header
      else

      if sig = end_central_dir_signature then
      begin
         process_end_central_dir;
         exit;
      end

      else
      begin
         displn('Invalid Zipfile Header');
         exit;
      end;
   end;

end;


(* ---------------------------------------------------------- *)
procedure select_pattern;
begin
   default_pattern := '*.*';

   while true do
   begin
      newline;
      disp(remove_path(zipfn));
      get_def(': View member filespec:', enter_eq+default_pattern+'? ');
      
      get_nextpar;
      pattern := par;
      stoupper(pattern);
      if length(pattern) = 0 then
         pattern := default_pattern;

      if (pattern = 'none') or (pattern = 'Q') or dump_user then
         exit;
   
      process_headers;
   
      default_pattern := 'none';
   end;
end;


(* ---------------------------------------------------------- *)
procedure view_zipfile;
begin
   zipfd := dos_open(zipfn,open_read);
   if zipfd = dos_error then
      exit;

   if expand_files then
      select_pattern
   else
   begin
      pattern := '*.*';
      process_headers;
   end;

   dos_close(zipfd);
end;



(* ---------------------------------------------------------- *)
procedure process_zipfile(name: filenames);
var
   mem:    longint;

begin
   linenum := 1;
   cmdline := '';
   expand_files := false;
   zipfn := name;
   view_zipfile;

   newline;
   get_def('View text files in this zipfile:','(Enter)=yes? ');

   (* process text viewing if desired *)
   get_nextpar;
   if par[1] <> 'N' then
   begin
      expand_files := true;
      view_zipfile;
   end;
end;


(*
 * main program
 *
 *)

var
   i:    integer;
   n:    integer;
   par:  anystring;

begin
   gotoxy(60,scroll_line+1);
   reverseVideo;
   disp(' ZipTV ');

   SetScrollPoint(scroll_line);
   gotoxy(1,23);  lowVideo;
   linenum := 1;

   if paramcount = 0 then
   begin
      displn(version);
{     newline;
      displn('Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.');
      newline;  }

      displn('Usage:  ziptv [-Pport] [-Tminutes] [-Llines] [-Mlines] FILE[.zip]');

{     newline;
      displn('-Pn   enables com port COMn and monitors carrier');
      displn('-Tn   allows user to stay in program for n minutes');
      displn('-Ln   sets lines per screen');
      displn('-Mn   sets maximum lines per session');
}
      halt;
   end;

   for i := 1 to paramcount do
   begin
      par := paramstr(i);
      n := atoi(copy(par,3,5));

      if par[1] = '-' then
         case upcase(par[2]) of
            'P':  opencom(n);
            'T':  tlimit := n;      {time limit}
            'L':  user.pagelen := n;
            'M':  maxlines := n;
         end
      else

      begin
        if pos('.',par) = 0 then
            par := par + '.ZIP';

        if dos_exists(par) then
            process_zipfile(par)
        else
            displn('File not found: '+par);
      end;
   end;

   newline;
   displn(version);
   closecom;
end.



