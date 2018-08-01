## Nginx version

This configuration was tested on **nginx/1.10.3**. Before installing the service, remember about the version with all available modules.

## Filesystem structure

```
tree lib/etc/nginx
lib/etc/nginx
├── dhparams_4096.pem
├── fastcgi.conf
├── fastcgi_params
├── koi-utf
├── koi-win
├── master
│   ├── _defaults
│   │   ├── acls
│   │   │   └── defaults.conf
│   │   ├── backends.conf
│   │   ├── certs
│   │   │   ├── defaults.key
│   │   │   └── nginx_defaults_bundle.crt
│   │   ├── commons
│   │   │   ├── http-defaults.common.conf
│   │   │   ├── http-localhost.common.conf
│   │   │   ├── https-defaults.common.conf
│   │   │   └── https-localhost.common.conf
│   │   └── servers.conf
│   ├── defaults.conf
│   ├── _domains
│   │   └── example.com
│   │       ├── acls
│   │       │   └── example.com.conf
│   │       ├── backends.conf
│   │       ├── certs
│   │       │   ├── example.com.key
│   │       │   └── nginx_example.com_bundle.crt
│   │       ├── commons
│   │       │   ├── http.example.com.conf
│   │       │   ├── https-csp.example.com.conf
│   │       │   └── https.example.com.conf
│   │       ├── credentials
│   │       │   └── template.txt
│   │       └── servers.conf
│   ├── domains.conf
│   ├── _globals
│   │   ├── acls
│   │   │   ├── globals.external.geo.acl
│   │   │   ├── globals.external.map.acl
│   │   │   ├── globals.internal.geo.acl
│   │   │   └── globals.internal.map.acl
│   │   ├── headers.conf
│   │   ├── main.conf
│   │   └── rate-limiting.conf
│   ├── globals.conf
│   └── _static
│       └── errors.conf
├── mime.types
├── modules.conf
├── nginx.conf
├── scgi_params
└── uwsgi_params

14 directories, 39 files
```

## Helpful aliases

```bash
alias nginx.test='nginx -t -c /etc/nginx/nginx.conf'
alias nginx.gen='systemctl reload nginx'
```

## Configuration (lib/etc/nginx)

###### :small_blue_diamond: nginx.conf

  > **type**: *file*  
  > *The main configuration file.*

In it there are global settings (`events` and `http` directives) and all included files.

```
user                            nginx;

worker_processes                2;
worker_rlimit_nofile            64000;

pid                             /var/run/nginx.pid;

error_log                       /var/log/nginx/error.log crit;

include                         /etc/nginx/modules.conf;

events {

  worker_connections            2048;
  # multi_accept                on;

}

http {

  include                       /etc/nginx/mime.types;

  include                       /etc/nginx/master/globals.conf;
  include                       /etc/nginx/master/localhost.conf;
  include                       /etc/nginx/master/defaults.conf;
  include                       /etc/nginx/master/domains.conf;

}
```

###### :small_blue_diamond: dhparams_4096.pem

  > **type**: *file*  
  > *Diffie Hellman Ephemeral Parameters.*

One of the first steps is to generate a new DH key:

```bash
openssl dhparam -out /etc/nginx/dhparam_4096.pem 4096
```

###### :small_blue_diamond: modules.conf

  > **type**: *file*  
  > *Contains paths to modules that may vary depending on the operating system.*

```
# Main module directory:
#   - /usr/lib/nginx/modules - main path
#   - /usr/share/nginx/modules - symbolic link

load_module                     /usr/share/nginx/modules/ndk_http_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_auth_pam_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_cache_purge_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_dav_ext_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_echo_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_fancyindex_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_geoip_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_headers_more_filter_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_image_filter_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_lua_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_perl_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_subs_filter_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_uploadprogress_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_upstream_fair_module.so;
load_module                     /usr/share/nginx/modules/ngx_http_xslt_filter_module.so;
load_module                     /usr/share/nginx/modules/ngx_mail_module.so;
load_module                     /usr/share/nginx/modules/ngx_nchan_module.so;
load_module                     /usr/share/nginx/modules/ngx_stream_module.so;
```

___

### Global configuration (lib/etc/nginx/master)

