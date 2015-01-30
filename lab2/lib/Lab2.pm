package Lab2;
use Mojo::Base 'Mojolicious';

use Lab2::Model::Users;
use Lab2::Model::Companies;
use Lab2::Model::Aircrafts;
use Lab2::Model::OAuth2;

sub startup {
	my $self = shift;

	$self->secrets(['signature']);
	$self->helper(usersh => sub { Lab2::Model::Users->instance() });
	$self->helper(aircraftsh => sub { Lab2::Model::Aircrafts->instance() });
	$self->helper(companiesh => sub { Lab2::Model::Companies->instance() });
	$self->helper(oauthh => sub { Lab2::Model::OAuth2->instance() });

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/')->to('main#index')->name('main');
	$r->get('/status')->to('main#status');

	$r->any([qw(GET POST)] => '/registration')->to('register#index')->name('index');
	$r->any([qw(GET POST)] => '/registration/apply')->to('register#register');

	$r->any([qw(GET POST)] => '/logout')->to('login#logout');
	$r->any([qw(GET POST)] => '/login')->to('login#index')->name('login');

	my $logged_in = $r->under('/resources')->to('login#logged_in');
	$logged_in->get('/me')->to('resource#me');

	$logged_in->get('/aircrafts')->to('resource#aircrafts');
	$logged_in->get('/companies')->to('resource#companies');

	$logged_in->get('/aircrafts/:id')->to('resource#aircraft');
	$logged_in->get('/companies/:id')->to('resource#company');

	$logged_in->get('/authorize')->to('OAuth2#authorize')->name('auth');
	$r->post('/access_token')->to('OAuth2#access_token');
	$r->post('/refresh_token')->to('OAuth2#refresh_token');
}

1;
