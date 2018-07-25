## Which Nginx version?

This configuration was tested on **nginx/1.10.3**. Before installing the service, remember about the version with all available modules.

## Configuration

### :white_square_button: nginx/nginx.conf

The main configuration file. In it there are global settings (`events` and `http` directives) and all included files.

```
include                         /etc/nginx/modules.conf;

user                            nginx;

worker_processes                2;
worker_rlimit_nofile            64000;

pid                             /var/run/nginx.pid;

error_log                       /var/log/nginx/error.log crit;

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

### :white_square_button: nginx/dhparams_4096.pem

One of the first steps is to generate a new DH key:

```bash
openssl dhparam -out /etc/nginx/dhparam_4096.pem 4096
```

### :white_square_button: nginx/modules.conf

It contains paths to modules that may vary depending on the operating system.

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

### :white_square_button: nginx/master/globals.conf

This file contains global configuration settings. All files are in the `nginx/master/_globals` directory.

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

#### :arrow_right: nginx/master/_globals

##### main.conf

It mainly contains settings related to the performance and optimization of the server.

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

# Enabling in the case of problems with large traffic.
# client_body_timeout           5s;
# client_header_timeout         5s
client_max_body_size            10m;

# If you use ssl disable compression.
gzip                            off;
```

##### headers.conf

Includes global headers settings.

```
proxy_set_header                Host $host;

proxy_set_header                X-Real-IP $remote_addr;

# alternative:                  X-Forwarded-Proto $scheme;
proxy_set_header                X-Forwarded-Proto "https";

proxy_set_header                X-Forwarded-For $proxy_add_x_forwarded_for;

proxy_hide_header               X-Powered-By;

more_set_headers                "Server: Unknown";
```

##### rate-limiting.conf

Contains settings responsible for limiting connections to the server.

```
# requests limiting
limit_req_zone                  $binary_remote_addr zone=per_ip_10r_s:20m rate=10r/s;
limit_req_zone                  $binary_remote_addr zone=per_ip_60r_s:200m rate=60r/s;
limit_req_zone                  $binary_remote_addr zone=per_ip_600r_s:200m rate=600r/s;
limit_req_zone                  $binary_remote_addr zone=per_ip_3000r_m:200m rate=3000r/m;

# connections limititng
limit_conn_zone                 $binary_remote_addr zone=per_ip_connections:200m;

# ratelimiting POST method
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

##### acls/

It contains files related to access control lists built from **map**, **geo** modules and standard **allow/deny** directives.

### :white_square_button: nginx/defaults.conf

This file contains localhost and defaults configuration settings. All files are in the `nginx/master/_defaults` directory.

```
# Localhost and default configuration.
include                         /etc/nginx/master/_defaults/servers.conf;
include                         /etc/nginx/master/_defaults/backends.conf;
```

#### :arrow_right: nginx/master/_defaults

##### servers.conf

It contains the default and localhost configuration for the ip address on which the service listens.

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

##### backends.conf

It contains the default backends configuration for the loopback address.

```
upstream default_backend {
  server 127.0.0.1:80           max_fails=3     fail_timeout=30s;
}

upstream static_default_backend {
  server 127.0.0.1:8000         max_fails=3     fail_timeout=30s;
}
```

##### certs/

Contains certificates.

##### commons/

Contains a specific configuration for listen directives. This file is attached to every configuration file for a given domain.

###### http-localhost.common.conf

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

###### https-localhost.common.conf

```
listen                          127.0.0.1:443 ssl;

root                            /etc/nginx/master/_static/error-pages/sites/other;

ssl_certificate                 /etc/nginx/master/_defaults/certs/nginx_localhost_bundle.crt;
ssl_certificate_key             /etc/nginx/master/_defaults/certs/localhost.key;

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

###### http-defaults.common.conf

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

###### https-localhost.common.conf

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

### :white_square_button: nginx/domains.conf

This file contains domains configuration settings. All files are in the `nginx/master/_domains` directory.

```
# Configuration for example.com domain.
include                         /etc/nginx/master/_domains/example.com/servers.conf;
include                         /etc/nginx/master/_domains/example.com/backends.conf;
```

#### :arrow_right: nginx/master/_domains/example.com

##### servers.conf

It contains the example.com domain configuration for the ip address on which the service listens.

```
server {

  include                       /etc/nginx/master/_domains/example.com/commons/http.common.conf;

  server_name                   example.com www.example.com;

  location / {

    return                      301 https://$server_name$request_uri;

  }

}

server {

  include                       /etc/nginx/master/_domains/example.com/commons/https-csp.common.conf;

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
      proxy_pass                http://localhost:80;
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
      proxy_pass                http://admin_example_com_backend;
    }

    if ($pass != 1) {
      rewrite                   ^(.*) https://example.com;
    }

    client_max_body_size        20m;

  }

  access_log                    /var/log/nginx/domains/example.com/example.com-access.log main;
  error_log                     /var/log/nginx/domains/example.com/example.com-error.log crit;

}

server {

  include                       /etc/nginx/master/_domains/example.com/commons/https.common.demo.conf;

  server_name                   demo.example.com;

  satisfy                       any;

  include                       /etc/nginx/master/_domains/example.com/acls/demo.conf;

  auth_basic                    "Restricted access";
  auth_basic_user_file          /etc/nginx/master_domains/example.com/credentials/demo.txt;

  deny                          all;

  location / {

    proxy_pass                  http://localhost:80;
    client_max_body_size        100m;

  }

  access_log                    /var/log/nginx/domains/example.com/demo.example.com-access.log main;
  error_log                     /var/log/nginx/domains/example.com/demo.example.com-error.log crit;

}
```

##### backends.conf

It contains the default backends configuration for the loopback address.

```
upstream admin_example_com_backend {
  server 10.250.20.10:80        max_fails=3     fail_timeout=30s;
}
```

##### acls/

It contains files related to access control lists built from **map**, **geo** modules and standard **allow/deny** directives.

##### certs/

Contains certificates for example.com.

##### commons/

Contains a specific configuration for listen directives. This file is attached to every configuration file for a given domain.

###### http.common.conf

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

###### https.common.conf

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

###### https-csp.common.conf

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

##### credentials/

It contains authorization data (login:pass).
