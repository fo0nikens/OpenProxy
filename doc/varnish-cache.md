## Varnish version

This configuration was tested on **varnish-5.0.0 revision 99d036f**.

## Filesystem structure

```
tree lib/etc/varnish 
lib/etc/varnish
├── builtin.vcl
├── default.vcl
└── master
    ├── acls
    │   └── main.vcl
    ├── backends
    │   ├── main.vcl
    │   └── probes.vcl
    ├── domains
    │   └── example.com
    │       ├── backends.vcl
    │       └── main.vcl
    ├── _static
    │   ├── error_maintenance.vcl
    │   ├── invalid_domain.vcl
    │   └── synth_maintenance.vcl
    └── _sub_vcl
        └── cache.vcl

7 directories, 11 files
```

## Configuration

###### :small_blue_diamond: secret

  > **type**: *file*  
  > *"Pre Shared Key" authentication method.*

If it has been removed, you must regenerate its content:

```
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | sha256sum | head -c 64 >/etc/varnish/secret
```

###### :small_blue_diamond: builtin.vcl

  > **type**: *file*  
  > *Default Varnish configuration file.*

The built-in VCL subroutines are always appended to yours.

###### :small_blue_diamond: default.vcl

  > **type**: *file*  
  > *Configuration file adapted from the default configuration (contains default entries to better visualize the configuration).*

