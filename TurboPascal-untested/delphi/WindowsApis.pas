(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0276.PAS
  Description: Re: Windows APIs
  Author: KEITH ANDERSON
  Date: 05-30-97  18:17
*)


> GetDiskFreeSpace(lpszRootPathName,
>                        lpSectorsPerCluster,
>                        lpBytesPerSector,
>                        lpFreeClusters,
>                        lpClusters);

The help file for this is:

BOOL GetDiskFreeSpace(

    LPCTSTR  lpRootPathName,    // address of root path
    LPDWORD  lpSectorsPerCluster,       // address of sectors per cluster
    LPDWORD  lpBytesPerSector,  // address of bytes per sector
    LPDWORD  lpNumberOfFreeClusters,    // address of number of free clusters
    LPDWORD  lpTotalNumberOfClusters    // address of total number of clusters
   );

Therefore, define the following variables:

Var Path:String;
      Sectors,Bytes,free,total:DWORD;
      FreeK,TotalK :Integer;

Assign the root directory of some drive to PATH.  For example,
if you want to get the information for drive C:, then
  PATH:='C:\';
if you want to get the information for volume SysVol on
server MainServer, then
  PATH:='\\MainServer\SysVol\';

The code to retrieve the total Kilobytes and free Kilobytes of the
drive goes as follows:

if getdiskfreespace(pchar(Path),sects,bytes,free,total) then
begin
   totalK:=trunc(((sects*bytes)/1024)*total);
   freeK:=trunc(((sects*bytes)/1024)*free);
end else
begin
  // error-- no access, drive doesn't provide this info, or drive doesn't exist
  totalK:=0;
  freeK:=0;
end;

Use the same methodology to use the other similar API functions.
I hope that helped.

