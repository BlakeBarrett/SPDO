cmake_minimum_required(VERSION 3.16)

# Set the path to your Qt installation
# Adjust this path based on your actual Qt installation location
set(CMAKE_PREFIX_PATH "/Volumes/Macintosh SSD/Blake/Qt/6.9.0/macos")

project(SPDO VERSION 2.0 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
 
# Find required Qt components - removing Positioning as it's not installed
find_package(Qt6 REQUIRED COMPONENTS Quick QuickEffects LinguistTools)

qt_standard_project_setup(REQUIRES 6.9) # Changed from 6.8 to 6.4 to match your Qt version

# Set up assets directory - modified to use file() command with QT_RESOURCE_ALIAS property
set(ASSETS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/assets")

# Define the assets individually to set the resource alias
set(APP_ASSETS
    "${ASSETS_DIR}/car-cruise-control.svg"
    "${ASSETS_DIR}/icon.png"
    "${ASSETS_DIR}/icon.svg"
    "${ASSETS_DIR}/max-speed.svg"
    "${ASSETS_DIR}/numeric.svg"
    "${ASSETS_DIR}/wiper.svg"
)

# Get all translation source files
file(GLOB TS_FILES "${CMAKE_SOURCE_DIR}/translations/*.ts")

# Set up Qt Linguist tools
qt_add_translations(SPDO
    TS_FILES ${TS_FILES}
    QM_FILES_OUTPUT_VARIABLE QM_FILES
    SOURCES 
        main.cpp
        spdo.cpp
        spdo.h
        Main.qml
)

# Add the QM files to the resources
qt_add_resources(TRANSLATIONRESOURCES
    PREFIX "/translations"
    FILES ${QM_FILES})

qt_add_executable(SPDO
    main.cpp
    spdo.cpp
    spdo.h
    ${TRANSLATIONRESOURCES}
)

# Set resource alias for each asset file
foreach(ASSET_FILE ${APP_ASSETS})
    get_filename_component(ASSET_NAME ${ASSET_FILE} NAME)
    set_source_files_properties(${ASSET_FILE} PROPERTIES QT_RESOURCE_ALIAS "assets/${ASSET_NAME}")
endforeach()

qt_add_qml_module(SPDO
    URI SPDO
    VERSION 2.0
    QML_FILES
        Main.qml
    RESOURCES
        ${APP_ASSETS}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(SPDO PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.blakebarrett.spdo
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# Include the Info.plist file for macOS
if(APPLE)
    set_target_properties(SPDO PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
    )
endif()

target_link_libraries(SPDO
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickEffects
)

include(GNUInstallDirs)
install(TARGETS SPDO
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)