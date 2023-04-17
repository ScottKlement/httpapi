# HTTPAPI -- HTTP client support for ILE RPG -- README

Main website https://www.scottklement.com

ALTERNATIVE #1: (Recommended) Use Git/Makefile
---------------------------------------------------------------------
This is the most modern approach and is the approach recommended if you wish to make changes to the source code that will be contributed back to the project. Using this approach, the source code will be kept in your IFS and managed with git.

  1) If not already installed, you'll need YUM on your IBM i. Instructions can be found here:
       - https://ibmi-oss-docs.readthedocs.io/en/latest/yum/README.html

  2) You'll need `git` and `GNU make`. If not already installed, from a PASE command line, type:
       - `yum install git`
       - `yum install make-gnu`

  3) Clone this repository from GitHub. From a PASE command line:
       - (if your PATH isn't set up)`export PATH=/QOpenSys/pkgs/bin:$PATH` 
       - `https://github.com/ScottKlement/httpapi.git`

  4) Build HTTPAPI from the PASE command line:
       - (if your PATH isn't set up) `export PATH=/QOpenSys/pkgs/bin:$PATH`
       - `cd httpapi`
       - `make LIBRARY=libhttp`

**NOTE**: To keep the messages on the screen clean and easy to follow, compile errors are not printed to the screen. Instead, files are created in the `tmp` subdirectory containing the output of the various compile commands.


ALTERNATIVE #2: INSTALL/COMPILE FROM A SAVE FILE
---------------------------------------------------------------------
  1) Transfer the HTTPAPI.SAVF from my web server to your PC.

  2) Create a SAVF on your IBM i:
          `CRTSAVF MYLIB/HTTPAPI`

  3) Transfer the file called HTTPAPI.SAVF from your PC to the newly created SAVF on your IBM i. I use FTP to do this, using binary mode, I do `put httpapi.savf MYLIB/HTTPAPI` You can do it whichever way you like, however

  4) Unpack the HTTPAPI library:
       - `RSTLIB SAVLIB(LIBHTTP) DEV(*SAVF) SAVF(MYLIB/HTTPAPI)`

  5)  Build the INSTALL program:
       - `CHGCURLIB CURLIB(LIBHTTP)`
       - `CRTBNDCL PGM(INSTALL) SRCFILE(LIBHTTP/QCLSRC)`

  6)  Use the INSTALL program to build everything else:
       - `CALL INSTALL`



ALTERNATIVE #3: ZIP FILE WITH WINDOWS BATCH UPLOADER
---------------------------------------------------------------------
The ZIP download from scottklement.com contains a Windows batch file designed to automate the the process of uploading the data from your PC to the IBM i. This batch file only works on Windows, and only works if FTP is the file transfer protocol.  If you can't use the batch file, there are manual instructions in the next section.

  1) On Windows, unzip the HTTPAPI.ZIP file to a temporary folder, for example, extract all files to `C:\httpapi`

  2) Open an MS-DOS prompt (or Command Prompt)

  3) Switch to the folder where you extracted the files 
       - `cd \httpapi`

  4) Run the batch file. Pass the host name, userid and password
     as parameters to the batch file.
       - `upload.bat ibmi.example.com bob mypassword`

  5) On the IBM i command-prompt, type:
       - `CHGCURLIB CURLIB(LIBHTTP)`
       - `CRTCLPGM INSTALL SRCFILE(LIBHTTP/QCLSRC)`
       - `CALL INSTALL`


WHAT IS SSL/TLS
---------------------------------------------------------------------
Secure Socket Layer (SSL) was introduced by Netscape Communications Corp to protect internet transactions. Netscape decided to open this protocol up to the wider Internet community, making it an open standard. After it became an open standard, it was renamed Transport Layer Security (TLS), so all newer version are named TLS (instead of SSL.)  Despite this name change, many (most?) people still refer to it as "SSL" when referring to it as a concept. When referring to it in terms of the different versions available, you can think of
TLS as "newer versions of SSL".

SSL/TLS provide two important measures of protection:

   **encryption**: All data in an SSL/TLS sessions are encrypted. This is important because data is often confidential and encryption prevents it from being viewed by others on the network.

   **authentication/idenfication**: Encryption is only useful if you know it can only be decrypted by a trusted party. For example, if you are sending a credit card number, you want to make sure it can only be decrypted by the store you are sending it to (in order to purchase something.) It doesn't do much good to     encrypt it if it'll be decrypted by a credit card thief. In other words, you need to know who you are sending it to.


