from __future__ import print_function # used for eprint

import os
import sys
import csv
import math
import struct
import olefile # pip install olefile
import numpy as np


class ExtractError(Exception):
    pass


def read_int(ole, stream):
    s = ole.openstream(stream)
    data = s.read()
    s.close()

    # validate length
    if len(data) != 4:
        raise ExtractError('Expected 4 bytes for "%s"' % stream)

    return struct.unpack('<i', data)[0]


def read_double(ole, stream):
    s = ole.openstream(stream)
    data = s.read()
    s.close()

    # validate length
    if len(data) != 8:
        raise ExtractError('Expected 8 bytes for "%s"' % stream)

    return struct.unpack('<d', data)[0]


def read_data(ole, stream, expected_length=None):
    s = ole.openstream(stream)
    data = s.read()
    s.close()

    # validate length
    if expected_length is not None and len(data) != expected_length:
        raise ExtractError('Expected %d bytes for "%s"' % (expected_length, stream))

    return data


def read_debug(ole, stream):
    s = ole.openstream(stream)
    data = s.read()
    s.close()

    a = ""
    if len(data) > 56:
        data = data[0:56]
        a = "..."

    print("%s: %s%s" % (stream, ":".join("{:02x}".format(ord(c)) for c in data), a))


def _extract_cxd(ole, to_file):
    if not ole.exists('File Info/Field Count'):
        raise ExtractError('Not an HCImage container')

    # number of frames
    expected_frames = read_int(ole, 'File Info/Field Count')

    # only supports single channel
    if ole.exists('File Data/Field 1/i_image2/Details/Binning'):
        raise ExtractError('Unsupported: multiple images per field')
    if ole.exists('File Data/Field 1/i_image1/Bitmap 2'):
        raise ExtractError('Unsupported: multiple bitmaps per image')

    # expected properties based on first frame
    height = int(read_double(ole, 'Field Data/Field 1/i_Image1/Details/Image_Height'))
    width = int(read_double(ole, 'Field Data/Field 1/i_Image1/Details/Image_Width'))
    depth = int(read_double(ole, 'Field Data/Field 1/i_Image1/Details/Image_Depth'))
    bytes_per_pixel = int(math.ceil(depth / 8.))
    bytes_per_frame = width * height * bytes_per_pixel

    # numpy formats
    dtype_read = np.dtype('u%d' % bytes_per_pixel).newbyteorder('<')
    dtype_write = np.dtype('u%d' % bytes_per_pixel)
    # video = np.ndarray((height, width, expected_frames), dtype=np.dtype('u%d' % bytes_per_pixel))

    # open video file
    fn = to_file + '.video'
    with open(fn, 'wb') as f:
        # for each frame
        rows = []
        for frame in range(1, expected_frames + 1):
            # frame details
            time_from_last = read_double(ole, 'Field Data/Field %d/Details/Time_From_Last' % frame)
            time_from_start = read_double(ole, 'Field Data/Field %d/Details/Time_From_Start' % frame)
            cur_exposure = read_double(ole, 'Field Data/Field %d/i_Image1/Details/Image_Exposure1' % frame)

            # image details
            cur_binning = int(read_double(ole, 'Field Data/Field %d/i_Image1/Details/Binning' % frame))
            cur_depth = int(read_double(ole, 'Field Data/Field %d/i_Image1/Details/Image_Depth' % frame))
            cur_height = int(read_double(ole, 'Field Data/Field %d/i_Image1/Details/Image_Height' % frame))
            cur_width = int(read_double(ole, 'Field Data/Field %d/i_Image1/Details/Image_Width' % frame))

            # check expectations
            if cur_depth != depth or cur_height != height or cur_width != width:
                raise ExtractError('Unsupported: change in depth (%d/%d), width (%d/%d) or height (%d/%d)'
                                   % (depth, cur_depth, width, cur_width, height, cur_height))

            # load bitmap
            bitmap_data = read_data(ole, 'Field Data/Field %d/i_Image1/Bitmap 1' % frame, expected_length=bytes_per_frame)
            bitmap_array = np.fromstring(bitmap_data, dtype=dtype_read)

            # write bytes
            bitmap_array.astype(dtype_write).tofile(f)

            # decode
            #video[:, :, frame - 1] = bitmap_array.reshape((height, width))

            # append row
            rows.append((frame, cur_binning, cur_depth, cur_height, cur_width, time_from_last, cur_exposure))

    # write csv
    fn = to_file + '.csv'
    with open(fn, 'w') as f:
        writer = csv.writer(f, doublequote=False, escapechar='\\', lineterminator='\n')
        for row in rows:
            writer.writerow([str(x) for x in row])

    return expected_frames


def extract_cxd(from_cxd, to_file):
    if not olefile.isOleFile(from_cxd):
        raise ExtractError('Not an OLE container')

    # open file
    ole = olefile.OleFileIO(from_cxd)

    try:
        return _extract_cxd(ole, to_file)
    finally:
        ole.close()


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def main():
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print('Usage:')
        print('')
        print('\t%s input-cxd [output-file]' % sys.argv[0])
        print('')
        sys.exit(0 if len(sys.argv) == 1 else 1)

    # read arguments
    in_cxd = sys.argv[1]
    out_file = in_cxd if len(sys.argv) < 3 else sys.argv[2]

    # check for file existence
    if not os.path.isfile(in_cxd):
        eprint('File not found: %s' % in_cxd)
        sys.exit(1)

    if not os.path.isdir(os.path.dirname(out_file)):
        eprint('Directory not found: %s' % os.path.dirname(out_file))
        sys.exit(1)

    # strip extension?
    if '.' in os.path.basename(out_file):
        out_file = os.path.splitext(out_file)[0]

    if os.path.isfile(out_file):
        eprint('Output already exists: %s' % out_file)
        sys.exit(1)

    # extract cxd file
    try:
        extracted = extract_cxd(in_cxd, out_file)
    except ExtractError as e:
        eprint('Error: %s' % e)
        sys.exit(1)
    else:
        print('Extracted %d frames.' % extracted)
        sys.exit(0)

if __name__ == '__main__':
    main()
