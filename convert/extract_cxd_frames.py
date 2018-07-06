from __future__ import print_function # used for eprint

import os
import sys
import csv
import math
import struct
import olefile # pip install olefile
from extract_cxd import ExtractError, read_int, read_double, read_data, read_debug


def _extract_cxd(ole, to_dir, prefix):
    if not ole.exists('File Info/Field Count'):
        raise ExtractError('Not an HCImage container')

    # number of frames
    expected_frames = read_int(ole, 'File Info/Field Count')

    # only supports single channel
    if ole.exists('File Data/Field 1/i_image2/Details/Binning'):
        raise ExtractError('Unsupported: multiple images per field')
    if ole.exists('File Data/Field 1/i_image1/Bitmap 2'):
        raise ExtractError('Unsupported: multiple bitmaps per image')

    # digits
    digits = 1 + int(math.floor(math.log10(expected_frames)))

    # for each frame
    rows = []
    for frame in xrange(1, expected_frames + 1):
        # frame details
        time_from_last = read_double(ole, 'Field Data/Field %d/Details/Time_From_Last' % frame)
        time_from_start = read_double(ole, 'Field Data/Field %d/Details/Time_From_Start' % frame)
        exposure = read_double(ole, 'Field Data/Field %d/i_Image1/Details/Image_Exposure1' % frame)

        # image details
        binning = int(read_double(ole, 'Field Data/Field %d/i_Image1/Details/Binning' % frame))
        depth = int(read_double(ole, 'Field Data/Field %d/i_Image1/Details/Image_Depth' % frame))
        height = int(read_double(ole, 'Field Data/Field %d/i_Image1/Details/Image_Height' % frame))
        width = int(read_double(ole, 'Field Data/Field %d/i_Image1/Details/Image_Width' % frame))

        # load image
        expected_bytes = width * height * int(math.ceil(depth / 8.))
        bitmap = read_data(ole, 'Field Data/Field %d/i_Image1/Bitmap 1' % frame, expected_length=expected_bytes)

        # write bitmap
        fn = '%%0%dd' % digits % frame
        fn = os.path.join(to_dir, prefix + fn + '.frame')
        with open(fn, 'wb') as f:
            f.write(bitmap)

        # append row
        rows.append((frame, binning, depth, height, width, time_from_last, exposure))

    # write csv
    fn = os.path.join(to_dir, prefix + 'frames.csv')
    with open(fn, 'wb') as f:
        writer = csv.writer(f, doublequote=False, escapechar='\\', lineterminator='\n')
        for row in rows:
            writer.writerow([str(x) for x in row])

    return expected_frames


def extract_cxd(from_cxd, to_dir, prefix=None):
    if not olefile.isOleFile(from_cxd):
        raise ExtractError('Not an OLE container')

    # open file
    ole = olefile.OleFileIO(from_cxd)

    try:
        return _extract_cxd(ole, to_dir, '' if prefix is None else prefix)
    finally:
        ole.close()


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def main():
    if len(sys.argv) != 3:
        print('Usage:')
        print('')
        print('\t%s input-cxd output-dir' % sys.argv[0])
        print('')
        sys.exit(0 if len(sys.argv) == 1 else 1)

    # read arguments
    in_cxd = sys.argv[1]
    out_dir = sys.argv[2]

    # check for file existence
    if not os.path.isfile(in_cxd):
        eprint('File not found: %s' % in_cxd)
        sys.exit(1)

    if not os.path.isdir(out_dir):
        eprint('Directory not found: %s' % out_dir)
        sys.exit(1)

    # figure out prefix from file name
    name, _ = os.path.splitext(os.path.basename(in_cxd))
    prefix = name + '_'

    # extract cxd file
    try:
        extracted = extract_cxd(in_cxd, out_dir, prefix)
    except ExtractError as e:
        eprint('Error: %s' % e)
        sys.exit(1)
    else:
        print('Extracted %d frames.' % extracted)
        sys.exit(0)

if __name__ == '__main__':
    main()
