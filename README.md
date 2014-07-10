nrpe Cookbook
=============
このクックブックにより、nrpeの設定を行うことが出来ます。
- `nrpe` や `plugin` のインストール (epelリポジトリより)
- `nrpe` と `xinetd` の設定ファイルの生成
- カスタム監視スクリプトの配置

Requirements
------------
- `perl` - 一部の監視スクリプトが perl で書かれています。

Attributes
----------

```
default["nrpe"]["nagios_server"] = "10.0.0.0"
default["nrpe"]["check_process"] = "snmpd,sshd,rsyslogd,ntpd"
```

Usage
-----
#### nrpe::default
nodeの `run_list`: に `nrpe` を記述する。

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[nrpe]"
  ]
}
```

Contributing
------------
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: TODO: List authors