###### :small_blue_diamond: master/globals.conf

  > **type**: *file*  
  > *Contains global configuration settings.*

```
# Main configuration file.
include                         /etc/nginx/master/_globals/main.conf;

# Headers configuration.
include                         /etc/nginx/master/_globals/headers.conf;

# Rate limiting configuration.
include                         /etc/nginx/master/_globals/rate-limiting.conf;

# Global access lists.
include                         /etc/nginx/master/_globals/acls/globals.internal.geo.acl;
include                         /etc/nginx/master/_globals/acls/globals.internal.map.acl;
include                         /etc/nginx/master/_globals/acls/globals.external.geo.acl;
include                         /etc/nginx/master/_globals/acls/globals.external.map.acl;
```

###### :small_blue_diamond: master/_globals/acls

  > **type**: *directory*  
  > *Contains files related to access control lists built from **map**, **geo** modules and standard **allow/deny** directives.*

###### :small_blue_diamond: master/_globals/main.conf

  > **type**: *file*  
  > *Contains settings related to the standard, performance and optimization of the server.*

```
default_type                    application/octet-stream;

log_format main                 '$remote_addr - $remote_user [$time_local] '
                                '"$request_method $scheme://$host$request_uri '
                                '$server_protocol" $status $body_bytes_sent '
                                '"$http_referer" "$http_user_agent" '
                                '$request_time';

server_tokens                   off;

proxy_intercept_errors          on;
ignore_invalid_headers          on;
if_modified_since               before;
server_names_hash_max_size      1024;
tcp_nodelay                     off;
tcp_nopush                      on;
sendfile                        on;

keepalive_requests              100;
keepalive_timeout               65;

# proxy_buffering               off;
proxy_buffers                   4 256k;
proxy_buffer_size               128k;
proxy_busy_buffers_size         256k;
client_header_buffer_size       64k;
large_client_header_buffers     4 64k;

# Enable in the case of problems with large traffic.
# client_body_timeout           5s;
# client_header_timeout         5s
client_max_body_size            10m;

# If you use ssl disable compression.
gzip                            off;
```

###### :small_blue_diamond: master/_globals/headers.conf

  > **type**: *file*  
  > *Includes global headers settings.*

```
proxy_set_header                Host $host;

proxy_set_header                X-Real-IP $remote_addr;

# alternative:                  X-Forwarded-Proto $scheme;
proxy_set_header                X-Forwarded-Proto "https";

proxy_set_header                X-Forwarded-For $proxy_add_x_forwarded_for;

proxy_hide_header               X-Powered-By;

more_set_headers                "Server: Unknown";
```

###### :small_blue_diamond: master/_globals/rate-limiting.conf

  > **type**: *file*  
  > *Contains settings responsible for limiting connections to the server.*

```
# requests limiting
limit_req_zone                  $binary_remote_addr zone=per_ip_10r_s:20m rate=10r/s;
limit_req_zone                  $binary_remote_addr zone=per_ip_60r_s:200m rate=60r/s;
limit_req_zone                  $binary_remote_addr zone=per_ip_600r_s:200m rate=600r/s;
limit_req_zone                  $binary_remote_addr zone=per_ip_3000r_m:200m rate=3000r/m;

# connections limititng
limit_conn_zone                 $binary_remote_addr zone=per_ip_connections:200m;

# rate limiting POST method
map $request_method $limit_post_map {
    default                     "";
    POST                        $binary_remote_addr;
}

map $request_method $limit_post_per_vhost_map {
    default                     "";
    POST                        $server_name;
}

limit_req_zone                  $limit_post_map zone=per_ip_post_limit_50r_s:20m rate=50r/s;
limit_req_zone                  $limit_post_per_vhost_map zone=per_server_post_limit_30r_s:20m rate=30r/s;
limit_req_status                420;
```

___

### Configuration for default servers

###### :small_blue_diamond: master/defaults.conf

  > **type**: *file*  
  > *Contains localhost and default hosts configuration settings.*

```
# Localhost and default configuration.
include                         /etc/nginx/master/_defaults/servers.conf;
include                         /etc/nginx/master/_defaults/backends.conf;
```

###### :small_blue_diamond: master/_defaults/certs

  > **type**: *directory*  
  > *Contains certificates for localhost and default hosts.*

