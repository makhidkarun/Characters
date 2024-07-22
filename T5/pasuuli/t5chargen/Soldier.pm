package Soldier;
use Military;
use Common;
use strict;
use warnings;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = qw/ C1+1 C2+1 C3+1 C4+1 C5+1 C6+1
Athlete Major Minor Gambler Trade Trade
Fighter Vacc_Suit Fighter Stealth Leader Tactics
Admin Fighter Hostile_Env Animals Liaison Navigation
Fighter Vacc_Suit Driver Stealth Heavy_Wpns Sensors
Soldier_Skill Liaison Language Soldier_Skill Computer Tactics
Art Science Explosives Medic Seafarer Trade
/;

my @cashout = qw/ Low_Psg Mid_Psg High_Psg Cr15000 StarPass Cr250000 Cr30000 Retire_x2 /;
my @benefits = qw/ Forbidden C1+1 C1+1 Life_Insurance C5+1 Wafer_Jack C4+1 Knighthood /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'career' }       = 'Soldier';
      $charref->{ 'careerAbbr' }   = 'S';
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

      return "Enlisted as S1.\n";
   }
   return 0;
}

sub getRank
{
   my $self = shift;
   my $charref = shift;
   my $rank = $charref->{ 'careerAbbr' };
   $rank = 'O' if $charref->{ 'commissioned' };
   return $rank . ($charref->{ 'rank' }) . ' (' . $self->getTitle($charref) . ')';
}

sub getTitle
{
   my $self = shift;
   my $charref = shift;
   my @enlisted = ('** Error ** enlisted ranks wrong in Soldier.pm', 'Private', 'Corporal', 'Sergeant', 'Staff Sergeant', 'Master Sergeant', 'Sergeant Major', 'Sergeant Major');
   my @officer  = ('** Error ** officer ranks wrong in Soldier.pm', '2nd Lieutenant', '1st Lieutenant', 'Captain', 'Major', 'Lt Colonel', 'Colonel', 'General' );
   my $rankno   = $charref->{ 'rank' };
   $rankno      = 6 if $rankno > 6;
 
   return $enlisted[ $rankno ] unless $charref->{ 'commissioned' };
   return $officer[ $rankno ];
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

   my $DM = -1 * int(rand(1.3+3));
   $DM++ if $charref->{ 'upp' }->[ 4 ] >= 10;
   
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
   
   return 0 if $charref->{ 'rank' } == 6; # there is no S7+
   
   my $end = $charref->{ upp }->[2];
   return $end + $charref->{ 'wound badges' } + $charref->{ 'medalCount' };
}

sub officerPromotionTarget
{
   my $self = shift;
   my $charref  = shift;
   
   return 0 if $charref->{ 'rank' } == 7; # there is no O8+

   my $soc = $charref->{ upp }->[5];
   return $soc + $charref->{ 'medalCount' } + $charref->{ 'wound badges' };
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
   my $target = $charref->{ upp }->[2]; # C3
   my $result =  Military::commission( $charref, $target );

   return $self->automaticSkill( $charref ) if $result;
   return $result;
}

sub automaticSkill
{
   my $self    = shift;
   my $charref = shift;
   my $rank    = $charref->{ 'rank' };
  
   unless ($charref->{ 'commissioned' }) # rating
   {
      return 'Fighter'    if $rank == 1;
      return 'Heavy_Wpns' if $rank == 3;
      return 'Leader'     if $rank == 4;
   }
   else # officer
   {
      return 'Leader'     if $rank == 1 || $rank == 6;
      return 'Tactics'    if $rank == 4;
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

   7;
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

sub calculateRetirement
{
   my $self = shift;
   my $charref  = shift;
   return Military::calculateRetirement( $charref );
}

1; # return 1 as all good modules should

