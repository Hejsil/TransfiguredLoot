#!/bin/sh

value=$1

cd "$HOME/.local/share/Steam/steamapps/compatdata/2132850/pfx/drive_c/users/steamuser/AppData/Local/RabbitSteel/SaveFileNonSynced" || exit 1
sed -i "s#ChangeLog=\"[^\"]*\"#ChangeLog=\"$value\"#g" modconfig.ini
