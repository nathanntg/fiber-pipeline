from __future__ import print_function # used for eprint

import os
import re
import sys
import tempfile
import matlab.engine
from extract_cxd import extract_cxd, ExtractError


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)



def _cxd_to_mat(dir_in, file_cxd, dir_temp, dir_out):
    # step 1. extract cxd file
    try:
        extract_cxd(file_cxd, dir_temp)
    except ExtractError as e:
        print('Extraction error: %s' % e)
        raise Exception('Failed')

    # step 2. run matlab
    eng = matlab.engine.start_matlab()
    try:
        eng.combine_audio_video(dir_temp, '', dir_in, dir_out, nargout=0)
    except matlab.engine.MatlabExecutionError as e:
        print('MATLAB Error: %s' % e)
        raise Exception('Failed')
    finally:
        eng.quit()


def main():
    if len(sys.argv) != 3:
        print('Usage:')
        print('')
        print('\t%s raw-dir synced-dir' % sys.argv[0])
        print('')
        sys.exit(0 if len(sys.argv) == 1 else 1)

    # read arguments
    dir_in = sys.argv[1]
    dir_out = sys.argv[2]

    # check for file existence
    if not os.path.isdir(dir_in):
        eprint('Directory not found: %s' % dir_in)
        sys.exit(1)

    if not os.path.isdir(dir_out):
        # automatically create directory
        dir_parent = os.path.dirname(dir_out)
        if not os.path.isdir(dir_parent):
            eprint('Directory not found: %s' % dir_parent)
            sys.exit(1)

        # create directory
        os.mkdir(dir_out)
    else:
        if len([x for x in os.listdir(dir_out) if x[-4:] == '.mat']) > 0:
            eprint('Directory not empty: %s' % dir_out)
            sys.exit(1)

    # find CXD file
    re_cxd = re.compile(r'\.cxd$', re.I)
    cxd = [os.path.join(dir_in, x) for x in os.listdir(dir_in) if re_cxd.search(x)]
    if len(cxd) != 1:
        eprint('Expected exactly 1 CXD file')
        sys.exit(1)

    # make temporary folder
    dir_temp = tempfile.mkdtemp()
    try:
        # run conversion
        _cxd_to_mat(dir_in, cxd[0], dir_temp, dir_out)
    except Exception as e:
        eprint('Error: %s' % e)
        sys.exit(1)
    else:
        print('Done!')
        sys.exit(0)
    finally:
        # clean up
        for x in os.listdir(dir_temp):
            os.remove(os.path.join(dir_temp, x))
        os.rmdir(dir_temp)

if __name__ == '__main__':
    main()
