#ifndef SPDO_H
#define SPDO_H

#include <QObject>
#include <QTimer>
#include <QSettings>

// Forward declaration of platform-specific location service class (to be implemented later)
class LocationService;

class SpeedReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(double topSpeed READ topSpeed WRITE setTopSpeed NOTIFY topSpeedChanged)
    Q_PROPERTY(bool metric READ metric WRITE setMetric NOTIFY metricChanged)
    Q_PROPERTY(int maxSpeed READ maxSpeed WRITE setMaxSpeed NOTIFY maxSpeedChanged)
    Q_PROPERTY(bool showDigital READ showDigital WRITE setShowDigital NOTIFY showDigitalChanged)
    Q_PROPERTY(bool showAnalog READ showAnalog WRITE setShowAnalog NOTIFY showAnalogChanged)
    Q_PROPERTY(bool showTopSpeed READ showTopSpeed WRITE setShowTopSpeed NOTIFY showTopSpeedChanged)
    Q_PROPERTY(QString displayText READ displayText NOTIFY displayTextChanged)
    Q_PROPERTY(QString backgroundImagePath READ backgroundImagePath WRITE setBackgroundImagePath NOTIFY backgroundImagePathChanged)
    Q_PROPERTY(bool gpsActive READ gpsActive NOTIFY gpsActiveChanged)
    Q_PROPERTY(QString appName READ appName CONSTANT)
    Q_PROPERTY(QString appVersion READ appVersion CONSTANT)

public:
    explicit SpeedReader(QObject *parent = nullptr);
    ~SpeedReader();

    // Property getters
    double speed() const { return m_speed; }
    double topSpeed() const { return m_topSpeed; }
    bool metric() const { return m_metric; }
    int maxSpeed() const { return m_maxSpeed; }
    bool showDigital() const { return m_showDigital; }
    bool showAnalog() const { return m_showAnalog; }
    bool showTopSpeed() const { return m_showTopSpeed; }
    QString displayText() const { return m_displayText; }
    QString backgroundImagePath() const { return m_backgroundImagePath; }
    bool gpsActive() const { return m_gpsActive; }
    QString appName() const { return m_appName; }
    QString appVersion() const { return m_appVersion; }

    // Property setters - add Q_INVOKABLE to ensure they're accessible from QML
    Q_INVOKABLE void setTopSpeed(double topSpeed);
    Q_INVOKABLE void setMetric(bool metric);
    Q_INVOKABLE void setMaxSpeed(int maxSpeed);
    Q_INVOKABLE void setShowDigital(bool showDigital);
    Q_INVOKABLE void setShowAnalog(bool showAnalog);
    Q_INVOKABLE void setShowTopSpeed(bool showTopSpeed);
    Q_INVOKABLE void setBackgroundImagePath(const QString &path);

    // Helper methods exposed to QML
    Q_INVOKABLE void resetTopSpeed() { setTopSpeed(0.0); }
    Q_INVOKABLE QString formatSpeed(double spd, bool isMetric);
    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void loadSettings();
    Q_INVOKABLE void startDemo();
    Q_INVOKABLE void stopDemo();
    Q_INVOKABLE void startLocationUpdates();
    Q_INVOKABLE void stopLocationUpdates();
    Q_INVOKABLE QString getGpsStatus() const;

signals:
    void speedChanged();
    void topSpeedChanged();
    void metricChanged();
    void maxSpeedChanged();
    void showDigitalChanged();
    void showAnalogChanged();
    void showTopSpeedChanged();
    void displayTextChanged();
    void backgroundImagePathChanged();
    void gpsActiveChanged();

private slots:
    void demoUpdate();
    void locationUpdate(double speedInMetersPerSecond);
    void locationError(const QString &errorMessage);

private:
    void updateDisplayText();
    double msToKPH(double metersPerSecond);
    double kphToMPH(double kmph);
    void updateSpeed(double speedValue);

    QTimer *m_demoTimer = nullptr;
    QTimer *m_fakeGpsTimer = nullptr; // Temporary timer to simulate GPS updates
    QSettings m_settings;

    double m_speed = 0.0;
    double m_topSpeed = 0.0;
    bool m_metric = false;
    int m_maxSpeed = 35; // Default max speed value
    bool m_showDigital = true;
    bool m_showAnalog = true;
    bool m_showTopSpeed = false;
    QString m_displayText;
    QString m_backgroundImagePath;
    bool m_demoIncreasing = true;
    bool m_gpsActive = false;
    QString m_gpsStatus = "GPS not active";
    QString m_appName = "Speedometer";
    QString m_appVersion = "1.0.0";
};

#endif // SPDO_H