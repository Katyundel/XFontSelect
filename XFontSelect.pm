package XFontSelect;
my $RCSRevKey = '$Revision: 0.42 $';
$RCSRevKey =~ /Revision: (.*?) /;
$VERSION=$1;
use vars qw( $VERSION );

=head1 NAME

  Tk::XFontSelect.pm--X11 Font Selection Dialog. 

=head1 SYNOPSIS

  use Tk;
  use Tk::XFontSelect;

  my $fontdialog = $mw -> FontSelect;
  my $font = $fontdialog -> Show;

=head1 DESCRIPTION

The Tk::XFontSelect widget displays a dialog box that lists the
descriptors of all of the fonts that are present on the system.
Selecting a font descriptor and pressing the "Accept" button returns
to the main application a string containing that font descriptor.

The list of font descriptors is generated by the xlsfonts command,
a standard utility of the XFree86 Rev. 3.3.2 distribution.

=head1 SEE ALSO

xlsfonts(1) man page.

=head1 VERSION INFO

First Release Version

$Revision: 0.42 $

=cut 

use Tk qw(Ev);
use Carp;
use Tk::widgets qw( LabEntry Button Frame Listbox Scrollbar );
use base qw(Tk::Toplevel);

Construct Tk::Widget 'XFontSelect';

my $defaultfont="*-helvetica-medium-r-*-*-12-*";


sub Cancel {
  shift -> withdraw;
  return undef;
}

sub Accept {
  my ($w) = shift;
  $w->configure( -font => $w -> Subwidget('fontlist')-> 
		   get($w -> Subwidget('fontlist') -> curselection ) );
  $w->withdraw;
}

sub Populate {
  my($w, $args) = @_;
  require Tk::Listbox;
  require Tk::Button;
  require Tk::Dialog;
  require Tk::DialogBox;
  require Tk::Toplevel;
#  require Tk::LabEntry;

  $w -> SUPER::Populate( $args );

  my $l = $w -> Component( 'ScrlListbox' => 'fontlist',
			   -height => 15,
			   -width => 50,
			   -scrollbars => 'se',
			   -font => $defaultfont ) -> pack;
  $l -> Subwidget('yscrollbar') -> configure(-width=>10);
  $l -> Subwidget('xscrollbar') -> configure(-width=>10);
  my $f1 = $w -> Component( Frame => 'buttonframe',
			    -container => 0, -relief => 'groove', 
		      -borderwidth => 3 );
  my $ab = $f1 -> Component ( Button => 'acceptbutton',
			      -text => 'Accept', -font => $defaultfont,
			      -default => 'active',
			      -command => ['Accept', $w]) 
    -> pack( -side => 'left', -padx => 10, -pady => 5 );
  my $cb = $f1 -> Component ( Button => 'cancelbutton', 
			      -text => 'Cancel', -font => $defaultfont,
			    -default => 'normal',
			    -command => ['Cancel', $w])
    -> pack( -side => 'left', -padx => 20, -pady => 2 );
  $f1 -> pack( -side => 'bottom', -expand => '1', -fill => 'x' );

  $w -> ConfigSpecs ( -font => ['PASSIVE', undef, undef, ''] );

  return $w;
}

sub Show {
  my $w = shift;
  $w -> grab;
  $w -> watchcursor;
  my @systemfonts;
  {
    open FONTLIST, 'xlsfonts|' or 
	die "Could not get system fonts using xlsfonts.\n";
    while ( <FONTLIST> ) {
	@systemfonts = map {split /^/m; } <FONTLIST>; 
    }
    close FONTLIST;
    my $l = $w -> Subwidget('fontlist');
    foreach $f ( @systemfonts ) { 
      chomp $f;
      $l -> insert( 'end', $f ); 
    }
  }
  $w -> defaultcursor;
  $w -> waitVariable(\$w -> {Configure}{-font} );
  return $w -> cget(-font);
}

sub watchcursor {
  my $w = shift;
  $w -> Busy( -recurse => '1' );
}

sub defaultcursor {
  my $w = shift;
  $w -> Unbusy( -recurse => '1' );
}


1;
__END__;

