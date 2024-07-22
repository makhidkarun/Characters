package Rogue;
use Common;
use strict;
use warnings;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = qw/ C1+1 C2+1 C3+1 C4+1 C5+1 C6+1
Science Major Minor Art Trade Trade
Driver Flyer Hostile_Env High-G Vacc_Suit Navigation
Starship_Skill Pilot Engineer Zero-G Vacc_Suit Astrogator
Trader Broker Computer JOT Teacher Fighter
Advocate Counsellor Language Leader Streetwise Comms
Art Science Athlete Soldier_Skill Stealth Trade
/;

my @cashout = qw/ Low_Psg Mid_Psg High_Psg Cr50000 StarPass Cr70000 Cr80000 Cr90000 Cr100000 Cr110000 Cr120000 /;
my @benefits = qw/ Forbidden C1+1 Wafer_Jack C2+1 C3+1 TAS_Fellow Life_Insurance C4+1 Directorship Ship_Share Knighthood /;

my %schemeBenefit = 
(
   Craftsman   => 'Cr100000',
   Scholar     => 'Cr20000',
   Entertainer => 'Cr100000',
   Citizen     => 'Cr10000',
   Scout       => 'Type S Scout',
   Merchant    => 'Ship_Share',
   Spacer      => 'Cr50000',
   Soldier     => 'Cr30000',
   Agent       => 'Cr100000',
   Noble       => 'Cr200000',
   Marine      => 'Cr40000',
   Functionary => 'Cr30000',
);

my @schemes = keys %schemeBenefit;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   my $drafted = shift;

   my $str = $charref->{ upp }->[0] || 7;
   if ( $drafted || roll() < $str )
   {
      $charref->{ 'career' }       = 'Rogue';
      $charref->{ 'careerAbbr' }   = 'R';
      $charref->{ 'terms'  }       = 0;
      $charref->{ 'commissioned' } = 0; 
      $charref->{ 'rank'   }       = 0; 
      $charref->{ 'wound badges' } = 0;
      $charref->{ 'permanent injury' } = 0;
      $charref->{ 'skillAwards' }  = 0;
      $charref->{ 'medalCount' }   = 0;
      $charref->{ 'schemes' }      = 0;
      $charref->{ 'medals' }       = {} unless $charref->{ 'medals' };
      $charref->{ 'skills' }       = {} unless $charref->{ 'skills' };
      $charref->{ 'benefits' }     = {} unless $charref->{ 'benefits' };
      $charref->{ 'cash' }        |= 0;
      $charref->{ 'retirement' }  |= 0;
      $charref->{ 'major' }        = Skills::getRealRandomSkill();
      $charref->{ 'minor' }        = Skills::getRealRandomSkill();

      # 
      #  Figure out Controlling Characteristic (CC)
      # 
      my $rro = Common::riskAndRewardOrder( $charref, [0,1,2,3,4,5] );
      my $CC  = $rro->[0];

      my $text = "Became a Rogue.\n";
      $text .= "Controlling Characteristic: C" . ($CC+1) . " (" . $charref->{'upp'}->[$CC] . ")" . "\n";
      $charref->{ 'controlling characteristic' } = $CC;
      $charref->{ 'risk and reward order' } = [ $CC ]; # 'cause the main engine has this.  dumb I know.
      
      return $text;
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
   $out .= Common::uppToString( $charref );  # $out .= sprintf("%X", $_) for @{$charref->{ 'upp' }};
   $out .= "\n";
   return $out;
}

sub riskAndReward
{
   my $self = shift;
   my $charref = shift;

   ###################################################
   #
   #  Risk and Reward is quite unique for the Rogue
   #
   ###################################################
   if ( $charref->{ 'imprisoned' } )
   {
      $charref->{ 'skillAwards' }++;
      $charref->{ 'imprisoned' } = 0;
      return "In prison.\n";
   }

   # Select Scheme
   my $scheme  = $schemes[ rand(@schemes) ]; 
   my $benefit = $schemeBenefit{ $scheme };

   # Risk is unique for Rogues
   my $CC = $charref->{ 'controlling characteristic' };
   my $asset = $charref->{ 'upp' }->[$CC] + $charref->{ 'terms' };

   my $text = "Scheme: $scheme\n";

   my $risk = roll() - $asset;
   if ( $risk > 0 )
   {
      $text .= "Caught!  Imprisoned for this term and next.\n";
      $charref->{ 'skillAwards' } += 1;
      $charref->{ 'imprisoned' } = 1;
   }

   # Reward
   my $reward = $asset - roll();
   if ( $reward >= 0 )
   {
      $text .= "Successful scheme ($scheme).\n";
      $charref->{ 'skillAwards' } += 4;

      # Number of times benefit is received.
      my $iterations = int(rand(6)+1);
      $iterations = int(rand(3)+1) if $charref->{ 'imprisoned' };
      
      $text .= "(Value halved due to imprisonment)\n" if $charref->{ 'imprisoned' };

      $text .= Benefits::addBenefit( $charref, $benefit ) for 1..$iterations;
   }
   else
   {
      $text .= "Failed scheme ($scheme). Attempt abandoned.\n";
      $charref->{ 'skillAwards' } += 1;
      Benefits::addBenefit( $charref, 'Fame', 1 );
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

   my $CC = $charref->{ 'controlling characteristic' }; 
   $charref->{ 'upp' }->[$CC] + $charref->{ 'terms' };
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

sub calculateRetirement { 0 } # Rogues don't "retire"

1; # return 1 as all good modules should

