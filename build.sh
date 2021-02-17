#!/bin/bash

#скачиваем необходимые библиотеки и скрипты
TMPFILE=`mktemp`
PWD=`pwd`
LIBDIR=$PWD/lib-linuxbuh
PKG2APPIMAGE=$PWD/pkg2appimage

if [ -e $LIBDIR ]; then

echo "Библиотеки есть"

else

echo "Качаем библиотеки"
wget "https://github.com/linuxbuh/lib-linuxbuh/archive/master.zip" -O $TMPFILE
unzip -d $PWD $TMPFILE
rm $TMPFILE
mv $PWD/lib-linuxbuh-master $PWD/lib-linuxbuh

fi

if [ -e $PKG2APPIMAGE ]; then

echo "pkg2appimage есть"

else

echo "Качаем pkg2appimage"
wget "https://raw.githubusercontent.com/AppImage/pkg2appimage/master/pkg2appimage" -O $PWD/pkg2appimage
chmod ugo+x $PWD/pkg2appimage
fi


###################################################################################################

#Подключаем переменные
source ./lib-linuxbuh/lib-bash-1c/param-all.lib


#Качаем библиатеку icu
LIBICU_VER=libicu63_63.2-3
WGETICUPATH=http://ftp.ru.debian.org/debian/pool/main/i/icu/

#Логин на сайте release.1c.ru
source ./lib-linuxbuh/bash-dialog-1c/login-1c.ru.dialog
########################################################################## Платформа #########################################################################



#Выбор битности платформы
#source ./lib-linuxbuh/bash-dialog/osbit-vibor.dialog
OSBIT=64
ICUOSBIT=_amd64.deb
MASHINETYPE=x86_64

ICU=$LIBICU_VER$ICUOSBIT

#Начинаем работу
#Подключаемся к серверу 1С
source ./lib-linuxbuh/lib-bash-1c/connect-platform.lib

#Выясняем url страниц на сайте release.1c.ru
source ./lib-linuxbuh/lib-bash-1c/url-platform.lib

#Скачиваем платформу
source ./lib-linuxbuh/lib-bash-1c/download-platform.lib

#Распаковываем платформу 1C
source ./lib-linuxbuh/lib-bash-1c/unpack-platform-client.lib


#Выбор дистрибутива для сборки

echo
echo -e "\e[1;31;42mВыбор дистрибутива для сборки 1С:Предприятие 8.3\e[0m"
echo
PS3='Выберите (нажмите цифру - например 1): '
echo
select BUILDDISTR in "xenial" "bionic"
do
  echo
  echo -e "\e[1;34;4mВы выбрали $BUILDDISTR\e[0m"
  echo
  break
done
#
#Проверка
if [[ -z "$BUILDDISTR" ]];then
    echo  -e "\e[31mВы не выбрали\e[0m"
    exit 1
fi
#

rm -fr $GDEPATH/AppImageBuild
mkdir $GDEPATH/AppImageBuild
mkdir $GDEPATH/AppImageBuild/$BUILDDISTR-lib

#Скачиваем библиотеку icu
WGETICU=$WGETICUPATH$ICU

source ./lib-linuxbuh/lib-bash-1c/appimage-builder.lib

cd $GDEPATH/AppImageBuild

find -type f -name \1c-client-$VERPLATFORM-$BUILDDISTR.yml -exec sed -i -r 's/HERE2/"$(dirname "$(readlink -f "${0}")")"/g' {} \;
find -type f -name \1c-client-$VERPLATFORM-$BUILDDISTR.yml -exec sed -i -r 's/HERE1/"${HERE}"/g' {} \;
find -type f -name \1c-client-$VERPLATFORM-$BUILDDISTR.yml -exec sed -i -r 's/HERE3/"${HERE}"/g' {} \;
find -type f -name \1c-client-$VERPLATFORM-$BUILDDISTR.yml -exec sed -i -r 's/HERE4/"${HERE}"/g' {} \;
find -type f -name \1c-client-$VERPLATFORM-$BUILDDISTR.yml -exec sed -i -r 's/LDEDIT/"${LD_LIBRARY_PATH}"/g' {} \;

ln -s $GDEPATH/pkg2appimage $GDEPATH/AppImageBuild/pkg2appimage

source $GDEPATH/AppImageBuild/pkg2appimage $GDEPATH/AppImageBuild/1c-client-$VERPLATFORM-$BUILDDISTR.yml

$GDEPATH/lib-linuxbuh/lib-bash/createdir.sh $GDEPATH/AppDistr
mv $GDEPATH/AppImageBuild/out/*.AppImage $GDEPATH/AppDistr/1C-Enterprise-$VERPLATFORM-$MASHINETYPE.AppImage

#exec ./buildappimage $VERPLATFORM $BUILDDISTR $GDEPATH
