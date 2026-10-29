"""Standalone QML material lab. No JMViewer imports or persisted settings.

python examples/glass_lab.py                 # interactive
python examples/glass_lab.py --capture      # screenshots and GPU/input checks
python examples/glass_lab.py --image PATH   # add a photographic background
"""

import argparse
import json
import sys
from pathlib import Path

from PyQt6.QtCore import QPoint, Qt, QTimer, QUrl
from PyQt6.QtGui import QColor, QFont, QGuiApplication
from PyQt6.QtQuick import QQuickView
from PyQt6.QtTest import QTest

parser = argparse.ArgumentParser(__doc__)
parser.add_argument('--capture', action='store_true')
parser.add_argument('--image')
parser.add_argument('--output', default='data/glass_lab')
args = parser.parse_args()
app = QGuiApplication(sys.argv[:1])
font = QFont('Microsoft YaHei UI', 10)
font.setWeight(QFont.Weight.DemiBold)
app.setFont(font)
view = QQuickView()
view.setTitle('Glass Lab - QML material comparison')
view.setResizeMode(QQuickView.ResizeMode.SizeRootObjectToView)
view.setSource(QUrl.fromLocalFile(str(Path(__file__).parent / 'glass_lab/Main.qml')))
if view.status() == QQuickView.Status.Error:
    raise SystemExit('\n'.join(e.toString() for e in view.errors()))
view.resize(1280, 940)
root = view.rootObject()
if args.image:
    root.setProperty(
        'externalImage', QUrl.fromLocalFile(str(Path(args.image).resolve())).toString()
    )
    root.setProperty('backgroundMode', 3)
view.show()
results = {}


def find_pane(name):
    pending = [root]
    while pending:
        item = pending.pop()
        if item.objectName() == name:
            return item
        pending.extend(item.childItems())
    return None


def press_at(point):
    QTest.mouseMove(view, point)
    QTest.qWait(40)
    QTest.mousePress(view, Qt.MouseButton.LeftButton, pos=point)


