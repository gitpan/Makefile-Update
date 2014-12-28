package Makefile::Update;

# ABSTRACT: Update make files.

use strict;
use warnings;
use autodie;

use Exporter qw(import);

our @EXPORT = qw(read_files_list upmake);

our $VERSION = '0.2'; # VERSION



sub read_files_list
{
    my ($fh) = @_;

    my ($var, %vars);
    while (<$fh>) {
        chomp;
        s/#.*$//;
        s/^\s+//;
        s/\s+$//;
        next if !$_;

        if (/^(\w+)\s*=$/) {
            $var = $1;
        } else {
            die "Unexpected contents outside variable definition at line $.\n"
                unless defined $var;
            push @{$vars{$var}}, $_;
        }
    }

    return \%vars;
}


sub upmake
{
    my ($fname, $updater, @args) = @_;

    my $fname_new = "$fname.upmake.new"; # TODO make it more unique

    open my $in, '<', $fname;
    open my $out, '>', $fname_new;

    my $changed = $updater->($in, $out, @args);

    close $in;
    close $out;

    if ($changed) {
        rename $fname_new, $fname;
    } else {
        unlink $fname_new;
    }

    $changed
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Makefile::Update - Update make files.

=head1 VERSION

version 0.2

=head1 SYNOPSIS

    use Makefile::Update;
    my $vars = read_files_list('files.lst');
    upmake('foo.vcxproj', $vars->{sources}, $vars->{headers});

=head1 FUNCTIONS

=head2 read_files_list

Reads the file containing the file lists definitions and returns a hash ref
with variable names as keys and refs to arrays of the file names as values.

Takes an (open) file handle as argument.

The file contents is supposed to have the following very simple format:

    # Comments are allowed and ignored.
    sources =
        file1.cpp
        file2.cpp

    headers =
        file1.h
        file2.h

=head2 upmake

Update the file with the given name in place using the specified function and
passing it the rest of the arguments.

This is meant to be used with C<update_xxx()> defined in different
Makefile::Update::Xxx modules.

=head1 AUTHOR

Vadim Zeitlin <vz-cpan@zeitlins.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Vadim Zeitlin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
