#!/bin/bash

# Markdown Editor Build Script
# Supports both macOS and iOS builds

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="MarkdownEditor"
BUNDLE_ID="com.yourcompany.markdowneditor"
VERSION="2.0"
BUILD_NUMBER="1"

# Directories
BUILD_DIR="build"
MACOS_BUILD_DIR="$BUILD_DIR/macos"
IOS_BUILD_DIR="$BUILD_DIR/ios"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Markdown Editor Build Script  ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}➤ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_requirements() {
    print_step "Checking build requirements..."
    
    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode is not installed or xcodebuild is not available"
        exit 1
    fi
    
    # Check if Swift is available
    if ! command -v swift &> /dev/null; then
        print_error "Swift is not available"
        exit 1
    fi
    
    print_success "All requirements satisfied"
}

create_project_structure() {
    print_step "Creating project structure..."
    
    # Create build directories
    mkdir -p "$MACOS_BUILD_DIR"
    mkdir -p "$IOS_BUILD_DIR"
    
    # Create Xcode project files
    create_project_pbxproj
    create_info_plist_macos
    create_info_plist_ios
    create_entitlements
    
    print_success "Project structure created"
}

create_project_pbxproj() {
    cat > "${APP_NAME}.xcodeproj/project.pbxproj" << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		0A1234567890ABCD /* main.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0A1234567890ABCE /* main.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		0A1234567890ABCE /* main.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = main.swift; sourceTree = "<group>"; };
		0A1234567890ABCF /* MarkdownEditor.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MarkdownEditor.app; sourceTree = BUILT_PRODUCTS_DIR; };
		0A1234567890ABD0 /* Info-macOS.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "Info-macOS.plist"; sourceTree = "<group>"; };
		0A1234567890ABD1 /* Info-iOS.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "Info-iOS.plist"; sourceTree = "<group>"; };
		0A1234567890ABD2 /* MarkdownEditor.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = MarkdownEditor.entitlements; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		0A1234567890ABD3 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		0A1234567890ABD4 = {
			isa = PBXGroup;
			children = (
				0A1234567890ABD5 /* MarkdownEditor */,
				0A1234567890ABD6 /* Products */,
			);
			sourceTree = "<group>";
		};
		0A1234567890ABD5 /* MarkdownEditor */ = {
			isa = PBXGroup;
			children = (
				0A1234567890ABCE /* main.swift */,
				0A1234567890ABD0 /* Info-macOS.plist */,
				0A1234567890ABD1 /* Info-iOS.plist */,
				0A1234567890ABD2 /* MarkdownEditor.entitlements */,
			);
			path = MarkdownEditor;
			sourceTree = "<group>";
		};
		0A1234567890ABD6 /* Products */ = {
			isa = PBXGroup;
			children = (
				0A1234567890ABCF /* MarkdownEditor.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		0A1234567890ABD7 /* MarkdownEditor-macOS */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 0A1234567890ABD8 /* Build configuration list for PBXNativeTarget "MarkdownEditor-macOS" */;
			buildPhases = (
				0A1234567890ABD9 /* Sources */,
				0A1234567890ABD3 /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = "MarkdownEditor-macOS";
			productName = MarkdownEditor;
			productReference = 0A1234567890ABCF /* MarkdownEditor.app */;
			productType = "com.apple.product-type.application";
		};
		0A1234567890ABDA /* MarkdownEditor-iOS */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 0A1234567890ABDB /* Build configuration list for PBXNativeTarget "MarkdownEditor-iOS" */;
			buildPhases = (
				0A1234567890ABD9 /* Sources */,
				0A1234567890ABD3 /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = "MarkdownEditor-iOS";
			productName = MarkdownEditor;
			productReference = 0A1234567890ABCF /* MarkdownEditor.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		0A1234567890ABDC /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					0A1234567890ABD7 = {
						CreatedOnToolsVersion = 15.0;
					};
					0A1234567890ABDA = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = 0A1234567890ABDD /* Build configuration list for PBXProject "MarkdownEditor" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 0A1234567890ABD4;
			productRefGroup = 0A1234567890ABD6 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				0A1234567890ABD7 /* MarkdownEditor-macOS */,
				0A1234567890ABDA /* MarkdownEditor-iOS */,
			);
		};
/* End PBXProject section */

/* Begin PBXSourcesBuildPhase section */
		0A1234567890ABD9 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				0A1234567890ABCD /* main.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		0A1234567890ABDE /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		0A1234567890ABDF /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
			};
			name = Release;
		};
		0A1234567890ABE0 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = MarkdownEditor.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "Info-macOS.plist";
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INFOPLIST_KEY_NSMainStoryboardFile = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 11.0;
				MARKETING_VERSION = 2.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.markdowneditor;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		0A1234567890ABE1 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = MarkdownEditor.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "Info-macOS.plist";
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INFOPLIST_KEY_NSMainStoryboardFile = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 11.0;
				MARKETING_VERSION = 2.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.markdowneditor;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
		0A1234567890ABE2 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "Info-iOS.plist";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 14.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 2.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.markdowneditor;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		0A1234567890ABE3 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "Info-iOS.plist";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 14.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 2.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.markdowneditor;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		0A1234567890ABD8 /* Build configuration list for PBXNativeTarget "MarkdownEditor-macOS" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				0A1234567890ABE0 /* Debug */,
				0A1234567890ABE1 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		0A1234567890ABDB /* Build configuration list for PBXNativeTarget "MarkdownEditor-iOS" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				0A1234567890ABE2 /* Debug */,
				0A1234567890ABE3 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		0A1234567890ABDD /* Build configuration list for PBXProject "MarkdownEditor" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				0A1234567890ABDE /* Debug */,
				0A1234567890ABDF /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 0A1234567890ABDC /* Project object */;
}
EOF

    mkdir -p "${APP_NAME}.xcodeproj"
}