Generate self-signed certificates:

```bash
openssl req -x509 -nodes -newkey rsa:4096 -keyout defaults.key -out nginx_defaults_bundle.crt -days 365
```

###### :small_blue_diamond: master/_defaults/acls

  > **type**: *directory*  
  > *Contains files related to access control lists built from **map**, **geo** modules and standard **allow/deny** directives (for default servers).*

###### :small_blue_diamond: master/_defaults/servers.conf

  > **type**: *file*  
  > *Contains ocalhost and default hosts configuration for the specific ip address.*

```
server {

  include                       /etc/nginx/master/_defaults/http-localhost.common.conf;

  server_name                   default_server;

  location / {
    root                        /etc/nginx/master/_static/error-pages/sites/other;
  }

  access_log                    /var/log/nginx/defaults/localhost-access.log main;
  error_log                     /var/log/nginx/defaults/localhost-error.log crit;

}

server {

  include                       /etc/nginx/master/defaults/https-localhost.common.conf;

  server_name                   default_server;

  location / {
      root                      /etc/nginx/master/_static/error-pages/sites/other;
  }

  access_log                    /var/log/nginx/defaults/localhost-access.log main;
  error_log                     /var/log/nginx/defaults/localhost-error.log crit;

}

server {

  include                       /etc/nginx/master/_defaults/http-defaults.common.conf;

  server_name                   default_server;

  location / {
    root                        /etc/nginx/master/_static/error-pages/sites/other;
  }

  access_log                    /var/log/nginx/defaults/defaults-access.log main;
  error_log                     /var/log/nginx/defaults/defaults-error.log crit;

}

server {

  include                       /etc/nginx/master/_defaults/https-defaults.common.conf;

  server_name                   default_server;

  location / {
      root                      /etc/nginx/master/_static/error-pages/sites/other;
  }

  access_log                    /var/log/nginx/defaults/defaults-access.log main;
  error_log                     /var/log/nginx/defaults/defaults-error.log crit;

}
```

###### :small_blue_diamond: master/_defaults/backends.conf

  > **type**: *file*  
  > *Contains the default backends configuration for the loopback address.*

```
upstream default_backend {
  server 127.0.0.1:80           max_fails=3     fail_timeout=30s;
}
```

###### :small_blue_diamond: master/_defaults/commons/http-localhost.common.conf

  > **type**: *file*  
  > *Specific configuration for listen directives. This file is attached to every configuration file for a localhost.*

```
listen                          127.0.0.1:80;

root                            /etc/nginx/master/_static/error-pages/sites/other;

include                         /etc/nginx/master/_static/errors.conf;

add_header                      X-Frame-Options "SAMEORIGIN" always;
add_header                      X-XSS-Protection "1; mode=block" always;
add_header                      X-Content-Type-Options "nosniff" always;

add_header                      Allow "GET, POST, HEAD" always;

if ( $request_method !~ ^(GET|POST|HEAD)$ ) {

  return 405;

}
```

###### :small_blue_diamond: master/_defaults/commons/https-localhost.common.conf

  > **type**: *file*  
  > *Specific configuration for listen directives. This file is attached to every configuration file for a localhost (ssl enabled).*

```
listen                          127.0.0.1:443 ssl;

root                            /etc/nginx/master/_static/error-pages/sites/other;

ssl_certificate                 /etc/nginx/master/_defaults/certs/nginx_defaults_bundle.crt;
ssl_certificate_key             /etc/nginx/master/_defaults/certs/defaults.key;

ssl_session_cache               shared:SSL:10m;
ssl_session_timeout             10m;
ssl_protocols                   TLSv1.2;
ssl_prefer_server_ciphers       on;
ssl_ciphers                     AES256+EECDH:AES256+EDH:!aNULL;
# Uncomment if issued by the CA:
# ssl_stapling                  on;
# ssl_stapling_verify           on;
ssl_ecdh_curve                  secp384r1;
ssl_dhparam                     /etc/nginx/dhparams_4096.pem;

include                         /etc/nginx/master/_static/errors.conf;

add_header                      Content-Security-Policy "default-src 'none'" always;
add_header                      Strict-Transport-Security "max-age=63072000; includeSubdomains" always;
add_header                      Referrer-Policy "no-referrer";
add_header                      X-Frame-Options "SAMEORIGIN" always;
add_header                      X-XSS-Protection "1; mode=block" always;
add_header                      X-Content-Type-Options "nosniff" always;

add_header                      Allow "GET, POST, HEAD" always;

if ( $request_method !~ ^(GET|POST|HEAD)$ ) {

  return 405;

}
```

