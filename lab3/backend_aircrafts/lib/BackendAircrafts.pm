package BackendAircrafts;
use Mojo::Base 'Mojolicious';

use BackendAircrafts::Model::Aircrafts;

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');
	$self->helper(aircrafts_helper => sub { BackendAircrafts::Model::Aircrafts->instance() });

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/aircrafts/count')->to('aircrafts#count');

	$r->get('/aircrafts')->to('aircrafts#list');
	$r->get('/aircrafts/:id')->to('aircrafts#info');

	$r->post('/aircrafts')->to('aircrafts#add');

	$r->put('/aircrafts/')->to('aircrafts#edit');

	$r->delete('/aircrafts/')->to('aircrafts#delete');

	$r->any('/*whatever' => {whatever => ''} => sub {
		my $c = shift;
		my $whatever = $c->param('whatever');
		$c->render(
			json => {
				error => "/$whatever did not match.",
			},
			status => 404,
		);
	});
}

1;
