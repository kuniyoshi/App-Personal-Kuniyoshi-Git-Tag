package App::Personal::Kuniyoshi::Git::Tag;
use strict;
use warnings;
use Carp qw( croak );
use Readonly;
use List::Util qw( first );
use Path::Class qw( file );
use Time::Piece qw( localtime );

our $VERSION = "0.02";

Readonly my $FILENAME => "Changes";

sub new { my $class = shift; bless { @_ }, $class }

sub exec { shift->{exec} }

sub m { shift->{m} }

sub a { shift->{a} }

sub changes { file( $FILENAME ) }

sub now { localtime->cdate }

sub new_rb {
    my $self = shift;
    my $line = first { m{\A ( \d+ [.] \d+ ) }msx }
               $self->changes->slurp( chomp => 1 );

    my( $current ) = split m{\s}, $line;

    return sprintf "%.2f", 0.01 + $current;
}

sub latest_tag {
    my $self = shift;
    chomp( my @tags = `git tag` );
    my $tag = first { m{\A RB_ \d }msx } reverse sort @tags
        or return "0.00";
    return( ( split "_", $tag )[-1] );
}

sub run {
    my $self = shift;
    my $new_rb = $self->new_rb;

    if ( ( my $tag = $self->latest_tag ) == $new_rb ) {
        croak "The tag already exists[$tag].";
    }
    elsif ( $tag > $new_rb ) {
        croak "The tag[$tag] is too new.";
    }

    return
        unless $self->exec;

    my @new_lines = (
        sprintf( "%-8.2f%s", $new_rb, $self->now ),
        sprintf( "        - %s", $self->m ),
        q{},
    );

    my @lines = $self->changes->slurp( chomp => 1 );
    splice @lines, 2, 0, @new_lines;

    my $FH = $self->changes->openw;
    print { $FH } map { $_, "\n" } @lines;
    close $FH
        or die "Could not close a file[$FILENAME].";

    my $option = $self->a ? "-am" : "-m";

    system( "git", "commit", $option, $self->m ) == 0
        or die "Could not commit[$!]";

    system( "git", "tag", "RB_$new_rb" ) == 0
        or die "Could not make new tag[RB_$new_rb].";

    return;
}


1;
__END__

=head1 NAME

App::Personal::Kuniyoshi::Git::Tag - Commit with tag

=head1 SYNOPSIS

  use App::Personal::Kuniyoshi::Git::Tag;
  App::Personal::Kuniyoshi::Git::Tag->new->run;

=head1 DESCRIPTION

i'm always typing following before release a new version.

=over

=item vim Changes (Add a new line)

=item git commit -m "Same-Message-As-Changes"

=item git tag RB_${SAME-VALUE-AS-CHANGES}

=back

This module does same thing those three commands.

This module do not work when you need two or more lines in Changes,
this module excepts only one change message in the Chagnes.

=head1 AUTHOR

kuniyoshi E<lt>kuniyoshi@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

