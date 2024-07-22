package T5Chargen;
use strict;
use warnings;
use Jenkins2rSmallPRNG;

use Skills;
use Benefits;
use Common;

use Craftsman;    # 01
use Scholar;      # 02
use Entertainer;  # 03
use Citizen;      # 04
use Scout;        # 05
use Merchant;     # 06
use Spacer;       # 07
use Soldier;      # 08
use Agent;        # 09
use Rogue;        # 10
use Noble;        # 11
use Marine;       # 12
use Functionary;  # 13

my @careers = qw/Scholar Entertainer Citizen Scout Merchant Spacer Soldier Agent Rogue Noble Marine/;

sub createProcess
{
   my $career = shift || 'soldier';
   $career = $careers[ rand( @careers ) ] if $career =~ /random/;
   
   return Craftsman->new()   if $career =~ /^craft/i;
   return Scholar->new()     if $career =~ /^schol/i;
   return Entertainer->new() if $career =~ /^ent/i;
   return Citizen->new()     if $career =~ /^citi/i;
   return Scout->new()       if $career =~ /^scou/i;
   return Merchant->new()    if $career =~ /^mer/i;
   return Spacer->new()      if $career =~ /^(spa|navy)/i;
   return Soldier->new()     if $career =~ /^(sol|army)/i;
   return Agent->new()       if $career =~ /^agen/i;
   return Rogue->new()       if $career =~ /^rog/i;
   return Noble->new()       if $career =~ /^nob/i;
   return Marine->new()      if $career =~ /^mar/i;
   return Functionary->new() if $career =~ /^fun/i;
}

sub generate
{
   my $charref = shift;
   my $process = shift;
   my $drafted = shift;
   my $fiat_terms = shift || 0;
   
   my $text = "";
   
   exit unless $process->begin( $charref, $drafted );
   my $autoskill = $process->automaticSkill( $charref );
   if ( $autoskill =~ /^[a-z]/i )
   {
      $text .= "Automatic skill: $autoskill\n";
      Skills::addSkill( $charref, $autoskill );
   }

   # loop
   {
      $text .= $process->toString( $charref ) . "\n";
      $text .= Skills::formatSkills( $charref->{ 'skills' } ) . "\n";
      $text .= "\n";
      $text .= $process->term( $charref );
      $text .= $process->riskAndReward( $charref );
   
      # could be posthumous
      unless ( $charref->{ 'ineligible for promotion this term' } )
      {
         my @autoskill = ();

         #
         # Officer promotion first
         #
         if ( $charref->{ 'commissioned' } )
         {
            my $promo = $process->promotion( $charref );
            push(@autoskill, $promo);
            $text .= "Promotion.\n" if $promo;
         }
         else # check for commission
         {
            my $comm = $process->commission( $charref );
            push(@autoskill, $comm);
            $text .= "Commissioned as Officer.\n" if $comm;
            $text .= "No Commission.\n" unless $comm;

            #
            # and finally, if still Rating, check Rating promotion
            #
            unless( $charref->{ 'commissioned' } )
            {
               my $promo = $process->promotion( $charref );
               push(@autoskill, $promo);
               $text .= "Promotion.\n";
            }
         }

         foreach my $res (@autoskill )
         { 
            next unless $res && $res =~ /^[a-z]/i;
            $text .= "Automatic skill: $res\n";
            Skills::addSkill( $charref, $res );
         }
      }

      last if Common::isDead( $charref );

      # never posthumous
      my @skill_receipts = Skills::selectSkills( $process, $charref );
      $text .= (scalar @skill_receipts) . " skills:\n";
      $text .= Skills::addSkill( $charref, $_ ) foreach @skill_receipts;

      $text .= Common::aging( $charref );

      last if $charref->{ upp }->[ 0 ] < 2 
           || $charref->{ upp }->[ 1 ] < 2 
           || $charref->{ upp }->[ 2 ] < 2 
           || $charref->{ upp }->[ 3 ] < 2 
           ;

      if ( $fiat_terms > 0 ) # fiat number of terms
      {
         $fiat_terms--;
         last if $fiat_terms == 0;
         redo;
      }
      else # normal continuation procedure
      {
         last if $charref->{ 'terms' } > 15;
		 my ($continue, $ctext) = continueToNextTerm( $process, $charref );
		 $text .= $ctext;
		 redo if $continue;
      }
   }

   $text .= Benefits::musterOut( $process, $charref ) 
      unless Common::isDead( $charref );

   $process->calculateRetirement( $charref );
   
   return $text;
}

sub continueToNextTerm
{
   my $process  = shift;
   my $charref  = shift;
   my $text = '';
   
   if ( Common::isDead( $charref ) )
   {
      $text = "The character has died.\n";
      return (0, $text);
   }
   elsif ( Common::isDisabled( $charref ) ) # ->{ 'permanent injury' } > 2 )
   {
      $text = "Disability discharge.\n";
      return (0, $text);
   }
   
   my $target   = $process->continueTarget( $charref );
   my @order    = @{$charref->{ 'risk and reward order' }};
   my $nextRisk = $charref->{ 'risk and reward order' }->[0];
   my $nextVal  = $charref->{ 'upp' }->[ $nextRisk ];

   my $think   = Common::roll() <= $nextVal * 1.5;
   my $worry   = Common::physicalStatsBelow( $charref, 5 ) && rand() > 0.5;
   if ( $think == 0 || $worry > 0 )
   {
      $text = "Character elects to stop\n";
      return (0, $text);
   }

   $text = "Continuation target: 2D <= $target\n";
   my $roll = Common::roll() <= $target;

   if ( $roll == 0 )
   {
      $text .= " - service terminated\n";
      return (0, $text);
   }
  
   $text .= "Continuing.\n\n";
   return (1, $text);
}


1; # return 1 as all good modules should