###### :small_blue_diamond: master/_defaults/commons/http-defaults.common.conf

  > **type**: *file*  
  > *Specific configuration for listen directives. This file is attached to every configuration file for a given domain.*

```
listen                          192.168.250.20:80;
listen                          192.168.250.21:80;

root                            /etc/nginx/master/_static/error-pages/sites/other;

include                         /etc/nginx/master/_static/errors.conf;

add_header                      X-Frame-Options "SAMEORIGIN" always;
add_header                      X-XSS-Protection "1; mode=block" always;
add_header                      X-Content-Type-Options "nosniff" always;

add_header                      Allow "GET, POST, HEAD" always;

if ( $request_method !~ ^(GET|POST|HEAD)$ ) {

  return 405;

}
```

###### :small_blue_diamond: master/_defaults/commons/https-defaults.common.conf

  > **type**: *file*  
  > *Specific configuration for listen directives. This file is attached to every configuration file for a given domain (ssl enabled).*

```
listen                          192.168.250.20:443 ssl;
listen                          192.168.250.21:443 ssl;

root                            /etc/nginx/master/_static/error-pages/sites/other;

ssl_certificate                 /etc/nginx/master/_defaults/certs/nginx_defaults_bundle.crt;
ssl_certificate_key             /etc/nginx/master/_defaults/certs/defaults.key;

ssl_session_cache               shared:SSL:10m;
ssl_session_timeout             10m;
ssl_protocols                   TLSv1.2;
ssl_prefer_server_ciphers       on;
ssl_ciphers                     AES256+EECDH:AES256+EDH:!aNULL;
# Uncomment if issued by the CA:
# ssl_stapling                  on;
# ssl_stapling_verify           on;
ssl_ecdh_curve                  secp384r1;
ssl_dhparam                     /etc/nginx/dhparams_4096.pem;

include                         /etc/nginx/master/_static/errors.conf;

add_header                      Content-Security-Policy "default-src 'none'" always;
add_header                      Strict-Transport-Security "max-age=63072000; includeSubdomains" always;
add_header                      Referrer-Policy "no-referrer";
add_header                      X-Frame-Options "SAMEORIGIN" always;
add_header                      X-XSS-Protection "1; mode=block" always;
add_header                      X-Content-Type-Options "nosniff" always;

add_header                      Allow "GET, POST, HEAD" always;

if ( $request_method !~ ^(GET|POST|HEAD)$ ) {

  return 405;

}
```

___

### Configuration for domains

###### :small_blue_diamond: master/domains.conf

  > **type**: *file*  
  > *Contains domain configuration settings (eg. example.com).*

```
# Configuration for example.com domain.
include                         /etc/nginx/master/_domains/example.com/servers.conf;
include                         /etc/nginx/master/_domains/example.com/backends.conf;
```

###### :small_blue_diamond: master/_domains/example.com/acls

  > **type**: *directory*  
  > *Contains files related to access control lists built from **map**, **geo** modules and standard **allow/deny** directives (for example.com).*

###### :small_blue_diamond: master/_domains/example.com/certs

  > **type**: *directory*  
  > *Contains certificates for example.com domain.*

###### :small_blue_diamond: master/_domains/example.com/servers.conf

  > **type**: *file*  
  > *Contains example.com domain configuration.*

