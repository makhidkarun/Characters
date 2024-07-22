package Common;
use strict;
use warnings;

sub roll { int(rand(6))+int(rand(6))+2 }
sub flux { roll() - 7 }
sub d6   { int(rand(6)+1) }

sub getUPP
{
   my $upp = shift || ''; 
   my $dna = shift || '';
   my @upp;

   if ( $upp =~ /^[0-9A-F]{6}$/ )
   {
      push @upp, hex $_ for split '', $upp;
   }
   elsif ( $dna =~ /^[1-6]{4}$/ )
   {
      push @upp, hex $_ for split '', $dna;
	  push @upp, d6() for 5..6; # EDU and SOC
	  
	  # Now add 1D to each characteristic.
	  $_ += d6() foreach @upp;
   }
   else
   {
      push @upp, roll() for 1..6;
   }

   return @upp;
}

sub riskAndRewardOrder
{
   my $charref     = shift;
   my $indref      = shift || [0,1,2,3];
   my @charIndices = @$indref;

#   print "Indices: ", @charIndices, "\n";

   my @order   = reverse sort { $charref->{ 'upp' }->[$a] <=> $charref->{ 'upp' }->[$b] } @charIndices;
   return \@order;
}

sub physicalStatsBelow
{
   my $charref = shift;
   my $val     = shift;
   my $under    = 0;
   
   $under++ if $charref->{ 'upp' }->[0] < $val;
   $under++ if $charref->{ 'upp' }->[1] < $val;
   $under++ if $charref->{ 'upp' }->[2] < $val;

   return $under;
}


sub toString
{
   my $career  = shift;
   my $charref = shift;

   my $upp = uppToString( $charref ); 

   # my @upp = @{$charref->{ 'upp' }};
   # my @ehex = ( 0..9, 'A'..'H', 'J'..'N', 'P'..'Z' );
   # for (@upp)
   # {
   #    $upp .= $ehex[ $_ ];
   # }


   my $rank = $career->getRank( $charref );
   $rank = "" unless $rank;
   $rank = " $rank" if $rank =~ /^\S/;

   $charref->{ 'preterms' } = 0 unless $charref->{ 'preterms' };
   
   my $etc = '';
   if ( $charref->{ 'former career' } )
   {
      my $fc = $charref->{ 'former career' };
      $etc = sprintf "($fc %s terms)  ", $charref->{ 'preterms' }
   }
   
   my $out .= sprintf "%s %s %s yrs  %s terms  $etc%s\n",
      $charref->{ 'career' } . $rank,
      $upp,
      18 + ($charref->{ 'preterms' } + $charref->{ 'terms' }) * 4,
      $charref->{ 'terms' },
      formatCash( $charref->{ 'cash' } + $charref->{ 'retirement' } );

   $out =~ s/terms/term/ if $charref->{ 'terms' } == 1;

   $out = "DEAD $out" if isDead( $charref );
   
   return $out;
}

sub formatCash
{
   my $cash = shift;
   return '(No cash)' if $cash == 0;
   return 'MCr ' . (int( $cash / 10000 ) / 100) if $cash > 1000000;
   if ( $cash > 1000 )
   {
      $cash =~ s/000$/,000/;
   }
   return "Cr $cash"; # otherwise
}

sub uppToString
{
   my $charref = shift;

   my @upp = @{$charref->{ 'upp' }};

   my $upp = '';
   my @ehex = ( 0..9, 'A'..'H', 'J'..'N', 'P'..'Z' );
   for (@upp)
   {
      $upp .= $ehex[ $_ ];
   }

   return $upp;
}

sub term
{
   # my $self = shift;
   my $charref = shift;
   $charref->{ 'terms' }++;
   $charref->{ 'skillAwards' } = 4;

   # return if $quiet;

   my $out = "Term " . $charref->{ 'terms' } . ": ";
   $out .= Common::uppToString( $charref );  # $out .= sprintf("%X", $_) for @{$charref->{ 'upp' }};
   $out .= "\n";
   return $out;
}

sub promotion
{
   my $charref = shift;
   my $target  = shift;

   if ( roll() < $target )
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

   if ( roll() < $target )
   {
      $charref->{ 'commissioned' } = 1;
      $charref->{ 'skillAwards' }++;
      $charref->{ 'rank' } = 1; # 2nd Lieutenant
   }
   return $charref->{ 'commissioned' };
}

