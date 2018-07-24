#### Installation

  > Remember to make a copy of the current configuration and all files/directories.

The configuration for the Nginx server is located in **src/nginx**.

It's very simple:

```bash
rsync -avur --delete lib/nginx/* /
```

###### Which Nginx version?

This configuration was tested on **nginx/1.10.3**. Before installing the service, remember about the version with all available modules.

#### Configuration

##### nginx/nginx.conf

The main configuration file. In it there are global settings (`events` and `http` directives) and all included files.

##### nginx/dhparams_4096.pem

One of the first steps is to generate a new DH key:

```bash
openssl dhparam -out /etc/nginx/dhparam_4096.pem 4096
```

##### nginx/modules.conf

It contains paths to modules that may vary depending on the operating system.

##### nginx/master/globals.conf

This file contains global configuration settings. All files are in the `nginx/master/_globals` directory.

###### nginx/master/_globals

**main.conf**

It mainly contains settings related to the performance and optimization of the server.

**headers.conf**

Includes global headers settings.

**rate-limiting.conf**

Contains settings responsible for limiting connections to the server.

**acls/**

It contains files related to access control lists built from **map** and **geo** modules.
