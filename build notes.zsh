# macOS 13 (Intel) + AppleJDK 17 + CrossOver

# https://airdownload.adobe.com/air/mac/download/32.0/AIRSDK_Compiler.dmg
airNative="$PWD/Downloads/AIRMac"
# https://airdownload.adobe.com/air/win/download/32.0/AIRSDK_Compiler.zip
airWindows="$PWD/Downloads/AIRWindows"
# https://download.oracle.com/java/19/latest/jdk-19_windows-x64_bin.zip
jdkWindows="$PWD/Downloads/JDKWindows"
# https://github.com/pixeljam/DinoRunDX/archive/refs/heads/main.zip
dr="$PWD/Downloads/DRDX"
# https://sourceforge.net/projects/box2dflash/files/box2dflash/Box2DFlashAS3_2.1a/Box2DFlashAS3%202.1a.zip/download
b2d="$PWD/Downloads/Box2D"
# https://github.com/Gamua/Starling-Framework/releases/download/v2.7/starling-2.7.zip
starling="$PWD/Downloads/Starling"
# https://dump.ventero.de/FRESteamWorks/v0.7/FRESteamWorks.ane
steamWrapper="$PWD/Downloads/FRESteamWorks.ane"
# https://partner.steamgames.com/downloads/steamworks_sdk.zip
steam="$PWD/Downloads/Steam"
PATH+=:"/Applications/CrossOver.app/Contents/SharedSupport/CrossOver/bin:$airNative/bin"

rm -rf Temp
mkdir Temp
cd Temp

# cxbottle --create --template win10_64 --bottle DRDX
bottle=DRDX

# TODO: figure out building SWCs (paid Flash IDE)

# SWF
debug=false
amxmlc "$dr/src/base/Brain.as" -compiler.debug=$debug -compiler.source-path+="$dr/src" -compiler.source-path+="$b2d/Source" -compiler.library-path+="$starling/starling/bin/starling.swc" -compiler.library-path+="$dr/assets/swcs/DR_Audio.swc" -compiler.library-path+="$dr/assets/swcs/DR_Interface.swc" -compiler.library-path+="$dr/assets/swcs/DR_Main.swc" -compiler.library-path+="$dr/assets/swcs/DR_Nodes.swc" -external-library-path+="$steamWrapper" -output Brain.swf

# resources
cp "$dr/src/base/Brain-app.xml" App.xml
sed -i '' 's/\[This value will be overwritten by Flash Builder in the output app.xml\]/Brain.swf/' App.xml
cp -R "$dr/src/assets" .
cp "$steamWrapper" .
cp "$steam/redistributable_bin/osx/libsteam_api.dylib" .
cp "$steam/redistributable_bin/win64/steam_api64.dll" .
mkdir Unpacked
unzip "$steamWrapper" -d Unpacked/SteamWrapper.ane
echo 248330 > steam_appid.txt

# test macOS
DYLD_LIBRARY_PATH="$steam/redistributable_bin/osx" adl -profile extendedDesktop -extdir Unpacked App.xml

# test Windows
wine --bottle "$bottle" "$airWindows/bin/adl.exe" -profile extendedDesktop -extdir Unpacked App.xml

# certificate
password=correcthorsebatterystaple
adt -certificate -cn Amy 2048-RSA Cert.p12 "$password"

# build macOS
adt -package -storetype pkcs12 -keystore Cert.p12 -storepass "$password" -target bundle Build.app App.xml Brain.swf assets -extdir . libsteam_api.dylib steam_appid.txt

open Build.app

# build Windows
# TODO: ugly, but adt on Z: generates very weird temp file issues

c=~/"Library/Application Support/CrossOver/Bottles/$bottle/drive_c"
rm -rf "$c/Temp"
cp -R . "$c/Temp"
pushd "$c/Temp"
wine --bottle "$bottle" "$jdkWindows/bin/java.exe" -jar "$airWindows/lib/adt.jar" -package -storetype pkcs12 -keystore Cert.p12 -storepass "$password" -target bundle -arch x64 Build App.xml Brain.swf assets -extdir . steam_api64.dll steam_appid.txt
popd
cp -R "$c/Temp/Build" .

wine --bottle "$bottle" Build/*.exe