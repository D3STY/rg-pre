<<<<<<< HEAD
# rg-pre

- base is the eur0-pre-system
- Makefiles updated
- updated all scripts

## Documentation:

## TODO:

### rg-pre
- [X] Debian 11 Support
- [X] ShellCheck
- [ ] Config File

### Documentation
- [ ] Coming soon....
=======
---
title: 're-pre'
disqus: hackmd
---

rg-pre
===

## Table of Contents

[TOC]

## Usage

Here is an example of how I added an affil, test preing with it and delete it
afterwards (This was done on a one-partitioned site, on a multi-partitioned site
which has pre dirs on different partitions you will need to pass the second parameter
both in "site addaffil" and in "site delaffil", the second parameter is the path where
the group dir should be create (for addaffil) or the path the group dir should be
removed from (for delaffil), if you noticed you can add the same group a number of times
to be in different pre dirs on different partitions):

### On the site

```gherkin=
site addaffil
200- Syntax: SITE ADDAFFIL <group> [pre_dir_path]
200 Command Successful.
site addaffil ABC
200- Adding ABC ...
200- Trying to add /site/PRE/ABC to /etc/glftpd.conf ...
200- Successfully added the ABC dir to /etc/glftpd.conf.
200- The /site/PRE/ABC dir has been created.
200- Group ABC can start preing now!!
```

```gherkin=
CWD /PRE/ABC
250 CWD command successful.
PWD
257 "/PRE/ABC" is current directory.
PASV
226- [Ul: 0.0MB] [Dl: 0.0MB] [Speed: 0.00K/s] [Free: 6758MB]
226  [Section: PRE] [Credits: 0.3MB] [Ratio: Unlimited]
MKD Tesing_-_Testing-2003-ABC
257 "/PRE/ABC/Tesing_-_Testing-2003-ABC" created.
PWD
257 "/PRE/ABC" is current directory.
```

```gherkin=
site pre
200- ,--------------------------------------------=
200- | Usage: SITE PRE <dirname> <section>
200- | Valid sections:
200- | MP3 
200- |
200- | If you do not specify a section then
200- | the release will be pre-ed to MP3.
200- |
200- | This moves a directory from a pre-dir to
200- | the provided section dir, and logs it.
200- `--------------------------------------------=
200 Command Successful.
site pre Tesing_-_Testing-2003-ABC
200- Second parameter wasn't specified, using MP3 by default ...
200- [dS] Release Info:  [dS]
200- [dS] Success! Release has been pre'd. [dS]
200 Command Successful.
```

In the channel

```gherkin=
<_dS_> -dS- [PRE-RELEASE] ==] ABC PRE [== Tesing_-_Testing-2003-ABC - (eur0dance@ABC with 0 files, 0MB) - []
```

 On the site again

```gherkin=
site delaffil ABC
200- Removing ABC ...
200- Trying to remove /site/PRE/ABC from the /etc/glftpd.conf file ...
200- The /etc/glftpd.conf has been updated, group ABC has been removed from it.
200- Success! /site/PRE/ABC has been removed.
200- Group ABC is NO LONGER affiled on this site!!
200 Command Successful.
```
>>>>>>> f1701ff (README)
