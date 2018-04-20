## LinuxBoot

The main LinuxBoot repository can be found at
[github.com/linuxboot/linuxboot](https://github.com/linuxboot/linuxboot).

The website is at [www.linuxboot.org](https://www.linuxboot.org).

Two potential runtimes for LinuxBoot are HEADS and NERF:

*   [HEADS](https://github.com/osresearch/heads)
*   [NERF (LinuxBoot + u-root)](https://github.com/u-root/u-root)

### Supported OCP Hardware

|            | Winterfell     | Leopard        | Tioga Pass | Monolake   | Wedge      | Meaning |
| ---------- | -------------- | -------------- | ---------- | ---------- | ---------- | ------- |
| Sockets    | x2             | x2             | x2         | 4x1        | x1         | How many CPU sockets? |
| CPU        | E5-2600v1 & v2 | E5-2600v3 & v4 | Xeon Gold  | Broadwell  | Broadwell  | Chipset |
| Flash size | 16 MB          | 16 MB          | 32 MB      | 16 MB      | 16 MB      | Total SPI flash size |
| DXE Size   | 4.2 MB         | 4.8 MB         | 11 MB      | ?          | ?          | Space available for DXE, LinuxBoot and initrd |
| DxeCore    | No             | Yes            | Yes        | Not tested | Not tested | Can we replace the DxeCore with our own? |
| coreboot   | No             | No             | No         | Yes        | Yes        | Can we replace the PEI with coreboot+FSP? |
| BootGuard  | N/A            | N/A            | Yes        | Yes        | Yes        | Can we bypass the CPU's BootGuard security? |
| OpenBMC    | No             | No             | Yes        | Yes        | Yes        | Does the system support OpenBMC? |
| VGA        | No             | Yes            | Yes        | Yes        | No?        | Does the BMC expose a VGA framebuffer? |
| TPM        | N/A            | Not yet        | Not yet    | Not tested | Not tested | Does the x86 have a TPM that works with LinuxBoot? |
| LOM        | e1000e         | None           | None       | Maybe      | Yes?       | Is there a LAN-on-motherboard port? |
| PCIe       | Yes            | Yes            | Yes        | Yes        | Yes        | Do we support the PCIe slots? |
