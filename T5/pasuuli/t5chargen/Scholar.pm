package Scholar;
use Common;
use strict;
use warnings;

sub new  
{ 
   return bless {}, shift;
}
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = split /\s/, "C1+1 C2+1 C3+1 C4+1 C5+1 C6+1 "
                       . "Major Major Minor Minor Trade Trade "
                       . "Seafarer Navigation Hostile_Env Flyer Driver Vacc_Suit "
                       . "Survey Survival Hostile_Env Animals Bureaucrat Navigation "
                       . "Fighter Fighter Flyer Stealth Gunner Sensors "
                       . "Scholar Admin Language Starship_Skill Bureaucrat Comms "
                       . "Art Science Athlete Medic Seafarer Trade"
                       ;

my @cashout = qw/ Low_Psg Mid_Psg High_Psg Cr15000 StarPass Cr25000 Cr30000 Cr35000 Cr40000 Cr50000 /;
my @benefits = qw/ C5+1 Wafer_Jack C5+1 C1+1 C2+1 C3+1 C4+1 Fame Ship_Share Life_Insurance /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $target = 0; # str = $charref->{ upp }->[0] || 7; ???
   if ( $drafted || roll() < $target )
   {
      $charref->{ 'career' }       = 'Scholar';
      $charref->{ 'careerAbbr' }   = 'S';
      $charref->{ 'terms'  }       = 0;
      $charref->{ 'commissioned' } = 0; # i.e. professional
      $charref->{ 'tenured' }      = 0;
      $charref->{ 'rank'   }       = 0; # Amateur
      $charref->{ 'skillAwards' }  = 0;
      $charref->{ 'publications' } = 0;
      $charref->{ 'skills' }       = {} unless $charref->{ 'skills' };
      $charref->{ 'benefits' }     = {} unless $charref->{ 'benefits' };
      $charref->{ 'cash' }        |= 0;
      $charref->{ 'retirement' }  |= 0;
      $charref->{ 'major' }        = Skills::getRealRandomSkill();
      $charref->{ 'minor' }        = Skills::getRealRandomSkill();
      my $text = "Scholar.\n";

      $charref->{ 'rank' } = 1 if $charref->{ 'upp' }->[3] >= 8;

      #
      #  Grant the scholar skill in his Major and Minor
      #
      $text .= Skills::addSkill( $charref, 'Major' ) for 1..2;
      $text .= Skills::addSkill( $charref, 'Minor' );
 
      # 
      #  Figure out risk and reward order
      # 
      $charref->{ 'risk and reward order' } = Common::riskAndRewardOrder( $charref );
      
      return $text;
   }
   
   return 0;
}

sub getRank
{
   my $self = shift;
   my $charref = shift;
   return '(' . $self->getTitle( $charref ) . ')';

#   my $rank = $charref->{ 'careerAbbr' };
#   $rank = 'P' if $charref->{ 'commissioned' }; # professional
#   $rank = 'T' if $charref->{ 'tenured' };      
#   $rank = $rank . $charref->{ 'rank' };
#   return " " . $rank . " (" . $self->getTitle( $charref ) . ")";
}

sub getTitle
{
   my $self    = shift;
   my $charref = shift;
   my $rankno  = $charref->{ 'rank' }; 
   my $rank    = 'Non-Traditional';
      $rank    = 'Amateur'                 if $rankno == 0;
      $rank    = 'Lecturer'                if $rankno == 1; 
      $rank    = 'Instructor'              if $rankno == 2;
      $rank    = 'Assistant Professor'     if $rankno == 3;
      $rank    = 'Associate Professor'     if $rankno == 4;
      $rank    = 'Professor'               if $rankno == 5;
      $rank    = 'Distinguished Professor' if $rankno >= 6;
      $rank    = "Tenured $rank"           if $charref->{ 'tenured' };      

   return $rank;
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
   Common::term( $charref );
}

sub riskAndReward
{
   my $self = shift;
   my $charref = shift;

   # 
   #  The Scholar's Reward is publication. 
   #

   my ($riskCharacteristic, @risk_and_reward_order) = @{$charref->{ 'risk and reward order' }};
   push @risk_and_reward_order, $riskCharacteristic;
   $charref->{ 'risk and reward order' } = \@risk_and_reward_order;

   my $char = $charref->{ upp }->[ $riskCharacteristic ];

   my $text = "Risk and Reward: using C" . ($riskCharacteristic+1) . " ($char)\n";

   my $risk = roll() - $char;
   my $reward = $char - roll();
   if ( $risk > 0 ) # unproductive
   {
      $text .= "Research unproductive.\n";
   }
   elsif ( $reward >= 0 ) # published
   {
      $text .= "Results are published!\n";
      $charref->{ 'publications' }++;
      $text .= Skills::addSkill( $charref, 'Major' ) for 1..2;
      if ( $reward >= 4 ) # award-winning
      {
         $text .= " - award-winning!\n";
         $charref->{ 'publications' }++;
      }
   }

   return $text;
}

sub promotionTarget
{
   my $self = shift;
   my $charref = shift;
   
   # Amateurs can't get promoted.
   return 0 if $charref->{ 'upp' }->[4] < 8; 

   my $TN = $charref->{ 'upp' }->[3] + $charref->{ 'publications' };

   # If not tenured and rank == 3: try for tenure.
   if ( $charref->{ 'rank' } == 3 )
   {
      if ( roll() < $charref->{ 'publications' } * 3 )
      {
         $charref->{ 'tenured' } = 1;
      }
   }

   # If tenured or rank < 3: 2D < Int + Pub for promotion.
   return $TN if $charref->{ 'tenured' } || $charref->{ 'rank' } < 3;

   # Maybe next term.
   return 0;
}

sub promotion
{
   my $self    = shift;
   my $charref = shift;
   my $target  = $self->promotionTarget( $charref );
   return Common::promotion( $charref, $target );
}

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

   $charref->{ upp }->[4] + $charref->{ 'publications' }; # EDU + Pubs
}

sub musterBenefitCount
{
   my $self = shift;
   my $charref  = shift;
   Common::musterBenefitCount( $charref );
}

sub musterBenefit
{
   my $self    = shift;
   my $charref = shift;
   my $type    = shift || 'random';
   $charref->{ 'benefitDM' } = $charref->{ 'rank' };
   return Common::musterBenefit( $charref, $type, \@cashout, \@benefits );
}

sub calculateRetirement { 0 }
#{
#   my $self = shift;
#   my $charref  = shift;
#   return Military::calculateRetirement( $charref );
#}

1; # return 1 as all good modules should

