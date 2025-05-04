#include "spdo.h"
#include <QDebug>
#include <QtMath>
#include <QCoreApplication>
#include <QRandomGenerator>

// Define version constants from CMake
#define PROJECT_VERSION_MAJOR 0
#define PROJECT_VERSION_MINOR 1

SpeedReader::SpeedReader(QObject *parent)
    : QObject(parent), m_settings(QSettings::IniFormat, QSettings::UserScope,
                                  QCoreApplication::organizationName(), QCoreApplication::applicationName())
{
    // Set application name and version from CMake project configuration
    m_appName = QCoreApplication::applicationName();
    m_appVersion = QString("%1.%2").arg(PROJECT_VERSION_MAJOR).arg(PROJECT_VERSION_MINOR);

    // Initialize demo timer
    m_demoTimer = new QTimer(this);
    connect(m_demoTimer, &QTimer::timeout, this, &SpeedReader::demoUpdate);

    // Initialize fake GPS timer with more frequent updates
    m_fakeGpsTimer = new QTimer(this);
    m_fakeGpsTimer->setInterval(500); // 500ms for more responsive updates
    connect(m_fakeGpsTimer, &QTimer::timeout, this, [this]()
            {
        // Simulate more realistic GPS behavior with smoother speed changes
        static double targetSpeed = 0.0;
        static int stabilityCounter = 0;
        
        // Occasionally change the target speed
        if (stabilityCounter <= 0) {
            // Generate a new target speed with preference for lower speeds
            double rand = QRandomGenerator::global()->generateDouble();
            targetSpeed = pow(rand, 1.5) * m_maxSpeed; // Weighted toward lower speeds
            stabilityCounter = QRandomGenerator::global()->bounded(5, 20); // Hold speed for 5-20 updates
        }
        stabilityCounter--;
        
        // Gradually move current speed toward target speed (smoother acceleration/deceleration)
        double currentSpeedMs = m_speed / 3.6; // Convert km/h to m/s
        double targetSpeedMs = targetSpeed / 3.6;
        double speedDiff = targetSpeedMs - currentSpeedMs;
        
        // Apply acceleration limits (typical car can accelerate at ~2.5 m/s²)
        double maxAccelStep = 1.25 * 0.5; // 1.25 m/s² * 0.5s interval
        if (speedDiff > maxAccelStep) 
            speedDiff = maxAccelStep;
        else if (speedDiff < -maxAccelStep) 
            speedDiff = -maxAccelStep;
            
        double newSpeedMs = currentSpeedMs + speedDiff;
        if (newSpeedMs < 0) newSpeedMs = 0;
        
        // Add small random noise for realism
        newSpeedMs += (QRandomGenerator::global()->generateDouble() - 0.5) * 0.5;
        if (newSpeedMs < 0) newSpeedMs = 0;
        
        locationUpdate(newSpeedMs); });

    // Load saved settings or use defaults
    loadSettings();

    // Update display text based on current speed and units
    updateDisplayText();
}

SpeedReader::~SpeedReader()
{
    saveSettings();

    if (m_demoTimer)
    {
        m_demoTimer->stop();
    }

    if (m_fakeGpsTimer)
    {
        m_fakeGpsTimer->stop();
    }
}

void SpeedReader::setTopSpeed(double topSpeed)
{
    if (qFuzzyCompare(m_topSpeed, topSpeed))
        return;

    m_topSpeed = topSpeed;
    emit topSpeedChanged();
}

void SpeedReader::setMetric(bool metric)
{
    if (m_metric == metric)
        return;

    m_metric = metric;
    updateDisplayText();
    emit metricChanged();
}

void SpeedReader::setMaxSpeed(int maxSpeed)
{
    if (m_maxSpeed == maxSpeed)
        return;

    m_maxSpeed = maxSpeed;
    emit maxSpeedChanged();
}

void SpeedReader::setShowDigital(bool showDigital)
{
    if (m_showDigital == showDigital)
        return;

    m_showDigital = showDigital;
    updateDisplayText();
    emit showDigitalChanged();
}

void SpeedReader::setShowAnalog(bool showAnalog)
{
    if (m_showAnalog == showAnalog)
        return;

    m_showAnalog = showAnalog;
    emit showAnalogChanged();
}

void SpeedReader::setShowTopSpeed(bool showTopSpeed)
{
    if (m_showTopSpeed == showTopSpeed)
        return;

    m_showTopSpeed = showTopSpeed;
    emit showTopSpeedChanged();
}

void SpeedReader::setBackgroundImagePath(const QString &path)
{
    if (m_backgroundImagePath == path)
        return;

    m_backgroundImagePath = path;
    emit backgroundImagePathChanged();
}

