use Test::Base;
use IPC::Run3;
use File::Slurp;

my $prolog = "$^X pro.pl";

plan tests => 3 * blocks();
my $count = 0;

chdir 'xprolog' or die;

run {
    my $block = shift;
    my $name = $block->name;
    my $id = sprintf("%03d", ++$count);
    write_file("$id.xpro", "/* $name */\n\n", $block->xpro);
    ok system($^X, "xpro.pl", "$id.xpro") == 0, "$name - xpro.pl ok";
    my ($stdout, $stderr);
    ok run3(
            [split(/\s+/, $prolog), '-s', "$id.pro", qw(-g go -t halt -q)],
            \undef,
            \$stdout,
            \$stderr,
        ),
        "$name - $prolog ok";
    warn $stderr if $stderr;
    is $stdout, $block->vectorized, "$name - vectorization ok";
};

__DATA__

=== TEST 1: ����ƽ��ƽ�е��ж�����
--- vrg

line a, b;
plan alpha, beta;
point p;
meet(a, b, p), a on beta, b on beta, a // alpha, b // alpha
=> alpha // beta

--- xpro
:- include(vectorize).

meet(\a, \b, p).
\a on #beta.
\b on #beta.
\a // #alpha.
\b // #alpha.

--- vectorized
orthogonal a alpha
orthogonal b alpha
orthogonal a beta
orthogonal b beta
unparallel a b



=== TEST 2: ����ƽ��ƽ�е����ʶ���
--- vrg

plane alpha, beta, theta;
line a, b;
alpha // beta, meet(alpha, theta, a), meet(beta, theta, b)
=> a // b;

--- xpro
:- include(vectorize).

#alpha // #beta.
meet(#alpha, #theta, \a).
meet(#beta, #theta, \b).

--- vectorized
orthogonal a alpha
orthogonal b beta
orthogonal a theta
orthogonal b theta
parallel alpha beta
unparallel alpha theta
unparallel beta theta



=== TEST 3: ����ƽ��ƽ�е����ʶ��� 2
--- vrg

plane alpha, beta;
line l;
alpha // beta, l on alpha => l // beta.

--- xpro
:- include(vectorize).

#alpha // #beta.
\l on #alpha.

--- vectorized
orthogonal l alpha
parallel alpha beta



=== TEST 4: ����ƽ��ƽ�е����ʶ��� 3
--- vrg

plane alpha, beta;
line l;
alpha // beta, l T alpha => l T beta

--- xpro
:- include(vectorize).

#alpha // #beta.
\l T #alpha.

--- vectorized
parallel l alpha
parallel alpha beta



=== TEST 5: ֱ�ߺ�ƽ�洹ֱ�����ʶ��� 2
--- vrg

line l1, l2;
plane alpha;
l1 T alpha, l2 on alpha => l1 T l2;

--- xpro
:-include(vectorize).

\l1 T #alpha.
\l2 on #alpha.

--- vectorized
orthogonal l2 alpha
parallel l1 alpha



=== TEST 6: ����ƽ�洹ֱ�����ʶ���
--- vrg

plane alpha, beta;
line l1, l2;
alpha T beta, meet(alpha, beta, l1), l2 on alpha, l2 T l1
=> l2 T beta;

--- xpro
:- include(vectorize).

#alpha T #beta.
meet(#alpha, #beta, \l1).
\l2 on #alpha.
\l2 T \l1.

--- vectorized
orthogonal l2 l1
orthogonal l1 alpha
orthogonal l1 beta
orthogonal l2 alpha
orthogonal alpha beta
unparallel alpha beta



=== TEST 7: �����߶���
PA��PO �ֱ���ƽ�� alpha �Ĵ��ߡ�б�ߣ�AO �� PO ��ƽ�� alpha �ڵ���Ӱ��
�� a �� alpha �ϣ�a ��ֱ�� AO���� a ��ֱ�� PQ.
--- vrg

line a;
line b; # line PA
line d; # line AO
line c; # line PO
point P, A, O;
b T alpha, project(c, alpha, d), a on alpha, a T d
=>
a T c;

--- xpro
:- include(vectorize).

\c A #alpha.
\c on #theta.
meet(#theta, #alpha, \d).
#theta T #alpha.
\a on #alpha.
\a T \d.

--- vectorized
orthogonal a d
orthogonal d theta
orthogonal d alpha
orthogonal c theta
orthogonal a alpha
orthogonal theta alpha
oblique c alpha
unparallel theta alpha
