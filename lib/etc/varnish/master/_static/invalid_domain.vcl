set resp.http.Content-Type = "text/html; charset=utf-8";

synthetic({"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="Invalid Domain">
<title>Invalid Domain</title>
<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.6/css/all.css">
<style>
/* Error Page Styles */
body {
padding-top: 20px;
padding-left: 100px;
padding-right: 100px;
}
.base {
font-size: 12px;
font-weight: 400;
font-family: monospace;
line-height: 2;
color: inherit;
padding: 10px 0px;
}
.body-content {
font-size: 12px;
font-weight: 400;
font-family: monospace;
line-height: 2;
color: inherit;
padding: 0px 0px;
}
.h1 {
font-size: 24px;
font-weight: 700;
font-family: sans;
}
.h2 {
font-size: 11px;
font-weight: 400;
font-family: sans;
}
.base, .body-content {
text-align: left;
background-color: transparent;
}
.h2 {
padding-left: 35px;
padding-right: 35px;
}
.info {
padding-left: 42px;
padding-right: 42px;
white-space: pre-line;
}
/* Colors */
.green {
color:#5cb85c;
}
.orange {
color:#f0ad4e;
}
.red {
color:#d9534f;
}
</style>
</head>
<body>
<div class="container">
<div class="base">
<div class="h1"></h1><i class="fas fa-exclamation-triangle red"></i>&nbspInvalid Domain</h1></div>
</div>
</div>
<div class="container">
<div class="body-content">
<div class="h2"><h2>Invalid Domain</h2></div>
<p class="info">This domain is unsupported by the server</p>
<br><br>
<p class="info">Req ID: "} + req.xid + {"</p>
<!--
Error "} + resp.status + " " + resp.reason + {"
-->
</div>
</div>
</body>
</html>"});

/*
ALTERNATIVE:
synthetic({"
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Invalid Domain</title>
</head>
<body>
<div style="margin-left: 100px; margin-top: 100px">
<h1>This domain is unsupported by the serve</h1>
<br /><br /><br /><br /><br /><br />
<h6>Req ID: "} + req.xid + {"</h6>
<!--
Error "} + resp.status + " " + resp.reason + {"
-->
</div>
</body>
</html>"});
*/
