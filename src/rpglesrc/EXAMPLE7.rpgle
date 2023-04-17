      * This example demonstrates posting multipart/form-data to a
      * web server.
      *
      * It is intended to mimic the following HTML form:
      *----------------------------------------------------------------
      *
      * <form method="post" enctype="multipart/form-data"
      *       action="http://www.scottklement.com/httpapi/upload.php">
      *
      *   <input type="hidden" name="operation" value="VERIFY">
      *
      *   File Format:
      *   <input type="radio"  name="data_format" value="HTML" checked>HTML
      *   <input type="radio"  name="data_format" value="PDF">PDF
      *   <input type="radio"  name="data_format" value="PTF">RTF<br>
      *
      *   File to send:
      *   <input type="file" name="handout"><br>
      *
      *   <input type="submit">
      *
      * </form>
      *
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

     D tempFile        s            200A   varying
     D ContentType     s             64A
     D enc             s               *
     D msg             s             52A
     D rc              s             10I 0

      /free

          http_debug(*on);
          *inlr = *on;

          //  Ask HTTPAPI for a temporary filename that won't
          //  conflict with another job.

          tempFile = http_tempfile();

          //  HTTPAPI's multipart/form-data encoding functions output
          //    two things:
          //
          //       1) A stream file field suitable for use with
          //            http_url_post_stmf()
          //       2) A content-type field suitable for use with
          //            http_url_post_stmf()
          //
          //  The http_mfd_encoder_open() API opens the stream file
          //  and initializes the encoding routines.  You must call
          //  that first:

          enc = http_mfd_encoder_open( tempFile : ContentType );
          if (enc = *NULL);
             msg = http_error();
             dsply msg;
             return;
          endif;

          //
          //  now you can add variables to the encoded stream file:
          //

           http_mfd_encoder_addvar_s(enc: 'operation'  : 'VERIFY');
           http_mfd_encoder_addvar_s(enc: 'data_format': 'PDF'   );

          //
          //  and you can even add the contents of another stream
          //  file, compatible with the <input type="file"> HTML
          //  keyword.
          //
          //  In this case, the HTTPAPI handout that was downloaded
          //  in EXAMPLE1 will be added to the temp file
          //

          http_mfd_encoder_addstmf( enc
                                  : 'handout'
                                  : '/tmp/Scott''s HTTPAPI +
                                    presentation handout.pdf'
                                  : 'application/octet-stream');

          //
          // once all of the variables/files have been added, the
          // http_mfd_encoder_close() API must be called to clean
          // up. (The stream file will remain on disk so that you
          // can use it with http_url_post_stmf)
          //

          http_mfd_encoder_close( enc );


          //
          //  post the results to the web server
          //

          rc = http_url_post_stmf('http://www.scottklement.com/httpapi'
                                    + '/upload.php'
                                 : tempFile
                                 : '/tmp/http_result.txt'
                                 : HTTP_TIMEOUT
                                 : HTTP_USERAGENT
                                 : ContentType );

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
