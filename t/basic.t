use strictures 1;
use Test::More;
use Test::Deep;

use Log::Structured;

my $var;

my $l_s = Log::Structured->new({
  category => 'CORE',
  priority => 'DEBUG',
  log_line       => 1,
  log_file       => 1,
  log_package    => 1,
  log_subroutine => 1,
  log_category   => 1,
  log_priority   => 1,
  log_event_listeners => [sub { $var = $_[1] }],
});

$l_s->log_event({
   message => 'frew',
});

cmp_deeply( $var, {
   line     => __LINE__ - 5,
   package  => __PACKAGE__,
   subroutine => 'Log::Structured::log_event',
   category => 'CORE',
   priority => 'DEBUG',
   message  => 'frew',
   file     => __FILE__,
}, 'simple log event works');

$l_s->log_event({
   message => 'frew',
   category => 'frew',
});

cmp_deeply( $var, {
   line     => __LINE__ - 6,
   package  => __PACKAGE__,
   subroutine => 'Log::Structured::log_event',
   category => 'frew',
   priority => 'DEBUG',
   message  => 'frew',
   file     => __FILE__,
}, 'overriding category works');

done_testing;
