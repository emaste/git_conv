# Git Primer

New committers are assumed to already be familiar with the basic operation of Git. If not, start by reading the [Git Book](https://git-scm.com/book/en/v2).

## Introduction

Git is a distributed version control system (DVCS), which means that the entire repository, including all of the history, is maintained with every copy (clone). Changes are made to a developer's local repository, then shared with other repositories. Git uses fetch, pull, and push to refer to these sharing operations.

A DVCS doesn't inherently have a canonical or "source of truth" repository; it is by convention that a canonical repository is established. We'll call the canonical FreeBSD.org repository "upstream."

The simplest case of making a change in the FreeBSD tree involves three steps:
1. Acquire latest changes from upstream
2. Commit change locally
3. Push to upstream

In some cases there will be newer changes in the upstream repository, as well as local changes that have not yet been pushed there.

There are two main approaches for dealing with this in a DVCS world - a rebase workflow, or a merge workflow. The rebase workflow "replays" the local commits on top of the upstream history, and maintains a linear progression. The merge workflow adds the new commits via a merge. The history logically diverges into two or more branches, coming back together via the merge.

In FreeBSD we (currently) use a rebase workflow. In the case of having local commits not yet upstream the steps are:

1. Acquire latest changes from upstream
2. Rebase local changes on upstream
3. Push to upstream

Examples of these cases are presented in this primer.

XXX describe git index

## Installing Git

Git can be installed from the FreeBSD package collection by issuing this commands:
```
# pkg install git
```
or from the ports tree:
```
# cd /usr/ports/devel/git
# make all install clean
```

## Getting Started

There are a few ways to obtain a working copy of the tree from Git. This section will explain them.

### Direct Checkout

The first is to check out directly from the main repository. For the src tree, use:
```
% git clone git@cgit-beta.freebsd.org/src.git /usr/src
```
For the doc tree, use:
```
% git clone git@cgit-beta.freebsd.org/doc.git /usr/doc
```
For the ports tree, use:
```
% git clone git@cgit-beta.freebsd.org/ports.git /usr/ports
```
Note:

Though the remaining examples in this document are written with the workflow of working with the src tree in mind, the underlying concepts are the same for working with the doc and the ports tree. Ports related Git operations are listed in Section XXX, “Ports Specific FAQ”.

The above command will check out a CURRENT source tree as /usr/src/, which can be any target directory on the local filesystem. Omitting the final argument of that command causes the working copy, in this case, to be named “src”, but that can be renamed safely.

git@ means the git protocol tunnelled over SSH. The name of the server is *cgit-beta.freebsd.org* and *src* is the repository.

If your FreeBSD login name is different from the login name used on the local machine, either include it in the URL (for example jarjar@cgit-beta.freebsd.org/src.git), or add an entry to ~/.ssh/config in the form:
```
Host cgit-beta.freebsd.org
    User jarjar
```
This is the simplest method, but it is hard to tell just yet how much load it will place on the repository.

**Note**: The git diff command does not require access to the server, as git stores the entire repository history locally.

### RELENG_* Branches and General Layout

In *git@cgit-beta.freebsd.org/src.git*, *src* refers to the source tree. Similarly, *ports* refers to the ports tree, and so on. These are separate repositories with their own revision hashes, access controls and commit mail.

For the base repository, the main branch refers to the -CURRENT tree. For example, *bin/ls* is what would go into */usr/src/bin/ls* in a release. Some key branches:

* *main* which corresponds to HEAD, also known as -CURRENT.
* *stable/n* which corresponds to RELENG_n.
* *releng/n.n* which corresponds to RELENG_n_n.
* *release/n.n.n* which corresponds to RELENG_n_n_n_RELEASE.

### FreeBSD Documentation Project Branches and Layout

In *git@cgit-beta.freebsd.org/doc.git*, *doc* refers to the repository root of the documentation tree.

In general, most FreeBSD Documentation Project work will be done within the main branch of the documentation source tree.

FreeBSD documentation is written and/or translated to various languages, each in a separate directory in the main branch.

Each translation set contains several subdirectories for the various parts of the FreeBSD Documentation Project. A few noteworthy directories are:

* */articles/* contains the source code for articles written by various FreeBSD contributors.
* */books/* contains the source code for the different books, such as the FreeBSD Handbook.
* */htdocs/* contains the source code for the FreeBSD website.

### FreeBSD Ports Tree Branches and Layout

In *git@cgit-beta.freebsd.org/ports.git*, *ports* refers to the repository root of the ports tree.

In general, most FreeBSD port work will be done within the main/ branch of the ports tree which is the actual ports tree used to install software. Some other key branches:

* RELENG_n_n_n which corresponds to RELENG_n_n_n is used to merge back security updates in preparation for a release.
* RELEASE_n_n_n which corresponds to RELEASE_n_n_n represents a release tag of the ports tree.
* /tags/RELEASE_n_EOL represents the end of life tag of a specific FreeBSD branch.

## Daily Use

This section will explain how to perform common day-to-day operations with Git.

### Help

git has built in help documentation. It can be accessed by typing:
```
% git help
% git help <subcommand>
```
Additional information can be found in the [Git Book](https://git-scm.com/book/en/v2).

### Checkout

As seen earlier, to check out the FreeBSD head branch:

### Anonymous Checkout

XXX
It is possible to anonymously check out the FreeBSD repository with Git. This will give access to a read-only tree that can be updated, but not committed back to the main repository. To do this, use:

### Status

To view the local changes that have been made to the working copy:
```
% git status
```

Git reports files in three different categories:
- Untracked (i.e., new files not yet added to the tree)
- Unstaged (modified, but not added to the index)
- Staged (modified and added to the index, for the next commit)

### Editing and Committing

Git does not need to be told in advance about file editing.

To commit staged changes (ones that have already been added to the index):
```
% git commit
```

To commit all changes, regardless of whether they're staged or not:
```
% git commit -a
```
To commit all changes in the current directory and all subdirectories:
```
% git commit .
```
To commit all changes in, for example, lib/libfetch/ and usr/bin/fetch/ in a single operation:
```
% git commit lib/libfetch usr/bin/fetch
```

### Adding and Removing Files

Files are added to a git repository with git add. To add a file named foo, create it, and then:
```
% git add foo
% git commit
```
Files can be removed with git rm:
```
% git rm foo
% git commit
```
Git does not require deleting the file before using git rm.

### Copying and Moving Files

To move and rename a file:
```
% git mv foo.c bar.c
```

### Log and Annotate

git log shows revisions and commit messages, most recent first, for files or directories. When used on a directory, all revisions that affected the directory and files within that directory are shown.

git annotate, or equally git blame, shows the most recent commit hash and who committed that change for each line of a file.

### Diffs

git diff displays changes in the working tree, or changes between specified version hashes. By default staged changes (i.e., in the index) are *not* shown by `git dff`.

Diffs generated by git are unified and include new files by default in the diff output.

git diff can show the changes between two revisions of the same file:
```
% git diff hash..hash file
```

### Reverting

Local uncommitted changes (including additions and deletions) can be reverted using git reset --hard HEAD.

### Conflicts

If a git command resulted in a merge conflict, Git will remember which files have conflicts and refuse to commit any changes to those files until explicitly told that the conflicts have been resolved. The simple, not yet deprecated procedure is:

## Advanced Use

### Sparse Checkouts

### Direct Operation

Certain operations can be performed directly on the repository without touching the working copy. Specifically, this applies to any operation that does not require editing a file, including:

### Merging with git

This section deals with merging code from one branch to another (typically, from head to a stable branch).

### Vendor Imports with git

Important:

Please read this entire section before starting a vendor import.

Note:

Patches to vendor code fall into two categories:

* Vendor patches: these are patches that have been issued by the vendor, or that have been extracted from the vendor's version control system, which address issues which cannot wait until the next vendor release.
* FreeBSD patches: these are patches that modify the vendor code to address FreeBSD-specific issues.

The nature of a patch dictates where it should be committed:

* Vendor patches must be committed to the vendor branch, and merged from there to head. If the patch addresses an issue in a new release that is currently being imported, it must not be committed along with the new release: the release must be imported and tagged first, then the patch can be applied and committed. There is no need to re-tag the vendor sources after committing the patch.
* FreeBSD patches are committed directly to head.

#### Preparing the Tree

If importing for the first time after the switch to Git, bootstrapping the merge history in the main tree is necessary.

##### Bootstrapping Merge History

If importing for the first time after the switch to Git, bootstrap svn:mergeinfo on the target directory in the main tree to the revision that corresponds to the last related change to the vendor tree, prior to importing new sources:

#### Importing New Sources

#### Merging to Head
```
% cd head/contrib/pf
% svn up
% svn merge --accept=postpone svn+ssh://repo.freebsd.org/base/vendor/pf/dist .
```

#### Committing the Vendor Import

Committing is now possible! Everything must be committed in one go. If done properly, the tree will move from a consistent state with old code, to a consistent state with new code.

### Using a Git Mirror

### Committing High-ASCII Data

## Some Tips

In commit logs etc., the first 12 characters of Git hashes are specified (“f3c8503082ea”) as per convention.
