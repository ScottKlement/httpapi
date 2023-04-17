      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO)
      /endif
     H BNDDIR('HTTPAPI')
      *
      *  Example of calling WebserviceX.net's ABA Bank Routing
      *  web service to display details about a bank routing number.
      *
      *  For example:
      *    CALL EXAMPLE17 PARM('021200025')
      *
      *  Note:  This web service wraps an entire XML document
      *         inside the "payload" of it's SOAP message.
      *         So this program parses XML twice.  First it
      *         parses the SOAP message to get the payload,
      *         then it parses the payload to get the data.
      *
      *  Note: If DEBUGGING is defined (below) you'll see what
      *         the XML response looks like at each step of the
      *         process.
      *

      // change the following to "/undefine" if you don't
      // want to see debugging messages
      /define DEBUGGING

     D EXAMPLE17       PR                  ExtPgm('EXAMPLE17')
     D   RoutNo                      32A   const
     D EXAMPLE17       PI
     D   RoutNo                      32A   const

      /copy httpapi_h
      /copy ifsio_h

     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
     D   command                  32702a   const options(*varsize)
     D   len                         15p 5 const
     D   igc                          3a   const options(*nopass)

     D SaveEmbed       PR
     D   embfile                     50a   varying
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    32767A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D bank_t          ds                  qualified
     D                                     based(Template)
     D   rtgno                       20a   varying
     D   name                        30a   varying
     D   addr                        30a   varying
     D   city                        20a   varying
     D   state                        2a   varying
     D   zip                         10a   varying
     D   phone                       15a   varying

     D embedded        PR
     D   bank                              likeds(bank_t)
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    32767A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D SOAP            s           2000A   varying
     D rc              s             10I 0
     D fd              s             10I 0
     D soapfile        s             50a   varying
     D embfile         s             50a   varying
     D cmd             s            200A
     D bank            ds                  likeds(bank_t)
     D wait            s              1A

      /free
      /if defined(DEBUGGING)
        http_debug(*ON);
      /endif
        *inlr = *on;

        if (%parms < 1);
           http_comp('You must pass an ABA Routing number!');
           return;
        endif;

        // ----------------------------------------------
        //  Create SOAP document to tell server
        //    - to call the getABADetailsByRoutingNumber routine
        //    - pass a parameter with the routing number.
        // ----------------------------------------------

        SOAP=
         '<?xml version="1.0" encoding="iso-8859-1" standalone="no"?> +
          <SOAP-ENV:Envelope +
               xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"> +
          <SOAP-ENV:Body> +
             <GetABADetailsByRoutingNumber +
                      xmlns="http://www.webserviceX.NET"> +
                <RoutingNumber>' + RoutNo + '</RoutingNumber> +
             </GetABADetailsByRoutingNumber> +
          </SOAP-ENV:Body> +
          </SOAP-ENV:Envelope>';

        // ----------------------------------------------
        //  Send request to server, and get response
        // ----------------------------------------------

          soapfile = http_tempfile();

          rc = http_url_post( 'http://www.webservicex.net/aba.asmx'
                            : %addr(SOAP)+2
                            : %len(SOAP)
                            : soapfile
                            : HTTP_TIMEOUT
                            : HTTP_USERAGENT
                            : 'text/xml'
                            : 'http://www.webserviceX.NET/+
                               GetABADetailsByRoutingNumber');

          if (rc <> 1);
             unlink(soapfile);
             http_crash();
          endif;

        // ----------------------------------------------
        //   The response from the server will be in
        //   the IFS in a file with a unique name.
        //   that IFS filename is in the "tempfile"
        //   variable at this point.
        //
        //   For debugging purposes, display the
        //   contents of that file, now.
        // ----------------------------------------------
      /if defined(DEBUGGING)
          dsply ('Press <ENTER> to see SOAP response') ' ' wait;
          cmd = 'DSPF STMF(''' + soapfile + ''')';
          QCMDEXC(cmd: %len(cmd));
      /endif


        // ----------------------------------------------
        //  Parse the SOAP document (the one in soapfile)
        //  Inside it will be another XML document that's
        //  embedded within -- save that to a separate
        //  file in the IFS.
        // ----------------------------------------------

          embfile = http_tempfile();

          if (http_parse_xml_stmf( soapfile
                                 : HTTP_XML_CALC
                                 : *null
                                 : %paddr(SaveEmbed)
                                 : %addr(embfile) ) < 0);
              callp close(fd);
              unlink(soapfile);
              unlink(embfile);
              http_crash();
          endif;

          unlink(soapfile);


        // ----------------------------------------------
        //   For the sake of debugging, display the
        //   contents of the embedded XML document
        //   (Remove from production code)
        // ----------------------------------------------

      /if defined(DEBUGGING)
          dsply ('Press <ENTER> to see extracted XML') ' ' wait;
          cmd = 'DSPF STMF(''' + embfile + ''')';
          QCMDEXC(cmd: %len(cmd));
      /endif

        // ----------------------------------------------
        //    Parse the second XML document (the one
        //    that was embedded)
        // ----------------------------------------------
          bank = *allx'00';
          if (http_parse_xml_stmf( embfile
                                 : HTTP_XML_CALC
                                 : *null
                                 : %paddr(Embedded)
                                 : %addr(bank) ) < 0);
              unlink(embfile);
              http_crash();
          endif;

        // ----------------------------------------------
        //   For the sake of demonstration, use DSPLY
        //   to show the results on the screen (you
        //   wouldn't do this in a real program.)
        // ----------------------------------------------

          dsply ('--- Reply from Web Service ---');
          dsply ('name  = ' + bank.name);
          dsply ('phone = ' + bank.phone);
          dsply (' addr = ' + bank.addr);
          dsply ('        ' + bank.city  + ' '
                            + bank.state + ' '
                            + bank.zip );
          dsply ('--- Press ENTER to end ---') ' ' wait;

          return;

      /end-free



     P SaveEmbed       B
     D SaveEmbed       PI
     D   embfile                     50a   varying
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    32767A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D writeConst      PR            10I 0 ExtProc('write')
     D  fildes                       10i 0 value
     D  buf                       65535A   const options(*varsize)
     D  bytes                        10U 0 value

     D xmlhdr          s             80a   varying
     D fd              s             10i 0

      /free
           if (name <> 'GetABADetailsByRoutingNumberResult');
             return;
           endif;

           // ------------------------------------------
           //   create new stream file in IFS
           //   tag it with CCSID 1208 (UTF-8)
           // ------------------------------------------

           unlink(embfile);
           fd = open(embfile: O_CREAT+O_CCSID+O_WRONLY
                            : S_IRUSR + S_IWUSR: 819);
           callp close(fd);

           // ------------------------------------------
           //    Open stream file for appending data
           //    and write embedded XML document to it
           // ------------------------------------------

           fd = open(embfile: O_WRONLY+O_TEXTDATA);

           xmlhdr= '<?xml version="1.0" encoding="iso-8859-1"?>' + x'0d25';
           writeConst(fd: xmlhdr: %len(xmlhdr));
           writeConst(fd: value:  %len(value));

           callp close(fd);
      /end-free
     P                 E


     P embedded        B
     D embedded        PI
     D   bank                              likeds(bank_t)
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    32767A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

      /free
         select;
         when name = 'RoutingNumber';
            bank.rtgno = %trimr(value);
         when name = 'BankName';
            bank.name  = %trimr(value);
         when name = 'Address';
            bank.addr = %trimr(value);
         when name = 'City';
            bank.city = %trimr(value);
         when name = 'State';
            bank.state = %trimr(value);
         when name = 'ZipCode';
            bank.zip   = %trimr(value);
         when name = 'PhoneNumber';
            bank.phone = %trimr(value);
         endsl;
      /end-free
     P                 E
