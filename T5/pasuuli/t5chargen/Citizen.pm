package Citizen;
use Common;
use strict;
use warnings;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = qw/ C1+1 C2+1 C3+1 C4+1 C5+1 C6+1
Major Major Minor Minor Trade Trade
Seafarer Navigation Hostile_Env Flyer Driver Vacc_Suit
Admin Broker Computer Animals Bureaucrat Trader
Advocate Broker Trader Liaison Counsellor Teacher
Art Science Trade Driver Bureaucrat Computer
Art Science Athlete Medic JOT Trade
/;

my @cashout = qw/ Cr5000 Cr10000 Cr15000 Cr20000 StarPass Cr30000 Cr40000 Cr50000 Cr50000 /;
my @benefits = qw/ Secret Wafer_Jack C1+1 C2+1 C3+1 C4+1 Life_Insurance C6+1 TAS_Fellow /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'career' }       = 'Citizen';
      $charref->{ 'careerAbbr' }   = 'C';
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
      
      return "A Citizen.\n";
   }
   
   return 0;
}

sub getRank
{
   undef; # this is the right way to do it.
#   my $self = shift;
#   my $charref = shift;
#   return "C" . $charref->{ 'terms' }; # not really rank, but...
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

sub riskAndReward
{
   my $self = shift;
   my $charref = shift;

   # Unique to Citizen

   my ($riskCharacteristic, @risk_and_reward_order) = @{$charref->{ 'risk and reward order' }};
   push @risk_and_reward_order, $riskCharacteristic;
   $charref->{ 'risk and reward order' } = \@risk_and_reward_order;

   my $char = $charref->{ 'upp' }->[ $riskCharacteristic ];
   my $ci = $riskCharacteristic+1;
   my $text;

   $text = "Citizen Life: using C$ci (=$char)\n";

   my $success = $char - roll();
   if ( $success > 0 ) 
   {
      my $target = $charref->{ 'citizenLife' } || 'job';

      if( $target eq 'job' )
      {
         if ( ! $charref->{ 'job' } )
         {
            my $randomSkill = Skills::getRealRandomSkill();
            $charref->{ 'job' } = $randomSkill;
            $text .= "Job: " . $charref->{ 'job' } . "\n";
            $text .= Skills::addSkill( $charref, $charref->{ 'job' } ) for 1..4;
         }
         else
         {
            $text .= "Job development:\n";
            $text .= Skills::addSkill( $charref, $charref->{ 'job' } );
         }
         $charref->{ 'citizenLife' } = 'hobby';
      }
      elsif( $charref->{ 'citizenLife' } eq 'hobby' )
      {
         if ( ! $charref->{ 'hobby' } )
         {
            my $randomSkill = Skills::getRealRandomSkill(1);
            $charref->{ 'hobby' } = $randomSkill;
            $text .= "Hobby: " . $charref->{ 'hobby' } . "\n";
            $text .= Skills::addSkill( $charref, $charref->{ 'hobby' } ) for 1..2;
         }
         else
         {
            $text .= "Hobby development:\n";
            $text .= Skills::addSkill( $charref, $charref->{ 'hobby' } );
         }
         $charref->{ 'citizenLife' } = 'job';
      }
   }
   else
   {
      $text .= " - failed\n";
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

sub continueTarget { 10 }

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

