%let pgm=utl-altair-slc-language8-powershell-read-write-text-files-summarize-and-looping-with-sqlite;

%stop_submission;

Altair slc language8 powershell read write text files summarize and looping with sqlite

Too long to post on a list, see github
https://github.com/rogerjdeangelis/utl-altair-slc-language8-powershell-read-write-text-files-summarize-and-looping-with-sqlite

CONTENTS

  1 regression using sqlite table
  2 summarize slite table
    select group_concat(name), sex, mean(age), mean(height) from have group by sex
  3 write and read text files in sqlite
  4 sqlite looping
    find the median of numbers 1-10 (5.5)
  5 sqlite tables back to slc

Note: I was unable to use the powershell module PSSQLite, which can simplify sqlite processing,
      because  I was unable to add windows extensions.
      I don't think PSSQlite supports sqlite windows extensions?

SOAPBOX ON
 I am not a fan of microsoft powershell and .NET because, whos to say, that
 microsoft will turn you perfectly working workstation into a brick(no security updates) and
 make you install a terrible win 11 operating system, and under certian conditions
 make you pay for it.
 Who knows what ms will do in the future?
SOAPBOX OFF

Note: Most of the sqlite queries below can NOT be done in 'proc sql' in sas or the slc
      Note sqlite has csv read and write commands, however I want to present general txt processing in sql.
      Keep in mind that I am demonstrating that the exact sqlite queries work in the 8 languages below.
      In addition you can use the exact same queries in any language or operating system that supports odbc.

OBJECTIVE
========

  I am trying to make sql programmers expert programmers in
  8 languages using exactly the same sql queries.
  Use packages and procedures for analysis and sql for data wrangling and interfacing.

  Add very powerfull sql processing to the open source spss
  Posgresql has windows extensions.

  I hope to add repos with  drop downs to sql with windows extensions in many languages

 *language 1   open source spss
 *language 2   open source matlab
 *language 3   r
 *language 4   python
 *language 5   altair odbc sqlite
 *language 6   excel
 *language 7   perl
 *language 8   powershell

RELATED REPOS (SEE FOR INFORMATION OF INSTALLING ODBC AND SQLITE
================================================================

https://github.com/rogerjdeangelis/utl-altair-slc-sqlite-cheat-sheet
https://github.com/rogerjdeangelis/utl-altair-slc-language1-drop-down-to-open-source-spss-and-execute-postgresql-query
https://github.com/rogerjdeangelis/utl-altair-slc-language2-drop-down-to-open-source-matlab-and-execute-sqlite-with-extensions
https://github.com/rogerjdeangelis/utl-altair-slc-language3-proc-r-read-write-csv-files-and-summarize-and-looping-with-sqlite
https://github.com/rogerjdeangelis/utl-altair-slc-language4-proc-python-read-write-csv-files-and-summarize-and-looping-with-sqlite
https://github.com/rogerjdeangelis/utl-altair-slc-native-language5-odbc-read-write-text-files-summarize-and-looping-with-sqlite
https://github.com/rogerjdeangelis/utl-altair-slc-language6-rexcel-read-write-text-files-summarize-and-looping-with-sqlite
https://github.com/rogerjdeangelis/utl-altair-slc-language7-perl-read-write-text-files-summarize-and-looping-with-sqlite
https://github.com/rogerjdeangelis/utl-altair-slc-language8-powershell-read-write-text-files-summarize-and-looping-with-sqlite


PREPARATION
===========

HOW TO INSTALL POWESHELL MODULES

Install ,NET
https://dotnet.microsoft.com/download

dotnet nuget add source "https://api.nuget.org/v3/index.json" --name nuget.org
dotnet nuget locals all --clear
cd C:\temp\mathnet-install\TempProject
dir *.csproj
dotnet add package MathNet.Numerics --version 5.0.0
Get-ChildItem -Path "$env:USERPROFILE\.nuget\packages\mathnet.numerics" -Recurse -Filter "MathNet.Numerics.dll" | Select-Object FullName
C:\Users\suzie\.nuget\packages\mathnet.numerics\5.0.0\lib\net472\MathNet.Numerics.dll
if ($dllPath) {
    Copy-Item $dllPath -Destination "C:\temp\MathNet.Numerics.dll"
    Write-Host "DLL copied to C:\temp\MathNet.Numerics.dll" -ForegroundColor Green
} else {
    Write-Host "DLL not found. Please check if the package installed correctly." -ForegroundColor Red
}

FIANL RESPONSE
DLL copied to C:\temp\MathNet.Numerics.dll

Install-Module -Name PSSQLite -Force

CHECK CONNECTION FOR POWERSHELL
===============================

%slc_psbegin;
cards4;
# Define connection string with extension
$connectionString = "DRIVER=SQLite3 ODBC Driver;database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;"

# Create and open connection
$conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
$conn.Open()
# Run a query
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT "select age, height from have";"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
         Write-Host $reader.GetString(0)
      }
$reader.Close()
$conn.Close()
;;;;
%slc_psend;


SAVE DROP DOWN MACROS IN YOUR AUTOCALL FOLDER. I USE C:/WPSOTO. EDIT FOR YOUR FOLDER
====================================================================================

data _null_;
 file "c:/wpsoto/slc_psbegin.sas";
 input;
 put _infile_;
cards4;
%macro slc_psbegin;
%utlfkil(c:/temp/ps_pgm.ps1);
%utlfkil(c:/temp/ps_pgm.log);
data _null_;
  file "c:/temp/ps_pgm.ps1";
  input;
  put _infile_;
%mend slc_psbegin;
;;;;
run;

data _null_;
 file "c:/wpsoto/slc_psend.sas";
 input;
 put _infile_;
cards4;
%macro slc_psend(returnvar=N);
options noxwait noxsync;
filename rut pipe  "powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log";
run;quit;
  data _null_;
    file print;
    infile rut recfm=v lrecl=32756;
    input;
    put _infile_;
    putlog _infile_;
  run;
  * use the clipboard to create macro variable;
  %if %upcase(%substr(&returnVar.,1,1)) ne N %then %do;
    filename clp clipbrd ;
    data _null_;
     length txt $200;
     infile clp;
     input;
     putlog "macro variable &returnVar = " _infile_;
     call symputx("&returnVar.",_infile_,"G");
    run;quit;
  %end;
data _null_;
  file print;
  infile rut;
  input;
  put _infile_;
  putlog _infile_;
run;quit;
data _null_;
  infile "c:/temp/ps_pgm.log";
  input;
  putlog _infile_;
  file print;
  put _infile_;
run;quit;
%mend slc_psend;
;;;;
run;


/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

* best first;
%utlfkil(d:/sqlite/mysqlite.db);

libname workx sas7bdat "d:/wpswrkx"; /*---  put in autoexec ---*/

proc datasets lib=workx kill;
run;

libname sqlite odbc noprompt="driver=sqlite3 odbc driver; database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;";

proc datasets lib=sqlite;
 delete have;
run;

options validvarname=v7;
data sqlite.have ;
  informat
    line    $24.
    name    $8.
    sex     $1.
    age     8.
    height  8.
    ;
 input name sex age height line &;
