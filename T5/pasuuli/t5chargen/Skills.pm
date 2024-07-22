package Skills;
use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Terse=1;
$Data::Dumper::Indent=1;

my @randomSkillList = qw/
ACV Comms High-G Steward Ordnance Naval_Arch
JOT Rider Sensors Fwd_Obs Survival Streetwise
LTA Spines Flapper Seafarer Astrogator
WMD Leader Tracked Engineer Computer Navigation
Chef Survey Animals Fluidics Bay_Weapons Explosives
Mole Dancer Tactics Launcher Magnetics Jump_Drive
Grav Artist Turrets Teamster Photonics Counsellor
Boat Legged Teacher Designer Vacc_Suit Sub
Starship_Skill Sapper Unarmed Engineer Artillery Aeronautics
Wing Driver Exotics Language Craftsman Aquanautics
Recon Gunner Stealth Musician Gravitics BattleDress
Actor Blades Trainer Strategy Forensics Electronics
Flyer Zero-G Animals Maneuver_Drive Biologics Hostile_Env
Pilot Author Liaison Polymers Ortillery Power_Systems
Rotor Broker Athlete Advocate Automotive Life_Support
Admin Trader Fighter Computer Bureaucrat Slug_Throwers
Beams Sprays Wheeled Diplomat Heavy_Wpns Fleet_Tactics
Medic Gambler Screens Mechanic Programmer Spacecraft_ACS No_Skill
/;

sub getAnySkill
{
   $randomSkillList[ rand(@randomSkillList) ];
}

my @randomKnowledgeList = qw/Rider Teamster Trainer ACV Automotive Grav_Driver
Legged Mole Tracked Wheeled Jump_Drive Life_Support Maneuver_Drive Power_Systems
BattleDress Beams Blades Exotics Slug_Throwers Sprays Unarmed
Aeronautics Flapper Grav_Flyer LTA Rotor Winged Bay_Weapons Ortillery Screens Spines Turrets
Artillery Launcher Ordnance WMD Small_Craft Spacecraft_ACS Spacecraft_BCS
Aquanautics Grav_Boat Boat Ship Sub Archaeology Biology Chemistry History
Linguistics Philosophy Physics Planetology Psionicology Psychohistory Robotics
Sophontology
/;

sub getAnyKnowledge()
{
   $randomKnowledgeList[ rand(@randomKnowledgeList) ];
}

sub getRealRandomSkill
{
   $randomSkillList[ rand(scalar @randomSkillList - 1) ];
}

#########################################################
#
#  Skill-knowledge subordinate relationships.
#
#########################################################
my %skillGroups =
(
   'Animals' => [ 'Rider', 'Teamster', 'Trainer' ],
   'Driver'  => [ 'ACV', 'Auto', 'Grav_Driver', 'Legged', 'Mole', 'Tracked', 'Wheeled' ],
   'Engineer' =>
   [
      'Jump_Drive',
      'Life_Support',
      'Maneuver_Drive',
      'Power_Systems'
   ],
   'Fighter' =>
   [
      'BattleDress', 'Beams', 'Blades', 'Exotics', 
      'Slug_Throwers', 'Sprays', 'Unarmed'
   ],
   'Flyer' =>
   [
      'Aeronautics',
      'Flapper',
      'Grav_Flyer',
      'LTA',
      'Rotor',
      'Winged'
   ],
   'Gunner' =>
   [
      'Bay_Weapons',
      'Ortillery',
      'Screens',
      'Spines',
      'Turrets'
   ],
   'Heavy Weapons' => [ 'Artillery', 'Launcher', 'Ordnance', 'WMD' ],
   'Pilot' => [ 'Small_Craft', 'Spacecraft_ACS', 'Spacecraft_BCS' ],
   'Seafarer' =>
   [
      'Aquanautics',
      'Grav_Boat',
      'Boat',
      'Ship',
      'Sub'
   ],
   'Starship_Skill' => ['Pilot', 'Engineer', 'Astrogator', 'Medic', 'Gunner', 'Sensors', 'Steward' ], # 'Comms' ],
);

#########################################################
#
#  Inverse map of the above, for reverse lookup.
#
#########################################################
my %isKnowledgeOf = ();

foreach my $skill (keys %skillGroups)
{
   #
   #   KLUDGE to differentiate a skill cascade from a knowledge group!
   #
   next if $skill eq 'Starship_Skill'; # this does NOT represent a knowledge group!
   
   my @knowledges = @{$skillGroups{$skill}};
   foreach my $knowledge (@knowledges)
   {
      $isKnowledgeOf{ $knowledge } = $skill;
   }
}

