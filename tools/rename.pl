#!/usr/bin/env perl

#Current Directoryにある指定した拡張子の、ファイル名の空白をアンダーバーに全置換。

#拡張子指定
$stat='mp4';
$fl='*'.'.'.$stat.'*';

@file=glob $fl;

foreach(@file){
	$new=$_;
	$new=~s!\s!_!g;
	print $_."-".$new."\n";
	system("mv \"$_\" $new");
}
