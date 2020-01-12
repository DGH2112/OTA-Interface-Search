# Contributing to Open Tools API Interface Search

Please try and follows the things that are layed out below as it will make it easier to accept a pull request however not following the below does not necessarily exclude a pull request from being accepted.

## Git Flow

For [Open Tools API Interface Search](https://www.davidghoyle.co.uk/WordPress/?page_id=1481) I use Git as the version control but I also use [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) for the development cycles. The main development is undertaken in the **Development** branch with stable releases being in the **master**. All pull requests should be made from the **Development** branch, prefereably using **Feature** branches or **BugFix** branches. I've defined prefixes for these already in the `.gitconfig` file. You should submit onyl one change per pull request at a time to make it easiler to review and accept the pull request.

Tools wise, I generally use [SourceTree](https://www.sourcetreeapp.com/) but that does not support Git Flow's **BugFix** functionality so I drop down to the command prompt to create **BugFix** branches as SourceTree can _Finish_ any type of open branch in Git Flow.

## Creating Pull Requests

Having not done this before as I've always been the sole contributor to my repositories so I borrowed the essense of the following from the [DUnitX](https://github.com/VSoftTechnologies/DUnitX) project:

1. Create a GitHub Account (https://github.com/join);
2. Fork the [Open Tools API Interface Search](https://www.davidghoyle.co.uk/WordPress/?page_id=1481)
   Repository and setup your local repository as follows:
     * Fork the repository (https://help.github.com/articles/fork-a-repo);
     * Clone your Fork to your local machine;
     * Configure upstream remote to the **Development**
       [Open Tools API Interface Search](https://www.davidghoyle.co.uk/WordPress/?page_id=1481)
       repository (https://github.com/DGH2112/Integrated-Testing-Helper);
3. For each change you want to make:
     * Create a new **Feature** or **BugFix** branch for your change;
     * Make your change in your new branch;
     * **Verify code compiles for ALL supported RAD Studio version (see below) and unit tests still pass**;
     * Commit change to your local repository;
     * Push change to your remote repository;
     * Submit a Pull Request (https://help.github.com/articles/using-pull-requests);
     * Note: local and remote branches can be deleted after pull request has been accepted.

**Note:** Getting changes from others requires [Syncing your Local repository](https://help.github.com/articles/syncing-a-fork) with the **Development** [Open Tools API Interface Search](https://www.davidghoyle.co.uk/WordPress/?page_id=1481) repository. This can happen at any time.

## Dependencies

[Open Tools API Interface Search](https://www.davidghoyle.co.uk/WordPress/?page_id=1481) has two dependecnies:
 * Virtual Treeview;
 * SynEdit.

## Project Configuration

The [Open Tools API Interface Search](https://www.davidghoyle.co.uk/WordPress/?page_id=1481) Open Tools API project uses a single projects file (`.DPR`) and should be compatible with RAD Studio XE3 and above (a limitation of the  version of Virtual Trees being used).

## Rationale

The following is a brief description of the rationale behind [Open Tools API Interface Search](https://www.davidghoyle.co.uk/WordPress/?page_id=1481). I will hopefully write more later.

It uses regular expressions to search the types (class, interfaces, etc), their methods and property for the search value asked for.

regards

David Hoyle Jan 2020