acl example_com_allow {

  "10.255.10.0/24";
  "10.255.20.0/24";
  "216.129.67.216/32";

}

sub vcl_recv {

  if (req.http.host ~ "^(www.)?example.com$") {

    if (req.http.host ~ "^www.example.com$") {

      return(synth(751, "https://example.com" + req.url));

    }

    else if (req.http.X-Forwarded-Proto != "https") {

      return(synth(751, "https://example.com" + req.url));

    }

    else if ((req.url ~ "^/backend.*")) {

      if (client.ip ~ localhost || client.ip ~ example_com_allow) {

        set req.backend_hint = example_com_lb.backend();
        return(pass);

      }

      else {

        return(synth(751, "https://example.com"));

      }

    }

    # Pipe these paths directly to backend for streaming.
    else if (req.url ~ "^/system/files") {

      return(pipe);

    }

    else {

      # For Sticky-IP:
      # set req.backend_hint = hash_ip_example_com_lb.backend(req.http.X-Real-IP);

      set req.backend_hint = example_com_lb.backend();

      # return(pass);

    }

  }

}

sub vcl_backend_response {

  if (bereq.http.host ~ "^(www.)?example.com$") {

  /*
  if (beresp.http.x-no-session) {

    unset beresp.http.cache-control;
    unset beresp.http.pragma;

    unset beresp.http.Set-Cookie;

    set beresp.http.X-Cacheable = "YES:No-Session";
    set beresp.ttl = 180s;
    set beresp.http.cache-control = "max-age=180";

  }
  */

  # Enabling cache by disabling headers.
  # https://book.varnish-software.com/4.0/chapters/HTTP.html#cache-related-headers-fields
  # Uncomment for specific urls:
  # if (bereq.url ~ "^/$") {

    unset beresp.http.expires;
    unset beresp.http.etag;
    unset beresp.http.vary;

    # Set Cache Control for specific urls.
    # set beresp.http.X-Cacheable = "YES:No-Session";
    # set beresp.ttl = 5s;
    # set beresp.http.cache-control = "max-age:5";

  # }

  }

}

sub vcl_deliver {

  if (req.http.host ~ "^(www.)?example.com$") {

    # set resp.http.Access-Control-Allow-Origin =  "*";
    # set resp.http.X-XSS-Protection = "1; mode=block";
    # set resp.http.X-Content-Type-Options = "nosniff";

  }

}

sub vcl_backend_error {

  if (bereq.http.host ~ "^(www.)?example.com$") {

    if (beresp.status == 500 ||
        beresp.status == 501 ||
        beresp.status == 502 ||
        beresp.status == 503 ||
        beresp.status == 504) {

      set beresp.http.Content-Type = "text/html; charset=utf-8";
      set beresp.http.vcl_error = "T";
      set beresp.uncacheable = true;

      synthetic(std.fileread("/usr/share/www/http-error-pages/sites/other/temporary_maintenance.html"));

      return(deliver);

    }

  }

}

sub vcl_synth {

  if (req.http.host ~ "^(www.)?example.com$") {

    if (resp.status == 404 ) {

      set resp.http.Server = "Unknown";

      include "/etc/varnish/master/_static/invalid_domain.vcl";

      return(deliver);

    }

    else if (resp.status >= 500 && resp.status <= 505) {

      return(restart);

    }

  }

}
