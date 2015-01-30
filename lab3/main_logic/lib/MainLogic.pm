package MainLogic;
use Mojo::Base 'Mojolicious';

use MainLogic::Model::Users;

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	$self->helper(service_companies_port => sub { $ENV{SERVICE_COMPANIES_PORT} });
	$self->helper(service_session_port => sub { $ENV{SERVICE_SESSION_PORT} });
	$self->helper(service_front_port => sub { $ENV{SERVICE_FRONT_PORT} });
	$self->helper(service_aircrafts_port => sub { $ENV{SERVICE_AIRCRAFTS_PORT} });

	$self->helper(users_helper => sub { MainLogic::Model::Users->instance() });

	# Router
	my $r = $self->routes;

	# Normal route to controller
	my $access = $r->under('/')->to('dispatcher#check_access');

	$access->get('/me')->to('users#user_info');
	$access->get('/aircrafts/count')->to('aircrafts#count');
	$access->get('/companies/count')->to('companies#count');

	$access->get('/aircrafts')->to('aircrafts#list');
	$access->get('/aircrafts/:id')->to('aircrafts#info');

	$access->get('/companies')->to('companies#list');
	$access->get('/companies/:company_id')->to('companies#info');

	$access->post('/users')->to('users#add_user');

	$access->post('/aircrafts')->to('aircrafts#add');
	$access->put('/aircrafts')->to('aircrafts#update');
	$access->delete('/aircrafts')->to('aircrafts#delete');

	$access->post('/companies')->to('companies#add');
	$access->put('/companies')->to('companies#update');
	$access->delete('/companies')->to('companies#delete');

	$access->post('/sessions')->to('session#add');
	$access->delete('/sessions')->to('session#delete');

	#$access->any('/*whatever' => {whatever => ''} => sub {
	#	my $c = shift;
	#	my $whatever = $c->param('whatever');
	#	$c->render(
	#		json => {
	#			error => "/$whatever did not match.",
	#		},
	#		status => 404,
	#	);
	#});
}

1;
