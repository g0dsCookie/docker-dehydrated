#!/usr/bin/env python3
import subprocess
import os
import os.path
import argparse
from datetime import datetime
from threading import Thread, Lock
from sys import exit
import sys

LOGDIR = "logs"

PRINT_LOCK = Lock()

tag = "g0dscookie/dehydrated"

prefix = "g0dscookie"
service = "dehydrated"
tag = "{}/{}".format(prefix, service)

versions = {
    "0.6.1": {
        "latest": False,
    },
    "0.6.2": {
        "latest": True,
    }
}

def check_version(version):
    if not version in versions:
        raise Exception("Unknown {} version {}".format(service, version))

def get_config(ver, cfg):
    check_version
    tmp = versions[ver][cfg]
    if type(tmp) is str:
        return get_config(tmp, cfg)
    elif type(tmp) is dict:
        return get_config(tmp["base"], cfg) + tmp["my"]
    else:
        return tmp

def build_tags(ver, latest):
    tags = []
    if latest:
        tags.extend(("-t", "{}:latest".format(tag)))
    tags.extend((
        "-t", "{}:{}".format(tag, ver[0]),
        "-t", "{}:{}.{}".format(tag, ver[0], ver[1]),
        "-t", "{}:{}.{}.{}".format(tag, ver[0], ver[1], ver[2]),
        "-t", "{}:{}.{}.{}-{}".format(tag, ver[0], ver[1], ver[2], datetime.utcnow().strftime("%Y-%m-%d-%H-%M-%S"))
    ))
    return tags

def build_args(ver):
    return [
        "--build-arg", "MAJOR={}".format(ver[0]),
        "--build-arg", "MINOR={}".format(ver[1]),
        "--build-arg", "PATCH={}".format(ver[2]),
    ]

def docker_build(ver):
    PRINT_LOCK.acquire()
    print("Building {}-{}...".format(tag, ver))
    PRINT_LOCK.release()

    tags = build_tags(ver.split("."), versions[ver]["latest"])
    bargs = build_args(ver.split("."))

    if not os.path.isdir(LOGDIR):
        os.mkdir(LOGDIR)

    if LOGDIR == "stdout":
        stdout = sys.stdout
        stderr = sys.stderr
    else:
        stdout = open(os.path.join(LOGDIR, "{}-{}.log".format(service, ver)), mode="w")
        stderr = open(os.path.join(LOGDIR, "{}-{}.err".format(service, ver)), mode="w")
    ret = subprocess.call(["docker", "build"] + tags + bargs + ["."], stdout=stdout, stderr=stderr)

    if LOGDIR != "stdout":
        stdout.close()
        stderr.close()
    
    if ret != 0:
        print("\"{}\" returned non-zero exit code: {}".format(" ".join(["docker", "build"] + tags + bargs + ["."]), ret))
        exit(ret)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="{} build script".format(tag))
    parser.add_argument("--version", default="all", type=str, help="Set the version to build (Defaults to %(default)s")
    parser.add_argument("-l", "--logdir", metavar="LOGDIR", default="logs", type=str, help="Set the log directory (Defaults to %(default)s")
    parser.add_argument("--stdout", action='store_true', help="Output to stdout instead of log file.")

    args = parser.parse_args()
    LOGDIR = args.logdir
    if args.stdout:
        LOGDIR = "stdout"

    if args.version == "all":
        if args.stdout:
            for ver in versions:
                docker_build(ver)
        else:
            threads = []
            for ver in versions:
                t = Thread(target=docker_build, args=(ver,))
                t.start()
                threads.append(t)
            for t in threads:
                t.join()
    elif args.version == "latest":
        for ver in versions:
            if versions[ver]["latest"]:
                docker_build(ver)
                exit(0)
        raise Exception('No "latest" version specified!')
    else:
        docker_build(args.version)