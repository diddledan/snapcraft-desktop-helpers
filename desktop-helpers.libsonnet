{
    apply(variant):: {
        assert
            variant == "glib" ||
            variant == "gnome" ||
            variant == "gtk" ||
            variant == "gtk2" ||
            variant == "gtk3" ||
            variant == "qt" ||
            variant == "qt4" ||
            variant == "qt5"
        ,

        local updateCommandLines(name, app) = (
            app + {
                "command-chain"+: [
                    "bin/desktop-launch",
                ],
            }
        ),

        local updateDependencies(name, part) = (
            part + {
                after+: [
                    "desktop-" + variant,
                ],
            }
        ),

        plugs: {
            "gtk-3-themes": {
                interface: "content",
                target: "$SNAP/data-dir/themes",
                "default-provider": "gtk-common-themes:gtk-3-themes",
            },
            "icon-themes": {
                interface: "content",
                target: "$SNAP/data-dir/icons",
                "default-provider": "gtk-common-themes:icon-themes",
            },
            "sound-themes": {
                interface: "content",
                target: "$SNAP/data-dir/sounds",
                "default-provider": "gtk-common-themes:sounds-themes",
            },
            "gnome-3-28-1804": {
                interface: "content",
                target: "$SNAP/gnome-platform",
                "default-provider": "gnome-3-28-1804:gnome-3-28-1804",
            },
        },
        apps: (
            if std.length(super.apps) > 0 then
                std.mapWithKey(updateCommandLines, super.apps)
            else {}
        ),
        parts: {
            ["desktop-" + variant]: {
                source: "https://github.com/ubuntu/snapcraft-desktop-helpers.git",
                plugin: "make",
                "source-subdir":
                    if variant == "gnome" || variant == "gtk" || variant == "gtk2" || variant == "gtk3" then (
                        "gtk"
                    ) else if variant == "qt" || variant == "qt4" || variant == "qt5" then (
                        "qt"
                    ) else (
                        "glib-only"
                    ),
                "make-parameters": [
                    (
                        if variant == "gnome" || variant == "gtk" then (
                            "FLAVOR=gtk3"
                        ) else if variant == "qt" then (
                            "FLAVOR=qt5"
                        ) else (
                            "FLAVOR=" + variant
                        )
                    ),
                ],
                "build-packages": (
                    if variant == "gnome" then
                        ["gcc"]
                    else if variant == "gtk" || variant == "gtk3" then
                        [
                            "build-essential",
                            "libgtk-3-dev",
                        ]
                    else if variant == "gtk2" then
                        [
                            "build-essential",
                            "libgtk2.0-dev",
                        ]
                    else if variant == "qt" || variant == "qt5" then
                        [
                            "build-essential",
                            "qtbase5-dev",
                            "dpkg-dev",
                        ]
                    else if variant == "qt4" then
                        [
                            "build-essential",
                            "libqt4-dev",
                            "dpkg-dev",
                        ]
                    else
                        ["libglib2.0-dev"]
                ),
                "stage-packages": (
                    if variant == "gnome" then ["gcc"]
                    else if variant == "gtk" || variant == "gtk3" then
                        [
                            "libxkbcommon0",  # XKB_CONFIG_ROOT
                            "ttf-ubuntu-font-family",
                            "dmz-cursor-theme",
                            "light-themes",
                            "adwaita-icon-theme",
                            "gnome-themes-standard",
                            "shared-mime-info",
                            "libgtk-3-0",
                            "libgdk-pixbuf2.0-0",
                            "libglib2.0-bin",
                            "libgtk-3-bin",
                            "unity-gtk3-module",
                            "libappindicator3-1",
                            "locales-all",
                            "xdg-user-dirs",
                            "ibus-gtk3",
                            "libibus-1.0-5",
                            "fcitx-frontend-gtk3",
                        ]
                    else if variant == "gtk2" then
                        [
                            "libxkbcommon0",  # XKB_CONFIG_ROOT
                            "ttf-ubuntu-font-family",
                            "dmz-cursor-theme",
                            "light-themes",
                            "adwaita-icon-theme",
                            "gnome-themes-standard",
                            "shared-mime-info",
                            "libgtk2.0-0",
                            "libgdk-pixbuf2.0-0",
                            "libglib2.0-bin",
                            "libgtk2.0-bin",
                            "unity-gtk2-module",
                            "locales-all",
                            "libappindicator1",
                            "xdg-user-dirs",
                            "ibus-gtk",
                            "libibus-1.0-5",
                        ]
                    else if variant == "qt" || variant == "qt5" then
                        [
                            "libxkbcommon0",
                            "ttf-ubuntu-font-family",
                            "dmz-cursor-theme",
                            "light-themes",
                            "adwaita-icon-theme",
                            "gnome-themes-standard",
                            "shared-mime-info",
                            "libqt5gui5",
                            "libgdk-pixbuf2.0-0",
                            "libqt5svg5", # for loading icon themes which are svg
                            {try: ["appmenu-qt5"]}, # not available on core18
                            "locales-all",
                            "xdg-user-dirs",
                            "fcitx-frontend-qt5",
                        ]
                    else if variant == "qt4" then
                        [
                            "libxkbcommon0",
                            "ttf-ubuntu-font-family",
                            "dmz-cursor-theme",
                            "light-themes",
                            "adwaita-icon-theme",
                            "gnome-themes-standard",
                            "shared-mime-info",
                            "libqtgui4",
                            "libgdk-pixbuf2.0-0",
                            "libqt4-svg", # for loading icon themes which are svg
                            "appmenu-qt",
                            "locales-all",
                            "sni-qt",
                            "xdg-user-dirs",
                        ]
                    else
                        ["libglib2.0-bin"]
                ),
            } + if variant == "gnome" then {
                    "override-build": "
snapcraftctl build
mkdir -pv $SNAPCRAFT_PART_INSTALL/gnome-platform
",
            }
        } + (
            if std.length(super.apps) > 0 then
                std.mapWithKey(updateDependencies, super.parts)
            else {}
        ),
    },
}