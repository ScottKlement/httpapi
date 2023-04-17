      * EXAMPLE27:
      * ----------
      * This example shows how to GET a web page that is hosted
      * by your IIS on your remote desktop PC. The authentication
      * mechanism used is NTLM, which is the default for IIS
      * servers.
      *
      * The program uses a persistent connection to download the
      * the web page twice.
      *
      * Since the devolper knows that the web server requires NTLM
      * negotiation, he does not need to try to GET the web page in
      * order to figure out the authentication mechanism.
      * Instead, he directly calls http_setauth() to specify
      * the credentials for authentication.
      *
      * The HTTP APIs used by the program are:
      *    http_persist_open()
      *    http_setauth()
      *    http_persist_get()
      *    http_persist_close()
      *
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP(*NEW)
      /endif
     H BNDDIR('HTTPAPI')

      /copy httpapi_h

     D Job_getTcpIpAddr...
     D                 PR            15A          varying

      * Note: The BNDDIR, above, tells ILE how to find the HTTPAPIR4
      *       service program which contains the routines.
      *       The /COPY directive provides prototypes and constants
      *       needed to call the routines.

     D example27       PR                  extpgm('EXAMPLE27')
     D  i_user                       32A   const
     D  i_password                   32A   const
     D  i_debugLog                   32A   const

     D example27       PI
     D  i_user                       32A   const
     D  i_password                   32A   const
     D  i_debugLog                   32A   const

     D rc              s             10I 0
     D err             S             10I 0 inz
     D msg             s             52A
     D URL             S            300A   varying
     D IFS             S            256A   varying

     D Basic           S              1N   inz(*Off)
     D Digest          S              1N   inz(*Off)
     D Realm           S            124A   inz
     D Ntlm            S              1N   inz(*Off)
     D user            S                   like(i_user     ) inz('Donald')
     D password        S                   like(i_password ) inz('TheSecret')
     D debugLog        S             32A   varying inz

     D pComm           S               *   inz
     D fd              S             10I 0 inz
      *
      *  fd/-1 = open()--Open File                          include <fcntl.h>
     D open...
     D                 PR            10I 0        extproc('open')               = int
     D  i_pPath                        *   value  options(*string)              = *path
     D  i_opnFLag                    10I 0 value                                = int
     D  i_mode                       10U 0 value  options(*nopass)              = uint
     D  i_codePage                   10U 0 value  options(*nopass)              = uint
     D  i_crtCodePage                10U 0 value  options(*nopass)              = uint
      *
      *  0/-1 = close()--Close File or Socket Descriptor    include <unistd.h>
     D close...
     D                 PR            10I 0 extproc('close')                     = int
     D  i_fd                         10I 0 value                                = int
      *
     D O_CREAT         C                   const( 8)                            | Append Mode
     D O_CCSID         C                   const(32)                            | CCSID
     D O_TRUNC         C                   const(64)                            | Truncate Fla
     D O_WRONLY        C                   const( 2)                            | Write Only
      /free

         if (%parms() >= 3);
            user = i_user;
            password = i_password;
            debugLog = i_debugLog;
            debugLog = %trim(i_debugLog);
         else;
            debugLog = '/tmp/';
         endif;

         // ********************************************************
         //  Turning on debugging.
         //
         //     Calling http_debug and passing *ON will turn on
         //     HTTPAPI's debugging support.  It will write a debug
         //     log file to the IFS in /tmp/httpapi_debug.txt
         //     with loads of tech info about the HTTP transaction.
         //
         //     The debug file is crucial if you have problems!
         // ********************************************************
         // http_debug(*ON);
         http_debug(*ON: debugLog + 'httpapi_example27.log');


         // ********************************************************
         //  Setting a proxy (if you need it|)
         // ********************************************************
         // Some corporate networks require you to send HTTP requests
         // through a proxy server (and some do not!) If yours does,
         // you'll need to uncomment these lines and set the right
         // proxy for your network:

         // http_setproxy( 'your.proxy.com': 8080);

         //  If you use a corporate proxy, and it requires a userid/password
         //  you'll have to uncomment the following and set the user/pass
         //  accordingly.
         //
         //  http_proxy_setauth( HTTP_AUTH_BASIC: 'userid': 'password' );
         //

         // More proxy notes:
         //    -- proxy is only required if your network requires it.
         //    -- user/pass is only required if your network requires it,
         //         (you can use a proxy without a user/password by leaving
         //             http_proxy_setauth() commented out...)
         //    -- The parameters for the preceding routines can be set with
         //         variables in place of the constants if you prefer.
         //         it's up to you.


         // ********************************************************
         //   What do I want to get?   Where should I put it?
         // ********************************************************
         // The URL points to a place on the IIS on your remote
         //   desktop PC.
         // The IFS variable tells HTTPAPI where to put it on your
         //   local i5 computer.

         URL = 'http://' + Job_getTcpIpAddr() + '/index.html';

         IFS = debugLog + 'httpapi_example27.html';

         // Open output file
         fd = open(IFS: O_WRONLY + O_TRUNC + O_CREAT + O_CCSID: 511: 819);

         // Open persistent connection
         pComm = http_persist_open(URL);

         // Set credentials
         http_setauth(HTTP_AUTH_NTLM: user: password);

         dou '1';

            // Now call HTTPAPI's "GET" routine.  Pass the above
            //  variables as parameters.  It'll download it to the IFS!
            //
            // get web page the first time
            if ( http_persist_get(pComm: URL: fd: %paddr('write')) = -1);
               leave;
            endif;

            // and get it a second time
            if ( http_persist_get(pComm: URL: fd: %paddr('write')) = -1);
               leave;
            endif;

            // Close http connection
            http_persist_close(pComm);

         enddo;

         // Close output file
         callp close(fd);

         // ********************************************************
         //  Error handling...
         //
         //  http_url_get() returns 1 when successful.
         //
         //  if it's unsuccessful, you can call the http_error()
         //  routine to learn what went wrong.  In this example,
         //  the error is put in the 'msg' variable.  You would
         //  then add code to display it to a user, or write it
         //  to a log file, or whatever is appropriate.
         // ********************************************************

         if (rc <> 1);
            msg = http_error;
         endif;

         *inlr = *on;
      /end-free

      *===============================================================*
      *  Returns the IP address of the 5250 client of the
      *  specified job.
      *===============================================================*
     P Job_getTcpIpAddr...
     P                 B                   export
     D                 PI            15A          varying
      *
      *  Retrieve Job Information (QUSRJOBI) API
     D QUSRJOBI...
     D                 PR                  extpgm('QUSRJOBI')
     D  o_rcvVar                  65535A          options(*varsize)
     D  i_rcvVarLen                  10I 0 const
     D  i_format                      8A   const
     D  i_qJob                       26A   const
     D  i_intJobID                   16A   const
     D  io_errCode                65535A          options(*nopass: *varsize)    OptGrp 1
     D  i_resPrfStat                  1A   const  options(*nopass)              OptGrp 2
      *
     D qJob            DS                  qualified
     D  name                         10A   inz('*')
     D  user                         10A   inz
     D  nbr                           6A   inz
      *
     D jobi0600        DS                  qualified
     D  jobType               61     61A
     D  jobSubType            62     62A
     D  device               127    136A
      *
      *  Retrieve Device Description (QDCRDEVD) API
     D QDCRDEVD...
     D                 PR                         extpgm('QDCRDEVD')
     D  o_rcvVar                  65535A          options(*varsize)
     D  i_lenRcvVar                  10I 0 const
     D  i_format                      8A   const
     D  i_devName                    10A   const
     D  io_errCode                65535A          options(*varsize)

     D devd0600        DS          1024    qualified
     D  tcpIpDotAddr         878    892A

     D errCode         DS                  inz
     D  bytPrv                       10I 0
     D  bytAvl                       10I 0
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE
         QUSRJOBI(jobi0600:%size(jobi0600):'JOBI0600':qJob:'':errCode);
         QDCRDEVD(devd0600:%size(devd0600):'DEVD0600':jobi0600.device:errCode);
         return %trim(devd0600.tcpIpDotAddr);
      /END-FREE
     P                 E

