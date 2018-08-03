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