cards4;
Alfred M 14 69 This is the 1st line
Alice F 13 56.5 This is the 2nd line
Barbara F 13 65.3 This is the 3rd line
Carol F 14 62.8 This is the 4th line
Henry M 14 63.5 This is the 5th line
;;;;
run;quit;

/*---  THE PROCS BELOW ARE ACCESSING THE SQLITE DATABASE TABLE HAVE ---*/
proc contents data=sqlite.have;
run;

proc print data=sqlite.have;
run;

proc sql;
 SELECT sql FROM sqlite.sqlite_master WHERE name='have'
;quit;

libname sqlite clear;


/**************************************************************************************************************************/
/*  SQLITE TABLE                                                                                                          */
/*                                                                                                                        */
/* Obs    line                        name        sex    age    height                                                    */
/*                                                                                                                        */
/*  1     This is the 1st line        Alfred       M      14     69.0                                                     */
/*  2     This is the 2nd line        Alice        F      13     56.5                                                     */
/*  3     This is the 3rd line        Barbara      F      13     65.3                                                     */
/*  4     This is the 4th line        Carol        F      14     62.8                                                     */
/*  5     This is the 5th line        Henry        M      14     63.5                                                     */
/*                                                                                                                        */
/*                                                                                                                        */
/* The CONTENTS OF SQLITE TABLE                                                                                           */
/*                                                                                                                        */
/* Data Set Name           HAVE                                                                                           */
/* Member Type             VIEW                                                                                           */
/* Engine                                                                                                                 */
/* Observations                .                                                                                          */
/* Variables               5                                                                                              */
/* Indexes                 0                                                                                              */
/* Observation Length      49                                                                                             */
/* Deleted Observations             0                                                                                     */
/* Data Set Type                                                                                                          */
/* Label                                                                                                                  */
/* Compressed              NO                                                                                             */
/* Sorted                  NO                                                                                             */
/* Data Representation                                                                                                    */
/* Encoding                wlatin1 Windows-1252 Western                                                                   */
/*                                                                                                                        */
/*                           Alphabetic List of Variables and Attributes                                                  */
/*                                                                                                                        */
/*       Number    Variable    Type             Len             Pos    Format          Informat                           */
/* ________________________________________________________________________________________________                       */
/*            4    age         Num                8              33                                                       */
/*            5    height      Num                8              41                                                       */
/*            1    line        Char              24               0    $24.            $24.                               */
/*            2    name        Char               8              24    $8.             $8.                                */
/*            3    sex         Char               1              32    $1.             $1.                                */
/*                                                                                                                        */
/*                                                                                                                        */
/* FROM SQLITE DICTINARY                                                                                                  */
/*                                                                                                                        */
/* sql                                                                                                                    */
/* ---------------------------------------------------------------------------------------------------------------------  */
/* CREATE TABLE have(line VARCHAR(24), name VARCHAR(8), sex VARCHAR(1), age DOUBLE PRECISION, height DOUBLE PRECISION )   */
/**************************************************************************************************************************/


/*                   _     _
(_)_ __  _ __  _   _| |_  | | ___   __ _
| | `_ \| `_ \| | | | __| | |/ _ \ / _` |
| | | | | |_) | |_| | |_  | | (_) | (_| |
|_|_| |_| .__/ \__,_|\__| |_|\___/ \__, |
        |_|                        |___/
*/

1                                          Altair SLC        13:24 Saturday, March 21, 2026

NOTE: Copyright 2002-2025 World Programming, an Altair Company
NOTE: Altair SLC 2026 (05.26.01.00.000758)
      Licensed to Roger DeAngelis
NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
NOTE: AUTOEXEC source line
1       +  ï»¿ods _all_ close;
           ^



NOTE: AUTOEXEC processing completed

1         * best first;
2         %utlfkil(d:/sqlite/mysqlite.db);
3
4         libname workx sas7bdat "d:/wpswrkx"; /*---  put in autoexec ---*/
NOTE: Library workx assigned as follows:
      Engine:        SAS7BDAT
      Physical Name: d:\wpswrkx


Altair SLC

The DATASETS Procedure

         Directory

Libref           WORKX
Engine           SAS7BDAT
Physical Name    d:\wpswrkx

                              Members

            Member    Member
  Number    Name      Type         File Size      Date Last Modified

--------------------------------------------------------------------

       1    AVGS      DATA             17408      21MAR2026:13:11:17
5
6         proc datasets lib=workx kill;
7         run;
NOTE: Deleting WORKX.avgs (type=DATA)
8
9         libname sqlite odbc noprompt=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;
NOTE: Library sqlite assigned as follows:
      Engine:        ODBC
      Physical Name:  (SQLite version 3.43.2)

NOTE: Procedure datasets step took :
      real time : 0.191
      cpu time  : 0.093



Altair SLC

The DATASETS Procedure

      Directory

Libref         SQLITE
Engine         ODBC
Data Source
10
11        proc datasets lib=sqlite;
NOTE: No matching members in directory
12         delete have;
13        run;
NOTE: SQLITE.HAVE (memtype="DATA") was not found, and has not been deleted
14
15        options validvarname=v7;
NOTE: Procedure datasets step took :
      real time : 0.031
      cpu time  : 0.000


16        data sqlite.have ;
17          informat
18            line    $24.
19            name    $8.
20            sex     $1.
21            age     8.
22            height  8.
23            ;
24         input name sex age height line &;
25        cards4;

NOTE: Data set "SQLITE.have" has an unknown number of observation(s) and 5 variable(s)
NOTE: The data step took :
      real time : 0.142
      cpu time  : 0.015


26        Alfred M 14 69 This is the 1st line
27        Alice F 13 56.5 This is the 2nd line
28        Barbara F 13 65.3 This is the 3rd line
29        Carol F 14 62.8 This is the 4th line
30        Henry M 14 63.5 This is the 5th line
31        ;;;;
32        run;quit;
33
34        proc contents data=sqlite.have;
35        run;
NOTE: Procedure contents step took :
      real time : 0.055
      cpu time  : 0.015


36
37        proc print data=sqlite.have;
38        run;
NOTE: 5 observations were read from "SQLITE.have"
NOTE: Procedure print step took :
      real time : 0.005
      cpu time  : 0.031


39
40        proc sql;
41         SELECT sql FROM sqlite.sqlite_master WHERE name='have'
42        ;quit;
WARNING: truncating character column type to 1024 characters long, based on dbmax_text setting.
WARNING: truncating character column name to 1024 characters long, based on dbmax_text setting.
WARNING: truncating character column tbl_name to 1024 characters long, based on dbmax_text setting.
WARNING: truncating character column sql to 1024 characters long, based on dbmax_text setting.
WARNING: truncating character column sql to 1024 characters long, based on dbmax_text setting.
NOTE: Procedure sql step took :
      real time : 0.031
      cpu time  : 0.000


NOTE: Libref SQLITE has been deassigned.
43
44        libname sqlite clear;
ERROR: Error printed on page 1

NOTE: Submitted statements took :
      real time : 0.729
      cpu time  : 0.250



