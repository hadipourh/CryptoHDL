# CryptoHDL
A list of VHDL codes implementing cryptographic algorithms

## Motivation

The motivation of creating this repository is to have a centralized point where all VHDL implementation of cryptographic algorithms can be fund. I do my best to keep it updated. If you find or have any VHDL implementation of cryptographic algorithm that are missing, don't hesitate 
to contribute.

## Contents

1. [CRAFT](#craft)

<a name="craft"></a>
## lineartrails

*This repository includes the hardware designs of CRAFT cipher*

* Developers: [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/CRAFT)
* Paper: [Lightweight Tweakable Block Cipher with Efficient Protection Against DFA Attacks. IACR Trans. Symmetric Cryptol. 2019]((https://eprint.iacr.org/2019/210)

There are 6 folders for the VHDL source code of different implementations of CRAFT. Apart from the unprotected implementation, all other designs MUST be synthesized by "keeping the hierarchy". Otherwise, no fault-detection and no protection against SCA is guaranteed. (https://sites.google.com/view/craftcipher/implementation).
