# Flash Player Distribution Download #

**This tool is no longer unmaintained**. If you require this kind of functionatlity, then please consider using autopkg or another maintained system.

About
--------

This is an open source (GPL v3 or later) script designed to make automated download of the latest Adobe Flash Player Mac OS X distribution installer simple.

There is also a version of the script which depends on autopkg. This should be used until Adobe changes the distribution download URL back so that it is accessible as an unauthenticated user.

License: [GNU GPL 3.0 License][1]


Requirements
---------
 - Mac OS X 10.8 or later
 - autopkg (depending on version)
 - python (depnding upon version)
 - wget (dpening on version)
 - internet access
 - adobe distribution url (passed in as argument 1 or entered into the script directly)

Usage Instructions
---------

Visit the [Adobe Flash Player Distribution URL][2] and apply for a distribution licence and URL, then run the script with the URL as the first argument, within quotes (as shown below) :

./path_to_script/build_latest_flash.bash "http://www.adobe.com/your/distribution/url/in/this/space"

Should you wish to use this script in another system it is important that you adhear to the licence agreement.


  [1]: http://www.gnu.org/copyleft/gpl.html
  [2]: http://www.adobe.com/products/players/flash-player-distribution.html

