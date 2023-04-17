      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP('KLEMENT')
      /endif
     H BNDDIR('HTTPAPI')

      *  Example of downloading and building a PF with all exchange
      *  rates for US dollars using Xurrency.com's RESTful
      *  web service.
      *
      *  To compile:
      *    * Make sure HTTPAPI is installed and in your *LIBL
      *    * CRTBNDRPG EXAMPLE13 SRCFILE(xxx/QRPGLESRC)
      *
      *  NOTE: Xurrency is free for PERSONAL use.  For commercial
      *        use, please check the following site:
      *       http://xurrency.com/license
      *
      *  For more info about the Xurrency API, see:
      *       http://xurrency.com/api
      *

      /include httpapi_h

     D getXml          PR
     D   userData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D uri             s           5000a   varying
     D rc              s             10i 0
     D target          s              3a
     D result          s             11p 4

      /free
         exec SQL set option naming=*sys, commit=*none;

         exec SQL drop table curr;

         exec SQL create table curr (
                     name char(3) not null,
                     rate decimal(11, 4) not null
                  );

         http_debug(*on: '/tmp/example13-debug.txt');

         uri = 'http://xurrency.com/usd/feed';
         rc = http_url_get_xml(uri: *null: %paddr(getXml): *null);
         if (rc <> 1);
           http_crash();
         endif;

         *inlr = *on;
      /end-free



     P getXml          B
     D getXml          PI
     D   userData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
      /free
          if (name = 'dc:targetCurrency');
            target = value;
          endif;
          if (name = 'dc:value');
            result = %dech(value:11:4);
          endif;
          if (name = 'item');
            exec SQL insert into curr values(:target, :result);
            reset target;
            reset result;
          endif;
      /end-free
     P                 E