REQUIREMENTS FOR BUILDING WITH SSL/TLS SUPPORT
---------------------------------------------------------------------
  1)  You need to have these programs installed (as of V5R2):
        - Digital Certificate Manager which is
            opt 34 of IBM i. (57xx-SS1)
        - TCP/IP Connectivity Utilities (57xx-TC1)
        - IBM HTTP server for iSeries (57xx-DG1)
        - IBM Crypto Access Provider (57xx-NAE)
        - In order to access the Digital Certificate Manager from the web server, you'll also need the IBM Developer Kit for Java (57xx-JV1).

  2)  This software uses IBM's "Global Secure Toolkit" (GSKit) for TLS. It is included with the base operating system.

  3)  Once you have all of that installed, you'll need to set up the *SYSTEM certificate store in the Digital Certificate Manager. If you already have this configured, you're ready to use HTTPAPI's SSL/TLS support.

  4)  Start the *IBM Navigator for i* by typing:
       - `STRTCPSVR SERVER(*HTTP) HTTPSVR(*ADMIN)`

  5)  Connect to the `Navigator for i` instance of the HTTP server by pointing your Web browser to:
       - http://your-system-name:2001

  6)  Click "Digital Certificate Manager"

  7)  Click "Create New Certificate Store" (in the navigation frame on the left)

  8)  Follow the prompts to create a *SYSTEM certificate store

  9)  You do not need to create or assign any certificates unless required by the business partner that you will be communicating with.  Usually this is only required when security is vital (such as when talking to a bank). Companies like UPS, for example, don't require you to send them any certificates.


ENABLING/DISABLING SSL/TLS PROTOCOLS
---------------------------------------------------------------------
Starting with IBM i 6.1, there are system values that control which versions of SSL/TLS that are available for applications (incuding HTTPAPI) to use.

QSSLPCL: The default value of *OPSYS means to let the operating system select the versions of SSL/TLS available to applications. This differs with each OS version.

- 7.1: SSLv3 and TLSv1.0
- 7.2: TLSv1.0, TLSv1.1 and TLSv1.2
- 7.3+: TLSv1.1, TLSv1.2, and TLSv1.3

You can change these values, however, to disable/enable protocol versions. For example:

  `CHGSYSVAL SYSVAL(QSSLPCL) VALUE('*TLSV1 *TLSV1.1 *TLSV1.2')`

**NOTE**: Because cryptography and security are always changing, it is highly recommended that you update to a supported version of IBM i if at all possible. (For example, at the time that I am writing this, the TLS support in v7r1 is not very secure, and many sites will reject it.)

The QSSLCSL and QSSLCSLCTL system values can be used to control which ciphers are available. We recommend keeping the system defaults for these unless you know what you're doing. For more
details on ciphers, see the IBM Information Center.


ENABLING SSL STRICT MODE:
---------------------------------------------------------------------
By default, HTTPAPI does not attept to verify the identity of the HTTP server you are communicating with. This is turned off because many organizations use SSL with "self-signed" certificates, and this makes things much simpler for them.

However, this essentially disables the identity checking that is meant to be done with SSL. Therefore, you may wish to perform stricter checking within HTTPAPI. You can do this by calling the https_strict() function prior to using SSL in your application:

- `https_strict(*ON);`



GRANTING ORDINARY USERS PERMISSION TO RUN TLS (SSL) APPLICATIONS
---------------------------------------------------------------------
When you get an error using SSL like the following:
  `(GSKit) Access to the key database is not allowed`
This is because the end-user doesn't have authority to the files in the IFS needed by the Global Secure Toolkit (GSKit) in the operating system. This is the component in the OS used for SSL/TLS.

To solve that problem, grant authority as follows...
In this example, I'm giving a user named SCOTTK access to the files.  (Change SCOTTK to the proper userid when you do it)

```
 CHGAUT OBJ('/') +
        USER(SCOTTK) DTAAUT(*RX)
 CHGAUT OBJ('/QIBM') +
        USER(SCOTTK) DTAAUT(*RX)
 CHGAUT OBJ('/QIBM/UserData') +
        USER(SCOTTK) DTAAUT(*RX)
 CHGAUT OBJ('/QIBM/UserData/ICSS') +
        USER(SCOTTK) DTAAUT(*RX)
 CHGAUT OBJ('/QIBM/UserData/ICSS/CERT') +
        USER(SCOTTK) DTAAUT(*RX)
 CHGAUT OBJ('/QIBM/UserData/ICSS/CERT/SERVER')
        USER(SCOTTK) DTAAUT(*RX)
 CHGAUT OBJ('/QIBM/UserData/ICSS/CERT/SERVER/DEFAULT.KDB')
        USER(SCOTTK) DTAAUT(*R)
 CHGAUT OBJ('/QIBM/UserData/ICSS/CERT/SERVER/DEFAULT.RDB')
        USER(SCOTTK) DTAAUT(*R)
```