#########################################################
#
#  These are not cascaded into a skill, but may 
#  themselves be skill groups.
#
#########################################################
my %knowledgeGroup =
(
   'Trade' =>
   [
      'Biologics', 'Craftsman', 'Electronics', 'Fluidics',
      'Gravitics', 'Magnetics', 'Mechanic', 'Photonics', 'Polymers', 'Programmer'
   ],
   'Art' =>
   [
      'Actor', 'Artist', 'Author', 'Chef', 'Dancer', 'Musician' 
   ],
   'Science' =>
   [
      'Archaeology', 'Biology', 'Chemistry', 'History', 'Linguistics',
      'Philosophy', 'Physics', 'Planetology', 'Psionicology', 'Psychohistory',
      'Psychology', 'Robotics', 'Sophontology'
   ],
   'Starship_Skill' =>
   [
      'Astrogator', 'Engineer', 'Gunner', 'Medic', 'Pilot', 'Sensors', 'Steward',  # 'Comms'
   ],
   'Soldier_Skill' =>
   [
      'Fighter', 'Fwd_Obs', 'Heavy_Wpns', 'Navigation', 'Recon', 'Sapper'
   ],
);

my @languages = qw/Darrian Vilani Zhodani Trokh Aekhu Gvegh Logaksu Urzaeng Ovaghoun Suedzuk Oynprith Bwap Vilani Darrian K'Kree Hiver Nenlat Sigka Sylean Vegan Ael_Yael Amindii Akwilan/;


sub randomLanguage { 'Language (_____________)' }
#
#  DONE: removed assignment of REAL language, replaced by placeholder.
#
# sub randomLanguage { 'Language (' . $languages[ rand(@languages) ] . ')' }

sub selectSkillIn
{
   my $skill = shift;
   my $text  = '';
 
   return $skill unless $skillGroups{ $skill };

   my @list = @{$skillGroups{$skill}};
   my $selection = $list[ rand(@list) ];
 
   return selectSkillIn( $selection );
}

sub addSkillLevel
{
   my $skills      = shift;
   my $name        = shift;

   my $text = '';

   return $text if $name =~ /No_Skill/i;
   
   if ( $knowledgeGroup{ $name } )
   {
      #
      #  This is either a skill or knowledge group,
      #  so select one in the group and add it as if it were a skill.
      #
      my @list = @{$knowledgeGroup{ $name }};
      my $kname = $list[ rand(@list) ];
      return addSkillLevel( $skills, $kname );
   }
   elsif ( $isKnowledgeOf{ $name } )
   {
      #
      #  This is a knowledge, so find its parent skill
      #  and record it straight.
      #
      my $parentSkill = $isKnowledgeOf{ $name };
      $skills->{ $parentSkill }->{ 'level' } = 0
         unless $skills->{ $parentSkill }->{ 'level' };
	  
      if ( ! $skills->{ $parentSkill }->{ 'knowledges' }->{ $name }
          || $skills->{ $parentSkill }->{ 'knowledges' }->{ $name } < 6 )
      {
         $text = "Incrementing $name without incrementing knowledge count for $parentSkill.\n";
         $skills->{ $parentSkill }->{ 'knowledges' }->{ $name }++;
      }
      else
      {
         $text = "Knowledge [$name] already maxed out at 6.\n";
      }
      # these don't increment 'knowledge count'
   }
   else
   {
      #
      #  This is a skill, so figure out if we have to 
      #  select a knowledge instead.
      #
      my $k_count   = $skills->{ $name }->{ 'knowledge count' } || 0;
      my $selection = selectSkillIn( $name );

      if ( $k_count >= 2 || $selection eq $name ) 
      {
         $skills->{ $name }->{ 'level' }++;
      }
      else # name <> selection, this is a knowledge
      {
         $skills->{ $name }->{ 'level' } = 0 
            unless $skills->{ $name }->{ 'level' };

	     if ( ! $skills->{ $name }->{ 'knowledges' }->{ $selection }
	         || $skills->{ $name }->{ 'knowledges' }->{ $selection } < 6 )
	     {
           $skills->{ $name }->{ 'knowledges' }->{ $selection }++;
           $skills->{ $name }->{ 'knowledge count' }++;
         }
		 else
		 {
	        $text = "Knowledge [$selection] already maxed out at 6.\n";		
		 }
      }
   }

   return $text; # $skills;
}

sub formatSkills
{
   my $skills = shift;
   my $delim  = shift || ', ';
   my @out = ();

   foreach my $name (sort keys %$skills)
   {
      my $knowledges = undef;
      my $level = $skills->{ $name }->{ 'level' } || 0;
      my $str = "$name-$level";

      my $kref = $skills->{ $name }->{ 'knowledges' } || {};
      my @klist = ();
      foreach my $kname (sort keys %$kref)
      {
         my $klevel = $kref->{ $kname };
         push @klist, "$kname-$klevel";
      }
      $knowledges = join ', ', @klist if @klist;
      $str = "$str ($knowledges)" if $knowledges;

      $str =~ s/_/ /g; # pretty up the output

      push @out, $str;
   }
   return join $delim, @out;
}

