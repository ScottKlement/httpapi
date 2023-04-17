      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP('KLEMENT')
      /endif
     H BNDDIR('HTTPAPI')

      *  Example of using the html2pdf RESTful web service to create
      *  a PDF document for a given web site
      *
      *  To compile:
      *   * Make sure HTTPAPI is installed and in your *LIBL
      *   *> CRTBNDRPG EXAMPLE9 SRCFILE(QRPGLESRC)
      *   *> CRTCMD CMD(EXAMPLE9) SRCFILE(QCMDSRC) -
      *   *>        PGM(EXAMPLE9)
      *
      *  To run, use the *CMD interface.
      *
      *    EXAMPLE9 URL('http://www.google.com')
      *             STMF('/tmp/google.pdf')
      *
      *
      *  More info on this web service is here:
      *    http://www.html2pdf.biz/api.php
      *
      *  NOTE: This web service is usually very slow. They claim
      *        to offer a better service if you pay for their
      *        commercial edition.  (I haven't tried it.  See
      *        the link, above, for details.)
      *

      /define WEBFORMS
      /copy httpapi_h

     D EXAMPLE9        PR                  ExtPgm('EXAMPLE5')
     D   inputURL                  5000a   varying const
     D   outputStmf                5000a   varying const
     D   outputFormat                 5a   const
     D EXAMPLE9        PI
     D   inputURL                  5000a   varying const
     D   outputStmf                5000a   varying const
     D   outputFormat                 5a   const

     D uri             s           5050a   varying
     D form            s                   like(WEBFORM)
     D rc              s             10i 0

      /free
         http_debug(*on: '/tmp/example9-debug.txt');

         if %parms < 3;
            http_comp('To call, type: +
         EXAMPLE9 URL(''http://google.com'') STMF(''/tmp/google.pdf'')');
            return;
         endif;

         // -----------------------------------------------
         //  service takes 2 parameters:
         //    'url' = the URL of the web site to convert
         //    'ret' = output format. (pdf, json or png)
         // -----------------------------------------------

         form = webform_open();
         webform_setVar(form: 'url': inputURL);
         webform_setVar(form: 'ret': %trimr(%subst(outputFormat:2)));
         uri = 'http://html2pdf.biz/api?' + webform_getData(form);
         webform_close(form);

         // -----------------------------------------------
         //  service will send a redirect (301 or 302) to tell
         //  you where to get the file...
         //
         //  Note: The third parameter to http_url_get()
         //        is the "timeout" parameter. Because this
         //        site is slow, I've overridden it to 300
         //        seconds (= 5 minutes)
         // -----------------------------------------------

         dou (rc<>301 and rc<>302);
            rc = http_url_get(uri: outputStmf: 300);
            if (rc=301 or rc=302);
               uri = http_redir_loc();
            endif;
         enddo;

         if (rc <> 1);
           http_crash();
         endif;

         *inlr = *on;
      /end-free
