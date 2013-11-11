# Some filter functions
#

filter match( $expr )
{
	if( $_.tostring() -match $expr )
	{	$_	}
}

filter notmatch( $expr )
{
	if( $_.tostring() -notmatch $expr )
	{	$_	}
}

filter like( $expr )
{
	if( $_.toString() -like $expr )
	{	$_	}
}

filter notlike( $expr )
{
	if( $_.tostring() -notlike $expr )
	{	$_	}
}


filter equal( $expr )
{
	if( $_.tostring() -eq $expr )
	{	$_	}
}

filter notequal( $expr )
{
	if( $_.tostring() -ne $expr )
	{	$_	}
}

filter lower( $expr )
{
	if( $_.tostring() -lt $expr )
	{	$_	}
}

filter greater( $expr )
{
	if( $_.tostring() -gt $expr )
	{	$_	}
}

filter lowerequal( $expr )
{
	if( $_.tostring() -le $expr )
	{	$_	}
}

filter greaterequal( $expr )
{
	if( $_.tostring() -ge $expr )
	{	$_	}
}


filter and( $expr )
{
	if( $_.tostring() -bAND $expr )
	{	$_	}
}

filter or( $expr )
{
	if( $_.tostring() -bOR $expr )
	{	$_	}
}

filter xor( $expr )
{
	if( $_.tostring() -bXOR $expr )
	{	$_	}
}

#filter not( $expr )
#{
#	if( $_.tostring() -bNOT $expr )
#	{	$_	}
#}
