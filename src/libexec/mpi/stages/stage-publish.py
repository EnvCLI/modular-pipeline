#! /usr/bin/env python3
# -*- coding: utf-8 -*-
import subprocess # to call system commands

###
# Publish Script
###

# arguments (available as args.name)
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--echo", default="test", help="echo the string you use here")
args = parser.parse_args()

# iterate over all artifacts

print(args.echo)


print("HELLO WORLD")
subprocess.call(["ls", "-l"], shell=True)

# import pathlib
# print(pathlib.Path('yourPathGoesHere').suffix)
