@echo off
REM Xiaomi Debloat Script (безопасное удаление мусора)

REM Проверка наличия adb.exe
if not exist ".\adb.exe" (
    echo ❌ adb.exe не найден в текущей папке. Положите его сюда.
    pause
    exit /b 1
)

REM Список пакетов для удаления
set PACKAGES=^
cn.wps.moffice_eng ^
cn.wps.xiaomi.abroad.lite ^
com.ebay.carrier ^
com.ebay.mobile ^
com.facebook.appmanager ^
com.facebook.katana ^
com.facebook.services ^
com.facebook.system ^
com.facemoji.lite.xiaomi ^
com.google.android.videos ^
com.google.android.youtube ^
com.google.ar.lens ^
com.hotplay.puzzlegames ^
com.mi.android.globalminusscreen ^
com.micredit.in ^
com.milink.service ^
com.mipay.wallet.in ^
com.miui.android.fashiongallery ^
com.miui.audioeffect ^
com.miui.audiomonitor ^
com.miui.backup ^
com.miui.bugreport ^
com.miui.calculator ^
com.miui.cit ^
com.miui.cleanmaster ^
com.miui.cloudbackup ^
com.miui.cloudservice ^
com.miui.cloudservice.sysbase ^
com.miui.fm ^
com.miui.fmservice ^
com.miui.gallery ^
com.miui.micloudsync ^
com.miui.misound ^
com.miui.miwallpaper ^
com.miui.notes ^
com.miui.phrase ^
com.miui.player ^
com.miui.screenrecorder ^
com.miui.touchassistant ^
com.miui.videoplayer ^
com.miui.weather2 ^
com.mobile.legends ^
com.netflix.partner.activation ^
com.opera.browser ^
com.opera.preinstall ^
com.verizon.remoteSimlock ^
com.xiaomi.bttester ^
com.xiaomi.calendar ^
com.xiaomi.discover ^
com.xiaomi.micloud.sdk ^
com.xiaomi.midrop ^
com.xiaomi.mipicks ^
com.xiaomi.misettings ^
com.xiaomi.payment ^
com.xiaomi.powerchecker ^
com.xiaomi.scanner ^
com.xiaomi.simactivate.service ^
com.zhiliaoapp.musically ^
ru.dublgis.dgismobile ^
ru.more.play ^
ru.oneme.app ^
ru.sportmaster.app ^
ru.sunlight.sunlight ^
ru.yandex.searchplugin ^
zombie.survival.craft.z

echo 🚀 Запуск очистки Xiaomi от мусора...

for %%p in (%PACKAGES%) do (
    echo ➡️ Удаление %%p
    .\adb.exe shell pm uninstall --user 0 %%p
)

echo ✅ Готово! Рекомендуется перезагрузить телефон.
pause
