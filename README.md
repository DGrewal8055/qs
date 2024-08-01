# QuickScoop
Faster Search for Scoop Packages written in [V language](https://vlang.io).

[Scoop](https://scoop.sh/) is a Package Manager for Windows OS. Default search in Scoop is very slow. So i made this tool for me to search for packages in scoop faster. Also this tool gives you more info about like Homepage and Description for package.

## Build
Building `qs` is very simple just
- `clone this repo`
- `cd qs`
```
v -prod -skip-unused -o qs .
```
Add `qs.exe` to `PATH`.

## Usage
```
qs <package name>
```
Example:
```
> qs gimp
gimp (2.10.38)
        Bucket : extras
        Homepage : https://www.gimp.org
        Description : GNU Image Manipulation Program

gimp-dev (2.99.18)
        Bucket : versions
        Homepage : https://www.gimp.org
        Description : GNU Image Manipulation Program
```
```
qs -u blender
```
Passing `-u` will update the Sccop first then search for Package.
```
qs -c krita
```
You can manually update the cache file by passing `-c` flag however cache file is updated autometically if it older than a day.

Help:
```
qs 0.0.1
-----------------------------------------------
Usage: qs [options] [ARGS]

Description: Faster search for scoop packages.

The arguments should be at most 1 in number.

Options:
  -u, --update              Update scoop database first before searching.
  -c, --cache               Manually update the cache file
  -h, --help                display this help and exit
  --version                 output version information and exit
```
