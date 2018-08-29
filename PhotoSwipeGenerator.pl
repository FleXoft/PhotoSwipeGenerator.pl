#!/usr/bin/perl

# PhotoSwipeGenerator.pl
#
# Designed by _flex
# Written  by _flex from FleXoft.
#   (gyorgy@fleischmann.hu)
#
# v1.00, 2018.09.01. Budapest, FleXoft
#   Rls:  first release
#
# Requirements:
# -------------
#
#      ImageMagick: brew install ImageMagick
#
# Documentation:
# --------------
#
#      Tested on:
#         Darwin flexs-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64
#         This is perl 5, version 18, subversion 2 (v5.18.2) built for darwin-thread-multi-2level
#         Version: ImageMagick 7.0.8-10 Q16 x86_64 2018-08-15 https://www.imagemagick.org
#
# TODO:
# -----
#

use strict;
use warnings;

use Pod::Usage;

use Getopt::Long;
my $directory    = 'photos/andras';       # directory [OK]
my $rows         = 4;                     # row# [OK]       
my $verbose;                              # [OK]
my $filelist;                             # jpgfilelist (jpg|title|author) [OK]
my $reverse;                              # [OK]
my $exclude;                              # exclude
my $outdir       = "_includes";           # output directory [OK]
my $filetag      = "";                    # [OK]
my $imgproperty  = "";                    # extra link property [OK] 
my $globaltitle  = "Fleischmann András";  # [OK]
my $globalauthor = "Fleischmann György";  # [OK]
my $filepattern  = "jpg";                 # [OK]
my $startnumber  = 0;                     # starting# [OK]

my $debug;
my $version;
my $help;                                 
my $man;

GetOptions ( "rows=i"         => \$rows,
             "directory=s"    => \$directory,
             "verbose"        => \$verbose,
             "filelist=s"     => \$filelist,
             "reverse"        => \$reverse,
             "exclude=s"      => \$exclude,
             "outdir=s"       => \$outdir,
             "filetag=s"      => \$filetag,
             "imgproperty=s"  => \$imgproperty,
             "title=s"        => \$globaltitle,
             "author=s"       => \$globalauthor,
             "filepattern"    => \$filepattern,
             "startnumber"    => \$startnumber,

             "debug"          => \$debug,
             "version"        => \$version,
             "help"           => \$help,
             "man"            => \$man 
            ) or die( "Error in command line arguments\n" );

=head1 NAME

PhotoSwipeGenerator.pl

=head1 SYNOPSIS
  
  PhotoSwipeGenerator.pl [options] 

  Options:
    - directory
    - rows
    - verbose
    - filelist
    - reverse
    - exclude
    - outdir
    - filetag
    - imgproperty 
    - title
    - author
    - filepattern
    - startnumber
    - debug
    - version
    - help
    - man 

=head1 OPTIONS

=over 4

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Detailed manual page.

=item B<-debug>

Debug option to get debug messages.

=item B<-verbose>

Enable verbose outputs.

=item B<-directory>

Specify the source directory to scan *.jpg files.

=item B<-rows>

Specify the # of rows you want to create. Default: 4

=item B<-filelist>

Specify a file wich contains the files with full path to process.

=item B<-reverse>

Reverse order, what else?

=item B<-exclude>

Exclude this file matching this pattern.

=item B<-outdir>

Specify the output directory.

=item B<-filetag>

Specify an extra tag for the links and file names.

=item B<-imgproperty>

Specify an extra HTML img property for the links.

=item B<-title>

Specify a global title property of the images.

=item B<-author>

Specify a global author property of the images.

=item B<-filepattern>

Specify a pattern for filematching. Default: jpg

=item B<-startnumber>

Specify number to start the numbering. Default: 0

In this case the array will be expanded not created.

=item B<-version>

Shows the version of itself.

=back

=cut

=head1 DESCRIPTION

B<This program> will generate array.html, rowx.html file to help implement Responsive JavaScript Image Gallery package.

http://photoswipe.com/

=cut

=head1 EXAMPLES

Examples of this script:

PhotoSwipeGenerator.pl --directory photos/2017-11-05-Ulloi --filetag _ulloi --outdir _includes

PhotoSwipeGenerator.pl --directory photos/jatszoter2018 --filetag _jatszoter2018 --outdir _includes -v -imgproperty 'class="shadow"'

PhotoSwipeGenerator.pl --directory photos/2017-11-05-Ulloi --filetag _ulloi --outdir _includes --imgproperty 'class="shadow zoomeffect"' --title "Üllői út v1.0β" -v

=cut

print "┏━┓╻ ╻┏━┓╺┳╸┏━┓┏━┓╻ ╻╻┏━┓┏━╸┏━╸┏━╸┏┓╻┏━╸┏━┓┏━┓╺┳╸┏━┓┏━┓ ┏━┓╻\n";
print "┣━┛┣━┫┃ ┃ ┃ ┃ ┃┗━┓┃╻┃┃┣━┛┣╸ ┃╺┓┣╸ ┃┗┫┣╸ ┣┳┛┣━┫ ┃ ┃ ┃┣┳┛ ┣━┛┃\n";
print "╹  ╹ ╹┗━┛ ╹ ┗━┛┗━┛┗┻┛╹╹  ┗━╸┗━┛┗━╸╹ ╹┗━╸╹┗╸╹ ╹ ╹ ┗━┛╹┗╸.╹  ┗━╸\n";

