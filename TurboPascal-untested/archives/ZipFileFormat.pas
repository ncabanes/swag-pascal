(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0022.PAS
  Description: Zip File Format
  Author: PHIL KATZ
  Date: 08-24-94  17:57
*)


System of Origin : IBM

Original author : Phil Katz

FILE FORMAT
-----------

Files stored in arbitrary order.  Large zipfiles can span multiple
diskette media. 
 
          Local File Header 1 
                    file 1 extra field 
                    file 1 comment 
               file data 1 
          Local File Header 2 
                    file 2 extra field 
                    file 2 comment
               file data 2
          . 
          . 
          . 
          Local File Header n 
                    file n extra field 
                    file n comment 
               file data n 
     Central Directory 
               central extra field
               central comment
          End of Central Directory
                    end comment
EOF


LOCAL FILE HEADER
-----------------

OFFSET LABEL       TYP  VALUE        DESCRIPTION
------ ----------- ---- ----------- ---------------------------------- 
00     ZIPLOCSIG   HEX  04034B50    ;Local File Header Signature 
04     ZIPVER      DW   0000        ;Version needed to extract 
06     ZIPGENFLG   DW   0000        ;General purpose bit flag 
08     ZIPMTHD     DW   0000        ;Compression method 
0A     ZIPTIME     DW   0000        ;Last mod file time (MS-DOS) 
0C     ZIPDATE     DW   0000        ;Last mod file date (MS-DOS) 
0E     ZIPCRC      HEX  00000000    ;CRC-32
12     ZIPSIZE     HEX  00000000    ;Compressed size 
16     ZIPUNCMP    HEX  00000000    ;Uncompressed size
1A     ZIPFNLN     DW   0000        ;Filename length
1C     ZIPXTRALN   DW   0000        ;Extra field length 
1E     ZIPNAME     DS   ZIPFNLN     ;filename 
--     ZIPXTRA     DS   ZIPXTRALN   ;extra field 
 
CENTRAL DIRECTORY STRUCTURE
--------------------------- 
 
OFFSET LABEL       TYP  VALUE        DESCRIPTION
------ ----------- ---- ----------- ----------------------------------
00     ZIPCENSIG   HEX  02014B50    ;Central file header signature 
04     ZIPCVER     DB   00          ;Version made by 
05     ZIPCOS      DB   00          ;Host operating system 
06     ZIPCVXT     DB   00          ;Version needed to extract 
07     ZIPCEXOS    DB   00          ;O/S of version needed for extraction 
08     ZIPCFLG     DW   0000        ;General purpose bit flag 
0A     ZIPCMTHD    DW   0000        ;Compression method 
0C     ZIPCTIM     DW   0000        ;Last mod file time (MS-DOS)
0E     ZIPCDAT     DW   0000        ;Last mod file date (MS-DOS) 
10     ZIPCCRC     HEX  00000000    ;CRC-32
14     ZIPCSIZ     HEX  00000000    ;Compressed size
18     ZIPCUNC     HEX  00000000    ;Uncompressed size 
1C     ZIPCFNL     DW   0000        ;Filename length 
1E     ZIPCXTL     DW   0000        ;Extra field length 
20     ZIPCCML     DW   0000        ;File comment length 
22     ZIPDSK      DW   0000        ;Disk number start
24     ZIPINT      DW   0000        ;Internal file attributes 
 
       LABEL       BIT        DESCRIPTION
       ----------- --------- -----------------------------------------
       ZIPINT         0       if = 1, file is apparently an ASCII or 
                              text file 
                      0       if = 0, file apparently contains binary 
                              data 

                     1-7      unused in version 1.0.
 
26     ZIPEXT      HEX  00000000    ;External file attributes, host 
                                    ;system dependent
2A     ZIPOFST     HEX  00000000    ;Relative offset of local header 
                                    ;from the start of the first disk 
                                    ;on which this file appears