```
server {

  include                       /etc/nginx/master/_domains/example.com/commons/http.example.com.conf;

  server_name                   example.com www.example.com;

  location / {

    return                      301 https://$server_name$request_uri;

  }

}

server {

  include                       /etc/nginx/master/_domains/example.com/commons/https-csp.example.com.conf;

  server_name                   example.com www.example.com;

  location / {

    proxy_pass                  http://localhost:80;
    client_max_body_size        100m;

  }

  location ~ ^/(backend|preview) {

    if ($globals_internal_geo_acl) {
      set $pass 1;
    }

    if ($pass = 1) {
      proxy_pass                http://example_com_backend;
    }

    if ($pass != 1) {
      rewrite                   ^(.*) https://example.com;
    }

    client_max_body_size        100m;

  }

  location ~ ^/admin {

    if ($globals_external_geo_acl) {
      set $pass 1;
    }

    if ($pass = 1) {
      proxy_pass                http://example_com_backend;
    }

    if ($pass != 1) {
      rewrite                   ^(.*) https://example.com;
    }

    client_max_body_size        20m;

  }

  access_log                    /var/log/nginx/domains/example.com/example.com-access.log main;
  error_log                     /var/log/nginx/domains/example.com/example.com-error.log crit;

}
```

###### :small_blue_diamond: master/_domains/example.com/backends.conf

  > **type**: *file*  
  > *Contains backends configuration for example.com domain.*

```
upstream example_com_backend {
  server 10.250.20.10:80        max_fails=3     fail_timeout=30s;
}
```

###### :small_blue_diamond: master/_domains/example.com/commons/http.example.com.conf

  > **type**: *file*  
  > *Specific configuration for example.com listen directives. This file is attached to every configuration file for a example.com domain.*

```
listen                          192.168.250.20:80;
listen                          192.168.250.21:80;

root                            /etc/nginx/master/_static/error-pages/sites/other;

include                         /etc/nginx/master/_static/errors.conf;

add_header                      X-Frame-Options "SAMEORIGIN" always;
add_header                      X-XSS-Protection "1; mode=block" always;
add_header                      X-Content-Type-Options "nosniff" always;

add_header                      Allow "GET, POST, HEAD" always;

if ( $request_method !~ ^(GET|POST|HEAD)$ ) {

    return 405;

}
```

###### :small_blue_diamond: master/_domains/example.com/commons/https.example.com.conf

  > **type**: *file*  
  > *Specific configuration for example.com listen directives. This file is attached to every configuration file for a example.com domain (ssl enabled).*

```
listen                          192.168.250.20:443 ssl;
listen                          192.168.250.21:443 ssl;

root                            /etc/nginx/master/_static/error-pages/sites/other;

ssl_certificate                 /etc/nginx/master/_domains/example.com/certs/nginx_example.com_bundle.crt;
ssl_certificate_key             /etc/nginx/master/_domains/example.com/certs/example.com.key;

ssl_session_cache               shared:SSL:10m;
ssl_session_timeout             10m;
ssl_protocols                   TLSv1.2;
ssl_prefer_server_ciphers       on;
ssl_ciphers                     AES256+EECDH:AES256+EDH:!aNULL;
# Uncomment if issued by the CA:
# ssl_stapling                  on;
# ssl_stapling_verify           on;
ssl_ecdh_curve                  secp384r1;
ssl_dhparam                     /etc/nginx/dhparams_4096.pem;

include                         /etc/nginx/master/_static/errors.conf;

add_header                      Strict-Transport-Security "max-age=63072000; includeSubdomains" always;
add_header                      Referrer-Policy "no-referrer";
add_header                      X-Frame-Options "SAMEORIGIN" always;
add_header                      X-XSS-Protection "1; mode=block" always;
add_header                      X-Content-Type-Options "nosniff" always;

add_header                      Allow "GET, POST, HEAD" always;

if ( $request_method !~ ^(GET|POST|HEAD)$ ) {

  return 405;

}
```

###### :small_blue_diamond: master/_domains/example.com/commons/https-csp.example.com.conf

  > **type**: *file*  
  > *Specific configuration for example.com listen directives. This file is attached to every configuration file for a example.com domain (ssl and csp enabled).*

