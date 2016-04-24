(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0028.PAS
  Description: dBase II File Structure
  Author: DAVID JURGENS
  Date: 08-27-93  20:35
*)

 HelpPC 2.0        PC Programmers Reference
 Copyright (c) 1990 David Jurgens

               dBASE - File Header Structure (dBASE II)

 Offset Size          Description

   00   byte    dBASE version number 02h=dBASE II
   01   word    number of data records in file
   03   byte    month of last update
   04   byte    day of last update
   05   byte    year of last update
   06   word    size of each data record
   08 512bytes  field descriptors  (see below)
  520   byte    0Dh if all 32 field descriptors used; otherwise 00h

 - dBASE II file header has a fixed size of 521 bytes


              DBASE - File header structure (DBASE III)

 Offset Size           Description

   00   byte      dBASE vers num 03h=dBASE III w/o .DBT
                  83h=dBASE III w .DBT
   01   byte      year of last update
   02   byte      month of last update
   03   byte      day of last update
   04   dword     long int number of data records in file
   08   word      header structure length
   10   word      data record length
   12 20bytes     version 1.0 reserved data space
 32-n 32bytes ea. field descriptors  (see below)
  n+1   byte      0dH field terminator.


 - unlike dBASE II, dBASE III has a variable length header


                      dBASE - Field Descriptors

 dBASE II Field Descriptors (header contains 32 FDs)

 Offset Size              Description

   00  11bytes    null terminated field name string, 0Dh as first
                  byte indicates end of FDs
   11   byte      data type, Char/Num/Logical (C,N,L)
   12   byte      field length
   13   word      field data address, (set in memory)
   15   byte      number of decimal places


 dBASE III Field Descriptors (FD count varies):

 Offset Size           Description

   00  11bytes   null terminated field name string
   11   byte     data type, Char/Num/Logical/Date/Memo
   12   dword    long int field data address, (set in memory)
   16   byte     field length
   17   byte     number of decimal places
   18  14bytes   version 1.00 reserved data area


