# Contributing

First, thank you for contributing to Cocmd! The goal of this document is to provide everything you need to start contributing to cocmd.

## Your First Contribution

1. [Fork the cocmd repository](https://github.com/cocmd/hub/fork) into your own GitHub account.
1. [Create a new Git branch](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-and-deleting-branches-within-your-repository).
1. Checkout `master` branch.
1. Make your changes.
1. [Submit the branch as a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork) to the main cocmd repo. An cocmd team member should comment and/or review your pull request within a few days. Although, depending on the circumstances, it may take longer.

## Workflow

### Git Branches

*All* changes must be made in a branch and submitted as [pull requests](#github-pull-requests). cocmd does not adopt any type of branch naming style, but please use something descriptive of your changes.

### GitHub Pull Requests

Once your changes are ready you must submit your branch as a [pull request](https://github.com/cocmd/hub/pulls).

#### Title

The pull request title must follow the format outlined in the [conventional commits spec](https://www.conventionalcommits.org). [Conventional commits](https://www.conventionalcommits.org) is a standardized format for commit messages. cocmd only requires this format for commits on the `main` branch. And because cocmd squashes commits before merging branches, this means that only the pull request title must conform to this format.

#### Reviews & Approvals

All pull requests should be reviewed by at least one cocmd committer.


### CI

Currently, cocmd uses GitHub Actions to run tests. The workflows are defined in `.github/workflows`.

## Setup

1. Install Cocmd (see Getting Started)[https://cocmd.org/docs/intro/]
1. Install this repo path as a package:
```bash
# from the root of this project
cocmd install ./packages
```
1. Now this repo on you machine is runnable by cocmd. run 
```bash
cocmd show packages
```
to make sure.