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

    $c->render('index.tt');
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
    <style type="text/css">
        #frame {
            background-color: blue;
        }
    </style>
</head>
<body>
    <div id="frame">
        <button id="enter">enter</button>
        <button id="exit">exit</button>
    </div>
    <script type="text/javascript">
        var frame = document.getElementById("frame");
        document.getElementById("enter").addEventListener("click", function(evt) {
            frame.mozRequestFullScreen();
        }, false);
        document.getElementById("exit").addEventListener("click", function(evt) {
            frame.mozCancelFullScreen();
            mozCancelFullScreen();
        }, false);
    </script>
</body>
</html>
