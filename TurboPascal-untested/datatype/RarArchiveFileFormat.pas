(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0035.PAS
  Description: RAR Archive File Format
  Author: ANDREW EIGUS
  Date: 05-26-95  23:26
*)

{
> Does anyone have the structures for RAR archived files?

 ██████╗   █████╗  ██████╗
 ██╔══██╗ ██╔══██╗ ██╔══██╗     RAR version 1.53 - Technical information
 ██████╔╝ ███████║ ██████╔╝     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 ██╔══██╗ ██╔══██║ ██╔══██╗
 ██║  ██║ ██║  ██║ ██║  ██║
 ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝

 ┌────────────────────────────────────────────────────────────────────────┐
 │THE ARCHIVE FORMAT DESCRIBED BELOW IS ONLY VALID FOR VERSIONS SINCE 1.50│
 └────────────────────────────────────────────────────────────────────────┘

 ╔════════════════════════════════════════════════════════════════════════╗
 ║ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ RAR archive file format ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒║
 ╚════════════════════════════════════════════════════════════════════════╝

   Archive file consists of variable length blocks. The order of these
blocks may vary, but the first block must be marker block followed by
an archive header block.

   Each block begins with following fields:

HEAD_CRC       2 bytes     CRC of total block or block part
HEAD_TYPE      1 byte      Block type
HEAD_FLAGS     2 bytes     Block flags
HEAD_SIZE      2 bytes     Block size
ADD_SIZE       4 bytes     Optional field - added block size

   Field ADD_SIZE present only if (HEAD_FLAGS & 0x8000) != 0

   Total block size is HEAD_SIZE if (HEAD_FLAGS & 0x8000) == 0
and HEAD_SIZE+ADD_SIZE if the field ADD_SIZE is present - when
(HEAD_FLAGS & 0x8000) != 0.

   In each block the followings bits in HEAD_FLAGS have the same meaning:

  0x4000 - if set, older RAR versions will ignore the block
           and remove it when the archive is updated.
           if clear, the block is copied to the new archive
           file when the archive is updated;

  0x8000 - if set, ADD_SIZE field is present and the full block
           size is HEAD_SIZE+ADD_SIZE.

  Declared block types:

HEAD_TYPE=0x72          marker block
HEAD_TYPE=0x73          archive header
HEAD_TYPE=0x74          file header
HEAD_TYPE=0x75          comment header
HEAD_TYPE=0x76          extra information

   Comment block is actually used only within other blocks and does not
exist separately.

   Archive processing is made in the following manner:

1. Read and check marker block
2. Read archive header
3. Read or skip HEAD_SIZE-sizeof(MAIN_HEAD) bytes
4. If end of archive encountered then terminate archive processing,
   else read 7 bytes into fields HEAD_CRC, HEAD_TYPE, HEAD_FLAGS,
   HEAD_SIZE.
5. Check HEAD_TYPE.
   In case block read needed:
         if HEAD_TYPE==0x74
           read file header ( first 7 bytes already read )
           read or skip HEAD_SIZE-sizeof(FILE_HEAD) bytes
           read or skip FILE_SIZE bytes
         else
           read corresponding HEAD_TYPE block:
             read HEAD_SIZE-7 bytes
             if (HEAD_FLAGS & 0x8000)
               read ADD_SIZE bytes
   In case block skip needed:
         skip HEAD_SIZE-7 bytes
         if (HEAD_FLAGS & 0x8000)
           skip ADD_SIZE bytes
6. go to 4.


 ╔════════════════════════════════════════════════════════════════════════╗
 ║▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  Block Formats  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒║
 ╚════════════════════════════════════════════════════════════════════════╝


   Marker block ( MARK_HEAD )


HEAD_CRC        Always 0x6152
2 bytes

HEAD_TYPE       Header type: 0x72
1 byte

HEAD_FLAGS      Always 0x1a21
2 bytes

HEAD_SIZE       Block size = 0x0007
2 bytes

   The marker block is actually considered as a fixed byte
sequence: 0x52 0x61 0x72 0x21 0x1a 0x07 0x00



   Archive header ( MAIN_HEAD )


HEAD_CRC        CRC of fields HEAD_TYPE to RESERVED2
2 bytes

HEAD_TYPE       Header type: 0x73
1 byte

HEAD_FLAGS      Bit flags:
2 bytes
                0x01    - Volume attribute (archive volume)
                0x02    - Archive comment present
                0x04    - Archive lock attribute
                0x08    - Solid attribute (solid archive)
                0x10    - Unused
                0x20    - Authenticity information present

                other bits in HEAD_FLAGS are reserved for
                internal use

HEAD_SIZE       Archive header total size including archive
2 bytes         comments and other added fields

RESERVED1       Reserved
2 bytes

RESERVED2       Reserved
4 bytes


Comment block   present if (HEAD_FLAGS & 0x02) != 0


????            Other included blocks - reserved for
                future use



   File header (File in archive)


HEAD_CRC        CRC of fields from HEAD_TYPE to FILEATTR
2 bytes         and file name

HEAD_TYPE       Header type: 0x74
1 byte

HEAD_FLAGS      Bit flags:
2 bytes
                0x01 - file continued from previous volume
                0x02 - file continued in next volume
                0x04 - file encrypted with password
                0x08 - file comment present

                (HEAD_FLAGS & 0x8000) == 1, because full
                block size is HEAD_SIZE + PACK_SIZE

HEAD_SIZE       File header full size including file name,
2 bytes         comments and other added fields

PACK_SIZE       Compressed file size
4 bytes

UNP_SIZE        Uncompressed file size
4 bytes

HOST_OS         Operating system used for archiving
1 byte          (value 0 stands for MS DOS)

FILE_CRC        File CRC
4 bytes

FTIME           Date and time in standard MS DOS format
4 bytes

UNP_VER         RAR version needed to extract file
1 byte

METHOD          Packing method
1 byte

NAME_SIZE       File name size
2 bytes

ATTR            File attributes
4 bytes

FILE_NAME       File name - string of NAME_LEN bytes size


Comment block   present if (HEAD_FLAGS & 0x08) != 0


????            Other extra included blocks - reserved for
                future use



  Comment block


HEAD_CRC        CRC of fields from HEAD_TYPE to COMM_CRC
2 bytes

HEAD_TYPE       Header type: 0x75
1 byte

HEAD_FLAGS      Bit flags
2 bytes

HEAD_SIZE       Comment header size + comment size
2 bytes

UNP_SIZE        Uncompressed comment size
2 bytes

UNP_VER         RAR version needed to extract comment
1 byte

METHOD          Packing method
1 byte

COMM_CRC        Comment CRC
2 bytes

COMMENT         Comment text



  Extra info block


HEAD_CRC        Block CRC
2 bytes

HEAD_TYPE       Header type: 0x76
1 byte

HEAD_FLAGS      Bit flags
2 bytes

HEAD_SIZE       Total block size
2 bytes

INFO            Other data


 ╔════════════════════════════════════════════════════════════════════════╗
 ║▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  Application notes  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒║
 ╚════════════════════════════════════════════════════════════════════════╝


   1. Should fields and included blocks be added in the future, their
size would be included in HEAD_SIZE.

   2. To process SFX archive you need to skip the SFX module searching
marker block in the archive. There is no marker block sequence (0x52 0x61
0x72 0x21 0x1a 0x07 0x00) in the SFX module itself.

   3. The CRC is calculated using the standard polynomial 0xEDB88320. In
case the size of the CRC is less than 4 bytes, only the low order bytes
are used.

   4. Packing method encoding:
         0x30 - storing
         0x31 - fastest compression
         0x32 - fast compression
         0x33 - normal compression
         0x34 - good compression
         0x35 - best compression

   5. The RAR extraction version number is encoded as 10 * Major version
+ minor version.
}

