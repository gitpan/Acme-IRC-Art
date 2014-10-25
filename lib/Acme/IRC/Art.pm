#!/usr/bin/perl
package Acme::IRC::Art;
use strict;
use Carp;
no warnings;

BEGIN {
	use Exporter ();
	use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION     = 0.2;
	@ISA         = qw (Exporter);
	#Give a hoot don't pollute, do not export more than needed by default
	@EXPORT      = qw ();
	@EXPORT_OK   = qw ();
	%EXPORT_TAGS = ();
}


=head1 NOM

Acme::IRC::Art - 

=head1 SYNOPSIS

 use Acme::IRC::Art;
 use NET::IRC;
 ...
 d�finition d'un connexion avec Net::IRC (voir la documentation de NET::IRC)
 ...
 my $art = Art->new(5,5);
 $art->rectangle(0,0,4,4,2);
 for ($art->result)  {
   $connection_irc->privmsg("#channel",$_);
   select(undef,undef,undef,0.5);
 }


=head1 DESCRIPTION

Acme::IRC::Art est un module qui vous permet de faire des jolis dessins sur l'irc comme si vous utilisiez une librairie
graphique tr�s basique, il n'a pas �tait con�ut pour faire de l'ascii art ( faire automatiquement des 
dessins avec les caract�res acsii), il se contente de manipuler des couleurs et du texte. 
Vous pouvez l'utiliser avec n'importe quel module qui fournis un client irc (eg Net::IRC) ou dans des script perl pour des client IRC.


=head1 UTILISATION

=over

=item new


D'abord il vous faut en premier lieu appeler le constructeur qui se nome new, il se contente de creer un canevas vide sur lequel vous allez travailler,
vous pouvez sp�cifier sa hauteur et sa largeur, le canevas est remplis d'espace par d�faut.


my $art->new($largeur,$hauteur);



Une r�gle � ne pas oublier c'est de d�finir votre dessin dans l'ordre auquel les �l�ments doivent appara�tre
si par exemple vous definissez un texte puis que vous dessinez un rectangle dessus le texte sera effac�


=cut


