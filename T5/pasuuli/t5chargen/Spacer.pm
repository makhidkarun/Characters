package Spacer;
use Military;
use Common;
use strict;
use warnings;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = qw/ C1+1 C2+1 C3+1 C4+1 C5+1 C6+1
Gambler Major Major Athlete Trade Trade
Fighter Fleet_Tactics Pilot Starship_Skill Gunner Sensors
Astrogator Fleet_Tactics Computer Starship_Skill Gunner Sensors
Gunner Gunner Sensors Counsellor Strategy Computer
Diplomat Admin Language Starship_Skill Liaison Comms
Art Science Athlete Medic Zero-G Trade
/;

my @cashout = qw/ Low_Psg StarPass Mid_Psg High_Psg Cr20000 Cr25000 Cr30000 Retire_x2 /;
my @benefits = qw/ C1+1 Wafer_Jack C1+1 C2+1 C3+1 Life_Insurance Ship_Share Knighthood /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'career' }       = 'Spacer';
      $charref->{ 'careerAbbr' }   = 'R';
      $charref->{ 'terms'  }       = 0;
      $charref->{ 'commissioned' } = 0; # enlisted
      $charref->{ 'rank'   }       = 1; # private
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
      
      return "Enlisted as R1.\n";
   }
   
   return 0;
}

sub getRank
{
   my $self = shift;
   my $charref = shift;
   my $rank = $charref->{ 'careerAbbr' };
   $rank = 'O' if $charref->{ 'commissioned' };
   return $rank . ($charref->{ 'rank' }) . ' (' . $self->getTitle( $charref ) . ')';
}

sub getTitle
{
   my $self = shift;
   my $charref = shift;
   my @rating = ('** Error ** problem with enlisted ranks in Merchant.pm', 'Spacehand', 'Able Spacer', 'Petty Officer Second', 'Petty Officer First', 'Chief Petty Officer', 'Master Chief Petty Officer', 'Master Chief Petty Officer');
   my @officer = ('** Error ** problem with officer ranks in Merchant.pm', 'Ensign', 'Sublieutenant', 'Lieutenant', 'Lt Commander', 'Commander', 'Captain', 'Admiral');
   my $rank = $charref->{ 'rank' };
   $rank = 6 if $rank > 6;

   return $officer[ $rank ] if $charref->{ 'commissioned' };
   return $rating[ $rank ];
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

   # Emulate Branch with a Reward DM
   my $DM = -1;
   $DM = 0 if $charref->{ 'skills' }->{ 'Engineer' } && $charref->{ 'skills' }->{ 'Engineer' } > 2;
   
   return Military::riskAndReward( $charref, $DM );
}

sub promotionTarget
{
   my $self = shift;
   my $charref = shift;
   
   return $self->officerPromotionTarget( $charref )
      if $charref->{ 'commissioned' };

   return $self->enlistedPromotionTarget( $charref );
}

sub enlistedPromotionTarget
{
   my $self = shift;
   my $charref = shift;
   
   return 0 if $charref->{ 'rank' } == 6; # there is no 'R7' and up

   my $dex = $charref->{ upp }->[1];
   return $dex + $charref->{ 'wound badges' } + $charref->{ 'medalCount' };
}

sub officerPromotionTarget
{
   my $self = shift;
   my $charref  = shift;
   
   return 0 if $charref->{ 'rank' } == 7; # there is no 'O8' and up
   
   my $soc = $charref->{ upp }->[5];
   return $soc + $charref->{ medalCount } + $charref->{ 'wound badges' };
}

sub promotion
{
   my $self    = shift;
   my $charref = shift;
   my $target  = $self->promotionTarget( $charref );
   my $result  = Military::promotion( $charref, $target );

   return $self->automaticSkill( $charref ) if $result;
   return $result;
}

sub commission
{
   my $self = shift;
   my $charref = shift;
   my $target = $charref->{ upp }->[1]; # Dex
   my $result = Military::commission( $charref, $target );

   return $self->automaticSkill( $charref ) if $result;
   return $result;
}

sub automaticSkill
{
   my $self = shift;
   my $charref = shift;
   my $rank    = $charref->{ 'rank' };
  
   unless ( $charref->{ 'commissioned' } ) # rating
   {
      return 'Fighter' if $rank == 1;
      return 'Gunner'  if $rank == 4;
      return 'Sensors' if $rank == 5;
   }
   else # officer
   {
      return 'Astrogator' if $rank == 1;
      return 'Engineer'   if $rank == 3;
      return 'Pilot'      if $rank == 4;
      return 'Leader'     if $rank == 6;
   }
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

   7 + $charref->{ 'terms' };
}

sub musterBenefitCount
{
   my $self = shift;
   my $charref  = shift;

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

sub calculateRetirement
{
   my $self = shift;
   my $charref  = shift;
   return Military::calculateRetirement( $charref );
}

1; # return 1 as all good modules should

