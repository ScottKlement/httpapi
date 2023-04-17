      * This example demonstrates how to parse a multipart/related response
      * in order to get an attachment.
      *
      * It is intended to call a SOAP WebService using MTOM to retrieve an attachment.
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
     D dec             s               *
     D msg             s             52A
     D rc              s             10I 0
     D fileinfo        ds
     D  filename                    256A
     D  fd                           10I 0

     D StartPrc        PR
     D   userdata                      *   value
     D   isRoot                        N   const

     D PartPrc         PR
     D   userdata                      *   value
     D   data                          *   value
     D   datalen                     10I 0 const

     D EndPrc          PR
     D   userdata                      *   value

      /free

       http_debug(*on);
       *inlr = *on;

       SOAP =
       '<soapenv:Envelope +
        xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" +
        xmlns:exam="http://examples.zenovalle.it/">+
           <soapenv:Header/>+
           <soapenv:Body>+
              <exam:getFile>+
                 <key>1234567890</key>+
              </exam:getFile>+
           </soapenv:Body>+
        </soapenv:Envelope>';

       //
       //  post the results to the web server
       //

       rc = http_url_post('http://localhost:8080/MTOMService'
                               + '/services/archiveServer'
                            : %addr(SOAP) + 2
                            : %len(SOAP)
                            : '/tmp/http_result.txt'
                            : HTTP_TIMEOUT
                            : HTTP_USERAGENT
                            : 'text/xml'
                            : 'getFile' );

          if (rc <> 1);
             msg = http_error();
             dsply msg;
             return;
          endif;

          //
          //  create a parser for the multipart/related response.
          //  It must be passed the reference to the procedure used
          //  by the parsing process in order to save the
          //  attachment on disk
          //

          dec = http_mpr_decoder_open( '/tmp/http_result.txt'
                                     : http_header('content-type')
                                     : %addr(fileinfo)
                                     : %paddr(StartPrc)
                                     : %paddr(PartPrc)
                                     : %paddr(EndPrc) );

          //
          //  parse the thing
          //

          if not http_mpr_decoder_parse(dec);
             msg = 'Parsing error.';
             dsply msg;
             return;
          endif;

          //
          // once all is completed, the http_mpr_decoder_close()
          // API must be called to clean up.
          //

          http_mpr_decoder_close(dec);


          QCMDEXC('DSPF ''/tmp/http_result_root.xml''': 200);
          QCMDEXC('DSPF ''' + %trim(filename) + '''': 200);

          //
          //  delete temp files, we're done
          //

          unlink('/tmp/http_result.txt');
          unlink('/tmp/http_result_root.xml');
          unlink(%trim(filename));

          return;
      /end-free


     P StartPrc        B
     D StartPrc        PI
     D   userdata                      *   value
     D   isRoot                        N   const

     D fileinfo        ds                  based(userdata)
     D  filename                    256A
     D  fd                           10I 0

     D id              s             64A   varying
      /free

       if isRoot;
          filename = '/tmp/http_result_root.xml';
          fd = open( %trim(filename)
                   : O_CREAT + O_TRUNC + O_CCSID + O_WRONLY
                   : S_IRUSR + S_IWUSR
       //          : 819 );
                   : 1208 );
       else;
          id = %trim(http_mpr_part_header('content-id'));
          id = %subst(id : 2 : %len(id) - 2);
          filename = '/tmp/' + %trim(id) + '.pdf';
          fd = open( %trim(filename)
                   : O_CREAT + O_TRUNC + O_CCSID + O_WRONLY
                   : S_IRUSR + S_IWUSR
       //          : 819 );
                   : 1208 );
       endif;

      /end-free
     P                 E


     P PartPrc         B
     D PartPrc         PI
     D   userdata                      *   value
     D   data                          *   value
     D   datalen                     10I 0 const

     D fileinfo        ds                  based(userdata)
     D  filename                    256A
     D  fd                           10I 0
      /free
        callp write(fd: data: datalen);
      /end-free
     P                 E


     P EndPrc          B
     D EndPrc          PI
     D   userdata                      *   value

     D fileinfo        ds                  based(userdata)
     D  filename                    256A
     D  fd                           10I 0
      /free
        callp close(fd);
      /end-free
     P                 E

