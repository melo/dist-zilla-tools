package Dist::Zilla::Plugin::MakeMaker::SkipInstall;

use Moose;

with 'Dist::Zilla::Role::AfterBuild';

has filename => (
  isa => 'Str',
  is  => 'ro',
  default =>  'Makefile.PL',
);

sub after_build {
  my ($self, $args) = @_;
  my $build_root = $args->{build_root};
  my $filename = $build_root->file($self->filename);
  
  my $content = $filename->slurp;
  
  my ($pre, $post) = split(/^\s*WriteMakefile[(]/sm, $content);
  $content = $pre
           . q{

exit 0 if $ENV{AUTOMATED_TESTING};
sub MY::install { "install ::\n" }

           }
           . "\nWriteMakefile("
           . $post;
  
  my $fh = $filename->openw;
  $fh->print($content) or Carp::croak("error writing to $filename: $!");
  $fh->close or Carp::croak("error closing $filename: $!");
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

Dist::Zilla::Plugin::MakeMaker::SkipInstall - skip the install rule of MakeMaker

=head1 SYNOPSIS

In your C<dist.ini> file:

    [MakeMaker::SkipInstall]

=head1 DESCRIPTION

This small plugin will edit the C<Makefile.PL> file, and override the install target to
become a no-op.

This will make your module fail the install phase. It will be built, and tested but will never be installed.

The most common use for this techinique is for L<Task> modules. Without a proper install phase, you can install your Task module repetedly.

=head1 CREDITS

The technique was described by ... 

The author just wrapped the concept into a L<Dist::Zilla> plugin.

=cut
