Last review: 2024-07-21

# Overview

`tfsplit` is a tool that allows refactoring terraform state by moving resource blocks around in a
file system. It works with either `terraform` or `OpenTofu`. It works by creating a directory structure
with separate JSON files for each resource where paths in the file system correspond to module
paths. Using `tfsplit`, you can refactor state with this workflow:
* Make sure your project is clean
* Run `terraform state pull`
* Run `tfsplit --action split` to split the state file into a directory structure
* Refactor the terraform project, including splitting and merging projects
* Rename/move files and directories in the split state, potentially across projects, to construct a
  directory structure that matches the refactored code
* Run `tfsplit --action merge` to reconstruct state for the reorganized resources
  * If updating a project in place, use the `--serial-from` option to preserve lineage
  * If creating a new project, run `terraform init`
* Use `terraform state push` to push the new state in all projects
* Run `terraform plan` to make sure things are clean (except outputs, which are not kept by
  `tfsplit`)
* Run `terraform apply` to regenerate outputs and repopulate the state with data sources

Splitting a project into multiple projects, merging projects, or moving objects from one project to
another is much easier using this approach than manually editing state files or using mixtures of
`terrform state` and `terraform import` commands.

Data sources and outputs are not preserved, so it is necessary to run `terraform apply` on the
resulting project.

# Examples

* Splitting a `for_each` into separate projects:
  * Each instance of the `for_each` will be called `something["key"]`
  * Create separate directories for each new project
  * Move each `something["key"]` from the old directory to just `something` in the new directory
* Moving a collection of resources into or out of a module
  * Just move the files in or out of a directory

# Case Study

This was used to split a project that had a module invocation for each of several "instances" into a
separate project for each instance. The terraform was refactored to change a module invocation with
`for_each` in one file to separate projects, each of which contained a single top-level module
invocation.

Changing the terraform code was a normal refactoring exercise. Updating the state was as follows:

Split the state of the original project into `/tmp/z`:
```
cd instances
terraform state pull >| orig.tfstate
tfsplit --action split --dir /tmp/z --state orig.tfstate
```

Then create a new temporary directory for each instance, and move things from /tmp/z into the new
directories, renaming them to remove the `for_each key`. For example, if /tmp/z contains
`module.x[key]` and `module.y[key]` for each key `"one"` and `"two"`, you could create directories
`/tmp/one` and `/tmp/two`, and distribute the modules into each directory, removing the key. For
example:

```
mkdir /tmp/one
mv '/tmp/z/module.x["one"]' /tmp/one/module.x
mv '/tmp/z/module.y["one"]' /tmp/one/module.y
mkdir /tmp/two
mv '/tmp/z/module.x["two"]' /tmp/two/module.x
mv '/tmp/z/module.y["two"]' /tmp/two/module.y
```

Then, in each project directory, create the terraform code as needed. Create the state with the
merge operation:

```
tfsplit --action merge --dir /tmp/$i --state new.tfstate
terraform init
terraform state push new.tfstate
terraform apply
```

If `terraform apply` is clean (no prompts), it will have updated the state to restore dependencies,
outputs, and data blocks, which `tfsplit` discards.

By moving all the objects out of /tmp/z, you can make sure you haven't forgotten anything. When
done, the old project's state can be removed and the project can be discarded.

# Testing

Run `./run_tests`. This does basic end-to-end testing on a sample project with `local_file`
resources to exercise all the functionality of `tfsplit`.

# Notes

The new state file has a random `"lineage"` uuid and a serial number of 1. If you are using this to
refactor an existing project rather than creating a new one, use `--serial-from old.tfstate`, which
copies `"lineage"` from the old project and sets `"serial"` to the next higher number from the old
state. Then you can use `terraform state push` to overwrite the old state with the new state.