/*                                   _                                     _  _        _     _
/ | _ __ ___  __ _ _ __ ___  ___ ___(_) ___  _ __    ___  _ __   ___  __ _| || |_ __ _| |__ | | ___
| || `__/ _ \/ _` | `__/ _ \/ __/ __| |/ _ \| `_ \  / _ \| `_ \ / __|/ _` | || __/ _` | `_ \| |/ _ \
| || | |  __/ (_| | | |  __/\__ \__ \ | (_) | | | || (_) | | | |\__ \ (_| | || || (_| | |_) | |  __/
|_||_|  \___|\__, |_|  \___||___/___/_|\___/|_| |_| \___/|_| |_||___/\__, |_| \__\__,_|_.__/|_|\___|
             |___/                                                      |_|
*/

%utlopts;
%slc_psbegin;
cards4;
# Load MathNet.Numerics DLL
$mathNetPath = "C:\temp\MathNet.Numerics.dll"

Add-Type -Path $mathNetPath
Write-Host "MathNet.Numerics loaded successfully" -ForegroundColor Green

# Connection string
$connectionString = "DRIVER=SQLite3 ODBC Driver;database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;"

# Connect to database
Write-Host "`nConnecting to SQLite database..." -ForegroundColor Cyan
$conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
$conn.Open()

# Query data
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT age, height FROM have"
$reader = $cmd.ExecuteReader()

# Load data into strongly-typed arrays
$age = New-Object System.Collections.Generic.List[double]
$height = New-Object System.Collections.Generic.List[double]

while ($reader.Read()) {
    $age.Add($reader.GetDouble(0))
    $height.Add($reader.GetDouble(1))
}

$reader.Close()
$conn.Close()

Write-Host "Loaded $($age.Count) records" -ForegroundColor Green

# Display the data for verification
Write-Host "`nData:" -ForegroundColor Cyan
for ($i = 0; $i -lt $age.Count; $i++) {
    Write-Host "Age: $($age[$i]), Height: $($height[$i])"
}

# Convert to arrays for MathNet
$ageArray = $age.ToArray()
$heightArray = $height.ToArray()

# Calculate linear regression
$fit = [MathNet.Numerics.Fit]::Line($ageArray, $heightArray)
$intercept = $fit.Item1
$slope = $fit.Item2

# Calculate predicted values as double array
$predicted = New-Object double[] $ageArray.Length
for ($i = 0; $i -lt $ageArray.Length; $i++) {
    $predicted[$i] = $intercept + $slope * $ageArray[$i]
}

# Calculate R-squared using double arrays
$rSquared = [MathNet.Numerics.GoodnessOfFit]::RSquared($heightArray, $predicted)

# Display results
Write-Host "`nPREDICTING HEIGHT FROM AGE" -ForegroundColor Yellow
Write-Host "============================"
Write-Host ("Intercept: {0:F4}" -f $intercept)
Write-Host ("Slope:     {0:F4}" -f $slope)
Write-Host ("R-squared: {0:F4}" -f $rSquared)
Write-Host ""
Write-Host ("Regression equation: height = {0:F4} + {1:F4} * age" -f $intercept, $slope)

# Show predictions for all records
Write-Host "`nDetailed predictions:" -ForegroundColor Yellow
Write-Host ("{0,-10} {1,-15} {2,-15} {3,-15}" -f "Age", "Actual Height", "Predicted", "Difference")
Write-Host ("{0,-10} {1,-15} {2,-15} {3,-15}" -f "---", "-------------", "---------", "----------")

for ($i = 0; $i -lt $ageArray.Length; $i++) {
    $pred = $intercept + $slope * $ageArray[$i]
    $diff = $heightArray[$i] - $pred
    Write-Host ("{0,-10:F2} {1,-15:F2} {2,-15:F2} {3,-15:F2}" -f $ageArray[$i], $heightArray[$i], $pred, $diff)
}
;;;;
%slc_psend;

/**************************************************************************************************************************/
/* Altair SLC                                                                                                             */
/* MathNet.Numerics loaded successfully                                                                                   */
/*                                                                                                                        */
/* Connecting to SQLite database...                                                                                       */
/* Loaded 5 records                                                                                                       */
/*                                                                                                                        */
/* Data:                                                                                                                  */
/* Age: 14, Height: 69                                                                                                    */
/* Age: 13, Height: 56.5                                                                                                  */
/* Age: 13, Height: 65.3                                                                                                  */
/* Age: 14, Height: 62.8                                                                                                  */
/* Age: 14, Height: 63.5                                                                                                  */
/*                                                                                                                        */
/* PREDICTING HEIGHT FROM AGE                                                                                             */
/* ============================                                                                                           */
/* Intercept: 6.3000                                                                                                      */
/* Slope:     4.2000                                                                                                      */
/* R-squared: 0.2552                                                                                                      */
/*                                                                                                                        */
/* Regression equation: height = 6.3000 + 4.2000 * age                                                                    */
/*                                                                                                                        */
/* Detailed predictions:                                                                                                  */
/* Age        Actual Height   Predicted       Difference                                                                  */
/* ---        -------------   ---------       ----------                                                                  */
/* 14.00      69.00           65.10           3.90                                                                        */
/* 13.00      56.50           60.90           -4.40                                                                       */
/* 13.00      65.30           60.90           4.40                                                                        */
/* 14.00      62.80           65.10           -2.30                                                                       */
/* 14.00      63.50           65.10           -1.60                                                                       */
/**************************************************************************************************************************/

/*                                _               _
 _ __ ___  __ _ _ __ ___  ___ ___(_) ___  _ __   | | ___   __ _
| `__/ _ \/ _` | `__/ _ \/ __/ __| |/ _ \| `_ \  | |/ _ \ / _` |
| | |  __/ (_| | | |  __/\__ \__ \ | (_) | | | | | | (_) | (_| |
|_|  \___|\__, |_|  \___||___/___/_|\___/|_| |_| |_|\___/ \__, |
          |___/                                           |___/
*/

1                                          Altair SLC          10:08 Sunday, March 22, 2026

NOTE: Copyright 2002-2025 World Programming, an Altair Company
NOTE: Altair SLC 2026 (05.26.01.00.000758)
      Licensed to Roger DeAngelis
NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
NOTE: AUTOEXEC source line
1       +  ï»¿ods _all_ close;
           ^

NOTE: AUTOEXEC processing completed

