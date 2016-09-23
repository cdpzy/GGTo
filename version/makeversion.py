#!/bin/python

import os
import sys
import shutil
import md5
import platform
import getopt
import datetime

outfilename = "version.lua"

# test architecture && platform && system && python_version
def testPlatform():
    print ("---------------------operation system-------------------------------")
    print (platform.architecture())
    print (platform.platform())
    # Returns the system/OS name, e.g. 'Linux', 'Windows' or 'Java'.
    # An empty string is returned if the value cannot be determined.
    print (platform.system())
    print (platform.python_version())


def genFileMD5(filepath):
    m = md5.new()
    fobj = open(filepath)
    while True:
        d = fobj.read(8096)
        if not d:
            break
        m.update(d)
    return m.hexdigest()

def outputUsage():
    print "usage:"
    print "     -h print this help information"
    print "     -d directory to loop up"
    print "     -o output file name"

def getParameters():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hd:o:")
    except getopt.GetopError as err:
        print str(err)
        outputUsage()
        sys.exit(1)

    directory = None
    outFileName = "version.lua"

    for o, a in opts:
        if o == "-h":
            outputUsage()
            sys.exit(0)
        elif o == "-d":
            directory = a
        elif o == "-o":
            outFileName = a
        else:
            outputUsage()
            sys.exit(1)
    
    if directory is None:
        outputUsage()
        sys.exit(1)

    return directory, outFileName

def getStartIndent(depth):
    return "\t" * depth

fileNameFilters = [".DS_Store", ".gitignore", ".gitattributes"]
dirNameFilters = [".svn", ".git"]

def needFilterOut(dirpath):
    originPaths = dirpath.split("/")
    for df in dirNameFilters:
        if df in originPaths:
            return True

    return False

def generateVersionInfo(directory, outfile, depth):
    for dirpath, dirnames, filenames in os.walk(directory):
        if needFilterOut(dirpath):
            continue

        for filename in filenames:
            if filename in fileNameFilters:
                continue

            filepath = os.path.join(dirpath, filename)
            signature = genFileMD5(filepath)
            writeinfo = getStartIndent(depth) + '["%s"] = "%s",\n' % (filepath, signature)
            outfile.write(writeinfo)

# usage: -d rootdir -e exclude -o outfile
if __name__ == '__main__':
    directory, outFileName = getParameters()

    outfile = open(outFileName, "wb")
    outfile.write("--auto generated  " + datetime.date.today().isoformat() + "\n")
    outfile.write("local version = {\n")
    generateVersionInfo(directory, outfile, 1)
    outfile.write("}\nreturn version\n")
    outfile.close()

