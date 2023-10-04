# -*- coding:utf-8 -*-
from __future__ import division

import sys

sys.path.append('../../udm/sw')
import udm
from udm import *

import sigma
from sigma import *


udm = udm('COM13', 921600)
print("")

sigma = sigma(udm)
# sigma.run_app_tests()
if (hw_test_sha256(sigma, 'apps/sha256.riscv') == 1):
    print("TEST SHA256 PASSED!")
else:
    print("TEST SHA256 FAILED!")

udm.disconnect()
