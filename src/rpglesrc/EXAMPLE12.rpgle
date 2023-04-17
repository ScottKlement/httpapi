      *  Example of looking up the weather from Weather Underground's
      *  RESTful web service from RPG.
      *
      *  To compile:
      *    * Make sure HTTPAPI is installed and in your *LIBL
      *    * CRTBNDRPG EXAMPLE12 SRCFILE(xxx/QRPGLESRC)
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP('KLEMENT')
      /endif
     H BNDDIR('HTTPAPI')

      /define WEBFORMS
      /copy httpapi_h

     D EXAMPLE12       PR                  ExtPgm('EXAMPLE12')
     D   queryString                 32a   const
     D EXAMPLE12       PI
     D   queryString                 32a   const

     D QUILNGTX        PR                  ExtPgm('QUILNGTX')
     D   text                     65535a   const options(*varsize)
     D   length                      10i 0 const
     D   msgid                        7a   const
     D   qualmsgf                    20a   const
     D   errorCode                32767a   options(*varsize)

     D ErrorEscape     ds                  qualified
     D   bytesProv                   10i 0 inz(0)
     D   bytesAvail                  10i 0 inz(0)

     D parseWeather    PR
     D   userData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D showForecast    PR
     D   msg                      65535a   varying const options(*varsize)

     D form            s                   like(WEBFORM)
     D rc              s             10i 0
     D uri             s            200a   varying

      /free
        if %parms() < 1;
           http_comp('Please pass a city name or postal code!');
           return;
        endif;

        //
        //  The query (city name/postal code) must be URL encoded
        //  like a form on a web page
        //

        form = webform_open();
        webform_setVar(form: 'query': %trim(queryString));
        uri ='http://api.wunderground.com/auto/wui/geo/ForecastXML/+
              index.xml?query=' + webform_getData(Form);
        webform_close(form);

        //
        // get the response, and parse it as an XML document.
        //  http_url_get_xml() will call the parseWeather procedure
        //  for each XML tag found.
        //

        rc = http_url_get_xml( uri: *null: %paddr(parseWeather): *null);
        if (rc <> 1);
           http_crash();
        endif;

        *inlr = *on;
      /end-free

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * parseWeather(): This is called by http_url_get_xml() for
      *   each XML tag found.
      *
      * When we see a weatther forecast in an <fcttext> tag, then
      * we'll display it's contents on the screen via the
      * IBM-supplied QUILNGTX API.
      *
      * The QUILNGTX is just an easy way to display a window with
      * text on the screen.  If you'd prefer to do something else
      * with the forecast, simply write the VALUE variable to
      * whereever you want the forecast to go...
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P parseWeather    B
     D                 PI
     D   userData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D title           s             80a   varying static
      /free
         if path = '/forecast/txt_forecast/forecastday';
            select;
            when name='title';
               title=value;
            when name='fcttext';
               showForecast(title + ': ' + value);
            endsl;
         endif;
      /end-free
     P                 E

     P showForecast    B
     D showForecast    PI
     D   msg                      65535a   varying const options(*varsize)
      /free
        QUILNGTX( msg
                : %len(msg)
                : *blanks
                : *blanks
                : errorEscape );
      /end-free
     P                 E