```
listen                          192.168.250.20:443 ssl;
listen                          192.168.250.21:443 ssl;

root                            /etc/nginx/master/_static/error-pages/sites/other;

ssl_certificate                 /etc/nginx/master/_domains/example.com/certs/nginx_example.com_bundle.crt;
ssl_certificate_key             /etc/nginx/master/_domains/example.com/certs/example.com.key;

ssl_session_cache               shared:SSL:10m;
ssl_session_timeout             10m;
ssl_protocols                   TLSv1.2;
ssl_prefer_server_ciphers       on;
ssl_ciphers                     AES256+EECDH:AES256+EDH:!aNULL;
# Uncomment if issued by the CA:
# ssl_stapling                  on;
# ssl_stapling_verify           on;
ssl_ecdh_curve                  secp384r1;
ssl_dhparam                     /etc/nginx/dhparams_4096.pem;

include                         /etc/nginx/master/_static/errors.conf;

add_header                      Content-Security-Policy "default-src 'none'; script-src 'self' https://ssl.google-analytics.com; img-src 'self' https://ssl.   >  \google-analytics.com; style-src 'self' https://fonts.googleapis.com https://maxcdn.bootstrapcdn.com; font-src 'self' https://fonts.gstatic.com https://    >  \maxcdn.bootstrapcdn.com; object-src 'none'; frame-ancestors 'self'; base-uri 'self'; form-action 'self';";
add_header                      Strict-Transport-Security "max-age=63072000; includeSubdomains" always;
add_header                      Referrer-Policy "no-referrer";
add_header                      X-Frame-Options "SAMEORIGIN" always;
add_header                      X-XSS-Protection "1; mode=block" always;
add_header                      X-Content-Type-Options "nosniff" always;

add_header                      Allow "GET, POST, HEAD" always;

if ( $request_method !~ ^(GET|POST|HEAD)$ ) {

  return 405;

}
```

###### :small_blue_diamond: master/_domains/example.com/credentials

  > **type**: *directory*  
  > *Contains authorization data (login:pass).*

###### :small_blue_diamond: master/_static/errors.conf

  > **type**: *file*  
  > *Definition of error-pages (eg. from https://github.com/trimstray/http-error-pages).*

```
#
# Error pages from https://github.com/trimstray/http-error-pages.
#
# Copy errors.conf to your Nginx main directory (or other):
#   cp templates/nginx/errors.conf /etc/nginx/master/_static/errors.conf
#
# Generate static html files:
#   cd /etc/nginx/master/_static
#   git clone https://github.com/trimstray/http-error-pages
#   cd http-http-error-pages && ./httpgen
#
# Include this file to your Nginx server section:
#   server {
#     include /etc/nginx/master/_static/errors.conf;
#     [...]
#   }
#

########################################################################
########################### HTTP Codes: 3xx ############################
########################################################################

# No interception:
#   - 301, 302, 303

########################################################################
########################### HTTP Codes: 4xx ############################
########################################################################

# They may be specific to the project:
#   - 404, 406 (Laravel)

error_page 400 /400.html;
location = /400.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 401 /401.html;
location = /401.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 403 /403.html;
location = /403.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 404 /404.html;
location = /404.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 405 /405.html;
location = /405.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 406 /406.html;
location = /406.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 407 /407.html;
location = /407.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 408 /408.html;
location = /408.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 411 /411.html;
location = /411.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 413 /413.html;
location = /413.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 414 /414.html;
location = /414.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 415 /415.html;
location = /415.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

# Alternative: /rate-limit.html : see 'other' section.
error_page 429 /429.html;
location = /429.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

error_page 431 /431.html;
location = /431.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/4xx;
  internal;
}

########################################################################
########################### HTTP Codes: 5xx ############################
########################################################################

error_page 500 /500.html;
location = /500.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/5xx;
  internal;
}

error_page 501 /501.html;
location = /501.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/5xx;
  internal;
}

error_page 502 /502.html;
location = /502.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/5xx;
  internal;
}

error_page 503 /503.html;
location = /503.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/5xx;
  internal;
}

error_page 504 /504.html;
location = /504.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/5xx;
  internal;
}

error_page 505 /505.html;
location = /505.html {
  root /etc/nginx/master/_static/http-error-pages/sites/errors/5xx;
  internal;
}

########################################################################
################################ Other #################################
########################################################################

# error_page 100 /temporary_maintenance.html;
# location = /temporary_maintenance.html {
#   root /etc/nginx/master/_static/http-error-pages/sites/other;
#   internal;
# }

# error_page 429 /rate-limit.html;
# location = /rate_limit.html {
#   root /etc/nginx/master/_static/http-error-pages/sites/other;
#   internal;
# }
```
