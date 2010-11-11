use strictures 1;
use Test::More;
use JSON::XS;

use Log::Structured;

my $l_s = Log::Structured->new({
  log_line       => 1,
  log_file       => 1,
  log_package    => 1,
  log_subroutine => 1,
  log_category   => 1,
  log_priority   => 1,
  date           => 1,
  log_event_listeners => [sub {
    print encode_json( $_[1] ) . "\n"
  }],
});

$l_s->log_event({
   message => 'frew',
});

$l_s->log_event({
   message => 'frew',
   category => 'frew',
});

