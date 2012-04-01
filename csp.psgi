use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;

our $VERSION = '0.01';


get '/' => sub {
    my $c = shift;

    my $res = $c->render('index.tt');

    my @policies = (
        "allow 'self'",
        "default-src localhost:5000",
        #"frame-src *",
        "frame-src zentooo.biz",
        #"img-src *",
        "img-src secure.gravatar.com",
        #"media-src *",
        "media-src yourfilehost.com",
        #"script-src *",
        "script-src zentooo.biz",
        "report-uri http://localhost:5000/report",
    );

    my $policy = join("; ", @policies);

    warn $policy;

    $res->header('X-Content-Security-Policy', $policy);
    #$res->header('X-Content-Security-Policy-Report-Only', $policy);
    #$res->header('X-Content-Security-Policy', 'policy-uri http://localhost:5000/policy');

    $res->header('X-Webkit-CSP', $policy);

    return $res;
};

post '/report' => sub {
    my $c = shift;
    use Data::Dump qw/dump/;

    warn dump $c->req->content;

    $c->render('index.tt');
};

get '/policy' => sub {
    my $c = shift;

    my $res = $c->req->new_response;
    $res->status(200);
    $res->header("Content-Type", "text/x-content-security-policy");
    $res->body(<<POLICY);
allow: 'self'; script-src *;
POLICY

    return $res;
};

# load plugins

__PACKAGE__->enable_session();
__PACKAGE__->to_app(handle_static => 1);

__DATA__

@@ index.tt
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>webapp</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js"></script>
    <script type="text/javascript" src="[% uri_for('/static/js/main.js') %]"></script>
    <link rel="stylesheet" href="http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css">
    <link rel="stylesheet" href="[% uri_for('/static/css/main.css') %]">
</head>
<body>

    <h1>Script Executions</h1>

    <h2>Inline Script</h2>
    <script type="text/javascript">
        alert("Hello, this is inline JavaScript!");
    </script>

    <h2>javascript: URI</h2>
    <a href="javascript:xss()">href="javascript:xss()"</a>

    <h2>onclick attribute</h2>
    <a onclick="xss()">onclick="xss()"</a>


    <h1>Execute Strings</h1>

    <h2>eval</h2>
    <script type="text/javascript">
        document.addEventListener("DOMContentLoaded", function() {
            do_eval("alert('This is evil eval.');");
        }, false);
    </script>

    <h2>setTimeout</h2>
    <script type="text/javascript">
        document.addEventListener("DOMContentLoaded", function() {
            do_timeout("alert('This is evil timeout.');");
        }, false);
    </script>

    <h2>new Function()</h2>
    <script type="text/javascript">
        document.addEventListener("DOMContentLoaded", function() {
            do_function("alert('This is evil new Function().');");
        }, false);
    </script>


    <h1>Resources</h1>

    <h2>Iframe with other domain (zentooo.biz)</h2>
    <iframe src="http://zentooo.biz/" frameborder="0"></iframe>

    <h2>Iframe with other domain (nilnil.info)</h2>
    <iframe src="http://nilnil.info/" frameborder="0"></iframe>

    <h2>Image hosted on other domain (twimg0-a.akamaihd.net)</h2>
    <img src="https://twimg0-a.akamaihd.net/profile_images/1379864305/3f2beb73b92a9fcefb3391a90043d5f5.png" frameborder="0"></img>

    <h2>Image hosted on other domain (secure.gravatar.com)</h2>
    <img src="https://secure.gravatar.com/avatar/6a4f5a57f6afbcff5bb4f69935cdc3db?s=140&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png" frameborder="0"></img>

    <h2>Video hosted on other domain (nilnil.info)</h2>
    <video src="http://nilnil.info/output.mp4"></video>

    <h2>Script hosted on other domain (zentooo.biz)</h2>
    <div id="zentooo"></div>
    <script type="text/javascript" src="http://zentooo.biz/js/csp.js"></script>

    <h2>Script hosted on other domain (nilnil.info)</h2>
    <div id="nilnil"></div>
    <script type="text/javascript" src="http://nilnil.info/js/csp.js"></script>


</body>
</html>

@@ /static/js/main.js
alert("Hello, this is JavaScript loaded from white-listed source!");

function do_eval(string) {
    eval(string);
}

function do_timeout(string) {
    setTimeout(string, 500);
}

function do_function(string) {
    var f = new Function(string);
    f();
}

function xss() {
    alert("Hello, this is JavaScript function loaded from white-listed source!");
}

@@ /static/css/main.css
h1 {
    margin-top: 60px;
}
footer {
    text-align: right;
}
