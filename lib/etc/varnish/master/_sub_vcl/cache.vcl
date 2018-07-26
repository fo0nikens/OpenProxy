sub req_force_cache {

  # Remove all cookies for static files.
  # A valid discussion could be held on this line: do you really need to cache static files that don't cause load? Only if you have memory left.
  # Sure, there's disk I/O, but chances are your OS will already have these files in their buffers (thus memory).
  # Before you blindly enable this, have a read here: https://ma.ttias.be/stop-caching-static-files/
  if (req.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|otf|ogg|ogm|opus|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {

    if (req.http.Set-Cookie) {

      unset req.http.Set-Cookie;

    }

    return(hash);

  }

}

sub res_force_cache {

  # Enable cache for all static files
  # The same argument as the static caches from above: monitor your cache size,
  # if you get data nuked out of it, consider giving up the static file cache.
  # Before you blindly enable this, have a read here:
  # https://ma.ttias.be/stop-caching-static-files/
  if (bereq.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|otf|ogg|ogm|opus|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {

    if (beresp.http.Set-Cookie || beresp.http.Cache-Control ~ "(private|no-cache|no-store)") {

      unset beresp.http.Set-Cookie;
      unset beresp.http.Cache-Control;

      set beresp.ttl = 180s;
      set beresp.uncacheable = false;

    }

  }

}
