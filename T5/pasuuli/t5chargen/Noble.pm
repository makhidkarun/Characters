package Noble;
use strict;
use warnings;
use Military;
use Common;
use Benefits;

sub new  { bless {}, shift }
sub roll { return int(rand(6)+1)+int(rand(6)+1) }
sub flux { return roll() - 7 }

my $quiet = 0;

sub quiet { $quiet = shift }

my @skills = split /\s/, "C1+1 C2+1 C3+1 C4+1 C5+1 C6+1 "
                       . "Major Major Minor Minor Trade Trade "
                       . "Flyer Driver Pilot Starship_Skill High-G Zero-G "
                       . "Advocate Counsellor Bureaucrat Liaison Leader Leader "
                       . "Liaison Strategy Tactics Diplomat Advocate Leader "
                       . "Capital Admin Language Starship_Skill Bureaucrat Comms "
                       . "Art Science Computer Comms Seafarer Trade"
                       ;

my @cashout = qw/ Cr20000 Cr30000 High_StarPass High_StarPass High_StarPass Cr140000 Cr160000 Cr180000 Cr200000 Cr220000 Cr240000 Cr260000/;
my @benefits = qw/ Wafer_Jack C1+1 C2+1 C3+1 C4+1 Ship_Share Proxy_1D Proxy_2D Life_Insurance C5+1 Directorship TAS_Life_Member/;
my @proxies = qw/Proxy_1 Proxy_2 Proxy_1D Proxy_1D Proxy_Flux Proxy_Flux Proxy_2D Proxy_2D Proxy_2D Proxy_2D Proxy_2D Proxy_2D/;

sub begin 
{
   my $self = shift;
   my $charref = shift;
   $charref->{ 'upp' }->[5] = 10 if $charref->{ 'upp' }->[5] < 10;

   #my $str = $charref->{ upp }->[0] || 7;
   {
      $charref->{ 'career' }       = 'Noble';
      $charref->{ 'careerAbbr' }   = 'N';
      $charref->{ 'terms'  }       = 0;
      $charref->{ 'commissioned' } = 1; # noble bypasses commission
      $charref->{ 'rank'   }       = $charref->{ upp }->[5]; # SOC
      $charref->{ 'wound badges' } = 0;
      $charref->{ 'permanent injury' } = 0;
      $charref->{ 'skillAwards' }  = 0;
      $charref->{ 'intrigues' }    = 0;
      $charref->{ 'exiles' }       = 0;
      #$charref->{ 'medalCount' }   = 0; 
      #$charref->{ 'medals' }       = {} unless $charref->{ 'medals' };
      $charref->{ 'skills' }       = {} unless $charref->{ 'skills' };
      $charref->{ 'benefits' }     = {} unless $charref->{ 'benefits' };
      $charref->{ 'cash' }        |= 0;
      $charref->{ 'retirement' }  |= 0;
      $charref->{ 'proxies'    }  |= 0;
      $charref->{ 'major' }        = Skills::getRealRandomSkill();
      $charref->{ 'minor' }        = Skills::getRealRandomSkill();

      # 
      #  Figure out risk and reward order
      # 
      my $rro = Common::riskAndRewardOrder( $charref, [1,2,3,4] );
      $charref->{ 'risk and reward order' } = $rro;

      #print "Chosen RR Order: C", join( ' C', @$rro ), "\n";

      return "Joined the career nobility.\n";
   }
   
   return 0;
}

sub getRank
{
   my $self = shift;
   my $charref = shift;
   my @title = qw/Gentleman Knight Baron Marquis Count Duke Archduke Royalty/;

   # forced elevation?
   $charref->{ upp }->[ 5 ] = 10 if $charref->{ upp }->[ 5 ] < 10;
   $charref->{ upp }->[ 5 ] = 17 if $charref->{ upp }->[ 5 ] > 17;

   my $SOC = $charref->{ upp }->[ 5 ]; 
 
   return '(' . $title[ $SOC - 10 ] . ')';
}

sub toString
{
   my $self = shift;
   my $charref = shift;
   return Common::toString( $self, $charref );
}

