# CryptoHDL
A list of VHDL codes implementing cryptographic algorithms

## Motivation

The motivation of creating this repository is to have a centralized point where all VHDL implementation of cryptographic algorithms can be found. I do my best to keep it updated. If you find or have any VHDL implementation of cryptographic algorithm that are missing, don't hesitate to contribute. :smile:

## Contents
1. [AES](#aes1)
2. [Ascon](#ascon)
3. [CRAFT](#craft)
4. [GIFT](#gift1)
5. [Gimli](#gimli)
6. [KATAN](#katan1)
7. [KTANTAN](#ktantan1)
8. [Klein](#klein1)
9. [LED128](#led128_1)
10. [LED64](#led64_1)
11. [LowMC](#lowmc)
12. [Midori](#midori1)
13. [Piccolo](#piccolo)
14. [Picnic](#picnic)
15. [PRESENT](#present1)
16. [Prince](#prince1)
17. [Simon](#simon1)
18. [Skinny](#skinny1)
19. [Skinny64](#skinny2)


<a name="aes1"></a>
## AES

*VHDL implementation of AES encryption, and decryption algorithms*

* Developers: [Hosein Hadipour](https://github.com/hadipourh)
* [Official Repository](https://github.com/hadipourh/AES-VHDL)

There are simple VHDL implementations of AES-128 encryption, and decryption algorithms, in this repository. This is actually my first experience in VHDL implementation! (https://hadipourh.github.io/AES-VHDL/).

*This repository includes the hardware designs of AES cipher*

* Developers: [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/AES)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

There are 3 folders for the VHDL source code of different implementations of AES. Apart from the unprotected implementation, all other designs MUST be synthesized by "keeping the hierarchy". Otherwise, no fault-detection and no protection against SCA is guaranteed.

<a name="ascon"></a>
## Ascon

*Energy Efficient Hardware Implementations of Ascon*

* Developers: [Michael Fivez](https://github.com/michaelfivez)
* [Official Repository](https://github.com/michaelfivez/ascon_hardware_implementation)
* Master Thesis: [Energy Efficient Hardware Implementations of CAESAR Submissions-2016](https://www.esat.kuleuven.be/cosic/publications/thesis-279.pdf)

Energy-efficient implementations of Ascon-128 and Ascon-128a by Michael Fivez, including a comparison with Joltik and MORUS. This repository contains several implementations of the Ascon hardware cipher.

*Side-channel protected hardware implementations of Ascon*

* Developers: [Hannes Groß](https://github.com/hgrosz)
* [Official Repository](https://github.com/hgrosz/ascon_dom)
* Paper: [Domain-Oriented Masking: Compact Masked Hardware Implementations with Arbitrary Protection Order](https://eprint.iacr.org/2016/486)

Side-channel protected hardware implementations of Ascon-128 and Ascon-128a by Hannes Groß using domain-oriented masking.

<a name="craft"></a>
## CRAFT

*This repository includes the hardware designs of CRAFT cipher*

* Developers: [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/CRAFT)
* Paper: [Lightweight Tweakable Block Cipher with Efficient Protection Against DFA Attacks. IACR Trans. Symmetric Cryptol. 2019](https://eprint.iacr.org/2019/210)

There are 6 folders for the VHDL source code of different implementations of CRAFT. Apart from the unprotected implementation, all other designs MUST be synthesized by "keeping the hierarchy". Otherwise, no fault-detection and no protection against SCA is guaranteed. (https://sites.google.com/view/craftcipher/implementation).

<a name="gift1"></a>
## GIFT
*This repository includes the hardware designs of GIFT cipher*

* Developers: [Anita Aghaie](https://www.emsec.ruhr-uni-bochum.de/chair/_staff/anita-aghaie/), [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/GIFT)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

Three types VHDL implementations of GIFT, can be found in this repository.

<a name="gimli"></a>
## Gimli

*Hardware implementation of Gimli*

* Developers: Daniel J. Bernstein, Stefan Kölbl, Stefan Lucks, Pedro Maat Costa Massolino, Florian Mendel, Kashif Nawaz, Tobias Schneider, Peter Schwabe, François-Xavier Standaert, Yosuke Todo, Benoît Viguier.
* [Official Website](http://gimli.cr.yp.to/index.html)
* Paper: [Gimli: a cross-platform permutation.](https://gimli.cr.yp.to/gimli-20170627.pdf)
* [Location within this repository](https://github.com/hadipourh/CryptoHDL/tree/master/gimli)

Gimli is a 384-bit permutation designed to achieve high security with high performance across a broad range of platforms, including 64-bit Intel/AMD server CPUs, 64-bit and 32-bit ARM smartphone CPUs, 32-bit ARM microcontrollers, 8-bit AVR microcontrollers, FPGAs, ASICs without side-channel protection, and ASICs with side-channel protection.

<a name="katan1"></a>
## KATAN

*Hardware implementation of KATAN*
* Developers: [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/KATAN)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)


Three types VHDL implementations of KATAN, can be found in this repository.

<a name="ktantan1"></a>
## KTANTAN

*Hardware implementation of KTANTAN*
* Developers: [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/KTANTAN)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

There are 3 folders for the VHDL source code of different implementations of KTANTAN in this repository.

<a name="klein1"></a>
## Klein

*A VHDL implementation of the Klein cipher*

* Developer: [Julian Harttung](https://github.com/huljar)
* [Official Repository](https://github.com/huljar/klein-vhdl)

This is an implementation of the KLEIN lightweight block cipher as described in [this paper](https://link.springer.com/chapter/10.1007/978-3-642-25286-0_1). It encrypts individual blocks of 64 bit length with either a 64, 80, or 96 bit key.

<a name="led128_1"></a>
## LED-128

*Hardware implementation of LED-128*
* Developers: [Anita Aghaie](https://www.emsec.ruhr-uni-bochum.de/chair/_staff/anita-aghaie/), [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/LED128)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

There are 3 folders for the VHDL source code of different implementations of LED-128 in this repository.

<a name="led64_1"></a>
## LED-64

*Hardware implementation of LED-64*
* Developers: [Anita Aghaie](https://www.emsec.ruhr-uni-bochum.de/chair/_staff/anita-aghaie/), [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/LED64)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

There are 3 folders for the VHDL source code of different implementations of LED-64 in this repository.

<a name="lowmc"></a>
## LowMC

*VHDL source code for LowMC*
* Developers: [Roman Walch](https://github.com/rw0x0)
* [Official Repository](https://github.com/IAIK/Picnic-FPGA)
* Paper: ["Efficient FPGA Implementations of LowMC and Picnic". Daniel Kales, Sebastian Ramacher, Christian Rechberger, Roman Walch, and Mario Werner](https://eprint.iacr.org/2019/1368.pdf)

FPGA implementation of Picnic and LowMC. 

 <a name="midori1"></a>
 ## Midori
 
 *Hardware implementation of Midori*
* Developers: [Anita Aghaie](https://www.emsec.ruhr-uni-bochum.de/chair/_staff/anita-aghaie/), [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/Midori)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

There are 3 folders for the VHDL source code of different implementations of Midori in this repository.

<a name="piccolo"></a>
## Piccolo

* Developers: [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/Piccolo)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

There are 3 folders for the VHDL source code of different implementations of Piccolo in this repository.

<a name="picnic"></a>
## Picnic

*VHDL source code for Picnic*
* Developers: [Roman Walch](https://github.com/rw0x0)
* [Official Repository](https://github.com/IAIK/Picnic-FPGA)
* Paper: ["Efficient FPGA Implementations of LowMC and Picnic". Daniel Kales, Sebastian Ramacher, Christian Rechberger, Roman Walch, and Mario Werner](https://eprint.iacr.org/2019/1368.pdf)

FPGA implementation of Picnic and LowMC.

<a name="present1"></a>
## PRESENT

*This repository includes the hardware designs of PRESENT cipher*
* Developers: [Anita Aghaie](https://www.emsec.ruhr-uni-bochum.de/chair/_staff/anita-aghaie/), [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/PRESENT)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

There are 3 folders for the VHDL source code of different implementations of PRESENT in this repository.

*A VHDL implementation of the PRESENT cipher*

* Developer: [Julian Harttung](https://github.com/huljar)
* [Official Repository](https://github.com/huljar/present-vhdl)

This is an implementation of the PRESENT lightweight block cipher as described in [this paper](https://link.springer.com/chapter/10.1007/978-3-540-74735-2_31). It encrypts individual blocks of 64 bit length with an 80 or 128 bit key. The desired key length can be set via the generic k (either K_80 or K_128).

<a name="prince1"></a>
## Prince

*A VHDL implementation of the Prince cipher*

* Developer: [Julian Harttung](https://github.com/huljar)
* [Official Repository](https://github.com/huljar/prince-vhdl)

This is an implementation of the PRINCE lightweight block cipher as described in [this paper](https://eprint.iacr.org/2012/529). It encrypts individual blocks of 64 bit length with a 128 bit key.

<a name="simon1"></a>
## Simon

*A VHDL implementation of the Simon cipher*

* Developers: [Anita Aghaie](https://www.emsec.ruhr-uni-bochum.de/chair/_staff/anita-aghaie/), [Amir Moradi](https://github.com/amircrypto001)
* [Official Repository](https://github.com/emsec/ImpeccableCircuits/tree/master/SIMON)
* Paper: ["Impeccable Circuits". Anita Aghaie, Amir Moradi, Shahram Rasoolzadeh, Aein Rezaei Shahmirzadi, Falk Schellenberg, Tobias Schneider.](https://eprint.iacr.org/2018/203)

There are 3 folders for the VHDL source code of different implementations of Simon in this repository.

<a name="skinny1"></a>
## Skinny

*Hardware implementation of Skinny64 and Skinny128 ciphers*

* Developers: [P. Sasdrich](https://www.emsec.ruhr-uni-bochum.de/chair/_staff/Pascal_Sasdrich/)
* [Official Website](https://sites.google.com/site/skinnycipher/implementation)
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
# Licenses
Two common types of licenses used in these repositories, are GPL, and BSD.
