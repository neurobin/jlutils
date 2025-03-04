###START###
#!/usr/bin/env bash

set -o errexit  #>Exit when a command fails (returns non-zero)
set -o pipefail #>Exit when a command within a pipeline fail (returns non-zero)
set -o nounset  #>Forbid to use unset

# Reset language to default
export LANG=C

# Switch to root account
RunasRoot () { sudo --login --user=root "$@"; }

# Colors for messages
PrintInfo () { printf '\e[32m[INFO]\e[0m \e[33m%s\e[0m\n' "$1"; }
PrintError () { printf '\e[31m[ERROR]\e[0m \e[33m%s\e[0m\n' "$1"; }
PrintQuestion () { printf '\e[35m[QUESTION]\e[0m \e[33m%s\e[0m\n' "$1"; }

RmLockFiles ()
{
   PrintInfo "Remove lock files of pamac and pacman"
   RunasRoot find /var/tmp/pamac/ -type f -iname "*db.lck" -exec rm --force --verbose "{}" \;
   RunasRoot find /var/lib/pacman/ -type f -iname "*db.lck" -exec rm --force --verbose "{}" \;
}

AskForUpgrade ()
{
   PrintInfo "Performing a full upgrade with pacman"
   while true; do
      PrintQuestion "Do you want to continue? [Yy/Nn] (Be aware that a full upgrade needs enough ram on a live session)"
      read -p "> [Yy/Nn] " yn
      case $yn in
      [Yy]*)
         RunasRoot pacman --sync --refresh --refresh --sysupgrade --sysupgrade --noconfirm
         PrintInfo "Done. Note that you need to refresh the database for pamac also."
         break
      ;;
      [Nn]*)
         break
      ;;
      *)
         PrintError "No valid answer. Continue." && continue ;;
      esac
   done
}

AskForRefreshKeys ()
{
   PrintInfo "Refresh GnuPG Database of pacman from the Internet"
   while true; do
      PrintQuestion "Do you want to continue? [Yy/Nn] (Note that this can take a while.)"
      read -p "> [Yy/Nn] " yn
      case $yn in
      [Yy]*)
         RunasRoot pacman-key --refresh-keys && break
      ;;
      [Nn]*)
         break
      ;;
      *)
         PrintError "No valid answer. Continue." && continue ;;
      esac
   done
}

AskForRemoveCache ()
{
   PrintInfo "Remove cached software packages [optional]"
   while true; do
      PrintQuestion "Delete them? [Yy/Nn]"
      read -p "[Yy/Nn] > " yn
      case $yn in
      [Yy]*)
         PrintInfo "Removing package cache"
         RunasRoot pacman --sync --clean --clean --noconfirm
         if [[ $(ls /var/cache/pacman/pkg/ | wc -l) != 0 ]]; then
            RunasRoot find /var/cache/pacman/pkg/ -type f -exec rm --force --verbose "{}" \;
         fi
      ;;
      [Nn]*)
         break
      ;;
      *)
         PrintError "No valid answer." && continue ;;
      esac
   done
}

AskForLocalMirrorSetup ()
{

   PrintInfo "Switch to a local mirror by Geolocation [optional]"
   while true; do
      PrintQuestion "Switch to local mirror? [Yy/Nn]"
      read -p "[Yy/Nn] > " yn
      case $yn in
      [Yy]*)
         PrintInfo "Switching to a local mirror by Geolocation"
         RunasRoot pacman-mirrors --geoip
         RunasRoot pacman-mirrors --fasttrack 5
      ;;
      [Nn]*)
         break
      ;;
      *)
         PrintError "No valid answer." && continue ;;
      esac
   done
}

BasicMethod ()
{
   RmLockFiles

   PrintInfo "Refresh Package Database"
   RunasRoot pacman --sync --refresh --refresh

   PrintInfo "Populate local keyrings to the GnuPG Database of pacman"
   RunasRoot pacman-key --populate archlinux manjaro

   AskForRefreshKeys

   AskForUpgrade
}

ModerateMethod ()
{
   RmLockFiles

   PrintInfo "Remove Pacman's GnuPG Database"
   RunasRoot find /etc/pacman.d/gnupg/ -exec rm --recursive --force --verbose "{}" \;

   PrintInfo "Initilize Pacman's GnuPG Database"
   RunasRoot pacman-key --init

   PrintInfo "Populate local keyrings to Pacman's GnuPG Database"
   RunasRoot pacman-key --populate archlinux manjaro

   AskForRefreshKeys

   AskForRemoveCache

   AskForUpgrade
}