1         %utlopts;
MPRINT(UTLOPTS):  MERROR NOCENTER DETAILS SERROR NONUMBER FULLSTIMER NODATE DKRICOND=WARN DKROCOND=WARN NOSYNTAXCHECK ;
MPRINT(UTLOPTS):  run;
MPRINT(UTLOPTS):  quit;
MLOGIC(UTLOPTS): Ending execution
2         %slc_psbegin;
MLOGIC(SLC_PSBEGIN): Beginning execution
MLOGIC(SLC_PSBEGIN): This macro was compiled from the autocall file c:\wpsoto\slc_psbegin.sas
MLOGIC(UTLFKIL): Beginning execution
MLOGIC(UTLFKIL): This macro was compiled from the autocall file c:\wpsoto\utlfkil.sas
MLOGIC(UTLFKIL): Parameter FILE has value c:/temp/ps_pgm.ps1
SYMBOLGEN: Macro variable file resolved to c:/temp/ps_pgm.ps1
MLOGIC(UTLFKIL): %IF condition %sysfunc(fileexist(&file)) ge 1  evaluated to TRUE
MLOGIC(UTLFKIL): %LET (variable name is rc)
SYMBOLGEN: Macro variable file resolved to c:/temp/ps_pgm.ps1
MLOGIC(UTLFKIL): %LET (variable name is rc)
SYMBOLGEN: Macro variable temp resolved to #LN00001
MLOGIC(UTLFKIL): Ending execution
MPRINT(SLC_PSBEGIN):  ;
MLOGIC(UTLFKIL): Beginning execution
MLOGIC(UTLFKIL): This macro was compiled from the autocall file c:\wpsoto\utlfkil.sas
MLOGIC(UTLFKIL): Parameter FILE has value c:/temp/ps_pgm.log
SYMBOLGEN: Macro variable file resolved to c:/temp/ps_pgm.log
MLOGIC(UTLFKIL): %IF condition %sysfunc(fileexist(&file)) ge 1  evaluated to TRUE
MLOGIC(UTLFKIL): %LET (variable name is rc)
SYMBOLGEN: Macro variable file resolved to c:/temp/ps_pgm.log
MLOGIC(UTLFKIL): %LET (variable name is rc)
SYMBOLGEN: Macro variable temp resolved to #LN00002
MLOGIC(UTLFKIL): Ending execution
MPRINT(SLC_PSBEGIN):  ;
MPRINT(SLC_PSBEGIN):  data _null_;
MPRINT(SLC_PSBEGIN):  file "c:/temp/ps_pgm.ps1";
MPRINT(SLC_PSBEGIN):  input;
MPRINT(SLC_PSBEGIN):  put _infile_;
MLOGIC(SLC_PSBEGIN): Ending execution
3         cards4;

NOTE: The file 'c:\temp\ps_pgm.ps1' is:
      Filename='c:\temp\ps_pgm.ps1',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=14:40:04 Mar 21 2026,
      Last Accessed=10:08:20 Mar 22 2026,
      Last Modified=10:08:20 Mar 22 2026,
      Lrecl=384, Recfm=V

NOTE: 77 records were written to file 'c:\temp\ps_pgm.ps1'
      The minimum record length was 80
      The maximum record length was 111
NOTE: The data step took :
      real time       : 0.000
      user cpu time   : 0.015
      system cpu time : 0.000
      Timestamp       :   22MAR26:10:08:21
      Peak working set    : 28048k
      Current working set : 28020k
      Page fault count    : 87


4         # Load MathNet.Numerics DLL
5         $mathNetPath = "C:\temp\MathNet.Numerics.dll"
6
7         Add-Type -Path $mathNetPath
8         Write-Host "MathNet.Numerics loaded successfully" -ForegroundColor Green
9
10        # Connection string
11        $connectionString = "DRIVER=SQLite3 ODBC Driver;database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;"
12
13        # Connect to database
14        Write-Host "`nConnecting to SQLite database..." -ForegroundColor Cyan
15        $conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
16        $conn.Open()
17
18        # Query data
19        $cmd = $conn.CreateCommand()
20        $cmd.CommandText = "SELECT age, height FROM have"
21        $reader = $cmd.ExecuteReader()
22
23        # Load data into strongly-typed arrays
24        $age = New-Object System.Collections.Generic.List[double]
25        $height = New-Object System.Collections.Generic.List[double]
26
27        while ($reader.Read()) {
28            $age.Add($reader.GetDouble(0))
29            $height.Add($reader.GetDouble(1))
30        }
31
32        $reader.Close()
33        $conn.Close()
34
35        Write-Host "Loaded $($age.Count) records" -ForegroundColor Green
36
37        # Display the data for verification
38        Write-Host "`nData:" -ForegroundColor Cyan
39        for ($i = 0; $i -lt $age.Count; $i++) {
40            Write-Host "Age: $($age[$i]), Height: $($height[$i])"
41        }
42
43        # Convert to arrays for MathNet
44        $ageArray = $age.ToArray()
45        $heightArray = $height.ToArray()
46
47        # Calculate linear regression
48        $fit = [MathNet.Numerics.Fit]::Line($ageArray, $heightArray)
49        $intercept = $fit.Item1
50        $slope = $fit.Item2
51
52        # Calculate predicted values as double array
53        $predicted = New-Object double[] $ageArray.Length
54        for ($i = 0; $i -lt $ageArray.Length; $i++) {
55            $predicted[$i] = $intercept + $slope * $ageArray[$i]
56        }
57
58        # Calculate R-squared using double arrays
59        $rSquared = [MathNet.Numerics.GoodnessOfFit]::RSquared($heightArray, $predicted)
60
61        # Display results
62        Write-Host "`nPREDICTING HEIGHT FROM AGE" -ForegroundColor Yellow
63        Write-Host "============================"
64        Write-Host ("Intercept: {0:F4}" -f $intercept)
65        Write-Host ("Slope:     {0:F4}" -f $slope)
66        Write-Host ("R-squared: {0:F4}" -f $rSquared)
67        Write-Host ""
68        Write-Host ("Regression equation: height = {0:F4} + {1:F4} * age" -f $intercept, $slope)
69
70        # Show predictions for all records
71        Write-Host "`nDetailed predictions:" -ForegroundColor Yellow
72        Write-Host ("{0,-10} {1,-15} {2,-15} {3,-15}" -f "Age", "Actual Height", "Predicted", "Difference")
73        Write-Host ("{0,-10} {1,-15} {2,-15} {3,-15}" -f "---", "-------------", "---------", "----------")
74
75        for ($i = 0; $i -lt $ageArray.Length; $i++) {
76            $pred = $intercept + $slope * $ageArray[$i]
77            $diff = $heightArray[$i] - $pred
78            Write-Host ("{0,-10:F2} {1,-15:F2} {2,-15:F2} {3,-15:F2}" -f $ageArray[$i], $heightArray[$i], $pred, $diff)
79        }
80
81        ;;;;
82        %slc_psend;
MLOGIC(SLC_PSEND): Beginning execution
MLOGIC(SLC_PSEND): This macro was compiled from the autocall file c:\wpsoto\slc_psend.sas
MLOGIC(SLC_PSEND): Parameter RETURNVAR has value N
MPRINT(SLC_PSEND):  options noxwait noxsync;
MPRINT(SLC_PSEND):  filename rut pipe "powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log";
MPRINT(SLC_PSEND):  run;
MPRINT(SLC_PSEND):  quit;
MPRINT(SLC_PSEND):  data _null_;
MPRINT(SLC_PSEND):  file print;
MPRINT(SLC_PSEND):  infile rut recfm=v lrecl=32756;
MPRINT(SLC_PSEND):  input;
MPRINT(SLC_PSEND):  put _infile_;
MPRINT(SLC_PSEND):  putlog _infile_;
MPRINT(SLC_PSEND):  run;

NOTE: The infile rut is:
      Unnamed Pipe Access Device,
      Process=powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log,
      Lrecl=32756, Recfm=V

NOTE: No records were written to file PRINT

