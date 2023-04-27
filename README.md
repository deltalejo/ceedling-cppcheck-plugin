# Cppcheck Ceedling Plugin

Add [Ceedling](https://github.com/ThrowTheSwitch/Ceedling) task for analyzing
code with [Cppcheck](http://cppcheck.net/).

## Installation

Clone this into Ceedling's plugin folder of your current project.

```shell
$ cd <your-project>/vendor/ceedling/plugins
$ git clone https://github.com/deltalejo/cppcheck-ceedling-plugin.git cppcheck
```

## Enable the plugin

Add the plugins path to your `project.yml` if you have not done it yet.
Then add `cppcheck` plugin to the enabled plugins list:

```yaml
:plugins:
  :load_paths:
    - vendor/ceedling/plugins
  :enabled:
    - cppcheck
```

## Configuration

Add `cppcheck` section to your `project.yml` specifying configuration options.
e.g:

```yaml
:cppcheck:
  :reports:
    - html
  :addons:
    - misra
```

### Reports

Three types of reports are available:

- text
- xml
- html

They can be enabled by listing them on the `:reports` list:

```yaml
:cppcheck:
  :reports:
    - text
    - html
```

#### Text

Artifact file and output format can be configured:

```yaml
:cppcheck:
  :text_artifact_filename: path/to/CppcheckResults.txt
  :template: gcc
```

`:template` can be any of the ones included with Cppcheck or custom format string.

#### XML

Artifact file can be configured:

```yaml
:cppcheck:
  :xml_artifact_filename: path/to/CppcheckResults.xml
```

#### HTML

Artifact directory and HTML title can be configured:

```yaml
:cppcheck:
  :html_artifact_dirname: path/to/CppcheckHtml
  :html_title: Awesome Project
```

*Notes:*

* This report requires the `cppcheck-htmlreport` tool to be available.
* This report implies the `xml` report.

### Preprocessor defines

#### Define names:

```yaml
:cppcheck:
  :defines:
    - A
    - B
    - C=1
```

#### Undefine names:

```yaml
:cppcheck:
  :undefines:
    - A
    - B
    - C
```

*Note: By default `TEST` is undefined so the analysis is performed against production code.*

### Includes

Force inclusion of files before checked files.

```yaml
:cppcheck:
  :includes:
    - file1.h
    - file2.h
```

### Platform

Specify platform to use for the analysis, can be any of the ones included with
Cppcheck, e.g.: unix64, or the path of the platform XML file.

```yaml
:cppcheck:
  :platform: unix64
```

### Standard

Specify C/C++ language standard.

```yaml
:cppcheck:
  :standard: c99
```

### Addons

Addons to be run.

```yaml
:cppcheck:
  :addons:
    - misra
    - path/to/addon.py
```

#### MISRA with rule texts file

Locate your rules text file or copy it to your project. e.g.: `<your-project>/misra.txt` and create the addon file `misra.json` inside your project:

##### **`misra.json`**
```json
{
	"script": "misra",
	"args": ["--rule-texts=misra.txt"]
}
```

Enable the addon:

```yaml
:cppcheck:
  :addons:
    - misra.json
```

### Checks

Enable additional checks:

```yaml
:cppcheck:
  :enable_checks:
    - performance
    - portability
```

Disable individual checks:

```yaml
:cppcheck:
  :disable_checks:
    - style
    - information
```

### Suppressions

Inline suppressions are disabled by default, they can be enabled with:

```yaml
:cppcheck:
  :inline_suppressions: true
```

Command line suppressions can be added also:

```yaml
:cppcheck:
  :suppressions:
    - memleak:src/file1.cpp
    - exceptNew:src/file1.cpp
```

### Library configuration

Add library configuration files:

```yaml
:cppcheck:
  :libraries:
    - lib1.cfg
    - lib2.cfg
```

### Rules

Regular expression rules:

```yaml
:cppcheck:
  :rules:
    - if \( p \) { free \( p \) ; }
```

### Extra options

For things not covered above, add extra command line options:

```yaml
:cppcheck:
  :options:
    - --max-configs=<limit>
    - --suppressions-list=<file>
```

## Usage

### Analyze whole project

Run analysis for all project sources:

```shell
$ ceedling cppcheck:all
```

*Note: This will enable all checks invoking Cppcheck with the option `--enable=all`.*

### Analyze single file

Run analysis for single source file:

```shell
$ ceedling cppcheck:<filename>
```
