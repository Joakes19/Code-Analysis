#!/usr/bin/perl
# Author: u6jo
# CGI Perl script: Code Analysis
use CGI qw(-utf-8 :all *table);
autoEscape(0);
use LWP::Simple qw(get);
use warnings;
binmode(STDOUT, ":encoding(utf-8)");
print header(-charset=>'utf-8'), "\n",
start_html({-title=>'Code Analysis',
-author=>'J.L.R.Oakes@liv.ac.uk'}), "\n";
# HTML Body Code:
 print h1('Code Analysis');
 print label('Please Enter a url OR your code as text:');  
 # Start of Form for code values
 print start_form(-method=>'POST',
                    -action=>'',
                    -enctype=>'UTF-8');
          print label('Type URL Here => ');
      print textfield(-name=>'URL',
                    -value=>'',
                    -size=>50,
                    -maxlength=>80);
      print br();print br();
          print label('Type Code Here');
          print br();
      print textarea(-name=>'codeText',
                          -default=>'',
                          -rows=>20,
                          -columns=>50);
                print br();
      print submit('Submit');
    print end_form;
	
# Checking for paramaters from form and running subroutine if found
if(param('URL') && param('codeText')){
        print h1('You have entered values in both fields! Please use only one field!');
} elsif(!param('codeText') && !param('URL')){
        print h1('You have not entered any values!');
} elsif(param('URL')){
        $myCode = get(param('URL'));
		$myCode =~ s/\n/<br>/g;
@codeResults = analyse($myCode);

} elsif(param('codeText')){
        $myCode =  param('codeText');
        $myCode =~ s/\n/<br>/g;
@codeResults = analyse($myCode);

}
# The table output after sub has been run
if(param('URL') || param('codeText')){
print h2("Your Code:");
print p($myCode);
print h1("Code Details");
print table({-border=>'black'},
           caption(''),
           Tr({-align=>'LEFT',-valign=>'TOP'},
           [
              td(['Number of lines of instruction' , $codeResults[0]]),
              td(['Number of elements of instruction' ,$codeResults[1]]),
              td(['Number of non-empty lines of comment'   , $codeResults[2]]),
              td(['Number of non-trivial comments'   , $codeResults[3]]),
              td(['Number of words of comment'   , $codeResults[4]]),
              td(['Ratio of lines of comment to lines of instruction', $codeResults[5]]),
              td(['Ratio of non-trivial comments to lines of instruction'   , $codeResults[6]]),
              td(['Ratio of words of comment to elements of instruction'   , $codeResults[7]])
           ]
           )
        );
		}
end_html;

#Start of Script
sub analyse {
 $givenCode = $_[0];
$commentCount = 0;
$commentWordCount = 0;
$nonTrivialCommentCount = 0;
$linesOfComment = 0;
$givenCode =~ s/<br>/\n/g;
$givenCode =~ s/\*\//\*\/\n/g;
#print $givenCode; - Debugging
		#Checking for all types of comments $1 = multi-line, others are single line
        while( $givenCode =~ s!\/\*([\s|\S]*?)\*\/\n|(\/\/\s+.*\n|\/\/\s+.*\n)|(\#\s+.*\n|\#\s+.*\n)!!x){
                if($1){
                        $commentCount += 1;
                        $tempComment = "$1";
						$tempWords = 0;
						@tempCommentLines = split /\n/ , $tempComment;
						foreach $tempLine(@tempCommentLines){
							if ($tempLine !~ /\s([\+\-\%\!\=\>\<\&\|\@\*\/])\s/){
								++$commentWordCount, ++ $tempWords while $tempLine =~ /\w+/g;
								++$linesOfComment;
								# Debbuging: print "$tempLine<br>";
							} 
						}
                        if($tempWords >= 5){$nonTrivialCommentCount++};
                }
                if($2 || $3){
                        $commentCount+=1;
                        $linesOfComment +=1;
                        $tempComment = "$2" || "$3";
                        $tempWords = 0;
                        #print $tempComment;
                        ++$commentWordCount, ++ $tempWords while $tempComment =~/\w+/g;
                        if($tempWords >= 5){$nonTrivialCommentCount++};
                 }
                $tempComment = "";
         }
		#Debugging:
        #print "\nComment Count: $commentCount, Comment Word Count: $commentWordCount, non-Trivial: $nonTrivialCommentCount, Lines of Comment: $linesOfComment\n";

#Counting instructions from remaining code with removed comments
$instructionLines = 0;
$instructionElements = 0;
$givenCode =~s/else/\nelse/g;
@codeLines = split /\n/ , $givenCode;
#Debbuging: print @codeLines;
foreach $line(@codeLines){
        if ($line =~ /\b(?!\d)\w+\b|[\+\*\-\%\!\=\>\<\&\|]+/x){
                # Debbuging: print "Line: $line<br>";
                $instructionLines +=1;
                while($line =~ /\b((?!\d)\w+)|([\+\*\-\%\!\=\>\<\&\|]+)/g){
                        $instructionElements += 1;
                }
        }
}
# Ratio calculations and rounding
$ratioLineCommentToLineInstrcution = sprintf("%0.1f", ($linesOfComment / $instructionLines));
$ratioNonTrivialToLineInstruction = sprintf("%0.1f", ($nonTrivialCommentCount / $instructionLines));
$ratioWordCommentToElementInstruction = sprintf("%0.1f", ($commentWordCount / $instructionElements));


@finalValues = ($instructionLines, $instructionElements,$linesOfComment, $nonTrivialCommentCount, $commentWordCount,$ratioLineCommentToLineInstrcution,$ratioNonTrivialToLineInstruction, $ratioWordCommentToElementInstruction);
return @finalValues;
}
#End of Script





