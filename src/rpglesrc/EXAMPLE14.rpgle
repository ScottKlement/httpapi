      * EXAMPLE14:  Track a package with UPS.
      *
      * This is an interactive program that asks for a UPS tracking
      * number, then gets the status of that package from UPS. You
      * might use this as a model for your own custom tracking app.
      * for example:
      *     -- Modify it to get the tracking number from your
      *        database instead of from the user.  (User keys an
      *        order number, it looks up the UPS tracking number,
      *        and tracks it, real time!)
      *     -- Modify it to track all packages for a day during
      *        a batch run, instead of working interactively.
      *     -- Make it a Web app where customers can see the
      *        status of their orders on-line.
      *
      * UPS offers several other services besides tracking, and you
      * can use this as a model for accessing those services as well.
      *
      * Prior to using this application, you *MUST* register with UPS,
      * then fill-in the UPS_USERID, UPS_PASSWD and UPS_LICENSE
      * constants in the D-specs below.
      *
      * For more information, see the following:
      *   http://ups.com/content/us/en/bussol/offering
      *       /technology/automated_shipping/online_tools.html
      *
      * Here's a shorter/easier link:
      *   http://tinyurl.com/hsrzt
      *
      * The URL used herein is UPS's URL for testing. They have a
      * different one for production. See the PDF documentation for
      * tracking found on the above Web site for more info.
      *
      * To Compile:
      *    CRTDSPF FILE(EXAMPLE14S) SRCFILE(xxx/QDDSSRC)
      *    CRTBNDRPG EXAMPLE14 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) 
      /endif
     H BNDDIR('HTTPAPI')

     FEXAMPLE14SCF   E             WORKSTN SFILE(SFLREC: RRN)
     F                                     indds(dsIndic)

      /copy httpapi_h

     D StartOfElement  PR
     D   UserData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D EndOfElement    PR
     D   UserData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D UPS_USERID      C                   '<put your userid here>'
     D UPS_PASSWD      C                   '<put your password here>'
     D UPS_LICENSE     C                   '<put your access license here>'

     D dsIndic         ds
     D   ExitKey              03     03N
     D   Clear_Sfl            50     50N
     D   Empty_Sfl            51     51N

     d act             s             10I 0
     d activity        ds                  qualified
     d   array                             dim(100)
     d   Date                         8A   overlay(array)
     d   Time                         6A   overlay(array:*next)
     D   Desc                        20A   overlay(array:*next)
     D   City                        20A   overlay(array:*next)
     D   State                        2A   overlay(array:*next)
     D   Status                      20A   overlay(array:*next)
     D   SignedBy                    20A   overlay(array:*next)

     D rc              s             10I 0
     D postData        s            750A   varying
     D TrackingNo      s             24A   varying
     D RRN             s              4  0
     D tempDate        s               D
     D tempTime        s               T

      /free
         if (  %subst(UPS_USERID:1:1) = '<'
            or %subst(UPS_PASSWD:1:1) = '<'
            or %subst(UPS_LICENSE:1:1) = '<' );
              http_comp('You must be registered with UPS! See +
                         comments in EXAMPLE14 member.');
              *inlr = *on;
              return;
         endif;

         exfmt TrackNo;
         if (ExitKey);
            *inlr = *on;
            return;
         endif;

         TrackingNo = %trim(scTrackNo);

       postData =
         '<?xml version="1.0"?>'                                      +
         '<AccessRequest xml:lang="en-US">'                           +
            '<AccessLicenseNumber>'                                   +
                UPS_LICENSE                                           +
            '</AccessLicenseNumber>'                                  +
            '<UserId>' + UPS_USERID + '</UserId>'                     +
            '<Password>' + UPS_PASSWD + '</Password>'                 +
         '</AccessRequest>'                                           +
         '<?xml version="1.0"?>'                                      +
         '<TrackRequest xml:lang="en-US">'                            +
            '<Request>'                                               +
               '<TransactionReference>'                               +
                  '<CustomerContext>'                                 +
                      'HTTPAPI EXAMPLE14'                             +
                  '</CustomerContext>'                                +
                  '<XpciVersion>1.0001</XpciVersion>'                 +
               '</TransactionReference>'                              +
               '<RequestAction>Track</RequestAction>'                 +
               '<RequestOption>activity</RequestOption>'              +
            '</Request>'                                              +
            '<TrackingNumber>' + TrackingNo + '</TrackingNumber>'     +
         '</TrackRequest>'                                            ;

       rc = http_url_post_xml('https://wwwcie.ups.com/ups.app/xml/Track'
                             : %addr(postData) + 2
                             : %len(postData)
                             : %paddr(StartOfElement)
                             : %paddr(EndOfElement)
                             : *NULL );
       if (rc <> 1);
          scmsg = http_error();
          // FIXME: REPORT ERROR TO USER
          *inlr = *on;
          return;
       endif;

       clear_sfl = *on;
       write SFLCTL;
       clear_sfl = *off;
       empty_sfl = *on;

       for RRN = 1 to act;
           monitor;
             tempDate = %date(activity.date(RRN): *ISO0);
             scDate = %char(tempDate: *USA);
           on-error;
             scDate = *blanks;
           endmon;

           monitor;
             tempTime = %time(activity.time(RRN): *HMS0);
             scTime = %char(tempTime: *HMS);
           on-error;
             scTime = *blanks;
           endmon;

           scDesc = activity.desc(RRN);
           scCity = activity.city(RRN);
           scState = activity.state(RRN);
           scStatus = activity.status(RRN);

           if (scSignedBy = *blanks);
              scSignedBy = activity.SignedBy(RRN);
           endif;

           write SFLREC;
           empty_sfl = *off;
       endfor;

       exfmt SFLCTL;
       *inlr = *on;

      /end-free


     P StartOfElement  B
     D StartOfElement  PI
     D   UserData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
      /free

        if path = '/TrackResponse/Shipment/Package' and name='Activity';
           act = act + 1;
        endif;

      /end-free
     P                 E


     P EndOfElement    B
     D EndOfElement    PI
     D   UserData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
      /free

       select;
       when  path = '/TrackResponse/Shipment/Package/Activity';

           select;
           when name = 'Date';
             activity.Date(act) = value;
           when name = 'Time';
             activity.Time(act) = value;
           endsl;

       when  path = '/TrackResponse/Shipment/Package/Activity' +
                    '/ActivityLocation';

           select;
           when name = 'Description';
             activity.Desc(act) = value;
           when name = 'SignedForByName';
             activity.SignedBy(act) = value;
           endsl;

       when  path = '/TrackResponse/Shipment/Package/Activity' +
                    '/ActivityLocation/Address';

           select;
           when name = 'City';
             activity.City(act) = value;
           when name = 'StateProvinceCode';
             activity.State(act) = value;
           endsl;

       when  path = '/TrackResponse/Shipment/Package/Activity' +
                    '/Status/StatusType';

           if   name = 'Description';
               activity.Status(act) = value;
           endif;

       endsl;

      /end-free
     P                 E