print "Verbose output option is enabled!\n" if $verbose;

# version option
if ( $version ) {
  open my $MYSELF, "<$0" or die;
  while ( <$MYSELF> ) {
    if ( /^# v(\d+\.\d{2}),/ ) {
      print "Version: $1\n";
      last;
    }
  }
  close $MYSELF or die;
  exit 0;
}

pod2usage( q( -verbose ) => 1 ) if $help;
pod2usage( -exitval => 0, -verbose => 2 ) if $man;

# isFileReadable ( filename )
sub isFileReadable ( $ ) {
  if ( ! -r "$_[0]" ) {
    print "!!! \"$_[0]\" not readable!\n";
    return 1;
  }
  return 0;
}

# readFile2Variable ( filename )
sub readFile2Variable ( $ ) {
  open( FILEHNDLR, "$_[0]" );
  my $return = join( '' , <FILEHNDLR> );
  close FILEHNDLR;
  return $return;
}

# Init "multidimensional" array 
my @rowfiles;
for ( my $i = 0; $i < $rows; $i++ ) {
  $rowfiles[$i] = [];
}

#open ( PICS,   "<pics.txt" ) or die "$!";
#open ( ROW01,  "> $outdir/row1$filetag.html" ) or die "$!";
#open ( ROW02,  "> $outdir/row2$filetag.html" ) or die "$!";
#open ( ROW03,  "> $outdir/row3$filetag.html" ) or die "$!";
#open ( ROW04,  "> $outdir/row4$filetag.html" ) or die "$!";

print "Generating...";

# collect a list of the pics
my @picslist;
if ( length ( $filelist ) ) {
  open FILE, "+<:encoding(utf-8)", "$filelist" or die "File ($filelist) open error: $!";

  while ( <FILE> ) {
    chomp;
    next if ( /^(\s)*$/ or /^#.*/ );
    push ( @picslist, $_ );
  }
  
  close( FILE );
}
else {
  @picslist = `ls -1dt "$directory"/*_ORIGINAL.$filepattern`;
}

# exclude this pattern
@picslist = grep !/$exclude/, @picslist if $exclude;

# reverse the list if needed
@picslist = reverse ( @picslist ) if ( $reverse ); 

# open a file for JavaScript array 
open ( ARRAY, "> $outdir/array$filetag.html" ) or die "$!";

if ( $startnumber == 0 ) {
  print ARRAY "var items = [\n";
}
else {
  print ARRAY "items = [\n"; 
}

# main loop 
my $counter = $startnumber;

foreach ( @picslist ) {
	chomp;

  my ( $originalFilename, $title, $author ) = split ( /\|/, $_ );
  $title = defined ( $title ) ? $title : "";
  $author = defined ( $author ) ? $author : "";

  my $filename = $originalFilename;
  $filename =~ s/_ORIGINAL\.$filepattern/\.$filepattern/;
  next if isFileReadable ( "$filename" );

  # create a link
	my $picHTML = "<a href=\"javascript:openPhotoSwipe(); gallery.goTo( $counter );\"><img title=\"$globaltitle\" $imgproperty src=\"".$filename."\"></a>\n";

  #
  my $modulo = $counter % $rows;
	
	#
  push ( $rowfiles[$modulo], $picHTML );

  # and a JavaScript array for PhotoSwipe
  if ( $counter != 0 ) { print ARRAY ",\n"; }

  my ( $w, $h ) = split ( /x/, `magick identify -format "%wx%h" "$originalFilename"` ); # get pic width x height

  # override title and author if exist 
  $filename =~ s/\.$filepattern//;
  $title  = readFile2Variable ( "$filename.title" )  if ( -r "$filename.title" );
  $author = readFile2Variable ( "$filename.author" ) if ( -r "$filename.author" );

  print ARRAY "{\n";
  print ARRAY "src   : '$originalFilename',\n";
  print ARRAY "w     : $w,\n";
  print ARRAY "h     : $h,\n";
  print ARRAY "title : '" . ( length( $title ) ? $title : $globaltitle ) . "',\n";
  print ARRAY "author: '" . ( length( $author ) ? $author : $globalauthor ) . "'\n"; 
  print ARRAY "}";

	$counter++;

  print "\rGenerating... [$counter]" if ( $verbose );
}
print "\n" if $verbose;

print ARRAY "];\n";

# save the last $counter
my $exitcode = $counter;

# row1, row2, row3, ...
$counter = 1;
foreach ( @rowfiles ) {
  open ( ROWFILE,  "> $outdir/row$counter$filetag.html" ) or die "$!";
    foreach ( @$_ ) {
        print ROWFILE $_;
    }
    close ROWFILE;
  $counter++;
}

close ARRAY;

# exit with the last number
exit $exitcode;