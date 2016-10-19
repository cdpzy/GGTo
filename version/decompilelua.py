#!/bin/python

import os
import sys
import xxtea
import getopt
import os.path
import shutil

def outputUsage()
    print "usage: "
    print "     -h show this message. "
    print "     -d input directory."
    print "     -o output directory."
    print "     -k decode key."
    print "     -s decode sign."


def getParameters()
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hd:o:k:s:")
    except getopt.GetopError as err:
        print str(err)
        outputUsage()
        sys.exit(1)

    inputDir = ""
    outputDir = ""
    decodeKey = ""
    decodeSign = ""
    for o, a in opts:
        if o == "-h":
            outputUsage()
            sys.exit(0)
        elif o == "-d":
            inputDir = a
        elif o == "-o":
            outputDir = a
        elif o == "-k":
            decodeKey = a
        elif o == "-s":
            decodeSign = a
        else:
            outputUsage()
            sys.exit(1)

    return inputDir, outputDir, decodeKey, decodeSign

def readFile(filename):
    filehandle = open(filename, "rb")
    content = filehandle.read()
    filehandle.close()
    return content

def trimSign(content, sign):
    if len(content) > len(sign):
        if content[:len(sign)] == sign:
            return content[len(sign)+1:]
    return content

def decode(content, key):
    dec = xxtea.decrypt(content, key)
    return dec

if __name__ == "__main__":
    content = readFile("base_game.luac")
    content = trimSign(content, "hfjsyttetqet")
    content = decode(content, "mianyangyruietdr")
    print content

    # inputDir, outputDir, decodeKey, decodeSign = getParameters()
