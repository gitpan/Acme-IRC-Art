# -*- perl -*-

use Test::More tests => 12;
use Acme::IRC::Art;

my $art = Acme::IRC::Art->new(8,1);

$art->text('Test',2,0);
is_deeply([$art->result],[("  Test  ")]);

$art->text('Test2',1,0);
is_deeply([$art->result],[(" Test2  ")]);

$art->rectangle(0,0,7,0,5,-1);
$art->text('Test',2,0,2);
is_deeply([$art->result],[("  \0032T\003\0032e\003\0032s\003\0032t\003  ")]);

$art->rectangle(0,0,7,0,5);
$art->text('Test',2,0,2);
is_deeply([$art->result],[("\0035,5 \003\0035,5 \003\0032,5T\003\0032,5e\003\0032,5s\003\0032,5t\003\0035,5 \003\0035,5 \003")]);


$art->rectangle(0,0,7,0,5,-1);
$art->text('  Test  ',0,0,2,5);
is_deeply([$art->result],[("\0032,5 \003\0032,5 \003\0032,5T\003\0032,5e\003\0032,5s\003\0032,5t\003\0032,5 \003\0032,5 \003")]);

$art->rectangle(0,0,7,0,5,-1);
$art->text('Test',2,0,'b');
is_deeply([$art->result],[("  \002T\002\002e\002\002s\002\002t\002  ")]);

$art->rectangle(0,0,7,0,5,-1);
$art->text('Test',2,0,'b5');
is_deeply([$art->result],[("  \0035\002T\002\003\0035\002e\002\003\0035\002s\002\003\0035\002t\002\003  ")]);

$art->rectangle(0,0,7,0,5,-1);
$art->text('Test',2,0,'b2',5);
is_deeply([$art->result],[("  \0032,5\002T\002\003\0032,5\002e\002\003\0032,5\002s\002\003\0032,5\002t\002\003  ")]);

$art->rectangle(0,0,7,0,5,-1);
$art->text('Test',2,0,['b1','b2','b3','b4'],[4..7]);
is_deeply([$art->result],[("  \0031,4\002T\002\003\0032,5\002e\002\003\0033,6\002s\002\003\0034,7\002t\002\003  ")]);


$art->rectangle(0,0,7,0,5,-1);
$art->text('1234',2,0,2,5);
is_deeply([$art->result],[("  \00302,051\003\00302,052\003\00302,053\003\00302,054\003  ")]);

$art->rectangle(0,0,7,0,5,-1);
$art->text('1234',2,0,'b2',5);
is_deeply([$art->result],[("  \00302,05\0021\002\003\00302,05\0022\002\003\00302,05\0023\002\003\00302,05\0024\002\003  ")]);

$art->rectangle(0,0,7,0,5,-1);
$art->text('1234',2,0,'b2',14);
is_deeply([$art->result],[("  \00302,14\0021\002\003\00302,14\0022\002\003\00302,14\0023\002\003\00302,14\0024\002\003  ")]);





