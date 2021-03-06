#!/bin/sh
#
# This test measures the performance of various read-tree
# and status operations.  It is primarily interested in
# the algorithmic costs of index operations and recursive
# tree traversal -- and NOT disk I/O on thousands of files.

test_description="Tests performance of read-tree"

. ./perf-lib.sh

test_perf_default_repo

# If the test repo was generated by ./repos/many-files.sh
# then we know something about the data shape and branches,
# so we can isolate testing to the ballast-related commits
# and setup sparse-checkout so we don't have to populate
# the ballast files and directories.
#
# Otherwise, we make some general assumptions about the
# repo and consider the entire history of the current
# branch to be the ballast.

test_expect_success "setup repo" '
	if git rev-parse --verify refs/heads/p0006-ballast^{commit}
	then
		echo Assuming synthetic repo from many-files.sh &&
		git branch br_base            master &&
		git branch br_ballast         p0006-ballast &&
		git config --local core.sparsecheckout 1 &&
		cat >.git/info/sparse-checkout <<-EOF
		/*
		!ballast/*
		EOF
	else
		echo Assuming non-synthetic repo... &&
		git branch br_base            $(git rev-list HEAD | tail -n 1) &&
		git branch br_ballast         HEAD
	fi &&
	git checkout -q br_ballast &&
	nr_files=$(git ls-files | wc -l)
'

test_perf "read-tree status br_ballast ($nr_files)" '
	git read-tree HEAD &&
	git status
'

test_done
