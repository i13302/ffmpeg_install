$stat='mp4';
$fl='*'.'.'.$stat.'*';

@file=glob $fl;

$i=0;
foreach(@file){
	$new=$_;
	#$new=~s!(\.$stat\.\d*)!!g;
	$new=~s!\s!_!g;
	#$new=$new."_".$i.".".$stat;
	print $_."-".$new."\n";
	system("mv \"$_\" $new");
	$i++;
}
