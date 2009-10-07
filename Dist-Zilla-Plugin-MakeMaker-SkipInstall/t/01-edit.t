#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Dist::Zilla;
use Dist::Zilla::Plugin::MakeMaker::SkipInstall;
use Path::Class qw( dir );
use File::Temp qw( tempdir );
use File::Copy qw( copy );

my $dir = dir(tempdir(CLEANUP => 1));
my $makefile = setup_project($dir);

my $plugin = Dist::Zilla::Plugin::MakeMaker::SkipInstall->new(
  plugin_name => 'MakeMaker::SkipInstall',
  zilla       => Dist::Zilla->from_config({dist_root => $dir->stringify}),
);
ok($plugin);
lives_ok sub { $plugin->after_build({build_root => $dir}) };

my $content = $makefile->slurp;
like($content, qr/exit 0 if \$ENV{AUTOMATED_TESTING}/);
like($content, qr/sub MY::install { "install ::\\n" }/);

done_testing();

sub setup_project {
  my $dir = shift;

  for my $f ('Makefile.PL', 'dist.ini') {
    my $dest = $dir->file($f)->stringify;
    copy($f, $dest)
      or die "Could not copy file '$f' to '$dest': $!";
  }

  return $dir->file('Makefile.PL');
}
