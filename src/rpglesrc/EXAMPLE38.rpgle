      * EXAMPLE38:
      * ----------
      * This example shows how to call a web service that is hosted
      * by your IIS on your remote desktop PC. The authentication
      * mechanism used is NTLM, which is the default for IIS
      * servers.
      *
      * The program uses a persistent connection to call the web
      * service twice.
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
      *    http_persist_post()
      *    http_persist_close()
      *
      *    http_parser_init()
      *    http_parser_parseChunk()
      *    http_parser_free()
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

     D example38       PR                  extpgm('EXAMPLE38')
     D  i_user                       32A   const
     D  i_password                   32A   const
     D  i_debugLog                   32A   const

     D EndOfElement    PR
     D  i_UserData                     *   value
     D  i_depth                      10I 0 value
     D  i_name                     1024A   varying const
     D  i_path                    24576A   varying const
     D  i_value                   65535A   varying const
     D  i_attrs                        *   dim(32767)
      *
      *  Sends a message to QCMD
     D sndMsg...
     D                 PR                         extproc('sndMsg')
     D  i_text                      128A   value  varying

     D example38       PI
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
     D postData        S            512A   inz varying
     D userData        DS                  likeds(userData_t ) inz
      *
     D userData_t      DS                  qualified  based(pDummy)
     D  srvType                      10A   varying
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
         http_debug(*ON: debugLog + 'httpapi_example38.log');


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
         // The URL first points to a welcome page on the IIS on your remote
         //   desktop PC.
         // The IFS variable tells HTTPAPI where to put it on your
         //   local i5 computer.
         // Then the URL is changed to point to a web service on the IIS on
         //   your remote desktop PC.

         IFS = debugLog + 'httpapi_example38.html';

         // Open output file
         fd = open(IFS: O_WRONLY + O_TRUNC + O_CREAT + O_CCSID: 511: 819);

         postData =
            '<soapenv:Envelope +
                xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" +
                xmlns:tem="http://tempuri.org/">+
                <soapenv:Header/>+
                <soapenv:Body>+
                   <tem:HelloWorld/>+
                </soapenv:Body>+
             </soapenv:Envelope>';

         dou '1';

            // Set first URL to GET the welcome page.
            URL = 'http://' + Job_getTcpIpAddr() + '/index.html';

            // Open persistent connection
            pComm = http_persist_open(URL);

            // Set credentials
            http_setauth(HTTP_AUTH_NTLM: user: password);

            // Now call HTTPAPI's "GET" routine.
            //  It'll download the welcome page to the IFS.
            rc = http_persist_get( pComm: URL: fd: %paddr('write'));
            if ( rc <> 1);
               sndMsg('Could not download welcome page');
               leave;
            endif;

            sndMsg('Welcome page save to: ' + IFS);

            // Initialize XML parser
            http_parser_init(
                  *omit: *null: %paddr(EndOfElement): %addr(userData));

            // Then call HTTPAPI's "POST" routine.  Pass the above
            //  variables as parameters.  It'll call the web service and
            //  parse the result.
            URL = 'http://' + Job_getTcpIpAddr() + '/HelloWorld.asmx';
            userData.srvType = 'good';
            rc = http_persist_post( pComm: URL: 0: *null
                                  : %addr(postData)+2: %len(postData)
                                  : 0: %paddr(http_parser_parseChunk));

            if ( rc <> 1);
               http_parser_free(*off);   // Free the parser in case of an error.
               sndMsg('Failed to call ''' + userData.srvType +
                      ''' web service at: ' + URL);
               leave;
            endif;

            // Now call HTTPAPI's "POST" routine.  Pass the above
            //  variables as parameters.  It'll produce an error
            //  because of an invalid URL.
            URL = 'http://' + Job_getTcpIpAddr() + '/HelloWorld.error';
            userData.srvType = 'bad';
            rc = http_persist_post( pComm: URL: 0: *null
                                  : %addr(postData)+2: %len(postData)
                                  : 0: %paddr(http_parser_parseChunk));
            if ( rc <> 1);
               http_parser_free(*off);   // Free the parser in case of an error.
               sndMsg('Failed to call ''' + userData.srvType +
                      ''' web service at: ' + URL);
               leave;
            endif;

            http_parser_free(*on);

         enddo;

         // Close http connection
         http_persist_close(pComm);

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
            sndMsg(msg);
         endif;

         *inlr = *on;
      /end-free

      *===============================================================*
      *  End-Of-Element callback procedure, used by eXpat parser.
      *===============================================================*
     P EndOfElement...
     P                 B
     D                 PI
     D  i_UserData                     *   value
     D  i_depth                      10I 0 value
     D  i_name                     1024A   varying const
     D  i_path                    24576A   varying const
     D  i_value                   65535A   varying const
     D  i_attrs                        *   dim(32767)
      *
     D userData        DS                  likeds(userData_t) based(i_UserData)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_path = '/soap:Envelope/soap:Body/HelloWorldResponse');
            if (i_name = 'HelloWorldResult');
               sndMsg('Response of ''' + userData.srvType +
                      ''' web service is: ' + i_value);
            endif;
         endif;

         return;

      /END-FREE
     P                 E

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
      *
      *===============================================================*
      *  *** private ***
      *  Sends a message to the caller.
      *===============================================================*
     P sndMsg...
     P                 B
      *
     D sndMsg...
     D                 PI
     D  i_text                      128A   value  varying
      *
      *  Return value
     D pBuffer         S               *   inz
      *
      *  Local fields
     D msgKey          S              4A                        inz
      *
     D qMsgF           DS                  qualified            inz
     D  name                         10A
     D  lib                          10A
      *
     D errCode         DS                  qualified            inz
     D  bytPrv                       10I 0
     D  bytAvl                       10I 0
     D  excID                         7A
     D  reserved                      1A
     D  excDta                      256A
      *
      *  Send Program Message (QMHSNDPM) API
     D QMHSNDPM        PR                         extpgm('QMHSNDPM')
     D   i_msgID                      7A   const
     D   i_qMsgF                     20A   const
     D   i_msgData                32767A   const  options(*varsize )
     D   i_length                    10I 0 const
     D   i_msgType                   10A   const
     D   i_callStkE               32767A   const  options(*varsize )
     D   i_callStkC                  10I 0 const
     D   o_msgKey                     4A
     D   io_ErrCode               32767A          options(*varsize )
     D   i_lenStkE                   10I 0 const  options(*nopass  )
     D   i_callStkEQ                 20A   const  options(*nopass  )
     D   i_wait                      10I 0 const  options(*nopass  )
     D   i_callStkEDT                10A   const  options(*nopass  )
     D   i_ccsid                     10I 0 const  options(*nopass  )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         clear qMsgF;
         qMsgF.name = 'QCPFMSG';
         qMsgF.lib  = '*LIBL';

         clear errCode;
         errCode.bytPrv = %size(errCode);

         QMHSNDPM('CPF9897': qMsgF: i_text: %len(i_text): '*INFO'
                  : '*CTLBDY': 1
                  : msgKey: errCode);

         return;

      /END-FREE
      *
     P sndMsg...
     P                 E

