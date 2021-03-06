#!/bin/sh

git=${1:-freebsd-base.git}
export GIT_DIR=$git

# Fix a whole bunch of svn vendor tags, that are created bogusly and result in
# an extra commit that hangs off the mainline branch. See
# https://github.com/freebsd/git_conv/issues/9 for what this looks like and why
# it happens.

rewrite_tag()
{
    local tag target
    test $# -eq 2 || { echo "wrong number of arguments given: $1 and $2" >&2; exit 1; }
    tag=$1
    target=$2

    c_auth=`git cat-file tag $tag | sed -n '/^tagger/s/^tagger //; s/ [0-9 +]*$//p'`
    c_date=`git cat-file tag $tag | sed -n '/^tagger/s/^tagger //p' | egrep -o '[0-9]* [+0-9]*$'`
    c_msg=`git cat-file tag $tag | sed '1,/^$/d'`
    c_committer=${c_auth%<*}
    c_email=${c_auth#*<}

    old_commit=`git show -s --format=%h "$tag^{commit}"`

    # Move the tag up to the ancestor
    GIT_COMMITTER_DATE="$c_date" GIT_COMMITTER_NAME="$c_committer" GIT_COMMITTER_EMAIL="$c_email" git tag -a -f -m "$c_msg" ${tag} ${target}
    # NOTE: grabs only the 2nd line (with the tag) and then re-edits the note
    # to drop the extra newline in the middle.
    git notes append -m "`git notes show $old_commit|tail -1`" "$tag^{commit}"
    EDITOR="sed -i.bak -e '/^$/d'" git notes edit "$tag^{commit}"
}

git --git-dir=$git for-each-ref --format='%(refname:short)' refs/tags |
    egrep -v "^(backups|release)/" |
    while read rev; do
        tag_tree=`git --git-dir=$git show -s --format=%t "$rev^{}"`
        parent_tree=`git --git-dir=$git show -s --format=%t "$rev~1" 2>/dev/null`
        # parent might not exists, like for example for
        # backups/cvs2svn/which@13122 which is a single, lone commit.
        [ -z "$parent_tree" ] && continue
        if [ $tag_tree = $parent_tree ]; then
            rewrite_tag $rev $rev~1
        fi
    done

# r221422 tagged a single file, as the vendor tree just has a single *new*
# file. This is however a file copy, not a dir copy and we end up with an extra
# commit object. Patch it up.
if git rev-parse -q --verify vendor/v4l/2.6.17~1 >/dev/null; then
    rewrite_tag vendor/v4l/2.6.17 `git log --format=%h --notes --grep='revision=221421$' vendor/v4l/dist`
fi

# Something else was merged into the commit, point to the commit on dist instead
if git rev-parse -q --verify vendor/illumos/20120614\^2 >/dev/null; then
    rewrite_tag vendor/illumos/20120614 `git log --format=%h --notes --grep='revision=238587$' vendor/illumos/dist`
fi

# vendor/sendmail/8.13.3 had files removed, later done in mainline
# vendor/sendmail/8.12.3 ditto, though removal was done much later
if git rev-list vendor/sendmail/dist..vendor/sendmail/8.12.3|wc -l|grep -q 1; then
    rewrite_tag vendor/sendmail/8.12.3 `git log --format=%h --notes --grep='revision=95152$' vendor/sendmail/dist`
fi
if git rev-list vendor/sendmail/dist..vendor/sendmail/8.13.3|wc -l|grep -q 1; then
    rewrite_tag vendor/sendmail/8.13.3 `git log --format=%h --notes --grep='revision=141865$' vendor/sendmail/dist`
fi

# vendor/openpam/HYDRANGEA had its tag slipped
if git rev-list vendor/openpam/dist..vendor/openpam/HYDRANGEA|wc -l|grep -q 1; then
    rewrite_tag vendor/openpam/HYDRANGEA `git log --format=%h --notes --grep='revision=174835$' vendor/openpam/dist`
fi

# vendor/groff/1.17 tag was slipped after some files were deleted ... twice
if git rev-list vendor/groff/dist..vendor/groff/1.17|wc -l|grep -q 1; then
    rewrite_tag vendor/groff/1.17 `git log --format=%h --notes --grep='revision=75587$' vendor/groff/dist`
fi
if git rev-list vendor/groff/dist..vendor/groff/1.17.2|wc -l|grep -q 1; then
    rewrite_tag vendor/groff/1.17.2 `git log --format=%h --notes --grep='revision=79546$' vendor/groff/dist`
fi
if git rev-list vendor/groff/dist..vendor/groff/1.18.1 | wc -l | grep -q 1; then
    rewrite_tag vendor/groff/1.18.1 `git log --format=%h --notes --grep='revision=104865$' vendor/groff/dist`
fi
if git rev-list vendor/groff/dist..vendor/groff/1.19 | wc -l | grep -q 1; then
    rewrite_tag vendor/groff/1.19 `git log --format=%h --notes --grep='revision=114405$' vendor/groff/dist`
fi
if git rev-list vendor/groff/dist..vendor/groff/1.19.2 | wc -l | grep -q 1; then
    rewrite_tag vendor/groff/1.19.2 `git log --format=%h --notes --grep='revision=151500$' vendor/groff/dist`
fi


# vendor/ncurses/5.2-20010512 had a file deletion slipped into it
if git rev-list vendor/ncurses/dist..vendor/ncurses/5.2-20010512|wc -l|grep -q 1; then
    rewrite_tag vendor/ncurses/5.2-20010512 `git log --format=%h --notes --grep='revision=76732$' vendor/ncurses/dist`
fi
# ditto
if git rev-list vendor/ncurses/dist..vendor/ncurses/5.2-20020518|wc -l|grep -q 1; then
    rewrite_tag vendor/ncurses/5.2-20020518 `git log --format=%h --notes --grep='revision=97055$' vendor/ncurses/dist`
fi
# vendor/ncurses/5.6-20061217
if git rev-list vendor/ncurses/dist..vendor/ncurses/5.6-20061217 | wc -l | grep -q 1; then
    rewrite_tag vendor/ncurses/5.6-20061217 `git log --format=%h --notes --grep='revision=166133$' vendor/ncurses/dist`
fi
# vendor/ncurses/5.6-20071222
if git rev-list vendor/ncurses/dist..vendor/ncurses/5.6-20071222 | wc -l | grep -q 1; then
    rewrite_tag vendor/ncurses/5.6-20071222 `git log --format=%h --notes --grep='revision=174996$' vendor/ncurses/dist`
fi

# vendor/bzip2/1.0.4
if git rev-list vendor/bzip2/dist..vendor/bzip2/1.0.4 | wc -l | grep -q 1; then
    rewrite_tag vendor/bzip2/1.0.4 `git log --format=%h --notes --grep='revision=167984$' vendor/bzip2/dist`
fi
# vendor/diff/2.8.7
if git rev-list vendor/diff/dist..vendor/diff/2.8.7 | wc -l | grep -q 1; then
    rewrite_tag vendor/diff/2.8.7 `git log --format=%h --notes --grep='revision=170759$' vendor/diff/dist`
fi
# vendor/file/5.00
if git rev-list vendor/file/dist..vendor/file/5.00 | wc -l | grep -q 1; then
    rewrite_tag vendor/file/5.00 `git log --format=%h --notes --grep='revision=191773$' vendor/file/dist`
fi
# vendor/less/v415
if git rev-list vendor/less/dist..vendor/less/v415 | wc -l | grep -q 1; then
    rewrite_tag vendor/less/v415 `git log --format=%h --notes --grep='revision=173686$' vendor/less/dist`
fi
# vendor/libuwx/BETA10
if git rev-list vendor/libuwx/dist..vendor/libuwx/BETA10 | wc -l | grep -q 1; then
    rewrite_tag vendor/libuwx/BETA10 `git log --format=%h --notes --grep='revision=160160$' vendor/libuwx/dist`
fi
# vendor/ntp/4.1.1a
if git rev-list vendor/ntp/dist..vendor/ntp/4.1.1a | wc -l | grep -q 1; then
    rewrite_tag vendor/ntp/4.1.1a `git log --format=%h --notes --grep='revision=106167$' vendor/ntp/dist`
fi

# Sigh, this was done the wrong way round. Some commits add the "tag" first,
# then copy to /dist, or they commit to both at the same time. This leads to a
# disconnected history, actually. We can patch it up by overriding the stray
# tag to point to something on the mainline.
if git rev-list vendor/alpine-hal/dist..vendor/alpine-hal/2.7a | wc -l | grep -q 2; then
    rewrite_tag vendor/alpine-hal/2.7a `git log --format=%h --notes --grep='revision=306016$' vendor/alpine-hal/dist`
fi
