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
    // 1. Bundled/sibling executable.
    const QString siblingMpv =
        QCoreApplication::applicationDirPath() + "/mpv";

    if (const QString path = executableIfValid(siblingMpv);
        !path.isEmpty())
        return path;

    // 2. Normal shell/application PATH.
    const QString pathMpv = QStandardPaths::findExecutable("mpv");
    if (!pathMpv.isEmpty())
        return pathMpv;

#ifdef Q_OS_MACOS
    // 3. Common Homebrew locations. GUI applications can inherit a more
    // restricted PATH than an interactive shell.
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
