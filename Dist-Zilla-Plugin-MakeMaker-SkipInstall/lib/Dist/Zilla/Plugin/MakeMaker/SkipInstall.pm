package Dist::Zilla::Plugin::MakeMaker::SkipInstall;

use Moose;

with 'Dist::Zilla::Role::AfterBuild'

has filename => (
  isa => 'Str',
  is  => 'ro',
  default =>  'Makefile.PL',
);

sub after_build {
  my ($self) = @_;
  my $filename = $self->filename;
  
  my $content = do {
    local $/;
    open my $fh, '<', $filename
      or Carp::croak("can't open '$filename' for reading: $!");
    <$fh>
  };
  
  my ($pre, $post) = split(/^\s*WriteMakefile[(]/sm, $content);
  $content = $pre
           . qq{## I was here\n}
           . 'WriteMakefile('
           . $post;
  
  open my $fh, '>', $filename
    or Carp::croak("can't open $filename for writing: $!");

  print $out_fh $content or Carp::croak("error writing to $filename: $!");
  close $out_fh or Carp::croak("error closing $filename: $!");
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
