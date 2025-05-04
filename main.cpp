#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "spdo.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set organization and application names for QSettings
    app.setOrganizationName("BlakeBarrett");
    app.setOrganizationDomain("blakebarrett.com");
    app.setApplicationName("SPDO");

    // Create the SpeedReader instance
    SpeedReader speedReader;

    QQmlApplicationEngine engine;

    // Register the SpeedReader class to QML
    engine.rootContext()->setContextProperty("speedReader", &speedReader);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("SPDO", "Main");

    // Start the demo mode by default
    speedReader.startDemo();

    return app.exec();
}