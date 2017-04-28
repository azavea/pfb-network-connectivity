#!/usr/bin/env python

""" A little utility script to take a bounding box, a number of partitions, and the number for
which partition is desired, and return a piece of the bounding box that's 1/num_parts wide.
"""

import sys

try:
    args = sys.argv[1].split(' ')
    (w, s, e, n) = [float(val) for val in args[0:4]]
    (num_parts, part) = [int(val) for val in args[4:6]]
    if part <= 0 or part > num_parts:
        raise Exception("Invalid bounding box partition: part {} of {}".format(part, num_parts))
except:
    sys.stderr.write("""
    Usage: {} W S E N NUM_PARTS PART

    Given bounding box, number of partitions, and which partition to return, breaks the box up
    horizontally into NUM_PARTS sections and returns the given section (1-indexed).

    argv was {}
    """.format(sys.argv[0], ' '.join(sys.argv[1:])))
    print "argv: ", sys.argv
    print "argv length: ", len(sys.argv)
    print "part {}, num_parts {}".format(part, num_parts)
    exit(1)

diff = (e - w) / num_parts
new_e = w + (part * diff)
print ' '.join([str(val) for val in new_e - diff, s, new_e, n])
