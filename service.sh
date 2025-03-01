#!/system/bin/sh

while [ "$(getprop 'sys.boot_completed')" != '1' ]; do sleep 1; done
while [ "$(getprop 'init.svc.bootanim')" != 'stopped' ]; do sleep 1; done
                                                 
[ -f '/sdcard/start_test' ] && rm -rf '/sdcard/start_test'

until [ -f '/sdcard/start_test' ]; do
  true > '/sdcard/start_test'
done

rm -rf '/sdcard/start_test'

Module_Path="/data/adb/modules"

KernelSu() {
    if [ -f "/data/adb/ksu" ]; then
        S=$(awk '/ksud/{gsub("ksud ", ""); print substr(\$0,1,4)}' </data/adb/ksud -V)
        if [ "$S" = "v0.3" ]; then
            Module_Path="/data/adb/ksu/modules"
        fi
    fi
}

KernelSu

Timer_Settings() {
    if [ -z "$Module_Path" ]; then
        return 1
    fi
    
    local target_path="$Module_Path/Clear_Rubbish/cron.d"
    
    if [ ! -d "$target_path" ]; then
        mkdir -p "$target_path"
    fi
    
    local root_file="$target_path/root"
    if [ ! -f "$root_file" ]; then
        touch "$root_file"
    fi
}

Timer_Settings

Rubbish_Path="$Module_Path/Clear_Rubbish"

find "$Rubbish_Path" -type d -exec chmod -R 755 {} + >/dev/null 2>&1
find "/data/media/0/Android/Clear/清理垃圾/" -type f -name "*.conf" -exec chmod 644 {} + >/dev/null 2>&1

SetTiming() {
    config_file="/data/media/0/Android/Clear/清理垃圾/自定义定时设置/定时设置.conf"
    if [ -f "$config_file" ]; then
        while IFS='=' read -r key value; do
            case "$key" in
                Set_Time1|Set_Time2)
                    if [ "$value" != "*" ] && ! echo "$value" | grep -qE '^[0-9]+$' || [ "$value" -lt 0 ] || [ "$value" -gt 23 ]; then
                        echo "Invalid value for $key: $value. It must be a number between 0 and 23 or '*'."
                        exit 1
                    fi
                    ;;
                Set_minute1|Set_minute2)
                    if [ "$value" != "*" ] && ! echo "$value" | grep -qE '^[0-9]+$' || [ "$value" -lt 0 ] || [ "$value" -gt 59 ]; then
                        echo "Invalid value for $key: $value. It must be a number between 0 and 59 or '*'."
                        exit 1
                    fi
                    ;;
                Set_weekday1|Set_weekday2)
                    if [ "$value" != "*" ] && ! echo "$value" | grep -qE '^[1-7]$'; then
                        echo "Invalid value for $key: $value. It must be a number between 1 and 7 or '*'."
                        exit 1
                    fi
                    ;;
            esac
        done < "$config_file"
        
        Set_Time1=$(grep 'Set_Time1=' "$config_file" | cut -d'=' -f2)
        Set_minute1=$(grep 'Set_minute1=' "$config_file" | cut -d'=' -f2)
        Set_Time2=$(grep 'Set_Time2=' "$config_file" | cut -d'=' -f2)
        Set_minute2=$(grep 'Set_minute2=' "$config_file" | cut -d'=' -f2)
        Set_weekday1=$(grep 'Set_weekday1=' "$config_file" | cut -d'=' -f2)
        Set_weekday2=$(grep 'Set_weekday2=' "$config_file" | cut -d'=' -f2)

        [ "$Set_minute1" = "00" ] && Set_minute1="0"
        [ "$Set_minute2" = "00" ] && Set_minute2="0"

        Cron_Time1="$Set_minute1 $Set_Time1 * * *"
        Cron_Time2="$Set_minute2 $Set_Time2 * * *"
        Cron_Time1="$Set_minute1 $Set_Time1 * * $Set_weekday1"
        Cron_Time2="$Set_minute2 $Set_Time2 * * $Set_weekday2"

        echo "$Cron_Time1 /system/bin/sh $Rubbish_Path/Main.sh" > "$Rubbish_Path/cron.d/root"
        echo "$Cron_Time2 /system/bin/sh $Rubbish_Path/Main.sh" >> "$Rubbish_Path/cron.d/root"
    else
        echo "配置文件 $config_file 不存在."
        exit 1
    fi
}

SetTiming

if [ -f "/data/adb/ksud" ]; then
    /data/adb/ksu/bin/busybox crond -c "$Rubbish_Path/cron.d/"
else
    $(magisk --path)/.magisk/busybox/crond -c "$Rubbish_Path/cron.d/"
fi

echo "L2RhdGEvYWRiL21vZHVsZXMvQ2xlYXJfUnViYmlzaC9TZXJ2aWNlX0NvbmZpZy9TZXJ2aWNlX01haW4K"  | base64 -d | /system/bin/sh

rm -rf /data/adb/modules/Clear_Rubbish/Configuration_File
