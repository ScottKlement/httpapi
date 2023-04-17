      * THE STORY SO FAR:
      * -----------------
      *  EXAMPLE1 showed the basics of downloading a file with HTTP
      *
      * EXAMPLE2:
      * ----------
      *  This builds on EXAMPLE1, adding some bells and whistles.
      *  (ding-ding, toot-toot).  I will not re-explain what I put
      *  in EXAMPLE1 but instead will explain the following
      *  enhancements:
      *      - How to use the "user agent" parameter.
      *      - How to use the "time out" parameter.
      *      - How to display download progress
      *
      *  For more details, see the comments, below.
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO)
      /endif
     H BNDDIR('HTTPAPI')

      /copy httpapi_h

     D my_procedure    PR
     D   Received                    10u 0 value
     D   Total                       10u 0 value

     D agent           s             64a
     D rc              s             10I 0
     D URL             S            300A    varying
     D IFS             S            256A    varying
     D timeout         s             10i 0
     D msg             s             80a

     c                   callp     http_debug(*ON)


     c****               callp     http_setproxy( 'proxy.example.com'
     c****                                      : 8080 )
     C****               callp     http_proxy_setauth( HTTP_AUTH_BASIC
     C****                                           : 'userid'
     C****                                           : 'password' )

     c                   eval      URL = 'http://www.scottklement.com'
     c                                 + '/presentations/'
     c                                 + 'Web Services from RPG with '
     c                                 + 'HTTPAPI.pdf'
     c                   eval      IFS = '/tmp/Scott''s HTTPAPI '
     c                                 + 'presentation handout.pdf'


      * Some sites get upset if you're not running Internet Explorer
      * The "user agent" parameter specifies a string that tells the
      * site which "browser" we are.  With the following string, the
      * site will think we're IE 8 running on Windows :)
      *
     c                   eval      agent = 'Mozilla/4.0 (compatible; +
     c                                      MSIE 8.0; +
     c                                      Windows NT 5.1; +
     c                                      Trident/4.0)'

      *
      * The default user agent for HTTPAPI is 'http-api/x.xx' (where
      * (x.xx is the version number).  A named constant, HTTP_USERAGENT
      * will always contain the default user agent
      *

      * Likewise, you can control timeouts.  If the network stops
      * responding, how long should HTTPAPI wait before it gives
      * up?  The default value is 60 seconds and is defined by
      * the constant HTTP_TIMEOUT -- but you can override this
      * if you like and specify your own...
      *
     c                   eval      Timeout = 30


      * Some of HTTPAPI's functions are implemented through "exit
      * procedures" (callback routines).  In this example, I want
      * to display the progress of downloading the PDF document.
      *
      * An exit procedure is a routine that *you* write, but HTTPAPI
      * calls when a certain "thing" happens.  In this case, each
      * time more bytes are received over the wire, I want HTTPAPI
      * to give me an updated byte count... that way I can tell the
      * user how much I've downloaded.
      *
      * To do that, I ask RPG where my subprocedure is stored in memory
      * using the %paddr() built-in function. Then, I tell HTTPAPI
      * the location in memory, so it can call it.
      *
     c                   callp     http_xproc( HTTP_POINT_DOWNLOAD_STATUS
     c                                       : %paddr(my_procedure) )


      *  okay... lets do this thing!
      *
     c                   callp     http_setOption('user-agent': agent)
     c                   callp     http_setOption('timeout': %char(timeout))


      *  http_stmf() will send an error message if something goes wrong
      *      so we can MONITOR for that, like any other error.
      *  http_error() can retrieve the error message into a variable

     c                   monitor
     c                   callp     http_stmf('GET': URL: IFS)
     c                   on-error
     c                   eval      msg = http_error()
     c                   endmon

      *
      * HTTPAPI provides a routine named http_comp() that displays
      * a completion message (like SNDPGMMSG MSGTYPE(*COMP) in CL)
      * this is an easy way to show what happened:
      *
     c                   if        msg = *blanks
     c                   callp     http_comp('Success!')
     c                   else
     c                   callp     http_comp(msg)
     c                   endif

     c                   eval      *inlr = *on


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * my_procedure():  Called by HTTPAPI to display the
      *                  download status.
      *
      * NOTE: HTTPAPI has to stop receiving to call this
      *       routine. So make it run fast, so it doesn't
      *       slow down the transfer!
      *
      * NOTE: The QMHSNDPM API is an IBM-supplied routine to
      *       send a program message (similar to CL SNDPGMMSG
      *       command)
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P my_procedure    B
     D my_procedure    PI
     D   Received                    10u 0 value
     D   Total                       10u 0 value

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                    8a   const

     D Msg             s             52a
     D Pct             s              3s 1
     D Key             s              4a

     c                   eval      Pct = (Received*100) / Total

     c                   eval      msg = 'Received '
     C                                 + %trim(%editc(Received:'P'))
     C                                 + ' of '
     C                                 + %trim(%editc(Total:'P'))
     C                                 + ' (' +%trim(%editc(Pct:'P'))+ '%)'

     c                   callp     QMHSNDPM( 'CPF9897'
     c                                     : 'QCPFMSG   *LIBL'
     c                                     : msg
     c                                     : %size(msg)
     c                                     : '*STATUS'
     c                                     : '*EXT'
     c                                     : 0
     c                                     : Key
     c                                     : x'00000000' )
     P                 E
