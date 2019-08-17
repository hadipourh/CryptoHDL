# CryptoHDL
A list of VHDL codes implementing cryptographic algorithms

## Motivation

The motivation of creating this repository is to have a centralized point where all VHDL implementation of cryptographic algorithms can be fund. I do my best to keep it updated. If you find or have any VHDL implementation of cryptographic algorithm that are missing, don't hesitate 
to contribute.

## Contents

1. [CRAFT](#craft)
2. [AES](#aes1)
3. [Skinny](#skinny1)
4. [Skinny64](#skinny2)

1. [License](#license)

<a name="craft"></a>
## CRAFT

*This repository includes the hardware designs of CRAFT cipher*

* Developers: [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/CRAFT)
* Paper: [Lightweight Tweakable Block Cipher with Efficient Protection Against DFA Attacks. IACR Trans. Symmetric Cryptol. 2019]((https://eprint.iacr.org/2019/210)

There are 6 folders for the VHDL source code of different implementations of CRAFT. Apart from the unprotected implementation, all other designs MUST be synthesized by "keeping the hierarchy". Otherwise, no fault-detection and no protection against SCA is guaranteed. (https://sites.google.com/view/craftcipher/implementation).

<a name="aes1"></a>
## AES

*This repository includes the hardware designs of AES cipher*

* Developers: [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/AES)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

There are 3 folders for the VHDL source code of different implementations of AES. Apart from the unprotected implementation, all other designs MUST be synthesized by "keeping the hierarchy". Otherwise, no fault-detection and no protection against SCA is guaranteed.

<a name="skinny1"></a>
## Skinny

*This repository includes the hardware designs of Skinny64 and Skinny128 ciphers*

* Developers: [P. Sasdrich](https://www.emsec.ruhr-uni-bochum.de/chair/_staff/Pascal_Sasdrich/)
* [Official Repository](https://sites.google.com/site/skinnycipher/implementation)
* Paper: [The SKINNY Family of Block Ciphers and its Low-Latency Variant MANTIS](https://eprint.iacr.org/2016/660)
* [Location within this repository](https://github.com/hadipourh/CryptoHDL/tree/master/Skinny)

SKINNY is a family of very lightweight tweakable block ciphers.

<a name="skinny2"></a>
## Skinny64

*This repository includes the hardware designs of Skinny64 cipher with protection against SCA*

* Developers: [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/Skinny64)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

<a name="license"></a>
# License
To do
