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
      * HTTPQSHR4 -- QShell interface to HTTPAPI
      *
      *  This program is intended to be called from a QShell command
      *  line or script.  In order for it to be functional, there
      *  should be a symbolic link between /usr/bin/httpapi and
      *  this RPG program.
      *
      *  If the symlink is missing, call this program with INSTALL
      *  as the first parameter, and the object library as the second.
      *
      *  For example:
      *   QSH CMD('/QSYS.LIB/LIBHTTP.LIB/HTTPQSHR4.PGM INSTALL LIBHTTP')
      */

      /copy VERSION

      /copy HTTPCMD_H
      /copy IFSIO_H
      /copy CONFIG_H

     D                 ds
     D  usagearr                           dim(27) ctdata
     D                                5a   overlay(usagearr:1)
     D  usagemsg                     65a   overlay(usagearr:6)

     D HTTPQSHR4       PR                  ExtPgm('HTTPQSHR4')
     D   p1                       65535a   options(*varsize)
     D   p2                       65535a   options(*varsize)
     D   p3                       65535a   options(*varsize)
     D   p4                       65535a   options(*varsize)
     D   p5                       65535a   options(*varsize)
     D   p6                       65535a   options(*varsize)
     D   p7                       65535a   options(*varsize)
     D   p8                       65535a   options(*varsize)
     D   p9                       65535a   options(*varsize)
     D   p10                      65535a   options(*varsize)
     D   p11                      65535a   options(*varsize)
     D   p12                      65535a   options(*varsize)
     D   p13                      65535a   options(*varsize)
     D   p14                      65535a   options(*varsize)
     D   p15                      65535a   options(*varsize)
     D HTTPQSHR4       PI
     D   p1                       65535a   options(*varsize)
     D   p2                       65535a   options(*varsize)
     D   p3                       65535a   options(*varsize)
     D   p4                       65535a   options(*varsize)
     D   p5                       65535a   options(*varsize)
     D   p6                       65535a   options(*varsize)
     D   p7                       65535a   options(*varsize)
     D   p8                       65535a   options(*varsize)
     D   p9                       65535a   options(*varsize)
     D   p10                      65535a   options(*varsize)
     D   p11                      65535a   options(*varsize)
     D   p12                      65535a   options(*varsize)
     D   p13                      65535a   options(*varsize)
     D   p14                      65535a   options(*varsize)
     D   p15                      65535a   options(*varsize)

     D option          PR             1n
     D   peArg                    65535a   varying const
     D   peOpt                       20a   varying const
     D   peVal                    32767a   varying options(*varsize)
     D   peSize                      10i 0 value
     D printError      PR
     D   inMsg                       80a   const
     D usage           PR
     D CEETREC         PR
     D   cel_rc_mod                  10i 0 const options(*omit)
     D   user_rc                     10i 0 const options(*omit)

     D FD_STDERR       c                   2

     D parmcount       s             10i 0
     D arg             s          65535a   varying
     D x               s             10i 0
     D rc              s             10i 0
     D URL             s          32767a   varying
     D cmd             s              7a   varying
     D type            s             64a   varying
     D                                     inz(HTTP_CONTTYPE)
     D user            s             80a   varying inz('*NONE')
     D pass            s           1024a   varying inz('*NONE')
     D proxy           s            256a   varying inz('*NONE')
     D proxyuser       s             80a   varying inz('*NONE')
     D proxypass       s           1024a   varying inz('*NONE')
     D debug           s            256a   varying inz('*NONE')
     D sslid           s            100a   varying inz('*DFT')
     D redir           s              4a   varying inz('Y')
     D upload          s          32767A   varying inz('-')
     D download        s          32767A   varying inz('*BASENAME')
     D cookies         s            256a   varying inz('*NONE')
     D sesscook        s              4a   varying inz('N')
     D errmsg          s             80a   varying inz('')
     D exitstatus      s             10i 0 inz(0)

      /free

       //-----------------------------------------------------------
       //  Interpret Parameters -- note that options can appear
       //   in any order, thus the funky looping..
       //-----------------------------------------------------------

       parmcount = %parms();
       if parmcount < 1;
          printError('Required parameter missing!');
          usage();
          CEETREC(*omit: 1);
          return;
       endif;

       for x = 1 to parmcount;

          select;
          when x = 1;
            arg = %str(%addr(p1));
          when x = 2;
            arg = %str(%addr(p2));
          when x = 3;
            arg = %str(%addr(p3));
          when x = 4;
            arg = %str(%addr(p4));
          when x = 5;
            arg = %str(%addr(p5));
          when x = 6;
            arg = %str(%addr(p6));
          when x = 7;
            arg = %str(%addr(p7));
          when x = 8;
            arg = %str(%addr(p8));
          when x = 9;
            arg = %str(%addr(p9));
          when x = 10;
            arg = %str(%addr(p10));
          when x = 11;
            arg = %str(%addr(p11));
          when x = 12;
            arg = %str(%addr(p12));
          when x = 13;
            arg = %str(%addr(p13));
          when x = 14;
            arg = %str(%addr(p14));
          when x = 15;
            arg = %str(%addr(p15));
          endsl;

          select;
          when x=1;
            cmd = %xlate('getposinal': 'GETPOSINAL': arg);

          when x = parmcount;
            URL = arg;

          when option(arg: 'redirect'   : redir     : %size(redir)    );
            redir = %xlate('yn':'YN':redir);

          when option(arg: 'user'       : user      : %size(user)     );
          when option(arg: 'type'       : type      : %size(type)     );
          when option(arg: 'pass'       : pass      : %size(pass)     );
          when option(arg: 'proxy'      : proxy     : %size(proxy)    );
          when option(arg: 'proxy-user' : proxyuser : %size(proxyuser));
          when option(arg: 'proxy-pass' : proxypass : %size(proxypass));
          when option(arg: 'debug'      : debug     : %size(debug)    );
          when option(arg: 'ssl-id'     : sslid     : %size(sslid)    );
          when option(arg: 'upload'     : upload    : %size(upload)   );
          when option(arg: 'download'   : download  : %size(download) );
          when option(arg: 'cookies'    : cookies   : %size(cookies)  );
          when option(arg: 'session-cookies': sesscook: %size(sesscook));
            sesscook = %xlate('yn':'YN':sesscook);

          other;
            printError('Unknown parameter: ' + arg);
            usage();
            CEETREC(*omit: 1);
            return;
          endsl;

       endfor;


       //-----------------------------------------------------------
       //  Verify that all needed parameters were passed
       //-----------------------------------------------------------

       select;
       when cmd = 'INSTALL';
       when cmd = 'GET';
          cmd = '*GET';
       when cmd = 'POST';
          cmd = '*POST';
       other;
          printError('Unknown cmd: ' + cmd);
          usage();
          CEETREC(*OMIT: 1);
          return;
       endsl;

       if %len(URL) < 5;
          printError('Invalid URL: ' + URL);
          usage();
          CEETREC(*omit: 1);
          return;
       endif;

       select;
       when redir='Y';
          redir='*YES';
       when redir='N';
          redir='*NO';
       other;
          printError('Invalid --redirect value.');
          usage();
          CEETREC(*omit: 1);
          return;
       endsl;

       select;
       when sesscook='Y';
          sesscook='*YES';
       when sesscook='N';
          sesscook='*NO';
       other;
          printError('Invalid --session-cookies value');
          usage();
          CEETREC(*omit: 1);
          return;
       endsl;


       //-----------------------------------------------------------
       //  Do an INSTALL Request (install the HTTPAPI symlink)
       //-----------------------------------------------------------

       if cmd = 'INSTALL';

           if access('/usr/bin': F_OK) = 0;
               if access('/usr/bin/httpapi': F_OK) = -1;
                    symlink( '/qsys.lib/'+URL+'.lib/httpqshr4.pgm'
                           : '/usr/bin/httpapi' );
               endif;
           endif;

           CEETREC(*omit: 0);
           return;

       endif;


       //-----------------------------------------------------------
       //  Do the POST/GET request
       //-----------------------------------------------------------

       monitor;
           HTTPCMDR4( URL
                    : download
                    : cmd
                    : upload
                    : type
                    : user
                    : pass
                    : redir
                    : proxy
                    : proxyuser
                    : proxypass
                    : debug
                    : sslid
                    : cookies
                    : sesscook
                    : errmsg
                    : exitstatus );
       on-error;
           errMsg = 'Error calling HTTPCMDR4. See job log.';
           exitStatus = 255 ;
       endmon;

       if (%len(errmsg)>0 and errmsg<>*blanks);
           printError(errmsg);
       endif;

       CEETREC(*OMIT: exitstatus);
       return;

      /end-free


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  option():  Parse a command-line option
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P option          B
     D option          PI             1n
     D   peArg                    65535a   varying const
     D   peOpt                       20a   varying const
     D   peVal                    32767a   varying options(*varsize)
     D   peSize                      10i 0 value
     D len             s             10i 0 static
     D size            s             10i 0 static
      /free
         len = %len(peOpt);
         if %len(peArg) >= (len+4)
            and %subst(peArg:1:2) = '--'
            and %subst(peArg:3:len) = peOpt
            and %subst(peArg:len+3:1) = '=';
                size = %len(%subst(peArg:len+4));
                if (size > (peSize-2));
                   size = peSize - 2;
                endif;
                peVal = %subst(peArg: len+4: size);
                return *on;
         else;
                return *off;
         endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  printError():  Print an error message to stderr
      *
      *    inMsg = (input) error message to print
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P printError      B
     D printError      PI
     D   inMsg                       80a   const
     D  msg            s             80a
     D msgno           s             10i 0

      /free
        msg = %trimr(inMsg) + x'25';
        callp write( FD_STDERR: %addr(msg): %len(%trimr(msg)));
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  usage(): Print command-line usage/syntax
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P usage           B
     D usage           PI
     D  msg            s             80a
     D x               s             10i 0
      /free
         for x = 1 to %elem(usagearr);
            msg = %trimr(usagemsg(x)) + x'25';
            callp write( FD_STDERR: %addr(msg): %len(%trimr(msg)));
         endfor;
      /end-free
     P                 E

**
     Usage:  httpapi get [OPTIONS] URL
2            httpapi post [OPTIONS] URL
3
4    options are:
5         --user=USERID             Specify UserID
6         --pass=PASSWORD           Specify Password
7         --type=CONTENTTYPE        MIME content type of POST
8                                     (ignored when GET)
9         --redirect=Y/N            Do/don't follow redirects
10                                    (default=Y)
11        --proxy=HOST[:PORT]       specify a proxy to use
12        --proxy-user=USERID       specify a userid
13                                    to use with the proxy.
14        --proxy-pass=PASSWORD     specify a password
15                                    to use with the proxy.
16        --debug=FILE              write debug info to FILE
17        --ssl-id=APP_ID           application ID profile
18                                    to associate with DCM
          --upload=FILE             file to upload in a POST
                                      request. (dft=stdin)
          --download=FILE           filename in which to save
                                      response. (-=stdout,
                                      dft=name in URL)
          --cookies=FILE            filename in which to save
                                      cookies (dft=reject all cookies)
          --session-cookies=Y/N     should session cookies be
                                      saved to cookies file?