2E     ZIPCFN      DS   ZIPCFNL     ;Filename or path - should not 
                                    ;contain a drive or device letter, 
                                    ;or a leading slash. All slashes 
                                    ;should be forward slashes '/' 
--     ZIPCXTR     DS   ZIPCXTL     ;extra field
--     ZIPCOM      DS   ZIPCCML     ;file comment


END OF CENTRAL DIR STRUCTURE
---------------------------- 
 
OFFSET LABEL       TYP  VALUE        DESCRIPTION 
------ ----------- ---- ----------- ---------------------------------- 
00     ZIPESIG     HEX  06064B50    ;End of central dir signature
04     ZIPEDSK     DW   0000        ;Number of this disk 
06     ZIPECEN     DW   0000        ;Number of disk with start central dir 
08     ZIPENUM     DW   0000        ;Total number of entries in central dir 
                                    ;on this disk 
0A     ZIPECENN    DW   0000        ;total number entries in central dir 
0C     ZIPECSZ     HEX  00000000    ;Size of the central directory
10     ZIPEOFST    HEX  00000000    ;Offset of start of central directory 
                                    ;with respect to the starting disk
                                    ;number 
14     ZIPECOML    DW   0000        ;zipfile comment length 
16     ZIPECOM     DS   ZIPECOML    ;zipfile comment
 
 
ZIP VALUES LEGEND
-----------------
 
       HOST O/S 
 
       VALUE  DESCRIPTION               VALUE  DESCRIPTION 
       ----- -------------------------- ----- ------------------------
       0      MS-DOS and OS/2 (FAT)     5      Atari ST 
       1      Amiga                     6      OS/2 1.2 extended file sys 
       2      VMS                       7      Macintosh 
       3      *nix                      8 thru 
       4      VM/CMS                    255    unused 

 
       GENERAL PURPOSE BIT FLAG 
 
       LABEL       BIT        DESCRIPTION 
       ----------- --------- -----------------------------------------
       ZIPGENFLG      0       If set, file is encrypted 
          or          1       If file Imploded and this bit is set, 8K 
       ZIPCFLG                sliding dictionary was used. If clear, 4K
                              sliding dictionary was used.
                      2       If file Imploded and this bit is set, 3 
                              Shannon-Fano trees were used. If clear, 2 
                              Shannon-Fano trees were used. 
                     3-4      unused 
                     5-7      used internaly by ZIP
 
       Note:  Bits 1 and 2 are undefined if the compression method is 
              other than type 6 (Imploding). 
 

       COMPRESSION METHOD
 
       NAME        METHOD  DESCRIPTION 
       ----------- ------ -------------------------------------------- 
       Stored         0    No compression used 
       Shrunk         1    LZW, 8K buffer, 9-13 bits with partial clearing 
       Reduced-1      2    Probalistic compression, L(X) = lower 7 bits 
       Reduced-2      3    Probalistic compression, L(X) = lower 6 bits 
       Reduced-3      4    Probalistic compression, L(X) = lower 5 bits 
       Reduced-4      5    Probalistic compression, L(X) = lower 4 bits
       Imploded       6    2 Shanno-Fano trees, 4K sliding dictionary
       Imploded       7    3 Shanno-Fano trees, 4K sliding dictionary 
       Imploded       8    2 Shanno-Fano trees, 8K sliding dictionary
       Imploded       9    3 Shanno-Fano trees, 8K sliding dictionary 

 
       EXTRA FIELD 

       OFFSET LABEL       TYP  VALUE       DESCRIPTION
       ------ ----------- ---- ---------- ----------------------------
       00     EX1ID       DW   0000        ;0-31 reserved by PKWARE
       02     EX1LN       DW   0000
       04     EX1DAT      DS   EX1LN       ;Specific data for individual
       .                                   ;files. Data field should begin
       .                                   ;with a s/w specific unique ID
       EX1LN+4
              EXnID       DW   0000
              EXnLN       DW   0000

              EXnDAT      DS   EXnLN       ;entire header may not exceed 64k



