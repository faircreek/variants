######################################################################## 
#
# Copyright (C) 2015  Olof <olof.faircreek@gmail.com>
# 
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m function.pm -m variants.pm <files>
########################################################################
package Vars;

#use strict;
use Sys::Hostname;

require "function.pm";

sub ToUpper
{
    my $string = shift;
    return uc($string);
}

Function::AddFunction ("toupper", "Vars::ToUpper");

sub ToLower
{
    my $string = shift;
    return lc($string);
}

Function::AddFunction ("tolower", "Vars::ToLower");

#This is just a test function

sub MultiInputs
{
    my $arg;
    my $output = "Multiple inputs: ";
    foreach $arg (@_) {
	$output = $output."<$arg> ";
    }
    return $output;
}

Function::AddFunction ("multi", "Vars::MultiInputs");

#End test function


sub HostName 
{

	my @holder = split /\./, hostname; 
	return $holder[0];
}

Function::AddFunction ("hostname", "Vars::HostName");


#Need to fix this for LDAP based netgroups too

sub get_primary_netgroups_host
{
  my $hostname = shift; 
  my (@netgroups,$netgroups); 
  chop($netgroups = `ypmatch "$hostname.*" netgroup.byhost 2>&1`); 
  if ($?) { 
      return (); 
  } 
  @netgroups = split(',', $netgroups); 
  return (@netgroups); 
}

sub NetGroupH 
{
	my $netgroup = shift;
	my @netgroups = get_primary_netgroups_host(HostName());
	if (grep { /$netgroup/ } @netgroups)
	{
	    return 1;
	} else {
	    return 0;
	}
}

Function::AddFunction ("netgroup", "Vars::NetGroupH");

sub get_primary_netgroups_user
{
  my $username = shift; 
  my (@netgroups,$netgroups); 
  chop($netgroups = `ypmatch "$username.*" netgroup.byuser 2>&1`); 
  if ($?) { 
      return (); 
  } 
  @netgroups = split(',', $netgroups); 
  return (@netgroups); 
}

sub NetGroupU 
{
	my $netgroup = shift;
        my $username = shift;
	my @netgroups = get_primary_netgroups_user($username);
	if (grep { /$netgroup/ } @netgroups)
	{
	    return 1;
	} else {
	    return 0;
	}
}

Function::AddFunction ("netgroup", "Vars::NetGroupU");


sub ipaddresses
{

	my(@IPS);
	my($ip);
	foreach( `/sbin/ifconfig -a` )
	{
		if( /inet addr:(\d+)\.(\d+)\.(\d+)\.(\d+)\s/ )
		{
                	$ip = ($1 << 24) + ($2 << 16) + ($3 << 8) + $4;
                	push( @IPS, $ip );
        	}
	}
	return(@IPS);
}

sub NetWork
{

        my( $search ) = @_;
        my( @ip, $ip, $nm );
	my @IPS = ipaddresses();


	if( $search =~ /^([\d+\.]+)\/(\d+)$/ ) {
                #
                # This is one of our IP specified network addresses.
                #
                $nm = $2;
                @ip = split( /\./, $1 );
                @ip = ( @ip, 0,0,0,0 )[0 .. 3];
                $ip = ( $ip[0] << 24 ) + ( $ip[1] << 16 ) + ( $ip[2] << 8 ) + $ip[3];
                $nm = 0xffffffff - ((2**(32-$nm))-1);


                foreach( @IPS ) {
                        #print("NM: $nm IP: $ip \n");
                        return( 1 ) if( ($_ & $nm) == ($ip & $nm));
                }
                return( 0 );
	}
	return( 0 );

}

Function::AddFunction ("network", "Vars::NetWork");




Filepp::SetDefine ("__HOSTNAME__", HostName());



return 1;
########################################################################
# End of file
########################################################################
