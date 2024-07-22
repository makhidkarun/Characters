package Benefits;
use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Terse=1;
$Data::Dumper::Indent=1;

my $quiet = 0;

sub new { bless {}, shift }
sub setQuiet { $quiet = shift }

sub musterOut
{
   my $process = shift;
   my $charref = shift;

   my $benefits = $process->musterBenefitCount( $charref );
   my $text = "Mustering Out:\n";
   
   for ( 1..$benefits )
   {
      my $benefit = undef;
      $benefit = $process->musterBenefit($charref, 'random');
      if ( defined $benefit )
      {
         redo if $charref->{ 'benefits' }->{ $benefit } && $benefit =~ /Wafer|TAS|Life/;
         $text .= addBenefit( $charref, $benefit );
      }
   }
   
   return $text;
}

sub addBenefit
{
   my $charref = shift;
   my $benefit = shift;
   my $level   = shift || 1;

   $benefit = 'Retire' if $benefit =~ /^retire_x2$/i;
   my $text = '';
   
   if ( $benefit =~ /^C(\d)\s*\+\s*1$/ ) # add characteristic improvement
   {
      my $characteristicIndex = $1 - 1;
      if ( $charref->{ upp }->[ $characteristicIndex ] < 15 )
      {
         $charref->{ upp }->[ $characteristicIndex ]++;
         $text .=  " - [C$1 +1]\n";
      }
      else
      {
         $text .= " - [C$1 +1] no benefit (maxed out)\n";
      }
   }
   elsif ( $benefit =~ /^Cr\s*(\d+)$/ ) # add cash
   {
      $charref->{ 'cash' } += $1;
	  $text .= " - Cr$1\n";
   }
   else # add the regular benefit
   {
      my ($benefitName, $level) = split '-', $benefit; # e.g. Fame-2
      $level = 1 unless $level;

      my $beneRef = $charref->{ 'benefits' };
      my %benefits   = %$beneRef;
      $benefits{ $benefitName } += $level;
      $charref->{ 'benefits' } = \%benefits;
	  $text .= " - $benefit+$level\n";

      if ( $benefitName =~ /knighthood/i && $charref->{ 'upp' }->[5] < 11 )
      {
         $charref->{ 'upp' }->[5] = 11;
      }
   }
   
   return $text;
}

sub formatBenefits
{
   my $benefits = shift;
   my @out = ();

   foreach my $name ( sort keys %$benefits )
   {
      my $level = $benefits->{$name};

      # Ship Shares
      $name = 'Ship Shares' if $name =~ /Ship Share/;


      my $str   = $name . '-' . $level; #"$name($level)"; per Marc 4/1/2017

      # Only once: Wafer Jack, Life Insurance, TAS
      $str = $name if $name =~ /Wafer|Life|TAS/;

      # Land grants: Knighthood, Barony
      $str = "$name(land grants: $level)" if $name =~ /Knight|Barony/;

      # Retirement
      $str = "$name(x$level)" if $name =~ /Retire/;

      $str =~ s/_/ /; # pretty it up a bit

      push @out, $str;
   }

   return join ", ", @out;
}

1;
