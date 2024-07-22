package Merchant;
use Military;
use Common;
use strict;
use warnings;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = split /\s/, "C1+1 C2+1 C3+1 C4+1 C5+1 C6+1 "
                       . "Major Major Minor Minor Trade Trade "
                       . "Astrogator Pilot Medic Sensors Steward Gunner "
                       . "Broker Trader Diplomat Admin Steward Trader "
                       . "Computer Trader Driver Advocate Steward Comms "
                       . "Broker Admin Language Starship_Skill JOT Vacc_Suit "
                       . "Art Science Computer Comms Medic Trade"
                       ;

my @cashout = qw/ Low_Psg StarPass Mid_Psg High_Psg Cr20000 Cr25000 Cr30000 Cr50000 /;
my @benefits = qw/ C1+1 Wafer_Jack C1+1 C2+1 C3+1 Life_Insurance Ship_Share Knighthood /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'career' }       = 'Merchant';
      $charref->{ 'careerAbbr' }   = 'R';
      $charref->{ 'terms'  }       = 0;
      $charref->{ 'commissioned' } = 0; # enlisted
      $charref->{ 'rank'   }       = 0; # Spacehand
      $charref->{ 'ship shares' }  = 0;
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
      
      return "Enlisted as R0.\n";
   }
   
   return 0;
}

sub getRank
{
   my $self = shift;
   my $charref = shift;
#   my $rank = $charref->{ 'careerAbbr' };
#   $rank = 'M' if $charref->{ 'commissioned' };
#   return $rank . $charref->{ 'rank' };
   return $self->getTitle( $charref );
}

sub getTitle
{
   my $self    = shift;
   my $charref = shift;
   my $rank    = $charref->{ 'rank' };
   unless ( $charref->{ 'commissioned' } )
   {
      return 'Spacehand' if $rank == 0;
      return 'Steward Apprentice' if $rank == 1;
      return 'Driver Helper';
   }
   else
   {
      return 'Fourth Ofcr' if $rank == 1;
      return 'Third Officer' if $rank == 2;
      return 'Second Officer' if $rank == 3;
      return 'First Officer' if $rank == 4;
      return 'Captain' if $rank == 5;
      return 'Senior Captain';
   }
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

sub riskAndReward # reward is unique to Merchants
{
   my $self = shift;
   my $charref = shift;

   #
   # Risk is common
   #
   my ($char, $text) = Common::risk( $charref );
   
   #
   # Reward is unique to Merchants
   #
   return $text if Common::isDead( $charref );
   
   my $reward = $char - roll();
   if ( $reward >= 0 ) 
   {
      $text.= "Ship Shares granted.\n";
      $charref->{ 'ship shares' }++;
      Benefits::addBenefit( $charref, 'Ship_Share', $charref->{ 'ship shares' } );
   }
   
   return $text;
}

sub promotionTarget
{
   my $self = shift;
   my $charref = shift;
   
   return $self->enlistedPromotionTarget( $charref )
      unless $charref->{ 'commissioned' };

   return $self->officerPromotionTarget( $charref );
}

sub enlistedPromotionTarget
{
   my $self = shift;
   my $charref = shift;
   
   return 0 if $charref->{ 'rank' } == 2; # there is no 'R3' and up
   
   my $dex = $charref->{ 'upp' }->[ 1 ];
   my $int = $charref->{ 'upp' }->[ 3 ];
   
   $dex += 3 if $int >= 8;

   return $dex;
}

sub officerPromotionTarget
{
   my $self = shift;
   my $charref  = shift;
   
   return 0 if $charref->{ 'rank' } == 6; # there is no 'M7' and up
   
   my $target = 2 * $charref->{ 'terms' };
   my $int = $charref->{ 'upp' }->[3];

   $target += 3 if $int >= 8;

   return $target;
}

sub promotion
{
   my $self    = shift;
   my $charref = shift;
   my $target  = $self->promotionTarget( $charref );
   my $result  = Common::promotion( $charref, $target );
   
   # Automatic Skill Reward for Promotion
   return $self->automaticSkill( $charref ) if $result;
   return $result;
}

#
#  The commission target is the officer promotion target.
#
sub commission
{
   my $self = shift;
   my $charref = shift;
   my $target = $self->officerPromotionTarget( $charref );
   my $result = Common::commission( $charref, $target );
   
   # Automatic Skill Reward for Commission
   return $self->automaticSkill( $charref ) if $result;
   return $result;
}

sub automaticSkill
{
   my $self    = shift;
   my $charref = shift;
   my $rank    = $charref->{ 'rank' };
   
   return 'Steward'   if $rank == 1;
   return 'Engineer'  if $rank == 2;
   return '' unless $charref->{ 'commissioned' };
   return 'Astrogator' if $rank == 3;
   return 'Pilot'      if $rank == 4;
   
   return 1; # no automatic skill
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

   $charref->{ upp }->[0]; # STR
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
   $charref->{ 'benefitDM' } = $charref->{ 'rank' } if $charref->{ 'commissioned' };
   return Common::musterBenefit( $charref, $type, \@cashout, \@benefits );
}

sub calculateRetirement { 0 } # nada

1; # return 1 as all good modules should

