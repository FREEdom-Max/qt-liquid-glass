"""Run from any working directory; --test checks the actual public controls."""
import sys
from pathlib import Path
from PyQt6.QtCore import QUrl, QTimer, QObject, Qt, QPointF, qInstallMessageHandler
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQuick import QQuickView
from PyQt6.QtTest import QTest

errors = []
def message(kind, context, text):
    print(text, file=sys.stderr)
    if 'qml' in text.lower() or 'shader' in text.lower():
        errors.append(text)

qInstallMessageHandler(message)
app = QGuiApplication(sys.argv[:1])
view = QQuickView()
view.setResizeMode(QQuickView.ResizeMode.SizeRootObjectToView)
view.setSource(QUrl.fromLocalFile(str(Path(__file__).with_name('Minimal.qml'))))
if view.errors():
    raise SystemExit(str(view.errors()))
view.show()
result = [0]
def verify():
    try:
        root = view.rootObject()
        def control(name):
            return root.findChild(QObject, name)
        def click(item):
            point = item.mapToScene(QPointF(item.width()/2, item.height()/2))
            QTest.mouseClick(view, Qt.MouseButton.LeftButton, pos=point.toPoint())
        button = control('button')
        click(button)
        assert root.property('clicks') == 1
        button.setProperty('enabled', False)
        click(button)
        assert root.property('clicks') == 1
        button.setProperty('enabled', True)
        button.forceActiveFocus()
        QTest.keyClick(view, Qt.Key.Key_Space)
        assert root.property('clicks') == 2
        switch = control('switch')
        click(switch)
        assert switch.property('checked')
        slider = control('slider')
        slider.forceActiveFocus()
        QTest.keyClick(view, Qt.Key.Key_Right)
        assert slider.property('value') > 50
        assert abs(control('progress').property('value') - slider.property('value') / 100) < .001
        for dark in (True, False):
            root.setProperty('whiteInk', dark)
            view.resize(900 if dark else 800, 600)
            QTest.qWait(150)
            assert not view.grabWindow().isNull()
        root.setProperty('effectsEnabled', False)
        click(button)
        assert root.property('clicks') == 3
        assert not root.property('shaderError'), root.property('shaderError')
        assert not errors, errors
        print('PASS: public controls, disabled button, keyboard, progress, themes, resize, fallback')
    except Exception as exc:
        result[0] = 1
        print('FAIL:', repr(exc), file=sys.stderr)
    finally:
        app.quit()
if '--test' in sys.argv:
    QTimer.singleShot(800, verify)
app.exec()
raise SystemExit(result[0])