NOTE: No records were read from file rut
NOTE: The data step took :
      real time       : 0.756
      user cpu time   : 0.000
      system cpu time : 0.000
      Timestamp       :   22MAR26:10:08:21
      Peak working set    : 28328k
      Current working set : 28296k
      Page fault count    : 59


MPRINT(SLC_PSEND):  * use the clipboard to create macro variable;
SYMBOLGEN: Macro variable returnVar resolved to N
MLOGIC(SLC_PSEND): %IF condition %upcase(%substr(&returnVar.,1,1)) ne N  evaluated to FALSE
MPRINT(SLC_PSEND):  data _null_;
MPRINT(SLC_PSEND):  file print;
MPRINT(SLC_PSEND):  infile rut;
MPRINT(SLC_PSEND):  input;
MPRINT(SLC_PSEND):  put _infile_;
MPRINT(SLC_PSEND):  putlog _infile_;
MPRINT(SLC_PSEND):  run;

NOTE: The infile rut is:
      Unnamed Pipe Access Device,
      Process=powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log,
      Lrecl=384, Recfm=V

NOTE: No records were written to file PRINT

NOTE: No records were read from file rut
NOTE: The data step took :
      real time       : 0.638
      user cpu time   : 0.000
      system cpu time : 0.000
      Timestamp       :   22MAR26:10:08:22
      Peak working set    : 28420k
      Current working set : 28388k
      Page fault count    : 31


MPRINT(SLC_PSEND):  quit;
MPRINT(SLC_PSEND):  data _null_;
MPRINT(SLC_PSEND):  infile "c:/temp/ps_pgm.log";
MPRINT(SLC_PSEND):  input;
MPRINT(SLC_PSEND):  putlog _infile_;
MPRINT(SLC_PSEND):  file print;
MPRINT(SLC_PSEND):  put _infile_;
MPRINT(SLC_PSEND):  run;

NOTE: The infile 'c:\temp\ps_pgm.log' is:
      Filename='c:\temp\ps_pgm.log',
      Owner Name=SLC\suzie,
      File size (bytes)=803,
      Create Time=14:40:04 Mar 21 2026,
      Last Accessed=10:08:22 Mar 22 2026,
      Last Modified=10:08:22 Mar 22 2026,
      Lrecl=384, Recfm=V

MathNet.Numerics loaded successfully

Connecting to SQLite database...
Loaded 5 records

Data:
Age: 14, Height: 69
Age: 13, Height: 56.5
Age: 13, Height: 65.3
Age: 14, Height: 62.8
Age: 14, Height: 63.5

PREDICTING HEIGHT FROM AGE
============================
Intercept: 6.3000
Slope:     4.2000
R-squared: 0.2552

Regression equation: height = 6.3000 + 4.2000 * age

Detailed predictions:
Age        Actual Height   Predicted       Difference
---        -------------   ---------       ----------
14.00      69.00           65.10           3.90
13.00      56.50           60.90           -4.40
13.00      65.30           60.90           4.40
14.00      62.80           65.10           -2.30
14.00      63.50           65.10           -1.60
NOTE: 28 records were read from file 'c:\temp\ps_pgm.log'
      The minimum record length was 0
      The maximum record length was 58
NOTE: 28 records were written to file PRINT

NOTE: The data step took :
      real time       : 0.018
      user cpu time   : 0.015
      system cpu time : 0.000
      Timestamp       :   22MAR26:10:08:22
      Peak working set    : 28488k
      Current working set : 28372k
      Page fault count    : 31


MPRINT(SLC_PSEND):  quit;
MLOGIC(SLC_PSEND): Ending execution
83
ERROR: Error printed on page 1

NOTE: Submitted statements took :
      real time       : 1.587
      user cpu time   : 0.078
      system cpu time : 0.015
      Timestamp       :   22MAR26:10:08:22
      Peak working set    : 28488k
      Current working set : 28364k
      Page fault count    : 3187



/*___                                             _                     _  _        _     _
|___ \   ___ _   _ _ __ ___  _ __ ___   __ _ _ __(_)_______   ___  __ _| || |_ __ _| |__ | | ___
  __) | / __| | | | `_ ` _ \| `_ ` _ \ / _` | `__| |_  / _ \ / __|/ _` | || __/ _` | `_ \| |/ _ \
 / __/  \__ \ |_| | | | | | | | | | | | (_| | |  | |/ /  __/ \__ \ (_| | || || (_| | |_) | |  __/
|_____| |___/\__,_|_| |_| |_|_| |_| |_|\__,_|_|  |_/___\___| |___/\__, |_| \__\__,_|_.__/|_|\___|
                                                                     |_|
*/

%slc_psbegin;
cards4;
# Load MathNet.Numerics DLL
$mathNetPath = "C:\temp\MathNet.Numerics.dll"

Add-Type -Path $mathNetPath
Write-Host "MathNet.Numerics loaded successfully" -ForegroundColor Green

# Connection string
$connectionString = "DRIVER=SQLite3 ODBC Driver;database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;"

$conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
$conn.Open()

$createCmd = $conn.CreateCommand()
$createCmd.CommandText = "DROP TABLE IF EXISTS avgs"
$createCmd.ExecuteNonQuery()

$createCmd = $conn.CreateCommand()
$createCmd.CommandText = @"
CREATE TABLE avgs AS
SELECT
    group_concat(name) as names,
    sex,
    round(avg(age), 1) as avg_age,
    round(avg(height), 1) as avg_height
FROM have
GROUP BY sex
"@
$rowsAffected = $createCmd.ExecuteNonQuery()

Write-Host "`nDisplaying avgs table contents:" -ForegroundColor Cyan

$query = "SELECT * FROM avgs;"
$cmd = New-Object System.Data.Odbc.OdbcCommand($query, $conn)
$adapter = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)
$dataTable = New-Object System.Data.DataTable
$adapter.Fill($dataTable) | Out-Null

$dataTable | Format-Table -AutoSize

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name FROM sqlite_master WHERE type='table';"
$reader = $cmd.ExecuteReader()

Write-Host "Tables in database:" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green

while ($reader.Read()) {
    Write-Host $reader.GetString(0)
}

$reader.Close()
$conn.Close()
;;;;
%slc_psend;

/**************************************************************************************************************************/
/*  Displaying avgs table contents:                                                                                       */
/*                                                                                                                        */
/* names               sex avg_age avg_height                                                                             */
/* -----               --- ------- ----------                                                                             */
/* Alice,Barbara,Carol F      13.3       61.5                                                                             */
/* Alfred,Henry        M        14       66.3                                                                             */
/*                                                                                                                        */
/*                                                                                                                        */
/* Tables in database:                                                                                                    */
/* ===================                                                                                                    */
/* sqlean_define                                                                                                          */
/* have                                                                                                                   */
/* avgs                                                                                                                   */
/**************************************************************************************************************************/

/*                                        _           _
 ___ _   _ _ __ ___  _ __ ___   __ _ _ __(_)_______  | | ___   __ _
/ __| | | | `_ ` _ \| `_ ` _ \ / _` | `__| |_  / _ \ | |/ _ \ / _` |
\__ \ |_| | | | | | | | | | | | (_| | |  | |/ /  __/ | | (_) | (_| |
|___/\__,_|_| |_| |_|_| |_| |_|\__,_|_|  |_/___\___| |_|\___/ \__, |
                                                              |___/
*/

