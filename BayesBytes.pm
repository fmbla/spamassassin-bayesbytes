=head1 NAME

Mail::SpamAssassin::Plugin::BayesBytes - make 3 byte tokens of a message
for better naive Bayes

=head1 LICENSE

Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to you under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License.  You may obtain a copy of the License at:

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 AUTHOR

Paul Stead <paul.stead@gmail.com>

=cut

package Mail::SpamAssassin::Plugin::BayesBytes;
my $VERSION = 0.01;

use strict;
use Mail::SpamAssassin::Plugin;
use File::Basename;

use vars qw(@ISA);
@ISA = qw(Mail::SpamAssassin::Plugin);

sub dbg { Mail::SpamAssassin::Plugin::dbg ("BayesBytes: @_"); }

sub new
{
  my ($class, $mailsa) = @_;

  $class = ref($class) || $class;
  my $self = $class->SUPER::new($mailsa);
  bless ($self, $class);

  $self->set_config($mailsa->{conf});
  $self->register_eval_rule("check_bayesbytes");

  $self;
}

sub set_config {
  my ($self, $conf) = @_;
  my @cmds = ();
  push(@cmds, {
    setting => 'bayesbytes_length',
    default => 3,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_INT,
    }
  );

  $conf->{parser}->register_commands(\@cmds);
}

sub extract_metadata {
  my ($self, $opts) = @_;
  my $pms = $opts->{permsgstatus};
  my $msg = $opts->{msg};

  return unless ($msg->can ("put_metadata"));

  my $bayesbytes = '';

  my $bodyc = join(" ", @{$pms->{msg}->get_visible_rendered_body_text_array()});
  for (my $i=length($bodyc)-3; $i>=0; $i--) {
    $bayesbytes .= join(",", unpack ('U*', substr ($bodyc, $i, 3 ))).' ';
  }

  chop $bayesbytes;

  if ($bayesbytes ne '') {
    $msg->put_metadata("X-SA-BayesBytes", $bayesbytes);
  }

  return 1;
}

sub check_post_learn {
  my ($self, $opts) = @_;

  my $bayesbytes =
    $opts->{permsgstatus}->get_message->get_metadata('X-SA-BayesBytes');

  return unless $bayesbytes;

  $opts->{permsgstatus}->get_message->delete_metadata('X-SA-BayesBytes');

  return 1;
}

sub check_bayesbytes
{
  return 0;
}

1;
