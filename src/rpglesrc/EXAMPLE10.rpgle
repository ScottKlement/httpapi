      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO)
      /endif
     H BNDDIR('HTTPAPI')

      *
      * This example shows how to send a "tweet" (change your
      * status on Twitter.com) via HTTPAPI.
      *
      * You must pass a userid/password.  This tells Twitter.com
      * which Twitter account to update.
      *
      *   CALL EXAMPLE10 PARM('youruserid' 'yourpassword')
      *
      *

      /define WEBFORMS
      /include httpapi_h

     D EXAMPLE10       PR                  ExtPgm('EXAMPLE10')
     D   userid                      32a   const
     D   passwd                      32a   const
      * This works like *ENTRY PLIST
     D EXAMPLE10       PI
     D   userid                      32a   const
     D   passwd                      32a   const

     D xmlReply        PR
     D   tw                                likeds(tweet)
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const

     D tweet           ds                  qualified
     D   id                          20a   varying
     D   text                       140a   varying inz('')
     D   created                     30a   varying

     D newStatus       s            140a   varying
     D form            s                   like(WEBFORM)
     D rc              s             10I 0
     D postData        s               *
     D postDataSize    s             10I 0

      /free
         if %parms < 2;
            http_comp('You must pass a USERID & PASSWORD');
            return;
         endif;

         //
         //  the http_setAuth() routine is used to set
         //  the userid/password of the HTTP connection.
         //

         http_setAuth( HTTP_AUTH_BASIC
                     : %trim(Userid)
                     : %trim(Passwd) );


         //
         //  newStatus is the new status message to set.
         //  because of spaces & other special symbols,
         //  it must be encoded, like a form on a web page.
         //

         newStatus = 'is testing HTTPAPI from ScottKlement.com';

         form = WEBFORM_open();
         WEBFORM_setVar(form: 'status': newstatus );
         WEBFORM_postData(form: postData: postDataSize );

         //
         //  http_post_xml() sends the encoded data to Twitter,
         //   receives the reply, and parses the reply as an
         //   XML document.
         //
         //  Note: We must set http_set_100_timeout() because
         //        Twitter doesn't allow Expect: 100-continue
         //        despite that RFC2616 says that all HTTP 1.1
         //        servers must recognize it.  Bug in Twitter??
         //

         http_set_100_timeout(0);
         rc = http_post_xml( 'http://twitter.com/statuses/update.xml'
                           : postData
                           : postDataSize
                           : *null
                           : %paddr(xmlReply)
                           : %addr(tweet)
                           : HTTP_TIMEOUT
                           : HTTP_USERAGENT
                           : 'application/x-www-form-urlencoded' );
         WEBFORM_close(form);
         if (rc <> 1);
            http_crash();
            return;
         endif;

         http_comp( 'Twitter status set at ' + tweet.created
                  + ' id=' + tweet.id);
         http_comp( 'Twitter status is now: ' + tweet.text );

         *inlr = *on;

      /end-free


      *------------------------------------------------------
      * xmlReply(): retrieve the XML reply from Twitter.
      *
      *  http_post_xml will call this subprocedure while
      *   it's parsing the XML.  It will call it individually
      *   for each XML tag it receives.
      *------------------------------------------------------
     P xmlReply        B
     D xmlReply        PI
     D   tw                                likeds(tweet)
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
      /free
         if path='/status';
            select;
            when name = 'created_at';
              tw.created = value;
            when name = 'id';
              tw.id = value;
            when name = 'text';
              tw.text = value;
            endsl;
          endif;
      /end-free
     P                 E
