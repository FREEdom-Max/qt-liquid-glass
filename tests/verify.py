"""GPU integration checks for public QML components; no third-party test runner."""
import json
import platform
import traceback
from datetime import datetime, timezone
from pathlib import Path

from PyQt6.QtCore import QObject, QPointF, Qt, QUrl, QT_VERSION_STR, PYQT_VERSION_STR, qVersion
from PyQt6.QtGui import QColor
from PyQt6.QtQuick import QSGRendererInterface
from PyQt6.QtTest import QTest


def center(item):
    return item.mapToScene(QPointF(item.width() / 2, item.height() / 2)).toPoint()


def click(view, item):
    QTest.mouseClick(view, Qt.MouseButton.LeftButton, pos=center(item))


def settle(view, delay=300):
    view.update()
    QTest.qWait(delay)


def image(view):
    shot = view.grabWindow()
    assert not shot.isNull(), 'GPU screenshot is empty'
    return shot


def rgb(shot, x, y, dpr):
    color = shot.pixelColor(round(x * dpr), round(y * dpr))
    return color.red(), color.green(), color.blue()


def verify(view, messages, output):
    output.mkdir(parents=True, exist_ok=True)
    api = view.rendererInterface().graphicsApi()
    report = {
        'time_utc': datetime.now(timezone.utc).isoformat(),
        'system': platform.platform(), 'python': platform.python_version(),
        'pyqt': PYQT_VERSION_STR, 'qt': qVersion(), 'qt_build': QT_VERSION_STR, 'backend': api.name,
        'dpr': view.devicePixelRatio(), 'checks': [], 'errors': [],
    }
    def passed(name):
        report['checks'].append(name)
    try:
        assert api not in (QSGRendererInterface.GraphicsApi.Software,
                           QSGRendererInterface.GraphicsApi.Unknown,
                           QSGRendererInterface.GraphicsApi.Null), 'A real GPU backend is required'
        root = view.rootObject()
        control = lambda name: root.findChild(QObject, name)
        button, switch, slider = [control(name) for name in ('button', 'switch', 'slider')]
        assert all((button, switch, slider, control('progress')))
        click(view, button)
        assert root.property('clicks') == 1
        button.setProperty('enabled', False)
        click(view, button)
        assert root.property('clicks') == 1
        button.setProperty('enabled', True)
        passed('button_mouse_and_disabled')

        button.forceActiveFocus()
        QTest.keyClick(view, Qt.Key.Key_Space)
        assert root.property('clicks') == 2
        for target in (switch, slider, control('themeSwitch'), control('effectsSwitch'), button):
            QTest.keyClick(view, Qt.Key.Key_Tab)
            assert target.property('activeFocus'), f'Tab did not reach {target.objectName()}'
        QTest.keyClick(view, Qt.Key.Key_Backtab)
        assert control('effectsSwitch').property('activeFocus')
        passed('tab_cycle_backtab_button_keyboard')

        click(view, switch)
        assert switch.property('checked')
        switch.setProperty('enabled', False)
        click(view, switch)
        assert switch.property('checked')
        switch.setProperty('enabled', True)
        switch.forceActiveFocus()
        QTest.keyClick(view, Qt.Key.Key_Space)
        assert not switch.property('checked')
        passed('switch_mouse_keyboard_and_disabled')

        slider.forceActiveFocus()
        QTest.keyClick(view, Qt.Key.Key_Right)
        assert slider.property('value') == 51
        start = center(slider)
        end = slider.mapToScene(QPointF(slider.width() * .85, slider.height() / 2)).toPoint()
        QTest.mousePress(view, Qt.MouseButton.LeftButton, pos=start)
        QTest.mouseMove(view, end, delay=80)
        QTest.mouseRelease(view, Qt.MouseButton.LeftButton, pos=end)
        assert slider.property('value') > 70
        value = slider.property('value')
        slider.setProperty('enabled', False)
        QTest.mouseClick(view, Qt.MouseButton.LeftButton, pos=start)
        QTest.keyClick(view, Qt.Key.Key_Left)
        assert slider.property('value') == value
        slider.setProperty('enabled', True)
        assert abs(control('progress').property('value') - value / 100) < .001
        passed('slider_mouse_keyboard_disabled_and_progress_binding')

        root.setProperty('fontFamily', 'Arial')
        root.setProperty('fontSize', 18)
        root.setProperty('accent', QColor('#407be0'))
        for item in (button, switch, slider, control('progress')):
            font = item.property('font')
            assert font.family() == 'Arial' and font.pixelSize() == 18
        settle(view)
        image(view).save(str(output / 'custom-theme.png'))
        root.setProperty('fontFamily', 'Microsoft YaHei UI')
        root.setProperty('fontSize', 14)
        root.setProperty('accent', QColor('#e58a40'))
        passed('shared_font_and_accent_configuration')

        for dark in (False, True):
            root.setProperty('whiteInk', dark)
            for backdrop in (1, 2):
                root.setProperty('backgroundMode', backdrop)
                settle(view)
                assert image(view).save(str(output / f'readability-{int(dark)}-{backdrop}.png'))
        passed('four_theme_background_combinations_rendered_for_visual_review')
        root.setProperty('backgroundMode', 0)
        root.setProperty('whiteInk', False)
        view.resize(920, 700)
        settle(view)
        assert root.width() == 920
        image(view).save(str(output / 'resized.png'))
        passed('window_resize')

        for state in ('effectsEnabled', 'backgroundReady'):
            root.setProperty(state, False)
            assert not root.property('materialReady')
            click(view, button)
            settle(view)
            image(view).save(str(output / f'fallback-{state}.png'))
            root.setProperty(state, True)
        assert root.property('clicks') == 4
        # Exercise the error-to-fallback contract without feeding an invalid shader to Qt.
        root.setProperty('shaderError', 'test-only simulated material failure')
        assert not root.property('effectsEnabled')
        root.setProperty('shaderError', '')
        root.setProperty('effectsEnabled', True)
        passed('effects_off_background_unavailable_and_error_fallback')

        view.setSource(QUrl.fromLocalFile(str(Path(__file__).with_name('Geometry.qml').resolve())))
        assert not view.errors(), view.errors()
        root = view.rootObject()
        moving = root.findChild(QObject, 'moving')
        clipper = root.findChild(QObject, 'clipper')
        probe = root.findChild(QObject, 'probe')
        dpr = view.devicePixelRatio()

        def compare_alignment(name):
            root.setProperty('lensVisible', True)
            root.setProperty('tint', 0.)
            settle(view)
            actual = image(view)
            surface = probe.property('surface')
            p0 = probe.mapToScene(QPointF(0, 0))
            p1 = probe.mapToScene(QPointF(probe.width(), probe.height()))
            expected = (p0.x(), p0.y(), p1.x()-p0.x(), p1.y()-p0.y())
            observed = (surface.x(), surface.y(), surface.z(), surface.w())
            assert max(abs(a-b) for a,b in zip(expected, observed)) < .01, (name, observed, expected)
            root.setProperty('lensVisible', False)
            settle(view)
            reference = image(view)
            deltas = []
            for x in range(round(p0.x()+35), round(p1.x()-35), 9):
                for y in range(round(p0.y()+30), round(p1.y()-30), 9):
                    # Avoid tile boundaries: subpixel filtering differs by at most one pixel.
                    if min(x % 40, 40-x % 40, y % 40, 40-y % 40) < 3:
                        continue
                    deltas.append(max(abs(a-b) for a,b in zip(rgb(actual,x,y,dpr), rgb(reference,x,y,dpr))))
            assert len(deltas) > 10, 'Insufficient interior pixels'
            assert max(deltas) <= 3, (name, 'misaligned backdrop', max(deltas))
            passed(name)

        compare_alignment('pixel_alignment_initial')
        moving.setX(73)
        moving.setY(51)
        compare_alignment('pixel_alignment_parent_translation')
        moving.setScale(1.35)
        compare_alignment('pixel_alignment_parent_scale')
        moving.setWidth(310)
        moving.setHeight(220)
        compare_alignment('pixel_alignment_scale_origin_after_parent_resize')
        moving.setTransformOrigin(moving.TransformOrigin.TopLeft)
        compare_alignment('pixel_alignment_top_left_scale_origin')

        moving.setScale(1.)
        moving.setX(120)
        moving.setY(50)
        clipper.setWidth(220)
        clipper.setHeight(220)
        clipper.setClip(True)
        root.setProperty('tint', .8)
        root.setProperty('lensVisible', True)
        settle(view)
        clipped = image(view)
        root.setProperty('lensVisible', False)
        settle(view)
        baseline = image(view)
        # Probe spans x=205..385; clipping ends at x=290. Check both sides.
        inside = max(abs(a-b) for a,b in zip(rgb(clipped,250,170,dpr),rgb(baseline,250,170,dpr)))
        outside = max(abs(a-b) for a,b in zip(rgb(clipped,330,170,dpr),rgb(baseline,330,170,dpr)))
        assert inside > 20 and outside <= 3, (inside, outside)
        clipped.save(str(output / 'parent-clip.png'))
        passed('parent_rectangular_clip_inside_outside_pixels')

        root.setProperty('lensVisible', True)
        probe.setWidth(0)
        assert not probe.property('active')
        probe.setWidth(180)
        assert probe.property('active')
        # Keep the native window valid; test the scene's zero-size contract itself.
        root.setWidth(0)
        assert not root.property('materialReady')
        root.setWidth(680)
        passed('zero_size_fallback_and_recovery')
        assert not root.property('shaderError'), root.property('shaderError')
        assert not messages, messages
        passed('no_qt_warnings_or_shader_errors')
        report['passed'] = True
    except Exception:
        report['passed'] = False
        report['errors'].append(traceback.format_exc())
    finally:
        report['qt_messages'] = list(messages)
        (output / 'results.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
        print(json.dumps(report, indent=2), flush=True)
    return 0 if report['passed'] else 1
