# -*- coding:utf-8 -*-
from __future__ import division

import sys
sys.path.append('../../../../../rtl/udm/sw')

import time

import udm
from udm import *

sys.path.append('..')
import sigma
from sigma import *

def hw_test_sha256(sigma, firmware_filename):
    
    verify_data = [
        0xb38d5f18, 0x25fe7122, 0xfca661f5, 0x262e8b93, 0x30ec0643, 0x8051da4e, 0x4876d107, 0x69193826
    ]
    
    return sigma.hw_test_generic(sigma, "sha256", firmware_filename, 0.1, verify_data)
