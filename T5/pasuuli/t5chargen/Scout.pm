package Scout;
use Military;
use Common;
use strict;
use warnings;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = qw/ C1+1 C2+1 C3+1 C4+1 C5+1 C6+1
Major Major Minor Minor Trade Trade
Comms Language Computer JOT Gunner Starship_Skill
Survey Survival Hostile_Env Animals Vacc_Suit Navigation
Diplomat Sensors Fighter Teacher Trader Streetwise
Survey Flyer Language Starship_Skill Engineer Comms
Art Science Athlete Medic Seafarer Trader
/;

my @cashout = qw/ Low_Psg Mid_Psg Mid_Psg Cr15000 StarPass Cr25000 Cr30000 Cr35000 Cr40000 Cr45000 Cr50000 Cr100000  /;
my @benefits = qw/ Wafer_Jack C5+1 C1+1 C2+1 C3+1 C4+1 Ship_Share Life_Insurance C6+1 TAS_Fellow Fame-2 Knighthood  /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'career' }       = 'Scout';
      $charref->{ 'careerAbbr' }   = 'S';
      $charref->{ 'terms'  }       = 0;
      $charref->{ 'commissioned' } = 0; 
      $charref->{ 'rank'   }       = 0; # no such thing
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
      
      return "Enlisted as Scout.\n";
   }
   
   return 0;
}

sub getRank
{
   my $self = shift;
   my $charref = shift;
   return undef; # no such thing as ranks
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
   
   # Terms are unique for Scouts in that they have 8 skills per term
   
   $charref->{ 'terms' }++;
   $charref->{ 'skillAwards' } = 8;

   # return if $quiet;

   my $out = "Term " . $charref->{ 'terms' } . ": ";
   $out .= Common::uppToString( $charref );  # $out .= sprintf("%X", $_) for @{$charref->{ 'upp' }};
   $out .= "\n";
   return $out;
}

sub riskAndReward
{
   my $self = shift;
   my $charref = shift;

   my ($riskCharacteristic, @risk_and_reward_order) = @{$charref->{ 'risk and reward order' }};
   push @risk_and_reward_order, $riskCharacteristic;
   $charref->{ 'risk and reward order' } = \@risk_and_reward_order;

   my $char = $charref->{ 'upp' }->[ $riskCharacteristic ];
   my $ci = $riskCharacteristic+1;
   my $text;

   if ( $char < roll() ) # let's be chicken
   {
      $charref->{ 'skillAwards' } = 4;
      $text = "Scout volunteers for Courier duty (C$ci=$char).\n";
   } 
   else # go for it
   {
      $text = "Risk and Reward: using C$ci (=$char)\n";

      my $injury = roll() - $char;
      if ( $injury > 0 ) # wounded
      {
         $text .= Common::injury( $charref, $riskCharacteristic, $injury );
      }

      my $reward = $char - roll();
      if ( $reward >= 0 )
      {
         $text .= "Discovery made.\n";
         # Discovery
         # Land Grant
         # Fame+1
         Benefits::addBenefit( $charref, "Discovery",  1 );
         Benefits::addBenefit( $charref, "Land Grant", 1 );
         Benefits::addBenefit( $charref, "Fame",       1 );
      }
   }
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

   $charref->{ 'upp' }->[ 3 ]; # Intelligence
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

sub calculateRetirement
{
   my $self = shift;
   my $charref  = shift;
   return Military::calculateRetirement( $charref );  # ?? DO Scouts have military retirement?
}

1; # return 1 as all good modules should