1                                          Altair SLC          11:34 Sunday, March 22, 2026

NOTE: Copyright 2002-2025 World Programming, an Altair Company
NOTE: Altair SLC 2026 (05.26.01.00.000758)
      Licensed to Roger DeAngelis
NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
NOTE: AUTOEXEC source line
1       +  ï»¿ods _all_ close;
           ^
ERROR: Expected a statement keyword : found "?"

NOTE: AUTOEXEC processing completed

1         %slc_psbegin;
2         cards4;

NOTE: The file 'c:\temp\ps_pgm.ps1' is:
      Filename='c:\temp\ps_pgm.ps1',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=14:40:04 Mar 21 2026,
      Last Accessed=11:34:07 Mar 22 2026,
      Last Modified=11:34:07 Mar 22 2026,
      Lrecl=32767, Recfm=V

NOTE: 52 records were written to file 'c:\temp\ps_pgm.ps1'
      The minimum record length was 80
      The maximum record length was 106
NOTE: The data step took :
      real time : 0.000
      cpu time  : 0.000


3         # Load MathNet.Numerics DLL
4         $mathNetPath = "C:\temp\MathNet.Numerics.dll"
5
6         Add-Type -Path $mathNetPath
7         Write-Host "MathNet.Numerics loaded successfully" -ForegroundColor Green
8
9         # Connection string
10        $connectionString = "DRIVER=SQLite3 ODBC Driver;database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;"
11
12        $conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
13        $conn.Open()
14
15        $createCmd = $conn.CreateCommand()
16        $createCmd.CommandText = "DROP TABLE IF EXISTS avgs"
17        $createCmd.ExecuteNonQuery()
18
19        $createCmd = $conn.CreateCommand()
20        $createCmd.CommandText = @"
21        CREATE TABLE avgs AS
22        SELECT
23            group_concat(name) as names,
24            sex,
25            round(avg(age), 1) as avg_age,
26            round(avg(height), 1) as avg_height
27        FROM have
28        GROUP BY sex
29        "@
30        $rowsAffected = $createCmd.ExecuteNonQuery()
31
32        Write-Host "`nDisplaying avgs table contents:" -ForegroundColor Cyan
33
34        $query = "SELECT * FROM avgs;"
35        $cmd = New-Object System.Data.Odbc.OdbcCommand($query, $conn)
36        $adapter = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)
37        $dataTable = New-Object System.Data.DataTable
38        $adapter.Fill($dataTable) | Out-Null
39
40        $dataTable | Format-Table -AutoSize
41
42        $cmd = $conn.CreateCommand()
43        $cmd.CommandText = "SELECT name FROM sqlite_master WHERE type='table';"
44        $reader = $cmd.ExecuteReader()
45
46        Write-Host "Tables in database:" -ForegroundColor Green
47        Write-Host "===================" -ForegroundColor Green
48
49        while ($reader.Read()) {
50            Write-Host $reader.GetString(0)
51        }
52
53        $reader.Close()
54        $conn.Close()
55        ;;;;
56        %slc_psend;

NOTE: The infile rut is:
      Unnamed Pipe Access Device,
      Process=powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log,
      Lrecl=32756, Recfm=V

NOTE: No records were written to file PRINT

NOTE: No records were read from file rut
NOTE: The data step took :
      real time : 0.745
      cpu time  : 0.000



NOTE: The infile rut is:
      Unnamed Pipe Access Device,
      Process=powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log,
      Lrecl=32767, Recfm=V

NOTE: No records were written to file PRINT

NOTE: No records were read from file rut
NOTE: The data step took :
      real time : 0.853
      cpu time  : 0.015



NOTE: The infile 'c:\temp\ps_pgm.log' is:
      Filename='c:\temp\ps_pgm.log',
      Owner Name=SLC\suzie,
      File size (bytes)=319,
      Create Time=10:30:46 Mar 22 2026,
      Last Accessed=11:34:08 Mar 22 2026,
      Last Modified=11:34:08 Mar 22 2026,
      Lrecl=32767, Recfm=V

MathNet.Numerics loaded successfully
0

Displaying avgs table contents:

names               sex avg_age avg_height
-----               --- ------- ----------
Alice,Barbara,Carol F      13.3       61.5
Alfred,Henry        M        14       66.3


Tables in database:
===================
sqlean_define
have
avgs
NOTE: 16 records were read from file 'c:\temp\ps_pgm.log'
      The minimum record length was 0
      The maximum record length was 42
NOTE: 16 records were written to file PRINT

NOTE: The data step took :
      real time : 0.031
      cpu time  : 0.015


57
58
ERROR: Error printed on page 1

NOTE: Submitted statements took :
      real time : 1.788
      cpu time  : 0.109



/*____            _                      _                 _ _        _            _      __ _ _
|___ /  ___  __ _| |  _ __ ___  __ _  __| | __      ___ __(_) |_ ___ | |_ _____  _| |_   / _(_) | ___  ___
  |_ \ / __|/ _` | | | `__/ _ \/ _` |/ _` | \ \ /\ / / `__| | __/ _ \| __/ _ \ \/ / __| | |_| | |/ _ \/ __|
 ___)  \__ \ (_| | | | | |  __/ (_| | (_| |  \ V  V /| |  | | ||  __/| ||  __/>  <| |_  |  _| | |  __/\__ \
|____/ |___/\__, |_| |_|  \___|\__,_|\__,_|   \_/\_/ |_|  |_|\__\___| \__\___/_/\_\\__| |_| |_|_|\___||___/
               |_|
*/

%utlfkil(d:/txt/class_export.txt);

%slc_psbegin;
cards4;
# Connection string
$connectionString = "DRIVER=SQLite3 ODBC Driver;database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;"

$conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
$conn.Open()

$createCmd = $conn.CreateCommand()
$createCmd.CommandText = "DROP TABLE IF EXISTS avgs"
$createCmd.ExecuteNonQuery()


Write-Host "`nCreate d:/txt/class_export.txt using sqlite writefile"
Write-Host "========================================================" -ForegroundColor Yellow

$createCmd = $conn.CreateCommand()
$createCmd.CommandText = @"
SELECT writefile(
    'd:/txt/class_export.txt',
    (SELECT group_concat(line, char(10)) FROM have)
    )
"@
$rowsAffected = $createCmd.ExecuteNonQuery()


$sql = @"
 SELECT value AS txt
 FROM json_each(
     '["' ||
     replace(
         cast(readfile('d:/txt/class_export.txt') AS text),
         CHAR(10),
         '","'
     ) ||
     '"]'
 )
"@

# Execute query
$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$reader = $cmd.ExecuteReader()

# Display results
Write-Host "`nResults from JSON_EACH using sqlite readfile():" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Yellow

$rowCount = 0
while ($reader.Read()) {
    $rowCount++
    Write-Host "Row $rowCount : $($reader.GetString(0))"
}

$reader.Close()
$conn.Close()
;;;;
%slc_psend;


