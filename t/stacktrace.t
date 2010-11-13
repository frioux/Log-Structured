use strictures 1;
use Test::More;
use Test::Deep;

use Log::Structured;

my @var;

my $l_s = Log::Structured->new({
  log_stacktrace => 1,
  log_line => 1,
  log_subroutine => 1,
  log_package => 1,
  log_file => 1,
  log_event_listeners => [sub { push @var, $_[1] }],
});

$l_s->log_event({ message => 'shallow' });

sub foo { bar() }
sub bar { baz() }
sub baz { biff() }
sub biff {
   $l_s->log_event({ message => 'deep' });
}

foo();

# It's silly to test line number.  subroutine is just as unique and way more
# stable
cmp_deeply( $var[0], {
   package  => __PACKAGE__,
   file     => __FILE__,
   line     => ignore(),
   subroutine => 'Log::Structured::log_event',
   stacktrace => [
      [ __PACKAGE__, __FILE__, ignore(), 'Log::Structured::log_event', ( ignore() ) x 7],
   ],
   message  => 'shallow',
}, 'Shallow log event works');

cmp_deeply( $var[1], {
   package  => __PACKAGE__,
   file     => __FILE__,
   line     => ignore(),
   subroutine => 'Log::Structured::log_event',
   stacktrace => [
      [ __PACKAGE__, __FILE__, ignore(), 'Log::Structured::log_event', ( ignore() ) x 7],
      [ __PACKAGE__, __FILE__, ignore(), 'main::biff', ( ignore() ) x 7],
      [ __PACKAGE__, __FILE__, ignore(), 'main::baz', ( ignore() ) x 7],
      [ __PACKAGE__, __FILE__, ignore(), 'main::bar', ( ignore() ) x 7],
      [ __PACKAGE__, __FILE__, ignore(), 'main::foo', ( ignore() ) x 7],
   ],
   message  => 'deep',
}, 'Deep log event works');

done_testing;
