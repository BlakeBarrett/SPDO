#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QLocale>
#include <QTranslator>
#include <QQmlContext>
#include <QQuickWindow> // Add window capabilities explicitly
#include "spdo.h"

int main(int argc, char *argv[])
{
    // Set environment variable to tell Qt to use native window decorations
    qputenv("QT_QUICK_CONTROLS_STYLE", "Fusion");
    
    // Enable high DPI scaling
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    
    QGuiApplication app(argc, argv);

    // Set up application information
    app.setOrganizationName("Blake Barrett");
    app.setOrganizationDomain("blakebarrett.com");
    app.setApplicationName("SPDO");

    // Load translations based on system locale
    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages)
    {
        const QString baseName = "spdo_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName))
        {
            app.installTranslator(&translator);
            break;
        }
    }

    // Create our SpeedReader object
    SpeedReader speedReader;

    // Register for QML using uppercase name as required by QML
    // Update to version 2.0 to match Main.qml import
    qmlRegisterSingletonInstance("com.blakebarrett.spdo", 2, 0, "SpeedReader", &speedReader);

    QQmlApplicationEngine engine;

    // Expose translator to QML
    engine.rootContext()->setContextProperty("currentLocale", QLocale::system().name());

    // Use a direct path to Main.qml that's now in the build directory
    const QUrl url(QStringLiteral("Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl)
                     {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    
    engine.load(url);

    return app.exec();
}