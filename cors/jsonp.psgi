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

    #$res->body(<<CODE);
#$callback_name({
    #msg: "message"
#});
#CODE

    $res->body("hoge");
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

    <script type="text/javascript">

        var xds = {
            load: function(url, callback, onerror) {
                var script = document.createElement("script");
                script.onload = script.onreadystatechange = function() {
                    if (xds.result) {
                        if (callback) callback.apply(xds, xds.result);
                    }
                    else if (onerror) {
                        onerror();
                    }
                };
                script.src = "/api/jsonp?callback=xds.callback";
                script.id = "jsonp-script";

                document.getElementsByTagName("head")[0].appendChild(script);
            },
            callback: function() {
                xds.result = arguments;
            }
        };

        document.addEventListener("DOMContentLoaded", function() {
            xds.load("/api/jsonp", function(result) {
                alert(result.msg);
            }, function() {
                alert("error");
            });
        }, false);

    </script>
</head>
<body>
</body>
</html>
