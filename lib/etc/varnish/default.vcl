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
