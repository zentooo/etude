use strict;
use warnings;

use Amon2::Lite;


get '/jsonp' => sub {
    my ($c, $p) = @_;
    return $c->render("index.tt");
};

any '/api/jsonp' => sub {
    my ($c, $p) = @_;

    my $callback_name = $c->req->parameters->{callback} || 'callback';

    my $res = $c->req->new_response(200);

    $res->body(<<CODE);
$callback_name({
    msg: "message"
});
CODE
    #$res->body("hoge");

    $res->header("Content-Type", "application/javascript");
    return $res;
};


__PACKAGE__->load_plugins(qw/
    Web::JSON
/);
__PACKAGE__->to_app;

__DATA__

@@ index.tt

<!DOCTYPE HTML>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title></title>
</head>
<body>
    <script type="text/javascript">
        var xds = {
            load: function(url, callback, onerror) {
                var script = document.createElement("script");

                script.onload = script.onreadystatechange = function() {
                    if ( this.readyState && this.readyState !== "loaded" ) return;

                    if (xds.result) {
                        if (callback) callback.apply(xds, xds.result);
                    }
                    else if (onerror) {
                        onerror();
                    }

                    script.parentNode.removeChild(script);
                };
                script.src = "/api/jsonp?callback=xds.callback";

                document.getElementsByTagName("head")[0].appendChild(script);
            },
            callback: function() {
                xds.result = arguments;
            },

            load2: function(url, callback, onerror, retry, callback_key) {
                var ifr = document.createElement("iframe");
                ifr.style.display = "none";
                document.body.appendChild(ifr);
                var d = ifr.contentWindow.document;
                var cnt = 0;
                ifr[ifr.readyState/*IE*/ ? "onreadystatechange" : "onload"] = function() {
                    if (this.readyState && this.readyState != 'complete' || cnt++) return;
                    if (d.x) {
                        if (callback) callback.apply(this, d.x);
                    } else if (retry && retry > 1) {
                        setTimeout(function(){ xds.load(url, callback, onerror, retry-1) }, 1000);
                    } else if (onerror)
                        onerror();
                    setTimeout(function(){ try { ifr.parentNode.removeChild(ifr); } catch(e) {} }, 0);
                };
                var url2 = url + (url.indexOf('?')<0?'?':'&') +
                    (callback_key?callback_key:'callback') + '=cb';
                d.write('<scr'+'ipt>function cb(){document.x=arguments}</scr'+'ipt>' +
                    '<scr'+'ipt src="'+url2+'"></scr'+'ipt>');
                d.close();
                return ifr;
            },

        };

        xds.load("/api/jsonp", function(result) {
            alert(result.msg);
        }, function() {
            alert("error");
        });
    </script>
</body>
</html>