/**************************************************************************************************************************/
/*  Create d:/txt/class_export.txt using sqlite writefile                                                                 */
/* ========================================================                                                               */
/*                                                                                                                        */
/* Results from JSON_EACH using sqlite readfile():                                                                        */
/* =================================================                                                                      */
/* Row 1 : This is the 1st line                                                                                           */
/* Row 2 : This is the 2nd line                                                                                           */
/* Row 3 : This is the 3rd line                                                                                           */
/* Row 4 : This is the 4th line                                                                                           */
/* Row 5 : This is the 5th line                                                                                           */
/**************************************************************************************************************************/

/*         _                      _                 _ _         _
 ___  __ _| |  _ __ ___  __ _  __| | __      ___ __(_) |_ ___  | | ___   __ _
/ __|/ _` | | | `__/ _ \/ _` |/ _` | \ \ /\ / / `__| | __/ _ \ | |/ _ \ / _` |
\__ \ (_| | | | | |  __/ (_| | (_| |  \ V  V /| |  | | ||  __/ | | (_) | (_| |
|___/\__, |_| |_|  \___|\__,_|\__,_|   \_/\_/ |_|  |_|\__\___| |_|\___/ \__, |
        |_|                                                             |___/
*/

1                                          Altair SLC          13:11 Sunday, March 22, 2026

NOTE: Copyright 2002-2025 World Programming, an Altair Company
NOTE: Altair SLC 2026 (05.26.01.00.000758)
      Licensed to Roger DeAngelis
NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
NOTE: AUTOEXEC source line
1       +  ï»¿ods _all_ close;
           ^
ERROR: Expected a statement keyword : found "?"

NOTE: AUTOEXEC processing completed

1         %utlfkil(d:/txt/class_export.txt);
2
3         %slc_psbegin;
4         cards4;

NOTE: The file 'c:\temp\ps_pgm.ps1' is:
      Filename='c:\temp\ps_pgm.ps1',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=14:40:04 Mar 21 2026,
      Last Accessed=13:11:29 Mar 22 2026,
      Last Modified=13:11:29 Mar 22 2026,
      Lrecl=32767, Recfm=V

NOTE: 54 records were written to file 'c:\temp\ps_pgm.ps1'
      The minimum record length was 80
      The maximum record length was 106
NOTE: The data step took :
      real time : 0.006
      cpu time  : 0.000


5         # Connection string
6         $connectionString = "DRIVER=SQLite3 ODBC Driver;database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;"
7
8         $conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
9         $conn.Open()
10
11        $createCmd = $conn.CreateCommand()
12        $createCmd.CommandText = "DROP TABLE IF EXISTS avgs"
13        $createCmd.ExecuteNonQuery()
14
15
16        Write-Host "`nCreate d:/txt/class_export.txt using sqlite writefile"
17        Write-Host "========================================================" -ForegroundColor Yellow
18
19        $createCmd = $conn.CreateCommand()
20        $createCmd.CommandText = @"
21        SELECT writefile(
22            'd:/txt/class_export.txt',
23            (SELECT group_concat(line, char(10)) FROM have)
24            )
25        "@
26        $rowsAffected = $createCmd.ExecuteNonQuery()
27
28
29        $sql = @"
30         SELECT value AS txt
31         FROM json_each(
32             '["' ||
33             replace(
34                 cast(readfile('d:/txt/class_export.txt') AS text),
35                 CHAR(10),
36                 '","'
37             ) ||
38             '"]'
39         )
40        "@
41
42        # Execute query
43        $cmd = $conn.CreateCommand()
44        $cmd.CommandText = $sql
45        $reader = $cmd.ExecuteReader()
46
47        # Display results
48        Write-Host "`nResults from JSON_EACH using sqlite readfile():" -ForegroundColor Yellow
49        Write-Host "=================================================" -ForegroundColor Yellow
50
51        $rowCount = 0
52        while ($reader.Read()) {
53            $rowCount++
54            Write-Host "Row $rowCount : $($reader.GetString(0))"
55        }
56
57        $reader.Close()
58        $conn.Close()
59        ;;;;
60        %slc_psend;

NOTE: The infile rut is:
      Unnamed Pipe Access Device,
      Process=powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log,
      Lrecl=32756, Recfm=V

NOTE: No records were written to file PRINT

NOTE: No records were read from file rut
NOTE: The data step took :
      real time : 0.681
      cpu time  : 0.015



NOTE: The infile rut is:
      Unnamed Pipe Access Device,
      Process=powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log,
      Lrecl=32767, Recfm=V

NOTE: No records were written to file PRINT

NOTE: No records were read from file rut
NOTE: The data step took :
      real time : 0.611
      cpu time  : 0.015



NOTE: The infile 'c:\temp\ps_pgm.log' is:
      Filename='c:\temp\ps_pgm.log',
      Owner Name=SLC\suzie,
      File size (bytes)=359,
      Create Time=10:30:46 Mar 22 2026,
      Last Accessed=13:11:31 Mar 22 2026,
      Last Modified=13:11:31 Mar 22 2026,
      Lrecl=32767, Recfm=V

0

Create d:/txt/class_export.txt using sqlite writefile
========================================================

Results from JSON_EACH using sqlite readfile():
=================================================
Row 1 : This is the 1st line
Row 2 : This is the 2nd line
Row 3 : This is the 3rd line
Row 4 : This is the 4th line
Row 5 : This is the 5th line
NOTE: 12 records were read from file 'c:\temp\ps_pgm.log'
      The minimum record length was 0
      The maximum record length was 56
NOTE: 12 records were written to file PRINT

NOTE: The data step took :
      real time : 0.015
      cpu time  : 0.000


61
ERROR: Error printed on page 1

NOTE: Submitted statements took :
      real time : 1.481
      cpu time  : 0.156

/*  _               _   _                   _
| || |    ___  __ _| | | | ___   ___  _ __ (_)_ __   __ _
| || |_  / __|/ _` | | | |/ _ \ / _ \| `_ \| | `_ \ / _` |
|__   _| \__ \ (_| | | | | (_) | (_) | |_) | | | | | (_| |
   |_|   |___/\__, |_| |_|\___/ \___/| .__/|_|_| |_|\__, |
                 |_|                 |_|            |___/
*/


%slc_psbegin;
cards4;
# Connection string
$connectionString = "DRIVER=SQLite3 ODBC Driver;database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;"

$conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
$conn.Open()

# Drop table if exists
$createCmd = $conn.CreateCommand()
$createCmd.CommandText = "DROP TABLE IF EXISTS avgs"
$createCmd.ExecuteNonQuery()

# Create command for the recursive query
$cmd = $conn.CreateCommand()  # <-- USE $cmd, not $createCmd
$cmd.CommandText = @"
WITH RECURSIVE nums(x) AS (
    SELECT 1
    UNION ALL
    SELECT x + 1 FROM nums WHERE x < 10
),
med AS (
    SELECT
        x,
        ROW_NUMBER() OVER (ORDER BY x) AS r,
        COUNT(*) OVER () AS c
    FROM nums
)
SELECT AVG(x) AS median
FROM med
WHERE r IN ((c+1)/2, (c+2)/2)
"@

# Use ExecuteScalar to get a single value
$median = $cmd.ExecuteScalar()

