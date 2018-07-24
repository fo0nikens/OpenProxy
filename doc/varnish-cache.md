#### Installation

  > Remember to make a copy of the current configuration and all files/directories.

The configuration for the Varnish server is located in **src/varnish-cache**.

It's very simple:

```bash
rsync -avur --delete lib/varnish-cache/* /
```

###### Which Varnish version?

This configuration was tested on **varnish-5.0.0 revision 99d036f**.
