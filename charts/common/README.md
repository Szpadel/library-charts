# common

Function library for some private charts

Basing on latest k8s-at-home release

## Requirements

Kubernetes: `>=1.16.0-0`

## Dependencies

| Repository | Name | Version |
|------------|------|---------|

## Installing the Chart

This is a [Helm Library Chart](https://helm.sh/docs/topics/library_charts/#helm).

**WARNING: THIS CHART IS NOT MEANT TO BE INSTALLED DIRECTLY**

## Using this library

Include this chart as a dependency in your `Chart.yaml` e.g.

```yaml
# Chart.yaml
dependencies:
- name: common
  version: 1.0.0
  repository: https://szpadel.github.io/liblary-charts/
```


## Configuration

Read through the [values.yaml](./values.yaml) file. It has several commented out suggested values.
