from __future__ import print_function # used for eprint

import os
import sys
import scipy
from scipy import ndimage
import numpy as np
import matplotlib.pyplot as plt


def load_video(fl, width=2048, height=2048, bytes_per_pixel=2):
    dtype_read = np.dtype('u%d' % bytes_per_pixel)
    return np.fromfile(fl, dtype=dtype_read).reshape((height, width, -1), order='F')


def show_image(im, scale=None):
    plt.figure()
    plt.imshow(im)


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def main():
    if len(sys.argv) != 2:
        print('Usage:')
        print('')
        print('\t%s input-video' % sys.argv[0])
        print('')
        sys.exit(0 if len(sys.argv) == 1 else 1)

    # read arguments
    in_video = sys.argv[1]

    # check for file existence
    if not os.path.isfile(in_video):
        eprint('File not found: %s' % in_video)
        sys.exit(1)

    # load video
    video = load_video(in_video)

    # show frame
    show_image(video[:, :, 0])

    # show mask
    mn = np.min(video, axis=2)
    mask = ndimage.grey_dilation(mn, size=(10, 10)) > 3000.

    # calculate standard deviation
    std = np.std(video, axis=2, dtype=np.float32)
    std[mask] = 0.
    show_image(std)

    print(video.shape)

    plt.show()
    sys.exit(0)

if __name__ == '__main__':
    main()
