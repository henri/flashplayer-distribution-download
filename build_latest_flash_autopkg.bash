#!/bin/bash

# Copyright 2016 - Henri Shustak 
# Licenced under the GNU GPL v3 or later
# Requires autopkg to be configured
# Version 1.0

#config - update as required for your enviroment
autopkg_pickup_dir="/Users/user/Library/AutoPkg/Cache/com.github.autopkg.pkg.FlashPlayerExtractPackage/"
output_dir="/Volumes/adobe_flash_player/downloads"
latest_version_absolute_path="/Volumes/adobe_flash_player/latest_build_version.txt"

#run autopkg and pull down the latest version of flash (run with sudo as smcadmin)
su smcadmin -l -c 'autopkg run AdobeFlashPlayer.pkg >> /dev/null 2> /dev/null'

#setup some varibales for work to be done
latest_version_file_name=`basename "${latest_version_absolute_path}"`
latest_download_name=`ls "${autopkg_pickup_dir}" | grep -e "^AdobeFlashPlayer-" | tail -n 1`
if [ "${latest_download_name}" == "" ] ; then echo "ERROR! : Unable to locate latest download" ; exit -5 ; fi
absolute_path_latest_download="${autopkg_pickup_dir}/${latest_download_name}"
latest_version_num=`echo "${latest_download_name}" | awk -F "AdobeFlashPlayer-" '{print $2}' | awk -F ".pkg" '{print $1}'`
disk_image_output_name="adobe_flash-${latest_version_num}-`date "+%Y%m%d"`.dmg"
disk_image_output_absolute_path="${output_dir}/${disk_image_output_name}"
last_version_saved=`cat "${latest_version_absolute_path}"`

echo "Latest Installed Version : ${last_version_saved}"
echo "Latest Available Version : ${latest_version_num}"

# skip updates if the latest version is already saved
if [ "${last_version_saved}" == "${latest_version_num}" ] ; then 
	echo "No updates available. Remote server has the same version as was previously built."
	exit 1
else
	echo "New Version Available!"
fi

# check the output image dest path is availible
if [ -f "${disk_image_output_absolute_path}" ] ; then echo "ERROR! : output file already exists." ; exit 0 ; fi

#make disk image with that package
tmp_working_dir=`mktemp -d /tmp/smc-autopkg-XXXXXXXXXXX`

absolute_path_tmp_dir_build="${tmp_working_dir}/AdobeFlashPlayer-${latest_version_num}"
rsync -a "${absolute_path_latest_download}" "${absolute_path_tmp_dir_build}/"
if [ $? != 0 ] ; then echo "ERROR! Unable to copy files to working directory" ; exit -1 ; fi
hdiutil create -srcfolder "${absolute_path_tmp_dir_build}" "${tmp_working_dir}/${disk_image_output_name}"
if [ $? != 0 ] ; then echo "ERROR! Unable to create disk image" ; exit -2 ; fi
rsync -rlpt "${tmp_working_dir}/${disk_image_output_name}" "${disk_image_output_absolute_path}"
if [ $? != 0 ] ; then echo "ERROR! Unable to copy disk image to output directory" ; exit -2 ; fi
rm -R "${tmp_working_dir}"
echo ${latest_version_num} > "${latest_version_absolute_path}"

echo "Completed update of Flash${latest_version_num}"

exit 0

