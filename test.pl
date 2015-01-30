#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use IO::Socket;
use IO::Select;
use Data::Dumper;
use HTTP::Response;

use FCGI;
use CGI;

my $CLIENT_ID = '8js0ffpu4td31mzilpbxs6vnzj33c116';
my $CLIENT_SECRET = 'Xs7x95bWSGtqXYVFLH1dgizbYoxtpQ2j';

$ENV{"PERL_LWP_SSL_VERIFY_HOSTNAME"} = 0;

my $socket = FCGI::OpenSocket(":9000", 5);
my $request = FCGI::Request(\*STDIN, \*STDOUT, \*STDERR, \%ENV, $socket);

my %old_env;
foreach my $k (keys %ENV) {
    $old_env{$k} = $ENV{$k};
}
while((my $rr = $request->Accept()) >= 0) {
    print "Content-Type: text/html\r\n\r\n";
    my $q = CGI->new();
    my $env = $request->GetEnvironment();
    my $code = $q->param("code");
    print "<br>CODE: $code<br>";
    $ENV{"PERL_LWP_SSL_VERIFY_HOSTNAME"} = 0;
    my $ua = LWP::UserAgent->new();
    my $resp = $ua->post("https://app.box.com/api/oauth2/token", Content => "grant_type=authorization_code&code=$code&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET");
    my ($token) = ($resp->content() =~ /"access_token":"(.+?)"/);
    print "<br>TOKEN: $token<br>";
    $resp = $ua->get("https://api.box.com/2.0/users/me", Authorization => "Bearer $token");
    print Dumper $resp->content();
};
