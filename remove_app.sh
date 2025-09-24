#!/bin/bash
# Xiaomi Debloat Script (безопасное удаление мусора)

# Проверка, что ADB доступен
if ! command -v adb &> /dev/null; then
    echo "❌ ADB не установлен. Установи: sudo apt install android-tools-adb"
    exit 1
fi

# Список пакетов для удаления
PACKAGES=(
com.android.bips
# com.android.htmlviewer
# com.android.wallpapercropper
com.google.android.apps.wellbeing
# com.google.android.contacts
com.miui.documentsuioverlay
# com.miui.guardprovider
# com.miui.rom
# com.miui.securityadd
# com.miui.securitycenter # Позволяет смотреть названия пакетов
com.miui.wmsvc
# com.xiaomi.account
# com.xiaomi.bluetooth
# com.xiaomi.finddevice # bootloop

#???
com.miui.vsimcore
# com.miui.daemon

# com.google.android.apps.restore
# com.google.android.overlay.setupwizard

com.xiaomi.mi_connect_service
com.xiaomi.miplay_client
com.focaltech.fingerprint
com.mi.globalbrowser

com.debug.loggerui
com.fido.asm
com.fido.xiaomi.uafclient
com.android.dreams.basic
com.android.wallpapercropper
com.android.wallpaperpicker
com.facemoji.lite.xiaomi
com.android.theme.color.orchid
com.android.theme.color.purple
com.android.theme.icon.teardrop
com.android.theme.color.green
com.android.theme.color.ocean
com.android.theme.color.space
com.android.theme.color.black
com.android.theme.color.cinnamon
com.android.theme.icon.square
com.wapi.wapicertmanager
com.miui.face
com.android.wallpaperbackup
com.android.theme.font.notoserifsource
com.android.theme.icon.squircle
com.android.theme.icon.roundedrect
com.android.theme.icon_pack.circular.android
com.android.theme.icon_pack.circular.launcher
com.android.theme.icon_pack.circular.systemui
com.android.theme.icon_pack.circular.settings
com.android.theme.icon_pack.circular.themepicker
com.android.theme.icon_pack.filled.android
com.android.theme.icon_pack.filled.launcher
com.android.theme.icon_pack.filled.systemui
com.android.theme.icon_pack.filled.settings
com.android.theme.icon_pack.filled.themepicker
com.android.theme.icon_pack.rounded.android
com.android.theme.icon_pack.rounded.launcher
com.android.theme.icon_pack.rounded.systemui
com.android.theme.icon_pack.rounded.settings
com.google.android.syncadapters.calendar
com.google.android.syncadapters.contacts

com.miui.freeform
com.miui.hybrid
com.miui.hybrid.accessory
com.miui.android.fashiongallery
com.android.emergency
com.android.calendar
com.android.egg
com.android.wallpaper.livepicker
com.android.printspooler
com.android.providers.calendar
com.google.android.gms.location.history
com.openmygame.android.sky.words
cn.wps.moffice_eng
cn.wps.xiaomi.abroad.lite
com.android.soundrecorder
com.block.juggle
com.ebay.carrier
com.ebay.mobile
com.facebook.appmanager
com.facebook.katana
com.facebook.services
com.facebook.system
com.facemoji.lite.xiaomi
com.google.android.apps.docs
com.google.android.apps.maps
com.google.android.apps.photos
com.google.android.apps.tachyon
com.google.android.apps.youtube.music
com.google.android.feedback
com.google.android.gm
com.google.android.googlequicksearchbox
com.google.android.printservice.recommendation
com.google.android.projection.gearhead
com.google.android.videos
com.google.android.youtube
com.google.ar.lens
com.hotplay.puzzlegames
com.mi.android.globalminusscreen
com.mi.global.shop
com.micredit.in
com.milink.service
com.mipay.wallet.in
com.miui.analytics
com.miui.audioeffect
com.miui.audiomonitor
com.miui.backup
com.miui.bugreport
com.miui.calculator
com.miui.cit
com.miui.cleanmaster
com.miui.cloudbackup
com.miui.cloudservice
com.miui.cloudservice.sysbase
com.miui.fm
com.miui.fmservice
com.miui.gallery
com.miui.micloudsync
com.miui.miservice
com.miui.misound
com.miui.miwallpaper
com.miui.msa.global
com.miui.notes
com.miui.phrase
com.miui.player
com.miui.qr
com.miui.screenrecorder
com.miui.touchassistant
com.miui.videoplayer
com.miui.weather2
com.miui.yellowpage
com.mobile.legends
com.netflix.partner.activation
com.opera.browser
com.opera.preinstall
com.tencent.soter.soterserver
com.verizon.remoteSimlock
com.vitastudio.mahjong
com.vk.vkvideo
com.xiaomi.bttester
com.xiaomi.calendar
com.xiaomi.discover
com.xiaomi.glgm
com.xiaomi.micloud.sdk
com.xiaomi.midrop
com.xiaomi.mipicks
com.xiaomi.misettings
com.xiaomi.payment
com.xiaomi.powerchecker
com.xiaomi.scanner
com.xiaomi.simactivate.service
com.yandex.browser
com.zhiliaoapp.musically
ru.beru.android
ru.dublgis.dgismobile
ru.more.play
ru.oneme.app
ru.sportmaster.app
ru.sunlight.sunlight
ru.yandex.searchplugin
zombie.survival.craft.z

)

echo "🚀 Запуск очистки Xiaomi от мусора..."

for pkg in "${PACKAGES[@]}"; do
    echo "➡️ Удаление $pkg"
    adb shell pm uninstall --user 0 "$pkg"
done

echo "✅ Готово! Рекомендуется перезагрузить телефон."
