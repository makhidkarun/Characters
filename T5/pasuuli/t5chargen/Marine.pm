package Marine;
use Military;
use Common;
use strict;
use warnings;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = qw/ C1+1 C2+1 C3+1 C4+1 C5+1 C6+1
Trade Major Minor Gambler Athlete Trade
Fighter Fighter Soldier_Skill Soldier_Skill Tactics Leader
Vacc_Suit Fighter Hostile_Env Stealth Tactics Leader 
Fighter Fighter Flyer Stealth Tactics Leader
Soldier_Skill Survival Language Gunner Fighter Leader
Art Science Explosives Medic Seafarer Trade
/;

my @cashout = qw/ Low_Psg StarPass Mid_Psg High_Psg Cr20000 Cr25000 Cr30000 Cr50000 Retire_x2 /;
my @benefits = qw/ C1+1 Wafer_Jack C1+1 C2+1 C3+1 Life_Insurance Ship_Share C4+1 Knighthood /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'career' }       = 'Marine';
      $charref->{ 'careerAbbr' }   = 'M';
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
      
      return "Enlisted as M1.\n";
   }
   
   return 0;
}

sub getRank
{
   my $self    = shift;
   my $charref = shift;
   my $rank    = $charref->{ 'careerAbbr' };
   $rank       = 'O' if $charref->{ 'commissioned' };
   return $rank . $charref->{ 'rank' } . ' (' . $self->getTitle($charref) . ')';
}

sub getTitle
{
   my $self    = shift;
   my $charref = shift;
   my $rank    = $charref->{ 'rank' };
   my $officer = 1 if $charref->{ 'commissioned' };
   my @enlisted = ('** Error ** enlisted ranks problem in Marine.pm', 'Private', 'Lance Corporal', 'Sergeant', 'Staff Sergeant', 'Master Sergeant', 'Sergeant Major', 'Sergeant Major');
   my @officer  = ('** Error ** officer ranks problem in Marins.pm', '2nd Lieutenant', '1st Lieutenant', 'Captain', 'Force Commander', 'Lt Coronel', 'Coronel', 'Brigarier');

   $rank = 6 if $rank > 6;
   return $enlisted[ $rank ] unless $officer;
   return $officer[ $rank ];
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

   # Reward DM
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
   
   return 0 if $charref->{ 'rank' } == 6; # there is no M7+
   
   my $str = $charref->{ upp }->[0];
   return $str + $charref->{ 'wound badges' } + $charref->{ 'medalCount' };
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
   my $target = $charref->{ upp }->[2]; # END
   my $result  = Military::commission( $charref, $target );

   return $self->automaticSkill( $charref ) if $result;
   return $result;
}

sub automaticSkill
{
   my $self    = shift;
   my $charref = shift;
   my $rank    = $charref->{ 'rank' };
   
   unless( $charref->{ 'commissioned' } ) # enlisted
   {
      return 'Fighter'    if $rank == 1;
      return 'Heavy_Wpns' if $rank == 3;
      return 'Tactics'    if $rank == 4;
      return 'Leader'     if $rank == 5;
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

   $charref->{ upp }->[0]; # STR alone 
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