```
################################################################################
################################# VCL VERSION ##################################
################################################################################

vcl 4.0;

################################################################################
#################################### VMODS #####################################
################################################################################

import directors;
import std;

################################################################################
############################# EXTERNAL SUBROUTINES #############################
################################################################################

# External subroutines.
include "/etc/varnish/master/_sub_vcl/cache.vcl";

################################################################################
##################################### ACLS #####################################
################################################################################

# Localhost, private and public addresses.
include "/etc/varnish/master/acls/main.vcl";

################################################################################
############################# BACKENDS DEFINITION ##############################
################################################################################

# VCL probes definition.
include "/etc/varnish/master/backends/probes.vcl";

# Localhost and specific backends configuration.
include "/etc/varnish/master/backends/main.vcl";

# Include domain backend configuration.
include "/etc/varnish/master/domains/example.com/backends.vcl";

################################################################################
############################## DOMAINS DEFINITION ##############################
################################################################################

# Include subroutines domain configuration.
include "/etc/varnish/master/domains/example.com/main.vcl";

################################################################################
# Client side

sub vcl_recv {

  # Block the forbidden IP address.
  if (client.ip ~ acl_forbidden_internal ||
      client.ip ~ acl_forbidden_external) {

    return(synth(403, "Not allowed"));

  }

  if (req.method == "PRI") {

    /* We do not support SPDY or HTTP/2.0 */
    return (synth(405));

  }

  if (req.method != "GET" &&
      req.method != "HEAD" &&
      req.method != "PUT" &&
      req.method != "POST" &&
      req.method != "TRACE" &&
      req.method != "OPTIONS" &&
      req.method != "DELETE" &&
      req.method != "PATCH") {

    /* Non-RFC2616 or CONNECT which is weird. */
    return (pipe);

  }

  if (req.method != "GET" && req.method != "HEAD") {

    /* We only deal with GET and HEAD by default */
    return (pass);

  }

  if (req.http.Authorization || req.http.Cookie) {

    /* Not cacheable by default */
    return (pass);

  }

  return (hash);

}

sub vcl_pipe {

  # By default Connection: close is set on all piped requests, to stop
  # connection reuse from sending future requests directly to the
  # (potentially) wrong backend. If you do want this to happen, you can undo
  # it here.
  # unset bereq.http.connection;
  return (pipe);

}

sub vcl_pass {

  return (fetch);

}

sub vcl_hash {

  hash_data(req.url);

  if (req.http.host) {

    hash_data(req.http.host);
  }

  else {

    hash_data(server.ip);

  }

  return (lookup);

}

sub vcl_purge {

  return (synth(200, "Purged"));

}

sub vcl_hit {

  if (obj.ttl >= 0s) {

    // A pure unadultered hit, deliver it
    return (deliver);

  }

  if (obj.ttl + obj.grace > 0s) {

    // Object is in grace, deliver it
    // Automatically triggers a background fetch
    return (deliver);

  }

  // fetch & deliver once we get the result
  return (miss);

}

sub vcl_miss {

  return (fetch);

}

sub vcl_deliver {

  # Add debug header to see if it's a HIT/MISS and the number of hits,
  # disable when not needed. Probably the best for this it will be:
  #
  #   - X-C|X-Cache = "H|Hit"
  #   - X-C|X-Cache = "M|Miss"
  #
  # but Varnish shouldn't show information about cached object.
  if (obj.hits > 0) {

    set resp.http.X-Cache = "HIT";

  }

  else {

    set resp.http.X-Cache = "MISS";

  }

  # Set security headers (only for http traffic, for https protocol headers
  # should be set in Nginx configuration.
  set resp.http.Access-Control-Allow-Origin =  "*";
  set resp.http.X-XSS-Protection = "1; mode=block";
  set resp.http.X-Content-Type-Options = "nosniff";

  # Please note that obj.hits behaviour changed in 4.0, now it counts per
  # objecthead, not per object and obj.hits may not be reset in some cases
  # where bans are in use.
  # See bug 1492 for details. So take hits with a grain of salt
  set resp.http.X-Cache-Hits = obj.hits;

  # Unset headers for objects.
  unset resp.http.Server;
  unset resp.http.X-Varnish;
  unset resp.http.Via;
  unset resp.http.Link;
  unset resp.http.X-Powered-By;
  unset resp.http.X-Drupal-Cache;
  unset resp.http.X-Generator;
  unset resp.http.Purge-Cache-Tags;

  # Unset headers for objects - used by Ban Lurker.
  unset resp.http.X-Host;
  unset resp.http.X-Url;

  return (deliver);

}

/*
 * We can come here "invisibly" with the following errors: 500 & 503
 */
sub vcl_synth {

  # HTTP 301 redirect.
  if (resp.status == 751 ) {

    set resp.http.Location = resp.reason;
    set resp.http.Server = "Unknown";

    unset resp.http.X-Varnish;

    set resp.status = 301;

    return(deliver);

  }

  # HTTP 302 redirect.
  if (resp.status == 752 ) {

    set resp.http.Location = resp.reason;
    set resp.http.Server = "Unknown";

    unset resp.http.X-Varnish;

    set resp.status = 302;

    return(deliver);

  }

  set resp.http.Content-Type = "text/html; charset=utf-8";
  set resp.http.Retry-After = "5";
  set resp.body = {"<!DOCTYPE html>
<html>
  <head>
    <title>"} + resp.status + " " + resp.reason + {"</title>
  </head>
  <body>
    <h1>Error "} + resp.status + " " + resp.reason + {"</h1>
    <p>"} + resp.reason + {"</p>
    <h3>Guru Meditation:</h3>
    <p>XID: "} + req.xid + {"</p>
    <hr>
    <p>Varnish cache server</p>
  </body>
</html>
"};

  return (deliver);

}

################################################################################
# Backend Fetch

sub vcl_backend_fetch {

  if (bereq.method == "GET") {

    unset bereq.body;

  }

  return (fetch);

}

sub vcl_backend_response {

  if (bereq.uncacheable) {

    return (deliver);

  }

  else if (beresp.ttl <= 0s ||
           beresp.http.Set-Cookie ||
           beresp.http.Surrogate-control ~ "no-store" ||
          (!beresp.http.Surrogate-Control &&
           beresp.http.Cache-Control ~ "no-cache|no-store|private") ||
           beresp.http.Vary == "*") {

    # Mark as "Hit-For-Pass" for the next 2 minutes
    set beresp.ttl = 120s;
    set beresp.uncacheable = true;

  }

  set beresp.http.X-Cache-Time = beresp.ttl;

  return (deliver);

}

sub vcl_backend_error {

  set beresp.http.Content-Type = "text/html; charset=utf-8";
  set beresp.http.Retry-After = "5";
  set beresp.body = {"<!DOCTYPE html>
<html>
  <head>
    <title>"} + beresp.status + " " + beresp.reason + {"</title>
  </head>
  <body>
    <h1>Error "} + beresp.status + " " + beresp.reason + {"</h1>
    <p>"} + beresp.reason + {"</p>
    <h3>Guru Meditation:</h3>
    <p>XID: "} + bereq.xid + {"</p>
    <hr>
    <p>Varnish cache server</p>
  </body>
</html>
"};

  return (deliver);

}

################################################################################
# Housekeeping

sub vcl_init {

  return (ok);

}

sub vcl_fini {

  return (ok);

}
```

