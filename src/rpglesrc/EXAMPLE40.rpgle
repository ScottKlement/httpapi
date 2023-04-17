      * This example demonstrates posting multipart/related to a
      * web server.
      *
      * It is intended to call a SOAP WebService using MTOM to send an attachment.
      * The service is a brief example that you can find here:
      *   https://github.com/zenovalle/MTOMService/raw/master/MTOMService.war
      * and install into one application server (you have to adjust the url
      * to the server you use).
      *----------------------------------------------------------------
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO)
      /endif
     H BNDDIR('HTTPAPI')

      /copy httpapi_h
      /copy ifsio_h

     D QCMDEXC         pr                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     D SOAP            s           1000A   varying
     D tempFile        s            200A   varying
     D ContentType     s            256A
     D enc             s               *
     D msg             s             52A
     D rc              s             10I 0

      /free

          http_debug(*on);
          *inlr = *on;

          //  Ask HTTPAPI for a temporary filename that won't
          //  conflict with another job.

          tempFile = http_tempfile();

          //  HTTPAPI's multipart/related encoding function output
          //    two things:
          //
          //       1) A stream file field suitable for use with
          //            http_url_post_stmf()
          //       2) A content-type field suitable for use with
          //            http_url_post_stmf()
          //
          //  The http_mfd_encoder_open() API opens the stream file
          //  and initializes the encoding routines.  You must call
          //  that first, passing the type of the message, and
          //  eventually the starting part id and info:

          enc = http_mpr_encoder_open( tempFile
                                     : 'application/xop+xml'
                                     : ContentType
                                     : '<root§httpapi.org>'
                                     : 'text/xml' );
          if (enc = *NULL);
             msg = http_error();
             dsply msg;
             return;
          endif;

          //
          //  now you can add the root part that is our SOAP:
          //

       SOAP =
       '<soapenv:Envelope +
        xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" +
        xmlns:exam="http://examples.zenovalle.it/"> +
           <soapenv:Header/> +
           <soapenv:Body> +
              <exam:archiveFile> +
                 <request> +
                    <fileLoad><inc:Include href="cid:testfile.pdf" +
        xmlns:inc="http://www.w3.org/2004/08/xop/include"/></fileLoad> +
                    <description>This is a test file</description> +
        <fileName>Scott''s HTTPAPI presentation handout.pdf</fileName> +
                    <fileType>application/pdf</fileType> +
                    <key>1234567890</key> +
                 </request> +
              </exam:archiveFile> +
           </soapenv:Body> +
        </soapenv:Envelope>';

           http_mpr_encoder_addstr_s( enc
                                    : SOAP
                                    : 'application/xop+xml; type="text/xml"'
                                    : '<root§httpapi.org>' );

          //
          //  then you can add other parts, for our example add
          //  the pdf file from EXAMPLE1.
          //

          http_mpr_encoder_addstmf( enc
                                  :'/tmp/Scott''s HTTPAPI '
                                   + 'presentation handout.pdf'
                                  : 'application/pdf'
                                  : '<testfile.pdf>' );

          //
          // once all of the variables/files have been added, the
          // http_mpr_encoder_close() API must be called to clean
          // up. (The stream file will remain on disk so that you
          // can use it with http_url_post_stmf)
          //

          http_mpr_encoder_close( enc );


          //
          //  post the results to the web server
          //

          rc = http_url_post_stmf('http://localhost:8080/MTOMService'
                                    + '/services/archiveServer'
                                 : tempFile
                                 : '/tmp/http_result.txt'
                                 : HTTP_TIMEOUT
                                 : HTTP_USERAGENT
                                 : ContentType
                                 : 'archiveFile' );

          if (rc <> 1);
             msg = http_error();
             dsply msg;
             return;
          endif;

          QCMDEXC('DSPF ''/tmp/http_result.txt''': 200);

          //
          //  delete temp files, we're done
          //

          unlink('/tmp/http_result.txt');
          unlink(tempFile);

          return;
      /end-free

