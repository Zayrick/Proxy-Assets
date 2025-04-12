# Proxy Assets

这个仓库包含了一些网络代理工具使用的通用资源。

## 项目结构

- `rule-set/`: 包含所有代理规则集文件
  - `personal/`: 个人整理的规则集
  - `external/`: 外部来源的规则集
  - `repo/`: 仓库相关规则集，内容来源于[MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat/tree/meta)
    - 对classical文件夹内的list文件做了兼容性转换：在Mihomo中IPv6规则和IPv4都使用IP-CIDR格式，但在其他软件中IPv6需要使用IP-CIDR6，本仓库进行了相应转换以提高兼容性

## 使用方法

根据您使用的代理工具，将这些规则导入到相应的配置文件中。

### 示例（Clash配置）

```yaml
rule-providers:
  SteamDownload:
    type: http
    behavior: classical
    url: "https://raw.githubusercontent.com/Zayrick/Proxy-Assets/main/rule-set/personal/SteamDownload.list"
    path: ./ruleset/SteamDownload.yaml
    interval: 86400
```

## 贡献指南

欢迎提交Pull Request以添加或更新规则。请确保：

1. 规则格式正确
2. 提供规则的来源或用途说明
3. 将规则放在合适的目录中
