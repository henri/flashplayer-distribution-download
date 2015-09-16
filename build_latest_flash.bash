#!/bin/bash
#
# (C) Henri Shustak 2014
#
# Released under the GNU GPL v3 or later
#
# About this script : 
#    Will download latest Mac OS X version of FireFox
#    Updates default so that the Mac OS X system proxy is used.
#    Builds package installer package for this modified version of FireFox
#    Modify this script to alter other various other settings.
#
# Requirements : 
#    - wget
#    - internet access for your system(s)
#    - adobe distribution authroization link (this needs to be entered into the variable below or provided as the first argument to the script)
#
#
# Script version :
#    1.0 : Initial release 
#    1.1 : Improved the version release check to keep up with the adobe site.
#    1.2 : Requires your adobe auth link and will also automatically generate download folder if it is not present.
#    1.3 : Removed some options which were no longer required.

# - - - - - - - - - - - - - - - - 
# script settings
# - - - -- - - - - - - - - - - - -

# configure the download authorization link to either the fist input parampter or to the default (which you can set below)
if [ "${1}" == "" ] ; then
	# configure a default distribution_auth_link
	distribution_auth_link=""
else
	distribution_auth_link="${1}"
fi

# download and build same copy again? ("YES"/"NO")
if [ "${download_and_build_same_copy_again}" != "YES" ] && [ "${download_and_build_same_copy_again}" != "NO" ] ; then
    download_and_build_same_copy_again="NO"
fi

	

# - - - - - - - - - - - - - - - - 
# calculate some variables and add clean up function
# - - - -- - - - - - - - - - - - -

# work out where we are in the file system
path_to_this_script="${0}"
parent_folder="`dirname \"${path_to_this_script}\"`"

# additional variables
user_agent="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9b5) Gecko/2008032619 Firefox/3.0b5 "

# add on some search paths
export PATH=/opt/local/bin:${PATH}

# clean up various left overs.
function clean_exit () {
    exit $exit_value
}


# - - - - - - - - - - - - - - - - 
# perform some checks 
# - - - -- - - - - - - - - - - - -
if [ ${#} -gt 1 ] ; then 
    echo "Usage : /path_to_this_script/script_name.bash [\"adobe distribution download URL\"]"
    echo "        eg. : ./build_latest_flash.bash [\"http://adobe_distribution_download_url\"]"
    export exit_value=-1
	clean_exit
fi

if [ "${distribution_auth_link}" == "" ] && [ ${#} -eq 0 ] ; then
	echo "You should provide a distribution authorization URL."
	echo "For additional information visit : <http://www.adobe.com/products/players/flash-player-distribution.html>"
    export exit_value=-1
	clean_exit
fi

# move to this scripts parents directory
cd "${parent_folder}"
if [ $? != 0 ] ; then
    echo "Unable to locate the directory where this script is installed."
    echo "Please check the script is in a accessible directory and then try"
    echo "running this script again."
    export exit_value=-1
    clean_exit
fi

# check there is a downloads folder present, if not create!
if ! [ -d ./downloads ] ; then
	mkdir ./downloads
	if [ $? != 0 ] ; then
		echo "Unable to locate or create the downloads directory!"
		export exit_value=-1
		clean_exit
	fi
fi

# check that wget is installed on this system
which wget > /dev/null
if [ $? != 0 ] ; then
	echo "This script requires that you have wget installed on your system."
	echo "Just a couple of possible options are listed below : "
	echo ""
	echo "     (1) Download and install the package from the following URL :"
	echo "         http://www.merenbach.com/software/wget"
	echo ""
	echo "     (2) Download and install Macports :"
	echo "         http://www.macports.org/"
	echo "         To install wget then issue the following commands :"
	echo ""
	echo "              $ sudo sudo port selfupdate"
	echo "              $ sudo port install wget"
	echo ""
	echo "Once wget is installed and in your path 'echo \$PATH', then try"
	echo "running this script again."
	export exit_value=-1
	clean_exit
fi


# version file storage varibles (file to store build version)
lastest_version_build_file="${parent_folder}/latest_build_version.txt"
current_version_build_file="${parent_folder}/current_build_version.txt"
last_version_built=`cat "${lastest_version_build_file}" 2> /dev/null`
if [ $? != 0 ] ; then
    echo "WARNING! : Unable to determine last built version."
    echo "           Could be the first time you are running this script?"
    last_version_built="?.?.?"
fi
    
    
# locate the latest version download link
echo "Attempting to check for latest version of flash...."
check_link="${distribution_auth_link}"
latest_availible_version=`wget --no-check-certificate --user-agent="${user_agent}" ${check_link} -O - 2> /dev/null | grep -A 1 '<span class="TextH3 LayoutSmallRow">' | head -n 2 | tail -n 1 | awk -F "Flash Player " '{print $2}' | awk -F "</span>" '{print $1}' | awk '{print $1}'`
if [ $? != 0 ] || [ "${latest_availible_version}" == "" ] ; then
	echo "ERROR ! : Unable to determine latest version available."
	export exit_value=-2
    clean_exit
fi
download_link=`wget --no-check-certificate --user-agent="${user_agent}" ${check_link} -O - 2> /dev/null | grep "(for System Administrators)" | awk -F "href=\"" '{print $2}' | awk -F "\">Download DMG Installer" '{print $1}' | head -n 1`
if [ $? != 0 ] || [ "${download_link}" == "" ] ; then
	echo "ERROR ! : Unable to determine latest version download link."
	export exit_value=-2
    clean_exit
fi
#http://fpdownload.macromedia.com/get/flashplayer/current/licensing/mac/install_flash_player_14_osx_pkg.dmg
echo "download link : $download_link"
# check that the latest version is availible for download
wget --spider --no-check-certificate --user-agent="${user_agent}" ${download_link} 2> /dev/null
if [ $? != 0 ] ; then
	echo "ERROR ! : Download link for latest version is unavailible."
	export exit_value=-2
    clean_exit
fi

echo "    Last successful built version : $last_version_built"
echo "    Latest available version      : $latest_availible_version"

# should the download proceed given the version availible from the servers?
if [ "$download_and_build_same_copy_again" == "NO" ] ; then 
	if [ "${latest_availible_version}" == "${last_version_built}" ] ; then
		echo "No updates available. Remote server has the same version as was previously built."
		export exit_value=-255
        clean_exit
	fi
fi

# download the latest version
echo "Attempting to download latest version...."
echo "    Download Link : $download_link"
download_name="./downloads/adobe_flash-${latest_availible_version}-`date "+%Y%m%d"`.dmg"
wget --no-check-certificate --user-agent="${user_agent}" --output-document="${download_name}" ${download_link} 

# check the download completed successfully
if [ $? != 0 ] ; then
    echo "Download failed. Please try to download manually."
    export exit_value=-1
    clean_exit
fi

# record the version of the download as completed
echo ${latest_availible_version} > "${lastest_version_build_file}"

# clean up the mess
export exit_value=0
clean_exit



