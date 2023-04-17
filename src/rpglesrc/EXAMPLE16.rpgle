      *  This is an example of calling a SOAP Web service w/HTTPAPI.
      *
      *  This sample calls the Currency Exchange Rate Web service
      *  provided by www.RestFulWebServices.net
      *
      *  To Compile
      *     CRTBNDRPG PGM(EXAMPLE16)
      *
      *  To Run:
      *     CALL EXAMPLE16 PARM('USD' 'JPY' 12.00)
      *
      *  (This shows the value of USD 12.00 in Japanese currency.)
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO)
      /endif
     H BNDDIR('HTTPAPI')

     D EXAMPLE16       PR                  ExtPgm('EXAMPLE16')
     D   Country1                     3A   const
     D   Country2                     3A   const
     D   parmAmount                  15P 5 const
     D EXAMPLE16       PI
     D   Country1                     3A   const
     D   Country2                     3A   const
     D   parmAmount                  15P 5 const

      /copy httpapi_h

     D URL             s            100a   varying
     D SOAP            s           1000A   varying
     D response        s           1000a   varying
     D Amount          s             12p 2
     D rate            s              9p 4
     D Result          s             12P 2

      /free

       if %parms < 3;
          http_comp( 'Please pass parms. e.g. CALL EXAMPLE16 '
                   + 'PARM(USD JPY 12.00)');
          return;
       endif;

       Amount = parmAmount;

       http_debug(*ON);

       URL = 'http://www.restfulwebservices.net/wcf/CurrencyService.svc';

       http_setOption('SoapAction': '"GetConversionRate"');

       SOAP =
       '<soapenv:Envelope +
            xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" +
            xmlns:ns="http://www.restfulwebservices.net/+
               ServiceContracts/2008/01">+
           <soapenv:Header/>+
           <soapenv:Body>+
              <ns:GetConversionRate>+
                 <ns:FromCurrency>'+%trim(Country1)+'</ns:FromCurrency>+
                 <ns:ToCurrency>'+%trim(Country2)+'</ns:ToCurrency>+
              </ns:GetConversionRate>+
           </soapenv:Body>+
        </soapenv:Envelope>';

       response = http_string( 'POST': URL: SOAP: 'text/xml');

       xml-into rate %xml(response: 'case=any ns=remove +
           path=Envelope/Body/GetConversionRateResponse+
                /GetConversionRateResult/Rate');

       Result = Amount * Rate;
       http_comp( %trim(Country1) + ' ' + %char(Amount)
                + ' = '
                + %trim(Country2) + ' ' + %char(Result));

       *inlr = *on;

      /end-free