sub risk
{
   my $charref = shift;

   my ($riskCharacteristic, @risk_and_reward_order) = @{$charref->{ 'risk and reward order' }};
   push @risk_and_reward_order, $riskCharacteristic;
   $charref->{ 'risk and reward order' } = \@risk_and_reward_order;

   my $char = $charref->{ upp }->[ $riskCharacteristic ];

   my $text = "Risk and Reward: using C" . ($riskCharacteristic+1) . " ($char)\n";

   my $injury = roll() - $char;
   if ( $injury > 0 ) # wounded
   {
      $charref->{ 'wound badges' }++; # Fine even for non-military.  Just don't use them in those cases.
      $text .= Common::injury( $charref, $riskCharacteristic, $injury );
   }
   
   return ($char, $text);
}

sub isDisabled
{
   my $charref = shift;
   return $charref->{ 'disabled' } || 0;
}

sub isDead
{
   my $charref = shift;
   return $charref->{ 'dead' } || 0;
}

sub resurrect # dire emergencies only, please
{
   my $charref = shift;

   $charref->{ 'upp' }->[ 0 ] = 5 if $charref->{ 'upp' }->[0] < 1;
   $charref->{ 'upp' }->[ 1 ] = 5 if $charref->{ 'upp' }->[1] < 1;
   $charref->{ 'upp' }->[ 2 ] = 5 if $charref->{ 'upp' }->[2] < 1;
   $charref->{ 'dead' } = 0;
}

sub injury
{
   my $charref             = shift;
   my $characteristicIndex = shift;
   my $injury              = shift;
   my $flux                = flux();
   my $total = $injury + $flux;
   
   $total = 0 if $total < 0; # i.e. no damage
   
   my $text = "Injury: $injury points to C" . ($characteristicIndex+1) . ".\n";
   $text .= " - flux applied: $flux\n";
   $text .= " - permanent damage: $total\n";
   $text .= " - disabled\n" if $total > 3;
   $text .= " - DEAD\n" if $total >= $charref->{ 'upp' }->[ $characteristicIndex ];
   
   if ( $total > 0 ) # injured
   {
      $charref->{ 'upp' }->[ $characteristicIndex ] -= $total;
      if ( $total > 3 ) # disabled
      {
         $charref->{ 'disabled' } = 1;
      }
      if ( $charref->{ 'upp' }->[ $characteristicIndex ] <= 0 )
      {
         $charref->{ 'dead' } = 1;
		 $charref->{ 'skillAwards' } = 0;
         $charref->{ 'upp' }->[ $characteristicIndex ] = 0;
      }
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

sub musterBenefitCount
{
   # my $self = shift;
   my $charref  = shift;

   my $benefits = $charref->{ 'terms' };
   $benefits *= 2 if $charref->{ 'disabled' };

   return $benefits;
}

sub musterBenefit
{
   my $charref = shift;
   my $type    = shift || 'random';
   my $cashref = shift;
   my $benefitref = shift;
   my $table_size = scalar @$benefitref;
   my $cash_selected = 0;
 
   my $DM = $charref->{ 'benefitDM' } || 0;

   if ( $type eq 'cash' || ($cash_selected < 3 && $type eq 'random' && rand() > 0.5) )
   {
      my $choice  = int(rand(6)) + $DM;
      $cash_selected++;
      return $cashref->[ $choice ] || $cashref->[ -1 ];
   }
   else
   {
      $DM = 0 if rand($DM)+3 > $table_size;  # elect to not use DM 
      my $choice  = int(rand(6)) + $DM;
      return $benefitref->[ $choice ] || $benefitref->[ -1 ];
   }
}

sub aging
{
   my $charref = shift;
   my $text = "";
   
   $charref->{ 'preterms' } = 0 unless $charref->{ 'preterms' };
   ###################################
   #
   #  AGING
   #
   ###################################   
   my $lifestage = 3 + ($charref->{ 'preterms' } + $charref->{ 'terms' }) / 2;
   if ( $lifestage >= 5 ) 
   {
      $text .= "Making aging rolls.\n";
	  if (roll() < $lifestage) # STR
	  {
         $charref->{ upp }->[ 0 ]--;
		 $text .= " - C1-1\n";
	  }
	  
	  if (roll() < $lifestage) # DEX
	  {
         $charref->{ upp }->[ 1 ]--;
		 $text .= " - C2-1\n";
	  }
	  
	  if (roll() < $lifestage) # END
	  {
         $charref->{ upp }->[ 2 ]--;
		 $text .= " - C3-1\n";
	  }

      if ( $lifestage >= 9 && roll() < $lifestage)
      {
         $charref->{ upp }->[ 3 ]--;
		 $text .= " - C4-1\n";
      }
   }
   return $text;
}

1;

