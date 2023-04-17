         The Hypertext Transfer Protocol API -- README


ALTERNATIVE #1: INSTALL FROM A SAVE FILE
---------------------------------------------------------------------
  1)  Transfer the HTTPAPI.SAVF from my web server to your PC.

  2)  Create a SAVF on your AS/400:
          CRTSAVF MYLIB/HTTPAPI

  3)  Transfer the file called HTTPAPI.SAVF from your PC to the
       newly created SAVF on your AS/400.   I use FTP to do this,
       using binary mode, I do "put httpapi.savf MYLIB/HTTPAPI"
       You can do it whichever way you like, however :)

  4)  Unpack the HTTPAPI library:
         RSTLIB SAVLIB(LIBHTTP) DEV(*SAVF) SAVF(MYLIB/HTTPAPI)

  5)  Build the INSTALL program:
         CHGCURLIB CURLIB(LIBHTTP)
         CRTCLPGM PGM(INSTALL) SRCFILE(LIBHTTP/QCLSRC)

  6)  Use the INSTALL program to build everything else:
         CALL INSTALL



ALTERNATIVE #2: ZIP FILE WITH WINDOWS BATCH UPLOADER
---------------------------------------------------------------------
The ZIP download from scottklement.com contains a Windows batch file
designed to automate the the process of uploading the data from
your PC to the 400.  This batch file only works on Windows, and only
works if FTP is the file transfer protocol.  If you can't use the
batch file, there are manual instructions in the next section.

  1) On Windows, unzip the HTTPAPI.ZIP file to a temporary folder,
       for example, extract all files to C:\httpapi

  2) Open an MS-DOS prompt (or Command Prompt)

  3) Switch to the folder where you extracted the files
       cd \httpapi

  4) Run the batch file. Pass the host name, userid and password
     as parameters to the batch file.
       upload.bat as400.example.com bob mypassword

  5) On the OS/400 command-prompt, type:
       - CHGCURLIB CURLIB(LIBHTTP)
       - CRTCLPGM INSTALL SRCFILE(LIBHTTP/QCLSRC)
       - CALL INSTALL


