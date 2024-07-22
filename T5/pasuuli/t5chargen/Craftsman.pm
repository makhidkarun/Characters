package Craftsman;
use Common;
use Skills;
use Benefits;
use strict;
use warnings;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }
sub d6   { int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = qw/ C1+1 C2+1 C3+1 C4+1 C5+1 C6+1
Major Major Minor Minor Trade Trade
Seafarer Navigation Hostile_Env Flyer Driver Vacc_Suit
Animals Comms Designer Computer Designer Designer 
Comms Bureaucrat Diplomat Leader Liaison Trader
Art Trade Trade New_Trade New_Trade Naval_Architect
Art Science Trade Athlete Animals Medic 
/;

my @cashout = qw/ Low_Psg Mid_Psg High_Psg Cr15000 StarPass Cr25000 Cr30000 Cr40000 /;
my @benefits = qw/ Forbidden Wafer_Jack C5+1 C1+1 C2+1 C3+1 C4+1 Ship_Share TAS_Fellow /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'former career' } = $charref->{ 'career' };

      $charref->{ 'career' }       = $charref->{ 'former career' } . ' Craftsman';
      $charref->{ 'careerAbbr' }   = 'R';
      $charref->{ 'preterms' }     = $charref->{ 'terms' };
      $charref->{ 'terms'  }       = 0;
      $charref->{ 'commissioned' } = 0; 
      $charref->{ 'rank'   }       = 0; 
      $charref->{ 'wound badges' } = 0;
      $charref->{ 'permanent injury' } = 0;
      $charref->{ 'skillAwards' }  = 0;
      $charref->{ 'medalCount' }   = 0;
      $charref->{ 'medals' }       = {} unless $charref->{ 'medals' };
      $charref->{ 'skills' }       = {} unless $charref->{ 'skills' };
      $charref->{ 'benefits' }     = {} unless $charref->{ 'benefits' };
      $charref->{ 'cash' }        |= 0;
      $charref->{ 'retirement' }  |= 0;
      $charref->{ 'major' }        = Skills::getRealRandomSkill();
      $charref->{ 'minor' }        = Skills::getRealRandomSkill();

      # 
      #  Figure out risk and reward order
      # 
      $charref->{ 'risk and reward order' } = Common::riskAndRewardOrder( $charref );
      
      return "A Craftsman.\n";
   }
   
   return 0;
}

sub getRank
{
   my $self = shift;
   my $charref = shift;
   return undef; #  no ranks
}

#
#  Internal method
#
sub masterPoints
{
   my $charref = shift;
   my $craftsman = $charref->{ 'skills' }->{ 'Craftsman' }->{ 'level' };

   my @skills = craftsmanFlatten( $charref->{ 'skills' } );
   @skills = sort { $b->{ 'level' } <=> $a->{ 'level' } } @skills;
   @skills = @skills[ 0..4 ] if scalar @skills > 5;

   my $points = $craftsman;
   $points += $_->{ 'level' } for @skills;

   my @used = ("Craftsman-$craftsman");
   push( @used, $_->{ 'name' } . '-' . $_->{ 'level' } ) for @skills;
   my $used = join ', ', @used;

   return $points, $used;
}

sub craftsmanFlatten # a specialized flattener that omits Craftsman and any skill < 6 and stops at 5.
{
   my $skillref = shift;
   my %skills = %$skillref;
   my @out    = ();

   foreach my $sname (keys %skills)
   {
      next if $sname eq 'Craftsman';

      my $level = $skills{ $sname }->{ 'level' };
      if ( $level >= 6 )
      {
         push @out, { name => $sname, level => $level };
      }
 
      if ( $skills{ $sname }->{ 'knowledges' } )
      {
         my %knowledges = %{ $skills{ $sname }->{ 'knowledges' } };
         foreach my $kname (keys %knowledges)
         {
            my $level = $knowledges{ $kname };
            if ( $level >= 6 )
            {
               push @out, { name => $kname, level => $level };
            }
         }
      }
   }
   return @out;
}


sub byLevel
{
   return 1  if $a->{ 'name' } eq 'Craftsman';
   return -1 if $b->{ 'name' } eq 'Craftsman';
   $b->{ 'level' } <=> $a->{ 'level' };
}

sub toString
{
   my $self = shift;
   my $charref = shift;
   return Common::toString( $self, $charref );
}

sub term
{
   my $self = shift;
   my $charref = shift;
   return Common::term( $charref );
}

sub riskAndReward # "Masterpiece"
{
   my $self = shift;
   my $charref = shift;
   my $text = '';

   # Unique to Craftsman

   my ($riskCharacteristic, @risk_and_reward_order) = @{$charref->{ 'risk and reward order' }};
   push @risk_and_reward_order, $riskCharacteristic;
   $charref->{ 'risk and reward order' } = \@risk_and_reward_order;

   my $char = $charref->{ 'upp' }->[ $riskCharacteristic ];
   my $ci = $riskCharacteristic+1;

   my ($points, $used) = masterPoints( $charref );

   my $total = $char + $points;
   $text .= "Masterpiece: using C$ci (=$char) + $points skill points = $total\n";   
   $text .= " - skills used: $used\n";

   if ( $total < 40 )
   {
      $text .= " - not enough points to attempt.\n";
	  $text .= Skills::addSkill( $charref, 'Craftsman' );
	  return $text;
   }
   
   my $masterpiece = $total - d6() - d6() - d6()   #
                            - d6() - d6() - d6()   #  9D task
							- d6() - d6() - d6();  # 
   if ( $masterpiece < 0 ) 
   {
      $text .= " - failed.\n";
      $text .= Skills::addSkill( $charref, 'Craftsman' );
      return $text;
   }
   
   # SUCCESS
   
   my $type = "Masterpiece";
      $type = "Perfect Masterpiece" if $total >= 55;

   $text .= "A $type has been created!\n";
   $text .= Skills::addSkill( $charref, 'Craftsman' ) for 1..3;
   $text .= Benefits::addBenefit( $charref, "$type/$total" );
   $charref->{ 'skillAwards' }++;
   
   return $text;
}

sub promotionTarget         { 0 }
sub enlistedPromotionTarget { 0 }
sub officerPromotionTarget  { 0 }
sub promotion               { 0 }
sub commission              { 0 }
sub automaticSkill          { 0 }

sub getSkillList
{
   return @skills;
}

sub getRandomSkill
{
   return $skills[ int(rand(@skills)) ];
}

sub continueTarget 
{ 
   my $self = shift;
   my $charref = shift;
   my $cs = $charref->{ 'skills' }->{ 'Craftsman' }->{ 'level' } * 2;
   $cs;
}

sub musterBenefitCount
{
   my $self = shift;
   my $charref = shift;

   return Common::musterBenefitCount( $charref );
}

sub musterBenefit
{
   my $self    = shift;
   my $charref = shift;
   my $type    = shift || 'random';
   $charref->{ 'benefitDM' } = $charref->{ 'terms' };
   return Common::musterBenefit( $charref, $type, \@cashout, \@benefits );
}

sub calculateRetirement { 0 }

1; # return 1 as all good modules should

