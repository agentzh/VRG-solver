use strict;
use warnings;

use CLIPSx_Compiler;
use List::MoreUtils 'uniq';
use File::Slurp;
use Data::Dump::Streamer;

our $infile = shift or
    die "usage: $0 infile\n";
(my $outfile = $infile) =~ s/\.xclp$/.clp/i;
$outfile .= '.clp' if $outfile !~ /\.clp$/i;

our ($base) = ($outfile =~ /([\w-]+)\.\w+$/);
$base = "f$base" if $base !~ /^[A-Za-z_]/;

my $source = read_file($infile);

$::RD_HINT = 1;
#$::RD_TRACE = 1;
our $parser = CLIPSx::Compiler->new;
my $data = $parser->program($source);
if (!defined $data) {
    die "abort.\n";
}
$data .= "\n" if $data and $data !~ /\n$/s;
if (@::facts) {
    $data .= "(deffacts $base\n    " . join("\n    ", uniq @::facts). ")\n";
}
$data .= "\n" if $data and $data !~ /\n$/s;

#my @elems = %infix_circumfix;
#warn "\%infix_circumfix: @elems\n";

#@elems = %infix_circum_close;
#warn "\%infix_circum_close: @elems\n";

if ($data) {
    write_file($outfile, $data);
    #print $data;
}