sub selectSkills
{
   my $process  = shift;
   my $charref  = shift;
   my $skills   = $charref->{ 'skillAwards' };
   $charref->{ 'skillAwards' } = 0; # reset

   my @receipts = ();

   #
   #  Per term, bunch all skill selections within one column.
   #  Let's see if that makes lower-level characters more useful.
   #
   my $section = int(rand(7)); # 0 to 6

   #
   #  First time thru, don't select personal development.
   #
   $section = int(rand(6)+1) if $charref->{ 'terms' } == 1; 

   for ( 1..$skills )
   {
      #my $skill = $process->getAnySkill(); # old way

      my @list = $process->getSkillList();                    # new way
      my $index = int(rand(6)) + $section * 6;                # voila'
      print STDERR "Index $index out of range\n" if $index > @list; 
      my $skill = $list[ $index ];                            # 

      #
      #  Turning these off for now.
      #
#      $skill = $charref->{ 'major' } if $skill eq 'Major';
#      $skill = $charref->{ 'minor' } if $skill eq 'Minor';

      push @receipts, $skill;
   }

   return @receipts;
}

sub addSkill 
{
   my $charref = shift;
   my $skill   = shift;

   my $text = '';

   if ( $skill =~ /^C(\d)\s*\+\s*1$/ ) # characteristic improvement
   {
      my $characteristicIndex = $1 - 1;
      if ( $charref->{ upp }->[ $characteristicIndex ] < 15 )
      {
         $charref->{ upp }->[ $characteristicIndex ]++;
         $text .= " - [C$1 +1]\n";
      }
      else
      {
         $text .= " - [C$1 +1] - characteristic maxed out, no benefit.\n";
      }
   }
   elsif ( $skill eq 'Language' ) # language knowledge
   {
      my $lang  = randomLanguage(); 
      my $level;

      if ( $charref->{ 'skills' }->{ $lang } )
      {
         $charref->{ 'skills' }->{ $lang }->{ 'level' }++
            if $charref->{ 'skills' }->{ $lang }->{ 'level' } < $charref->{ 'max lang level' };
      }
      else
      {
         unless ( defined $charref->{ 'lang level' } )
         {
            my $max = $charref->{ upp }->[ 4 ]; # EDU
               $max = $charref->{ upp }->[ 3 ] if $charref->{ upp }->[ 3 ] > $max;

            $charref->{ 'lang level' } = $max;
            $charref->{ 'max lang level' } = $max - 1;
         }

         return $text unless $charref->{ 'lang level' } > 1;
         $charref->{ 'lang level' }--;
         $charref->{ 'skills' }->{ $lang }->{ 'level' } = $charref->{ 'lang level' };
      }
   }
   elsif ( $skill =~ /No_Skill/i )
   {
      # no skill awarded
   }
   else # skill or knowledge
   {
      $skill = getAnySkill()     if $skill =~ /Any_Skill/i;  # random skill awarded
      $skill = getAnyKnowledge() if $skill =~ /Any_Knowledge/i;
      addSkillLevel( $charref->{ 'skills' }, $skill );
      $text .= " - $skill\n";
   }
}

sub skillLevelAnalysis
{
   my $charref = shift;
   my $skills  = $charref->{ 'skills' };
   my %skills  = %$skills;

   my $total = 0;
   my @inv   = ();
   for my $sk (keys %skills)
   {
      $total += $skills->{ $sk }->{ 'level' } || 1;
      push @inv, $skills->{ $sk }->{ 'level' } || 1;
   }

   my $mean = 0;
   my $median = 0;
   if ( @inv )
   {
      @inv = sort { $a <=> $b } @inv;
      $mean = (0.5 + $total) / (scalar @inv );
      $median = scalar @inv / 2;
      $median = $inv[$median];
   }

   return sprintf "[Skill level mean: %.02f, median: %.02f]\n", $mean, $median;
}

sub flatten
{
   my $skillref = shift;
   my %skills = %$skillref;
   my @out    = ();
   
   foreach my $skey (keys %skills)
   {
      push @out, { name => $skey, level => $skills{$skey}->{ 'level' } } if $skills{ $skey }->{ 'level' };
      if ( $skills{ $skey }->{ 'knowledges' } )
      {
         foreach my $kkey (keys %{$skills{ $skey }->{ 'knowledges' }} )
         {
            push @out, { name => $kkey, level => $skills{ $skey }->{ 'knowledges' }->{ $kkey } };
         }
      }
   }
   return @out;
}

1; # return 1 as all good modules should