sub term # common utility
{
   my $self = shift;
   my $charref = shift;
   Common::term( $charref );
}

sub riskAndReward
{
   my $self = shift;
   my $charref = shift;

   my ($riskCharacteristic, @risk_and_reward_order) = @{$charref->{ 'risk and reward order' }};
   push @risk_and_reward_order, $riskCharacteristic;
   $charref->{ 'risk and reward order' } = \@risk_and_reward_order;

   my $char = $charref->{ upp }->[ $riskCharacteristic ];
   
   #
   #  Risk and Reward are unique for Nobles.
   #
   my $out = '';

   # Return from Exile
   if ( $charref->{ 'ineligible for promotion this term' } ) 
   {
      $out .= "Attempt Return ";
      $out .= "using C" . ($riskCharacteristic+1) . " ($char)\n";

      # Roll for Return
      my $risk = $char - roll() + $charref->{ 'exiles' } - $charref->{ 'intrigues' };
      if ( $risk < 0 ) # failed return
      {
         $out .= "Still in Exile.\n";
      }
      else
      {
         $out .= "Returned from Exile.\n";
         delete $charref->{ 'ineligible for promotion this term' };
      }
   }

   # Intrigue
   unless ( $charref->{ 'ineligible for promotion this term' } ) 
   {
      $out .= "Attempt Intrigue " ;
      $out .= "using C" . ($riskCharacteristic+1) . " ($char)\n";

      # Roll for Intrigue
      my $risk = $char - roll() - $charref->{ 'exiles' } + $charref->{ 'intrigues' };
      if ( $risk < 0 ) # exiled
      {
         $out .= "Exiled.\n";
         $charref->{ 'exiles' }++;
         $charref->{ 'ineligible for promotion this term' } = 1;
      }
      else # intrigue successful
      {
         $out .= "Intrigue successful.\n";
         $charref->{ 'intrigues' }++;
         $charref->{ 'upp' }->[5]++;
         $out .= " - Elevated\n";
         $charref->{ 'skillAwards' } += 2;
         $charref->{ 'landGrants' }++;
         $out .= " - Land Grant\n";
         $charref->{ 'fame' } = int( 1.5 * $charref->{ 'upp' }->[5] );
      }
   }
   return $out;
}

sub promotion      { 0 }
sub commission     { 0 }
sub automaticSkill { 0 }


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

   return 7;
}

sub musterBenefitCount
{
   my $self = shift;
   my $charref  = shift;
   Common::musterBenefitCount($charref);
}

sub musterBenefit
{
   my $self    = shift;
   my $charref = shift;
   my $type    = shift || 'random';
   
   my $DM = $charref->{ 'terms' };
   my $choice = int(rand(6)) + $DM;

   if ($type eq 'random')
   {
      my $r = int(rand(3));
      $type = 'cash';
      $type = 'benefit' if $r == 1;
      $type = 'power'   if $r == 2;
   }

#   print "Benefit: $type\n";
 
   if ( $type eq 'cash' )
   {
      return $cashout[ $choice ] || $cashout[ -1 ];
   }
   elsif ($type eq 'benefit' )
   {
      my $benefit = $benefits[ $choice ] || $benefits[ -1 ];
      return $benefit unless $benefit =~ /Proxy/;

      addProxies( $self, $charref, $benefit ) if $benefit =~ /Proxy/;
      return;
   }

   # else

   my $power = $proxies[ $choice ] || $proxies[ -1 ];
   addProxies( $self, $charref, $power );

   return undef; # already handled Proxies
}

sub addProxies
{
   my $self = shift;
   my $charref = shift;
   my $power = shift;

   my $proxies = $charref->{ 'proxies' } || 0;

   $proxies += 1              if $power eq 'Proxy_1';
   $proxies += 2              if $power eq 'Proxy_2';
   $proxies += int(rand(6)+1) if $power eq 'Proxy_1D';
   $proxies += roll()         if $power eq 'Proxy_2D';
   $proxies += flux()         if $power eq 'Proxy_Flux';

   Benefits::addBenefit( $charref, 'Proxies', $proxies );
}

sub calculateRetirement { 0 } # none for Nobles

1; # return 1 as all good modules should

