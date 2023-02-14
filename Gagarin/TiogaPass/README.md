# OCP Tioga Pass Open System Firmware

## Features

* Boot options: SATA, NVME, USB, PXE, HTTP
* Boot methods: UEFI
* Interfaces: VGA interface, GUI interface
* Security features: TPM support, SecureBoot
* IPMI (Onetime boot)

## Build

### Pre-requisites

1. Windows 10
2. Visual Studio 2015 SP3 (Community Edition or Developer Edition or Enterprise Edition)
3. Python 3.7 (64 bit) and higher
   * Add this to your path
4. Python 2.7
   * Install into `C:\Python27`
5. ASL - http://www.acpica.org/
   * Install into `C:\ASL`
6. NASM - установлен в каталог **C:\NASM** - http://www.nasm.us/
   * Install into `C:\NASM`

### How To Build

1. Into that folder, clone:

```powershell
git clone https://github.com/tianocore/edk2-non-osi.git
git checkout 74d4da60a4

git clone https://github.com/tianocore/edk2.git
cd edk2
git checkout 497ac7b6d7
git submodule update --init
cd ..

git clone https://github.com/tianocore/edk2-platforms.git
cd edk2-platforms
git checkout c9e377b00f
cd ..
```
2. Apply patches:

```powershell
cd edk2-platforms
git apply ..\src\0001-SecureBoot-enabled.patch
git apply ..\src\0002-SMBIOS-strings-changed.patch
git apply ..\src\0003-Added-logo.patch
git apply ..\src\0004-Copy-bds-module-from-edk2.patch
git apply ..\src\0005-Added-bmc-ipmi-bootorder-control.patch
cd ..
```
3. Build firmware

```powershell
cd edk2-platforms\Platform\Intel\PurleyOpenBoardPkg\BoardTiogaPass
GitEdk2MinTiogaPass.bat
cd edk2-platforms\Platform\Intel\PurleyOpenBoardPkg\BoardTiogaPass
bld release
```

4. Final BIOS image will be Build\PurleyOpenBoardPkg\BoardTiagoPass\RELEASE_VS2015x86\FV\PLATFORM.fd
5. This BIOS image needs to be merged with Intel SPS binary

### How to flash

To flash, use the [flashrom](https://github.com/flashrom/flashrom) or others tools

## Test Report

| Test Criteria                                                | Result |
| ------------------------------------------------------------ | ------ |
| The platform with OSF must be capable of booting an operating system whose code is openly available under an OSI-approved license (such as Linux). | PASS   |
| Bare minimum: The platform with OSF needs to be able to be cold re-booted into OS 100 times sequentially without issue. | PASS   |
| If the system advertises support for a warm reboot, the platform flashed with OSF needs to be able to be warm re-booted into OS 100 times sequentially without issue. | PASS   |



| Configuration             | Value                                        |
| :------------------------ | :------------------------------------------- |
| UEFI                      | 0.1.2                                        |
| Intel ME firmware version | SPS 4.01.04.505.0                            |
| BMC                       | v1.12.11                                     |
| Base OS                   | CentOS Linux 8                               |
| Kernel                    | 4.18.0-240.e18.x86_64                        |
| Base Board SN             | 0001-1021-0009                               |
| CPU                       | 2x Intel(R) Xeon(R) Gold 6230R CPU @ 2.10GHz |
| Memory                    | 12x Samsung M393A1K43DB1-CVF                 |
| SATA                      | 4x INTEL SSDSC2KB240G8                       |
| NVME                      | INTEL SSDPEKKA128G7                          |
| PCIe                      | Mellanox ConnectX-4                          |



## Potential Gaps To Use OCP Tioga Pass OSF in Production

The OCP GAGAR>N OSF code base only supports Intel Server Platform Services (SPS) binary. Intel SPS binary is available under Intel agreement.
