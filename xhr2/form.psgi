use strict;
use warnings;

use Amon2::Lite;
use Data::Dump qw/dump/;

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
        warn dump $c->req->uploads;
        warn dump $c->req->parameters;
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

    <form id="form1" action="">
        <input type="text" name="text"/>
        <input type="password" name="password"/>
        <input type="file" name="file1"/>
        <select id="select" name="select">
        	<option value="value1">value1</option>
        	<option value="value2">value2</option>
        </select>
    </form>

    <form id="form2" action="">
        <input type="file" name="file2"/>
    </form>

    <input type="button" id="send" value="send" />

    <script type="text/javascript">
        function $(id) {
            return document.getElementById(id);
        }
        function $$(selector) {
            return document.querySelectorAll(selector);
        }

        function req(method, data, headers, callback) {
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
            xhr.send(data);
        }
        document.addEventListener("DOMContentLoaded", function() {

            $("send").addEventListener("click", function() {
                var form1 = $("form1");
                var form2 = $("form2");

                var formData = new FormData(form1);

                formData.append("foo", "bar");
                console.dir(form2.children[0].files[0]);
                formData.append("file2", form2.children[0].files[0]);
                console.dir(formData);

                req("POST", formData, {}, function(xhr) {
                    console.log("DONE");
                });
            }, false);
        }, false);
    </script>
</head>
<body>
</body>
</html>
