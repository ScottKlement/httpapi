
     H NOMAIN

      /copy RDWR_H

     D Data_t          ds                  qualified
     D                                     template
     D

     D StringReader_t  ds                  qualified
     D                                     template

     D    h                                likeds(RDWR_t)
     D    data                             likeds(DATA_t)

     P http_StringReader...
     P                 B                   export
     D                 PI              *   opdesc
     D   str                           a   varying len(16000000)
     D
     D vanilla         ds                  likeds(RDWR_t) inz(*likeds)

     D stringReader    ds                  qualified
     D   h                                 likeds(RDWR_t)
     D   d
      /free
       p_hnd = %alloc(%size(hnd));
       hnd = vanilla;

       hnd.directions = RDWR_READER;

       hnd.open    = %paddr(http_StringReader_open);
       hnd.read    = %paddr(http_StringReader_close);
       hnd.write   = *null;
       hnd.close   = %paddr(http_StringReader_close);
       hnd.cleanup = %paddr(http_StringReader_cleanup);



      /end-free
     P                 E