# Print the result
Write-Host "Median of numbers 1-10 is: $median" -ForegroundColor Green

$conn.Close()
;;;;
%slc_psend;


/**************************************************************************************************************************/
/*  Altair SLC                                                                                                            */
/*                                                                                                                        */
/* Median of numbers 1-10 is: 5.5                                                                                         */
/**************************************************************************************************************************/

/*                   _               _
| | ___   ___  _ __ (_)_ __   __ _  | | ___   __ _
| |/ _ \ / _ \| `_ \| | `_ \ / _` | | |/ _ \ / _` |
| | (_) | (_) | |_) | | | | | (_| | | | (_) | (_| |
|_|\___/ \___/| .__/|_|_| |_|\__, | |_|\___/ \__, |
              |_|            |___/           |___/
*/

1                                          Altair SLC          13:35 Sunday, March 22, 2026

NOTE: Copyright 2002-2025 World Programming, an Altair Company
NOTE: Altair SLC 2026 (05.26.01.00.000758)
      Licensed to Roger DeAngelis
NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
NOTE: AUTOEXEC source line
1       +  ï»¿ods _all_ close;
           ^
ERROR: Expected a statement keyword : found "?"

NOTE: AUTOEXEC processing completed

1         %slc_psbegin;
2         cards4;

NOTE: The file 'c:\temp\ps_pgm.ps1' is:
      Filename='c:\temp\ps_pgm.ps1',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=14:40:04 Mar 21 2026,
      Last Accessed=13:35:12 Mar 22 2026,
      Last Modified=13:35:12 Mar 22 2026,
      Lrecl=32767, Recfm=V

NOTE: 38 records were written to file 'c:\temp\ps_pgm.ps1'
      The minimum record length was 80
      The maximum record length was 106
NOTE: The data step took :
      real time : 0.000
      cpu time  : 0.000


3         # Connection string
4         $connectionString = "DRIVER=SQLite3 ODBC Driver;database=d:/sqlite/mysqlite.db;LoadExt=d:/dll/sqlean.dll;"
5
6         $conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
7         $conn.Open()
8
9         # Drop table if exists
10        $createCmd = $conn.CreateCommand()
11        $createCmd.CommandText = "DROP TABLE IF EXISTS avgs"
12        $createCmd.ExecuteNonQuery()
13
14        # Create command for the recursive query
15        $cmd = $conn.CreateCommand()  # <-- USE $cmd, not $createCmd
16        $cmd.CommandText = @"
17        WITH RECURSIVE nums(x) AS (
18            SELECT 1
19            UNION ALL
20            SELECT x + 1 FROM nums WHERE x < 10
21        ),
22        med AS (
23            SELECT
24                x,
25                ROW_NUMBER() OVER (ORDER BY x) AS r,
26                COUNT(*) OVER () AS c
27            FROM nums
28        )
29        SELECT AVG(x) AS median
30        FROM med
31        WHERE r IN ((c+1)/2, (c+2)/2)
32        "@
33
34        # Use ExecuteScalar to get a single value
35        $median = $cmd.ExecuteScalar()
36
37        # Print the result
38        Write-Host "Median of numbers 1-10 is: $median" -ForegroundColor Green
39
40        $conn.Close()
41        ;;;;
42        %slc_psend;

NOTE: The infile rut is:
      Unnamed Pipe Access Device,
      Process=powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log,
      Lrecl=32756, Recfm=V

NOTE: No records were written to file PRINT

NOTE: No records were read from file rut
NOTE: The data step took :
      real time : 0.586
      cpu time  : 0.015



NOTE: The infile rut is:
      Unnamed Pipe Access Device,
      Process=powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log,
      Lrecl=32767, Recfm=V

NOTE: No records were written to file PRINT

NOTE: No records were read from file rut
NOTE: The data step took :
      real time : 0.570
      cpu time  : 0.000



NOTE: The infile 'c:\temp\ps_pgm.log' is:
      Filename='c:\temp\ps_pgm.log',
      Owner Name=SLC\suzie,
      File size (bytes)=34,
      Create Time=10:30:46 Mar 22 2026,
      Last Accessed=13:35:13 Mar 22 2026,
      Last Modified=13:35:13 Mar 22 2026,
      Lrecl=32767, Recfm=V

0
Median of numbers 1-10 is: 5.5
NOTE: 2 records were read from file 'c:\temp\ps_pgm.log'
      The minimum record length was 1
      The maximum record length was 30
NOTE: 2 records were written to file PRINT

NOTE: The data step took :
      real time : 0.015
      cpu time  : 0.015


43
ERROR: Error printed on page 1

NOTE: Submitted statements took :
      real time : 1.315
      cpu time  : 0.125

/*___              _               _               _     _                _     _              _
| ___|   ___  __ _| |   ___  _   _| |_ _ __  _   _| |_  | |__   __ _  ___| | __| |_ ___    ___| | ___
|___ \  / __|/ _` | |  / _ \| | | | __| `_ \| | | | __| | `_ \ / _` |/ __| |/ /| __/ _ \  / __| |/ __|
 ___) | \__ \ (_| | | | (_) | |_| | |_| |_) | |_| | |_  | |_) | (_| | (__|   < | || (_) | \__ \ | (__
|____/  |___/\__, |_|  \___/ \__,_|\__| .__/ \__,_|\__| |_.__/ \__,_|\___|_|\_\ \__\___/  |___/_|\___|
                |_|                   |_|
*/

proc sql;
  connect to odbc
    (noprompt="DRIVER=SQLite3 ODBC Driver;
               Database=d:\sqlite\mysqlite.db;
               LoadExt=d:\dll\sqlean.dll;");
  select * from connection to odbc
    (select name as sqlite_objects  from sqlite_master);
quit;


proc print data=sqlite.avgs width=min;
run;

data workx.avgs;
  set sqlite.avgs;
run;quit;

data _null_;
 infile "d:/txt/class_export.txt";
 file print;
 input;
 put _infile_;
run;

libname sqlite clear;

/**************************************************************************************************************************/
/* Altair SLC                                                                                                             */
/*                                                                                                                        */
/* sqlite_objects                                                                                                         */
/* -----------------------------------                                                                                    */
/* sqlean_define                                                                                                          */
/* sqlite_autoindex_sqlean_define_1                                                                                       */
/* have                                                                                                                   */
/* avgs                                                                                                                   */
.*                                                                                                                        */
/* WORKX.AVGS total obs=2                                                                                                 */
.*                                            AVG_                                                                        */
/*  NAMES                  SEX    AVG_AGE    HEIGHT                                                                       */
/*                                                                                                                        */
/*  Alice,Barbara,Carol     F      13.3       61.5                                                                        */
/*  Alfred,Henry            M      14.0       66.3                                                                        */
/*                                                                                                                        */
/*                                                                                                                        */
/* PRINTED OUTPUT                                                                                                         */
/*                                                                                                                        */
/* This is the 1st line                                                                                                   */
/* This is the 2nd line                                                                                                   */
/* This is the 3rd line                                                                                                   */
/* This is the 4th line                                                                                                   */
/* This is the 5th line                                                                                                   */
/**************************************************************************************************************************/


/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
