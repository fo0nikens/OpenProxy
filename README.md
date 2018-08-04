<p align="center">
    <img src="https://github.com/trimstray/OpenProxy/blob/master/doc/img/OpenProxy_preview.png"
        alt="Master">
</p>

<h4 align="center">:small_orange_diamond: still beta version :small_orange_diamond:</h4>

<br>

<p align="center">
  <a href="https://github.com/trimstray/OpenProxy/tree/master">
    <img src="https://img.shields.io/badge/Branch-master-green.svg?longCache=true"
        alt="Branch">
  </a>
  <a href="http://www.gnu.org/licenses/">
    <img src="https://img.shields.io/badge/License-GNU-blue.svg?longCache=true"
        alt="License">
  </a>
</p>

<div align="center">
  <sub>Created by
  <a href="https://twitter.com/trimstray">trimstray</a> and
  <a href="https://github.com/trimstray/OpenProxy/graphs/contributors">
    contributors
  </a>
</div>

<br>

***

### Introduction

The main goal of the **OpenProxy** project is to create a high-performance open source http and https proxy server for production environments.

If you don't want to use both services at the same time, nothing prevents you from using the configurations only for a specific service.

### Varnish Cache

<img src="https://github.com/trimstray/OpenProxy/blob/master/doc/img/varnish_software_logo.png" align="right">

  > Before using the **Varnish Cache** please read **[Introduction](https://varnish-cache.org/intro/)**.

<p align="justify"><b>Varnish Cache</b> is a web application accelerator also known as a caching HTTP reverse proxy. You install it in front of any server that speaks HTTP and configure it to cache the contents. Varnish Cache is really, really fast. It typically speeds up delivery with a factor of 300 - 1000x, depending on your architecture.</p>

To increase your knowledge, read **[Varnish Documentation](https://varnish-cache.org/docs/index.html)**.

###### Varnish Cache with OpenProxy

The next step should be to read the **[Varnish Cache OpenProxy documentation](https://github.com/trimstray/OpenProxy/blob/master/doc/varnish-cache.md)**.

### Nginx

<img src="https://github.com/trimstray/OpenProxy/blob/master/doc/img/nginx_logo.png" align="right">

  > Before using the **Nginx** please read **[Beginner’s Guide](http://nginx.org/en/docs/beginners_guide.html)**.

<p align="justify"><b>Nginx</b> (<i>/ˌɛndʒɪnˈɛks/ EN-jin-EKS</i>) is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server, originally written by Igor Sysoev. For a long time, it has been running on many heavily loaded Russian sites including Yandex, Mail.Ru, VK, and Rambler.</p>

To increase your knowledge, read **[Nginx Documentation](https://nginx.org/en/docs/)**.

###### Nginx with OpenProxy

The next step should be to read the **[Nginx OpenProxy documentation](https://github.com/trimstray/OpenProxy/blob/master/doc/nginx.md)**.

### Installation

  > Remember to make a copy of the current configuration and all files/directories.

It's very simple - full directory sync:

```bash
rsync -avur --delete lib/nginx/ /etc/nginx/
rsync -avur --delete lib/varnish-cache/ /etc/varnish/
```

For leaving your configuration (not recommended) remove `--delete` rsync param.

### Configuration

#### Initializing new domain

###### Varnish Cache

Added your domain definitions to **default.vcl**:

```bash
### BACKENDS DEFINITION
include "/etc/varnish/master/domains/your.domain/backends.vcl";

### DOMAINS DEFINITION
include "/etc/varnish/master/domains/your.domain/main.vcl";
```

Clone to your domain directory:

```bash
cd /etc/varnish/master/domains
cp -R example.com/ your.domain
```

and replace *example.com* to your domain name:

```bash
cd your.domain
sed -i 's/example.com/your.domain/g' *
sed -i 's/example_com/your_domain/g' *
```

  > Remember to adjust the configuration to your needs.

###### Nginx

Added your domain definitions to **domains.conf**:

```bash
cd /etc/nginx/master/
cat >> domains.conf << __EOF__
# Configuration for your.domain domain.
include                         /etc/nginx/master/_domains/your.domain/servers.conf;
include                         /etc/nginx/master/_domains/your.domain/backends.conf;
__EOF__

cd _domains
cp -R example.com/ your.domain
```

and replace *example.com* to your domain name:

```bash
cd domains/your.domain
sed -i 's/example.com/your.domain/g' *
sed -i 's/example_com/your_domain/g' *
```

  > Remember to adjust the configuration to your needs.

#### Aliases

Import aliases from `lib/etc/skel/aliases` to your shell init file and reload shell session with `exec $SHELL -l`.

#### Error pages

For example:

```bash
cd /usr/share/www/

git clone https://github.com/trimstray/http-error-pages && cd http-error-pages
./httpgen
```

#### Before init services

- reinit **systemd** configuration: `systemctl daemon-reload`
- adjust `/etc/default/varnish`

### Maintenance

##### Varnish Cache

###### Show config params

```bash
varnishadm param.show
varnishadm param.show max_retries
```

###### Show boot configuration

```bash
varnishadm vcl.show boot
```

###### Compile new configuration

```bash
varnishadm vcl.load config_name /etc/varnish/default.vcl
```

###### Load new configuration

```bash
varnishadm vcl.use config_name
```

###### Show backend list

```bash
varnishadm backend.list
```

###### Drop objects from cache

```bash
varnishadm ban req.http.host == example.com
varnishadm ban "req.http.host == example.com && req.url == /backend.*"
```

###### Show backends health

```bash
varnishlog -g raw -i Backend_health
```

###### Show all requests (without filters)

```bash
varnishlog -g request
```

###### Show all requests and responses (raw format)

```bash
varnishlog -g raw
```

###### Show requests with specific Host header

```bash
varnishlog -g request -q "ReqHeader eq 'Host: example.com'" -i Begin,ReqMethod,ReqUrl,ReqHeader
```

###### Show requests with specific User-Agent header

```bash
varnishlog -g request -q "ReqHeader eq 'User-Agent: x-bypass'"
```

###### Show requests with HTTP 200 status

```bash
varnishlog -i BackendOpen,BereqURL -q "BerespStatus == 200"
```

###### Show requests with HTTP 503 status from backends

```bash
varnishlog -d -q 'RespStatus == 503' -g request
```

###### Show requests with Backend Fetch Error

```bash
varnishlog -b -q 'FetchError'
```

### External resources

##### Varnish Cache

###### Base

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://varnish-cache.org/"><b>Varnish HTTP Cache Project</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/varnishcache/varnish-cache"><b>Varnish Cache source code repository</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/brandonwamboldt/varnish-dashboard"><b>Varnish Dashboard</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/mattiasgeniar/varnish-4.0-configuration-templates"><b>Varnish 4.0 Template</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/mattiasgeniar/varnish-5.0-configuration-templates"><b>Varnish 5.0 Template</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://opensource.com/business/16/2/getting-started-with-varnish-cache"><b>Getting started with web app accelerator Varnish Cache</b></a><br>
</p>

###### Cheatsheets

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://kly.no/varnish/regex.txt"><b>Varnish Regexp</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://docs.fastly.com/guides/vcl/vcl-regular-expression-cheat-sheet.html"><b>VCL regular expression cheat sheet</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.hostingadvice.com/how-to/varnish-regex/"><b>5 Basic Tips to Using Regular Expressions in Varnish</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://feryn.eu/blog/varnishlog-measure-varnish-cache-performance/"><b>Varnishlog: measure your Varnish cache performance</b></a><br>
</p>

###### Performance & Hardening

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/comotion/security.vcl"><b>Protect your websites with Varnish rules</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/varnish/varnish-modules"><b>Collection of Varnish Cache modules (vmods) by Varnish Software</b></a><br>
</p>
<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/nbs-system/naxsi"><b>WAF for Nginx</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://geekflare.com/install-modsecurity-on-nginx/"><b>ModSecurity for Nginx</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.upguard.com/blog/how-to-build-a-tough-nginx-server-in-15-steps"><b>How to Build a Tough NGINX Server in 15 Steps</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.cyberciti.biz/tips/linux-unix-bsd-nginx-webserver-security.html"><b>Top 25 Nginx Web Server Best Security Practices</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html"><b>Strong SSL Security on Nginx</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/denji/nginx-tuning"><b>Nginx Tuning For Best Performance by Denji</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://enable-cors.org/index.html"><b>Enable cross-origin resource sharing (CORS)</b></a><br>
</p>

##### Nginx

###### Base

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.nginx.com/"><b>Nginx Project</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/nginx/nginx"><b>Nginx official read-only mirror</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/h5bp/server-configs-nginx"><b>Nginx boilerplate configs</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/nginx-boilerplate/nginx-boilerplate"><b>Awesome Nginx configuration template</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/yandex/gixy"><b>Nginx static analyzer</b></a><br>
</p>

###### Cheatsheets

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://gist.github.com/carlessanagustin/9509d0d31414804da03b"><b>Nginx Cheatsheet</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/SimulatedGREG/nginx-cheatsheet"><b>Nginx Quick Reference</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://mijndertstuij.nl/writing/posts/nginx-cheatsheet/"><b>Nginx Cheatsheet by Mijdert Stuij</b></a><br>
</p>

###### Performance & Hardening

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/nbs-system/naxsi"><b>WAF for Nginx</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://geekflare.com/install-modsecurity-on-nginx/"><b>ModSecurity for Nginx</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.upguard.com/blog/how-to-build-a-tough-nginx-server-in-15-steps"><b>How to Build a Tough NGINX Server in 15 Steps</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.cyberciti.biz/tips/linux-unix-bsd-nginx-webserver-security.html"><b>Top 25 Nginx Web Server Best Security Practices</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html"><b>Strong SSL Security on Nginx</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/denji/nginx-tuning"><b>Nginx Tuning For Best Performance by Denji</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://enable-cors.org/index.html"><b>Enable cross-origin resource sharing (CORS)</b></a><br>
</p>

##### Comparison

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="http://www.bbc.co.uk/blogs/internet/entries/17d22fb8-cea2-49d5-be14-86e7a1dcde04"><b>BBC Digital Media Distribution: How we improved throughput by 4x</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/jiangwenyuan/nuster/wiki/Web-cache-server-performance-benchmark:-nuster-vs-nginx-vs-varnish-vs-squid"><b>Web cache server performance benchmark: nuster vs nginx vs varnish vs squid</b></a><br>
</p>

##### Log Analyzers

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://goaccess.io/"><b>GoAccess</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.graylog.org/"><b>Graylog</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.elastic.co/products/logstash"><b>Logstash</b></a><br>
</p>

##### Online tools

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://regexr.com/"><b>Online tool to learn, build, & test Regular Expressions</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.regextester.com/"><b>Online Regex Tester & Debugger</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.ssllabs.com/ssltest/"><b>SSL Server Test</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://cipherli.st/"><b>Strong ciphers for Apache, Nginx, Lighttpd and more</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://securityheaders.com/"><b>Analyse the HTTP response headers by Security Headers</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://observatory.mozilla.org/"><b>Analyze your website by Mozilla Observatory</b></a><br>
</p>

### :ballot_box_with_check: Todo

- [ ] Add more useful aliases
- [ ] Add more examples for varnish tools
- [ ] Automates initializing new domains

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

### License

GPLv3 : <http://www.gnu.org/licenses/>

**Free software, Yeah!**
