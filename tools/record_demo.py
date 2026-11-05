"""Record a 24-second GIF from the actual public component example. Requires Pillow."""
import io
import sys
from pathlib import Path
from PIL import Image
from PyQt6.QtCore import QBuffer, QIODevice, QObject, QPointF, Qt, QTimer, QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQuick import QQuickView
from PyQt6.QtTest import QTest

root_dir = Path(__file__).resolve().parents[1]
app = QGuiApplication([])
view = QQuickView()
view.setSource(QUrl.fromLocalFile(str(root_dir / 'examples/Minimal.qml')))
view.show()
frames = []
result = [0]
def record():
    try:
        root = view.rootObject()
        button = root.findChild(QObject, 'button')
        slider = root.findChild(QObject, 'slider')
        def pos(item, fraction=.5):
            return item.mapToScene(QPointF(item.width()*fraction, item.height()/2)).toPoint()
        def click(name):
            QTest.mouseClick(view, Qt.MouseButton.LeftButton, pos=pos(root.findChild(QObject, name)))
        for frame in range(192):
            if frame == 8:
                root.setProperty('demonstration', '按压反馈 · 背景折射')
                QTest.mousePress(view, Qt.MouseButton.LeftButton, pos=pos(button))
            if frame == 16:
                QTest.mouseRelease(view, Qt.MouseButton.LeftButton, pos=pos(button))
            if frame == 32:
                click('switch')
            if frame == 48:
                root.setProperty('demonstration', '滑块拖动 · 进度同步')
                QTest.mousePress(view, Qt.MouseButton.LeftButton, pos=pos(slider))
            if 48 <= frame < 72:
                QTest.mouseMove(view, pos(slider, .15 + (frame-48)/24*.7))
            if frame == 72:
                QTest.mouseRelease(view, Qt.MouseButton.LeftButton, pos=pos(slider, .85))
            if frame == 88:
                click('themeSwitch')
                root.setProperty('demonstration', '深色主题 · 清晰文字')
            if frame == 112:
                QTest.mousePress(view, Qt.MouseButton.LeftButton, pos=pos(button))
            if frame == 120:
                QTest.mouseRelease(view, Qt.MouseButton.LeftButton, pos=pos(button))
            if frame == 136:
                click('effectsSwitch')
                root.setProperty('demonstration', '关闭效果 · 保留交互')
            if frame == 160:
                click('effectsSwitch')
                click('themeSwitch')
                root.setProperty('demonstration', 'Qt Quick · 四种公开控件')
            QTest.qWait(125)
            shot = view.grabWindow()
            assert not shot.isNull() and not root.property('shaderError')
            buffer = QBuffer()
            buffer.open(QIODevice.OpenModeFlag.WriteOnly)
            shot.save(buffer, 'PNG')
            picture = Image.open(io.BytesIO(bytes(buffer.data()))).convert('RGB')
            picture.thumbnail((800, 640))
            frames.append(picture)
        output = root_dir / 'docs/demo.gif'
        frames[0].save(output, save_all=True, append_images=frames[1:], duration=125, loop=0, optimize=True)
        frames[0].save(root_dir / 'docs/minimal.png')
        print(f'Recorded {len(frames)} frames, 24 seconds: {output.name}')
    except Exception as exc:
        result[0] = 1
        print(repr(exc), file=sys.stderr)
    finally:
        view.close()
        app.quit()
QTimer.singleShot(800, record)
app.exec()
raise SystemExit(result[0])
