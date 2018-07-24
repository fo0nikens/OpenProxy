<h4 align="center">:small_orange_diamond: HTTP/HTTPS Proxy Stack with Varnish Cache and Nginx :small_orange_diamond:</h4>

<br>

<p align="center">
    <img src="https://github.com/trimstray/BIG-Proxy/blob/master/doc/img/BIG-Proxy_preview.png"
        alt="Master">
</p>

<br>

<p align="center">
  <a href="https://github.com/trimstray/BIG-Proxy/tree/master">
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
  <a href="https://github.com/trimstray/BIG-Proxy/graphs/contributors">
    contributors
  </a>
</div>

<br>

***

### Introduction

The main goal of this project is to create a high-performance proxy server for http and https traffic.

### Varnish Cache

<img src="https://github.com/trimstray/BIG-Proxy/blob/master/doc/img/varnish_software_logo.png" align="right">

  > Before using the **Varnish Cache** please read **[Introduction](https://varnish-cache.org/intro/)**.

**Varnish Cache** is a web application accelerator also known as a caching HTTP reverse proxy. You install it in front of any server that speaks HTTP and configure it to cache the contents. Varnish Cache is really, really fast. It typically speeds up delivery with a factor of 300 - 1000x, depending on your architecture.

To increase your knowledge, learn **[Varnish Documentation](https://varnish-cache.org/docs/index.html)**.

### Nginx

<img src="https://github.com/trimstray/BIG-Proxy/blob/master/doc/img/nginx_logo.png" align="right">

  > Before using the **Nginx** please read **[Beginner’s Guide](http://nginx.org/en/docs/beginners_guide.html)**.

**Nginx** (/ˌɛndʒɪnˈɛks/ EN-jin-EKS) is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server, originally written by Igor Sysoev. For a long time, it has been running on many heavily loaded Russian sites including Yandex, Mail.Ru, VK, and Rambler.

To increase your knowledge, learn **[Nginx Documentation](https://nginx.org/en/docs/)**.

### Resources

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
</p>

##### Nginx

###### Base

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://www.nginx.com/"><b>Nginx Project</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/nginx/nginx"><b>Nginx official read-only mirror</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/h5bp/server-configs-nginx"><b>Nginx boilerplate configs</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/nginx-boilerplate/nginx-boilerplate"><b>Awesome Nginx configuration template</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/yandex/gixy"><b>Nginx static analyzer</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/nbs-system/naxsi"><b>WAF for Nginx</b></a><br>
</p>

###### Cheatsheets

<p>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://gist.github.com/carlessanagustin/9509d0d31414804da03b"><b>Nginx Cheatsheet</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://github.com/SimulatedGREG/nginx-cheatsheet"><b>Nginx Quick Reference</b></a><br>
&nbsp;&nbsp;:small_orange_diamond: <a href="https://mijndertstuij.nl/writing/posts/nginx-cheatsheet/"><b>Nginx Cheatsheet by Mijdert Stuij</b></a><br>
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
</p>

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

### License

GPLv3 : <http://www.gnu.org/licenses/>

**Free software, Yeah!**
