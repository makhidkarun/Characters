package Functionary;
use Common;
use strict;
use warnings;

###############################################################
#
#   SORT OF A VIOLATION OF SEPARATION OF CONCERNS
#
###############################################################
use Skills;
###############################################################
#
#   ....KIND OF, IN A WAY.
#
###############################################################

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = qw/ C1+1 C2+1 C3+1 C4+1 C5+1 C6+1
Major Major Minor Minor Trade Trade
High-G Vacc_Suit Driver Flyer Navigation Seafarer
Trade Art Science Any_Skill Bureaucrat Leader
Advocate Broker Trader Teacher Trade Driver
Advocate Comms Language Admin Bureaucrat Comms
Art Science Athlete Designer Seafarer Trade
/;

my @cashout = qw/ Cr5000 Cr10000 Cr15000 Cr20000 StarPass Cr30000 Cr40000 Cr50000 C60000 Pension_x2 Pension_x2/;
my @benefits = qw/ Forbidden C1+1 Wafer_Jack C1+1 C2+1 C3+1 C4+1 Life_Insurance TAS_Fellow Knighthood Directorship /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'former career' } = $charref->{ 'career' };
	  
      $charref->{ 'career' }       = $charref->{ 'former career' } . ' Functionary';
      $charref->{ 'careerAbbr' }   = 'F';
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
      
      return "A Functionary.\n";
   }
   
   return 0;
}

sub getRank
{
   my $self = shift;
   my $charref = shift;
   return "F" . $charref->{ 'rank' } . ' (' . $self->getTitle($charref) . ')';
}

sub getTitle
{
   my $self    = shift;
   my $charref = shift;
   my $rank    = $charref->{ 'rank' };
   my @rank    = ('Clerk', 'Supervisor', 'Senior Supervisor', 'Manager', 'Senior Manager', 'Assistant Director');

   return $rank[ $rank ] if $rank < 6;
   if ( $rank == 6 ) # Director
   {
      my $prev = $charref->{'former career'};

      return 'College President'    if $prev eq 'Scholar';
      return 'Association Director' if $prev eq 'Entertainer';
      return 'Starport Warden'      if $prev eq 'Merchant';
      return 'Bank President'       if $prev eq 'Rogue';
      return 'Director';
   }

   return 'Secretary' if $rank > 7;

   # Rank == 7:

   my $n = int(rand(6)+1);
   $n = $n . 'th' if $n > 3;
   $n = "3rd" if $n eq '3';
   $n = "2nd" if $n eq '2';
   $n = "1st" if $n eq '1';

   return "$n UnderSecretary"; 
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

sub riskAndReward # "office politics"
{
   my $self = shift;
   my $charref = shift;

   # Unique to Functionary

   my ($riskCharacteristic, @risk_and_reward_order) = @{$charref->{ 'risk and reward order' }};
   push @risk_and_reward_order, $riskCharacteristic;
   $charref->{ 'risk and reward order' } = \@risk_and_reward_order;

   my $char = $charref->{ 'upp' }->[ $riskCharacteristic ];
   my $ci = $riskCharacteristic+1;
   my $text = "Office Politics: using C$ci (=$char)\n";

   my $risk = $char - roll();
   if ( $risk < 0 ) 
   {
      $text .= " - failed.\n";
      $charref->{ 'terminated' } = 1;
   }
   
   my $reward = $char - roll();
   if ( $reward >= 0 ) # PROMOTED
   {
      $text .= " - promoted.\n";
      $charref->{ 'rank' }++;
      $charref->{ 'skillAwards' }++;
      my $skill = $self->automaticSkill( $charref );
      if ( $skill && $skill =~ /^[a-z]/i )
      {
         $text .= "Automatic skill: $skill\n";
         Skills::addSkill( $charref, $skill );
      }
   }
   
   return $text;
}

sub promotionTarget         { 0 }
sub enlistedPromotionTarget { 0 }
sub officerPromotionTarget  { 0 }
sub promotion               { 0 }
sub commission              { 0 }

sub automaticSkill
{
   my $self    = shift;
   my $charref = shift;
   my $rank    = $charref->{ 'rank' };

   return 'Bureaucrat' if $rank == 0 || $rank == 3;
   return 'Admin'      if $rank == 2;
   return undef;
}

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
   
   # All or nothing:
   
   return 0 if $charref->{ 'terminated' };
   return 100;
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