create_info_plist_macos() {
    cat > "Info-macOS.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>markdown-viewer</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$BUILD_NUMBER</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>This app uses the microphone for voice-to-text transcription when editing markdown documents.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>This app uses speech recognition to convert voice commands into markdown formatting.</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeIconFiles</key>
            <array/>
            <key>CFBundleTypeName</key>
            <string>Markdown Document</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSHandlerRank</key>
            <string>Owner</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>net.daringfireball.markdown</string>
                <string>public.plain-text</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF
}

create_info_plist_ios() {
    cat > "Info-iOS.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleExecutable</key>
    <string>markdown-viewer</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$BUILD_NUMBER</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>This app uses the microphone for voice-to-text transcription when editing markdown documents.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>This app uses speech recognition to convert voice commands into markdown formatting.</string>
    <key>UILaunchScreen</key>
    <dict>
        <key>UIColorName</key>
        <string>AccentColor</string>
        <key>UIImageName</key>
        <string>LaunchIcon</string>
    </dict>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Markdown Document</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSHandlerRank</key>
            <string>Owner</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>net.daringfireball.markdown</string>
                <string>public.plain-text</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF
}

create_entitlements() {
    cat > "${APP_NAME}.entitlements" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.device.microphone</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
EOF
}

build_macos() {
    print_step "Building macOS application..."
    
    # Create macOS app bundle structure
    MACOS_APP_PATH="$MACOS_BUILD_DIR/${APP_NAME}.app"
    MACOS_CONTENTS_PATH="$MACOS_APP_PATH/Contents"
    MACOS_MACOS_PATH="$MACOS_CONTENTS_PATH/MacOS"
    MACOS_RESOURCES_PATH="$MACOS_CONTENTS_PATH/Resources"
    
    mkdir -p "$MACOS_MACOS_PATH"
    mkdir -p "$MACOS_RESOURCES_PATH"
    
    # Copy Info.plist
    cp "Info-macOS.plist" "$MACOS_CONTENTS_PATH/Info.plist"
    
    # Compile Swift code for macOS
    print_info "Compiling Swift source for macOS..."
    
    # Use swiftc to compile the main.swift file
    swiftc -target x86_64-apple-macos11.0 \
           -import-objc-header /dev/null \
           -framework SwiftUI \
           -framework WebKit \
           -framework Speech \
           -framework AVFoundation \
           -framework AppKit \
           -o "$MACOS_MACOS_PATH/markdown-viewer" \
           main.swift
    
    if [ $? -eq 0 ]; then
        print_success "macOS build completed successfully"
        print_info "macOS app bundle: $MACOS_APP_PATH"
    else
        print_error "macOS build failed"
        return 1
    fi
}

