      *  This is a SOAP 1.2 example. This web service is very
      *  similar to the one in EXAMPLE16, except that a different
      *  version of SOAP is used.
      *
      *  EXAMPLE16 uses SOAP 1.1, which is older, but is still
      *  *MUCH* more popular than 1.2.  For some reason, version
      *  1.2 never became popular.
      *
      *  Notice the differences:
      *    - 1.2 uses a Content-Type of application/soap+xml
      *    - 1.2 adds an action= parameter to the content-type
      *           (this replaces the SoapAction parameter)
      *    - 1.2 uses a different namespace for the SOAP
      *            elements.
      *
      *  This sample calls the Currency Exchange Rate Web service
      *  provided by www.WebServiceX.net
      *
      *  To Compile (requires V5R1):
      *     CRTBNDRPG PGM(EXAMPLE18) SRCFILE(libhttp/QRPGLESRC)
      *
      *  To Run:
      *     CALL EXAMPLE18 PARM('USD' 'JPY' 12.00)
      *
      *  (This shows the value of USD 12.00 in Japanese currency.)
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO)
      /endif
     H BNDDIR('HTTPAPI':'QC2LE')

     D EXAMPLE18       PR                  ExtPgm('EXAMPLE18')
     D   Country1                     3A   const
     D   Country2                     3A   const
     D   Amount                      15P 5 const
     D EXAMPLE18       PI
     D   Country1                     3A   const
     D   Country2                     3A   const
     D   Amount                      15P 5 const

      /copy httpapi_h

     D Incoming        PR
     D   rate                         8F
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D SOAP            s          32767A   varying
     D rc              s             10I 0
     D rate            s              8F
     D Result          s             12P 2

      /free

       if ( %parms < 3 );
          http_comp( 'Please pass parms. e.g. CALL EXAMPLE18 +
                      PARM(USD JPY 12.00)');
          return;
       endif;

       // Note:  http_debug(*ON/*OFF) can be used to turn debugging
       //        on and off.  When debugging is turned on, diagnostic
       //        info is written to an IFS file named
       //        /tmp/httpapi_debug.txt

       http_debug(*ON);

       // Note:  http_XmlStripCRLF(*ON/*OFF) controls whether or not
       //        the XML parser removes CR and LF characters from the
       //        Xml data that's passed to your 'Incoming' procedure.

       http_XmlStripCRLF(*ON);

       SOAP =
       '<?xml version="1.0" encoding="utf-8"?>+
        <soap:Envelope +
              xmlns:soap="http://www.w3.org/2003/05/soap-envelope" +
              xmlns:web="http://www.webserviceX.NET/">+
        <soap:Header/>+
        <soap:Body>+
          <web:ConversionRate>+
            <web:FromCurrency>'+ %trim(Country1) +'</web:FromCurrency>+
            <web:ToCurrency>'+ %trim(Country2) +'</web:ToCurrency>+
          </web:ConversionRate>+
       </soap:Body>+
       </soap:Envelope>';

       http_debug(*ON);

       rc = http_url_post_xml(
                         'http://www.webservicex.net/CurrencyConvertor.asmx'
                         : %addr(SOAP) + 2
                         : %len(SOAP)
                         : *NULL
                         : %paddr(Incoming)
                         : %addr(rate)
                         : HTTP_TIMEOUT
                         : *omit
                         : 'application/soap+xml; charset=UTF-8; +
                            action="http://www.webserviceX.NET/ConversionRate"'
                         );

       if (rc <> 1);
          http_crash();
       else;
          Result = %dech(Amount * rate: 12: 2);
          http_comp(%trim(Country1) + ' ' + %char(%dec(Amount:12:2))
                    + ' = ' + %trim(Country2) + ' '+ %char(Result));
       endif;

       *inlr = *on;

      /end-free

     P Incoming        B
     D Incoming        PI
     D   rate                         8F
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D atof            PR             8F   extproc('atof')
     D   string                        *   value options(*string)

      /free
          if (name = 'ConversionRateResult');
             rate = atof(value);
          endif;
      /end-free
     P                 E
