package Dist::Zilla::Plugin::LatestPrereqs;

use Moose;
use CPAN;
with 'Dist::Zilla::Role::PrereqSource';

sub register_prereqs {
  my ($self) = @_;
  my $zilla = $self->zilla;

  my $prereqs = $zilla->prereq;
  my $cpan    = _startup_cpan();

  my $guts = $prereqs->_guts;
  for my $phase (keys %$guts) {
    for my $type (keys %{$guts->{$phase}}) {
      my $prereqs = $guts->{$phase}{$type}->as_string_hash;

      for my $module (keys %$prereqs) {
        $self->log_debug("Check version of '$module', type '$type' for phase '$phase'");
        ## allow for user defined required version
        next if $prereqs->{$module};

        ## fetch latest version
        $self->log_debug("Fetch latest version for '$module' from CPAN");
        my $info = $cpan->expand('Module', $module);
        next unless my $version = $info->cpan_version;

        ## register the latest version
        $self->log_debug("Update version of '$module' to '$version'");
        $zilla->register_prereqs(
          { type  => $type,
            phase => $phase,
          },
          $module => $version,
        );
      }
    }
  }
}

sub _startup_cpan {
  ## Hide output of CPAN
  $CPAN::Be_Silent++;

  return 'CPAN::Shell';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__


=head1 NAME

Dist::Zilla::Plugin::LatestPrereqs - adjust prereqs to use latest version available


=head1 SYNOPSIS

At the B<BOTTOM> of your C<dist.ini> file:

    [LatestPrereqs]


=head1 DESCRIPTION

This plugin will filter over all your declared or discovered
prerequisites, contact CPAN, and adjust the version to the latest one
available.

This will make sure that your module will be installed with the latest
version available on CPAN at the time you built your package.

The most common use for this techinique is for L<Task> modules. You can
rebuild your Task module on a regular basis to make sure it has the
latest versions of your dependencies.

Please note that this plugin only makes sure that the version of the
prereq is the latest at the time you build your package, not the latest
at the time the package is installed.

To do that it would require updates to the CPAN toolchain. Although I
would welcome that, this plugin implements the next best thing.


=head1 EXTRA REQUIREMENTS

This plugin uses the L<CPAN> module, but hides the output, so make sure
you have your cpan shell properly configured before trying to use this.


=head1 CREDITS

Marcel Gruenauer (hanekomu) described something like this in his
article "Repeatedly installing Task::* distributions":

L<http://hanekomu.at/blog/dev/20091005-1227-repeatedly_installing_task_distributions.html>

But the method he suggested does not work because it does not force the
latest version of the module to be installed.

A L<Dist::Zilla> plugin that implements what Marcel describes is also
available, see L<Dist::Zilla::Plugin::MakeMaker::SkipInstall>.


=head1 SEE ALSO

L<Dist::Zilla>, L<Dist::Zilla::Plugin::MakeMaker::SkipInstall>.


=head1 AUTHOR

Pedro Melo, C<< <melo at cpan.org> >>


=head1 COPYRIGHT & LICENSE

Copyright 2009-2010 Pedro Melo.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=begin make-pod-coverage-happy

=over 4

=item register_prereqs()

Loops over all the given prereqs and uses L<CPAN> to figure out which is
the latest version of the module.

=back

=end make-pod-coverage-happy

=cut
