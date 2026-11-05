"""Interactive public-component example; tests require a real GPU backend."""
import argparse
import sys
from pathlib import Path

from PyQt6.QtCore import QTimer, QUrl, QtMsgType, qInstallMessageHandler
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQuick import QQuickView


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument('--test', action='store_true')
    parser.add_argument('--output', type=Path, default=Path('data/verification'))
    args = parser.parse_args()
    messages = []
    def message(kind, context, text):
        print(text, file=sys.stderr)
        if kind in (QtMsgType.QtWarningMsg, QtMsgType.QtCriticalMsg, QtMsgType.QtFatalMsg):
            messages.append(text)
    qInstallMessageHandler(message)
    app = QGuiApplication(sys.argv[:1])
    view = QQuickView()
    view.setTitle('Qt Liquid Glass')
    view.setResizeMode(QQuickView.ResizeMode.SizeRootObjectToView)
    view.setSource(QUrl.fromLocalFile(str(Path(__file__).with_name('Minimal.qml').resolve())))
    if view.errors():
        raise SystemExit(str(view.errors()))
    view.show()
    result = [0]
    if args.test:
        # Import only our repository's test runner, never the parent application.
        sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tests'))
        from verify import verify
        def run():
            result[0] = verify(view, messages, args.output)
            view.close()
            app.quit()
        QTimer.singleShot(800, run)
    app.exec()
    return result[0]


if __name__ == '__main__':
    raise SystemExit(main())