ALTERNATIVE #3: ZIP FILE, COPY THE FILES MANUALLY
---------------------------------------------------------------------
Note: This is the most difficult way to install HTTPAPI. If possible
      please use either the SAVF or XML methods instead.

  1)  Transfer the HTTPAPI.ZIP from my web server to your PC.

  2)  Extract HTTPAPI.ZIP to a temporary location on your PC.

      Note: If you're using a Linux/Unix computer, and using
            the "unzip" tool from InfoZip, use the -a switch
            to convert the file format from DOS to UNIX.
            An example follows:
               unzip -a httpapi.zip

  3)  Create the necessary objects on the iSeries box:
          CRTLIB LIBHTTP
          CRTSRCPF FILE(LIBHTTP/QCLSRC) RCDLEN(92)
          CRTSRCPF FILE(LIBHTTP/QDDSSRC) RCDLEN(92)
          CRTSRCPF FILE(LIBHTTP/QRPGLESRC) RCDLEN(112)
          CRTSRCPF FILE(LIBHTTP/QSH) RCDLEN(124)
          CRTSRCPF FILE(LIBHTTP/QSRVSRC) RCDLEN(92)
          CRTSRCPF FILE(LIBHTTP/QXMLGENS) RCDLEN(112)
          CRTSRCPF FILE(LIBHTTP/EXPAT) RCDLEN(112)

  4)  Use FTP to transfer the data to the iSeries. Start by
         opening an "MS-DOS Prompt" (or "Command Prompt")

  5)  In the command prompt, type the following:
       - ftp your-as400-name here
         (enter userid & password)
       - quote site namefmt 1
       - cd /qsys.lib/libhttp.lib
       - prompt off
       - ascii
       - mput QCLSRC.FILE/*
       - mput QDDSSRC.FILE/*
       - mput QRPGLESRC.FILE/*
       - mput QSH.FILE/*
       - mput QSRVSRC.FILE/*
       - mput QXMLGENS.FILE/*
       - mput EXPAT.FILE/*
       - quit

  6)  At the iSeries command-prompt type:
       - CHGCURLIB CURLIB(LIBHTTP)
       - CRTCLPGM INSTALL SRCFILE(LIBHTTP/QCLSRC)
       - CALL INSTALL


WHAT IS SSL/TLS
---------------------------------------------------------------------
Secure Socket Layer (SSL) was introduced by Netscape Communications
Corp to protect internet transactions. Netscape decided to open this
protocol up to the wider Internet community, making it an open
standard.  After it became an open standard, it was renamed
Transport Layer Security (TLS), so all newer version are named TLS
(instead of SSL.)  Despite this name change, many (most?) people still
refer to it as "SSL" when referring to it as a concept. When referring
to it in terms of the different versions available, you can think of
TLS as "newer versions of SSL".

SSL/TLS provide two important measures of protection:

   encryption: All data in an SSL/TLS sessions are encrypted. This
      is important because data is often confidential and encryption
      prevents it from being viewed by others on the network.

   authentication/idenfication: Encryption is only useful if you
      know it can only be decrypted by a trusted party. For example,
      if you are sending a credit card number, you want to make sure
      it can only be decrypted by the store you are sending it to
      (in order to purchase something.)  It doesn't do much good to
      encrypt it if it'll be decrypted by a credit card thief. In
      other words, you need to know who you are sending it to.


REQUIREMENTS FOR BUILDING WITH SSL/TLS SUPPORT
---------------------------------------------------------------------
  1)  You need to have these programs installed (as of V5R2):
        -- Digital Certificate Manager which is
            opt 34 of OS/400. (57xx-SS1)
        -- TCP/IP Connectivity Utilities (57xx-TC1)
        -- IBM HTTP server for iSeries (57xx-DG1)
        -- IBM Crypto Access Provider (57xx-AC3) (pre V5R4)
             (Starting with 6.1, this is called 57xx-NAE)
        -- In order to access the Digital Certificate Manager from
             the web server, you'll also need the IBM Developer
             Kit for Java (57xx-JV1).

  2)  This software uses IBM's "Global Secure Toolkit" (GSKit)
        for SSL.  This is available only in V4R5 and later.

        In V5R1 and later, it is included with the base OS/400.

        For V4R5:  You need CUM PTF packages C1100450 to be installed
                   In addition to that, I have the following PTFs
                   installed: (I don't know which ones are absolutely
                   necessary)
                   SF64938  SF66346  SF64197  SF64936
                   MF25723  MF25724  MF25725  MF25728  MF25306
                   MF25307  MF25309

        Of course, you'll want to make sure that you read the cover
        sheets and install any prerequsites, as per normal PTF
        procedures...

  3)  Once you have all of that installed, you'll need to set up
        the *SYSTEM certificate store in the Digital Certificate
        Manager. If you already have this configured, you're
        ready to use HTTPAPI's SSL support.

  4)  Start the digital certificate manager by typing:
        STRTCPSVR SERVER(*HTTP) HTTPSVR(*ADMIN)

  5)  Connect to the ADMIN instance of the HTTP server by pointing
        your Web browser to:
        http://your-system-name:2001

  6)  Click "Digital Certificate Manager"

  7)  Click "Create New Certificate Store" (in the navigation frame
        on the left)

  8)  Follow the prompts to create a *SYSTEM certificate store

  9)  You do not need to create or assign any certificates unless
        required by the business partner that you will be
        communicating with.  Usually this is only required when
        security is vital (such as when talking to a bank).
        Companies like UPS, for example, don't require you to send
        them any certificates.


ENABLING/DISABLING SSL/TLS PROTOCOLS
---------------------------------------------------------------------
Starting with IBM i 6.1, there are system values that control
which versions of SSL/TLS that are available for applications
(incuding HTTPAPI) to use.

QSSLPCL:  The default value of *OPSYS means to let the operating
          system select the versions of SSL/TLS available to
          applications. This differs with each OS version.

             5.4 and earlier: all protocols available
             6.1: SSLv3 and TLSv1,0
             7.1: SSLv3 and TLSv1.0
             7.2: TLSv1.0, TLSv1.1 and TLSv1.2

          You can change these values, however, to disable/enable
          protocol versions. For example, if you have the PTFs
          installed, you can enable TLS v1.1 and v1.2 on 7.1 by
          changing the system value:

       CHGSYSVAL SYSVAL(QSSLPCL) VALUE('*TLSV1 *TLSV1.1 *TLSV1.2')

These protocols only enforce what applications are allowed to use
or not use. They do not enable support within the application itself.
By default, HTTPAPI will try to negotiate any of the TLS protocols
but the older SSL protocols are disabled by default.  You can
control which protocols HTTPAPI enables by calling https_init()
prior to using your SSL URLs.

 https_init(*blanks: *ON: *ON: *ON: *ON: *ON);

The above example enables all protocols. They are SSLv2, SSLv3,
TLSv1.0, TLSv1.1, and TLSv1.2, respectively.  You can disable
or enable each one by passing *ON or *OFF as appropriate.

The QSSLCSL and QSSLCSLCTL system values can be used to control
which ciphers are available. We recommend keeping the system
defaults for these unless you know what you're doing.  For more
details on ciphers, see the IBM Information Center.


ENABLING SSL STRICT MODE:
---------------------------------------------------------------------
By default, HTTPAPI does not attept to verify the identity of the
HTTP server you are communicating with.  This is turned off because
many organizations use SSL with "self-signed" certificates, and
this makes things much simpler for them.

However, this essentially disables the identity checking that
is meant to be done with SSL. Therefore, you may wish to perform
stricter checking within HTTPAPI. You can do this by calling the
https_strict() function prior to using SSL in your application:

     https_strict(*ON);



GRANTING ORDINARY USERS PERMISSION TO RUN SSL APPLICATIONS
---------------------------------------------------------------------
When you get an error using SSL like the following:
  "(GSKit) Access to the key database is not allowed"
This is because the end-user doesn't have authority to the files
in the IFS needed by the Global Secure Toolkit (GSKit) in the
operating system. This is the component in the OS used for SSL/TLS.

To solve that problem, grant authority as follows...
In this example, I'm giving a user named SCOTTK access to the
files.  (Change SCOTTK to the proper userid when you do it)

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

If you wish to give all users access to run SSL programs, then
you should change USER(SCOTTK) to USER(*PUBLIC).  You can also
use an AUTL if you like by specifying AUTL(your-autl) instead
of USER(your-user)

NOTE: It's okay to give extra access. For example, if your
      users currently have *RWX to the IFS root, there's no
      need to change it to *RX, *RWX will also work. The
      above authorities are the minimum levels needed.

NOTE: Adopted authority does not work in the IFS.  Please
      grant permissions by the actual userid, not the adopted
      one.



REQUIREMENTS FOR BUILDING EXPAT FOR XML SUPPORT
---------------------------------------------------------------------
NOTE: This describes the process of building the EXPAT service
      program that HTTPAPI can use. If you don't want to build
      it from source, it's possible to install it from a precompiled
      version. See the next section for details.

  1)  System requirements:
       - V5R1 or later.
       - You need the ILE C compiler (57xx-WDS opt 51)
         (Note that in V5R1 and later, all compilers are bundled
          together. If you have the RPG compiler, you have the
          right to use the C compiler as well, but may need to
          install it separately.)
       - You need the System Openness Includes option of
          OS/400 installed (57xx-SS1 opt 13)
          (This is part of OS/400, but is installed separately)

  2) Select 'Y' in the install program for both of the following
       questions:
        'Would you like to build eXpat from source code?'
        'Would you like to compile support for eXpat into HTTPAPI?'


INSTALLING THE PRE-BUILD EXPAT SERVICE PROGRAM
---------------------------------------------------------------------
NOTE: This is only necessary if you haven't compiled Expat in the
      previous step, but would still like to use HTTPAPI's support
      for XML parsing.

  1) System Requirements:
      -- Must be at V5R1 or later.

  2) Follow the steps above to install HTTPAPI, but when the
      'License Agreement' page appears, press F3 to exit.

  3) Download the precompile Expat SAVEFILE from
      http://www.scottklement.com/expat/

  4) Create a save file on the iSeries to receive the Expat
      source code:
         CRTSAVF FILE(MYLIB/EXPAT)

  5) Use FTP to upload the SAVF:
      -  ftp as400-name-here
         (enter userid & password)
      -  quote site namefmt 0
      -  cd mylib
      -  binary
      -  put expat.savf expat
      - quit

  6) Restore ONLY the EXPAT service program to LIBHTTP
      - RSTOBJ OBJ(EXPAT) SAVLIB(LIBEXPAT) DEV(*SAVF)
               OBJTYPE(*SRVPGM) RSTLIB(LIBHTTP)

  7) Now re-run the INSTALL program for HTTPAPI.
      - CHGCURLIB CURLIB(LIBHTTP)
      - CALL INSTALL

  8) Answer the following questions in the Installer:
      Specify 'N' for:
        'Would you like to build eXpat from source code?'
      Specify 'Y' for:
        'Would you like to compile support for eXpat into HTTPAPI?' = Y


TRYING THE EXAMPLE PROGRAMS:
-------------------------------------------------------------------
I included many example programs with the library.  They are
called "EXAMPLExx" where "xx" is a number.

If you specified 'Y' in HTTPAPI's install program for the question
'Would you like to build the sample programs?' then these have
already been built for you.

Look at the source members in LIBHTTP/QRPGLESRC for information on
how they work and what they do, then try them out.



IF YOU HAVE ANY QUESTIONS, OR NEED HELP:
-------------------------------------------------------------------
HTTPAPI is an open-source project, there is no "official" support,
but most people are able to get support from the members of the
FTPAPI mailing list.

The FTPAPI list is used to support both the FTPAPI and HTTPAPI
projects.

First, check to see if someone else has had the same problem and
had it resolved.  You can search the archives of the mailing list
at the following link:
  http://www.scottklement.com/archives/

If you still need help, you should sign up for the FTPAPI mailing
list. You can do so at the following link:
  http://www.scottklement.com/ftpapi/ftpapilist.html

Once you've subscribed, you can ask questions to the list by
sending an e-mail to:
  ftpapi@lists.scottklement.com

Good Luck!
