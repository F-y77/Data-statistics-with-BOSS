name = "BOSS击杀统计"
description = "记录BOSS击杀数据。F1查看记录，F2添加记录，F10清零选择，F11退出操作；自动模式下，BOSS死亡时自动统计，击杀消息会广播给所有人，且拥有手动模式的所有功能。"
author = "Va6gn"
version = "1.0"

-- 兼容性
api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

-- 服务器模组
all_clients_require_mod = false
client_only_mod = false
server_only_mod = true

server_filter_tags = {"BOSS击杀统计"}

-- 配置选项
configuration_options = {
    {
        name = "auto_tracking",
        label = "统计模式",
        options = {
            {description = "手动", data = false,hover = "手动模式下，相对方便，且不会出BUG。"},
            {description = "自动", data = true,hover = "自动模式下，全自动，但小心出BUG！"}
        },
        default = false,
    },
}

-- 图标
icon_atlas = "modicon.xml"
icon = "modicon.tex" 