package Entertainer;
use Skills;
use Common;
use strict;
use warnings;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @vocations = qw/Actor Artist Author Dancer Musician Chef/;

my $talent = $vocations[ rand @vocations ];

my @skills = split /\s/, "C1+1 C2+1 C3+1 C4+1 C5+1 C6+1 "
                       . "Major Major Minor Minor Trade Trade "
                       . "Zero-G Vacc_Suit Pilot Astrogator Sensors Starship_Skill "
                       . "Survey Survival Hostile_Env Animals Bureaucrat Navigation "
                       . "Broker Trader Advocate Liaison Diplomat Bureaucrat "
                       . "Art Art Language Admin Bureaucrat Broker "
                       . "Art Art Athlete Medic Trade Trade"
                       ;

my @cashout = qw/ Low_Psg Mid_Psg High_Psg Cr10000 StarPass Cr30000 Cr40000 Cr50000 Cr60000 Cr70000 /;
my @benefits = qw/ C1+1 Wafer_Jack C5+1 C1+1 C2+1 C3+1 C4+1 Ship_Share Life_Insurance TAS_Fellow /;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

#   my $str = $charref->{ upp }->[0] || 7;
#   if ( $drafted || roll() < $str )
#   {
      $charref->{ 'career' }       = $talent;
      $charref->{ 'careerAbbr' }   = 'E';
      $charref->{ 'terms'  }       = 0;
      $charref->{ 'commissioned' } = 0; # no such thing
      $charref->{ 'rank'   }       = 0; # no such thing
      $charref->{ 'wound badges' } = 0; # no such thing
      $charref->{ 'permanent injury' } = 0; # no such thing
      $charref->{ 'skillAwards' }  = 0;
      $charref->{ 'medalCount' }   = 0; # no such thing
      $charref->{ 'medals' }       = {}; # no such thing  unless $charref->{ 'medals' };
      $charref->{ 'skills' }       = {} unless $charref->{ 'skills' };
      $charref->{ 'benefits' }     = {} unless $charref->{ 'benefits' };
      $charref->{ 'cash' }        |= 0;
      $charref->{ 'retirement' }  |= 0;
      $charref->{ 'talent' }       = $talent;
      $charref->{ 'major' }        = Skills::getRealRandomSkill();
      $charref->{ 'minor' }        = Skills::getRealRandomSkill();

      my $level = Common::roll();
      $charref->{ 'fame' }         = $level;

      # 
      #  Figure out risk and reward order
      # 
      $charref->{ 'risk and reward order' } = Common::riskAndRewardOrder( $charref );
       
      my $text = "Enlisted as $talent.\n";
      $text .= Skills::addSkill( $charref, $talent ) for 1..$level;
      return $text;
#   }
   
}

sub getRank
{
   my $self = shift;
   my $charref = shift;
   return 'Fame ' . $charref->{ 'fame' };
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
   my $text = '';

   #
   #  R&R is unique to Entertainers
   #
   
   return "" unless $charref->{ 'terms' } > 1; # skip first term
  
   # roll flux to adjust fame
   my $delta = Common::flux();

   # roll up to two more times.  
   if ( $delta <= 0 )
   {
      $delta += Common::flux();
   }

   # potentially the last roll.
   if ( $delta <= 0 ) 
   {
      $delta += Common::flux();
   } 

   $charref->{ 'fame' } += $delta;
   $text = "Fame is now " . $charref->{ 'fame' };

   if ( $delta > 0 ) # fame & talent increases
   {
      $charref->{ 'skillAwards' } += 2;
      $text .= Skills::addSkill( $charref, $talent );
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
   my $index = int(rand(@skills));
#   print "index: $index\n";
   return $skills[ $index ];
}

sub continueTarget
{
   my $self = shift;
   my $charref = shift;

   $charref->{ 'fame' };
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

   $charref->{ 'benefitDM' } = $charref->{ 'terms' };
   return Common::musterBenefit( $charref, $type, \@cashout, \@benefits );
}

sub calculateRetirement { 0 }

1; # return 1 as all good modules should