If you wish to give all users access to run SSL programs, then you should change USER(SCOTTK) to USER(*PUBLIC). You can also use an AUTL if you like by specifying AUTL(your-autl) instead of USER(your-user)

**NOTE**: It's okay to give extra access. For example, if your users currently have *RWX to the IFS root, there's no need to change it to *RX, *RWX will also work. The above authorities are the minimum levels needed.

**NOTE**: Adopted authority does not work in the IFS. Please grant permissions by the actual userid, not the adopted one.


REQUIREMENTS FOR BUILDING EXPAT FOR XML SUPPORT
---------------------------------------------------------------------
**NOTE**: This describes the process of building the EXPAT service program that HTTPAPI can use. If you don't want to build it from source, it's possible to install it from a precompiled version. See the next section for details.

  1)  System requirements:
       - V5R1 or later.
       - You need the ILE C compiler (57xx-WDS opt 51)
         (Note that in V5R1 and later, all compilers are bundled together. If you have the RPG compiler, you have the right to use the C compiler as well, but may need to install it separately.)
       - You need the System Openness Includes option of IBM i installed (57xx-SS1 opt 13)
          (This is part of IBM i, but is installed separately)

  2) If HTTPAPI was built with the `make` method, Expat was built automatically (unless explicitly disabled.)          

  3) If built with the INSTALL program, Select 'Y' in the for both of the following questions:
       - 'Would you like to build eXpat from source code?'
       - 'Would you like to compile support for eXpat into HTTPAPI?'


INSTALLING THE PRE-BUILT EXPAT SERVICE PROGRAM
---------------------------------------------------------------------
**NOTE**: This is only necessary if you haven't compiled Expat in the previous step, but would still like to use HTTPAPI's support for XML parsing.

  1) System Requirements:
       - Must be at V5R1 or later.

  2) Follow the steps above to install HTTPAPI, but when the 'License Agreement' page appears, press F3 to exit.

  3) Download the precompile Expat SAVEFILE from
      http://www.scottklement.com/expat/

  4) Create a save file on the IBM i to receive the Expat source code:
       - `CRTSAVF FILE(MYLIB/EXPAT)`

  5) Use FTP to upload the SAVF:
      - `ftp as400-name-here`
         (enter userid & password)
      - `quote site namefmt 0`
      - `cd mylib`
      - `binary`
      - `put expat.savf expat`
      - `quit`

  6) Restore ONLY the EXPAT service program to LIBHTTP
       - `RSTOBJ OBJ(EXPAT) SAVLIB(LIBEXPAT) DEV(*SAVF) OBJTYPE(*SRVPGM) RSTLIB(LIBHTTP)`

  7) Now re-run the INSTALL program for HTTPAPI.
      - `CHGCURLIB CURLIB(LIBHTTP)`
      - `CALL INSTALL`

  8) Answer the following questions in the INSTALL program:
      - Specify 'N' for 'Would you like to build eXpat from source code?'
      - Specify 'Y' for 'Would you like to compile support for eXpat into HTTPAPI?'


TRYING THE EXAMPLE PROGRAMS:
-------------------------------------------------------------------
I included many example programs with the library.  They are called "EXAMPLExx" where "xx" is a number.

If you specified 'Y' in HTTPAPI's install program for the question 'Would you like to build the sample programs?' then these have already been built for you.

Look at the source members in LIBHTTP/QRPGLESRC for information on how they work and what they do, then try them out.


IF YOU HAVE ANY QUESTIONS, OR NEED HELP:
-------------------------------------------------------------------
HTTPAPI is an open-source project, there is no "official" support, but most people are able to get support from the community using the HTTPAPI forum at the following link:  https://www.scottklement.com/forums/

First, check to see if someone else has had the same problem and had it resolved. You can search the forums using the seach box in the upper-right of the page.

If you still need help, 
- Make sure you've signed up for the forums (link is in the upper-right)
- Make sure you're currently signed in.
- click on the link for the [HTTPAPI forum](https://www.scottklement.com/forums/viewforum.php?f=2)
- Click "New Topic"

Good Luck!
