# Chroniton

Chroniton is a tool for verifying constant-time behavior of cryptographic software. Instead of using leakage models, Chroniton directly verifies software with respect to a hardware implementation at the RTL level.

For more details on Chroniton, see the [paper]() or slides ([.key](https://anish.io/files/chroniton:plarch23-slides.key), [.pdf](https://anish.io/files/chroniton:plarch23-slides.pdf)).

## Organization

This repository contains the Chroniton Racket library (in `chroniton/`) and a number of examples (in `examples/`), including both expository examples as well as examples verifying cryptographic code on various hardware.

## Examples

### Hardware

Located in `examples/hardware/`.

- [**PicoRV32**](https://github.com/YosysHQ/picorv32/commit/f00a88c36eaab478b64ee27d8162e421049bcc66): a tiny RISC-V CPU. This repository also contains a simple SoC built around it.
- [**biRISC-V**](https://github.com/ultraembedded/biriscv/commit/6af9c4be5a0807d368eaad5e49af52322e31d073): a dual-issue in-order 6-stage-pipelined RISC-V CPU. This repository contains a slightly modified version of the CPU (to work with our Verilog-to-Rosette pipeline, removing async resets for example) and a modified version of the testbench to serve as a simple model of a SoC.
- [**OpenTitan Big Number Accelerator (OTBN)**](https://github.com/lowRISC/opentitan/tree/e1d873a8f9fb349de8f312c9d7aae7b140c6615c/hw/ip/otbn): a cryptographic accelerator in the OpenTitan. This repository contains a heavily modified version of the OTBN, to make it work as a standalone device and to simplify it. Simplifications include removing memory scrambling and removing SECDED encoding.

### Software

Located in `examples/software/`.

- `mul64`: an expository example, a program that multiplies two 64-bit numbers together on a RISC-V processor.
- `branch-padding`: a program that demonstrates branching with padding for overall constant-time behavior. The padding is tuned for the PicoRV32, so it'll verify against that, but when run on the biRISC-V, it will not have constant-time behavior (which is caught by Chroniton).
- [`ed25519`](https://github.com/orlp/ed25519/commit/b1f19fab4aebe607805620d25a5e42566ce46a0e): an off-the-shelf C implementation of Ed25519 signatures, along with some driver code. This runs on the RISC-V processors.
- `wadd`: an expository example, a program that adds two 256-bit numbers together using the `bn.add` instruction on the OTBN.
- [`x25519`](https://github.com/lowRISC/opentitan/blob/e1d873a8f9fb349de8f312c9d7aae7b140c6615c/sw/otbn/crypto/x25519.s): an off-the-shelf OTBN assembly implementation of X25519 key exchange, along with some driver code.

## Usage

To build hardware implementations, run `make` in the corresponding directory to synthesize Racket code from the Verilog. For performance, you should compile the Racket code ahead of time with `raco make {name}.rkt`. This can take up to 1 minute (for `otbn.rkt`). To build software, run `make` in the corresponding directory to produce memory images.

The `examples/` directory contains the top-level Chroniton invocation, including the "hints", the untrusted proof input Chroniton uses to improve performance, for all the examples. The naming convention is `{hardware name}-{software name}.rkt`, so e.g., to run the `mul64` example on the `biriscv`, run `racket biriscv-mul64.rkt`.

## Docker image

We provide a [Docker
image](https://hub.docker.com/repository/docker/anishathalye/chroniton) that
includes all the dependencies. You can download it with `docker pull
anishathalye/chroniton`.

To mount the repository on `/chroniton` and get a shell in the Docker image,
run:

```bash
docker run -it --rm -v "${PWD}/:/chroniton" -w /chroniton anishathalye/chroniton
```

## Dependencies

If you want to install the dependencies locally, here is what you need:

- [RISC-V compiler toolchain](https://github.com/riscv/riscv-gnu-toolchain)
- [OTBN toolchain](https://github.com/lowRISC/opentitan/tree/master/hw/ip/otbn/util)
- [sv2v](https://github.com/zachjs/sv2v)
- [Yosys](https://github.com/YosysHQ/yosys)
- [bin2coe](https://github.com/anishathalye/bin2coe)
- [Racket](https://racket-lang.org/)
- [Rosette](https://github.com/emina/rosette)
- [Knox](https://github.com/anishathalye/knox)

## Citation

```bibtex
@inproceedings{chroniton:plarch23,
    author =    {Anish Athalye and M. Frans Kaashoek and Nickolai Zeldovich and Joseph Tassarotti},
    title =     {Leakage models are a leaky abstraction: the case for cycle-level verification of constant-time cryptography},
    month =     {jun},
    year =      {2023},
    booktitle = {1st Workshop on Programming Languages and Computer Architecture~(PLARCH)},
    address =   {Orlando, FL},
}
```
