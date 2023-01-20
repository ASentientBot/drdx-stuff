set -e
cd "$(dirname "$0")"

# TODO: these cases are getting kind of clunky, refactor?

target=$1
mode=$2
if [[ -z $target || -z $mode ]]
then
	echo "usage: $0 (mac, windows, ios, android, mac_mobile) (test, build, build_run)"
	exit 1
fi
echo "target: $target, mode: $mode"

# TODO: automate download/extract? some require login...

deps="$PWD/Dependencies"
wine="$deps/portable-winehq-stable-5.0-osx64"
air="$deps/AIRSDK_Compiler.macos"
airWindows="$deps/AIRSDK_Compiler.windows"
jdk="$deps/jdk1.8.0_351"
jdkWindows="$deps/jdk-19.0.1"
drdx="$deps/DinoRunDX"
steamWrapper="$deps/FRESteamWorks.ane"
steam="$deps/steamworks_sdk_155"

password='correct horse battery staple'

iosHost=root@localhost
iosPort=2222

PATH="$wine/bin:$jdk/Contents/Home/bin:$air/bin:$PATH"

temp="$PWD/Temp"
rm -rf "$temp"
mkdir "$temp"
cd "$temp"

source="$temp/Source"
cp -R "$drdx" "$source"

if [[ $target = ios || $target = android || $target = mac_mobile ]]
then
	main=../MobileBrain.as

	# TODO: possible to override with prototype/etc instead of direct edit?

	sed -i '' 's/stage.nativeWindow/\/\//' "$source/src/base/Brain.as"
else
	main="$source/src/base/Brain.as"
	extraArgs=-external-library-path+="$steamWrapper"
fi

# TODO: figure out building SWCs (paid Flash IDE)

debug=false
if [[ $mode = test ]]
then
	debug=true
fi

amxmlc "$main" -compiler.debug=$debug -compiler.source-path+="$source/src" -compiler.library-path+="$source/assets/swcs/DR_Audio.swc" -compiler.library-path+="$source/assets/swcs/DR_Interface.swc" -compiler.library-path+="$source/assets/swcs/DR_Main.swc" -compiler.library-path+="$source/assets/swcs/DR_Nodes.swc" $extraArgs -output Brain.swf

cp "$source/src/base/Brain-app.xml" App.xml
sed -i '' 's/\[This value will be overwritten by Flash Builder in the output app.xml\]/Brain.swf/' App.xml
cp -R "$source/src/assets" .
cp "$steamWrapper" .
cp "$steam/redistributable_bin/osx/libsteam_api.dylib" .
cp "$steam/redistributable_bin/win64/steam_api64.dll" .
echo 248330 > steam_appid.txt

if [[ $mode = test ]]
then
	mkdir Unpacked
	unzip "$steamWrapper" -d "Unpacked/$(basename "$steamWrapper")"
fi

# TODO: why are these incompatible?

adt -certificate -cn Amy 2048-RSA Cert.p12 "$password"

openssl genrsa -out Cert.key 2048
openssl req -x509 -new -subj '/CN=Amy/OU=Amy' -nodes -key Cert.key -sha256 -days 9999 -out Cert.crt
openssl pkcs12 -export -passout pass:"$password" -out Cert2.p12 -inkey Cert.key -in Cert.crt

defaults write "$PWD/Fake.plist" ApplicationIdentifierPrefix -array -string ''
defaults write "$PWD/Fake.plist" Platform -array -string iOS
plutil -convert xml1 Fake.plist
security create-keychain -p "$password" "$PWD/Fake.keychain"
security import Cert2.p12 -k "$PWD/Fake.keychain" -P "$password"
security cms -S -k "$PWD/Fake.keychain" -N Fake -i Fake.plist -o Fake.mobileprovision

if [[ $target = mac || $target = mac_mobile ]]
then
	if [[ $mode = test ]]
	then
		DYLD_LIBRARY_PATH="$steam/redistributable_bin/osx" adl -profile extendedDesktop -extdir Unpacked App.xml
	fi

	if [[ $mode = build || $mode = build_run ]]
	then
		adt -package -storetype pkcs12 -keystore Cert.p12 -storepass "$password" -target bundle Build.app App.xml Brain.swf assets -extdir . libsteam_api.dylib steam_appid.txt
	fi

	if [[ $mode = build_run ]]
	then
		Build.app/Contents/MacOS/*
	fi
fi

if [[ $target = windows ]]
then
	export WINEPREFIX="$PWD/Prefix"
	export WINEDLLOVERRIDES="mscoree,mshtml="

	if [[ $mode = test ]]
	then
		# TODO: 32-bit, only works in CrossOver WINE

		wine64 "$airWindows/bin/adl.exe" -profile extendedDesktop -extdir Unpacked App.xml
	fi

	if [[ $mode = build || $mode = build_run ]]
	then
		wine64 "$jdkWindows/bin/java.exe" -jar "$airWindows/lib/adt.jar" -package -storetype pkcs12 -keystore Cert.p12 -storepass "$password" -target bundle -arch x64 Build App.xml Brain.swf assets -extdir . steam_api64.dll steam_appid.txt
	fi

	if [[ $mode = build_run ]]
	then
		# TODO: black screen on non-CrossOver WINE

		wine64 Build/*.exe
	fi
fi

if [[ $target = ios || $target = android ]]
then
	# TODO: ugly, is there some PlistBuddy/defaults-like tool for XML?

	cp App.xml AppMobile.xml
	sed -i '' 's/<extensionID>com.amanitadesign.steam.FRESteamWorks<\/extensionID>//' AppMobile.xml
	sed -i '' 's/<\/initialWindow>/<aspectRatio>landscape<\/aspectRatio><\/initialWindow>/' AppMobile.xml
fi

if [[ $target = ios ]]
then
	# TODO: support unjailbroken provisioning/signing

	# TODO: confirm performance on armv7 devices is unacceptable
	# in case building on ≤ Mojave or messing with no32exec=0 again is worthwhile...
	# (setting iOS ≥ 11 is the only way to prevent adt from failing on stock Ventura)

	sed -i '' 's/<\/application>/<iPhone><InfoAdditions><![CDATA[<key>MinimumOSVersion<\/key><string>11.0<\/string>]]><\/InfoAdditions><requestedDisplayResolution>high<\/requestedDisplayResolution><\/iPhone><\/application>/' AppMobile.xml

	# TODO: proper launch images (currently just convinces AIR im aware of iPhone 5)

	cp ../Default*.png .

	adt -package -target ipa-debug -connect -storetype pkcs12 -keystore Cert2.p12 -storepass "$password" -provisioning-profile Fake.mobileprovision Build.ipa AppMobile.xml Brain.swf assets Default*.png

	unzip Build.ipa
	codesign -fs - --deep Payload/*app
	zip -r Build.ipa Payload

	if [[ $mode = build_run || $mode = test ]]
	then
		scp -P $iosPort Build.ipa "$iosHost":/var/root
		ssh -p $iosPort "$iosHost" appinst Build.ipa
	fi

	if [[ $mode = test ]]
	then
		# TODO: possible to avoid typing "run" every time?

		fdb
	fi
fi

if [[ $target = android ]]
then
	if [[ $mode = build || $mode = build_run ]]
	then
		adt -package -target apk-captive-runtime -storetype pkcs12 -keystore Cert.p12 -storepass "$password" Build.apk AppMobile.xml Brain.swf assets
	fi

	# TODO: implement test, build_run
fi