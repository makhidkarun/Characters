#!/usr/local/bin/perl
use lib '.';
use strict;
use warnings;
use Jenkins2rSmallPRNG;
use YAML;

use T5Chargen;
use Skills;
use Benefits;
use Common;

use CGI;

my $cgi = new CGI;

my $career = $cgi->param( 'career' ) || "Soldier"; 
my $dna    = $cgi->param( 'dna' )    || '';
my $upp    = $cgi->param( 'upp' )    || '';
my $fiat_terms  = $cgi->param( 'terms' )  || 0;  # 0 = whatever
my $count  = $cgi->param( 'count' )  || 1;
my $name   = $cgi->param( 'name' )   || "No name"; 
my $quiet  = $cgi->param( 'quiet' )  || 0;

if ( $count == 1 && $quiet == 0 )
{
   print<<BEGINFORM;
content-type: text/html

<form method=post action='../../cgi-bin/processForm.cgi'>
<textarea name='output' cols='80' rows='25'>
BEGINFORM
}

$career = "\u\L$career"; # capitalize

if ( $career eq 'Random' )
{
   $career = 1 + int(rand(13));
   $career = "Craftsman"   if $career eq '1';
   $career = "Scholar"     if $career eq '2';
   $career = "Entertainer" if $career eq '3';
   $career = "Citizen"     if $career eq '4';
   $career = "Scout"       if $career eq '5';
   $career = "Merchant"    if $career eq '6';
   $career = "Spacer"      if $career eq '7';
   $career = "Soldier"     if $career eq '8';
   $career = "Agent"       if $career eq '9';
   $career = "Rogue"       if $career eq '10';
   $career = "Noble"       if $career eq '11';
   $career = "Marine"      if $career eq '12';
   $career = "Functionary" if $career eq '13';
}

my $generated    = 0;
my @quietBuffer  = ();
my @termCount    = (('-') x 20);
my $MAX_PER_TERM = int($count / 5);
my @characters = ();
my @vat = ();

for my $num (1..$count)
{
   $generated++;
   my $drafted = 1;
   my $gentext = '';
   my $charref;
   my $process = T5Chargen::createProcess( $career );
 
   ###########################################################
   # 
   #  Prep the character for its career
   #
   ###########################################################
   {
      my @upp = Common::getUPP( $upp, $dna );
      $charref = 
      {
         'name'   => $name,
         'upp'    => \@upp,
         'skills' => {},
      };
      my $prepText = '';

      ##############################################################
      #
      # generate a pre-career first
      #
      ##############################################################
      if ( $career =~ /func|craft/i )
      {
         $prepText .= "Generating initial career.\n";
         my $preprocess = T5Chargen::createProcess( 'random' );
         my $pre_fiat_terms = 4 + int(rand(4));
		 $pre_fiat_terms = $fiat_terms - 1 if $fiat_terms && $pre_fiat_terms > $fiat_terms;
		 $fiat_terms -= $pre_fiat_terms;

         $prepText .= T5Chargen::generate( $charref, $preprocess, $drafted, $pre_fiat_terms );
#         Common::resurrect( $charref ) if Common::isDead( $charref ); # !

         redo if Common::isDead( $charref );
		 
	 if ( $career =~ /craft/i )
	 {
            my @skills = Craftsman::craftsmanFlatten( $charref->{ 'skills' } );
            redo unless scalar @skills >= 2;
	 }
#         print STDERR "OK /", scalar @characters, "\n";
      }
   }
   
   Skills::addSkill( $charref, 'Craftsman' ) if $career =~ /craft/i && ! $charref->{ 'skill' }->{ 'Craftsman' };   
   $gentext .= T5Chargen::generate( $charref, $process, $drafted, $fiat_terms );

   if ( $count > 10 )
   {
      # Oh, you're doing a list.  Well in that case, let's impose some sanity.
      push @vat, $charref if Common::isDead( $charref );
      redo if Common::isDead( $charref );

      $termCount[ $charref->{ 'terms' } ]++;
      redo if $termCount[ $charref->{ 'terms' } ] >= $MAX_PER_TERM
           && $career !~ /func|craft/i; # is it right to include Craftsman here?
   }

   push @characters, $charref;
   print STDERR scalar @characters, ' ';

#   next unless $quiet == 0;
   
   my $header      = $process->toString( $charref ); 
   my $skillList   = Skills::formatSkills( $charref->{ 'skills' } );
   my $benefitList = Benefits::formatBenefits( $charref->{ 'benefits' } );
   
   if ( $count == 1 && $quiet == 0 )
   {
      my $summary  = $header;
         $summary .= "\t$skillList\n";
         $summary .= "\t$benefitList\n" if $benefitList;

      print $gentext;
      print "\n", Skills::skillLevelAnalysis( $charref );
      print form( $summary );
   }
   else
   {
      my $nl = 'text:p';
      my $q  = 'text:p text:style-name="Quotations"';
      my $p  = 'text:p text:style-name="Text_20_body"';
      my $span = 'text:span text:style-name="T7"';
      my $spanend = 'text:span';

      $header =~ s/\n//; # remove newline

      # Forbidden(1), Knighthood(land grants: 6)
      my $summary = "<$p>XXX. $header</$nl>\n";

      if ( length( $benefitList ) > 0 && length( $header ) + length( $benefitList ) < 90 )
      {
         #
         #  This makes the entry shorter by 2 lines
         #
         $summary = "<$p>XXX. $header, $benefitList</$nl>\n";
         $summary .= "<$q>$skillList</$nl>\n";
      }
      else
      {
         $summary .= "<$q>$skillList</$nl>\n";
         $summary .= "<$q>$benefitList</$nl>\n" if $benefitList;

#         $summary .= "<br />\n";
#         $summary .= "<br />$skillList<br />\n"; 
#         $summary .= "<br />$benefitList<br />\n" if $benefitList;
#         $summary .= "<br />\n";

#         $summary .= "<blockquote>$skillList</blockquote>\n";
#         $summary .= "<blockquote>$benefitList</blockquote>\n" if $benefitList;

      }

      push @quietBuffer, $summary;
   }
}

#print STDERR "Count: $count, Quiet: $quiet, Buffer: ", scalar @quietBuffer, "\n";

if ( $quiet > 0 )
{
   shift @termCount;
   my @out = sort byTermText @quietBuffer;

   my $num = 1;
   foreach (@out)
   {
      s/XXX/$num/;
      print;
      $num++;
   }
   
   @characters = sort byTerms @characters;
   $num = 1;
   foreach my $charref (@characters)
   {
      $charref->{ 'index' } = $charref->{ 'career' } . ' ' . $num;
	  $num++;
   }

   YAML::DumpFile( "$career.$count.yml", @characters );
   YAML::DumpFile( "$career.dead.yml",   @vat );

   open OUT, ">>", "log.t5chargen";
   print OUT sprintf "%-25s, %4s, %4s actual, %4s died, dist @termCount\n",
                     $career,
                     $count, 
                     $generated, 
                     scalar @vat;
   close OUT;
}


sub form
{
   my $text = shift;

   return<<EOFORM;

Traveller5 Character Summary:
========================================================
$text
========================================================
</textarea>
<br />
</pre>
<br />
Address: <input name="address" length="20" />
<input type="hidden" name="builder" value="character.character" />
<input type="submit" value="Email it" />
</form>
EOFORM
}


sub byTermText
{
   my ($t1) = $a =~ /(\d+) term(s)? /;
   my ($t2) = $b =~ /(\d+) term(s)? /;

   return $t1 <=> $t2;
}

sub byTerms
{
   $a->{ 'terms' } <=> $b->{ 'terms' }
}