def verify():
    out = Path(args.output)
    out.mkdir(parents=True, exist_ok=True)
    try:
        QTest.qWait(250)
        assert not root.property('shaderError'), root.property('shaderError')
        assert view.isExposed()
        results['graphics_api'] = str(view.rendererInterface().graphicsApi())
        results['dpr'] = view.devicePixelRatio()
        root.setProperty('backgroundMode', 1)
        QTest.qWait(250)
        bent = view.grabWindow()
        assert not bent.isNull()
        bent.save(str(out / 'grid-on.png'))
        root.setProperty('bendEnabled', False)
        QTest.qWait(250)
        flat = view.grabWindow()
        flat.save(str(out / 'grid-off.png'))
        assert bent != flat, 'Refraction must alter output'
        results['refraction_pixels_differ'] = True
        root.setProperty('bendEnabled', True)
        root.setProperty('chromatic', False)
        QTest.qWait(250)
        achromatic = view.grabWindow()
        assert bent != achromatic, 'Dispersion must alter output'
        achromatic.save(str(out / 'grid-no-dispersion.png'))
        results['dispersion_pixels_differ'] = True
        root.setProperty('chromatic', True)
        for mode, name in [(0, 'landscape'), (2, 'text')]:
            root.setProperty('backgroundMode', mode)
            QTest.qWait(250)
            view.grabWindow().save(str(out / (name + '.png')))
        for scheme, name in [(0, 'light-glass'), (1, 'dim-white')]:
            root.setProperty('readabilityMode', scheme)
            for mode, bgname in [(0, 'landscape'), (1, 'grid'), (2, 'text')]:
                root.setProperty('backgroundMode', mode)
                QTest.qWait(300)
                view.grabWindow().save(str(out / (name + '-' + bgname + '.png')))
        root.setProperty('readabilityMode', 0)
        root.setProperty('night', True)
        QTest.qWait(250)
        view.grabWindow().save(str(out / 'dark.png'))
        root.setProperty('night', False)
        root.setProperty('backgroundMode', 0)
        # QWindow input exercises actual QML hit testing.
        first = find_pane('tier0')
        assert first is not None
        assert [find_pane('tier' + str(i)).property('amount') for i in range(3)] == [
            10.0,
            19.0,
            28.0,
        ]
        before = first.property('taps')
        button = find_pane('buttonSurface0')
        normal_width = button.property('width')
        press_at(QPoint(150, 336))
        QTest.qWait(120)
        assert 50 < button.property('height') < 52
        assert normal_width * 0.98 < button.property('width') < normal_width * 0.99
        view.grabWindow().save(str(out / 'button-pressed.png'))
        QTest.mouseRelease(view, Qt.MouseButton.LeftButton, pos=QPoint(150, 336))
        assert first.property('taps') == before + 1
        QTest.qWait(220)
        assert abs(button.property('height') - 54) < 0.1
        press_at(QPoint(130, 440))
        QTest.mouseMove(view, QPoint(290, 440))
        QTest.qWait(150)
        handle = find_pane('sliderHandle0')
        assert 55.5 < handle.property('width') < 56.5
        assert 33.5 < handle.property('height') < 34.5
        view.grabWindow().save(str(out / 'slider-dragging.png'))
        QTest.mouseRelease(view, Qt.MouseButton.LeftButton, pos=QPoint(290, 440))
        assert first.property('sliderValue') > 0.6
        QTest.qWait(230)
        assert abs(handle.property('width') - 52) < 0.1
        assert abs(handle.property('height') - 36) < 0.1
        original = first.property('switched')
        QTest.mouseClick(view, Qt.MouseButton.LeftButton, pos=QPoint(350, 587))
        assert first.property('switched') != original
        thumb = find_pane('switchThumb0')
        QTest.qWait(50)
        x_early = thumb.property('x')
        assert 25 < x_early < 34
        QTest.qWait(70)
        assert 8 < thumb.property('x') < 26
        view.grabWindow().save(str(out / 'switch-mid-transition.png'))
        QTest.qWait(250)
        assert abs(thumb.property('x') - 4) < 0.1
        results['button_slider_deform_and_switch_easing'] = True
        segment = find_pane('segments0')
        capsule = find_pane('capsule0')
        press_at(QPoint(335, 698))
        assert segment.property('pressPreview'), 'Press should respond without a hold timer'
        QTest.qWait(60)
        progress_a = segment.property('position')
        assert 0.05 < progress_a < 1.95
        assert capsule.property('height') > 45, 'Magnification should begin immediately'
        QTest.qWait(80)
        progress_b = segment.property('position')
        QTest.qWait(80)
        progress_c = segment.property('position')
        assert 0 < progress_c - progress_b < progress_b - progress_a
        QTest.qWait(180)
        assert abs(segment.property('position') - 2) < 0.03
        assert capsule.property('height') > 54
        assert capsule.property('veil') < 0.001
        assert capsule.property('blur') < 0.001
        assert capsule.property('refraction') > 33
        assert first.property('selected') == 0
        view.grabWindow().save(str(out / 'segment-long-press.png'))
        QTest.mouseRelease(view, Qt.MouseButton.LeftButton, pos=QPoint(335, 698))
        assert first.property('selected') == 2
        assert not segment.property('pressPreview')
        QTest.qWait(400)
        assert abs(capsule.property('height') - 40) < 0.1
        results['press_immediate_move_and_magnify'] = True
        results['lifted_capsule_clear_with_strong_refraction'] = True

        QTest.qWait(600)
        segment = find_pane('segments0')
        first.setProperty('selected', 0)
        QTest.qWait(700)
        QTest.mouseMove(view, QPoint(100, 698))
        QTest.qWait(30)
        press_at(QPoint(100, 698))
        QTest.mouseMove(view, QPoint(220, 698))
        QTest.qWait(80)
        assert segment.property('dragging')
        QTest.qWait(180)
        capsule = find_pane('capsule0')
        assert capsule.property('height') > segment.property('height') + 6
        assert capsule.property('y') < -3
        assert capsule.property('width') > segment.property('cell') * 1.1
        assert capsule.property('zoom') > 1.12
        assert 0.5 < segment.property('position') < 1.8
        assert first.property('selected') == 0, 'Selection commits only on release'
        view.grabWindow().save(str(out / 'segment-drag.png'))
        # Place the capsule boundary across a label, rather than across empty space.
        segment.setProperty('position', 0.5)
        QTest.qWait(250)
        colored = view.grabWindow()
        colored.save(str(out / 'segment-partial-coverage.png'))
        content = find_pane('contentLens0')
        original_color = content.property('selectedColor')
        content.setProperty('selectedColor', QColor(first.property('ink')))
        QTest.qWait(100)
        plain = view.grabWindow()
        dpr = view.devicePixelRatio()
        lens_x = 46 + capsule.property('x')
        lens_y = 674 + capsule.property('y')
        half_w = capsule.property('width') / 2
        half_h = capsule.property('height') / 2
        changed = outside = 0
        for py in range(int(658 * dpr), int(738 * dpr), 2):
            for px in range(int(30 * dpr), int(450 * dpr), 2):
                a = colored.pixelColor(px, py)
                b = plain.pixelColor(px, py)
                if (
                    max(
                        abs(a.red() - b.red()), abs(a.green() - b.green()), abs(a.blue() - b.blue())
                    )
                    < 4
                ):
                    continue
                changed += 1
                qx = abs((px + 0.5) / dpr - lens_x - half_w) - half_w + half_h
                qy = abs((py + 0.5) / dpr - lens_y - half_h)
                distance = (max(qx, 0) ** 2 + qy**2) ** 0.5 + min(max(qx, qy), 0) - half_h
                if distance > 1.5:
                    outside += 1
        assert changed > 20, 'Covered text/icons should change color'
        assert outside == 0, f'Color escaped capsule: {outside} pixels'
        results['color_mask_changed_samples'] = changed
        results['color_mask_outside_samples'] = outside
        content.setProperty('selectedColor', original_color)

        QTest.mouseMove(view, QPoint(335, 698))
        QTest.mouseRelease(view, Qt.MouseButton.LeftButton, pos=QPoint(335, 698))
        QTest.qWait(800)
        assert first.property('selected') == 2
        assert abs(segment.property('position') - 2) < 0.02
        assert abs(capsule.property('height') - 40) < 0.1
        segment.setProperty('focus', True)
        QTest.keyClick(view, Qt.Key.Key_Left)
        QTest.qWait(600)
        assert first.property('selected') == 1
        results['drag_follow_snap_keyboard'] = True
        results['readability_schemes_captured'] = True
        results['button_slider_switch_segments'] = True
        QTest.qWait(250)
        view.grabWindow().save(str(out / 'interaction.png'))
        results['qml_errors'] = [e.toString() for e in view.errors()]
        results['shader_error'] = root.property('shaderError')
        assert not results['qml_errors'] and not results['shader_error']
    except Exception as exc:
        import traceback

        traceback.print_exc()
        results['failed'] = repr(exc)
    finally:
        (out / 'results.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
        print(json.dumps(results, indent=2), flush=True)
        if args.capture:
            app.quit()


if args.capture:
    QTimer.singleShot(1000, verify)
app.exec()
if results.get('failed'):
    raise SystemExit(1)
