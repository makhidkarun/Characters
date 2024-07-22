package Agent;
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
Zero-G Vacc_Suit Pilot Starship_Skill Gunner Sensors
Survey Survival Hostile_Env Animals Bureaucrat Navigation
Fighter Soldier_Skill Flyer Stealth Gunner Streetwise
Any_Knowledge Admin Language Starship_Skill Forensics Comms
Art Science Athlete Medic Seafarer Trade
/;

my @cashout = qw/ Low_Psg Mid_Psg High_Psg Cr15000 StarPass Cr25000 Cr30000 Cr35000 Cr40000 Cr45000 Cr90000 /;
my @benefits = qw/ Forbidden C1+1 Wafer_Jack C1+1 C2+1 C3+1 C4+1 Ship_Share Life_Insurance C6+1 Knighthood  /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'career' }       = 'Agent';
      $charref->{ 'careerAbbr' }   = 'A';
      $charref->{ 'terms'  }       = 0;
      $charref->{ 'commissioned' } = 0; 
      $charref->{ 'rank'   }       = 0; # no such thing
      $charref->{ 'wound badges' } = 0;
      $charref->{ 'permanent injury' } = 0;
      $charref->{ 'skillAwards' }  = 0;
      $charref->{ 'medalCount' }   = 0;
      $charref->{ 'commendations' } = 0;
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
   
   # Terms are unique for Agents
   
   $charref->{ 'terms' }++;
   $charref->{ 'skillAwards' } = 2;

   # return if $quiet;

   my $out = "Term " . $charref->{ 'terms' } . ": ";
   $out .= Common::uppToString( $charref );  # sprintf("%X", $_) for @{$charref->{ 'upp' }};
   $out .= "\n";
   return $out;
}

sub riskAndReward
{
   my $self = shift;
   my $charref = shift;
   my $text = '';

   # Select Mission
   my @missions = qw/Soldier Soldier Marine Marine Navy Navy Scholar Scholar Entertainer Entertainer Citizen Citizen Merchant Merchant Scout Scout Noble Functionary/;
   my $mission = $missions[ rand( @missions ) ];
   $text .= Skills::addSkill( $charref, "${mission}_skill" );

   # Risk
   my ($char, $text2) = Common::risk( $charref );

   $text .= $text2;

   # Reward
   my $reward = $char - roll();
   if ( $reward >= 0 )
   {
      $text .= "Successful mission ($mission).\n";
      $charref->{ 'skillAwards' } += 4;
      $charref->{ 'commendations' }++;
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

   $charref->{ 'upp' }->[ 0 ] + $charref->{ 'terms' }; # Str + Terms
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

   $charref->{ 'benefitDM' } = $charref->{ 'terms' } + $charref->{ 'commendations' };
   return Common::musterBenefit( $charref, $type, \@cashout, \@benefits );
}

sub calculateRetirement
{
   my $self = shift;
   my $charref  = shift;
   return Military::calculateRetirement( $charref );  # ?? DO Scouts have military retirement?
}

1; # return 1 as all good modules should