QString SpeedReader::formatSpeed(double spd, bool isMetric)
{
    return QString::number(qRound(spd)) + (isMetric ? "km/h" : "MPH");
}

void SpeedReader::saveSettings()
{
    m_settings.setValue("metric", m_metric);
    m_settings.setValue("maxSpeed", m_maxSpeed);
    m_settings.setValue("showDigital", m_showDigital);
    m_settings.setValue("showAnalog", m_showAnalog);
    m_settings.setValue("showTopSpeed", m_showTopSpeed);
    m_settings.setValue("backgroundImagePath", m_backgroundImagePath);
    m_settings.sync();
}

void SpeedReader::loadSettings()
{
    m_metric = m_settings.value("metric", false).toBool();
    m_maxSpeed = m_settings.value("maxSpeed", 35).toInt();
    m_showDigital = m_settings.value("showDigital", true).toBool();
    m_showAnalog = m_settings.value("showAnalog", true).toBool();
    m_showTopSpeed = m_settings.value("showTopSpeed", false).toBool();
    m_backgroundImagePath = m_settings.value("backgroundImagePath", "").toString();

    emit metricChanged();
    emit maxSpeedChanged();
    emit showDigitalChanged();
    emit showAnalogChanged();
    emit showTopSpeedChanged();
    emit backgroundImagePathChanged();
}

void SpeedReader::startDemo()
{
    m_fakeGpsTimer->stop();
    m_gpsActive = false;
    emit gpsActiveChanged();

    m_demoTimer->start(1000);
    m_gpsStatus = "Demo mode active";
}

void SpeedReader::stopDemo()
{
    m_demoTimer->stop();
}

void SpeedReader::startLocationUpdates()
{
    stopDemo();

    // In a real implementation, this would use a native location API
    // For now, we'll use a more realistic simulation
    m_gpsActive = true;
    m_gpsStatus = "GPS active (simulation)";
    emit gpsActiveChanged();

    m_fakeGpsTimer->start();
    qDebug() << "Simulated GPS updates started";
}

void SpeedReader::stopLocationUpdates()
{
    if (m_fakeGpsTimer->isActive())
    {
        m_fakeGpsTimer->stop();
        m_gpsActive = false;
        m_gpsStatus = "GPS inactive";
        emit gpsActiveChanged();
        qDebug() << "Simulated GPS updates stopped";
    }
}

QString SpeedReader::getGpsStatus() const
{
    return m_gpsStatus;
}

void SpeedReader::locationUpdate(double speedInMetersPerSecond)
{
    if (speedInMetersPerSecond < 0)
    {
        return;
    }

    // Always store speed internally in KPH for consistency
    double speedKph = msToKPH(speedInMetersPerSecond);

    // Store the raw KPH value internally
    updateSpeed(speedKph);
}

void SpeedReader::locationError(const QString &errorMessage)
{
    m_gpsStatus = "Error: " + errorMessage;
    qWarning() << "Location error:" << errorMessage;
}

void SpeedReader::demoUpdate()
{
    if (m_demoIncreasing)
    {
        m_speed += QRandomGenerator::global()->bounded(5) + 1;
        if (m_speed >= m_maxSpeed)
        {
            m_speed = m_maxSpeed;
            m_demoIncreasing = false;
        }
    }
    else
    {
        m_speed -= QRandomGenerator::global()->bounded(5) + 1;
        if (m_speed <= 0)
        {
            m_speed = 0;
            m_demoIncreasing = true;
        }
    }

    if (m_speed > m_topSpeed)
    {
        setTopSpeed(m_speed);
    }

    updateDisplayText();
    emit speedChanged();
}

void SpeedReader::updateSpeed(double speedValue)
{
    if (qFuzzyCompare(m_speed, speedValue))
        return;

    m_speed = speedValue;

    if (m_speed > m_topSpeed)
    {
        setTopSpeed(m_speed);
    }

    updateDisplayText();
    emit speedChanged();
}

void SpeedReader::updateDisplayText()
{
    if (m_showDigital)
    {
        // Format the speed based on current unit setting
        double displaySpeed = m_metric ? m_speed : kphToMPH(m_speed);
        m_displayText = formatSpeed(displaySpeed, m_metric);
    }
    else
    {
        m_displayText = "";
    }

    emit displayTextChanged();
}

double SpeedReader::msToKPH(double metersPerSecond)
{
    static const double secondsPerHour = 3600.0;
    return (metersPerSecond * secondsPerHour) / 1000.0;
}

double SpeedReader::kphToMPH(double kmph)
{
    return kmph / 1.609;
}