```
__________  ________                      
\______   \/  _____/______ _______  ____  
 |       _/   \  ___\____ \\_  __ \/ __ \ 
 |    |   \    \_\  \  |_\ \|  | \/  ___/_
 |____|_  /\______  /   ___/|__|   \___  /
        \/        \/|__|               \/ 
```


# RG-pre

## Introduction

RG-pre is a collection of shell scripts that can be used to automate the process of pre-releasing files on a File server. 

## Prerequisites

Before using RG-pre, you will need to have the following installed:

* A Linux server with SSH access
* A glFTPd server with a pre-release directory
* A text editor
* A command-line FTP client

## Installation

To install RG-pre, simply clone the repository to your server:

```
git clone https://github.com/RG-pre/rg-pre.git
```

## Configuration

Once RG-pre is installed, you will need to configure it. The configuration file is located at `/etc/rg-pre.conf`.
The configuration file contains the following settings:

* `logpath`: The path to the log file.
* `sitename`: The name of your Usenet server.
* `glftpd_conf`: The path to the glftpd configuration file.
* `base_pre_path`: The path to the pre-release directory.
* `datapath`: The path to the data directory.
* `date_0day_format`: The date format for 0day releases.
* `date_mp3_format`: The date format for MP3 releases.
* `date_mv_format`: The date format for MVID releases.
* `section_names`: The names of the pre-release sections.
* `target_paths`: The paths to the pre-release sections.
* `script_paths`: The paths to the scripts that return pre-release information.
* `allowdefaultsection`: Whether or not to allow the "SITE PRE <dirname>" command.
* `defaultsection`: The number of the default pre-release section.

## Usage
The rg-pre script is used through the following command format:

```
SITE PRE <dirname> <section>
```
* `<dirname>` is the name of the directory that you want to pre-release.
* `<section>` is the name of the pre-release section that you want to pre-release to.

## Sample Interactions
### Adding Affil

```
SITE addaffil
[PRE] Syntax: SITE ADDAFFIL <group> [pre_dir_path]
```

```
site addaffil ABC
[PRE] Adding ABC ...
[PRE] Trying to add /site/PRE/ABC to /etc/glftpd.conf ...
[PRE] Successfully added the ABC dir to /etc/glftpd.conf.
[PRE] The /site/PRE/ABC dir has been created.
[PRE] Group ABC can start preing now!!
```

### Pre-Releasing

```
site pre
[PRE] Usage: SITE PRE <dirname> <section>
[PRE] Valid sections: MP3
[PRE] If no section specified, release is pre-ed to MP3.
[PRE] Moves a dir from pre-dir to provided section, logging it.
```

```
site pre Tesing_-_Testing-2003-ABC
[PRE] Second parameter wasn't specified, using MP3 by default ...
[PRE] [PRE] Release Info:  [dS]
[PRE] [PRE] Success! Release has been pre'd. [dS]
```

### Removing Affil
```
site delaffil ABC
[PRE] Removing ABC ...
[PRE] Trying to remove /site/PRE/ABC from /etc/glftpd.conf ...
[PRE] /etc/glftpd.conf updated; group ABC removed from it.
[PRE] Success! /site/PRE/ABC has been removed.
[PRE] Group ABC is NO LONGER affiliated on this site!!
```