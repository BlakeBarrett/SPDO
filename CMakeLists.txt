cmake_minimum_required(VERSION 3.16)

# Set the path to your Qt installation
# Platform-specific paths handled via conditional logic
if(APPLE)
    # Default macOS Qt location
    set(CMAKE_PREFIX_PATH "/Users/Blake/Qt/6.9.0/macos")
else()
    # Linux Qt location
    set(CMAKE_PREFIX_PATH "/media/ntfs/Users/Blake/Qt/6.9.0/gcc_64")
endif()

project(SPDO VERSION 2.0 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required Qt components
find_package(Qt6 REQUIRED COMPONENTS Quick Qml Gui)

qt_standard_project_setup(REQUIRES 6.9)

# Copy Main.qml directly to the build directory
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Main.qml ${CMAKE_CURRENT_BINARY_DIR}/Main.qml COPYONLY)

# Instead of using qt_add_resources, let's use file(COPY) to copy assets to the build directory
set(ASSETS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/assets")
set(BUILD_ASSETS_DIR "${CMAKE_CURRENT_BINARY_DIR}/assets")

# Make sure the destination directory exists
file(MAKE_DIRECTORY ${BUILD_ASSETS_DIR})

# Copy the assets to the build directory
file(COPY ${ASSETS_DIR}/ DESTINATION ${BUILD_ASSETS_DIR})

# Change the target name to SPDO_APP
qt_add_executable(SPDO_APP
    main.cpp
    spdo.cpp
    spdo.h
)

# Set the output name to "SPDO_exe" to avoid conflicts with directories
set_target_properties(SPDO_APP PROPERTIES OUTPUT_NAME "SPDO_exe")

qt_add_qml_module(SPDO_APP
    URI SPDO
    VERSION 2.0
    QML_FILES
        Main.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(SPDO_APP PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.blakebarrett.spdo
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# Include the Info.plist file for macOS
if(APPLE)
    set_target_properties(SPDO_APP PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
    )
endif()

target_link_libraries(SPDO_APP
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS SPDO_APP
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install assets alongside the executable
install(DIRECTORY ${ASSETS_DIR}/ 
    DESTINATION ${CMAKE_INSTALL_BINDIR}/assets
)