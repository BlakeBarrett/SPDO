#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QLocale>
#include <QTranslator>
#include <QQmlContext>
#include "spdo.h"

int main(int argc, char *argv[])
{
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

    // Register for QML
    qmlRegisterSingletonInstance("com.blakebarrett.spdo", 1, 0, "SpeedReader", &speedReader);

    QQmlApplicationEngine engine;

    // Expose translator to QML
    engine.rootContext()->setContextProperty("currentLocale", QLocale::system().name());

    const QUrl url(u"qrc:/SPDO/Main.qml"_qs);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl)
                     {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}