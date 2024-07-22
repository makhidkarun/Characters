use strict;
use warnings;

# unlink 'log.t5chargen';

my %crew = ();

{
   my $summary = `perl t5chargen.pl career=Random quiet=1`;
#   print $summary;
 
   for my $skill ( 'Pilot', 'Astrogator', 'Engineer', 'Steward', 'Gunner', 'Computer', 'Sensors', 'Medic' )
   {
      if (hasSkill($summary, $skill) && !$crew{ $skill } && alive($summary))
      {
         $crew{ $skill } = $summary;
         print STDERR "\nFound $skill\n";
         last;
      }
   }
   redo unless $crew{ 'Pilot' } 
            && $crew{ 'Astrogator' } 
            && $crew{ 'Engineer' } 
            && $crew{ 'Steward' }
            && $crew{ 'Computer' }
            && $crew{ 'Medic' }
            && $crew{ 'Sensors' };
}

for my $skill ( 'Pilot', 'Astrogator', 'Engineer', 'Steward', 'Gunner' )
{
   print $crew{ $skill }, "\n" if $crew{ $skill };
}


sub hasSkill
{
   my $dude  = shift;
   my $skill = shift;
   return 0 if $dude =~ /(\d\d) yrs/ && $1 > 30 + int(rand(6)+rand(6)) * 3;
   return 1 if $dude =~ /$skill-[^01]/;
   return 0;
}

sub alive
{
   my $dude  = shift;
   return 0 if $dude =~ /DEAD/;
   return 1;
}
