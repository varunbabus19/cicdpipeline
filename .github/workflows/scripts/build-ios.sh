
# Functions
printHelp() {
    echo "\t"
    echo "\tUse: ./build-ios.sh -t <BUILD_TYPE> -v <VARIANT>  -b <VERSIONNUMBER> -n <BUILDNUMBER>"
    echo "\t"
    echo "\tWhere,"
    echo "\t"
    echo "\t<BUILD_TYPE> = debug || release"
    echo "\t<VARIANT> = prod | qa | dev"
    echo "\t<VERSIONNUMBER> like 1.0.0"
    echo "\t<BUILDNUMBER> like 123"
    echo "\t"
}

FLUTTER_ADDITIONAL_FLAGS=""

# Read parameters
while getopts t:w:v:b:n:c option
do
case "${option}"
in
t) BUILD_TYPE=${OPTARG};;
v) VARIANT=${OPTARG};;
b) VERSIONNUMBER=${OPTARG};;
n) BUILDNUMBER=${OPTARG};;
c) FLUTTER_ADDITIONAL_FLAGS="--config-only";;
esac
done

# Validate parameter values
if [[ -z "$BUILD_TYPE"  || ( "$BUILD_TYPE" != "debug" && "$BUILD_TYPE" != "release" ) ]]; then
    printHelp
    exit 1
fi

if [[ -z "$VARIANT" || ( "$VARIANT" != "prod" && "$VARIANT" != "qqa" && "$VARIANT" != "dev" ) ]]; then
    printHelp
    exit
fi


regExp='^[0-9]+([.][0-9]+([.][0-9]+))?$'
if ! [[ $VERSIONNUMBER =~ $regExp ]] ; then
  printHelp
  exit
fi

# Remove dot from BUILDNUMBER if any
BUILDNUMBER=${BUILDNUMBER//.}
regExpNumber='^[0-9]+$'
if ! [[ $BUILDNUMBER =~ $regExpNumber ]] ; then
  printHelp
  exit
fi


FLAVOR="$VARIANT"
MAIN_FILE_NAME="$VARIANT"
MAIN_FILE="lib/main_""$MAIN_FILE_NAME"".dart"
ICON_FILE="flutter_launcher_icons-""${MAIN_FILE_NAME}"".yaml"


echo "Creating $BUILD_TYPE build of Flowbird - $FLAVOR"


# Generate and build Flutter project
echo "\tGenerate and build flutter project"
echo "Removing Old Builds.."
rm -rf build

echo "Running flutter clean.."
flutter clean
flutter packages get
flutter precache --ios
cd ios
echo "Running Pod install.."
pod install
cd ..
echo "Creating flutter icons..."
#flutter pub run flutter_launcher_icons:main -f $ICON_FILE
echo "Creating ios.."
#flutter build ios --"$BUILD_TYPE" --flavor "$FLAVOR" -t "$MAIN_FILE" --build-name="$VERSIONNUMBER" --build-number="$BUILDNUMBER" --no-codesign $FLUTTER_ADDITIONAL_FLAGS
flutter build ios --"$BUILD_TYPE" --build-name="$VERSIONNUMBER" --build-number="$BUILDNUMBER" --no-codesign $FLUTTER_ADDITIONAL_FLAGS