AggressiveMethod ()
{
   RmLockFiles

   PrintInfo "Switch to global mirror (Manjaro's CDN)"
   RunasRoot pacman-mirrors --country Global
   RunasRoot pacman-mirrors --fasttrack 5

   PrintInfo "Remove Pacman's GnuPG Database"
   RunasRoot find /etc/pacman.d/gnupg/ -exec rm --recursive --force --verbose "{}" \;

   PrintInfo "Initilize Pacman's GnuPG Database"
   RunasRoot pacman-key --init

   PrintInfo "Removing package cache"
   RunasRoot pacman --sync --clean --clean --noconfirm
   if [[ $(ls /var/cache/pacman/pkg/ | wc -l) != 0 ]]; then
      RunasRoot find /var/cache/pacman/pkg/ -type f -exec rm --force --verbose "{}" \;
   fi

   PrintInfo "Create a temporary folder in /tmp"
   TMPDIR="$(mktemp -d)"
   PrintInfo "${TMPDIR}"

   PrintInfo "Copy /etc/pacman.conf to ${TMPDIR}/pacman.conf and disable temporarily gpg verification."
   RunasRoot cp "/etc/pacman.conf" "${TMPDIR}/pacman.conf"
   RunasRoot sed --in-place --regexp-extended 's/^(SigLevel).+$/\1 = Never/g' "${TMPDIR}/pacman.conf"

   PrintInfo "Download the newest packages which contains the gpg keyrings in ${TMPDIR}"
   RunasRoot pacman --sync --refresh --downloadonly --noconfirm --cachedir "${TMPDIR}" --config "${TMPDIR}/pacman.conf" archlinux-keyring manjaro-keyring gnupg --overwrite "*"

   PrintInfo "Install temporarily downloaded keyring packages"
   RunasRoot pacman --upgrade --noconfirm --config "${TMPDIR}/pacman.conf" --overwrite "*" $(find ${TMPDIR} -type f -name "*.tar.*")

   PrintInfo "Remove temporary directory: ${TMPDIR}"
   RunasRoot find "${TMPDIR}" -type f -exec rm --recursive --force --verbose "{}" \;
   RunasRoot rmdir --verbose "${TMPDIR}"

   AskForLocalMirrorSetup

   AskForRefreshKeys

   AskForUpgrade

}

HelpPage ()
{
   printf "\n\t%s\n" "Method 1 - Basic"
   printf "\t%s\n" "1. Remove lock files of pamac and pacman"
   printf "\t%s\n" "2. Refresh Package Database"
   printf "\t%s\n" "3. Populate local keyrings to the GnuPG Database of pacman"
   printf "\t%s\n" "4. Refresh GnuPG Database of pacman from the Internet [optional]"
   printf "\t%s\n" "5. Performing a full upgrade with pacman [optional]"

   printf "\n\t%s\n" "Method 2 - Moderate"
   printf "\t%s\n" "1. Remove lock files of pamac and pacman"
   printf "\t%s\n" "2. Remove Pacman's GnuPG Database"
   printf "\t%s\n" "3. Initilize Pacman's GnuPG Database"
   printf "\t%s\n" "4. Populate local keyrings to Pacman's GnuPG Database"
   printf "\t%s\n" "5. Refresh GnuPG Database of pacman from the Internet [optional]"
   printf "\t%s\n" "6. Remove cached software packages [optional]"
   printf "\t%s\n" "7. Performing a full upgrade with pacman [optional]"

   printf "\n\t%s\n" "Method 3 - Aggressive"
   printf "\t%s\n" "1. Remove lock files of pamac and pacman"
   printf "\t%s\n" "2. Switch to global mirror (Manjaro's CDN)"
   printf "\t%s\n" "3. Remove Pacman's GnuPG Database"
   printf "\t%s\n" "4. Initilize Pacman's GnuPG Database"
   printf "\t%s\n" "5. Remove cached software packages"
   printf "\t%s\n" "6. Create a temporary folder in /tmp"
   printf "\t%s\n" "7. Copy /etc/pacman.conf to TMPDIR/pacman.conf and disable temporarily gpg verification."
   printf "\t%s\n" "8. Download the newest packages which contains the gpg keyrings in TMPDIR"
   printf "\t%s\n" "9. Install temporarily downloaded keyring packages"
   printf "\t%s\n" "10. Remove temporary directory TMPDIR"
   printf "\t%s\n" "11. Switch to a local mirror by Geolocation"
   printf "\t%s\n" "12. Refresh GnuPG Database of pacman from the Internet [optional]"
   printf "\t%s\n" "13. Performing a full upgrade with pacman [optional]"

   printf "\n\t%s\n\n" "Note: That tool is not designed to fix gpg issues with your local user GnuPG Database, which is commonly used for AUR Packages as an example."
}

HelpUsage () { printf '\e[32m%s\e[0m\n' "$0 [--usage|--help|--basic|--moderate|--aggressive|--ask] (default: [--basic])"; }

Menu ()
{
   clear
   while true; do
      printf '\e[33m%s\e[0m\n' "1. Basic"
      printf '\e[33m%s\e[0m\n' "2. Moderate"
      printf '\e[33m%s\e[0m\n' "3. Aggressive"
      printf '\e[33m%s\e[0m\n' "4. Explanations of the methods"
      printf '\n\e[33m%s\e[0m\n\n' "Type [q] to quit."
      PrintQuestion "Choose a Method by typing the number and press ENTER on you keyboard."
      read -p "[1,2,3,4,q]>  " choice
      case $choice in
         1)
            BasicMethod && exit
         ;;
         2)
            ModerateMethod && exit
         ;;
         3)
            AggressiveMethod && exit
         ;;
         4)
            HelpPage && continue
         ;;
         q)
            exit
         ;;
         *)
            clear && PrintError "No valid answer. Continue." && continue ;;
      esac
   done
}

[[ -z $@ ]] && BasicMethod && exit
case $1 in
   --basic)
      BasicMethod && exit
   ;;
   --moderate)
      ModerateMethod && exit
   ;;
   --aggressive)
      AggressiveMethod && exit
   ;;
   --help)
      HelpUsage && HelpPage && exit
   ;;
   --usage)
      HelpUsage && exit
   ;;
   --ask)
      Menu && exit
   ;;
   *)
      PrintError "\"$1\" is not a valid parameter. See \"$0 --usage\""
   ;;
esac
###END###
