# 2024-06

- Switch base image to `ubuntu:jammy` instead, we could solve the dependencies to work with latest version (noble), but it came with `python3.12` which seems to have problem with `pytorch` multiprocessing according to this [issue](https://github.com/pytorch/pytorch/issues/125990).
