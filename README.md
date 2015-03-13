# pullall

When run in a folder, it looks for subfolders that are git repositories,
and tries to update them on their current branch.

If that repository contains a node module, npm install is run, and if
one of the dependencies is to another node module in the same parent folder,
then npm link is run to that module.

Non git repos are ignored.

Warns you about dirty git repositories, i.e. repositories that contain uncommited changes.

### example

```
$ ls
snow tyrion daenerys cersei sansa khal
$ pullall
# snow (jon-snow)
Already up to date

# tryrion (tyrion-lannister)  dirty!
Already up to date

# arya (arya-stark)  dirty!
remote: Counting objects: 8, done.
remote: Compressing objects: 100% (5/5), done.
remote: Total 8 (delta 5), reused 6 (delta 3), pack-reused 0
Unpacking objects: 100% (8/8), done.
From github.com:got/arya
   f1981ab..84fd761  master     -> origin/master
Updating repo
Updating f1981ab..84fd761
error: Your local changes to the following files would be overwritten by merge:
        lib/index.js
Please, commit your changes or stash them before you can merge.
Aborting
Updating dependencies
Linking globally

# sansa (sansa-stark)
Already up to date

# khal (khal-drogo)
Already up to date

# infra
Already up to date

# daenerys (daenerys)
Already up to date

# tywin (tywin-lannister)  dirty!
Already up to date

Linking #tyrion-lannister to #sansa-stark
Linking #arya-stark to #jon-snow
Linking #arya-stark to #daenerys
Linking #sansa-stark to #daenerys
Linking #khal-drogo to #sansa-stark
Linking #khal-drogo to #daenerys
Linking #tywin-lannister to #sansa-stark
Linking #tywin-lannister to #daenerys
```
