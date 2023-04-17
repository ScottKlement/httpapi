      * THE STORY:
      * ----------
      * HTTPAPI is a tool designed to help work with the HTTP protocol
      * in ILE RPG (and possibly other languages). The members named
      * EXAMPLE are intended to teach you the basics of using HTTPAPI.
      * when you are done with this member, please proceed to EXAMPLE2.
      *
      * EXAMPLE1:
      * ----------
      * This first example will demonstrate how to connect to a web
      * address (called a "URL") and download data from that web server.
      * The network protocol that web servers speak is called "HTTP".
      *
      * HTTPAPI does not try to be a web browser. It has no idea what
      * data it's downloading, or how to display it.  It only knows
      * how to retrieve data and store it somewhere.
      *
      * EXAMPLE1 will download a PDF document (though, any type of
      * document should work) and save it to a file in the IFS.
      *
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO)
      /endif
     H BNDDIR('HTTPAPI')

      /copy httpapi_h

      * Note: The BNDDIR, above, tells ILE how to find the HTTPAPIR4
      *       service program which contains the routines.
      *       The /COPY directive provides prototypes and constants
      *       needed to call the routines.

     D rc              s             10I 0
     D msg             s             52A
     D URL             S            300A    varying
     D IFS             S            256A    varying

      *********************************************************
      *  Turning on debugging.
      *
      *     Calling http_debug and passing *ON will turn on
      *     HTTPAPI's debugging support.  It will write a debug
      *     log file to the IFS in /tmp/httpapi_debug.txt
      *     with loads of tech info about the HTTP transaction.
      *
      *     The debug file is crucial if you have problems!
      *********************************************************
     c                   callp     http_debug(*ON)


      *********************************************************
      *  Setting a proxy (if you need it!)
      *********************************************************
     C* Some corporate networks require you to send HTTP requests
     C* through a proxy server (and some do not!) If yours does,
     C* you'll need to uncomment these lines and set the right
     C* proxy for your network:
     C*
     c****               callp     http_setproxy( 'proxy.example.com'
     c****                                      : 8080 )

     C* If you use a corporate proxy, and it requires a userid/password
     C* you'll have to uncomment the following and set the user/pass
     C* accordingly.
     c*
     C****               callp     http_proxy_setauth( HTTP_AUTH_BASIC
     C****                                           : 'userid'
     C****                                           : 'password' )

     C* More proxy notes:
     C*    -- proxy is only required if your network requires it.
     C*    -- user/pass is only required if your network requires it,
     C*         (you can use a proxy without a user/password by leaving
     C*             http_proxy_setauth() commented out...)
     C*    -- The parameters for the preceding routines can be set with
     C*         variables in place of the constants if you prefer.
     C*         it's up to you.


      *********************************************************
      *  What do I want to get?   Where should I put it?
      *********************************************************
     C* The URL points to a place on Scott's web site where
     C*   he has a PDF file.
     C* The IFS variable tells HTTPAPI where to put it on your
     C*   local computer.

     c                   eval      URL = 'http://www.scottklement.com'
     c                                 + '/presentations/'
     c                                 + 'Web Services from RPG with '
     c                                 + 'HTTPAPI.pdf'

     c                   eval      IFS = '/tmp/Scott''s HTTPAPI '
     c                                 + 'presentation handout.pdf'

     C* Now call HTTPAPI's routine that receives to a stream file
     C*  with the above variables as parameters. It will download
     C*  to the IFS.
     C*
     c                   callp     http_stmf('GET': URL: IFS)

     c                   eval      *inlr = *on
