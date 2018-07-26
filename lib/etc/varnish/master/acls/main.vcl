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
