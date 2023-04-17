      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP(*NEW)
      /endif
     H BNDDIR('HTTPAPI')

     D/copy httpapi_h

     D status          PR
     D   BytesRecv                   10U 0 value
     D   BytesTotal                  10U 0 value

     D rc              s             10I 0
     D msg             s             52A

     c                   eval      *inlr = *on

     C* Register our "STATUS" procedure as the procedure for HTTPAPI
     C* to call to tell us about the download progress...
     C*
     c                   if        HTTP_xproc(HTTP_POINT_DOWNLOAD_STATUS:
     c                                        %paddr('STATUS')) < 0
     c                   eval      msg = http_error
     c                   dsply                   msg
     c                   endif

     C* Retrieve Scott Klement's sockets tutorial:

     c                   eval      rc = http_url_get(
     c                             'http://www.scottklement.com/rpg/'+
     c                             'socktut/tutorial.pdf':
     c                             '/tmp/sock_tutorial.pdf')

     c                   if        rc <> 1
     c                   eval      msg = http_error
     c                   dsply                   msg
     c                   endif

     c                   eval      *inlr = *on


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Because we registered it (above) HTTPAPI will call this proc
      *  each time more data is received from the HTTP server.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P status          B
     D status          PI
     D   BytesRecv                   10U 0 value
     D   BytesTotal                  10U 0 value

     D LastPct         s              3P 0 static
     D Pct             s              3P 0
     D Msg             s             52A

      ** When using the "chunked" encoding, the web server will not
      ** tell us the full file size, so we can only display "bytes received"
     c                   if        BytesTotal = 0
     c                   eval      Msg = %trim(%editc(BytesRecv:'P'))
     c                                 + ' bytes have been received'
     c     Msg           dsply
     c                   return
     c                   endif

      **
      **  When chunked encoding is not used, we'll display a percent
      **
     c                   eval(h)   Pct = (BytesRecv*100) / BytesTotal

     c                   if        Pct <> LastPct
     c                   eval      Msg = 'Download is '
     c                                 + %trim(%editc(Pct:'P'))
     c                                 + '% completed.'
     c     Msg           dsply
     c                   eval      LastPct = Pct
     c                   endif

     P                 E