sub new  {
  my ($class, $largeur, $hauteur) = @_;
  
  #gestion d'erreur
  my $syntaxe = 'Syntaxe correcte : $deco = Art->new(largeur, hauteur)';
  croak("Les arguments de la fonction \'new\' de Art.pm sont: la largeur et la hauteur du canevas
   $syntaxe") if @_!=3;
  croak("Largeur et hauteur doivent �tre des nombres
   $syntaxe") if ($largeur!~/^\d+$/ or $hauteur!~/^\d+$/);
  croak("la largeur ou la hauteur ne sont pas des nombre
   $syntaxe") if ($largeur!~/\d/ or $hauteur!~/\d/);


  $hauteur-- and $largeur--;
  my @canevas;
  $#canevas = $hauteur;
  #fill with spaces
  foreach my $temp (0..$hauteur)  {
    foreach my $temp2 (0..$largeur)   {
      $canevas[$temp][$temp2] = " ";
    } 
  }
  my $self = {};
  bless ($self,$class);
  $self->{canevas} = [@canevas];
  return $self;
}

=pod

=item result


Quand vous avez finis de d�finir votre dessin avec les m�thodes qui sont d�crite par la suite, appeler
la methode C<result> qui ne prend aucun arguments et qui retourne un tableau qui contient chaque ligne
de messages � envoyer pour afficher votre dessin.


=cut

sub result {
 my ($this) = shift;
 use Data::Dumper;
 return map {join '',@{$_}} @{$this->{canevas}};
}


=head1 Methodes

Voici la liste des m�thodes avec lesquelles vous allez pouvoir dessiner


=over
=item pixel

La m�thode 'pixel' pour afficher ou non un pixel , vous devez sp�cifier sa position et sa couleur

 $art->pixel($x,$y,$couleur,$on);

$on est une valeur boul�enn pour dire d'afficher ou d'effacer le pixel (-1 pour effacer).
$on est vraie par d�faut vous pouvez utiliser la synthaxe suivante

 $art->pixel($x,$y,$couleur);

Une derni�re chose : le $x et $y peuvent �tre des r�f�rences vers un tableau, mais attention les coordonn�es en
x et en y doivent correspondent une � une, exemple pour remplir la diagional d'un carr� de 3 sur 3

 $art->pixel([0,1,2],[0,1,2],5);



=cut

sub pixel  {
  my ($this, $x, $y, $color, $on) = @_;
  my @canevas = @{$this->{canevas}};
 
  #gestion d'erreur
  my $syntaxe = '$deco->pixel( position x , position y , couleur , [on])';
  croak("Les arguments de \'pixel\' sont : la position en x , la position en y , la couleur et l'�tat du pixel
   $syntaxe")   if @_<4 or @_>5;
  croak("Les tableaux des position x et y ne sont pas de la m�me taille !
   $syntaxe")   if (ref $y and ref $x and @$x != @$y);
  croak("l'un d'un arguments de position n'est pas compatible avec l'autre
   $syntaxe")   if (ref $y and !ref $x or ref $x and !ref $y);
  croak("Vous etes sortit du canevas d�finit") if ((!ref $x and !ref $y ) and ($y>$#canevas or $x>(@{$canevas[0]}-1)));
  
  my (@y, @x);
  if (ref $y) {
       @x = @$x;
       @y = @$y;
  }
  else {
      $x[0] = $x;
      $y[0] = $y;
      $#y = 0;
  }
  $on = 0 unless defined $on;
  for (0..$#y)  {
    if ($on >= 0) {   
      $canevas[$y[$_]][$x[$_]] = "\003$color,$color \003";
    }
    else { 
      $canevas[$y[$_]][$x[$_]] = " ";
    }
  }
  $this->{canevas} = [@canevas];
}


=item text

La m�thode 'text' permet d'afficher du texte � partir d'une position donn�e, la syntaxe est :

 $art->text($texte,$position_x, $position_y,[$mise_en_forme],[$couleur_fond]);

plusieurs mise en forme de texte sont disponible
 
 -"b" : met le texte en gras
 -un nombre met le texte � la couleur correspondante
 -"b".un nombre met le texte en gras avec une couleur

exemple:

 $art->text("Bonjour !",2,0,"b5",2);

Cel� mettra le "B" au pixel de coordonn�e 2,0 , les autres lettres seront plac�es � la suite,
par exemple le premier "o" aura comme coordonn�e 3,0. Le texte sera en rouge fonc� avec du gras ("b5")
sur fond bleu.

Exp�rimentale :

    $art->text($text,$x,$y,\@mise_en_forme,[\@fond]);

Soyez prudent car aucun v�rification n'est faite le la validit� des arguments dans ce cas l�


=cut


sub text  {
  my ($this, $text, $x, $y, $bolt, $fond) = @_;
  my @canevas = @{$this->{canevas}};

  $bolt = 0 unless defined $bolt;
  $fond = 0 unless defined $fond;
  #gestion d'erreur
  my $syntaxe = 'Syntaxe correcte : $deco->text($texte,$positionx,$positiony,[$mise_en_forme],[$fond])';

  croak("les arguments de \'text\' sont le texte, la position x de la premi�re lettre,i".
	" la position x de la permi�re lettre, sa mise en forme, [le fond de couleur du texte]
   $syntaxe") if (@_ > 6 or @_ < 4);
  
  croak("Mise en forme : $bolt incorrecte regardez la documentation pour avoir des informations sur la mise en forme")      if (!ref $bolt and (length($bolt) > 3 or $bolt !~ /\d/ and $bolt !~ /b/) and @_ == 5);
	      
  croak("Un des arguments qui devrai �tre un nombre de l'est pas
   $syntaxe") if ($x !~ /\d/ or $y !~ /\d/);

  croak("la valeur de fond sp�cifi� est trop grande")  if !ref $fond and $fond > 15;
  croak("la couleur de mise en forme est trop grande") if !ref $bolt and $bolt > 15;
  croak("Vous etes sortit du canevas d�finit")         if ($y > $#canevas or $x > (@{$canevas[0]}-1));

  my $a_bolt = $bolt if ref $bolt;
  my $a_fond = $fond if ref $fond;
  my @lettre = split '',$text;
  my $color;
  foreach my $position (0..$#lettre)  {
    $bolt = $a_bolt->[$position] if $a_bolt;
    $fond = $a_fond->[$position] if $a_fond;
    my $v;
    my $fond2 = $fond;
    my $pixel = \$canevas[$y][$x+$position];
    
    # on red�finis le fond au besoin
    $this->pixel($x + $position, $y, $2) if $$pixel =~ /\003(\d|),(\d)/;
    $fond2 ||= $2;
    $v = ',' if $fond or $$pixel ne " ";
    
    # on place enfin la lettre
    $$pixel=~s/\s/\002$lettre[$position]\002/ if $bolt eq 'b';
    if (($color) = ($bolt =~ /b(\d+)/)) { #bolt with color
      ($fond2, $color, $lettre[$position]) = correction($fond2, $color, $lettre[$position]) and 
      $$pixel = "\003${color}${v}${fond2}\002$lettre[$position]\002\003";
    }
    if (($color) = ($bolt =~ /^(\d+)/)) { #only color
      ($fond2, $color, $lettre[$position]) = correction($fond2, $color, $lettre[$position]) and 
      $$pixel = "\003${color}${v}${fond2}$lettre[$position]\003";
    }
    if (!$bolt and !$fond)              { #euh
      ($fond2, $color, $lettre[$position]) = correction($fond2, $color, $lettre[$position]) and 
      $$pixel = "\003${v}${fond2}$lettre[$position]\003";
    }
    if (!$bolt and !$fond and !$fond2) { #just text
      ($fond2, $color, $lettre[$position]) = correction($fond2, $color, $lettre[$position]) and 
      $$pixel = $lettre[$position];
    }
    sub correction   {
      #sub qui corrige au besoin pour pouvoir faire apara�tre les chiffres
      $_[0] = "0$_[0]" if $_[0] =~ /^\d$/ and $_[2] =~ /^\d$/;
      $_[1] = "0$_[1]" if $_[1] =~ /^\d$/ and $_[2] =~ /^\d$/;
      return @_;
    }
  }
  $this->{canevas} = [@canevas];
}


=item rectangle

La m�thode rectangle permet de faire facilement des rectangles mais aussi des lignes

La syntaxe est la suivante :

 $art->rectangle($position_x1,$position_y1,$position_x2,$position_y2,$couleur,[$on]);

x1 et y1 repr�sentent les coordonn�es du pixel au coin en haut � gauche, et x2 et y2 celle du coin en bas � droite


=back

=cut

sub rectangle  {
  my ($this, $x1, $y1, $x2, $y2, $color, $on) = @_;
  foreach my $t1 ($y1..$y2) {
    foreach my $t2 ($x1..$x2)  {
      $this->pixel($t2, $t1, $color, $on);
    }
  }
}

=item save

La m�thode save permet de sauvegarder dans un fichier l'image obtenus pour la recharger par la suite avec
la m�thode load par exemple. C'est un simple fichier avec le texte ascii n�cessaire pour l'irc.

La syntaxe est la suivante :

 $art->save($path_to_file);

path_to_file est �videment le chemin vers le fichier

=cut

sub save {
  my ($this, $fname) = @_;
  my @canevas = @{$this->{canevas}};

  my $syntax = 'Syntax : $art->save($file_name)';
  croak("missing argument : $syntax") if ! defined $fname;

  open FILE, ">", $fname or croak "Error opening $fname with write permision : $!";
  foreach my $t (@canevas) {
    print FILE join('', @$t), "\n";
  }
  close FILE;
}

=item load

La m�thode load permet de charger des fichiers d'image au format utilis� par la m�thode save.

La syntaxe est la suivante :

 $art->load($path_to_file)

path_to_file est toujours le chemin vers le fichier

=cut

sub load {
  my ($this, $fname) = @_;
  my @canevas = @{$this->{canevas}};

  my $syntax = 'Syntax :$art->load($file_name)';
  croak("missing argument : $syntax") if ! defined $fname;

  open FILE, "$fname" or croak "Can't open $fname : $!";
  foreach my $t (<FILE>) {
    push @canevas, chomp $t;
  }
  close FILE;
}

1;


=head1 Annexe

couleurs :

 0 : Gris clair (ou blanc)
 1 : Noir
 2 : Bleu fonc�
 3 : Vert fonc�
 4 : Rouge 
 5 : Rouge fonc�
 6 : Violet
 7 : Orange
 8 : Jaune
 9 : Vert clair
 10 : Bleu ciel fonc�
 11 : Bleu ciel clair
 12 : Bleu
 13 : Rose
 14 : Gris fonc�
 15 : Gris

=head1 BUGS

Il n'y a pas de bugs connus, le probl�me de rendu peut venir d'un choix de police dont les 
caract�re ne sont pas tous de la m�me  taille, ce qui pose un probl�me aussi pour 
les dessins ascii.

=head1 SUPPORT



=head1 AUTHOR

	Colinet Sylvain
	skarsnikum@free.fr
	http://skarsnik.homelinux.org/~skarsnik

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1). Net::IRC, POE::Component::IRC 

=cut

__END__
