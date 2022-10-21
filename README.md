Last review: 2022-10-21

# Overview

This tool splits a terraform state file into a directory structure containing separate JSON files for each resource and then merges that directory structure back into a terraform state file. This makes it easy to do bulk refactoring of state files in conjunction with refactoring of code.

Splitting a project into multiple projects, merging projects, or moving objects from one project to another is much easier using this approach than manually editing state files or using mixtures of `terrform state` and `terraform import` commands.

# Examples

* Splitting a for_each into separate projects:
  * Each instance of the for_each will be called `something["key"]`
  * Create separate directories for each new project
  * Move each `something["key"]` from the old directory to just `something` in the new directory
* Changing the name of a module
  * Just rename the module directory. No need to `terraform state mv` each item in the module.
* Moving a collection of resources into or out of a module
  * Just move the files in or out of a directory

# Case Study

This was used to split a project that had a module invocation for each of several "instances" into a separate project for each instance. The terraform was refactored to change a module invocation with `for_each` in one file to separate projects, each of which contained a single top-level module invocation.

Changing the terraform code was a normal refactoring exercise. To change the state, the basic workflow was

```
cd instances
terraform state pull >| orig.tfstate
tf-split --action split --dir /tmp/z --state orig.tfstate
```

Then create a new temporary directory for each instance, and move things from /tmp/z into the new directories, renaming them to remove the `for_each key`. For example, if /tmp/z contains `modules.x[key]` and `modules.y[key]` for each key `"one"` and `"two"`, you could create directories `/tmp/one` and `/tmp/two`, and distribute the modules into each directory, removing the key. For example:

```
for i in one two; do mkdir -p /tmp/$i; mv /tmp/z/modules.*\"$i\"* /tmp/$i; done
patmv 's/\[.*//' */z/modules.*
```

Then, in each project directory, create the terraform code as needed. Create the state with the merge operation:

```
tf-split --action merge --dir /tmp/$i --state new.tfstate
terraform init
terraform state push new.tfstate
terraform apply
```

If `terraform apply` is clean (no prompts), it will have updated the state to restore dependencies, outputs, and data blocks, which `tf-split` discards.

By moving all the objects out of /tmp/z, you can make sure you haven't forgotten anything. When done, the old project's state can be removed and the project can be discarded.

# Testing

As of the initial implementation, there are no automated tests, but the `tests/tf` directory contains a project that can be used for experimentation.

# Notes

The new state file has a random `"lineage"` uuid and a serial number of 1. If you are using this to refactor an existing project rather than creating a new one, copy `"lineage"` from the old project and set `"serial"` to the next higher number from the old state. Then you can use `terraform state push` to overwrite the old state with the new state.
