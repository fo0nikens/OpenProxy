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
