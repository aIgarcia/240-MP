#include "MpvLocator.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>

namespace mpvbin {

static QString executableIfValid(const QString &path)
{
    const QFileInfo info(path);
    return info.isFile() && info.isExecutable() ? path : QString();
}

QString locate()
{
    const QString siblingMpv =
        QCoreApplication::applicationDirPath() + "/mpv";

    if (const QString path = executableIfValid(siblingMpv);
        !path.isEmpty())
        return path;

    const QString pathMpv = QStandardPaths::findExecutable("mpv");
    if (!pathMpv.isEmpty())
        return pathMpv;

#ifdef Q_OS_MACOS
    const QString candidates[] = {
        "/usr/local/bin/mpv",
        "/opt/homebrew/bin/mpv",
        "/Applications/mpv.app/Contents/MacOS/mpv",
        QDir::homePath() +
            "/Applications/mpv.app/Contents/MacOS/mpv"
    };

    for (const QString &candidate : candidates) {
        if (const QString path = executableIfValid(candidate);
            !path.isEmpty())
            return path;
    }
#endif

    return {};
}

} // namespace mpvbin
