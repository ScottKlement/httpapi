     /*-                                                                            +
      * Copyright (c) 2008-2023 Scott C. Klement                                    +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms, with or without          +
      * modification, are permitted provided that the following conditions          +
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice, this list of conditions and the following disclaimer.            +
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice, this list of conditions and the following disclaimer in the      +
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ''AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +

     /*
      * HTTPCMDR4 -- Command-line & CL interface to HTTPAPI
      *   (also serves as a back-end to the QSH interface)
      *
      *  This program is intended to be called via the HTTPAPI
      *  command, or the httpapi QShell command. Please don't
      *  call it directly.
      */

      /copy VERSION

      /copy ifsio_h
      /copy httpapi_h
      /copy errno_h
      /copy httpcmd_h
      /copy private_h

     D HTTPCMDR4       PI
     D   peUrl                    32767a   varying const
     D   peDownload                 256a   varying const
     D   peReqType                    5a           const
     D   peUpload                   256a   varying const
     D   peType                      64a   varying const
     D   peUser                      80a   varying const
     D   pePass                    1024a   varying const
     D   peRedir                      4a           const
     D   peProxy                    256a   varying const
     D   peProxyUser                 80a   varying const
     D   peProxyPass               1024a   varying const
     D   peDebug                    256a   varying const
     D   peSSLID                    100a   varying const
     D   peCookies                  256a   varying const
     D   peSessCook                   4a           const
     D   peErrMsg                    80a   varying options(*nopass)
     D   peExitSts                   10i 0         options(*nopass)

     D printError      PR
     D   inMsg                       80a   const options(*nopass)
     D memwriter       PR            10i 0
     D   fd                          10i 0 value
     D   data                     65535a   options(*varsize)
     D   len                         10u 0 value
     D memreader       PR            10i 0
     D   fd                          10i 0 value
     D   data                     65535a   options(*varsize)
     D   len                         10u 0 value
     D readupload      PR            10i 0
     D   fd                          10i 0 value
     D cleanup         PR
     D   exitstatus                  10i 0 value
     D basename        PR         32767a   varying
     D   pathname                 32767a   varying const

     D FD_STDIN        c                   0
     D FD_STDOUT       c                   1

     D memdata         s               *   inz(*null)
     D memlen          s             10i 0 inz(0)
     D memalloc        s             10i 0 inz(0)
     D upldata         s               *   inz(*null)
     D upllen          s             10i 0 inz(0)
     D uplleft         s             10i 0 inz(0)
     D upl             s          65535a   based(uplpos)

     D reqtype         s              5a
     D uploadfd        s             10i 0 inz(-1)
     D downloadfd      s             10i 0 inz(-1)
     D x               s             10i 0
     D rc              s             10i 0
     D URL             s          32767a   varying
     D type            s             64a   varying
     D                                     inz(HTTP_CONTTYPE)
     D user            s             80a   varying
     D pass            s           1024a   varying
     D proxy           s            256a   varying
     D proxyport       s             10i 0 inz(8080)
     D proxyuser       s             80a   varying
     D proxypass       s           1024a   varying
     D debug           s            256a   varying
     D sslid           s            100a   varying
     D redir           s              4a   varying inz('*YES')
     D upload          s          32767A   varying inz('-')
     D download        s          32767A   varying inz('-')
     D cookies         s            256a   varying
     D sesscook        s              1n   inz(*OFF)
     D inputlen        s             10i 0
     D pos             s             10i 0
     D RTN_ERROR       s              1n   inz(*OFF)
     D LastMsg         s             80a   varying

      /free

       //-----------------------------------------------------------
       //  Interpret Parameters
       //-----------------------------------------------------------

       if %parms < 15;
          printError('Parameter mismatch');
          cleanup(1);
          return;
       endif;
       if %parms >= 17;
          RTN_ERROR = *ON;
       endif;

       url      = %trim(peURL);
       reqtype  = %xlate('getpos':'GETPOS':peReqType);
       redir    = %xlate('yesno':'YESNO':peRedir);
       type     = peType;

       if (peDownload = '*BASENAME');
          download = basename(url);
       else;
          download = %trim(peDownload);
       endif;

       if (peUpload = '*NONE');
          upload = '';
       else;
          upload = %trim(peUpload);
       endif;

       if (peUser = '*NONE');
          user='';
       else;
          user = %trim(peUser);
       endif;

       if (pePass = '*NONE');
          pass='';
       else;
          pass = %trim(pePass);
       endif;

       if (peProxy = '*NONE');
          proxy='';
       else;
          proxy = %trim(peProxy);
       endif;

       if (peProxyUser = '*NONE');
          proxyuser='';
       else;
          proxyuser = %trim(peProxyUser);
       endif;

       if (peProxyPass = '*NONE');
          proxypass='';
       else;
          proxypass = %trim(peProxyPass);
       endif;

       if (peDebug = '*NONE');
          debug = '';
       else;
          debug = %trim(peDebug);
       endif;

       if (peSSLID = '*DFT');
          sslid = '';
       else;
          sslid = %trim(peSSLID);
       endif;

       if (peCookies = '*NONE');
          cookies = '';
       else;
          cookies = %trim(peCookies);
       endif;

       if (peSessCook = '*YES');
          sesscook = *ON;
       endif;


       //-----------------------------------------------------------
       //  Verify that all needed parameters were passed
       //-----------------------------------------------------------

       if ( peReqType <> '*GET'
            and peReqType <> '*POST' );
          printError('Unknown request type: ' + peReqType);
          cleanup(1);
          return;
       endif;

       if %len(%trim(peURL)) < 5;
          printError('Invalid URL: ' + URL);
          cleanup(1);
          return;
       endif;

       if peRedir<>'*YES' and peRedir<>'*NO';
          printError('Invalid redirect value.');
          cleanup(1);
          return;
       endif;

       if peSessCook<>'*YES' and peSessCook<>'*NO';
          printError('Invalid SESSCOOK value.');
          cleanup(1);
          return;
       endif;


       //-----------------------------------------------------------
       //  Set options specified by the parameters.
       //-----------------------------------------------------------

       if %len(debug)>0;
          http_debug(*ON:debug);
       endif;

       if %len(cookies)>0;
          http_cookie_file(cookies:sesscook);
       endif;

      /if defined(HAVE_SSLAPI)
       if %len(sslid)>0;
          https_init(sslid);
       endif;
      /endif

       if %len(user)>0 or %len(pass)>0;
          http_setauth( HTTP_AUTH_BASIC : user: pass);
       endif;

       if %len(proxy)>0;
          pos = %scan(':': proxy);
          if (pos>1 and pos<%len(proxy) );
             proxyport = atoi(%subst(proxy:pos+1));
             proxy     = %subst(proxy:1:pos-1);
          endif;
          if http_setproxy(proxy:proxyport) = -1;
             printError();
             cleanup(2);
             return;
          endif;
       endif;

       if %len(proxyuser)>0 or %len(proxypass)>0;
          if http_proxy_setauth( HTTP_AUTH_BASIC
                               : proxyuser
                               : proxypass ) = -1;
             printError();
             cleanup(2);
             return;
          endif;
       endif;

       if peReqType = '*POST';
          if upload='-';
             uploadfd = -1;
          else;
             uploadfd = open( %trimr(upload) : O_RDONLY );
             if uploadfd = -1;
                printError( %trimr(upload) + ': '
                          + %str(strerror(errno)) );
                cleanup(3);
                return;
             endif;
          endif;
       endif;

       if download='-';
          downloadfd = FD_STDOUT;
       else;
          downloadfd = open( %trimr(download)
                           : O_WRONLY + O_CREAT + O_TRUNC + O_CCSID
                           : HTTP_IFSMODE
                           : HTTP_CCSID );
          if downloadfd = -1;
             printError( %trimr(download) + ': '
                       + %str(strerror(errno)) );
             cleanup(3);
             return;
          endif;
       endif;


       //-----------------------------------------------------------
       //  Do the POST/GET request
       //-----------------------------------------------------------

       if peReqType='*GET';
           rc = http_url_get_raw( URL
                                : downloadfd
                                : %paddr(memwriter) );
       else;
           readupload(uploadfd);
           rc = http_url_post_raw2( URL
                                  : uploadfd
                                  : %paddr(memreader)
                                  : upllen
                                  : downloadfd
                                  : %paddr(memwriter)
                                  : HTTP_TIMEOUT
                                  : HTTP_USERAGENT
                                  : type );
       endif;


       //-----------------------------------------------------------
       //  Handle any redirects.
       //-----------------------------------------------------------

       if redir='*YES' and (rc=302 or rc=303);

          x=0;
          dou (rc<>302 and rc<>303) or x=5;
             memlen = 0;
             rc = http_url_get_raw( http_redir_loc()
                                  : downloadfd
                                  : %paddr(memwriter) );
             x = x + 1;
          enddo;

          if (rc=302 or rc=303);
             printError('More than five redirects.');
             cleanup(4);
             return;
          endif;

       endif;


       //-----------------------------------------------------------
       //  Check for errors
       //-----------------------------------------------------------

       if rc = 1 or rc>=200 and rc<300;
          // success!
       else;
          printError();
          cleanup(5);
          return;
       endif;

       if (memlen > 0);
          if downloadfd = -1;
             callp write( FD_STDOUT: memdata: memlen);
          else;
             callp write( downloadfd: memdata: memlen);
          endif;
       endif;

       cleanup(0);
       return;

      /end-free


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  printError():  Set an error message
      *
      *    inMsg = (input/optional) error message to print
      *              if not given, the msg will be retrieved
      *              by calling http_error()
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P printError      B
     D printError      PI
     D   inMsg                       80a   const options(*nopass)
     D  msg            s             80a
     D msgno           s             10i 0

      /free
        if %parms>= 1;
           msg = %trimr(inMsg) + x'25';
        else;
           msg = http_error(msgno);
           msg = %char(msgno) + ' ' + msg + x'25';
        endif;

        LastMsg = msg;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  memwriter(): Write HTTP response into memory
      *
      *  the memory addressed by the "memdata" pointer is intended
      *  to automatically "grow" in size as needed to store the
      *  received data.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P memwriter       B
     D memwriter       PI            10i 0
     D   fd                          10i 0 value
     D   data                     65535a   options(*varsize)
     D   len                         10u 0 value

     D CHUNK_SIZE      c                   131072

     D newlen          s             10i 0 static
     D newdata         s          65535a   based(p_newdata)
      /free
         newlen = memlen + len;

         dow (newlen > memalloc);
            memalloc = memalloc + CHUNK_SIZE;
            if (memdata = *null);
               memdata = TS_malloc(memalloc);
            else;
               memdata = TS_realloc(memdata: memalloc);
            endif;
         enddo;

         p_newdata = memdata + memlen;
         %subst(newdata:1:len) = %subst(data:1:len);
         memlen = newlen;

         return len;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  memreader(): Read POST data from memory
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P memreader       B
     D memreader       PI            10i 0
     D   fd                          10i 0 value
     D   data                     65535a   options(*varsize)
     D   len                         10u 0 value
      /free

         if (len >= uplleft);
            len = uplleft;
            %subst(data:1:len) = %subst(upl:1:len);
            uplleft = 0;
         else;
            %subst(data:1:len) = %subst(upl:1:len);
            uplleft = uplleft - len;
            uplpos  = uplpos  + len;
         endif;

         return len;
      /end-free
     P                 E



      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  readupload(): Read all of upload file into memory
      *
      *  the memory addressed by the "memdata" pointer is intended
      *  to automatically "grow" in size as needed to store the
      *  received data.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P readupload      B
     D readupload      PI            10i 0
     D   fd                          10i 0 value

     D savememdata     s                   like(memdata)
     D savememlen      s                   like(memlen)
     D savememalloc    s                   like(memalloc)

     D buf             s          65535a
     D newlen          s             10i 0 static
      /free
         if (fd = -1);
            fd = FD_STDIN;
         endif;

         savememdata  = memdata;
         savememlen   = memlen;
         savememalloc = memalloc;

         memdata      = *null;
         memlen       = 0;
         memalloc     = 0;

         newlen = read(fd: %addr(buf): %size(buf));
         dow newlen > 0;
           memwriter(fd: buf: newlen);
           newlen = read(fd: %addr(buf): %size(buf));
         enddo;

         upldata  = memdata;
         uplpos   = memdata;
         upllen   = memlen;
         uplleft  = memlen;
         memdata  = savememdata;
         memlen   = savememlen;
         memalloc = savememalloc;

         return upllen;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  cleanup():  Clean up any open resources before ending
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cleanup         B
     D cleanup         PI
     D   exitstatus                  10i 0 value

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                     80A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A   const
     D   ErrorCode                    8a   const
      /free

         if uploadfd <> -1;
            callp close(uploadfd);
         endif;

         if downloadfd <> -1;
            callp close(downloadfd);
         endif;

         if memdata <> *null;
            TS_free(memdata);
         endif;

         if upldata <> *null;
            TS_free(upldata);
         endif;

         select;
         when RTN_ERROR = *ON;
            peErrMsg  = lastMsg;
            peExitSts = exitStatus;
         when exitStatus <> 0
           and %len(lastMsg) > 0;
            QMHSNDPM( 'CPF9897'
                    : 'QCPFMSG   *LIBL'
                    : lastMsg
                    : %len(lastMsg)
                    : '*ESCAPE'
                    : '*PGMBDY'
                    : 1
                    : *blanks
                    : x'0000000000000000');
         endsl;

         *INLR = *ON;
         return;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  basename(): Remove directory/prefix from filename
      *
      *     pathname = (input) IFS pathname to get basename of
      *
      * returns '' if no path, or only directories, provided.
      *         else returns the basename
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P basename        B
     D                 PI         32767a   varying
     D   pathname                 32767a   varying const

     D pos             s             10i 0 inz(0)
     D str             s             10i 0 inz(-1)
     D result          s          32767a   varying
      /free
       if %len(pathname) > 0;
          dou pos=0 or pos>=%len(pathname);
             pos = %scan('/': pathname: pos+1);
             if (pos>0 and pos<%len(pathname));
                str = pos + 1;
             endif;
          enddo;
       endif;
       if str = -1;
          return '';
       endif;
       result = %subst(pathname:str);
       dow %len(result)>0 and %subst(result:%len(result):1)='/';
         %len(result) = %len(result) - 1;
       enddo;
       if %len(result)=0 or result=*blanks;
          return '';
       endif;
       return result;
      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h
