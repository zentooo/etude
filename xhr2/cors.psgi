use strict;
use warnings;

use Amon2::Lite;


get '/xhr2' => sub {
    my ($c, $p) = @_;
    return $c->render("index.tt");
};

any '/api/xhr2' => sub {
    my ($c, $p) = @_;

    if ( $c->req->method eq "OPTIONS" ) {
        if ( my $header = $c->req->header("Access-Control-Request-Method") ) {
            my $res = $c->req->new_response(200);
            $res->header("Access-Control-Allow-Origin", "http://localhost:11000");
            $res->header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
            $res->header("Access-Control-Max-Age", "2520");
            return $res;
        }
    }
    else {
        my $res = $c->render_json(+{ data => { foo => 'bar' } });
        $res->header("Access-Control-Allow-Origin", "http://localhost:11000");
        #$res->header("Access-Control-Allow-Methods", "PUT");
        return $res;
    }
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

    <select id="method" name="method">
    	<option value="GET" selected="selected">GET</option>
    	<option value="POST">POST</option>
    	<option value="PUT">PUT</option>
    	<option value="DELETE">DELETE</option>
    	<option value="OPTIONS">OPTIONS</option>
    </select>

    <select id="headers" name="headers" multiple>
    	<option value="Cache-Control">cache-control</option>
    	<option value="X-Hogehoge">x-hogehoge</option>
    </select>

    <input type="button" id="send" value="send" />

    <script type="text/javascript">
        function $(id) {
            return document.getElementById(id);
        }
        function $$(selector) {
            return document.querySelectorAll(selector);
        }

        function req(method, headers, callback) {
            var xhr = new XMLHttpRequest();

            xhr.open(method, "http://localhost:12000/api/xhr2");

            if ( typeof headers === "object" ) {
                for ( var k in headers ) {
                    xhr.setRequestHeader(k, headers[k]);
                }
            }
            xhr.onreadystatechange = function() {
                if ( xhr.readyState === xhr.DONE ) {
                    callback(xhr);
                }
            };
            xhr.send();
        }
        document.addEventListener("DOMContentLoaded", function() {
            var method = "GET";
            //var headers = { "Cache-Control": "no-cache" };
            var headers = { "Access-Control-Request-Method": "PUT" };

            $("method").addEventListener("change", function() {
                Array.prototype.forEach.call($$("#method option"), function(el) {
                    if ( el.selected === true ) {
                        method = el.value;
                    }
                });
            }, false);

            $("headers").addEventListener("change", function() {
                Array.prototype.forEach.call($$("#headers option"), function(el) {
                    if ( el.selected === true ) {
                        headers[el.value] = 1;
                    }
                });
            }, false);

            $("send").addEventListener("click", function() {
                console.log(method);
                console.dir(headers);
                req(method, headers, function(xhr) {
                });
            }, false);
        }, false);
    </script>
</head>
<body>
</body>
</html>