build_ios() {
    print_step "Building iOS application..."
    
    print_info "Creating iOS build using xcodebuild..."
    
    # Note: For iOS builds, we need to use xcodebuild with proper project setup
    # This is a simplified version - a full iOS build would require proper Xcode project
    
    if command -v xcodebuild &> /dev/null; then
        # Create iOS simulator build
        print_info "Building for iOS Simulator..."
        
        xcodebuild -project "${APP_NAME}.xcodeproj" \
                   -target "MarkdownEditor-iOS" \
                   -sdk iphonesimulator \
                   -configuration Debug \
                   -derivedDataPath "$IOS_BUILD_DIR" \
                   build
        
        if [ $? -eq 0 ]; then
            print_success "iOS build completed successfully"
            print_info "iOS build output: $IOS_BUILD_DIR"
        else
            print_error "iOS build failed"
            return 1
        fi
    else
        print_error "xcodebuild not found. iOS build requires Xcode."
        return 1
    fi
}

build_simple_macos() {
    print_step "Building simple macOS executable..."
    
    # Simple build without app bundle for testing
    swiftc -target x86_64-apple-macos11.0 \
           -framework SwiftUI \
           -framework WebKit \
           -framework Speech \
           -framework AVFoundation \
           -framework AppKit \
           -o "$MACOS_BUILD_DIR/markdown-editor" \
           main.swift
    
    if [ $? -eq 0 ]; then
        print_success "Simple macOS executable built successfully"
        print_info "Executable: $MACOS_BUILD_DIR/markdown-editor"
        chmod +x "$MACOS_BUILD_DIR/markdown-editor"
    else
        print_error "Simple macOS build failed"
        return 1
    fi
}

package_release() {
    print_step "Packaging release builds..."
    
    # Create release directory
    RELEASE_DIR="release"
    mkdir -p "$RELEASE_DIR"
    
    # Package macOS app
    if [ -d "$MACOS_BUILD_DIR/${APP_NAME}.app" ]; then
        print_info "Creating macOS DMG..."
        
        # Create a simple DMG (requires hdiutil on macOS)
        if command -v hdiutil &> /dev/null; then
            hdiutil create -srcfolder "$MACOS_BUILD_DIR/${APP_NAME}.app" \
                          -volname "$APP_NAME" \
                          "$RELEASE_DIR/${APP_NAME}-macOS-v${VERSION}.dmg"
            
            print_success "macOS DMG created: $RELEASE_DIR/${APP_NAME}-macOS-v${VERSION}.dmg"
        else
            # Fallback to ZIP
            (cd "$MACOS_BUILD_DIR" && zip -r "../$RELEASE_DIR/${APP_NAME}-macOS-v${VERSION}.zip" "${APP_NAME}.app")
            print_success "macOS ZIP created: $RELEASE_DIR/${APP_NAME}-macOS-v${VERSION}.zip"
        fi
    fi
    
    # Package iOS app (if exists)
    if [ -d "$IOS_BUILD_DIR" ]; then
        (cd "$IOS_BUILD_DIR" && zip -r "../$RELEASE_DIR/${APP_NAME}-iOS-v${VERSION}.zip" .)
        print_success "iOS ZIP created: $RELEASE_DIR/${APP_NAME}-iOS-v${VERSION}.zip"
    fi
}

clean() {
    print_step "Cleaning build directories..."
    
    rm -rf "$BUILD_DIR"
    rm -rf "release"
    rm -f "${APP_NAME}.xcodeproj/project.pbxproj"
    rm -f "Info-macOS.plist"
    rm -f "Info-iOS.plist"
    rm -f "${APP_NAME}.entitlements"
    
    print_success "Clean completed"
}

show_usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  macos          Build for macOS only"
    echo "  ios            Build for iOS only (requires Xcode)"
    echo "  both           Build for both platforms"
    echo "  simple         Build simple macOS executable (no app bundle)"
    echo "  package        Package release builds"
    echo "  clean          Clean all build artifacts"
    echo "  help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./build.sh macos          # Build macOS app"
    echo "  ./build.sh simple         # Build simple executable"
    echo "  ./build.sh both package   # Build both platforms and package"
    echo ""
}

main() {
    print_header
    
    if [ $# -eq 0 ]; then
        show_usage
        exit 0
    fi
    
    check_requirements
    
    for arg in "$@"; do
        case $arg in
            macos)
                create_project_structure
                build_macos
                ;;
            ios)
                create_project_structure
                build_ios
                ;;
            both)
                create_project_structure
                build_macos
                build_ios
                ;;
            simple)
                mkdir -p "$BUILD_DIR"
                build_simple_macos
                ;;
            package)
                package_release
                ;;
            clean)
                clean
                ;;
            help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $arg"
                show_usage
                exit 1
                ;;
        esac
    done
    
    echo ""
    print_success "Build script completed!"
}

# Run main function with all arguments
main "$@"