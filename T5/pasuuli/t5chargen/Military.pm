package Military;
use strict;
use warnings;
use Common;

sub roll { int(rand(6))+int(rand(6))+2 }

sub promotion
{
   my $charref = shift;
   my $target  = shift;

   if ( roll() <= $target )
   {
      $charref->{ 'rank' }++;
      $charref->{ 'skillAwards' }++;
      return 1;
   }
   return 0;
}

sub commission
{
   my $charref = shift;
   my $target  = shift;

   return 0 if $charref->{ 'commissioned' }; # an officer

   if ( roll() <= $target )
   {
      $charref->{ 'commissioned' } = 1;
      $charref->{ 'skillAwards' }++;
      $charref->{ 'rank' } = 1; # 2nd Lieutenant or whatever
   }
   return $charref->{ 'commissioned' };
}

sub riskAndReward
{
   my $charref  = shift;
   my $rewardDM = shift || 0;

   # Risk is common
   my ($char, $text) = Common::risk( $charref );

   # These can be posthumous
   my $reward = $char - roll() + $rewardDM;
   if ( $reward >= 0 ) # ribbon
   {
      $text .= reward( $charref, $reward ); # Military::reward()
   }

   return $text;
}

sub reward
{
   my $charref             = shift;
   my $rewardRoll          = shift;

   my $text = " - campaign ribbon.\n";
   $charref->{ 'campaign ribbons' }++ unless Common::isDead( $charref );
   $charref->{ 'campaign ribbons (posthumous)' }++ if Common::isDead( $charref );

   if ( $rewardRoll > 0 ) # medal
   {
      $text .= " - medal awarded.\n";
      $charref->{ 'medalCount' }++ unless Common::isDead( $charref );
      $charref->{ 'medalCount (posthumous)' }++ if Common::isDead( $charref );
   }
   
   return $text;
}

sub calculateRetirement
{
   my $charref  = shift;

   return if $charref->{ 'terms' } < 4;

   $charref->{ 'retirement' } = 2000 * $charref->{ 'terms' }; # base
   $charref->{ 'retirement' } = 3000 * $charref->{ 'terms' } if $charref->{ 'commissioned' };

   ###########################################################
   #
   #  Figure in the retirement multiplier benefit
   #
   ###########################################################
   my $multiple = $charref->{ 'benefits' }->{ 'Retire' } || 0;
   $multiple++;
   $charref->{ 'retirement' } *= $multiple;
}

1;

