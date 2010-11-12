package Log::Structured;

use Moo;
use Sub::Quote;

use Time::HiRes qw(gettimeofday tv_interval);

has log_event_listeners => (
  is => 'ro',
  isa => quote_sub(q<
    die "log_event_listeners must be an arrayref!"
      unless ref $_[0] && ref $_[0] eq 'ARRAY';

    for (@{$_[0]}) {
      die "each log_event_listener must be an coderef!"
        unless ref $_ && ref $_ eq 'CODE';
    }
  >),
  default => quote_sub q{ [] },
);

has $_ => ( is => 'rw' ) for qw( category priority message );

has "log_$_" => ( is => 'rw' ) for qw(
  milliseconds_since_start milliseconds_since_last_log
  line file package subroutine category priority
  date host pid
);

sub add_log_event_listener {
  my $self = shift;

  die "each log_event_listener must be an coderef!"
    unless ref $_[1] && ref $_[1] eq 'CODE';

   push @{$self->log_event_listeners}, $_[1]
}

sub log_event {
   my $self = shift;
   my $event_data = shift;

   $self->${\"log_$_"} and $event_data->{$_} ||= $self->$_ for qw(
      milliseconds_since_start milliseconds_since_last_log
      line file package subroutine category priority
      date host pid
   );

   $self->$_($event_data) for @{$self->log_event_listeners}
}

sub milliseconds_since_start {
   int tv_interval(shift->{start_time}, [ gettimeofday ]) * 1000
}

sub milliseconds_since_last_log {
   int tv_interval(shift->{last_event}, [ gettimeofday ]) * 1000
}

sub line { shift->_caller->[2] }

sub file { shift->_caller->[1] }

sub package { shift->_caller->[0] }

sub subroutine { shift->_caller->[3] }

sub _caller {
  my $self = shift;
  my $depth = $self->{caller_depth} || 0;
  my $clan  = $self->{caller_clan};

  $depth += 2;

  if (defined $clan) {
    my $c; do {
      $c = caller ++$depth;
    } while $c && $c =~ $clan;
    return [caller $depth]
  } else {
    return [caller $depth]
  }
}

sub date { return [localtime] }

sub host {
  require Sys::Hostname;
  return Sys::Hostname::hostname()
}

sub pid { $$ }

1;
