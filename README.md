# Cppcheck Ceedling Plugin

Add [Ceedling](https://github.com/ThrowTheSwitch/Ceedling) task for analyzing
code with [Cppcheck](http://cppcheck.net/).

## Installation

Create a folder in your machine for Ceedling plugins if you do not have one
already. *e.g.* `~/some/place/for/plugins`:

```shell
$ mkdir -p ~/some/place/for/plugins
```

### Get the plugin

`cd` into the plugins folder and clone this repo:

```shell
$ cd ~/some/place/for/plugins
$ git clone https://github.com/deltalejo/cppcheck-ceedling-plugin.git cppcheck
```

### Enable the plugin

Add the plugins path to your `project.yml` to tell Ceedling where to find
them if you have not done it yet. Then add `cppcheck` plugin to the enabled
plugins list:

```yaml
:plugins:
  :load_paths:
    - ~/some/place/for/plugins
  :enabled:
    - cppcheck
```

## Usage

### Configuration

Add `cppcheck` section to your `project.yml` specifyng configuration options:

```yaml
:cppcheck:
  :addons: []
  :defines: []
  :undefines:
    - TEST
  :options: []  
```

### Analyze whole project

Run analysis for all project sources:

```shell
$ ceedling cppcheck:all
```

### Analyze single file

Run analysis for single source file:

```shell
$ ceedling cppcheck:<filename>
```