###### :small_blue_diamond: _static/error_maintenance.vcl

  > **type**: *file*  
  > *Contains error maintenance static site.*

###### :small_blue_diamond: _static/invalid_domain.vcl

  > **type**: *file*  
  > *Contains invalid domain static site.*

###### :small_blue_diamond: _static/synth_maintenance.vcl

  > **type**: *file*  
  > *Contains synth maintenance static site.*

###### :small_blue_diamond: _sub_vcl/cache.vcl

  > **type**: *file*  
  > *Rules for cache.*

```
/*
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
*/
```

###### :small_blue_diamond: acls/main.vcl

  > **type**: *file*  
  > *Contains access control lists.*

```
#
# Standard ACLs definitions.
#
acl localhost {

  "localhost";
  "127.0.0.1";
  "::1";

}

/*
acl acl_purge_internal {

  "10.255.253.10/32";

}

acl acl_purge_external {

  "41.194.61.3"/32;

}
*/

acl acl_forbidden_internal {

  "10.255.253.124/32";

}

acl acl_forbidden_external {

  "41.194.61.2"/32;

}

/*
acl acl_globals_internal {

  "10.255.10.0/24";
  "10.255.20.0/24";
  "10.255.30.0/24";
  "172.31.254.0/24";
  "192.168.0.0/16";

}

acl acl_globals_external {

  "216.129.67.216/32";
  "65.64.29.68/32";
  "88.151.87.220/32";

}
*/
```

###### :small_blue_diamond: backends/main.vcl

  > **type**: *file*  
  > *Main configuration file for backends*

```
#
# Standard backends definitions.
#
/*
backend BK_localhost {

  .host = "127.0.0.1";
  .port = "8080";

}

# ``````````````````````````````````````````````````````````````````````````````

#
# Include backends from external files.
#
include "/etc/varnish/master/domains/example.com/backends.vcl";
*/
```

###### :small_blue_diamond: backends/probes.vcl

  > **type**: *file*  
  > *Main configuration file with probes for backends.*

```
probe pb_basic {

    .url = "/";

    .interval   = 10s;
    .timeout    = 2s;
    .window     = 5;
    .threshold  = 3;

}

/*
probe pb_extended {

  .request =
    "GET /server-status.txt HTTP/1.1"
    "Host: *"
    "Connection: close"
    "User-Agent: Varnish Health Probe";

  .interval   = 10s;
  .timeout    = 2s;
  .window     = 5;
  .threshold  = 3;

}
*/
```

###### :small_blue_diamond: domains/example.com/main.vcl

  > **type**: *file*  
  > *Main configuration file for example.com domain.*

```
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
```

###### :small_blue_diamond: domains/example.com/backends.vcl

  > **type**: *file*  
  > *Main configuration file for example.com domain backends.*

```
backend BK_WEB_backend_0 {

  .host = "192.168.240.71";
  .port = "80";
  .probe = pb_basic;

}

backend BK_WEB_backend_1 {

  .host = "192.168.240.72";
  .port = "80";
  .probe = pb_basic;

}

# ``````````````````````````````````````````````````````````````````````````````

sub vcl_init {

  new example_com_lb = directors.round_robin();

  example_com_lb.add_backend(BK_WEB_backend_0);
  example_com_lb.add_backend(BK_WEB_backend_1);

}

sub vcl_init {

  new hash_ip_example_com_lb = directors.hash();

  hash_ip_example_com_lb.add_backend(BK_WEB_backend_0, 1.0);
  hash_ip_example_com_lb.add_backend(BK_WEB_backend_1, 1.0);

}
```
